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
  dir = /etc/ssl/sodecaf
  certificate = $dir/certs/cacert.pem
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

- Accorder uniquement l'accès en lecture seule à root pour la clé privée
  
  ```bash
  chmod 400 /etc/ssl/sodecaf/private/cakey.pem
  ```

- Création du certificat auto-signé de l'autorité de certification
  
  ```bash
    openssl req -new -x509 -days 1825 -key /etc/ssl/sodecaf/private/cakey.pem -out  /etc/ssl/sodecaf/certs/cacert.pem
  ```

- Configuration d'openssl.cnf sur le serveur web
  
  ```bash
  dir = /etc/ssl
  ```

- Création du fichier de demande de certificat
  
  ```bash
  openssl req -new -key /etc/ssl/private/srvwebkey.pem -out certs/srvwebkey_dem.pem
  ```

- Copie du fichier de demande de certificat sur la machine CA
  
  ```bash
  scp /etc/ssl/certs/srvwebkey_dem.pem etudiant@172.16.0.20:/home/etudiant
  ```

## 3. On travaille sur CA

- Création du certificat signé par l'autorité de certification
  
  ```bash
  openssl ca -policy policy_anything -out /etc/ssl/srvwebcert.pem -infiles /home/etudiant/srvwebkey_dem.pem
  ```

- Copie du certificat signé sur le serveur web SRV-WEB1
  
  ```bash
  scp /etc/ssl/sodecaf/certs/srvwebcert.pem etudiant@172.16.0.10:/home/etudiant
  ```

## 4. On travaille sur SRV-WEB1

- Déplacer le certificat signé dans le dossier des certificats
  
  ```bash
  mv /home/etudiant/srvwebcert.pem /etc/ssl/certs
  ```

- Changement de propriétaire du certificat
  
  ```bash
  chown root:root /etc/ssl/certs/srvwebcert.pem
  ```

## 5. Configuration d'Apache2 sur SRV-WEB1

- Activation du module SSL sous Apache2
  
  ```bash
  a2enmod ssl
  ```

- Création du Virtualhost pour HTTPS
  
  ```bash
  cd /etc/apache2/sites-available
  cp ./sodecaf.conf sodecaf-ssl.conf
  ```
- Configuration de sodecaf-ssl.conf
  ```bash
  nano /etc/apache2/sites-available/sodecaf-ssl.conf
  ```
  ```apacheconf
  <VirtualHost *:443>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@sodecaf.local
        DocumentRoot /var/www/sodecaf
        DirectoryIndex sodecaf.html

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/srvwebcert.pem
        SSLCertificateKeyFile /etc/ssl/private/srvwebkey.pem

#       RewriteEngine On
#       RewriteCond %{HTTPS} !=on
#       RewriteRule ^/?(.*) https://%{SERVER_NAME}/$1 [R,L]

        <Directory "/var/www/sodecaf">
                Options -ExecCGI
                Options -Indexes
        </Directory>

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

        # For most configuration files from conf-available/, which are
        # enabled or disabled at a global level, it is possible to
        # include a line for only one particular virtual host. For example the
        # following line enables the CGI configuration for this host only
        # after it has been globally disabled with "a2disconf".
        #Include conf-available/serve-cgi-bin.conf
</VirtualHost>
```
