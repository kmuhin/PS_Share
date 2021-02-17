@echo off

cd "%~dp0\history\"

set age="-30"

set filelist="history-%COMPUTERNAME%.%DATE%"

forfiles /M  "*.txt"  /D %age% > "%filelist%.list"

"C:\Program Files\7-Zip\7z.exe" a "%filelist%.7z" @"%filelist%.list"

if {%ERRORLEVEL%} EQU {0} (
	forfiles /M  "*.txt"  /D %age% /C "cmd /c del @file"
)