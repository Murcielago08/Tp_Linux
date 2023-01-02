# TP6 : Travail autour de la solution NextCloud

Dans ce dernier TP, on va construire autour de la solution de la NextCloud pour améliorer son niveau de qualité ou de sécurité.

On se met dans la peau d'un admin jusqu'au bout, en proposant des fonctionnalités additionnelles permettant de s'assurer du bon fonctionnement de la solution dans le temps, de façon pérenne.

Ce qu'on fait avec NextCloud là est réplicable avec n'importe quelle autre application dans un autre environnement.

Concrètement, dans ce TP, on va :

- mettre en place un reverse proxy NGINX
  - il va protéger notre serveur web
- développer un script de sauvegarde
  - il sauvegardera à intervalles réguliers les fichiers liés à NextCloud
- installer fail2ban
  - pour se protéger des attaques de bruteforce
- mettre en place un monitoring simple
  - avec un autre outil libre : Netdata
  - il nous permettra de surveiller via une interface sexy l'état de notre serveur
  - et de nous envoyer des alertes (sur Discord) en cas de soucis

# 0. Setup

## Sommaire

- [TP6 : Travail autour de la solution NextCloud](#tp6--travail-autour-de-la-solution-nextcloud)
- [0. Setup](#0-setup)
  - [Sommaire](#sommaire)
  - [Checklist](#checklist)
  - [Le lab](#le-lab)
- [I. Here we go](#i-here-we-go)
- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)
- [Module 2 : Sauvegarde du système de fichiers](#module-2--sauvegarde-du-système-de-fichiers)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Clean it](#2-clean-it)
    - [3. Service et timer](#3-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)
- [Module 3 : Fail2Ban](#module-3--fail2ban)
- [Module 4 : Monitoring](#module-4--monitoring)

## Checklist

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] firewall actif, qui ne laisse passer que le strict nécessaire
- [x] SSH fonctionnel
- [x] accès Internet (une route par défaut, une carte NAT c'est très bien)
- [x] résolution de nom
- [x] SELinux activé en mode *"permissive"* (vérifiez avec `sestatus`, voir [mémo install VM tout en bas](https://gitlab.com/it4lik/b1-reseau-2022/-/blob/main/cours/memo/install_vm.md#4-pr%C3%A9parer-la-vm-au-clonage))

**Les éléments de la 📝checklist📝 sont STRICTEMENT OBLIGATOIRES à réaliser mais ne doivent PAS figurer dans le rendu.**

## Le lab

Vous pouvez réutiliser les VMs du TP précédent.

Dans la suite du TP, la machine qui porte NextCloud est appelée `web.tp6.linux` et celle qui porte la base de données `db.tp6.linux`.

Il est nécessaire en tout cas de partir avec NextCloud en place sur deux machines (web + db).

# I. Here we go

Pour plus de clarté, chaque partie est dans une page dédiée.

Chaque module est indépendant, et ils peuvent être faits dans le désordre.

- [TP6 : Travail autour de la solution NextCloud](#tp6--travail-autour-de-la-solution-nextcloud)
- [0. Setup](#0-setup)
  - [Sommaire](#sommaire)
  - [Checklist](#checklist)
  - [Le lab](#le-lab)
- [I. Here we go](#i-here-we-go)
- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)
- [Module 2 : Sauvegarde du système de fichiers](#module-2--sauvegarde-du-système-de-fichiers)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Clean it](#2-clean-it)
    - [3. Service et timer](#3-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)
- [Module 3 : Fail2Ban](#module-3--fail2ban)
- [Module 4 : Monitoring](#module-4--monitoring)

# Module 1 : Reverse Proxy

Un reverse proxy est donc une machine que l'on place devant un autre service afin d'accueillir les clients et servir d'intermédiaire entre le client et le service.

Dans notre cas, on va là encore utiliser un outil libre : NGINX (et oui, il peut faire ça aussi, c'est même sa fonction première).

L'utilisation d'un reverse proxy peut apporter de nombreux bénéfices :

- décharger le service HTTP de devoir effectuer le chiffrement HTTPS (coûteux en performances)
- répartir la charge entre plusieurs services
- effectuer de la mise en cache
- fournir un rempart solide entre un hacker potentiel et le service et les données importantes
- servir de point d'entrée unique pour accéder à plusieurs sites web


# I. Setup

🖥️ **VM `proxy.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](#checklist).**

➜ **On utilisera NGINX comme reverse proxy**

- installer le paquet `nginx`
- démarrer le service `nginx`
- utiliser la commande `ss` pour repérer le port sur lequel NGINX écoute
- ouvrir un port dans le firewall pour autoriser le trafic vers NGINX
- utiliser une commande `ps -ef` pour déterminer sous quel utilisateur tourne NGINX
- vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine

➜ **Configurer NGINX**

- nous ce qu'on veut, c'pas une page d'accueil moche, c'est que NGINX agisse comme un reverse proxy entre les clients et notre serveur Web
- deux choses à faire :
  - créer un fichier de configuration NGINX
    - la conf est dans `/etc/nginx`
    - procédez comme pour Apache : repérez les fichiers inclus par le fichier de conf principal, et créez votre fichier de conf en conséquence
  - NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy
    - y'a donc un fichier de conf NextCloud à modifier
    - c'est un fichier appelé `config.php`

Référez-vous à monsieur Google pour tout ça :)

Exemple de fichier de configuration minimal NGINX.:

```nginx
server {
    # On indique le nom que client va saisir pour accéder au service
    # Pas d'erreur ici, c'est bien le nom de web, et pas de proxy qu'on veut ici !
    server_name web.tp6.linux;

    # Port d'écoute de NGINX
    listen 80;

    location / {
        # On définit des headers HTTP pour que le proxying se passe bien
        proxy_set_header  Host $host;
        proxy_set_header  X-Real-IP $remote_addr;
        proxy_set_header  X-Forwarded-Proto https;
        proxy_set_header  X-Forwarded-Host $remote_addr;
        proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;

        # On définit la cible du proxying 
        proxy_pass http://<IP_DE_NEXTCLOUD>:80;
    }

    # Deux sections location recommandés par la doc NextCloud
    location /.well-known/carddav {
      return 301 $scheme://$host/remote.php/dav;
    }

    location /.well-known/caldav {
      return 301 $scheme://$host/remote.php/dav;
    }
}
```

➜ **Modifier votre fichier `hosts` de VOTRE PC**

- pour que le service soit joignable avec le nom `web.tp6.linux`
- c'est à dire que `web.tp6.linux` doit pointer vers l'IP de `proxy.tp6.linux`
- autrement dit, pour votre PC :
  - `web.tp6.linux` pointe vers l'IP du reverse proxy
  - `proxy.tp6.linux` ne pointe vers rien
  - taper `http://web.tp6.linux` permet d'accéder au site (en passant de façon transparente par l'IP du proxy)

> Oui vous ne rêvez pas : le nom d'une machine donnée pointe vers l'IP d'une autre ! Ici, on fait juste en sorte qu'un certain nom permette d'accéder au service, sans se soucier de qui porte réellement ce nom.

➜ **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy
- en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal
- **comment ?** Je vous laisser là encore chercher un peu par vous-mêmes (hint : firewall)

➜ **Une fois que c'est en place**

- faire un `ping` manuel vers l'IP de `proxy.tp6.linux` fonctionne
- faire un `ping` manuel vers l'IP de `web.tp6.linux` ne fonctionne pas

# II. HTTPS

Le but de cette section est de permettre une connexion chiffrée lorsqu'un client se connecte. Avoir le ptit HTTPS :)

Le principe :

- on génère une paire de clés sur le serveur `proxy.tp6.linux`
  - une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais
  - l'autre est la clé publique : elle sera stockée dans un fichier appelé *certificat*
    - le *certificat* est donné à chaque client qui se connecte au site
- on ajuste la conf NGINX
  - on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic
  - on lui demande d'écouter sur le port convetionnel pour HTTPS : 443 en TCP

Je vous laisse Google vous-mêmes "nginx reverse proxy nextcloud" ou ce genre de chose :)

# Module 2 : Sauvegarde du système de fichiers

Dans cette partie, **on va monter un *serveur de sauvegarde* qui sera chargé d'accueillir les sauvegardes des autres machines**, en particulier du serveur Web qui porte NextCloud.

Le *serveur de sauvegarde* sera un serveur NFS. NFS est un protocole qui permet de partager un dossier à travers le réseau.

Ainsi, notre *serveur de sauvegarde* pourra partager un dossier différent à chaque machine qui a besoin de stocker des données sur le long terme.

Dans le cadre du TP, le serveur partagera un dossier à la machine `web.tp6.linux`.

Sur la machine `web.tp6.linux` s'exécutera à un intervalles réguliers un script qui effectue une sauvegarde des données importantes de NextCloud et les place dans le dossier partagé.

Ainsi, ces données seront archivées sur le *serveur de sauvegarde*.

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

- il s'appellera `tp6_backup.sh`
- il devra être stocké dans le dossier `/srv` sur la machine `web.tp6.linux`
- le script doit commencer par un *shebang* qui indique le chemin du programme qui exécutera le contenu du script
  - ça ressemble à ça si on veut utiliser `/bin/bash` pour exécuter le contenu de notre script :

```
#!/bin/bash
```

- pour apprendre quels dossiers il faut sauvegarder dans tout le bordel de NextCloud, [il existe une page de la doc officielle qui vous informera](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/backup.html)
- vous devez compresser les dossiers importants
  - au format `.zip` ou `.tar.gz`
  - le fichier produit sera stocké dans le dossier `/srv/backup/`
  - il doit comporter la date, l'heure la minute et la seconde où a été effectué la sauvegarde
    - par exemple : `nextcloud_2211162108.tar.gz`

> On utilise la notation américaine de la date `yymmdd` avec l'année puis le mois puis le jour, comme ça, un tri alphabétique des fichiers correspond à un tri dans l'ordre temporel :)

### 2. Clean it

On va rendre le script un peu plus propre vous voulez bien ?

➜ **Utiliser des variables** déclarées en début de script pour stocker les valeurs suivantes :

- le nom du fichier `.tar.gz` ou `zip` produit par le script

```bash
# Déclaration d'une variable toto qui contient la string "tata"
toto="tata"

# Appel de la variable toto
# Notez l'utilisation du dollar et des double quotes
echo "$toto"
```

---

➜ **Commentez le script**

- au minimum un en-tête sous le shebang
  - date d'écriture du script
  - nom/pseudo de celui qui l'a écrit
  - un résumé TRES BREF de ce que fait le script

---

➜ **Environnement d'exécution du script**

- créez un utilisateur sur la machine `web.tp6.linux`
  - il s'appellera `backup`
  - son homedir sera `/srv/backup/`
  - son shell sera `/usr/bin/nologin`
- cet utilisateur sera celui qui lancera le script
- le dossier `/srv/backup/` doit appartenir au user `backup`
- pour tester l'exécution du script en tant que l'utilisateur `backup`, utilisez la commande suivante :

```bash
$ sudo -u backup /srv/tp6_backup.sh
```

### 3. Service et timer

🌞 **Créez un *service*** système qui lance le script

- inspirez-vous des *services* qu'on a créés et/ou manipulés jusqu'à maintenant
- la seule différence est que vous devez rajouter `Type=oneshot` dans la section `[Service]` pour indiquer au système que ce service ne tournera pas à l'infini (comme le fait un serveur web par exemple) mais se terminera au bout d'un moment
- vous appelerez le service `backup.service`
- assurez-vous qu'il fonctionne en utilisant des commandes `systemctl`

```bash
$ sudo systemctl status backup
$ sudo systemctl start backup
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

- le fichier doit être créé dans le même dossier
- le fichier doit porter le même nom
- l'extension doit être `.timer` au lieu de `.service`
- ainsi votre fichier s'appellera `backup.timer`
- la syntaxe est la suivante :

```systemd
[Unit]
Description=Run service X

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

> [La doc Arch est cool à ce sujet.](https://wiki.archlinux.org/title/systemd/Timers)

🌞 Activez l'utilisation du *timer*

- vous vous servirez des commandes suivantes :

```bash
# demander au système de lire le contenu des dossiers de config
# il découvrira notre nouveau timer
$ sudo systemctl daemon-reload

# on peut désormais interagir avec le timer
$ sudo systemctl start backup.timer
$ sudo systemctl enable backup.timer
$ sudo systemctl status backup.timer

# il apparaîtra quand on demande au système de lister tous les timers
$ sudo systemctl list-timers
```

## II. NFS

### 1. Serveur NFS

> On a déjà fait ça au TP4 ensemble :)

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`

> Et ouais pour pas que ce soit le bordel, on va appeler le dossier comme la machine qui l'utilisera :)

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`
- créer le fichier `/etc/exports`
  - remplissez avec un contenu adapté
  - j'vous laisse faire les recherches adaptées pour ce faire
- ouvrir les ports firewall nécessaires
- démarrer le service
- je vous laisse check l'internet pour trouver [ce genre de lien](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9) pour + de détails

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

- il devra monter le dossier `/srv/nfs_shares/web.tp6.linux/` qui se trouve sur `storage.tp6.linux`
- le dossier devra être monté sur `/srv/backup/`
- je vous laisse là encore faire vos recherches pour réaliser ça !
- faites en sorte que le dossier soit automatiquement monté quand la machine s'allume

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

# Module 3 : Fail2Ban

Fail2Ban c'est un peu le cas d'école de l'admin Linux, je vous laisse Google pour le mettre en place.

C'est must-have sur n'importe quel serveur à peu de choses près. En plus d'enrayer les attaques par bruteforce, il limite aussi l'imact sur les performances de ces attaques, en bloquant complètement le trafic venant des IP considérées comme malveillantes

🌞 Faites en sorte que :

- si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban
- vérifiez que ça fonctionne en vous faisant ban
- utilisez une commande dédiée pour lister les IPs qui sont actuellement ban
- afficher l'état du firewal, et trouver la ligne qui ban l'IP en question
- lever le ban avec une commande liée à fail2ban

> Vous pouvez vous faire ban en effectuant une connexion SSH depuis `web.tp6.linux` vers `db.tp6.linux` par exemple, comme ça vous gardez intacte la connexion de votre PC vers `db.tp6.linux`, et vous pouvez continuer à bosser en SSH.

# Module 4 : Monitoring

Dans ce sujet on va installer un outil plutôt clé en main pour mettre en place un monitoring simple de nos machines.

L'outil qu'on va utiliser est [Netdata](https://learn.netdata.cloud/docs/agent/packaging/installer/methods/kickstart).

🌞 **Installer Netdata**

- je vous laisse suivre la doc pour le mettre en place [ou ce genre de lien](https://wiki.crowncloud.net/?How_to_Install_Netdata_on_Rocky_Linux_9)
- vous n'avez PAS besoin d'utiliser le "Netdata Cloud" machin truc. Faites simplement une install locale.
- installez-le sur `web.tp6.linux` et `db.tp6.linux`.

➜ **Une fois en place**, Netdata déploie une interface un Web pour avoir moult stats en temps réel, utilisez une commande `ss` pour repérer sur quel port il tourne.

Utilisez votre navigateur pour visiter l'interface web de Netdata `http://<IP_VM>:<PORT_NETDATA>`.

🌞 **Une fois Netdata installé et fonctionnel, déterminer :**

- l'utilisateur sous lequel tourne le(s) processus Netdata
- si Netdata écoute sur des ports
- comment sont consultables les logs de Netdata

➜ **Vous ne devez PAS utiliser le "Cloud Netdata"**

- lorsque vous accéder à l'interface web de Netdata :
  - vous NE DEVEZ PAS être sur une URL `netdata.cloud`
  - vous DEVEZ visiter l'interface en saisissant l'IP de votre serveur
- l'interface Web tourne surle port 19999 par défaut

🌞 **Configurer Netdata pour qu'il vous envoie des alertes** 

- dans [un salon Discord](https://learn.netdata.cloud/docs/agent/health/notifications/discord) dédié en cas de soucis

🌞 **Vérifier que les alertes fonctionnent**

- en surchargeant volontairement la machine 
- par exemple, effectuez des *stress tests* de RAM et CPU, ou remplissez le disque volontairement
- demandez au grand Internet comme on peut "stress" une machine (c'est le terme technique)