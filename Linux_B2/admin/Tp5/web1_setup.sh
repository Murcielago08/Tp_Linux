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

# Installation de Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
config_status=$?

if [ $config_status -ne 0 ]; then
    echo "Erreur lors de l'ajout du dépôt Docker."
    exit $config_status
fi

sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
install_status=$?

if [ $install_status -ne 0 ]; then
    echo "Erreur lors de l'installation de Docker."
    exit $install_status
fi

sudo systemctl start docker
start_status=$?

if [ $start_status -ne 0 ]; then
    echo "Erreur lors du démarrage du service Docker."
    exit $start_status
fi

sudo systemctl enable docker
enable_status=$?

if [ $enable_status -ne 0 ]; then
    echo "Erreur lors de l'activation du service Docker au démarrage."
    exit $enable_status
fi

# Configuration de Apache et PHP dans un conteneur Docker
cd /var/serv
sudo docker compose up -d
compose_status=$?

if [ $compose_status -ne 0 ]; then
    echo "Erreur lors du démarrage des conteneurs Apache et PHP."
    exit $compose_status
fi

echo "Tout s'est bien déroulé."
