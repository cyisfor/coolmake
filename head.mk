all: # have stuff depend on this to be built

define PUSHVARS
define POPVARS :=
O=$(O)
TOP=$(TOP)
define POPVARS :=
$(POPVARS)
endef
endef
endef
$(eval $(PUSHVARS))

VPATH+=src

COOLMAKE?=coolmake
# include $(COOLMAKE)/top.mk


# pkg-config stuff
# lazy evaluation, so we can't use ifeq()
CFLAGS+=$(if $(P),$(shell pkg-config --cflags $(P)))
LDLIBS+=$(if $(P),$(shell pkg-config --libs $(P)))

CFLAGS+=-fdiagnostics-color=auto

# any includes that are target specific, just set INC=
CFLAGS+=$(patsubst %,-I%,$(INC))
#INC:=otherinclude


ifeq ($(V),)
MAKEFLAGS+=-s
endif

O:=o # switch to $(TOP)o later

# switch all names for object names, and add those names to the list of module names compiled
# since this is lazy, $N will be different if we assign it, then access $(O)
#every link depends on ALLN
#ALLN=common ferrets note
define commit_objects =
mods:=$$(sort $$(mods) $(N))
endef

define OBJ =
$(patsubst %,$(O)/%.lo,$N $(ALLN))
endef

define OBJECTS =
$(OBJ)\
$(eval $(commit_objects)) 
endef

# libtool needs to be told to be quiet
# $(S) will be @ except when V=1
LIBTOOL:=libtool --tag=CC 
ifeq ($(V),)
S:=@
LIBTOOL+=--quiet 
else
S:=
endif
LIBTOOL+=--mode=

all:
	@$(call STATUS,DONE)

$(guile (load "$(COOLMAKE)/status.scm"))
STATUS=$(guile (status "$1" "$2"))


# generate stuff like programs, libraries, and object files
# since these are lazy, will handle any target specific CFLAGS or w/ev (like INC)
# note, libtool takes care of adding -shared or -fPIC or whatever
define LINK =
	$(call STATUS,Link,$(or $*, $(notdir $@)))
	$(S)$(LIBTOOL)link $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)
endef
define COMPILE =
	$(call STATUS,Compile,$(or $*, $(basename $(notdir $@))))
	$(S)$(COMPILE_PREFIX)$(LIBTOOL)compile $(CC) -MF $(addsuffix .d, $(basename $<)) -MT "$@ $(addsuffix .d, $(basename $<))" -MMD $(CFLAGS) -c -o $@ $(filter %.c,$^)
endef
define COMPILEDEP =
	$(call STATUS,Dependency,$(or $*, $(basename $(notdir $@))))
	$(S)$(COMPILE_PREFIX)$(LIBTOOL)compile $(CC) -MF $@ -MT "$(addsuffix .lo, $(basename $@)) $@" -MM $(CFLAGS) $<
endef
define SYMLINK =
	ln -rs $(or $<,$|) $@
endef

# example:
# N=main module
# main: $(OBJECTS)
# 	$(LINK)


define AUTOMAKE_SUBPROJECT_SCRIPT =
VPATH+=$1
$1/$2.la: $1/Makefile | $1
	$$(MAKE) -C $1 $2.la

$1/Makefile: $1/configure
	./configure

$1/configure: $1/configure.ac
	sh $(COOLMAKE)/smartautogen.sh $1
endef

# call this with the location, and the library name (libxml2, libxml2) etc
AUTOMAKE_SUBPROJECT=$(eval $(call AUTOMAKE_SUBPROJECT_SCRIPT,$1,$2))

define REQUIRE_VAR =
ifeq ($$$1,)
$$(error provide $1)
endif
endef

$(guile (load "$(COOLMAKE)/clonepull.scm"))
CLONEPULL=$(guile (clonepull))

data_to_header_string/pack: | data_to_header_string
	cd data_to_header_string && ninja

define PACK =
o/$(dir $F): | o
	$$(call STATUS,Directory,$$@)
	$$(S)mkdir $$@

o/$F.pack.c: $F data_to_header_string/pack | o o/$(dir $F)
	@echo PACK $F $N
	$$(S)name=$N ./data_to_header_string/pack < $F >$$@.temp
	$$(S)mv $$@.temp $$@
endef

# this is a common packing thing I like to use...

data_to_header_string:
	git clone https://github.com/cyisfor/data_to_header_string

# N=schema
# F=sql/search_schema.sql
# $(eval $(PACK))

clean:
	git clean -ndx
	@echo ^C to not delete
	@read
	git clean -fdx

.PHONY: all clean

