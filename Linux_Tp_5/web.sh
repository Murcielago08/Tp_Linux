#!/bin/bash

# Verification si le fichier de conf apache à copier existe bien
if [[ ! -f /srv/conf_for_nextcloud ]]; then
  echo "Fichier /srv/conf_for_nextcloud pas crée, créer le avec comme contenu la configuration à la fin du petit 2 de la partie 3 du tp5 linux (TP5 : Self-hosted cloud)"
  exit 0
fi

#desactivation de SElinux de façon permanante
sed -i 's/enforcing/permissive/g' /etc/selinux/config
setenforce 0

# nom de la machine
echo 'db.tp5.linux' | tee /etc/hostname

# installation du serveur apache
dnf install httpd -y > /dev/null
systemctl enable httpd
systemctl start httpd
echo "Serveur Apache installé et lancé ^^"

# ouverture du port pour apache
firewall-cmd --add-port=80/tcp --permanent > /dev/null
firewall-cmd --reload > /dev/null
echo "Port pour le service apache ouvert ^^"

# installation de php
dnf config-manager --set-enabled crb -y > /dev/null
dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y > /dev/null
dnf module list php -y > /dev/null
dnf module enable php:remi-8.1 -y > /dev/null
dnf install -y php81-php > /dev/null
## installation des modules php nécessaires pour nextcloud
dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
echo "Service php installé ^^"

# récupération du dossier pour nextcloud
mkdir /var/www/tp5_nextcloud/
curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip -O > /dev/null
dnf install unzip -y > /dev/null
unzip nextcloud-25.0.0rc3.zip > /dev/null
mv nextcloud/* /var/www/tp5_nextcloud/
cd /var/www/
sudo chown apache:apache tp5_nextcloud/
chown -R apache:apache tp5_nextcloud/
echo "Récupération du dossier nextcloud et déplacer dans le fichier /var/www/tp5_nextcloud/ ^^"

# copie de la conf dans le tp5 dans un dossier .conf pour nextcloud
cp /srv/conf_for_nextcloud /etc/httpd/conf.d/tp5_nextcloud.conf
# restart serveur apache
systemctl restart httpd
echo "Installation et configuration du serveur apache, démarrage du nextcloud ^^"