# Configuration Windows Server Core avec PowerShell

- Configurer l'interface réseau de SRV-WIN-Core1
  
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

- 
