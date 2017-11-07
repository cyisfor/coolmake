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

$(O)/%.lo: $(TOP)src/%.c | $(O)/%.d $(O)
	$(COMPILE)

$(O)/%.d: $(TOP)src/%.c | $(O)
	$(COMPILEDEP)
	$(eval LASTDEP?=$@)

REDEPENDENCY=echo eh

define PROGRAM_template
$$(TOP)$$(OUT): $$(OBJECTS)

$$(TOP)$$(OUT): $$(TOP)%:
$$(value LINK)

$$(OBJECTS): $$(O)/$(ORULE)
$$(value COMPILE)

$$(DEPENDENCIES): $$(O)/$(DRULE)
$$(value COMPILEDEP)
endef
# it looks prettier if we don't have to $$ everywhere

ORULE=%.lo: %.c
DRULE=%.d: %.c
$(eval P2:=$(PROGRAM_template))
$(error $(P2))
$(error $(value PROGRAM_template3))

N=a b c d
OUT=foo
$(call PROGRAM)

define OBJECT
$(O)/$(OUT).lo: $(N).c
endef

$(O):
	$(call STATUS,Directory,$@)
	$(S)mkdir $@
