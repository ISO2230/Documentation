# Mise en place d'un DNS (Debian 12)

- Installer bind9
  
  ```bash
  apt update && apt upgrade -y && apt install bind9 -y
  ```

- Déclaration d'une zone sur le serveur maître
  
  ```bash
  nano /etc/bind/named.conf.local
  ```
  
  ```shell
  zone "sodecaf.fr" {
      type master;
      file "db.sodecaf.fr";
  };
  
  ```

- Enregistrement de type SOA
  
  ```bash
  nano /var/cache/bind/db.sodecaf.fr
  ```
  
  ```shell
  ;fichier de zone db.sodecaf.fr
  $TTL 86400
  @    IN    SOA    srv-dns1.sodecaf.fr    hostmaster.sodecaf.fr (
              2025092201    ;serial
              86400        ;refresh
              21600        ;retry
              3600000    ;expire
              3600 )    ;negative caching ttl
  
  @    IN    NS    srv-dns1.sodecaf.fr.
  @    IN    NS    srv-dns2.sodecaf.fr.
  
  srv-dns1    IN    A    172.16.0.3
  srv-dns2    IN    A    172.16.0.4
  srv-web1    IN    A    172.16.0.10
  srv-web2    IN    A    172.16.0.11
  www        IN    A    172.16.0.12
  web1        IN    CNAME    srv-web1.sodecaf.fr
  web2        IN    CNAME    srv-web2.sodecaf.fr
  ```

- Déclaration de zone inverse
  
  ```bash
  nano /etc/bind/named.conf.local
  ```
  
  ```shell
  zone "0.16.172.in-addr.arpa" {
      type master;
      file "db.172.16.0.rev";
  };
  ```

- Enregistrement de la zone inverse
  
  ```bash
  
  cp /var/cache/bind/db.sodecaf.fr /var/cache/bind/db.172.16.0.rev
  nano /var/cache/bind/db.172.16.0.rev
  ```
  
  ```shell
  ;fichier de zone db.172.16.0.rev
  $TTL 86400
  @    IN    SOA    srv-dns1.sodecaf.fr    hostmaster.sodecaf.fr (
              2025092201    ;serial
              86400        ;refresh
              21600        ;retry
              3600000    ;expire
              3600 )    ;negative caching ttl
  
  @    IN    NS    srv-dns1.sodecaf.fr.
  @    IN    NS    srv-dns2.sodecaf.fr.
  
  
  3    IN    PTR    srv-dns1.sodecaf.fr.
  4    IN    PTR    srv-dns2.sodecaf.fr.
  10    IN    PTR    srv-web1.sodecaf.fr.
  11    IN    PTR    srv-web2.sodecaf.fr.
  12    IN    PTR    www.sodecaf.fr.
  ```

## Sur SRV-DNS2

- Paramétrer l'esclave
  
  ```bash
  nano /etc/bind/named.conf/local
  ```
  
  ```shell
  zone "sodecaf.fr" {
      type slave;
      file "slave/db.sodecaf.fr";
      masters {172.16.0.3;};
  };
  
  zone "0.16.172.in-addr.arpa" {
      type slave;
      file "slave/db.172.16.0.rev";
      masters {172.16.0.3;};
  };
  ```

- créer le dossier 'slave' et le changer de groupe
  
  ```bash
  cd /var/cache/bind
  mkdir slave
  chgrp bind slave/
  chmod g+w slave/
  ```

- redémarrer bind9
  
  ```bash
  service bind9 restart
  ```

## Sur SRV-DNS1 et SRV-DNS2

- Activer et paramétrer l'option Forwarder
  
  ```bash
  nano /etc/bind/named.conf.options
  ```
  
  ```shell
  options {
      directory "var/cache/bind";
      forwarders {
              8.8.8.8;
              1.1.1.1;
      };
  };
  ```


