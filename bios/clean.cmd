@echo off
rem ***
rem *** Cleans up all temporary and files that that will be reproduced by a build
rem ***

echo.
echo/|set /p =Cleaning directory...

type NUL>tmp.tmp && erase/q tmp.tmp
type NUL>foo.bak && erase/q *.bak
type NUL>foo.lst && erase/q *.lst 
type NUL>foo.obx && erase/q *.obx
type NUL>foo.bin && erase/q *.bin
type NUL>foo.hex && erase/q *.hex
type NUL>foo.inc && erase/q *.inc


echo/|set /p =Done.
echo.

timeout 3
