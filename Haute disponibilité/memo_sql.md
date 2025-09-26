# Mémo SQL

- Créer une base de données
  
  ```sql
  create database gsb_valide;
  ```

- Créer un nouvel utilisateur
  
  ```sql
  create user 'userGsb'@'localhost' identified by 'secret';
  ```

- Importer un fichier SQL
  
  ```bash
  mysql gsb_valide < gsb_frais_structure.sql
  ```

- Donner les droits d'un utilisateur à une base de données
  
  ```sql
  grant all privileges on gsb_valide.* to 'userGsb'@'localhost';
  flush privileges;
  ```

- Afficher le contenu d'une table
  
  ```sql
  use gsb_valide;
  select * from Visiteur;
  ```






