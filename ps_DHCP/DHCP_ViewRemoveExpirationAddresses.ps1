$computername = "localhost"
$scopeid = "192.168.0.0"
$count = 0
foreach ($object in Get-DhcpServerv4Lease -ComputerName $computername -ScopeId $scopeid)
{
      if ($object.leaseExpiryTime -le (Get-Date))
      {
            $count++
            $object
            Remove-DhcpServerv4Lease -ComputerName $computername -IPAddress ($object.IPAddress).IPAddressToString -WhatIf
      }
}
write-host "count: $count"
