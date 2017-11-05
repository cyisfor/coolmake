# this makes coolmake. see Makefile.example for how to use otherwise

define CLONE =
ifeq ($(guile (stat "$(local)")),)
$(dest):
	git clone $(remote) $(dest).temp
	cd $(dest).temp && git remote add local $(local)
	mv $(dest).temp $(dest)
else
$(dest):
	git clone $(local) $(dest).temp
	cd $(dest).temp && git remote set-url origin $(remote) && git remote add local $(local)
	mv $(dest).temp $(dest)

local:=~/code/mystuff
remote:=https://github.com/cyisfor/cyutil/
dest:=mystuff
$(CLONE)
