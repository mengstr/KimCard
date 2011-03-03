@echo off
rem ***
rem *** Cleans up all temporary and files that that will be reproduced by a build
rem ***

echo/|set /p =Cleaning directory...

mkdir Debug\foo
rmdir /Q /S Debug

type NUL>foo.bak && erase/q *.bak
type NUL>foo.hex && erase/q *.hex 

echo Done.

IF "%1"=="/NODELAY" GOTO Continue
timeout 3
:Continue

