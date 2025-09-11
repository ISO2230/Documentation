# Mise en place de l'HTTPS

# Utilisation d'une autorité de certification interne

## Préparation de la machine CA

- Installation d'Openssl :
  
  ```bash
  apt update && apt upgrade -y
  apt install openssl
  ```

- Paramétrer la configuration d'Openssl et changer la valeur de la variable `dir` par `/etc/ssl` :
  
  ```bash
  nano /etc/ssl/openssl.cnf
  ```




