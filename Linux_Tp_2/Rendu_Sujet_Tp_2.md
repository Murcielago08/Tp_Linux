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
[murci@tp2 ~]$ sudo tail -n10 /var/log/secure | grep sshd
Nov 28 10:48:11 tp2 sshd[688]: Server listening on 0.0.0.0 port 22.
Nov 28 10:48:11 tp2 sshd[688]: Server listening on :: port 22.
Nov 28 10:49:03 tp2 sshd[826]: Accepted password for murci from 192.168.56.1 port 52030 ssh2
Nov 28 10:49:04 tp2 sshd[826]: pam_unix(sshd:session): session opened for user murci(uid=1000) by (uid=0)
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
PS C:\Users\darkj> ssh -p 16578 murci@linuxtp
murci@linuxtp's password:
Last login: Tue Nov 22 18:49:04 2022 from 192.168.56.1
[murci@tp2 ~]$
```

✨ **Bonus : affiner la conf du serveur SSH**

- faites vos plus belles recherches internet pour améliorer la conf de SSH
- par "améliorer" on entend essentiellement ici : augmenter son niveau de sécurité
- le but c'est pas de me rendre 10000 lignes de conf que vous pompez sur internet pour le bonus, mais de vous éveiller à divers aspects de SSH, la sécu ou d'autres choses liées


# II. Service HTTP

## 1. Mise en place

🌞 **Installer le serveur NGINX**

```
[murci@tp2 ~]$ sudo dnf install nginx
```

🌞 **Démarrer le service NGINX**

```
[murci@tp2 ~]$ sudo systemctl enable nginx
tl start nginxCreated symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /usr/lib/systemd/system/nginx.service.
[murci@tp2 ~]$ sudo systemctl start nginx
[murci@tp2 ~]$ sudo systemctl status nginx | grep active
     Active: active (running) since Mon 2022-11-28 8:48:13 CET; 12min ago
```

🌞 **Déterminer sur quel port tourne NGINX**

```
[murci@tp2 ~]$ sudo cat /etc/nginx/nginx.conf | grep listen
        listen       80;
        listen       [::]:80;
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
```

🌞 **Déterminer les processus liés à l'exécution de NGINX**

```
[murci@tp2 ~]$ ps -ef | grep nginx
root         812       1  0 10:48 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        814     812  0 10:48 ?        00:00:00 nginx: worker process
murci        946     891  0 11:03 pts/0    00:00:00 grep --color=auto nginx
```

🌞 **Euh wait**

```
http://192.168.56.2
[murci@tp2 ~]$ curl http://192.168.56.2 | head -n 7
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  7620  100  7620    0     0   676k      0 --:--:-- --:--:-- --:--:--  676k
<!doctype html>
<html>
  <head>
    <meta charset='utf-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>
    <title>HTTP Server Test Page powered by: Rocky Linux</title>
    <style type="text/css">
```

## 2. Analyser la conf de NGINX

🌞 **Déterminer le path du fichier de configuration de NGINX**

```
[murci@tp2 ~]$ ls -al /etc/nginx/nginx.conf
-rw-r--r--. 1 root root 2334 May 16  2022 /etc/nginx/nginx.conf
```

🌞 **Trouver dans le fichier de conf**

```
[murci@tp2 ~]$ cat /etc/nginx/nginx.conf | grep "server {" -A 16
    server {
        listen       80;
        listen       [::]:80;
        server_name  _;
        root         /usr/share/nginx/html;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
--
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
#
#        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;

[murci@tp2 ~]$ cat /etc/nginx/nginx.conf | grep "conf.d"
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

## 3. Déployer un nouveau site web

🌞 **Créer un site web**
```
[murci@tp2 ~]$ sudo mkdir -p /var/www/tp2_linux
[murci@tp2 ~]$ sudo touch /var/www/tp2_linux/index.html
[murci@tp2 ~]$ sudo cat /var/www/tp2_linux/index.html
<h1>MEOW mon premier serveur web</h1>
```

🌞 **Adapter la conf NGINX**

```
[murci@tp2 ~]$ cat /etc/nginx/nginx.conf | grep "server {" -A 16
#    server {
#        listen       443 ssl http2;
#        listen       [::]:443 ssl http2;
#        server_name  _;
#        root         /usr/share/nginx/html;
##        ssl_certificate "/etc/pki/nginx/server.crt";
#        ssl_certificate_key "/etc/pki/nginx/private/server.key";
#        ssl_session_cache shared:SSL:1m;
#        ssl_session_timeout  10m;
#        ssl_ciphers PROFILE=SYSTEM;
#        ssl_prefer_server_ciphers on;
#
#        # Load configuration files for the default server block.
#        include /etc/nginx/default.d/*.conf;
#
#        error_page 404 /404.html;
#            location = /40x.html {

[murci@tp2 ~]$ sudo systemctl restart nginx


[murci@tp2 ~]$ echo $RANDOM
20484
[murci@tp2 ~]$ sudo cat /etc/nginx/conf.d/monsite.conf
server {
  # le port choisi devra être obtenu avec un 'echo $RANDOM' là encore
  listen 20484;

  root /var/www/tp2_linux;
}
[murci@tp2 ~]$ sudo firewall-cmd --add-port=20484/tcp --permanent
success
[murci@tp2 ~]$ sudo firewall-cmd --reload
success
[murci@tp2 ~]$ sudo firewall-cmd --list-all | grep ports
  ports: 80/tcp 16578/tcp 20484/tcp
  forward-ports:
  source-ports:
[murci@tp2 ~]$ sudo systemctl restart nginx
```


🌞 **Visitez votre super site web**

```
[murci@tp2 ~]$ curl http://192.168.56.2:20484
<h1>MEOW mon premier serveur web</h1>
```

# III. Your own services

## 1. Au cas où vous auriez oublié

good ^^

## 2. Analyse des services existants

🌞 **Afficher le fichier de service SSH**

```
[murci@tp2 ~]$ cat /usr/lib/systemd/system/sshd.service | grep ExecStart=
ExecStart=/usr/sbin/sshd -D $OPTIONS
```

🌞 **Afficher le fichier de service NGINX**

```
[murci@tp2 ~]$ cat /usr/lib/systemd/system/nginx.service | grep ExecStart=
ExecStart=/usr/sbin/nginx
```

## 3. Création de service

🌞 **Créez le fichier `/etc/systemd/system/tp2_nc.service`**

```
[murci@tp2 ~]$ sudo touch /etc/systemd/system/tp2_nc.service
[murci@tp2 ~]$ sudo cat /etc/systemd/system/tp2_nc.service
[Unit]
Description=Super netcat tout fou

[Service]
ExecStart=/usr/bin/nc -l 8888
```

🌞 **Indiquer au système qu'on a modifié les fichiers de service**

```
[murci@tp2 ~]$ sudo systemctl daemon-reload
```

🌞 **Démarrer notre service de ouf**

```
[murci@tp2 ~]$ sudo systemctl start tp2_nc.service
```

🌞 **Vérifier que ça fonctionne**

- vérifier que le service tourne avec un `systemctl status <SERVICE>`

```
[murci@tp2 ~]$ sudo systemctl status tp2_nc
[sudo] password for murci:
● tp2_nc.service - Super netcat tout fou
     Loaded: loaded (/etc/systemd/system/tp2_nc.service; static)
     Active: active (running) since Wed 2022-12-28 22:04:10 CET; 7min ago
   Main PID: 914 (nc)
      Tasks: 1 (limit: 5907)
     Memory: 1.1M
        CPU: 3ms
     CGroup: /system.slice/tp2_nc.service
             └─914 /usr/bin/nc -l 8888

Dec 28 22:04:10 tp2 systemd[1]: Started Super netcat tout fou.
```

- vérifier que `nc` écoute bien derrière un port avec un `ss`

```
[murci@tp2 ~]$ sudo ss -el | grep tp2_nc
tcp   LISTEN 0      10                                        0.0.0.0:ddi-tcp-1               0.0.0.0:*     ino:20121 sk:3 cgroup:/system.slice/tp2_nc.service <->
tcp   LISTEN 0      10                                           [::]:ddi-tcp-1                  [::]:*     ino:20120 sk:5 cgroup:/system.slice/tp2_nc.service v6only:1 <->
```

- vérifer que juste ça marche en vous connectant au service depuis votre PC

```

```

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