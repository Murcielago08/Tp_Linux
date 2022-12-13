**Sommaire**
- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)
- [Partie 2 : Mise en place et maîtrise du serveur de base de données](#partie-2--mise-en-place-et-maîtrise-du-serveur-de-base-de-données)
- [Partie 3 : Configuration et mise en place de NextCloud](#partie-3--configuration-et-mise-en-place-de-nextcloud)
  - [1. Base de données](#1-base-de-données)
  - [2. Serveur Web et NextCloud](#2-serveur-web-et-nextcloud)
  - [3. Finaliser l'installation de NextCloud](#3-finaliser-linstallation-de-nextcloud)

# Partie 1 : Mise en place et maîtrise du serveur Web

Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.

On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.

![Tipiii](../pics/linux_is_a_tipi.jpg)

## 1. Installation

🖥️ **VM web.tp5.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](../README.md#checklist).**

| Machine         | IP            | Service     |
|-----------------|---------------|-------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web |

🌞 **Installer le serveur Apache**

- paquet `httpd`
- la conf se trouve dans `/etc/httpd/`
  - le fichier de conf principal est `/etc/httpd/conf/httpd.conf`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`

> Ce que j'entends au-dessus par "fichier de conf principal" c'est que c'est **LE SEUL** fichier de conf lu par Apache quand il démarre. C'est souvent comme ça : un service ne lit qu'un unique fichier de conf pour démarrer. Cherchez pas, on va toujours au plus simple. Un seul fichier, c'est simple.  
**En revanche** ce serait le bordel si on mettait toute la conf dans un seul fichier pour pas mal de services.  
Donc, le principe, c'est que ce "fichier de conf principal" définit généralement deux choses. D'une part la conf globale. D'autre part, il inclut d'autres fichiers de confs plus spécifiques.  
On a le meilleur des deux mondes : simplicité (un seul fichier lu au démarrage) et la propreté (éclater la conf dans plusieurs fichiers).

🌞 **Démarrer le service Apache**

- le service s'appelle `httpd` (raccourci pour `httpd.service` en réalité)
  - démarrez-le
  - faites en sorte qu'Apache démarre automatiquement au démarrage de la machine
    - ça se fait avec une commande `systemctl` référez-vous au mémo
  - ouvrez le port firewall nécessaire
    - utiliser une commande `ss` pour savoir sur quel port tourne actuellement Apache
    - une portion du mémo commandes est dédiée à `ss`

**En cas de problème** (IN CASE OF FIIIIRE) vous pouvez check les logs d'Apache :

```bash
# Demander à systemd les logs relatifs au service httpd
$ sudo journalctl -xe -u httpd

# Consulter le fichier de logs d'erreur d'Apache
$ sudo cat /var/log/httpd/error_log

# Il existe aussi un fichier de log qui enregistre toutes les requêtes effectuées sur votre serveur
$ sudo cat /var/log/httpd/access_log
```

🌞 **TEST**

- vérifier que le service est démarré
- vérifier qu'il est configuré pour démarrer automatiquement
- vérifier avec une commande `curl localhost` que vous joignez votre serveur web localement
- vérifier depuis votre PC que vous accéder à la page par défaut
  - avec votre navigateur (sur votre PC)
  - avec une commande `curl` depuis un terminal de votre PC (je veux ça dans le compte-rendu, pas de screen)

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

- affichez le contenu du fichier `httpd.service` qui contient la définition du service Apache

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

- mettez en évidence la ligne dans le fichier de conf principal d'Apache (`httpd.conf`) qui définit quel user est utilisé
- utilisez la commande `ps -ef` pour visualiser les processus en cours d'exécution et confirmer que apache tourne bien sous l'utilisateur mentionné dans le fichier de conf
  - filtrez les infos importantes avec un `| grep`
- la page d'accueil d'Apache se trouve dans `/usr/share/testpage/`
  - vérifiez avec un `ls -al` que tout son contenu est **accessible en lecture** à l'utilisateur mentionné dans le fichier de conf

🌞 **Changer l'utilisateur utilisé par Apache**

- créez un nouvel utilisateur
  - pour les options de création, inspirez-vous de l'utilisateur Apache existant
    - le fichier `/etc/passwd` contient les informations relatives aux utilisateurs existants sur la machine
    - servez-vous en pour voir la config actuelle de l'utilisateur Apache par défaut (son homedir et son shell en particulier)
- modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
- redémarrez Apache
- utilisez une commande `ps` pour vérifier que le changement a pris effet
  - vous devriez voir un processus au moins qui tourne sous l'identité de votre nouvel utilisateur

🌞 **Faites en sorte que Apache tourne sur un autre port**

- modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix
  - montrez la ligne de conf dans le compte rendu, avec un `grep` pour ne montrer que la ligne importante
- ouvrez ce nouveau port dans le firewall, et fermez l'ancien
- redémarrez Apache
- prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi
- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port
- vérifiez avec votre navigateur que vous pouvez joindre le serveur sur le nouveau port

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](../part2/README.md)**

# Partie 2 : Mise en place et maîtrise du serveur de base de données

Petite section de mise en place du serveur de base de données sur `db.tp5.linux`. On ira pas aussi loin qu'Apache pour lui, simplement l'installer, faire une configuration élémentaire avec une commande guidée (`mysql_secure_installation`), et l'analyser un peu.

🖥️ **VM db.tp5.linux**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

| Machines        | IP            | Service                 |
|-----------------|---------------|-------------------------|
| `web.tp5.linux` | `10.105.1.11` | Serveur Web             |
| `db.tp5.linux`  | `10.105.1.12` | Serveur Base de Données |

🌞 **Install de MariaDB sur `db.tp5.linux`**

- déroulez [la doc d'install de Rocky](https://docs.rockylinux.org/guides/database/database_mariadb-server/)
- je veux dans le rendu **toutes** les commandes réalisées
- faites en sorte que le service de base de données démarre quand la machine s'allume
  - pareil que pour le serveur web, c'est une commande `systemctl` fiez-vous au mémo

🌞 **Port utilisé par MariaDB**

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp5.linux`
  - filtrez les infos importantes avec un `| grep`
- il sera nécessaire de l'ouvrir dans le firewall

> La doc vous fait exécuter la commande `mysql_secure_installation` c'est un bon réflexe pour renforcer la base qui a une configuration un peu *chillax* à l'install.

🌞 **Processus liés à MariaDB**

- repérez les processus lancés lorsque vous lancez le service MariaDB
- utilisz une commande `ps`
  - filtrez les infos importantes avec un `| grep`

# Partie 3 : Configuration et mise en place de NextCloud

Enfin, **on va setup NextCloud** pour avoir un site web qui propose de vraies fonctionnalités et qui a un peu la classe :)

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