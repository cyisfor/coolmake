#include "ensure.h"
#include "mystring.h"

#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/stat.h>

#include <pcre.h>

#include <unistd.h> // fork, write, unlink, etc
#include <fcntl.h> // open, O_*
#include <stdlib.h> // mkstemp
#include <signal.h>

#include <assert.h>


/* compile, but capture stderr. if "fatal error: X.h: No such file or directory"
	 then add make rule ourtarget: X.h, then $(MAKE) X.h, then recompile
*/

int main(int argc, char *argv[])
{
	if(argc <= 2) exit(1);
	
	struct pat {
		pcre* pat;
		pcre_extra* study;
		pcre_jit_stack* stack;
	};

	const char* errstr = NULL;
	int erroff = 0;
	struct pat nosuchfile = {
		.pat = pcre_compile("^([^:]+):.*? fatal error: ([^:]+): No such file or directory$",
												PCRE_MULTILINE,
												&errstr, &erroff,
												NULL)
	};
	assert(nosuchfile.pat);
	nosuchfile.study = pcre_study(nosuchfile.pat, PCRE_STUDY_JIT_COMPILE, &errstr);
	assert(nosuchfile.study);

	nosuchfile.stack = pcre_jit_stack_alloc(0x1000,0x10000);

	char* line = NULL;
	size_t space = 0;
	// whole match, first subexp, second subexp, then 3/2 extra space.
#define ovecsize (6 * 3 / 2)
	int ovec[ovecsize] = {};

	for(;;) {
		char template[] = ".tmpXXXXXX";
		int err = mkstemp(template);
		ensure_ge(err, 0);
		//unlink(template);

		int pid = fork();
		if(pid == 0) {
			dup2(err,2);
			close(err);
			execvp(argv[1], argv+1);
			abort();
		}
		int status = 0;
		waitpid(pid, &status, 0);
		if(WIFEXITED(status) && 0 == WEXITSTATUS(status)) {
			// success!
			break;
		}
		struct stat info;
		ensure0(fstat(err,&info));
		const char* mem = mmap(NULL, info.st_size, PROT_READ, MAP_PRIVATE, err, 0);
		ensure_ne(mem, MAP_FAILED);
		close(err);

		size_t offset = 0;
		while(offset < info.st_size) {
			int res = pcre_jit_exec(nosuchfile.pat, nosuchfile.study,
															mem, info.st_size, offset,
															0, // options
															ovec, ovecsize,
															nosuchfile.stack);
			if(res != 3) break;
			// 2 substrings captured

			string source = { mem+ovec[2],ovec[3]-ovec[2] };
			string header = { mem+ovec[4],ovec[5]-ovec[4] };

			int gen = open("gendeps.d",O_WRONLY|O_APPEND|O_CREAT,0644);
			ensure_ge(gen,0);

			write(gen,source.s, source.l);
			write(gen, LITLEN(" o/gendeps.d: "));
			write(gen, header.s, header.l);
			write(gen, LITLEN("\n"));
			close(gen);

			int makepid = fork();
			if(makepid == 0) {
				char* headerp = malloc(header.l+1);
				memcpy(headerp,header.s,header.l);
				headerp[header.l] = '\0';
				
				execlp("make","make", headerp, NULL);
				abort();
			}
			waitpid(makepid,&status, 0);
			if(WIFEXITED(status)) {
				if (0 != WEXITSTATUS(status)) {
					exit(WEXITSTATUS(status));
				}
			} else {
				raise(WTERMSIG(status));
			}

			offset = ovec[1]+1;
		}
	}
	return 0;
}
