# VLAN tagging des VM sur l'ESXi

## Sous Windows

- Vérifier le VLAN ID d'une interface réseau
  
  ```powershell
  Get-NetAdapterAdvancedProperty Ethernet0 -DisplayName "VLAN ID"
  ```

- Définir le VLAN ID
  
  ```powershell
  Set-NetAdapterAdvancedProperty Ethernet0 -DisplayName "VLAN ID" -DisplayValue 100
  ```


