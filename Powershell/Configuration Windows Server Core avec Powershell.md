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
  $NomEtendue = "DHCP_sodecaf"
  $IPreseau = "172.16.0.0"
  $DebutEtendueDHCP = "172.16.0.150"
  $FinDebutDHCP = "172.16.0.200"
  $MasqueIP = "255.255.255.0"
  $IPPasserelle = "172.16.0.254"
  $IPDNSPrimaire = "127.0.0.1"
  $IPDNSSecondaire = "8.8.8.8"
  $DomainNameDNS = "sodecaf.local"
  $DureeBail = "14400" # Durée du bail : 4h
  $NomServeurDHCP = "SRV-WIN-CORE1"
  
  # Création de l'étendue
  Add-DhcpServer4Scope -ScopeId $IPreseau -Name $NomEtendue -State Active
  Set-DhcpServer4Scope -ScopeId $IPreseau -OptionId 3 -Value $IPPasserelle
  
  
  # Activation de l'étendue
  
  ```


