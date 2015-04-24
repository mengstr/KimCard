@echo off

..\utils\xasm.exe /l test6502.a6502
copy test6502.obx test6502.bin
..\utils\bin2hex.exe /I6 test6502.bin

rem ***
rem *** Converts the .HEX -file to .INC 
rem ***
rem ***
rem *** .HEX format
rem ***
rem *** :2000000085F36885F16885EF85FA6885F085FB84F486F5BA86F220881E4C4F1C6CF6006C62
rem *** :20002000ED00A2FF9A86F220881E000000000000000000000000000000000000000000005A
rem ***
rem *** .INC format
rem ***
rem ***    .db 0x85, 0xF3, 0x68, 0x85, 0xF1, 0x68, 0x85, 0xEF, 0x85, 0xFA, 0x68, 0x85, 0xF0, 0x85, 0xFB, 0x84, 0xF4, 0x86, 0xF5, 0xBA, 0x86, 0xF2, 0x20, 0x88, 0x1E, 0x4C, 0x4F, 0x1C, 0x6C, 0xF6, 0x00, 0x6C  
rem ***    .db 0xED, 0x00, 0xA2, 0xFF, 0x9A, 0x86, 0xF2, 0x20, 0x88, 0x1E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  
rem ***
 


setLocal EnableDelayedExpansion

type NUL > tmp.tmp
for /f "tokens=* delims= " %%a in (test6502.hex) do (
	set b=%%a0000000000000000000000000000000000000000000000000000000000000000
	echo !b! 

	set bytecount=!b:~1,2!
	IF NOT !bytecount!==00 (
		echo/|set /p =____.db 0x!b:~9,2!, >> tmp.tmp
		echo/|set /p =0x!b:~11,2!, >> tmp.tmp
		echo/|set /p =0x!b:~13,2!, >> tmp.tmp
		echo/|set /p =0x!b:~15,2!, >> tmp.tmp
		echo/|set /p =0x!b:~17,2!, >> tmp.tmp
		echo/|set /p =0x!b:~19,2!, >> tmp.tmp
		echo/|set /p =0x!b:~21,2!, >> tmp.tmp
		echo/|set /p =0x!b:~23,2!, >> tmp.tmp
		echo/|set /p =0x!b:~25,2!, >> tmp.tmp
		echo/|set /p =0x!b:~27,2!, >> tmp.tmp
		echo/|set /p =0x!b:~29,2!, >> tmp.tmp
		echo/|set /p =0x!b:~31,2!, >> tmp.tmp
		echo/|set /p =0x!b:~33,2!, >> tmp.tmp
		echo/|set /p =0x!b:~35,2!, >> tmp.tmp
		echo/|set /p =0x!b:~37,2!, >> tmp.tmp
		echo/|set /p =0x!b:~39,2!, >> tmp.tmp

		echo/|set /p =0x!b:~41,2!, >> tmp.tmp
		echo/|set /p =0x!b:~43,2!, >> tmp.tmp
		echo/|set /p =0x!b:~45,2!, >> tmp.tmp
		echo/|set /p =0x!b:~47,2!, >> tmp.tmp
		echo/|set /p =0x!b:~49,2!, >> tmp.tmp
		echo/|set /p =0x!b:~51,2!, >> tmp.tmp
		echo/|set /p =0x!b:~53,2!, >> tmp.tmp
		echo/|set /p =0x!b:~55,2!, >> tmp.tmp
		echo/|set /p =0x!b:~57,2!, >> tmp.tmp
		echo/|set /p =0x!b:~59,2!, >> tmp.tmp
		echo/|set /p =0x!b:~61,2!, >> tmp.tmp
		echo/|set /p =0x!b:~63,2!, >> tmp.tmp
		echo/|set /p =0x!b:~65,2!, >> tmp.tmp
		echo/|set /p =0x!b:~67,2!, >> tmp.tmp
		echo/|set /p =0x!b:~69,2!, >> tmp.tmp
		echo 0x!b:~71,2! >> tmp.tmp
	)
)

type NUL > test6502.inc
echo. >> test6502.inc
echo %; START OF TEST6502 >> test6502.inc
for /f "tokens=* delims= " %%b in (tmp.tmp) do (
	set c=%%b
	echo !c:_= ! >> test6502.inc
)
echo %; END OF TEST6502 >> test6502.inc
echo. >> test6502.inc

erase tmp.tmp

echo.
echo TEST6502.INC generated.
echo.

:eof
timeout 3

