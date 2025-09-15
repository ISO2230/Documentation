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
