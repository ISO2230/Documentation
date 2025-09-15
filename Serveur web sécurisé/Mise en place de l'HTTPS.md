# Mise en oeuvre de l'HTTPS sur un serveur web

# Utilisation d'une autorité de certification interne

## 1. Préparation de la machine CA

- Configuration IP : /etc/network/interfaces
  
  ```bash
  allow-hotplug ens33
  iface ens33 inet static
        address 172.16.0.20/24
        gateway 172.16.0.254
  ```

- Installation d'openssl
  
  ```bash
  apt update && sudo apt upgrade -y
  apt install openssl
  ```
  
  ## 2. configuration d'openssl

- Editez le fichier /etc/ssl/openssl.cnf
  
  ```bash
  dir = ./sodecaf
  ```

- Création des dossiers et fichiers nécessaires
  
  ```bash
  mkdir /etc/ssl/sodecaf
  mkdir /etc/ssl/sodecaf/private
  mkdir /etc/ssl/sodecaf/certs
  mkdir /etc/ssl/sodecaf/newcerts
  cd /etc/ssl/sodecaf/
  touch index.txt
  echo "01" > serial
  ```

- Création de la clé privée cakey.pem
  
  ```bash
  openssl genrsa -des3 -out /etc/ssl/sodecaf/private/cakey.pem 4096
  ```

> Mot de passe de chiffrement pour cakey.pem : Btssio2017

- 

  Accorder uniquement l'accès en lecture seule à root pour la clé privée

```bash
chmod 400 /etc/ssl/sodecaf/private/cakey.pem
```

- Création du certificat auto-signé de l'autorité de certification
  
  ```bash
  openssl req -new -x509 -days 1825 -key /etc/ssl/sodecaf/private/cakey.pem -out /etc/ssl/sodecaf/certs/cacert.pem
  ```
