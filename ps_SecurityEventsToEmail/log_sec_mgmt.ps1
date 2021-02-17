param($eventRecordID,$eventChannel)

if (-not $eventRecordID -or -not $eventChannel) {
	Write-Host not enough options:  eventRecordID eventChannel
	exit
}

$event_codes="event_codes.csv"
#[IO.Path]::GetDirectoryName($MyInvocation.InvocationName)
if ( $zworkdir= split-path -parent $MyInvocation.MyCommand.Definition )
{
 $filename= [IO.Path]::GetFileNameWithoutExtension($MyInvocation.InvocationName)
 $event_codes="$zworkdir\event_codes.csv" 
}



#mail
$from="security<security@emaildomain.com>"
$recipients="recipient1@maildomain.com","recipient2@gmail.com" 
$subject="Security. Host: $Env:COMPUTERNAME."
$Encoding = [System.Text.Encoding]::UTF8
$smtpclient=new-object net.mail.smtpclient("mail.maildomain.com")
$msg=new-object net.mail.mailmessage
$msg.from=$from

$msg.SubjectEncoding=$Encoding
$msg.BodyEncoding=$Encoding

###
$r = ("-" * 30)
$rr = ("=" * 30)
$rr+" Start"
Get-Date

write-host  "eventRecordID: [$eventRecordID]"
write-host  "eventChannel: [$eventChannel]"

$ids=@{}
Import-Csv -Path "$event_codes" -Delimiter ";" -Header key,value | % { $ids[$_.key] = $_.value }

foreach ($address in $recipients) {
    $msg.to.add($address)
}

function format_event()
{
$desc=$ids["$($event_sec.Id)"]
$msg.body=@"
$($desc)

LogName: $($event_sec.LogName)
Source: $($event_sec.ProviderName)
ContainerLog: $($event_sec.$ContainerLog)
Logged: $($event_sec.TimeCreated.ToString("dd.MM.yyy hh:mm:ss"))
Event ID: $($event_sec.Id) 
Computer: $($event_sec.MachineName)
RecordID: $($eventRecordID)
eventChannel: $($eventChannel)

"@
$EventDataXML=[xml]($event_sec.ToXml())
$TargetUserName=($EventDataXML.Event.EventData.Data | ? {$_.name -match "targetUserName"} | % {$_.'#text'})
$global:subject+=" $TargetUserName"
$msg.body+=($EventDataXML.Event.EventData.ChildNodes.GetEnumerator() | ft -AutoSize -HideTableHeaders | Out-String -Width 200)
}



$event_sec=Get-WinEvent -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[EventRecordID=$eventRecordID]]</Select></Query></QueryList>"

if ($event_sec) {
 format_event
 write-host $msg.Body
} else
{
 Write-Host "error:Get-WinEvent"
 $msg.body=$msg.body,"error:Get-WinEvent"
}


$msg.subject=$subject
# $smtpclient.send($msg)


$rr+" End"
