# Partie 1 : Mise en place et maîtrise du serveur Web

Dans cette partie on va installer le serveur web, et prendre un peu la maîtrise dessus, en regardant où il stocke sa conf, ses logs, etc. Et en manipulant un peu tout ça bien sûr.

On va installer un serveur Web très très trèèès utilisé autour du monde : le serveur Web Apache.

- [Partie 1 : Mise en place et maîtrise du serveur Web](#partie-1--mise-en-place-et-maîtrise-du-serveur-web)
  - [1. Installation](#1-installation)
  - [2. Avancer vers la maîtrise du service](#2-avancer-vers-la-maîtrise-du-service)

![Tipiii](../pics/linux_is_a_tipi.jpg)

## 1. Installation

🖥️ **VM web.tp5.linux**

🌞 **Installer le serveur Apache**

- paquet `httpd`
- la conf se trouve dans `/etc/httpd/`
  - je vous conseille **vivement** de virer tous les commentaire du fichier, à défaut de les lire, vous y verrez plus clair
    - avec `vim` vous pouvez tout virer avec `:g/^ *#.*/d`

```
[murci@tp5web ~]$ sudo dnf install httpd -y

[murci@tp5web ~]$ sudo vim /etc/httpd/conf/httpd.conf
```

🌞 **Démarrer le service Apache**

- le service s'appelle `httpd` (raccourci pour `httpd.service` en réalité)

```
[murci@tp5web ~]$ sudo systemctl start httpd; sudo systemctl enable httpd

[murci@tp5web ~]$ sudo ss -altnp | grep httpd
LISTEN 0      511                *:80              *:*    users:(("httpd",pid=10760,fd=4),("httpd",pid=10759,fd=4),("httpd",pid=10758,fd=4),("httpd",pid=10755,fd=4))

[murci@tp5web ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp 22/tcp
```

🌞 **TEST**

- vérifier que le service est démarré

```
[murci@tp5web ~]$ sudo systemctl status httpd | grep active
     Active: active (running) since Mon 2022-12-12 16:39:54 CET; 18min ago
```

- vérifier qu'il est configuré pour démarrer automatiquement

```
[murci@tp5web ~]$ sudo systemctl status httpd | grep enable
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; vendor preset: disabled)
```

- vérifier avec une commande `curl localhost` que vous joignez votre serveur web localement

```
[murci@tp5web ~]$ curl localhost
<!doctype html>
<html>
[...]
</html>
```

- vérifier depuis votre PC que vous accéder à la page par défaut

```
PS C:\Users\darkj> curl http://10.105.1.11:80
<!doctype html>
<html>
[...]
</html>
```

## 2. Avancer vers la maîtrise du service

🌞 **Le service Apache...**

- affichez le contenu du fichier `httpd.service` qui contient la définition du service Apache

```
[murci@tp5web ~]$ systemctl cat httpd
# /usr/lib/systemd/system/httpd.service
# See httpd.service(8) for more information on using the httpd service.

# Modifying this file in-place is not recommended, because changes
# will be overwritten during package upgrades.  To customize the
# behaviour, run "systemctl edit httpd" to create an override unit.

# For example, to pass additional options (such as -D definitions) to
# the httpd binary at startup, create an override unit (as is done by
# systemctl edit) and enter the following:

#       [Service]
#       Environment=OPTIONS=-DMY_DEFINE

[Unit]
Description=The Apache HTTP Server
Wants=httpd-init.service
After=network.target remote-fs.target nss-lookup.target httpd-init.service
Documentation=man:httpd.service(8)

[Service]
Type=notify
Environment=LANG=C

ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
# Send SIGWINCH for graceful stop
KillSignal=SIGWINCH
KillMode=mixed
PrivateTmp=true
OOMPolicy=continue

[Install]
WantedBy=multi-user.target
```

🌞 **Déterminer sous quel utilisateur tourne le processus Apache**

- mettez en évidence la ligne dans le fichier de conf principal d'Apache (`httpd.conf`) qui définit quel user est utilisé

```
[murci@tp5web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep 'User '
User apache
```

- utilisez la commande `ps -ef` pour visualiser les processus en cours d'exécution et confirmer que apache tourne bien sous l'utilisateur mentionné dans le fichier de conf

```
[murci@tp5web ~]$ ps -ef | grep apache
apache       709     685  0 17:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       711     685  0 17:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       712     685  0 17:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache       713     685  0 17:13 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
murci       1194    1152  0 17:33 pts/0    00:00:00 grep --color=auto apach
```

- la page d'accueil d'Apache se trouve dans `/usr/share/testpage/`

```
[murci@tp5web ~]$ ls -al /usr/share/testpage/index.html
-rw-r--r--. 1 root root 7620 Jul 27 20:05 /usr/share/testpage/index.html
```

🌞 **Changer l'utilisateur utilisé par Apache**

- créez un nouvel utilisateur

```
[murci@tp5web ~]$ sudo cat /etc/passwd | grep apache
apache:x:48:48:Apache:/usr/share/httpd:/sbin/nologin
apache2:x:1001:1001::/usr/share/httpd:/sbin/nologin
```

- modifiez la configuration d'Apache pour qu'il utilise ce nouvel utilisateur

```
[murci@tp5web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep apache2
User apache2
Group apache2
```

- utilisez une commande `ps` pour vérifier que le changement a pris effet

```
[murci@tp5web ~]$ ps -ef | grep apache2
apache2     1117    1116  0 14:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     1118    1116  0 14:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     1119    1116  0 14:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
apache2     1120    1116  0 14:24 ?        00:00:00 /usr/sbin/httpd -DFOREGROUND
```

🌞 **Faites en sorte que Apache tourne sur un autre port**

- modifiez la configuration d'Apache pour lui demander d'écouter sur un autre port de votre choix

```
[murci@tp5web ~]$ sudo cat /etc/httpd/conf/httpd.conf | grep 2003
Listen 2003
```

- prouvez avec une commande `ss` que Apache tourne bien sur le nouveau port choisi

```
[murci@tp5web ~]$ sudo ss -altnp | grep httpd
LISTEN 0      511                *:2003            *:*    users:(("httpd",pid=1382,fd=4),("httpd",pid=1381,fd=4),("httpd",pid=1380,fd=4),("httpd",pid=1378,fd=4))
```

- vérifiez avec `curl` en local que vous pouvez joindre Apache sur le nouveau port

```
PS C:\Users\darkj> curl http://10.105.1.11:2003
<!doctype html>
<html>
[...]
</html>
```

📁 **Fichier `/etc/httpd/conf/httpd.conf`**

[httpd.conf](httpd.conf)

➜ **Si c'est tout bon vous pouvez passer à [la partie 2.](Rendu_Tp5_part_2.md)**