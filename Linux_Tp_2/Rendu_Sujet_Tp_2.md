# TP2 : Appréhender l'environnement Linux

Dans ce TP, on va aborder plusieurs sujets, dans le but principal de se familiariser un peu plus avec l'environnement GNU/Linux.

> Pour rappel, nous étudions et utilisons GNU/Linux de l'angle de l'administrateur, qui gère des serveurs. Nous n'allons que très peu travailler avec des distributions orientées client. Rocky Linux est parfaitement adapté à cet usage.

Ce que vous faites dans ce TP deviendra peu à peu naturel au fil des cours et de votre utilsation de GNU/Linux.

Comme d'hab rien à savoir par coeur, jouez le jeu, et la plasticité de votre cerveau fera le reste.

Une seule VM Rocky suffit pour ce TP.

# Sommaire

- [TP2 : Appréhender l'environnement Linux](#tp2--appréhender-lenvironnement-linux)
- [Sommaire](#sommaire)
- [I. Service SSH](#i-service-ssh)
  - [1. Analyse du service](#1-analyse-du-service)
  - [2. Modification du service](#2-modification-du-service)
- [II. Service HTTP](#ii-service-http)
  - [1. Mise en place](#1-mise-en-place)
  - [2. Analyser la conf de NGINX](#2-analyser-la-conf-de-nginx)
  - [3. Déployer un nouveau site web](#3-déployer-un-nouveau-site-web)
- [III. Your own services](#iii-your-own-services)
  - [1. Au cas où vous auriez oublié](#1-au-cas-où-vous-auriez-oublié)
  - [2. Analyse des services existants](#2-analyse-des-services-existants)
  - [3. Création de service](#3-création-de-service)


# I. Service SSH

Le service SSH est déjà installé sur la machine, et il est aussi déjà démarré par défaut, c'est Rocky qui fait ça nativement.

## 1. Analyse du service

On va, dans cette première partie, analyser le service SSH qui est en cours d'exécution.

🌞 **S'assurer que le service `sshd` est démarré**
```
[murci@tp2 ~]$ systemctl status sshd | grep active
     Active: active (running) since Tue 2022-11-22 16:53:19 CET; 4min 46s ago
```     

🌞 **Analyser les processus liés au service SSH**


```bash
[murci@tp2 ~]$ ps -ef | grep sshd
root         685       1  0 16:53 ?        00:00:00 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
root         817     685  0 16:53 ?        00:00:00 sshd: murci [priv]
murci        831     817  0 16:53 ?        00:00:00 sshd: murci@pts/0
murci        886     832  0 17:00 pts/0    00:00:00 grep --color=auto sshd
```

🌞 **Déterminer le port sur lequel écoute le service SSH**


```
[murci@tp2 ~]$ ss | grep ssh
tcp   ESTAB  0      52                    192.168.56.2:ssh       192.168.56.1:61702
```

🌞 **Consulter les logs du service SSH**


```
[murci@tp2 ~]$ sudo tail -n10 /var/log/secure
Nov 22 17:16:44 murci sudo[918]: pam_unix(sudo:session): session closed for user root
Nov 22 17:16:48 murci sudo[922]:   murci : TTY=pts/0 ; PWD=/home/murci ; USER=root ; COMMAND=/bin/journalctl -xe -u sshd
Nov 22 17:16:48 murci sudo[922]: pam_unix(sudo:session): session opened for user root(uid=0) by murci(uid=1000)
Nov 22 17:16:48 murci sudo[922]: pam_unix(sudo:session): session closed for user root
Nov 22 17:17:06 murci sudo[928]:   murci : TTY=pts/0 ; PWD=/home/murci ; USER=root ; COMMAND=/bin/cat /var/log/secure
Nov 22 17:17:06 murci sudo[928]: pam_unix(sudo:session): session opened for user root(uid=0) by murci(uid=1000)
Nov 22 17:17:06 murci sudo[928]: pam_unix(sudo:session): session closed for user root
Nov 22 17:17:16 murci sudo[932]:   murci : TTY=pts/0 ; PWD=/home/murci ; USER=root ; COMMAND=/bin/tail -n10 /var/log/secure
Nov 22 17:17:16 murci sudo[932]: pam_unix(sudo:session): session opened for user root(uid=0) by murci(uid=1000)
Nov 22 17:17:16 murci sudo[932]: pam_unix(sudo:session): session closed for user root
```

## 2. Modification du service

🌞 **Identifier le fichier de configuration du serveur SSH**

```
[murci@tp2 ~]$ sudo cat sshd_config | grep Port
#Port 22
#GatewayPorts no
```

🌞 **Modifier le fichier de conf**

```
[murci@tp2 ~]$ echo $RANDOM
16578

[murci@tp2 ~]$ sudo cat /etc/ssh/sshd_config | grep Port
#Port 16578
#GatewayPorts no

[murci@tp2 ~]$ sudo firewall-cmd --remove-port=22/tcp --permanent
success
[murci@tp2 ~]$ sudo firewall-cmd --add-port=16578/tcp --permanent
success
[murci@tp2 ~]$ sudo firewall-cmd --reload
success
[murci@tp2 ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 80/tcp 16578/tcp
  forward-ports:
  source-ports:
```

🌞 **Redémarrer le service**

```
[murci@tp2 ~]$ sudo systemctl restart sshd
```

🌞 **Effectuer une connexion SSH sur le nouveau port**

```
C:\Users\darkj> ssh murci@linuxtp -p 16578
```

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées


# II. Service HTTP

## 1. Mise en place

🌞 **Installer le serveur NGINX**

- je vous laisse faire votre recherche internet
- n'oubliez pas de préciser que c'est pour "Rocky 9"

🌞 **Démarrer le service NGINX**

🌞 **Déterminer sur quel port tourne NGINX**

- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées
- ouvrez le port concerné dans le firewall

🌞 **Déterminer les processus liés à l'exécution de NGINX**

- vous devez filtrer la sortie de la commande utilisée pour n'afficher que les lignes demandées

🌞 **Euh wait**

- y'a un serveur Web qui tourne là ?
- bah... visitez le site web ?
  - ouvrez votre navigateur (sur votre PC) et visitez `http://<IP_VM>:<PORT>`
  - vous pouvez aussi (toujours sur votre PC) utiliser la commande `curl` depuis un terminal pour faire une requête HTTP
- dans le compte-rendu, je veux le `curl` (pas un screen de navigateur)
  - utilisez Git Bash si vous êtes sous Windows (obligatoire)
  - vous utiliserez `| head` après le `curl` pour afficher que certaines des premières lignes
  - vous utiliserez une option à cette commande `head` pour afficher les 7 premières lignes de la sortie du `curl`

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

- faites un `ls -al <PATH_VERS_LE_FICHIER>` pour le compte-rendu

🌞 **Trouver dans le fichier de conf**

- les lignes qui permettent de faire tourner un site web d'accueil (la page moche que vous avez vu avec votre navigateur)
  - ce que vous cherchez, c'est un bloc `server { }` dans le fichier de conf
  - vous ferez un `cat <FICHIER> | grep <TEXTE> -A X` pour me montrer les lignes concernées dans le compte-rendu
    - l'option `-A X` permet d'afficher aussi les `X` lignes après chaque ligne trouvée par `grep`
- tout en bas du fichier, une ligne qui parle d'inclure d'autres fichiers de conf
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - bah ouais, on stocke pas toute la conf dans un seul fichier, sinon ça serait le bordel

## 3. Déployer un nouveau site web

🌞 **Créer un site web**

- bon on est pas en cours de design ici, alors on va faire simplissime
- créer un sous-dossier dans `/var/www/`
  - par convention, on stocke les sites web dans `/var/www/`
  - votre dossier doit porter le nom `tp2_linux`
- dans ce dossier `/var/www/tp2_linux`, créez un fichier `index.html`
  - il doit contenir `<h1>MEOW mon premier serveur web</h1>`

🌞 **Adapter la conf NGINX**

- dans le fichier de conf principal
  - vous supprimerez le bloc `server {}` repéré plus tôt pour que NGINX ne serve plus le site par défaut
  - redémarrez NGINX pour que les changements prennent effet
- créez un nouveau fichier de conf
  - il doit être nommé correctement
  - il doit être placé dans le bon dossier
  - c'est quoi un "nom correct" et "le bon dossier" ?
    - bah vous avez repéré dans la partie d'avant les fichiers qui sont inclus par le fichier de conf principal non ?
    - créez votre fichier en conséquence
  - redémarrez NGINX pour que les changements prennent effet
  - le contenu doit être le suivant :

```nginx
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen <PORT>;

  root /var/www/tp2_linux;
}
```

🌞 **Visitez votre super site web**

- toujours avec une commande `curl` depuis votre PC (ou un navigateur)

# III. Your own services

## 1. Au cas où vous auriez oublié

Au cas où vous auriez oublié, une petite partie qui ne doit pas figurer dans le compte-rendu, pour vous remettre `nc` en main.

> Allez-le télécharger sur votre PC si vous ne l'avez pu. Lien dans Google ou dans le premier TP réseau.

➜ Dans la VM

- `nc -l 8888`
  - lance netcat en mode listen
  - il écoute sur le port 8888
  - sans rien préciser de plus, c'est le port 8888 TCP qui est utilisé

➜ Sur votre PC

- `nc <IP_VM> 8888`
- vérifiez que vous pouvez envoyer des messages dans les deux sens

> Oubliez pas d'ouvrir le port 8888/tcp de la VM bien sûr :)

## 2. Analyse des services existants

🌞 **Afficher le fichier de service SSH**

- vous pouvez obtenir son chemin avec un `systemctl status <SERVICE>`
- mettez en évidence la ligne qui commence par `ExecStart=`
  - encore un `cat <FICHIER> | grep <TEXTE>`
  - c'est la ligne qui définit la commande lancée lorsqu'on "start" le service
    - taper `systemctl start <SERVICE>` ou exécuter cette commande à la main, c'est (presque) pareil

🌞 **Afficher le fichier de service NGINX**

- mettez en évidence la ligne qui commence par `ExecStart=`

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

- son contenu doit être le suivant (nice & easy)

```service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 8888
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

- la commande c'est `sudo systemctl daemon-reload`

🌞 **Démarrer notre service de ouf**

- avec une commande `systemctl start`

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`
- vérifier que `nc` écoute bien derrière un port avec un `ss`
  - vous filtrerez avec un `| grep` la sortie de la commande pour n'afficher que les lignes intéressantes
- vérifer que juste ça marche en vous connectant au service depuis votre PC

➜ Si vous vous connectez avec le client, que vous envoyez éventuellement des messages, et que vous quittez `nc` avec un CTRL+C, alors vous pourrez constater que le service s'est stoppé

- bah oui, c'est le comportement de `nc` ça ! 
- le client se connecte, et quand il se tire, ça ferme `nc` côté serveur aussi
- faut le relancer si vous voulez retester !

🌞 **Les logs de votre service**

- mais euh, ça s'affiche où les messages envoyés par le client ? Dans les logs !
- `sudo journalctl -xe -u tp2_nc` pour visualiser les logs de votre service
- `sudo journalctl -xe -u tp2_nc -f ` pour visualiser **en temps réel** les logs de votre service
  - `-f` comme follow (on "suit" l'arrivée des logs en temps réel)
- dans le compte-rendu je veux
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique le démarrage du service
  - une commande `journalctl` filtrée avec `grep` qui affiche un message reçu qui a été envoyé par le client
  - une commande `journalctl` filtrée avec `grep` qui affiche la ligne qui indique l'arrêt du service

🌞 **Affiner la définition du service**

- faire en sorte que le service redémarre automatiquement s'il se termine
  - comme ça, quand un client se co, puis se tire, le service se relancera tout seul
  - ajoutez `Restart=always` dans la section `[Service]` de votre service
  - n'oubliez pas d'indiquer au système que vous avez modifié les fichiers de service :)