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

Import-Module ActiveDirectory

if ( $zworkdir= split-path -parent $MyInvocation.MyCommand.Definition )
{
 $filename= [IO.Path]::GetFileNameWithoutExtension($MyInvocation.InvocationName)
 $path_history="$zworkdir\history.$(Get-Date -format yyyy.MM.dd)"
}

New-Item -ItemType directory -Path "$path_history"


$SearchBaseComputers="OU=Workstations,OU=Domain Computers,DC=domain,DC=local"
$SearchBaseUsers="DC=domain,DC=local"
$DCServer="pdc.domain.local"
$psexec="PsExec.exe"
$cmd="ipconfig /all"

$computers=Get-ADComputer -SearchBase "$SearchBaseComputers" -Filter * -Server $DCServer

foreach ( $dnsname in $computers ) {
$computer=$dnsname.DNSHostName
"`n"+$computer+":"
if ( -NOT (Test-Connection -Count 1 -Delay 1 -Quiet -ComputerName $computer) ) {
	echo "	not available"
	continue
}
& $psexec \\$computer $cmd > $path_history\$computer.ipconfig.txt
}