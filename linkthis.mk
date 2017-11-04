include coolmake/head.mk
include main.mk
include coolmake/tail.mk

git-tools/funcs.sh: | git-tools
	git submodule update --init

git-tools:
	git submodule add -b master https://github.com/cyisfor/git-tools
	git commit -a -m 'git-tools submodule'

coolmake/head.mk:
	sh setup.sh
coolmake/tail.mk libxml2/include: ;
