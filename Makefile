# this makes coolmake. see Makefile.example for how to use otherwise

COOLMAKE=.

include head.mk
include top.mk

define CLONE =
ifeq ($(wildcard $(local)),)
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
update: $(dest)-update
$(dest)-update: | $(dest)
	cd $| && git pull $(local)
ifeq ($(noremote),)
	cd $| && git pull $(remote)
endif
.PHONY: $(dest)-update
endef
.PHONY: update

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
VPATH+=note/
CFLAGS+=-I.
CFLAGS+=-Imystuff/src
CFLAGS+=-Inote/

LDLIBS+=-lpcre

N=compiledep note itoa
compiledep: $(OBJECTS)
	$(LINK)

N=compiledep
$(OBJECTS): src/compiledep.c | note
	$(COMPILE)
# XXX: make seems to only consider the first order-only thingie in a rule
$(OBJECTS): | mystuff

compiledep: COMPILE_PREFIX:=

N=itoa
$(OBJECTS): mystuff/src/itoa.c | $(O)
	$(COMPILE)
mystuff/src/itoa.c: | mystuff

N=note
$(OBJECTS): note/note.c | $(O)
	$(COMPILE)
note/note.c: | note

testcompiledep:

N=testcompiledep
$(N): $(OBJECTS)
	$(LINK)

o/$(N).d: COMPILE_PREFIX=+./compiledep $@ #
o/$(N).d: compiledep

o/$(N).lo: src/testcompiledep.c compiledep
	$(COMPILE)

all: testcompiledep

o/gen1.h: | o
	$(call STATUS,Gen,1)
	$(S)echo "#include \"o/gen2.h\"" > $@

o/gen2.h: | o
	$(call STATUS,Gen,2)
	$(S)echo "#include \"o/gen3.h\"" > $@

o/gen3.h: | o
	$(call STATUS,Gen,3)
	$(S)echo "static char makeflags[] = \"$(MAKEFLAGS)\";" >$@

include tail.mk
-include o/lostdeps.d
