#!/bin/bash

# Mise à jour du système
sudo apt-get update
sudo apt-get upgrade -y

# Installation de MariaDB
sudo apt-get install -y mariadb-server

# Configuration de MariaDB
sudo sed -i 's/127.0.0.1/10.5.1.211/g' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo mysql -u root -e "CREATE DATABASE app_nulle;"
sudo mysql -u root -e "CREATE USER 'app_user'@'10.5.1.11' IDENTIFIED BY 'password';"
sudo mysql -u root -e "GRANT ALL PRIVILEGES ON app_nulle.* TO 'app_user'@'10.5.1.11';"
sudo mysql -u root -e "FLUSH PRIVILEGES;"
