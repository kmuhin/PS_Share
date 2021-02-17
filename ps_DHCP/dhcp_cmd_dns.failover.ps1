# Получить информацию DNS всех скопов и состояние failover

$scopesoptions=@()
$scopes=get-dhcpserverv4scope 
echo Global:
$(Get-DhcpServerv4OptionValue -OptionId 6).value
echo ""
echo Local:
foreach ($scope in $scopes) {
 $dns=Get-DhcpServerv4OptionValue -OptionId 6 -ScopeId $scope.scopeid -ErrorAction SilentlyContinue
 $a=[ordered]@{'Scope'=$scope.ScopeId.IPAddressToString}
 $a.add('Lease',$scope.LeaseDuration)
 $a.add('DNS Servers',$dns.value)
 $failover=Get-DhcpServerv4Failover -scopeid $scope.ScopeId -ErrorAction SilentlyContinue
 $a.Add('Failover',$failover.name)
 $scopesoptions+=New-Object -TypeName psobject -property $a
}
$scopesoptions
