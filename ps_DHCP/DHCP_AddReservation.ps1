# строка с адресом и именем добавляется в резервацию с маком производным от ip
$ipname="172.16.6.170  server1.domain.local"

$ipname=$ipname -replace "\s+"," "
$ip=@($ipname.split(""))
$mac="{0:d3}{1:d3}{2:d3}{3:d3}" -f $( @([int[]]$ip[0].split('.')) )
$scope=$ip[0] -replace ".[0-9]+$",".0"
write-host $ip[0] $ip[1] $mac $scope

Add-DhcpServerv4Reservation -ScopeId $scope -IPAddress $ip[0] -Name $ip[1] -Description $ip[1] -ClientId $mac -WhatIf