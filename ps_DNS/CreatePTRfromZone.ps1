# Needs one param - forward zone.
# Creates PTR record for every A record in forward zone.
# THE PTR zone must exist.
Param (
	[Parameter(Mandatory=$true)][string]$zonename
)

#$zonename="ipmi.local"

$records = Get-DnsServerResourceRecord -rrtype A -zonename $zonename

foreach ( $record in $records) {
    echo $record
    $ipsplit=$record.RecordData.IPv4Address.IPAddressToString.Split(".")
    $zonenameptr=$ipsplit[2]+"."+$ipsplit[1]+"."+$ipsplit[0]+".in-addr.arpa"
    Add-DnsServerResourceRecordPtr -ZoneName $zonenameptr -Name $ipsplit[3] -PtrDomainName "$($record.hostname).$($zonename)"
}