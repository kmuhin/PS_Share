# pure UTC unix epoch
# round to sec
$date_utc = (Get-Date).ToUniversalTime()
$date_epoch = [int][double]::Parse((Get-Date $date_utc -uformat %s))

# one line with milliseconds
Get-Date (Get-Date).ToUniversalTime() -uformat %s