@echo off
rem ***
rem *** Cleans up all temporary and files that that will be reproduced by a build
rem ***

echo.
echo/|set /p =Cleaning directory...

mkdir Debug\foo
rmdir /Q /S Debug

type NUL>foo.bak && erase/q *.bak
type NUL>foo.hex && erase/q *.hex 

echo/|set /p =Done.
echo.

timeout 3
