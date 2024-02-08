#!/bin/bash

# Mise à jour du système
sudo apt-get update
sudo apt-get upgrade -y

# Installation de Docker
sudo apt-get install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker

# Configuration de Apache et PHP dans un conteneur Docker
sudo docker run -d --name app_nulle \
  -v /path/to/app_nulle:/var/www/app_nulle \
  -p 127.0.0.1:80:80 \
  -e VIRTUAL_HOST=app_nulle.tp2.b5 \
  php:apache
