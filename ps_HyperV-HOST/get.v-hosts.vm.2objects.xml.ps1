# Generates reports of hyper-v hosts in AD. 
# Three different types or report: txt, csv, xml.
# Shows VMs of hosts.
# Shows mac addresses of virtual machines in csv version.
# Shows state of VMs: running, off, etc.
# Shows replica state, replica server and replica name.

Import-Module Hyper-V -RequiredVersion 1.1
Import-Module ActiveDirectory

# script directory
$zworkdir= split-path -parent $MyInvocation.MyCommand.Definition
#[IO.Path]::GetDirectoryName($MyInvocation.InvocationName)
# script name
$filename= [IO.Path]::GetFileNameWithoutExtension($MyInvocation.InvocationName)
# AD OU to search hosts with Get-ADComputer for ver.1.
$SearchBase="OU=Virtual Hosts,OU=Servers,OU=Domain Computers,DC=domain,DC=local"
# report history
$reportname="$zworkdir\reports\vlist.$(Get-Date -format yyyy.MM.dd.HHmm)"
# base name of report
$curname="$zworkdir\vlist"
## ver.1
#$vhosts=Get-ADComputer -SearchBase "$SearchBase" -Filter *
## ver.2
## Takes hosts by objectClass
$vhostsad=Get-ADObject –LDAPFilter "(&(objectClass=serviceConnectionPoint)(CN=Microsoft Hyper-V))"
#
$v=$vhostsad | % { ($_.DistinguishedName -split "," -replace ".*=")[1] }
$vhosts=@()
foreach ($hostname in $v ) {
	$objhostname=new-object system.object
	$objhostname | Add-Member -type NoteProperty -Name Name -Value $hostname
	$vhosts+=$objhostname
}
##
if (!$?)  {exit}
#initial array of own objects
$fullist=@()
$progress=0

#create xml docuent for file output
[xml]$xmlDoc = New-Object system.Xml.XmlDocument
$xmlDoc.LoadXml("<?xml version=`"1.0`" encoding=`"utf-8`"?><Racine></Racine>")
$xmlelt=$xmldoc.CreateElement("vhosts")
$xmlDoc.LastChild.AppendChild($xmlelt) | Out-Null
$xmlsubelt=$xmlDoc.CreateElement("count")
$xmlelt.AppendChild($xmlsubelt) | Out-Null
$xmlsubtext=$xmlDoc.CreateTextNode($vhosts.Count)
$xmlsubelt.AppendChild($xmlsubtext) | Out-Null

foreach ($vhost in $($vhosts | Sort-Object -Property name))
{
    $progress+=1
    
    $xmlsubelt=$xmlDoc.CreateElement("vhost")
    $xmlelt.AppendChild($xmlsubelt) | Out-Null
    $xmlattr=$xmlDoc.CreateAttribute("name")
    $xmlattr.Value="$($vhost.name)"
    $xmlsubelt.Attributes.Append($xmlattr) | Out-Null

    $a=Get-VM -ComputerName $vhost.name
    $OS=$(Get-CimInstance Win32_OperatingSystem -ComputerName $vhost.name).caption
    Write-Host [$progress/$($vhosts.count)] $($vhost.name) [$($a.count)]
    $xmlsubelt2=$xmlDoc.CreateElement("OS")
    $xmlsubelt.AppendChild($xmlsubelt2) | Out-Null
    $xmlsubtext2=$xmlDoc.CreateTextNode($OS)
    $xmlsubelt2.AppendChild($xmlsubtext2) | Out-Null
    $xmlsubelt2=$xmlDoc.CreateElement("count")
    $xmlsubelt.AppendChild($xmlsubelt2) | Out-Null
    $xmlsubtext2=$xmlDoc.CreateTextNode($a.Count)
    $xmlsubelt2.AppendChild($xmlsubtext2) | Out-Null
    
    $subprogress=0
    foreach ($vm in $a)
    {
        $subprogress+=1
        Write-Host [$progress/$($vhosts.count)] $($vhost.name) [$subprogress/$($a.count)] $($vm.Name) 
        $xmlsubelt2=$xmlDoc.CreateElement("vm")
        $xmlsubelt.AppendChild($xmlsubelt2) | Out-Null
        $xmlsubtext2=$xmlDoc.CreateTextNode($vm.name)
        $xmlsubelt2.AppendChild($xmlsubtext2) | Out-Null
	$macs=($vm | Get-VMNetworkAdapter |  select -expandproperty macaddress) -join ","
#create own object
#the first object in array must have all elements
        $b=new-object system.object
        $b | Add-Member -type NoteProperty -name vhost -Value $vhost.name
        $b | Add-Member -type NoteProperty -name vm -Value $vm.Name
        $b | Add-Member -type NoteProperty -name state -Value $vm.State
        $b | Add-Member -type NoteProperty -name ReplicationState -Value $vm.ReplicationState
        $b | Add-Member -type NoteProperty -name ReplicationMode -Value $vm.ReplicationMode
        $b | Add-Member -type NoteProperty -name Id -Value $vm.Id
	$b | Add-Member -type NoteProperty -name macs -Value $macs
        $replicaserver=""
#        if ($vm.ReplicationMode -eq 2) {continue}
#if replication is enaabled, then get detailed of replication
        if ($vm.ReplicationMode -eq 1) 
        {
            $vmrepl=Get-VMReplication -ComputerName $vhost.name -VMName $vm.name
            $replicaserver=$vmrepl.replicaserver.Split(".")[0]
            
        }
        $b | Add-Member -type NoteProperty -name replicaserver -Value $replicaserver
        $b | Add-Member -type NoteProperty -name replicaname -Value ""
        $fullist+=$b

    }

}
#$fullist
#search and set replica name for main vm in replication
foreach ( $vmprimary in $fullist )
{
    if ($vmprimary.ReplicationMode -eq 2) {continue}
    if ($vmprimary.ReplicationMode -eq 1)
    {
        $replica=($fullist | where-object { $_.id -eq $vmprimary.id -and $_.ReplicationMode -eq 2 -and $_.vhost -eq $vmprimary.replicaserver })
    } else {$replica=""}
    $vmprimary.replicaname=$replica.vm
    
}

#list of objects without replica
$primarylist=$fullist | Where-Object {$_.ReplicationMode -ne 2}
#list of objects running and without replica.
$runninglist=$primarylist | Where-Object {$_.state -eq 2}
#save full list to file csv
$primarylist | Select-Object * -ExcludeProperty id,ReplicationMode | Export-Csv -delimiter ";" -NoTypeInformation "$($reportname).csv"
#save to file xml
$xmlDoc.Save("$($reportname).xml")
#save to file txt without replica
$stat="hosts total:`t$($vhosts.Count)",`
	"vms total:`t$($primarylist.Count)",`
	"vms running:`t$($runninglist.Count)",`
	"vms replicating:`t $($($primarylist| Where-Object -Property ReplicationMode -eq -value Primary).count)",`
	"replication errors:`t $($($primarylist| Where-Object -Property ReplicationState -ne -value Replicating | Where-Object -Property ReplicationState -ne -value Disabled).count)"
$stat | Out-File "$($reportname).txt"
#$a=@{Expression={$_.vhost};Label="vhost";width=10}, `
#   @{Expression={$_.ReplicationState};Label="RState"}, `
#   @{Expression={$_.Replicaserver};Label="RServer"}
$fullist | Where-Object {$_.ReplicationMode -ne 2} `
    | ft -AutoSize @{Expression={$_.vhost};Label="vhost";width=10}, `
    vm,state,@{Expression={$_.ReplicationState};Label="RState"}, `
    @{Expression={$_.Replicaserver};Label="RServer"}, `
    @{Expression={$_.replicaname};Label="RName"} `
    | Out-File "$($reportname).txt" -Append -Width 130
cp "$($reportname).xml" "$($curname).xml"
cp "$($reportname).txt" "$($curname).txt"
cp "$($reportname).csv" "$($curname).csv"
