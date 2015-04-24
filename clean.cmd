@echo off
rem ***
rem *** Cleans up all temporary and files and all directories of the project
rem ***

echo.

type NUL>foo.bak && erase/q *.bak

echo TEST
cd test
call clean.cmd /NODELAY
cd ..

echo BIOS
cd bios
call clean.cmd /NODELAY
cd ..

echo KIMCARD
cd kimcard
call clean.cmd /NODELAY
cd ..

echo.
echo All done.
echo.

timeout 5
