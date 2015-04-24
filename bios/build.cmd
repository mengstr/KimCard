@echo off

..\utils\xasm.exe /l bios-kim1.a6502
..\utils\bin2inc.exe bios-kim1.obx tmp.tmp 6 > bios-kim1.inc

echo.
echo BIOS-KIM1.INC generated.
echo.

:eof
timeout 3

