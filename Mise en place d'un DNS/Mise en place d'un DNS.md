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
  }
  ```

- Enregistrement de type SOA
  
  ```bash
  nano /etc/var/cache/bind/db.sodecaf.fr
  ```
  
  ```shell
  
  ```
