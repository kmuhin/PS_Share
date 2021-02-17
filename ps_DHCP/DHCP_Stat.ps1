# statistic of dhcp scopes
# inusetotalmatch - total stat of scopes by matching string in name 
function inusetotalmatch
{
	Param(
	  [Parameter(Mandatory = $True)]
	  [string]$matchstring
	)
	echo "$matchstring inuse total:"
	$dhcpstat | ? {$_.name -match "$matchstring" } | measure -sum inuse | fl count,sum

}
$dhcpstat=@()
$dhcpscopes=get-dhcpserverv4scope
foreach ($dhcpscope in $dhcpscopes) 
{ 
    $myobject=New-Object system.object
    $dhcpstatscope=Get-DhcpServerv4ScopeStatistics -ScopeId $dhcpscope.ScopeId
    $myobject | Add-Member -type NoteProperty -name ScopeID -Value $dhcpscope.ScopeId.IPAddressToString
    $myobject | Add-Member -type NoteProperty -name Name -Value $dhcpscope.Name
    $myobject | Add-Member -type NoteProperty -name Free -Value $dhcpstatscope.Free
    $myobject | Add-Member -type NoteProperty -name InUse -Value $dhcpstatscope.inUse
    $myobject | Add-Member -type NoteProperty -name PercentageInUse -Value $dhcpstatscope.PercentageInUse
    $dhcpstat+=$myobject
}
$dhcpstat | Sort-Object PercentageInUse -Descending | ft -AutoSize

# show number of clients for scopes containing "wifi" in the name.
inusetotalmatch "wifi"
# The Wi-Fi client can roam between different scopes within leathtime. Therefore, the same ClientID will appear in all scopes.
# Count unique clientID.
echo "Unique clientId in all wifi scopes"
Get-DhcpServerv4Scope | ? {$_.name -match "wifi"} | Get-DhcpServerv4Lease | Sort-Object clientid -Unique | measure | fl count
# other scopes
inusetotalmatch "wks"
inusetotalmatch "prn"

