# Cluster web

- Installation de corosync, pacemaker et crmsh
  
  ```bash
  apt update && apt upgrade
  apt install corosync pacemaker crmsh -y
  ```

- Vérifier le statut de corosync
  
  ```bash
  service corosync status
  ```

- Création de la clé pour le chiffrement des échanges
  
  ```bash
  corosync-keygen
  ls -la /etc/corosync/
  ```
