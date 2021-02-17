# Получаю записи старше 7 дней.
$dnsage=7

# Получаю все записи зоны domain.local
$dns_domain=Get-DnsServerResourceRecord domain.local

# Получаю записи старше 7 дней.
$dns_domain_7ago=$dns_domain  | ? {$_.timestamp -ne $null} |? { ((get-date) - $_.timestamp).totaldays -gt $dnsage }
# Получаю записи старше 4 дней.
$dns_domain_4ago=$dns_domain  | ? {$_.timestamp -ne $null} |? { ((get-date) - $_.timestamp).totaldays -gt 4 }

# Выбираю записи только A и DHCID
$dns_domain_7ago_a= $dns_domain_7ago | ? {$_.RecordType -eq "A" -or $_.RecordType -eq "DHCID"}