## backup_result_mail.cmd 
Wrapper of backup_result_mail.ps1.
This one is to run script and using on Task Scheduler.
## backup_result_mail.ps1 
Sends detail report of backup WindowsBackups on email.
## backup_result_zabbix.cmd
Wrapper of backup_result_zabbix.ps1.
This one is to run script and using on Task Scheduler.
## backup_result_zabbix.ps1 - sends result of backup WindowsBackups on zabbix.
## history 
Script logs.
## history.cmd 
Archives history.
It can be used in the task scheduler or started manually.
## Microsoft-Windows-Backup.xml 
Task for WindowsTaskScheduler. Runs backup_result_mail.cmd.
Events: 14, 19.
## TaskSchedulerImportTasks.cmd
Import task(s) by filename from TaskSchedulerImportTasks.txt.
## TaskSchedulerImportTasks.txt 
List of tasks to import.
## windows backup result is sent to zabbix.xml
Task for WindowsTaskScheduler. Runs backup_result_zabbix.cmd.
Events: 14, 19

Copyright (c) 2016 Konstantin Mukhin