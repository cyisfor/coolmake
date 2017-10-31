# let us figure out where we actually are, for output purposes

# this can't go in head.mk, because EVERY level must include it, to get their own top

ifeq ($(words $(MAKEFILE_LIST)),2)
# top level, since it'll also have coolmake/head.mk in it, so 2
else
# coolmake/head.mk is the lastword, so we need the SECOND to last word...
# so be sneaky, and prepend a value, then wordlist by the original length, to get a
# list with the second value at the end.

num:=$(words $(MAKEFILE_LIST))
TOP:=$(wordlist 1,$(num),dummyprefixthing $(MAKEFILE_LIST))
TOP:=$(dir $(lastword $(TOP)))
endif

O:=$(TOP)o

define PROGRAM
$(OUT): $(OBJECTS)
	$(LINK)
endef


# generate objects, and also update .d files
# this is a really sneaky trick, so I'll explain
# thanks to Tom Tromney I guess for this trick (whoever he is)
# http://make.mad-scientist.net/papers/advanced-auto-dependency-generation/

define OBJECT
$(O)$(N).lo: $(N).c $(O)$(N).d | $(O)
	$(COMPILE)
endef

$(TOP)o:
	mkdir $@
