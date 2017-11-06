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

compiledep: COMPILE_PREFIX:=

N=note/note
$(OBJECTS): note/note.c | note $(O)
	$(COMPILE)

testcompiledep: COMPILE_PREFIX:=+./compiledep #

N=testcompiledep
$(N): o/$(N).lo
	$(LINK)
o/$(N).lo: src/testcompiledep.c compiledep
	$(COMPILE)

all: testcompiledep

o/gen1.h:
	$(call STATUS,Gen,1)
	$(S)echo "#include \"o/gen2.h\"" > $@

o/gen2.h:
	$(call STATUS,Gen,2)
	$(S)echo "static char makeflags[] = \"$(MAKEFLAGS)\";" >$@

include tail.mk

