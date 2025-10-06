# Script - création d'une étendue DHCP

$NomEtendue = "DHCP_sodecaf"
$IPreseau = "172.16.0.0"
$DebutEtendueDHCP = "172.16.0.150"
$FinEtendueDHCP = "172.16.0.200"
$MasqueIP = "255.255.255.0"
$IPPasserelle = "172.16.0.254"
$IPDNSPrimaire = "172.16.0.1"
$IPDNSSecondaire = "8.8.8.8"
$DomainNameDNS = "sodecaf.local"
$DureeBail = "14400" # durée du bail = 4h
$nomServeurDHCP = "SRV-WIN-CORE1"

# Effacement de l'étendue si existante
if ((Get-DhcpServerv4Scope -ComputerName $nomServeurDHCP) -ne $null) {
	write-host ("Etendue déjà présente, elle sera supprimée")
	Remove-DhcpServerv4Scope -ScopeId $IPreseau -Force
}

# Création de l'étendue
Add-DhcpServerv4Scope -Name $NomEtendue -StartRange $DebutEtendueDHCP  -EndRange $FinEtendueDHCP -SubnetMask $MasqueIP
Set-DhcpServerv4OptionValue -ScopeId $IPreseau -OptionId 3 -Value $IPPasserelle
Set-DhcpServerv4OptionValue -ScopeId $IPreseau -OptionId 6 -Value $IPDNSPrimaire,$IPDNSSecondaire -Force
Set-DhcpServerv4OptionValue -ScopeId $IPreseau -OptionId 15 -Value $DomainNameDNS
Set-DhcpServerv4OptionValue -ScopeId $IPreseau -OptionId 51 -Value $DureeBail

# Activation de l'étendue
Set-DhcpServerv4Scope -ScopeId $IPreseau -Name $NomEtendue -State Active

# Affichage des informations de l'étendue créée
Get-DhcpServerv4Scope -ScopeId $IPreseau
Get-DhcpServerv4OptionValue -ComputerName $nomServeurDHCP -ScopeId $IPreseau

# Supprimer une étendue
# Remove-DhcpServerv4Scope -ScopeId $IPreseau -Force
