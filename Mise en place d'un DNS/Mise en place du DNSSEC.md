# Mise en place du DNSSEC sur SRV-DNS1

- Créer une clé dnssec dans /etc/bind/keys
  
  ```bash
  cd /etc/bind
  mkdir keys
  dnssec-keygen -a rsasha1 -b 1024 -n zone sodecaf.fr
  ```
  
  > Clé ZSK Sodecaf publique : Ksodecaf.fr.+005+59788.key
  > 
  > Clé ZSK Sodecaf privée : Ksodecaf.fr.+005+59788.private
  
  ```bash
  dnssec-keygen -a rsasha1 -b 1024 -f KSK -n zone sodecaf.fr
  ```
  
  > Clé KSK Sodecaf publique : Ksodecaf.fr.+005+23627.key
  > 
  > Clé KSK Sodecaf privée : Ksodecaf.fr.+005+23627.private

- Ajouter les clés publiques ZSK et KSK dans /var/cache/bind/db.sodecaf.fr
  
  ```bash
  nano /var/cache/bind/db.sodecaf.fr
  ```
  
  ```shell
  ;KSK
  $include "/etc/bind/keys/Ksodecaf.fr.+005+23627.key"
  
  ;ZSK
  $inlude "/etc/bind/keys/Ksodecaf.fr.+005+59788.key"
  ```

- Signer la zone db.sodecaf.fr
  
  ```bash
  cd /var/cache/bind
  dnssec-signzone -o sodecaf.fr -t -k /etc/bind/keys/Ksodecaf.fr.+005+23627 db.sodecaf.fr /etc/bind/keys/Ksodecaf.fr.+005+59788
  ```
