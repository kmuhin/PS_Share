# ������� ������ ������ 7 ����.
$dnsage=7

# ������� ��� ������ ���� domain.local
$dns_domain=Get-DnsServerResourceRecord domain.local

# ������� ������ ������ 7 ����.
$dns_domain_7ago=$dns_domain  | ? {$_.timestamp -ne $null} |? { ((get-date) - $_.timestamp).totaldays -gt $dnsage }
# ������� ������ ������ 4 ����.
$dns_domain_4ago=$dns_domain  | ? {$_.timestamp -ne $null} |? { ((get-date) - $_.timestamp).totaldays -gt 4 }

# ������� ������ ������ A � DHCID
$dns_domain_7ago_a= $dns_domain_7ago | ? {$_.RecordType -eq "A" -or $_.RecordType -eq "DHCID"}