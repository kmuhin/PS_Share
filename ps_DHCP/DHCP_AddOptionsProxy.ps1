Add-DhcpServerv4OptionDefinition -OptionId 252 -Description "proxy auto-config" -Type string -name wpad
# set global option
Set-DhcpServerv4OptionValue -wpad "http://127.0.0.1/wpad.dat"
# set scope option
Set-DhcpServerv4OptionValue -ScopeId "172.16.17.0" -Wpad "http://squid-ldap.domain.local/wpad.dat"
# remove global option
Remove-DhcpServerv4OptionValue 252