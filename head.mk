all: # have stuff depend on this to be built

VPATH+=src

# lazy evaluation, so we can't use ifeq()
CFLAGS+=$(if $(P),$(shell pkg-config --cflags $(P)))
LDLIBS+=$(if $(P),$(shell pkg-config --libs $(P)))

CFLAGS+=-fdiagnostics-color=auto

# any includes that are target specific, just set INC=
CFLAGS+=$(patsubst %,-I%,$(INC))
#INC:=otherinclude

O:=o # switch to $(TOP)o later

# switch all names for object names, and add those names to the list of module names compiled
# since this is lazy, $N will be different if we assign it, then access $(O)
#every link depends on ALLN
#ALLN=common ferrets note
OBJECTS=$(patsubst %,$(O)/%.lo,$N $(ALLN)) \
$(eval mods:=$$(mods) $(N))

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

COLOR.reset:=$$'\x1b[0m'
COLOR.grey:=$$'\x1b[01;30m'
COLOR.red:=$$'\x1b[01;31m'
COLOR.green:=$$'\x1b[01;32m'
COLOR.yellow:=$$'\x1b[01;33m'
COLOR.blue:=$$'\x1b[01;34m'
COLOR.pink:=$$'\x1b[01;35m'
COLOR.cyan:=$$'\x1b[01;36m'
COLOR.white:=$$'\x1b[01;37m'

all:
	@echo $(COLOR.green)DONE

STATUS=@echo $(COLOR.white)$1 $(COLOR.yellow)$2$(COLOR.reset)

# generate stuff like programs, libraries, and object files
# since these are lazy, will handle any target specific CFLAGS or w/ev (like INC)
# note, libtool takes care of adding -shared or -fPIC or whatever
define LINK =
	$(call STATUS,Link,$(or $*, $(notdir $@)))
	$(S)$(LIBTOOL)link $(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)
endef
define COMPILE =
	$(call STATUS,Compile,$(or $*, $(basename $(notdir $@))))
	$(S)$(LIBTOOL)compile $(CC) -MF $(addsuffix .d, $(basename $<)) -MT $@ -MMD $(CFLAGS) -c -o $@ $<
endef

# example:
# N=main module
# main: $(OBJECTS)
# 	$(LINK)


define AUTOMAKE_SUBPROJECT_SCRIPT =
VPATH+=$1
$1/$2.la: $1/Makefile
	$$(MAKE) -C $1 $2.la

$1/Makefile: $1/configure
	./configure

$1/configure: $1/configure.ac
	sh coolmake/smartautogen.sh $1
endef

# call this with the location, and the library name (libxml2, libxml2) etc
AUTOMAKE_SUBPROJECT=$(eval $(call AUTOMAKE_SUBPROJECT_SCRIPT, $1, $2))

define REQUIRE_VAR =
ifeq ($$$1,)
$$(error provide $1)
endif
endef

$(guile (load "coolmake/clonepull.scm"))
CLONEPULL=$(guile (clonepull))

data_to_header_string/pack: | data_to_header_string
	cd data_to_header_string && ninja

define PACK =
o/$(dir $F): | o
	mkdir $$@

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

