# Partie 3 : Configuration et mise en place de NextCloud

Enfin, **on va setup NextCloud** pour avoir un site web qui propose de vraies fonctionnalités et qui a un peu la classe :)

- [Partie 3 : Configuration et mise en place de NextCloud](#partie-3--configuration-et-mise-en-place-de-nextcloud)
  - [1. Base de données](#1-base-de-données)
  - [2. Serveur Web et NextCloud](#2-serveur-web-et-nextcloud)
  - [3. Finaliser l'installation de NextCloud](#3-finaliser-linstallation-de-nextcloud)

## 1. Base de données

🌞 **Préparation de la base pour NextCloud**

- une fois en place, il va falloir préparer une base de données pour NextCloud :
  - connectez-vous à la base de données à l'aide de la commande `sudo mysql -u root -p`

```
[murci@tp5db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 18
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
Query OK, 1 row affected (0.000 sec)

MariaDB [(none)]> GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';
Query OK, 0 rows affected (0.001 sec)

MariaDB [(none)]> FLUSH PRIVILEGES;
Query OK, 0 rows affected (0.000 sec)
```

🌞 **Exploration de la base de données**

- afin de tester le bon fonctionnement de la base de données, vous allez essayer de vous connecter, **comme NextCloud le fera plus tard** :
  - depuis la machine `web.tp5.linux` vers l'IP de `db.tp5.linux`

```
[murci@tp5web ~]$ mysql -u nextcloud -h 10.105.1.12 -p

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| nextcloud          |
+--------------------+
2 rows in set (0.00 sec)

mysql> USE nextcloud
Database changed
mysql> SHOW TABLES;
Empty set (0.00 sec)
```

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

- il faudra donc vous reconnectez localement à la base en utilisant l'utilisateur `root`
```
[murci@tp5db ~]$ sudo mysql -u root -p
Enter password:
Welcome to the MariaDB monitor.  Commands end with ; or \g.
Your MariaDB connection id is 24
Server version: 10.5.16-MariaDB MariaDB Server

Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

MariaDB [(none)]> use mysql;SELECT user FROM user;
Reading table information for completion of table and column names
You can turn off this feature to get a quicker startup with -A

Database changed
+-------------+
| User        |
+-------------+
| nextcloud   |
| mariadb.sys |
| mysql       |
| root        |
+-------------+
4 rows in set (0.001 sec)
```

## 2. Serveur Web et NextCloud

🌞 **Install de PHP**

```
[murci@tp5web ~]$ sudo dnf config-manager --set-enabled crb

[murci@tp5web ~]$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

[murci@tp5web ~]$ dnf module list php
Last metadata expiration check: 0:00:08 ago on Tue 13 Dec 2022 04:33:09 PM CET.
Rocky Linux 9 - AppStream
Name     Stream      Profiles                      Summary
php      8.1         common [d], devel, minimal    PHP scripting language

Remi's Modular repository for Enterprise Linux 9 - x86_64
Name     Stream      Profiles                      Summary
php      remi-7.4    common [d], devel, minimal    PHP scripting language
php      remi-8.0    common [d], devel, minimal    PHP scripting language
php      remi-8.1    common [d], devel, minimal    PHP scripting language
php      remi-8.2    common [d], devel, minimal    PHP scripting language

[murci@tp5web ~]$ sudo dnf module enable php:remi-8.1 -y
Complete!

[murci@tp5web ~]$ sudo dnf install -y php81-php
Complete!
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```
[murci@tp5web ~]$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
Complete!
```

🌞 **Récupérer NextCloud**

- récupérer le fichier suivant avec une commande `curl` ou `wget` : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip

```
[murci@tp5web ~]$ curl https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip -O
```

- extrayez tout son contenu dans le dossier `/var/www/tp5_nextcloud/` en utilisant la commande `unzip`

```
[murci@tp5web ~]$ unzip nextcloud-25.0.0rc3.zip
[murci@tp5web ~]$ sudo mv nextcloud /var/www/tp5_nextcloud/
[murci@tp5web tp5_nextcloud]$ sudo mv -v /var/www/tp5_nextcloud/nextcloud/* /var/www/tp5_nextcloud/
[murci@tp5web tp5_nextcloud]$ sudo mv -v /var/www/tp5_nextcloud/nextcloud/.* /var/www/tp5_nextcloud/
```

- **assurez-vous que le dossier `/var/www/tp5_nextcloud/` et tout son contenu appartient à l'utilisateur qui exécute le service Apache**
  - utilisez une commande `chown` si nécessaire

```
[murci@tp5web tp5_nextcloud]$ sudo chown apache:apache tp5_nextcloud/
[murci@tp5web tp5_nextcloud]$ sudo chown -R apache:apache tp5_nextcloud/
```


🌞 **Adapter la configuration d'Apache**

- regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf

```
[murci@tp5web ~]$ cat /etc/httpd/conf/httpd.conf | grep "\.d"
Include conf.modules.d/*.conf
IncludeOptional conf.d/*.conf
```

- créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :

```
[murci@tp5web conf.d]$ cat vhost.conf
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/>
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

🌞 **Redémarrer le service Apache** pour qu'il prenne en compte le nouveau fichier de conf

```
[murci@tp5web conf.d]$ sudo systemctl restart httpd
```

## 3. Finaliser l'installation de NextCloud

🌞 **Exploration de la base de données**

- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation

```
[murci@tp5web ~]$ mysql -u nextcloud -h 10.105.1.12 -p

mysql> SELECT COUNT(*) AS nb_tables FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE';
+-----------+
| nb_tables |
+-----------+
|        95 |
+-----------+
1 row in set (0.00 sec)
```

➜ **NextCloud est tout bo, en place, vous pouvez aller sur [la partie 4.](Rendu_Tp5_part_4.md)**