#Детальный отчет по выполненному бэкапу. С объектами и объемом данных.
#Получаю параметры от планировщика скрипту: ID, Channel записи события, по которой сработал триггер.
param($eventRecordID,$eventChannel)

#$eventRecordID=844
#$eventChannel="Microsoft-Windows-Backup"

#[IO.Path]::GetDirectoryName($MyInvocation.InvocationName)
if ($MyInvocation.MyCommand.Name ) {
    if ( $zworkdir= split-path -parent $MyInvocation.MyCommand.Definition )
    {
        $filename= [IO.Path]::GetFileNameWithoutExtension($MyInvocation.InvocationName)
        $path_history="$zworkdir\history\$($Env:COMPUTERNAME).$(Get-Date -format yyyy.MM.dd).txt"
    }
} else {
    $filename=$null
    $path_history=$null
}
#функция приведения больших чисел из байт с приятночитаемые.
Function Get-OptimalSize()
{
    Param(
	[Parameter(Mandatory=$true, ValueFromPipeline=$true, Position=0)][System.int64]$sizeInBytes,
	[int]$Digits=2
	)
    switch ($sizeInBytes)
    {
        {$sizeInBytes -ge 1TB} {"{0:n$Digits}" -f ($sizeInBytes/1TB) + " TB" ; break}
        {$sizeInBytes -ge 1GB} {"{0:n$Digits}" -f ($sizeInBytes/1GB) + " GB" ; break}
        {$sizeInBytes -ge 1MB} {"{0:n$Digits}" -f ($sizeInBytes/1MB) + " MB" ; break}
        {$sizeInBytes -ge 1KB} {"{0:n$Digits}" -f ($sizeInBytes/1KB) + " KB" ; break}
        Default { "{0:n$sigDigits}" -f $sizeInBytes + " Bytes" }
    } # EndSwitch
} # End Function Get-OptimalSize

add-pssnapin windows.serverbackup -ErrorAction SilentlyContinue
#mail data
$from="robot <robot@goster.ru>"
$recipients="robot@goster.ru" 
$subject="Backup notification from $Env:COMPUTERNAME."

$smtpclient=new-object net.mail.smtpclient("mail.goster.ru")
$msg=new-object net.mail.mailmessage
$msg.from=$from

foreach ($address in $recipients) {
    $msg.to.add($address)
}

$FLAG_ERROR=$false
$FLAG_WARNING=$false

$msg.body="1 last action: "
$body=Get-WBJob -Previous 1 | Out-String -Width 200
$msg.body=$msg.body,$body
$msg.body=$msg.body,"Summary:"
$wbresult = get-wbsummary
$body=$wbresult | Out-String -Width 200
$msg.body=$msg.body,$body
if ( $wbresult.LastBackupResultHR -gt 0 )
{
	$FLAG_ERROR=$true
}

#get detailed info from eventlog
#Получаю детальную информацию по записи из евентлога. Использую фильтр по параметрам полученным ранее.
if (-not $eventRecordID -or -not $eventChannel) {
	Write-Host not enough options:  eventRecordID eventChannel
} else
{
	Write-Host  eventRecordID: $eventRecordID 
	Write-Host  eventChanneleventChannel: $eventChannel

	$event=Get-WinEvent -LogName $eventChannel -FilterXPath "<QueryList><Query Id='0' Path='$eventChannel'><Select Path='$eventChannel'>*[System[EventRecordID=$eventRecordID]]</Select></Query></QueryList>"
	if ( $event )
	{
#new array
  $BackupItems=@()
#всего передано байт
  $TotalTransferred=0
#получаю запись в формате XML
  $eventXML=[xml]$event.ToXml()
#получаю ветку с информацией об объектах в формате XML.
#event-eventdata-<Data Name="VolumesInfo">-<VolumeInfo>
  $VolumesInfo=[xml]($eventxml.Event.EventData.Data | Where-Object {$_.Name -eq "VolumesInfo"}).innertext
  if ( $VolumesInfo ) {
#прохожу по нодам и составляю отчет по объектам бэкапа.
  foreach  ($a in $VolumesInfo.VolumeInfo.ChildNodes) 
  { 
	$TotalTransferred+=$a.DataTransferred
#передано байт по данному объекту
	$DataTransferred=Get-OptimalSize $a.DataTransferred
#всего байт по этому объекту
	$TotalSize=Get-OptimalSize $a.TotalSize
	$text="$($a.name) transferred $DataTransferred of $($TotalSize)"
	if ( [int]$a.IsIncremental ) {
		$text+="; Incremental"
	} elseif ($a.IsIncremental -ne $null) {
		$text+="; Full"
	}
        
	
	if ( $a.HResult -ne 0 )
	{
		$FLAG_WARNING=$TRUE
		$text="    [!] $text"
	} else
	{
		$text="    $text"
	}
	$BackupItems+=$text
	Write-Host  $text
  }
  }
  $ComponentInfo=[xml]($eventxml.Event.EventData.Data | Where-Object {$_.Name -eq "ComponentInfo"}).innertext
# информация по компонентам. к примеру, виртуальные машины.
  if ( $ComponentInfo) {
  foreach  ($a in $ComponentInfo.ComponentInfo.ChildNodes) 
  { 
	$TotalTransferred+=$a.DataTransferred
	$DataTransferred=Get-OptimalSize $a.DataTransferred
	$TotalSize=Get-OptimalSize $a.TotalSize
	$Caption=$a.Caption -split "\\"
    	if ($Caption[1])
	{
        	$Caption="$($Caption[1])($($Caption[0]))"
	} 
	$text="$($Caption) transferred $DataTransferred of $($TotalSize)"
	if ( [int]$a.IsIncremental ) {
		$text+="; Incremental"
	}  elseif ($a.IsIncremental -ne $null) {
		$text+="; Full"
	}
	
	
	if ( $a.HResult -ne 0 )
	{
		$FLAG_WARNING=$TRUE
		$text="    [!] $text"
		
	} else
	{
		$text="    $text"
	}
	$BackupItems+=$text
	Write-Host $text
  }
  }
 Write-Host "Total transferred : $(Get-OptimalSize $TotalTransferred)"
 $msg.Body+="`nTotal transferred : $(Get-OptimalSize $TotalTransferred)`n"
 $msg.Body+=$($BackupItems -join "`n")
	}
}

Write-Host '$FLAG_ERROR :' $FLAG_ERROR
Write-Host '$FLAG_WARNING :' $FLAG_WARNING

if ($FLAG_ERROR) {
	$subject = "[Error!] $subject"
} elseif ($FLAG_WARNING) {
	$subject = "[Warning!] $subject"
}

$msg.subject=$subject
if ($path_history)
{
    $msg.body | Out-File "$path_history"
}
$smtpclient.send($msg)

