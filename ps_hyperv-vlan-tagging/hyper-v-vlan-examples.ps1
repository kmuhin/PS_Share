# add interface to VM
Add-VMNetworkAdapter -SwitchName Switch -VMName "VmName" -Name "TrunkNic"
# set trunc
Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList "100,101" -VMName "VmName" -VMNetworkAdapterName "TrunkNic" -NativeVlanId 1
# set untagged
Set-VMNetworkAdapterVlan  -VMName "VmName" -VMNetworkAdapterName "TrunkNic" -Untagged


examples:
 Add-VMNetworkAdapter -SwitchName "Internal Network" -VMName "gentoo.router.ntp1" -Name "TrunkNic"

 Add-VMNetworkAdapter -VMName "gentoo.router.ntp1" -Name "external"

 Add-VMNetworkAdapter -VMName "gentoo.router.ntp1" -Name "local.trunc"

 Add-VMNetworkAdapter -VMName "gentoo.router.ntp1" -Name "external2"

 
Set-VMNetworkAdapterVlan -Trunk -AllowedVlanIdList "2,3,30" -VMName "gentoo.router.ntp1" -VMNetworkAdapterName "local.trunc" -NativeVlanId 1

Set-VMNetworkAdapterVlan  -VMName "gentoo.router.ntp1" -VMNetworkAdapterName "local.trunc" -Untagged