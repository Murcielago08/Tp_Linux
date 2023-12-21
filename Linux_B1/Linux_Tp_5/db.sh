#!/bin/bash

# desactivation de SElinux de façon permanante
sed -i 's/enforcing/permissive/g' /etc/selinux/config
setenforce 0

# nom de la machine
echo 'db.tp5.linux' | tee /etc/hostname

# intallation mariadb et mise en route du service ^^
dnf install mariadb-server -y > /dev/null
systemctl start mariadb
systemctl enable mariadb
echo "Mariadb est installé et lancer avec succès"

# configuration et installation de mysql_secure
## Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.plugin', 'mysql_native_password', '$.authentication_string', PASSWORD('$esc_pass')) WHERE User='root';"
## Kill the anonymous users
mysql -e "DELETE FROM mysql.global_priv WHERE User='';"
## disallow remote login for root
mysql -e "DELETE FROM mysql.global_priv WHERE User='root' AND Host NOT IN
('localhost', '127.0.0.1', '::1');"
## Kill off the demo database
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
## Make our changes take effect
mysql -e "FLUSH PRIVILEGES;"
mysql -e "UPDATE mysql.global_priv SET priv=json_set(priv, '$.password_last_changed', UNIX_TIMESTAMP(), '$.plugin', 'mysql_native_password','$.authentication_string', 'invalid', '$.auth_or', json_array(json_object(), json_object('plugin', 'unix_socket'))) WHERE User='root';"
## ouverture du port pour mariadb
firewall-cmd --add-port=3306/tcp --permanent > /dev/null
firewall-cmd --reload > /dev/null
echo "Port pour le service mariadb ouvert"

systemctl restart mariadb

# setup de la base de donnée nextcloud
ip="hostname -I"
mysql -e "CREATE USER 'nextcloud'@'ip' IDENTIFIED BY 'pewpewpew';"
mysql -e "CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'ip';"
mysql -e "FLUSH PRIVILEGES;"

echo "Installation, configiration et setup de la base de donnée de mariadb fini ^^"