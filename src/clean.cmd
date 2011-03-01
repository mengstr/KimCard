@echo off
rem ***
rem *** Cleans up all temporary and files that that will be reproduced by a build
rem ***

echo.
echo/|set /p =Cleaning directory...

type NUL>foo.bak && erase/q *.bak
type NUL>foo.hex && erase/q *.hex 
type NUL>foo.map && erase/q *.map
type NUL>foo.obj && erase/q *.obj
type NUL>foo.tmp && erase/q *.tmp
type NUL>foo.aws && erase/q *.aws
type NUL>foo.bat && erase/q *.bat


echo/|set /p =Done.
echo.

timeout 3
