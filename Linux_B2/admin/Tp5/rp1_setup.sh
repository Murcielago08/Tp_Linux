#!/bin/bash

# Mise à jour du système
sudo apt-get update
sudo apt-get upgrade -y

# Installation de NGINX
sudo apt-get install -y nginx

# Installation de certbot pour Let's Encrypt
sudo apt-get install -y certbot python3-certbot-nginx

# Ajustement des permissions sur le répertoire /etc/letsencrypt
sudo chown -R vagrant:vagrant /etc/letsencrypt

# Obtention du certificat SSL avec Let's Encrypt
sudo certbot --nginx --agree-tos --register-unsafely-without-email --redirect --non-interactive -d app_nulle.tp2.b5

# Configuration du reverse proxy pour HTTPS
sudo rm /etc/nginx/sites-enabled/default
echo 'server {
        listen 127.0.0.1:80;
        server_name app_nulle.tp2.b5;

        location / {
            proxy_pass http://10.5.1.11;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }

    server {
        listen 127.0.0.1:443 ssl;
        server_name app_nulle.tp2.b5;

        ssl_certificate /etc/letsencrypt/live/app_nulle.tp2.b5/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/app_nulle.tp2.b5/privkey.pem;

        location / {
            proxy_pass http://10.5.1.11;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
        }
    }' | sudo tee /etc/nginx/sites-available/app_nulle.conf


sudo ln -s /etc/nginx/sites-available/app_nulle.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx
