
- [Partie 1 : Partitionnement du serveur de stockage](#partie-1--partitionnement-du-serveur-de-stockage)
- [Partie 2 : Serveur de partage de fichiers](#partie-2--serveur-de-partage-de-fichiers)
- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [1. Intro NGINX](#1-intro-nginx)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)

# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.

➜ **Ajouter un disque dur de 2G à la VM**

- cela se fait via l'interface graphique de virtualbox
- il faut éteindre la VM pour ce faire

> [**Référez-vous au mémo LVM pour réaliser le reste de cette partie.**](../../../cours/memos/lvm.md)

**Le partitionnement est obligatoire pour que le disque soit utilisable.** Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.

Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de *LVM*.

**Allons !**

![Part please](../pics/part_please.jpg)

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM
- créer un nouveau *volume group (VG)*
  - il devra s'appeler `storage`
  - il doit contenir le PV créé à l'étape précédente
- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable
  - elle doit être dans le VG `storage`
  - elle doit occuper tout l'espace libre

🌞 **Formater la partition**

- vous formaterez la partition en ext4 (avec une commande `mkfs`)
  - le chemin de la partition, vous pouvez le visualiser avec la commande `lvdisplay`
  - pour rappel un *Logical Volume (LVM)* **C'EST** une partition

🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/storage`
  - preuve avec une commande `df -h` que la partition est bien montée
    - utilisez un `| grep` pour isoler les lignes intéressantes
  - prouvez que vous pouvez lire et écrire des données sur cette partition
- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement

Ok ! Za, z'est fait. On a un espace de stockage dédié pour stocker nos sites web.

**Passons à [la partie 2 : installation du serveur de partage de fichiers](./../part2/README.md).**

# Partie 2 : Serveur de partage de fichiers

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/site_web_1/`
  - `/storage/site_web_2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/site_web_1/` est monté dans `/var/www/site_web_1/`
  - le dossier `/storage/site_web_2/` est monté dans `/var/www/site_web_2/`

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

- contenu du fichier `/etc/exports` dans le compte-rendu notamment

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

> Je vous laisse vous inspirer de docs sur internet **[comme celle-ci](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9)** pour mettre en place un serveur NFS.

**Ok, on a fini avec la partie 2, let's head to [the part 3](./../part3/README.md).**

# Partie 3 : Serveur web

## 1. Intro NGINX

![gnignigggnnninx ?](../pics/ngnggngngggninx.jpg)

**NGINX (prononcé "engine-X") est un serveur web.** C'est un outil de référence aujourd'hui, il est réputé pour ses performances et sa robustesse.

Un serveur web, c'est un programme qui écoute sur un port et qui attend des requêtes HTTP. Quand il reçoit une requête de la part d'un client, il renvoie une réponse HTTP qui contient le plus souvent de l'HTML, du CSS et du JS.

> Une requête HTTP c'est par exemple `GET /index.html` qui veut dire "donne moi le fichier `index.html` qui est stocké sur le serveur". Le serveur renverra alors le contenu de ce fichier `index.html`.

Ici on va pas DU TOUT s'attarder sur la partie dév web étou, une simple page HTML fera l'affaire.

Une fois le serveur web NGINX installé (grâce à un paquet), sont créés sur la machine :

- **un service** (un fichier `.service`)
  - on pourra interagir avec le service à l'aide de `systemctl`
- **des fichiers de conf**
  - comme d'hab c'est dans `/etc/` la conf
  - comme d'hab c'est bien rangé, donc la conf de NGINX c'est dans `/etc/nginx/`
  - question de simplicité en terme de nommage, le fichier de conf principal c'est `/etc/nginx/nginx.conf`
- **une racine web**
  - c'est un dossier dans lequel un site est stocké
  - c'est à dire là où se trouvent tous les fichiers PHP, HTML, CSS, JS, etc du site
  - ce dossier et tout son contenu doivent appartenir à l'utilisateur qui lance le service
- **des logs**
  - tant que le service a pas trop tourné c'est empty
  - les fichiers de logs sont dans `/var/log/`
  - comme d'hab c'est bien rangé donc c'est dans `/var/log/nginx/`
  - on peut aussi consulter certains logs avec `sudo journalctl -xe -u nginx`

> Chaque log est à sa place, on ne trouve pas la même chose dans chaque fichier ou la commande `journalctl`. La commande `journalctl` vous permettra de repérer les erreurs que vous glisser dans les fichiers de conf et qui empêche le démarrage correct de NGINX.

## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**

- installez juste NGINX (avec un `dnf install`) et passez à la suite
- référez-vous à des docs en ligne si besoin

## 3. Analyse

Avant de config des truks 2 ouf étou, on va lancer à l'aveugle et inspecter ce qu'il se passe, inspecter avec les outils qu'on connaît ce que fait NGINX à notre OS.

Commencez donc par démarrer le service NGINX :

```bash
$ sudo systemctl start nginx
$ sudo systemctl status nginx
```

🌞 **Analysez le service NGINX**

- avec une commande `ps`, déterminer sous quel utilisateur tourne le processus du service NGINX
  - utilisez un `| grep` pour isoler les lignes intéressantes
- avec une commande `ss`, déterminer derrière quel port écoute actuellement le serveur web
  - utilisez un `| grep` pour isoler les lignes intéressantes
- en regardant la conf, déterminer dans quel dossier se trouve la racine web
  - utilisez un `| grep` pour isoler les lignes intéressantes
- inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus
  - ça va se faire avec un `ls` et les options appropriées

## 4. Visite du service web

**Et ça serait bien d'accéder au service non ?** Genre c'est un serveur web. On veut voir un site web !

🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

- vous avez reperé avec `ss` dans la partie d'avant le port à ouvrir

🌞 **Accéder au site web**

- avec votre navigateur sur VOTRE PC
  - ouvrez le navigateur vers l'URL : `http://<IP_VM>:<PORT>`
- vous pouvez aussi effectuer des requêtes HTTP depuis le terminal, plutôt qu'avec un navigateur
  - ça se fait avec la commande `curl`
  - et c'est ça que je veux dans le compte-rendu, pas de screen du navigateur :)

> Si le port c'est 80, alors c'est la convention pour HTTP. Ainsi, il est inutile de le préciser dans l'URL, le navigateur le fait de lui-même. On peut juste saisir `http://<IP_VM>`.

🌞 **Vérifier les logs d'accès**

- trouvez le fichier qui contient les logs d'accès, dans le dossier `/var/log`
- les logs d'accès, c'est votre serveur web qui enregistre chaque requête qu'il a reçu
- c'est juste un fichier texte
- affichez les 3 dernières lignes des logs d'accès dans le contenu rendu, avec une commande `tail`

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

- une simple ligne à modifier, vous me la montrerez dans le compte rendu
  - faites écouter NGINX sur le port 8080
- redémarrer le service pour que le changement prenne effet
  - `sudo systemctl restart nginx`
  - vérifiez qu'il tourne toujours avec un ptit `systemctl status nginx`
- prouvez-moi que le changement a pris effet avec une commande `ss`
  - utilisez un `| grep` pour isoler les lignes intéressantes
- n'oubliez pas de fermer l'ancien port dans le firewall, et d'ouvrir le nouveau
- prouvez avec une commande `curl` sur votre machine que vous pouvez désormais visiter le port 8080

> Là c'est pas le port par convention, alors obligé de préciser le port quand on fait la requête avec le navigateur ou `curl` : `http://<IP_VM>:8080`.

---

🌞 **Changer l'utilisateur qui lance le service**

- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`
  - référez-vous au [mémo des commandes](../../cours/memos/commandes.md) pour la création d'utilisateur
  - l'utilisateur devra avoir un mot de passe, et un homedir défini explicitement à `/home/web`
- modifiez la conf de NGINX pour qu'il soit lancé avec votre nouvel utilisateur
  - utilisez `grep` pour me montrer dans le fichier de conf la ligne que vous avez modifié
- n'oubliez pas de redémarrer le service pour que le changement prenne effet
- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur
  - utilisez un `| grep` pour isoler les lignes intéressantes

---

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

- configurez NGINX pour qu'il utilise une autre racine web que celle par défaut
  - avec un `nano` ou `vim`, créez un fichiez `/var/www/site_web_1/index.html` avec un contenu texte bidon
  - dans la conf de NGINX, configurez la racine Web sur `/var/www/site_web_1/`
  - vous me montrerez la conf effectuée dans le compte-rendu, avec un `grep`
- n'oubliez pas de redémarrer le service pour que le changement prenne effet
- prouvez avec un `curl` depuis votre hôte que vous accédez bien au nouveau site

> **Normalement le dossier `/var/www/site_web_1/` est un dossier créé à la Partie 2 du TP**, et qui se trouve en réalité sur le serveur `storage.tp4.linux`, notre serveur NFS.

![MAIS](../pics/nop.png)

## 6. Deux sites web sur un seul serveur

Dans la conf NGINX, vous avez du repérer un bloc `server { }` (si c'est pas le cas, allez le repérer, la ligne qui définit la racine web est contenu dans le bloc `server { }`).

Un bloc `server { }` permet d'indiquer à NGINX de servir un site web donné.

Si on veut héberger plusieurs sites web, il faut donc déclarer plusieurs blocs `server { }`.

**Pour éviter que ce soit le GROS BORDEL dans le fichier de conf**, et se retrouver avec un fichier de 150000 lignes, on met chaque bloc `server` dans un fichier de conf dédié.

Et le fichier de conf principal contient une ligne qui inclut tous les fichiers de confs additionnels.

🌞 **Repérez dans le fichier de conf**

- la ligne qui inclut des fichiers additionels contenus dans un dossier nommé `conf.d`
- vous la mettrez en évidence avec un `grep`

> On trouve souvent ce mécanisme dans la conf sous Linux : un dossier qui porte un nom finissant par `.d` qui contient des fichiers de conf additionnels pour pas foutre le bordel dans le fichier de conf principal. On appelle ce dossier un dossier de *drop-in*.

🌞 **Créez le fichier de configuration pour le premier site**

- le bloc `server` du fichier de conf principal, vous le sortez
- et vous le mettez dans un fichier dédié
- ce fichier dédié doit se trouver dans le dossier `conf.d`
- ce fichier dédié doit porter un nom adéquat : `site_web_1.conf`

🌞 **Créez le fichier de configuration pour le deuxième site**

- un nouveau fichier dans le dossier `conf.d`
- il doit porter un nom adéquat : `site_web_2.conf`
- copiez-collez le bloc `server { }` de l'autre fichier de conf
- changez la racine web vers `/var/www/site_web_1/index.html`
- et changez le port d'écoute pour 8888

> N'oubliez pas d'ouvrir le port 8888 dans le firewall. Vous pouvez constater si vous le souhaitez avec un `ss` que NGINX écoute bien sur ce nouveau port.

🌞 **Prouvez que les deux sites sont disponibles**

- depuis votre PC, deux commandes `curl`
- pour choisir quel site visitez, vous choisissez un port spécifique