# from unix epoch to local time
Function get-epochDate ($epochDate) { 
  [timezone]::CurrentTimeZone.ToLocalTime(([datetime]'1/1/1970').AddSeconds($epochDate)) 
}

# unix time in sec
$timestamp= [int][double]::Parse((Get-Date (Get-Date).ToUniversalTime() -uformat %s))
# local time
get-epochDate($timestamp)