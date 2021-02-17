function Get-SystemUptime
{
	[DateTime]::Now - [Management.ManagementDateTimeConverter]::ToDateTime((Get-WmiObject Win32_OperatingSystem).LastBootUpTime)
}