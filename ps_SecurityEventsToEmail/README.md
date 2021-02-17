# Security event notifications in Windows 10
Events such as "Login", "Login Failed", etc.
The script is launched by an event trigger in Windows Scheduler.
Sends email with details of event.

- event_codes.csv: list of some event codes
- LOG: log of events
- log_sec_mgmt.cmd: wrapper for launch log_sec_mgmt.ps1.
- log_sec_mgmt.ps1: powershell script
- securitylog.xml: task for WindowsScheduler
- TaskShedulerImportTasks.cmd: importer task of scheduler
- TaskShedulerImportTasks.txt: list of tasks to import

## Installation

### Edit securitylog.xml and set correct path to script:
  <Actions Context="Author">
    <Exec>
      <Command>C:\tools\ps_SecurityEventsToEmail\log_sec_mgmt.cmd</Command>

### Edit log_sec_mgmt.ps1. Set correct smtp server and your mailboxes:
    $from="security<security@emaildomain.com>"
    $recipients="recipient1@maildomain.com","recipient2@gmail.com" 
    $subject="Security. Host: $Env:COMPUTERNAME."
    $Encoding = [System.Text.Encoding]::UTF8
    $smtpclient=new-object net.mail.smtpclient("mail.maildomain.com")

### Edit TaskShedulerImportTasks.cmd. Set correct username:
    set USERNAME=User


### Run to import task:

    TaskShedulerImportTasks.cmd

### Advices:
    1. In EventViewer increase Security Log Size to 70016 KByte (default is 2048 KByte).
    2. Windows Scheduler Settings:
        "Stop the task if it runs longer then" - 1 minute
        "Run a new instance in parallel" instead "Queue a new instance".

## Setup specific events.
Edit securitylog.xml:
<Triggers>
    <EventTrigger>
      <Enabled>true</Enabled>
      <Subscription>
Task = 13824 or Task = 13825 or Task = 13826 or Task = 12551 or EventID = 4625
