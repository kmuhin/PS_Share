@echo off
set file=event_dfrs_2212_mail.ps1
set localpath=c$\scripts\ps_DFSR_error

set dc=pdc dc1 dc2 dc3

for %%i in (%dc%) do (
echo %%i
copy %file% "\\%%i.domain.local\%localpath%\"
)

exit 0
