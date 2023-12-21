# Partie 3 : Serveur web

- [Partie 3 : Serveur web](#partie-3--serveur-web)
  - [2. Install](#2-install)
  - [3. Analyse](#3-analyse)
  - [4. Visite du service web](#4-visite-du-service-web)
  - [5. Modif de la conf du serveur web](#5-modif-de-la-conf-du-serveur-web)
  - [6. Deux sites web sur un seul serveur](#6-deux-sites-web-sur-un-seul-serveur)


## 2. Install

🖥️ **VM web.tp4.linux**

🌞 **Installez NGINX**

```
[murci@tp4web ~]$ sudo dnf install nginx
```

## 3. Analyse

🌞 **Analysez le service NGINX**

- avec une commande `ps`, déterminer sous quel utilisateur tourne le processus du service NGINX

```
[murci@tp4web ~]$ ps -ef | grep nginx
root         908       1  0 14:12 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx        909     908  0 14:12 ?        00:00:00 nginx: worker process
murci        917     875  0 14:12 pts/0    00:00:00 grep --color=auto nginx
```

- avec une commande `ss`, déterminer derrière quel port écoute actuellement le serveur web

```
[murci@tp4web ~]$ sudo ss -alnp | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*     users:(("nginx",pid=909,fd=6),("nginx",pid=908,fd=6))

tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=909,fd=7),("nginx",pid=908,fd=7))
```

- en regardant la conf, déterminer dans quel dossier se trouve la racine web

```
[murci@tp4web ~]$ cat /etc/nginx/nginx.conf | grep root
        root         /usr/share/nginx/html;
#        root         /usr/share/nginx/html;
```

- inspectez les fichiers de la racine web, et vérifier qu'ils sont bien accessibles en lecture par l'utilisateur qui lance le processus

```
[murci@tp4web ~]$ ls -al /usr/share/nginx/html/
total 12
drwxr-xr-x. 3 root root  143 Dec  9 15:57 .
drwxr-xr-x. 4 root root   33 Dec  9 15:57 ..
-rw-r--r--. 1 root root 3332 Oct 31 16:35 404.html
-rw-r--r--. 1 root root 3404 Oct 31 16:35 50x.html
drwxr-xr-x. 2 root root   27 Dec  9 15:57 icons
lrwxrwxrwx. 1 root root   25 Oct 31 16:37 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct 31 16:35 nginx-logo.png
lrwxrwxrwx. 1 root root   14 Oct 31 16:37 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 Oct 31 16:37 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png
```

## 4. Visite du service web


🌞 **Configurez le firewall pour autoriser le trafic vers le service NGINX**

```
[murci@tp4web ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp 22/tcp
```

🌞 **Accéder au site web**

- vous pouvez aussi effectuer des requêtes HTTP depuis le terminal, plutôt qu'avec un navigateur (`curl` ^^)
```
PS C:\Users\darkj> curl http://192.168.56.5:80


StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky
                    Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 13:25:59 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">;
                    outerText=; tagName=IMG; alt=[ Powered by Rocky Linux
                    ]; src=icons/poweredby.png}, @{innerHTML=; innerText=;
                    outerHTML=<IMG src="poweredby.png">; outerText=;
                    tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website;
                    tagName=A; href=https://rockylinux.org/},
                    @{innerHTML=Apache Webserver</STRONG>;
                    innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache
                    Webserver</STRONG></A>; outerText=Apache Webserver;
                    tagName=A; href=https://httpd.apache.org/},
                    @{innerHTML=Nginx</STRONG>; innerText=Nginx;
                    outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>;
                    outerText=Nginx; tagName=A; href=https://nginx.org},
                    @{innerHTML=<IMG alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png">; innerText=; outerHTML=<A
                    id=rocky-poweredby href="https://rockylinux.org/"><IMG
                    alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
```

🌞 **Vérifier les logs d'accès**

- trouvez le fichier qui contient les logs d'accès, dans le dossier `/var/log`

```
[murci@tp4web ~]$ sudo cat /var/log/nginx/access.log | tail -n 3
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /icons/poweredby.png HTTP/1.1" 200 15443 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /poweredby.png HTTP/1.1" 200 368 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
192.168.56.1 - - [10/Dec/2022:14:28:24 +0100] "GET /favicon.ico HTTP/1.1" 404 3332 "http://192.168.56.5/" "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/107.0.0.0 Safari/537.36 OPR/93.0.0.0" "-"
```

## 5. Modif de la conf du serveur web

🌞 **Changer le port d'écoute**

- une simple ligne à modifier, vous me la montrerez dans le compte rendu

```
[murci@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep 8080
        listen       8080;
```

- redémarrer le service pour que le changement prenne effet

```
[murci@tp4web ~]$ systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendo>
     Active: active (running) since Sat 2022-12-10 19:27:11 CET; 13s ago
```

- prouvez-moi que le changement a pris effet avec une commande `ss`

```
[murci@tp4web ~]$ sudo ss -alnp | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:8080             0.0.0.0:*     users:(("nginx",pid=914,fd=6),("nginx",pid=913,fd=6))
tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=914,fd=7),("nginx",pid=913,fd=7))
```

- n'oubliez pas de fermer l'ancien port dans le firewall, et d'ouvrir le nouveau

```
[murci@tp4web ~]$ sudo firewall-cmd --list-all | grep 8080
  ports: 22/tcp 8080/tcp
```

- prouvez avec une commande `curl` sur votre machine que vous pouvez désormais visiter le port 8080

```
PS C:\Users\darkj> curl http://192.168.56.5:8080                            

StatusCode        : 200
StatusDescription : OK
Content           : <!doctype html>
                    <html>
                      <head>
                        <meta charset='utf-8'>
                        <meta name='viewport' content='width=device-width,
                    initial-scale=1'>
                        <title>HTTP Server Test Page powered by: Rocky
                    Linux</title>
                       ...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 7620
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 18:32:29 GMT
                    ETag: "62e17e64-1dc4"
                    Last-Modified: Wed, 27 Jul 202...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 7620], [Content-Type, text/html]...}
Images            : {@{innerHTML=; innerText=; outerHTML=<IMG alt="[
                    Powered by Rocky Linux ]" src="icons/poweredby.png">;
                    outerText=; tagName=IMG; alt=[ Powered by Rocky Linux
                    ]; src=icons/poweredby.png}, @{innerHTML=; innerText=;
                    outerHTML=<IMG src="poweredby.png">; outerText=;
                    tagName=IMG; src=poweredby.png}}
InputFields       : {}
Links             : {@{innerHTML=<STRONG>Rocky Linux website</STRONG>;
                    innerText=Rocky Linux website; outerHTML=<A
                    href="https://rockylinux.org/"><STRONG>Rocky Linux
                    website</STRONG></A>; outerText=Rocky Linux website;
                    tagName=A; href=https://rockylinux.org/},
                    @{innerHTML=Apache Webserver</STRONG>;
                    innerText=Apache Webserver; outerHTML=<A
                    href="https://httpd.apache.org/">Apache
                    Webserver</STRONG></A>; outerText=Apache Webserver;
                    tagName=A; href=https://httpd.apache.org/},
                    @{innerHTML=Nginx</STRONG>; innerText=Nginx;
                    outerHTML=<A
                    href="https://nginx.org">Nginx</STRONG></A>;
                    outerText=Nginx; tagName=A; href=https://nginx.org},
                    @{innerHTML=<IMG alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png">; innerText=; outerHTML=<A
                    id=rocky-poweredby href="https://rockylinux.org/"><IMG
                    alt="[ Powered by Rocky Linux ]"
                    src="icons/poweredby.png"></A>; outerText=; tagName=A;
                    id=rocky-poweredby; href=https://rockylinux.org/}...}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 7620
```

---

🌞 **Changer l'utilisateur qui lance le service**

- pour ça, vous créerez vous-même un nouvel utilisateur sur le système : `web`

```
[murci@tp4web ~]$ sudo useradd web -m
[murci@tp4web ~]$ sudo passwd web
Changing password for user web.
New password:
BAD PASSWORD: The password is shorter than 8 characters
Retype new password:
passwd: all authentication tokens updated successfully.
[murci@tp4web ~]$ cat /etc/passwd | grep web
nginx:x:991:991:Nginx web server:/var/lib/nginx:/sbin/nologin
web:x:1001:1001::/home/web:/bin/bash
```

- modifiez la conf de NGINX pour qu'il soit lancé avec votre nouvel utilisateur
  
```
[murci@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep web
user web;
```

- n'oubliez pas de redémarrer le service pour que le changement prenne effet

```
[murci@tp4web ~]$ sudo systemctl restart nginx
```

- vous prouverez avec une commande `ps` que le service tourne bien sous ce nouveau utilisateur

```
[murci@tp4web ~]$ sudo ps -ef | grep nginx
root        1002       1  0 19:43 ?        00:00:00 nginx: master process /usr/sbin/nginx
web         1003    1002  0 19:43 ?        00:00:00 nginx: worker process
murci       1005     870  0 19:43 pts/0    00:00:00 grep --color=auto nginx
```

---

**Il est temps d'utiliser ce qu'on a fait à la partie 2 !**

🌞 **Changer l'emplacement de la racine Web**

- configurez NGINX pour qu'il utilise une autre racine web que celle par défaut

```
[murci@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep site_web_1
        root         /var/www/site_web_1/;
```

- n'oubliez pas de redémarrer le service pour que le changement prenne effet

```
[murci@tp4web ~]$ sudo systemctl restart nginx
```

- prouvez avec un `curl` depuis votre hôte que vous accédez bien au nouveau site

```
PS C:\Users\darkj> curl http://192.168.56.5:8080                            

StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                    <html>
                            <head>
                                    <title>OE OE ma page</title>
                            </head>
                            <body>
                            <h1>OE OE ma page</h1>
                            <p>Mon site web ^^</p>
                            </body>
                    </html>
                    ...
```

## 6. Deux sites web sur un seul serveur

🌞 **Repérez dans le fichier de conf**

- la ligne qui inclut des fichiers additionels contenus dans un dossier nommé `conf.d`

```
[murci@tp4web ~]$ sudo cat /etc/nginx/nginx.conf | grep conf.d
    # Load modular configuration files from the /etc/nginx/conf.d directory.
    include /etc/nginx/conf.d/*.conf;
```

🌞 **Créez le fichier de configuration pour le premier site**

```
[murci@tp4web ~]$ cat /etc/nginx/conf.d/site_web_1.conf
server {
        listen       8080;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_1/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

🌞 **Créez le fichier de configuration pour le deuxième site**

```
[murci@tp4web ~]$ cat /etc/nginx/conf.d/site_web_2.conf
server {
        listen       8888;
        listen       [::]:80;
        server_name  _;
        root         /var/www/site_web_2/;

        # Load configuration files for the default server block.
        include /etc/nginx/default.d/*.conf;

        error_page 404 /404.html;
        location = /404.html {
        }

        error_page 500 502 503 504 /50x.html;
        location = /50x.html {
        }
    }
```

🌞 **Prouvez que les deux sites sont disponibles**

- depuis votre PC, deux commandes `curl`

```
site web n°1 ^^ :
PS C:\Users\darkj> curl http://192.168.56.5:8080


StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                            <head>
                                    <title>OE OE ma page</title>
                            </head>                                                                     <body>                                                                      <h1>OE OE ma page</h1>                                                      <p>Mon site web ^^</p>                                                      </body>
                    </html>...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 201
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 19:33:34 GMT
                    ETag: "6394dccf-c9"
                    Last-Modified: Sat, 10 Dec 2022 1...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 201], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 201

site web n°2 ^^ :
PS C:\Users\darkj> curl http://192.168.56.5:8888


StatusCode        : 200
StatusDescription : OK
Content           : <! DOCTYPE html>
                    <html>
                            <head>
                                    <title>OE OE ma page<title>
                            </head>
                            <body>
                            <h1>OE OE ma page</h1>
                            <p>Mon site web nÂ°2 ^^</p>
                            </body>
                    </h...
RawContent        : HTTP/1.1 200 OK
                    Connection: keep-alive
                    Accept-Ranges: bytes
                    Content-Length: 205
                    Content-Type: text/html
                    Date: Sat, 10 Dec 2022 19:34:00 GMT
                    ETag: "6394db04-cd"
                    Last-Modified: Sat, 10 Dec 2022 1...
Forms             : {}
Headers           : {[Connection, keep-alive], [Accept-Ranges, bytes],
                    [Content-Length, 205], [Content-Type, text/html]...}
Images            : {}
InputFields       : {}
Links             : {}
ParsedHtml        : mshtml.HTMLDocumentClass
RawContentLength  : 205
```