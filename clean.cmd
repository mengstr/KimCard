@echo off
rem ***
rem *** Cleans up all temporary and files and all directories of the project
rem ***

echo.

type NUL>foo.bak && erase/q *.bak

echo Cleaning directory TEST
cd test
call clean.cmd
cd ..

echo Cleaning directory BIOS
cd bios
call clean.cmd
cd ..

echo Cleaning directory KIMCARD
cd kimcard
call clean.cmd
cd ..

echo All done.
echo.

timeout 3
