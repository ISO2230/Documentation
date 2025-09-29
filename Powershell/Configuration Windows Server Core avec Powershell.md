# Configuration Windows Server Core avec PowerShell

- Configurer l'interface réseau de SRV-WIN-CORE1
  
  ```powershell
  $NomDuServeur = "SRV-WIN-CORE1"
  $IPServeur = "172.16.0.1" #@IPv4 à donner au serveur
  $IPLongueurMasque = "24" #notation CIDR
  $IPPasserelle = "172.16.0.254"
  $IPDNSPrimaire = "127.0.0.1"
  $IPDNSSecondaire = "8.8.8.8"
  
  New-NetIPAddress -IPAddress $IPServeur -PrefixLength $IPLongueurMasque -InterfaceIndex (Get-NetAdapter).ifIndex -DefaultGateway $IPPasserelle
  Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ($IPDNSPrimaire,$IPDNSSecondaire)
  Rename-Computer -NewName $NomDuServeur -Force
  
  Restart-Computer
  
  
  ```

- Installer le service ADDS et promouvoir le serveur
  
  ```powershell
  $DomainNameDNS = "sodecaf.local"
  $DomainNameNetbios = "SODECAF"
  $ForestConfiguration = @{
  '-DatabasePath'= 'C:\Windows\NTDS';
  '-DomainMode' = 'Default';
  '-DomainName' = $DomainNameDNS;
  '-DomainNetbiosName' = $DomainNameNetbios;
  '-ForestMode' = 'Default';
  '-InstallDns' = $true;
  '-LogPath' = 'C:\Windows\NTDS';
  '-NoRebootOnCompletion' = $false;
  '-SysvolPath' = 'C:\Windows\SYSVOL';
  '-Force' = $true;
  '-CreateDnsDelegation' = $false }
  Install-WindowsFeature -name AD-Domain-Services -IncludeManagementTools
  Install-ADDSForest @ForestConfiguration
  
  Restart-Computer
  
  
  ```

- Installer le service DHCP
  
  ```powershell
  Install-WindowsFeature -Name DHCP -IncludeManagementTools
  ```

- Créer le groupe de sécurité DHCP
  
  ```powershell
  Add-DhcpServerSecurityGroup
  ```

- Redémarrer le service DHCP
  
  ```powershell
  Restart-Service dhcpserver
  ```

- Créer et configurer une étendue
  
  ```powershell
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
  ```


