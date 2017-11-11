# make a main.mk
# make a Makefile that includes coolmake/main.mk
# go
include coolmake/head.mk
include main.mk
include coolmake/tail.mk

git-tools/funcs.sh: | git-tools
	git submodule update --init

git-tools:
	git submodule add -b master https://github.com/cyisfor/git-tools
	cd git-tools && git commit -a -m 'git-tools submodule'

.PRECIOUS: coolmake/main.mk # wtf
