# Adds scope /24 to DHCP
# usage: Add-FullScope24("192.168.0")
# result:
# prefix: 192.168.0
# name: 192.168.0.0
# description: 192.168.0.0
# router: 192.168.0.1
# full lease range except router
# lease duration: 1 day

function Add-FullScope24 {
	param(
		[Parameter(Mandatory = $true)][string]$prefix,
		[String]$name="$prefix.0",
		[String]$description="$prefix.0",
        [TimeSpan]$leaseduration="1.00:00:00"
	)
    $router  = "$prefix.1"
    $scopeid = "$prefix.0"
    echo "prefix: $prefix"
    echo "name: $name"
    echo "description: $description"
    echo "leaseduration: $leaseduration"
	Add-DhcpServerv4Scope -StartRange "$prefix.1" -EndRange "$prefix.254"  -SubnetMask "255.255.255.0" `
		-Name "$name" -Description "$description" -LeaseDuration $leaseduration
	Set-DhcpServerv4OptionValue      -ScopeID $scopeid -Router "$router"
	Add-DhcpServerv4ExclusionRange   -ScopeID $scopeid -StartRange "$router" -EndRange "$router"

}
