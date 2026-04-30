# Prérequis pour la répartition de charge avec HAProxy

- Un serveur Debian 12 pour HAProxy
- Deux serveurs web (on utilisera ceux du cluster corosync)

## Préparation du cluster

Sur srv-web1, supprimer la ressource servweb de corosync :

```shell
crm resource stop serviceWeb
crm resource stop IPFailover
crm configure delete servweb
crm resource start IPFailover
crm configure clone cServiceWeb serviceWeb
crm resource start serviceWeb
```

Si vous tapez la commande 'crm mon', vous devez avoir ce résultat :

```txt
crm_mon :
============
Last updated: Tue Aug 27 23:23:12 2013
...
============

Online: [ serv1 serv2 ]

Clone Set: cServiceMySQL [serviceMySQL]
	Started: [ serv2 serv1 ]
IPFailover	(ocf::heartbeat:IPaddr2):	Started serv1
Clone Set: cServiceWeb [serviceWeb]
	Started: [ serv2 serv1 ]
```

### Configuration de MySQL

Le fichier de configuration de MySQL doit être modifié de manière à ce que le service MySQL puisse supporter une écriture simultanée sur les deux serveurs (voir annexe 3 du Coté Labo « Haute disponibilité d'un service Web dynamique ») :

> **auto_increment_increment** contrôle l'incrémentation entre les valeurs successives des clés (le pas d'incrémentation).
> 
> **auto_increment_offset** détermine le point de départ des valeurs des colonnes de type AUTO_INCREMENT.

Sur le serveur serv1 (fichier /etc/mysql/mariadb.conf.d/50-server.cnf) :
```bash
auto_increment_offset=1
auto_increment_increment=2
```

Sur le serveur serv2 (fichier /etc/mysql/mariadb.conf.d/50-server.cnf) :
```bash
auto_increment_offset=2
auto_increment_increment=2
```
---
## HAProxy et HTTPS

Il est nécessaire de désactiver le protocole HTTPS de la configuration Apache2 sur les serveurs web.

Désactiver la partie HTTPS dans le fichier de configuration comme suit :
```bash
<VirtualHost *:80>
	ServerAdmin webmaster@sodecaf.fr
	DocumentRoot /var/www/sodecaf
	DirectoryIndex sodecaf.html
	
	<Directory "/var/www/sodecaf">
		Options -Indexes -FollowSymlinks -MultiViews -ExecCGI
		AllowOverride none
		Require all granted
	</Directory>
	
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
```
---
## Installation et première configuration d'HAProxy

Installation et démarrage d'HAProxy :
```shell
apt-get update && apt-get upgrade -y
apt-get install haproxy
```

