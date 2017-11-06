o/testcompiledep.lo src/testcompiledep.c o/lostdeps.d: o/gen1.h
o/testcompiledep.d ./o/gen1.h o/lostdeps.d: o/gen2.h
o/lostdeps.d: src/testcompiledep.c
o/testcompiledep.d: doesntwork.h
o/testcompiledep.lo src/testcompiledep.c o/lostdeps.d: doesntwork.h
