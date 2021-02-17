# Вычитание дат (тип DateTime) приводит к типу TimeSpan
Get-DnsServerResourceRecord | ? {$_.timestamp -ne $null} |? { ((get-date) - $_.timestamp).totaldays -lt 2 }