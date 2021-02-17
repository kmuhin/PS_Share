# резервация 100 адресов
$scope = "172.16.5"
# 172.16.5 -> 172016005
$idprefix="{0:d3}{1:d3}{2:d3}" -f $( @([int[]]$scope.split(".")) )
foreach($i in 1..100) {
    $j="{0:d3}" -f $i
    Add-DhcpServerv4Reservation -IPAddress "$scope.$i" -ScopeId "$scope.0" -ClientId "$idprefix$j" -Name "Test_$j" -Description  "test $j"
}

