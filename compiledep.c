/* compile, but capture stderr. if "fatal error: X.h: No such file or directory"
	 then add make rule ourtarget: X.h, then $(MAKE) X.h, then recompile
*/

int main(int argc, char *argv[])
{
	struct pat {
		pcre* pat;
		pcre_extra* study;
		pcre_jit_stack* stack;
	};

	struct pat nosuchfile = {
		.pat = pcre_compile("^([^:]+):.*? fatal error: ([^:]+): No such file or directory$");
	};
	assert(nosuchfile.pat);
	const char* errstr = NULL;
	nosuchfile.study = pcre_study(nosuchfile.pat, PCRE_STUDY_JIT_COMPILE, &errstr);
	assert(nosuchfile.study);

	nosuchfile.stack = pcre_jit_stack_alloc(0x1000,0x10000);

	char* line = NULL;
	size_t space = 0;
#define ovecsize = 6 * 3 / 2;
	int ovec[ovecsize] = {};

	for(;;) {
		char template[] = ".tmpXXXXXX";
		int err = mkstemp(template);
		unlink(template);
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
		ensure0(stat(err,&info));
		const char* mem = mmap(NULL, info.st_size, PROT_READ, MAP_PRIVATE, err, 0);
		ensure_ne(mem, MAP_FAILED);
		close(err);

		const char* cur = mem;
		size_t offset = 0;
		while(offset < info.st_size) {
			int res = pcre_jit_exec(nosuchfile.pat, nosuchfile.study,
															mem, info.st_size, offset,
															0, // options
															ovec, ovecsize);
			
		}
		
	return 0;
}
