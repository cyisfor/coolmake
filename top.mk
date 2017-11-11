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
VPATH+=$(TOP)src
endif

O:=$(TOP)o

ifeq ($(wildcard $(TOP)src),)
SRC?=$(TOP)
else
SRC?=$(TOP)src
endif

$(O)/%.lo: $(SRC)/%.c | $(O)
	$(COMPILE)

$(O)/%.d: $(SRC)/%.c | $(O)
	$(COMPILEDEP)
	$(eval LASTDEP?=$@)

define PROGRAM
$(TOP)$(OUT): $(OBJECTS)

$(OBJECTS): | $(O)

$(TOP)$(OUT): $(TOP)%:
$(value LINK)
endef

# N=a b c d
# OUT=foo
# $(eval $(PROGRAM))

$(O):
	$(call STATUS,Directory,$@)
	$(S)mkdir $@
