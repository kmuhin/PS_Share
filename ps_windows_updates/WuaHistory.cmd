rem @echo off

rem set filelog="%~dpn0.%COMPUTERNAME%.%DATE%.log"
set filelog="%~dp0LOG\%~n0.%COMPUTERNAME%.%DATE%-%TIME::=%.log"
echo %filelog%
echo %DATE% %TIME% START >> %filelog%
echo %0 %* >> %filelog%
powershell -File "%~dpn0.ps1" %* 2>&1 >> %filelog% 
echo %DATE% %TIME% END >> %filelog%

cd "%~dp0\LOG\"
forfiles /M "*.log" /D -120 /C "cmd /c del @file"