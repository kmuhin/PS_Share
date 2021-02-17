@echo off

set USERNAME=User
set TASKSFILE="%~dpn0.txt"
set PWD=%~dp0
echo %TASKSFILE%
FOR /F "usebackq tokens=*" %%i in (%TASKSFILE%) do (
	echo %%i
	schtasks.exe /delete /TN "%%~ni"
  	schtasks.exe /create /TN "%%~ni" /XML "%PWD%\%%~ni.xml" /RU %USERNAME%
)