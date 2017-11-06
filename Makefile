# this makes coolmake. see Makefile.example for how to use otherwise

COOLMAKE=.

include head.mk
include top.mk

define CLONE =
ifeq ($(wildcard ~/code/mystuff),)
$(dest):
	git clone $(remote) $(dest).temp
	cd $(dest).temp && git remote add local $(local)
	mv $(dest).temp $(dest)
else
$(dest):
	git clone $(local) $(dest).temp
	cd $(dest).temp && git remote set-url origin $(remote) && git remote add local $(local)
	mv $(dest).temp $(dest)
endif
endef 

local:=~/code/mystuff
remote:=https://github.com/cyisfor/cyutil/
dest:=mystuff
$(eval $(CLONE))

local:=~/code/note
remote:=https://github.com/cyisfor/note/
dest:=note
$(eval $(CLONE))

all: compiledep

CFLAGS+=-ggdb
VPATH+=mystuff/src
VPATH+=note/src
CFLAGS+=-I.
CFLAGS+=-Imystuff/src
CFLAGS+=-Inote/

LDLIBS+=-lpcre

N=compiledep note/note
compiledep: $(OBJECTS)
	$(LINK)

N=compiledep
$(OBJECTS): src/compiledep.c | note mystuff
	$(COMPILE)

N=note/note
$(OBJECTS): note/note.c | note $(O)
	$(COMPILE)

testcompiledep: COMPILE_PREFIX:=+./compiledep #
testcompiledep: o/testcompiledep.o compiledep
	$(LINK)
o/testcompiledep.o: src/testcompiledep.c
	$(COMPILE)

o/gen1.h:
	echo "#include \"o/gen2.h\"" > $@

o/gen2.h:
	echo "static char makeflags[] = \"$(MAKEFLAGS)\";" >$@

include tail.mk
