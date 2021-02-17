# script
###Workaround: The OS handle’s position is not what FileStream expected
###http://www.leeholmes.com/blog/2008/07/30/workaround-the-os-handles-position-is-not-what-filestream-expected/
$bindingFlags = [Reflection.BindingFlags] “Instance,NonPublic,GetField”
$objectRef = $host.GetType().GetField(“externalHostRef”, $bindingFlags).GetValue($host)
$bindingFlags = [Reflection.BindingFlags] “Instance,NonPublic,GetProperty”
$consoleHost = $objectRef.GetType().GetProperty(“Value”, $bindingFlags).GetValue($objectRef, @())
[void] $consoleHost.GetType().GetProperty(“IsStandardOutputRedirected”, $bindingFlags).GetValue($consoleHost, @())
$bindingFlags = [Reflection.BindingFlags] “Instance,NonPublic,GetField”
$field = $consoleHost.GetType().GetField(“standardOutputWriter”, $bindingFlags)
$field.SetValue($consoleHost, [Console]::Out)
$field2 = $consoleHost.GetType().GetField(“standardErrorWriter”, $bindingFlags)
$field2.SetValue($consoleHost, [Console]::Out)
###

$r=("=" * 30)
$r
add-pssnapin windows.serverbackup -ErrorAction SilentlyContinue

$zworkdir= [IO.Path]::GetDirectoryName($MyInvocation.InvocationName)
Write-Host workdir: $zworkdir
$filezabbixdata = "$zworkdir\zabbixdata.$Env:COMPUTERNAME.txt"
$zabbix_sender = "`"C:\Program Files\zabbix\zabbix_sender.exe`" -c C:\zabbix_agentd.conf -v -T -s `"$Env:COMPUTERNAME`""
# вычисляю timestamp в формате unix time для отправки заббиксу. 
# необходимо для того, чтобы контроллировать актуальность значений в файле, 
# и во избежание ситуации, когда файл с данными по каким-то причинам не обновлялся, но данные исправно передаем забиксу, который автоматически проставляет свой timestamp и данные считает актуальными.
$a_utc = (Get-Date).ToUniversalTime()
$zabbix_timestamp_ctime = [int][double]::Parse((Get-Date $a_utc -uformat %s))

if (Test-Path $filezabbixdata)
{ 
	Write-Host "file exists and will be removed: $filezabbixdata"
	Remove-Item  $filezabbixdata -force
} else {
	Write-Host "file not exists: $filezabbixdata"
}

function zabbixpreparedata($key,$value)
{
# строка с полями данных разделенных пробелами. 1-ое поле "сервер" ,если дефис, то берется из конфига забикс. далее поля "ключ" "timestamp" "значение"
	$msg =  "- " + $key + " " + $zabbix_timestamp_ctime + " " + $value
	Out-File -FilePath  $filezabbixdata -InputObject $msg -Append -encoding default
}

function zabbixsenddata
{
	$filezabbixdata = "`"$filezabbixdata`""
	Write-Host "command:"
	Write-Host "$zabbix_sender -i $filezabbixdata"
	Write-Host "command result:"
	$r
	Invoke-Expression "& $zabbix_sender -i $filezabbixdata"
}

$wbackup  = Get-Wbsummary

if ( -not $wbackup ) 
{
	$r
	exit
}

$a_ageseconds = ( ((get-date).ToFileTimeUtc() -  $wbackup.LastSuccessfulBackupTime.ToFileTimeUtc())/10000000 ) -Replace("[,\.]\d*", "")
zabbixpreparedata wb`.hresult $wbackup.LastBackupResultHR
zabbixpreparedata wb`.age $a_ageseconds
zabbixsenddata
$r
