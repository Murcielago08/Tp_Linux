# TP 3 : We do a little scripting

Aujourd'hui un TP pour appréhender un peu **le scripting**.

➜ **Le scripting dans GNU/Linux**, c'est simplement le fait d'écrire dans un fichier une suite de commande, qui seront exécutées les unes à la suite des autres lorsque l'on exécutera le script.

Plus précisément, on utilisera la syntaxe du shell `bash`. Et on a le droit à l'algo (des variables, des conditions `if`, des boucles `while`, etc).

➜ **Bon par contre, la syntaxe `bash`, elle fait mal aux dents.** Ca va prendre un peu de temps pour s'habituer.

![Bash syntax](./pics/bash_syntax.jpg)

Pour ça, vous prenez connaissance des deux ressources suivantes :

- [le cours sur le shell](../../cours/shell/README.md)
- [le cours sur le scripting](../../cours/scripting/README.md)
- le très bon https://devhints.io/bash pour tout ce qui est relatif à la syntaxe `bash`

➜ **L'emoji 🐚** est une aide qui indique une commande qui est capable de réaliser le point demandé

## Sommaire

- [TP 3 : We do a little scripting](#tp-3--we-do-a-little-scripting)
  - [Sommaire](#sommaire)
- [I. Script carte d'identité](#i-script-carte-didentité)
  - [Rendu](#rendu)
- [II. Script youtube-dl](#ii-script-youtube-dl)
  - [Rendu](#rendu-1)
- [III. MAKE IT A SERVICE](#iii-make-it-a-service)
  - [Rendu](#rendu-2)


# I. Script carte d'identité

## Rendu

📁 **Fichier `/srv/idcard/idcard.sh`**

🌞 **Vous fournirez dans le compte-rendu**, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

[idcard.sh](idcard.sh)

```
[murci@tp3 ~]$ /srv/idcard/idcard.sh
Machine name : tp3
OS Rocky Linux and kernel version is 5.14.0-70.26.1.el9_0.x86_64
IP : 192.168.56.255
RAM : 579Mi memory available on 960Mi total memory
Disque : 5.1G space left
Top 5 processes by RAM usage :
  - /usr/bin/python3 (RAM utilisé : 3.9)
  - /usr/sbin/NetworkManager (RAM utilisé : 1.9)
  - /usr/lib/systemd/systemd (RAM utilisé : 1.7)
  - /usr/lib/systemd/systemd (RAM utilisé : 1.3)
  - sshd: (RAM utilisé : 1.2)
Listening ports :
  - 323 udp : chronyd
  - 22 tcp : sshd
Here is your random cat : ./cat.jpeg
```

# II. Script youtube-dl


## Rendu

📁 **Le script `/srv/yt/yt.sh`**

[yt.sh](yt.sh)

📁 **Le fichier de log `/var/log/yt/download.log`**, avec au moins quelques lignes

[download.log](download.log)

🌞 Vous fournirez dans le compte-rendu, en plus du fichier, **un exemple d'exécution avec une sortie**, dans des balises de code.

```
[murci@tp3 yt]$ /srv/yt/yt.sh https://youtu.be/9ZX1k4XhX24
Video https://youtu.be/9ZX1k4XhX24 was downloaded.
File path : /srv/yt/downloads/chat qui miaule/chat qui miaule.mp4

[murci@tp3 ~]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=GBIIQ0kP15E
Video https://www.youtube.com/watch?v=GBIIQ0kP15E was downloaded.
File path : /srv/yt/downloads/Rickroll (Meme Template)/Rickroll (Meme Template).mp4

[murci@tp3 ~]$ /srv/yt/yt.sh https://www.youtube.com/watch?v=7NNJQJXNO5I
Video https://www.youtube.com/watch?v=7NNJQJXNO5I was downloaded.
File path : /srv/yt/downloads/Bleach: Fade to Black - Fade to Black B13a 【Intense Symphonic Metal Cover】/Bleach: Fade to Black - Fade to Black B13a 【Intense Symphonic Metal Cover】.webm
```

# III. MAKE IT A SERVICE


## Rendu

📁 **Le script `/srv/yt/yt-v2.sh`**

[yt-v2.sh](yt-v2.sh)

📁 **Fichier `/etc/systemd/system/yt.service`**

[yt.service](yt.service)

🌞 Vous fournirez dans le compte-rendu, en plus des fichiers :

- un `systemctl status yt` quand le service est en cours de fonctionnement

```
[murci@tp3 ~]$ systemctl status yt
● yt.service - Telechargement de videos YouTube
     Loaded: loaded (/etc/systemd/system/yt.service; disabled; vendor prese>
     Active: active (running) since Mon 2022-12-05 06:29:51 CET; 13min ago
   Main PID: 28792 (yt-v2.sh)
      Tasks: 2 (limit: 5907)
     Memory: 580.0K
        CPU: 160ms
     CGroup: /system.slice/yt.service
             ├─28792 /bin/bash /srv/yt/yt-v2.sh
             └─28969 sleep 5

Dec 05 06:29:51 tp3 systemd[1]: Started Telechargement de videos YouTube.
```

- un extrait de `journalctl -xe -u yt`

```
Dec 05 06:29:51 tp3 systemd[1]: Started Telechargement de videos YouTube.
░░ Subject: A start job for unit yt.service has finished successfully
░░ Defined-By: systemd
░░ Support: https://access.redhat.com/support
░░
░░ A start job for unit yt.service has finished successfully.
░░
░░ The job identifier is 3826.
Dec 05 06:52:40 tp3 yt-v2.sh[28792]: Video https://www.youtube.com/watch?v=P3RNPoQIX0M was downloaded.
Dec 05 06:52:40 tp3 yt-v2.sh[28792]: File path : /srv/yt/downloads/Zaraki Kenpachi Appears - Bleach: TYBW Episode 5 [On the Precipice of Defeat ] (HQ Cover)/Zaraki Kenpachi Appears - Bleach: TYBW Episode 5 [On the Precipice of Defeat ] (HQ Cover).mp4
```
