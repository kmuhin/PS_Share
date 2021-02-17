#mail
$from="robot <robot@goster.ru>"
$recipients="robot@goster.ru" 
$subject="[Error!] Host: $Env:COMPUTERNAME. The DFS Replication service stopped replication on volume E:."

$smtpclient=new-object net.mail.smtpclient("mail.goster.ru")
$msg=new-object net.mail.mailmessage
$msg.from=$from
$uptime=[DateTime]::Now - [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)
###
$r = ("-" * 30)
$rr = ("=" * 30)
$rr+" Start"
Get-Date

foreach ($address in $recipients) {
    $msg.to.add($address)
}

function format_event2213()
{

$frs_disk=%{([xml]$event_2213.ToXml()).Event.EventData.Data[1]}
$frs_guid=%{([xml]$event_2213.ToXml()).Event.EventData.Data[0]}

$msg.body+="Uptime: ",[math]::truncate($uptime.totaldays)," days `n"
$msg.body+="The DFS Replication service stopped replication on volume $frs_disk. This occurs when a DFSR JET database is not shut down cleanly and Auto Recovery is disabled. To resolve this issue, back up the files in the affected replicated folders, and then use the ResumeReplication WMI method to resume replication. `n `n"
$msg.body+="LogName: ",$event_2213.LogName
$msg.body+="`nSource:",$event_2213.ProviderName,"`nLogged:",$event_2213.TimeCreated.ToString("dd.MM.yyy HH:mm:ss")
$msg.body+="`nEvent ID:",$event_2213.Id,"Computer:",$event_2213.MachineName
$msg.body+="`nVolume:",$frs_disk
$msg.body+="`nGUID:",$frs_guid
$x=@"
Recovery Steps 
1. Back up the files in all replicated folders on the volume. Failure to do so may result in data loss due to unexpected conflict resolution during the recovery of the replicated folders. 
2. To resume the replication for this volume, use the WMI method ResumeReplication of the DfsrVolumeConfig class. For example, from an elevated command prompt, type the following command: 
wmic /namespace:\\root\microsoftdfs path dfsrVolumeConfig where volumeGuid="$frs_guid" call ResumeReplication 
"@
$msg.body+="`n`n"+$x
}



#"By default, events are returned in newest-first order."
$event_2213=Get-WinEvent -FilterHashtable @{LogName="DFS Replication";ProviderName="DFSR";Id=2213} -ErrorAction SilentlyContinue  -MaxEvents 1

if ($event_2213) {
 format_event2213
} else
{
 Write-Host "error:Get-WinEvent"
 $msg.body=$msg.body,"error:Get-WinEvent"
}


$msg.subject=$subject
$smtpclient.send($msg)


$rr+" End"
