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

- Création d'un nouveau fichier de configuration de corosync
  
  ```bash
  mv /etc/corosync/corosync.conf /etc/corosync/corosync.conf.sav
  nano /etc/corosync/corosync.conf
  ```
  
  ```shell
  totem {
      version: 2
      cluster_name: cluster_web
      crypto_cipher: aes256
      crypto_hash: sha1
      clear_node_high_bit:yes
  }
  logging {
      fileline: off
      to_logfile: yes
      logfile: /var/log/corosync/corosync.log
      to_syslog: no
      debug: off
      timestamp: on
      logger_subsys {
          subsys: QUORUM
          debug: off
      }
  }
  quorum {
      provider: corosync_votequorum
      expected_votes: 2
      two_nodes: 1
  }
  nodelist {
      node {
          name: srv-web1
          nodeid: 1
          ring0_addr: 172.16.0.10
      }
      node {
          name: srv-web2
          nodeid: 2
          ring0_addr: 172.16.0.11
      }
  }
  service {
      ver: 0
      name: pacemaker
  }
  ```

- Vérifier la configuration de corosync
  
  ```bash
  corosync-cfgtool -s
  ```

- Cloner le serveur web, modifier le nom d'hôte et l'IP du clone

- Visualiser l'état du cluster
  
  ```bash
  crm status
  ```

- Afficher la configuration du cluster
  
  ```bash
  crm configure show
  ```

- Désactivation de STONITH (Shot The Other Node In The Head)
  
  ```bash
  crm configure property stonith-enabled=false
  ```

- Désactiver le quorum
  
  ```bash
  crm configure property no-quorum-policy="ignore"
  ```

- Configuration du Failover IP (IP virtuelle)
  
  ```bash
  crm configure primitive IPFailover ocf:heartbeat:IPaddr2 params ip=172.16.0.12 cidr_netmask=24 nic=ens33 iflabel=VIP
  ```

- Tests de basculement
  
  ```bash
  crm node online
  crm node standby
  ```

- Arrêter ou supprimer une ressource
  
  ```bash
  crm resource stop <nom_ressource>
  crm configure delete <nom_ressource>
  ```

- Editer la configuration (à utiliser avec prudence)
  
  ```bash
  crm configure edit
  ```

- Configuration du serviceWeb
  
  ```bash
  crm configure
  primitive serviceWeb lsb:apache2 op monitor interval=60s op start interval=0 timeout=60s op stop interval=0 timeout=60s
  commit
  quit
  ```

- Vérifier la disponibilité du service
  
  ```bash
  nmap localhost -p 80
  ```

- Création du groupe de ressources servweb
  
  ```bash
  crm configure
  group servweb IPFailover serviceWeb meta migration-threshold="5"
  commit
  quit
  ```

- Définir une préférence de nœud primaire pour l'IP virtuelle
  
  ```bash
  crm resource move IPFailover srv-web1
  ```


