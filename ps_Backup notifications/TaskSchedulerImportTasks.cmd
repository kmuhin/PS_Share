@echo off

set TASKSFILE="%~dpn0.txt"
echo %TASKSFILE%
FOR /F "usebackq tokens=*" %%i in (%TASKSFILE%) do (
	echo %%i
	schtasks.exe /delete /TN "%%~ni"
  	schtasks.exe /create /TN "%%~ni" /XML "%%~ni.xml" /RU domain.local\administrator
)