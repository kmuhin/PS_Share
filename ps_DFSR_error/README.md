# Sends an mail by event 2213 - dfs replications error.

 - DFS Replication_DFSR_2213.xml: Schedule Task with with event trigger.
 - distribute_on_servers.cmd: Copy event_dfrs_2212_mail.ps1 to servers.
 - event_dfrs_2212_mail.cmd: Wrapper. It is used in task to run the script.
 - event_dfrs_2212_mail.ps1: It is the script itself. Receives information and sends it by email.
 - TaskShedulerImportTasks.cmd: The script imports the schedule task.
 - TaskShedulerImportTasks.txt: List of tasks to import.
 - event_dfrs_2212_mail.log: Script log.
