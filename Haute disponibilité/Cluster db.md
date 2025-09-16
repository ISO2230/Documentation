# Cluster de base de données

- Configurer le fichier e configuration serveur de maradb sur SRV-WEB1 (serveur maître)
  
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

- Autoriser la réplication pour l'utilisateur distant
  
  ```sql
  grant replication slave on *.* to 'replicateur'@'%';
  ```

- Bloquer l'écriture dans MySQL
  
  ```sql
  flush tables with read lock;
  ```

- Configurer le fichier e configuration serveur de maradb sur SRV-WEB2 (serveur esclave)
  
  ```bash
  nano /etc/mysql/mariadb.conf.d/50-server.cnf
  ```
  
  ```shell
  [mysqld]
  #bind-address    = 127.0.0.1
  log_error    = /var/log/mysql/error.log
  server-id    = 2
  log_bin    = /var/log/mysql/mysql-bin.log
  expire_logs_days    = 10
  max_binlog_size    = 100M
  master-retry-count    = 20
  binlog_do_db    = gsb_valide
  ```
