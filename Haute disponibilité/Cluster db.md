# Cluster de base de données

- Créer le dossier des logs MySQL sur les deux serveurs (SRV-WEB1 & SRV-WEB2)
  
  ```bash
  mkdir -m 2750 /var/log/mysql
  chown mysql /var/log/mysql
  touch /var/log/mysql/error.log
  ```

- Configurer le fichier e configuration serveur de mariadb sur SRV-WEB1 (serveur maître)
  
  ```bash
  nano /etc/mysql/mariadb.conf.d/50-server.cnf
  ```
  
  ```shell
  [mysqld]
  #bind-address    = 127.0.0.1
  log_error    = /var/log/mysql/error.log
  server-id    = 1
  log_bin    = /var/log/mysql/mysql-bin.log
  expire_logs_days    = 10
  max_binlog_size    = 100M
  binlog_do_db    = gsb_valide
  ```

- Créer un utilisateur pour l'accès distant
  
  ```sql
  create user 'replicateur'@'%' identified by 'Btssio2017';
  ```

- Autoriser la réplication pour l'utilisateur distant (sur le serveur maître)
  
  ```sql
  grant replication slave on *.* to 'replicateur'@'%';
  ```

- Bloquer l'écriture dans MySQL
  
  ```sql
  flush tables with read lock;
  ```

- Débloquer les tables (si besoin)
  
  ```sql
  unlock tables;
  ```

- Afficher le statut du maître
  
  ```sql
  show master status;
  ```

- Configurer le fichier de configuration serveur de mariadb sur SRV-WEB2 (serveur esclave)
  
  ```bash
  nano /etc/mysql/mariadb.conf.d/50-server.cnf
  ```
  
  ```shell
  [mysqld]
  #bind-address    = 127.0.0.1
  log_error    = /var/log/mysql/error.log
  server-id    = 2
  expire_logs_days    = 10
  max_binlog_size    = 100M
  master-retry-count    = 20
  replicate-do-db    = gsb_valide
  ```

- Configurer l'esclave
  
  ```sql
  stop slave;
  change master to master_host='172.16.0.10',
  master_user='replicateur',
  master_password='Btssio2017',
  master_log_file='mysql-bin.000001',
  master_log_pos=328;
  start slave;
  ```

- Vérifier le statut de l'esclave (avec l'affichage ligne par ligne)
  
  ```sql
  show slave status \G;
  ```

- Une fois l'esclave correctement configuré, on déverrouille les bases de données sur le serveur maître SRV-WEB1
  
  ```sql
  unlock tables;
  ```

- Pour vérifier la configuration du serveur maître et serveur esclave, on modifie le mot de passe d'un utilisateur dans la base de données gsb_valide (à faire sur SRV-WEB1)
  
  ```sql
  use gsb_valide;
  select * from Visiteur;
  update gsb_valide.Visiteur set mdp='toto' where login='agest';
  ```

- Ensuite, on vérifie que la base de données a été mise à jour sur l'esclave (SRV-WEB2)
  
  ```sql
  use gsb_valide;
  select * from Visiteur;
  ```

---

## Réplication bi-directionnelle

### Sur SRV-WEB1

- Ajouter dans /etc/mysql/mariadb.conf.d/50-server.cnf les lignes suivantes
  
  ```shell
  [mysqld]
  log-slave-updates
  master-retry-count    = 20
  replicate-do-db        = gsb_valide
  ```

### Sur SRV-WEB2

- Modifier le le fichier de config de MySQL
  
  ```shell
  [mysqld]
  log_bin        = /var/log/mysql/mysql-bin.log
  
  binlog_do_db    = gsb_valide
  log-slave-updates
  ```

- redémarrer le service MySQL
  
  ```bash
  service mariadb restart
  ```

- Créer l'utilisateur 'replicateur' sur SRV-WEB2 et lui donner les droits de réplication
  
  ```sql
  create user 'replicateur'@'%' identified by 'Btssio2017';
  grant replication slave on *.* to 'replicateur'@'%';
  ```

- Reconfigurer SRV-WEB2 dans MySQL
  
  ```sql
  stop slave;
  change master to master_host='172.16.0.10',
  master_user='replicateur',
  master_password='Btssio2017',
  master_log_file='mysql-bin.000002',
  master_log_pos=342;
  start slave;
  ```

### Sur SRV-WEB1

- Reconfigurer SRV-WEB1 dans MySQL
  
  ```sql
  change master to master_host='172.16.0.11',
  master_user='replicateur',
  master_password='Btssio2017',
  master_log_file='mysql-bin.000001',
  master_log_pos=328;
  start slave;
  ```

### Sur SRV-WEB1 & SRV-WEB2

- Redémarrer MySQL
  
  ```bash
  service mariadb restart
  ```

---

## Intégration de MySQL dans le cluster

- Configurer la ressource serviceMySQL sur l'un des deux serveurs
  
  ```bash
  crm configure primitive serviceMySQL ocf:heartbeat:mysql params socket=/var/run/mysqld/mysqld.sock
  ```

- Créer un clone de la ressource serviceMySQL
  
  ```bash
  crm configure clone cServiceMySQL serviceMySQL
  ```
