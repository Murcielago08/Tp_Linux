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

# Installation de NGINX
sudo dnf install -y nginx
nginx_install_status=$?

if [ $nginx_install_status -ne 0 ]; then
    echo "Erreur lors de l'installation de NGINX."
    exit $nginx_install_status
fi

# Installation de certbot pour Let's Encrypt
sudo dnf install -y certbot python3-certbot-nginx
certbot_install_status=$?

if [ $certbot_install_status -ne 0 ]; then
    echo "Erreur lors de l'installation de certbot."
    exit $certbot_install_status
fi

# Ajustement des permissions sur le répertoire /etc/letsencrypt
sudo chown -R vagrant:vagrant /etc/letsencrypt
chown_status=$?

if [ $chown_status -ne 0 ]; then
    echo "Erreur lors de l'ajustement des permissions sur /etc/letsencrypt."
    exit $chown_status
fi

# Obtention du certificat SSL avec Let's Encrypt
sudo certbot --nginx --agree-tos --register-unsafely-without-email --redirect --non-interactive -d app_nulle.tp2.b5
certbot_status=$?

if [ $certbot_status -ne 0 ]; then
    echo "Erreur lors de l'obtention du certificat SSL avec Let's Encrypt."
    exit $certbot_status
fi

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
    }' | sudo tee /etc/nginx/conf.d/app_nulle.conf

nginx_conf_status=$?

if [ $nginx_conf_status -ne 0 ]; then
    echo "Erreur lors de la configuration du reverse proxy pour HTTPS."
    exit $nginx_conf_status
fi

#sudo ln -s /etc/nginx/conf.d/app_nulle.conf /etc/nginx/sites-enabled/
sudo systemctl restart nginx
nginx_restart_status=$?

if [ $nginx_restart_status -ne 0 ]; then
    echo "Erreur lors du redémarrage de NGINX."
    exit $nginx_restart_status
fi

echo "Tout s'est bien déroulé."
