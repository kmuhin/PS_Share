@echo off

set filelog="%~dpn0.%COMPUTERNAME%.%DATE%.log"
echo %filelog%
echo %DATE% %TIME% START >> %filelog%
powershell -File "%~dpn0.ps1" %* 2>&1 >> %filelog% 
echo %DATE% %TIME% END >> %filelog%

cd "%~dp0"
forfiles /M "*.log" /D -30 /C "cmd /c del @file"
