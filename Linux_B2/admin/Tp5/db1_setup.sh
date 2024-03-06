#!/bin/bash

# Mise à jour du système
sudo dnf update -y
update_status=$?

if [ $update_status -ne 0 ]; then
    echo "Erreur lors de la mise à jour du système."
    exit $update_status
fi

sudo dnf upgrade -y
upgrade_status=$?

if [ $upgrade_status -ne 0 ]; then
    echo "Erreur lors de la mise à niveau du système."
    exit $upgrade_status
fi

# Installation de MariaDB
sudo dnf install -y mariadb-server
mariadb_install_status=$?

if [ $mariadb_install_status -ne 0 ]; then
    echo "Erreur lors de l'installation de MariaDB."
    exit $mariadb_install_status
fi

# Configuration de MariaDB
sudo systemctl start mariadb
start_status=$?

if [ $start_status -ne 0 ]; then
    echo "Erreur lors du démarrage de MariaDB."
    exit $start_status
fi

sudo systemctl enable mariadb
enable_status=$?

if [ $enable_status -ne 0 ]; then
    echo "Erreur lors de l'activation de MariaDB au démarrage."
    exit $enable_status
fi

# Chemin du fichier init.sql
init_sql="/home/vagrant/db_init/init.sql"

# Vérification de l'existence du fichier init.sql
if [ -f "$init_sql" ]; then
    # Si le fichier existe, exécutez-le pour initialiser la base de données
    sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS meo; USE meo; SOURCE $init_sql;"
    mysql_status=$?

    if [ $mysql_status -ne 0 ]; then
        echo "Erreur lors de l'exécution du fichier $init_sql pour créer la base de données."
        exit $mysql_status
    else
        echo "Le fichier $init_sql a été exécuté avec succès pour créer la table 'meo'."
    fi
else
    echo "Le fichier $init_sql n'existe pas."
fi

echo "Tout s'est bien déroulé."
