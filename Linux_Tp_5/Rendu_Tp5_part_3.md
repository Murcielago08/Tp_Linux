# Partie 3 : Configuration et mise en place de NextCloud

Enfin, **on va setup NextCloud** pour avoir un site web qui propose de vraies fonctionnalités et qui a un peu la classe :)

- [Partie 3 : Configuration et mise en place de NextCloud](#partie-3--configuration-et-mise-en-place-de-nextcloud)
  - [1. Base de données](#1-base-de-données)
  - [2. Serveur Web et NextCloud](#2-serveur-web-et-nextcloud)
  - [3. Finaliser l'installation de NextCloud](#3-finaliser-linstallation-de-nextcloud)

## 1. Base de données

Dans cette section, on va préparer le service de base de données pour que NextCloud puisse s'y connecter.

Le but :

- créer une base de données dans le serveur de base de données
- créer une utilisateur dans le serveur de base de données
- donner tous les droits à cet utilisateur sur la base de données qu'on a créé

> Note : ici on parle d'un utilisateur de la base de données. Il n'a rien à voir avec les utilisateurs du système Linux qu'on manipule habituellement. Il existe donc un système d'utilisateurs au sein d'un serveur de base de données, qui ont des droits définis sur des bases précises.

🌞 **Préparation de la base pour NextCloud**

- une fois en place, il va falloir préparer une base de données pour NextCloud :
  - connectez-vous à la base de données à l'aide de la commande `sudo mysql -u root -p`
  - exécutez les commandes SQL suivantes :

```sql
-- Création d'un utilisateur dans la base, avec un mot de passe
-- L'adresse IP correspond à l'adresse IP depuis laquelle viendra les connexions. Cela permet de restreindre les IPs autorisées à se connecter.
-- Dans notre cas, c'est l'IP de web.tp5.linux
-- "pewpewpew" c'est le mot de passe hehe
CREATE USER 'nextcloud'@'10.105.1.11' IDENTIFIED BY 'pewpewpew';

-- Création de la base de donnée qui sera utilisée par NextCloud
CREATE DATABASE IF NOT EXISTS nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- On donne tous les droits à l'utilisateur nextcloud sur toutes les tables de la base qu'on vient de créer
GRANT ALL PRIVILEGES ON nextcloud.* TO 'nextcloud'@'10.105.1.11';

-- Actualisation des privilèges
FLUSH PRIVILEGES;

-- C'est assez générique comme opération, on crée une base, on crée un user, on donne les droits au user sur la base
```

> Par défaut, vous avez le droit de vous connecter localement à la base si vous êtes `root`. C'est pour ça que `sudo mysql -u root` fonctionne, sans nous demander de mot de passe. Evidemment, n'importe quelles autres conditions ne permettent pas une connexion aussi facile à la base.

🌞 **Exploration de la base de données**

- afin de tester le bon fonctionnement de la base de données, vous allez essayer de vous connecter, **comme NextCloud le fera plus tard** :
  - depuis la machine `web.tp5.linux` vers l'IP de `db.tp5.linux`
  - utilisez la commande `mysql` pour vous connecter à une base de données depuis la ligne de commande
    - par exemple `mysql -u <USER> -h <IP_DATABASE> -p`
    - si vous ne l'avez pas, installez-là
    - vous pouvez déterminer dans quel paquet est disponible la commande `mysql` en saisissant `dnf provides mysql`
- **donc vous devez effectuer une commande `mysql` sur `web.tp5.linux`**
- une fois connecté à la base, utilisez les commandes SQL fournies ci-dessous pour explorer la base

```sql
SHOW DATABASES;
USE <DATABASE_NAME>;
SHOW TABLES;
```

> Si ça marche cette commande, alors on est assurés que NextCloud pourra s'y connecter aussi. En effet, il utilisera le même user et même password, depuis la même machine.

🌞 **Trouver une commande SQL qui permet de lister tous les utilisateurs de la base de données**

- vous ne pourrez pas utiliser l'utilisateur `nextcloud` de la base pour effectuer cette opération : il n'a pas les droits
- il faudra donc vous reconnectez localement à la base en utilisant l'utilisateur `root`

> Comme déjà dit dans une note plus haut, les utilisateurs de la base de données sont différents des utilisateurs du système Rocky Linux qui porte la base. Les utilisateurs de la base définissent des identifiants utilisés pour se connecter à la base afin d'y voir ou d'y modifier des données.

Une fois qu'on s'est assurés qu'on peut se co au service de base de données depuis `web.tp5.linux`, on peut continuer.

## 2. Serveur Web et NextCloud

⚠️⚠️⚠️ **N'OUBLIEZ PAS de réinitialiser votre conf Apache avant de continuer. En particulier, remettez le port et le user par défaut.**

🌞 **Install de PHP**

```bash
# On ajoute le dépôt CRB
$ sudo dnf config-manager --set-enabled crb
# On ajoute le dépôt REMI
$ sudo dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-9.rpm -y

# On liste les versions de PHP dispos, au passage on va pouvoir accepter les clés du dépôt REMI
$ dnf module list php

# On active le dépôt REMI pour récupérer une version spécifique de PHP, celle recommandée par la doc de NextCloud
$ sudo dnf module enable php:remi-8.1 -y

# Eeeet enfin, on installe la bonne version de PHP : 8.1
$ sudo dnf install -y php81-php
```

🌞 **Install de tous les modules PHP nécessaires pour NextCloud**

```bash
# eeeeet euuuh boom. Là non plus j'ai pas pondu ça, c'est la doc :
$ sudo dnf install -y libxml2 openssl php81-php php81-php-ctype php81-php-curl php81-php-gd php81-php-iconv php81-php-json php81-php-libxml php81-php-mbstring php81-php-openssl php81-php-posix php81-php-session php81-php-xml php81-php-zip php81-php-zlib php81-php-pdo php81-php-mysqlnd php81-php-intl php81-php-bcmath php81-php-gmp
```

🌞 **Récupérer NextCloud**

- créez le dossier `/var/www/tp5_nextcloud/`
  - ce sera notre *racine web* (ou *webroot*)
  - l'endroit où le site est stocké quoi, on y trouvera un `index.html` et un tas d'autres marde, tout ce qui constitue NextCloud :D
- récupérer le fichier suivant avec une commande `curl` ou `wget` : https://download.nextcloud.com/server/prereleases/nextcloud-25.0.0rc3.zip
- extrayez tout son contenu dans le dossier `/var/www/tp5_nextcloud/` en utilisant la commande `unzip`
  - installez la commande `unzip` si nécessaire
  - vous pouvez extraire puis déplacer ensuite, vous prenez pas la tête
  - contrôlez que le fichier `/var/www/tp5_nextcloud/index.html` existe pour vérifier que tout est en place
- **assurez-vous que le dossier `/var/www/tp5_nextcloud/` et tout son contenu appartient à l'utilisateur qui exécute le service Apache**
  - utilisez une commande `chown` si nécessaire

> A chaque fois que vous faites ce genre de trucs, assurez-vous que c'est bien ok. Par exemple, vérifiez avec un `ls -al` que tout appartient bien à l'utilisateur qui exécute Apache.

🌞 **Adapter la configuration d'Apache**

- regardez la dernière ligne du fichier de conf d'Apache pour constater qu'il existe une ligne qui inclut d'autres fichiers de conf
- créez en conséquence un fichier de configuration qui porte un nom clair et qui contient la configuration suivante :

```apache
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

![NextCloud error](../pics/nc_install.png)

## 3. Finaliser l'installation de NextCloud

➜ **Sur votre PC**

- modifiez votre fichier `hosts` (oui, celui de votre PC, de votre hôte)
  - pour pouvoir joindre l'IP de la VM en utilisant le nom `web.tp5.linux`
- avec un navigateur, visitez NextCloud à l'URL `http://web.tp5.linux`
  - c'est possible grâce à la modification de votre fichier `hosts`
- on va vous demander un utilisateur et un mot de passe pour créer un compte admin
  - ne saisissez rien pour le moment
- cliquez sur "Storage & Database" juste en dessous
  - choisissez "MySQL/MariaDB"
  - saisissez les informations pour que NextCloud puisse se connecter avec votre base
- saisissez l'identifiant et le mot de passe admin que vous voulez, et validez l'installation

🌴 **C'est chez vous ici**, baladez vous un peu sur l'interface de NextCloud, faites le tour du propriétaire :)

🌞 **Exploration de la base de données**

- connectez vous en ligne de commande à la base de données après l'installation terminée
- déterminer combien de tables ont été crées par NextCloud lors de la finalisation de l'installation
  - ***bonus points*** si la réponse à cette question est automatiquement donnée par une requête SQL