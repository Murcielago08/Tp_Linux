# TP2 admins : PHP stack

Une fois que tu sais manipuler Docker en tant qu'admin :

➜ **tu peux facilement tester des services/apps**

- en les lançant dans des conteneurs
- sans te taper une install
- azi je veux juste regarder la webui, nik la doc de 3 pieds de long
- tester des stacks complètes qui nécessitent 3, 4, 5 services, en une commande

➜ **tu peux conteneuriser des apps en prod**

- pour une meilleure sécu éventuellement, si tu respectes les bonnes pratiques
- pour une gestion un peu unifiée de tes services
- si tout est conteneur, c'est unifié !

➜ **tu peux proposer/gérer des services qui utilisent les conteneurs sous le capot**

- je pense à tout ce qui est CI/CD, pipelines, etc
- aussi à copain Kubernetes

➜ **te préparer à use Kubernetes qui est dans ton futur d'admin si tu te tournes vers le système**

- Kube il lance juste des conteneurs pour toi
- donc bien maîtriser la notion de conteneur, ça aide pas mal à capter le délire

## Sommaire

- [TP2 admins : PHP stack](#tp2-admins--php-stack)
  - [Sommaire](#sommaire)
- [I. Good practices](#i-good-practices)
- [II. Reverse proxy buddy](#ii-reverse-proxy-buddy)
  - [A. Simple HTTP setup](#a-simple-http-setup)
  - [B. HTTPS auto-signé](#b-https-auto-signé)
  - [C. HTTPS avec une CA maison](#c-https-avec-une-ca-maison)

# I. Good practices

On peut custom pas mal de trucs au moment du run (`docker run` ou avec `docker compose`).

Donc "just for good measures" comme on dit...

🌞 **Limiter l'accès aux ressources**

- limiter la RAM que peut utiliser chaque conteneur à 1G
- limiter à 1CPU chaque conteneur

```
version: '3'
services:
  service_name:
    image: nom_de_l_image
    deploy:
          resources:
            limits:
              cpus: '1'
              memory: 1g
```

> Ca se fait avec une option sur `docker run` ou son équivalent en syntaxe `docker-compose.yml`.

🌞 **No `root`**

- s'assurer que chaque conteneur n'utilise pas l'utilisateur `root`
- mais bien un utilisateur dédié
- on peut préciser avec une option du `run` sous quelle identité le processus sera lancé

```
version: '3'
services:
  service_name:
    image: nom_de_l_image
    user: "user:group"
```

> Je rappelle qu'un conteneur met en place **un peu** d'isolation, **mais le processus tourne concrètement sur la machine hôte**. Donc il faut bien que, sur la machine hôte, il s'exécute sous l'identité d'un utilisateur, comme n'importe quel autre processus.

# II. Reverse proxy buddy

On continue sur le sujet PHP !

On va ajouter un reverse proxy dans le mix !

## A. Simple HTTP setup

🌞 **Adaptez le `docker-compose.yml`** de [la partie précédente](./php.md)

- il doit inclure un quatrième conteneur : un reverse proxy NGINX
  - image officielle !
  - un volume pour ajouter un fichier de conf
- je vous file une conf minimale juste en dessous
- c'est le seul conteneur exposé (partage de ports)
  - il permet d'accéder soit à PHPMyAdmin
  - soit à votre site
- vous ajouterez au fichier `hosts` de **votre PC** (le client)
  - `www.supersite.com` qui pointe vers l'IP de la machine qui héberge les conteneurs
  - `pma.supersite.com` qui pointe vers la même IP (`pma` pour PHPMyAdmin)
  - en effet, c'est grâce au nom que vous saisissez que NGINX saura vers quel conteneur vous renvoyer !

> *Tu peux choisir un nom de domaine qui te plaît + on s'en fout, mais pense à bien adapter tous mes exemples par la suite si tu en choisis un autre.*

```nginx
server {
    listen       80;
    server_name  www.supersite.com;

    location / {
        proxy_pass   http://nom_du_conteneur_PHP;
    }
}

server {
    listen       80;
    server_name  pma.supersite.com;

    location / {
        proxy_pass   http://nom_du_conteneur_PMA;
    }
}
```

[Docker Compose](./php/docker-compose.yml)
[Conf Nginx](./php/nginx.conf)

## B. HTTPS auto-signé

🌞 **HTTPS** auto-signé

- générez un certificat et une clé auto-signés
- adaptez la conf de NGINX pour tout servir en HTTPS
- la clé et le certificat doivent être montés avec des volumes (`-v`)
- la commande pour générer une clé et un cert auto-signés :

```bash
openssl req -new -newkey rsa:4096 -days 365 -nodes -x509 -keyout www.supersite.com.key -out www.supersite.com.crt
```

> Vous pouvez générer deux certificats (un pour chaque sous-domaine) ou un certificat *wildcard* qui est valide pour `*.supersite.com` (genre tous les sous-domaines de `supersite.com`).

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php> ls


    Répertoire : C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        22/12/2023     12:24                sql
d-----        04/01/2024     17:12                src
-a----        15/01/2024     21:00            829 docker-compose.yml
-a----        15/01/2024     20:58            818 nginx.conf
-a----        15/01/2024     21:03           1970 pma.supersite.com.crt
-a----        15/01/2024     21:03           3324 pma.supersite.com.key
-a----        15/01/2024     21:03           1970 www.supersite.com.crt
-a----        15/01/2024     21:03           3320 www.supersite.com.key


version: "3"

services:
 phpapache:
    image: php:8.0.0-apache
    volumes:
      - "./src/:/var/www/html"

 mysql:
    image: mysql
    restart: always
    environment:
      - MYSQL_DATABASE=mysqldb
      - MYSQL_ROOT_PASSWORD=oui
    volumes:
      - "./sql/:/docker-entrypoint-initdb.d"

 phpmyadmin:
    image: phpmyadmin
    restart: always
    environment:
      - PMA_ARBITRARY=1
      - PMA_HOST=mysql
      - PMA_USER=root
      - PMA_PASSWORD=oui

 nginx:
    image: nginx:stable-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./certs/www.supersite.com.crt:/etc/ssl/certs/www.supersite.com.crt"
      - "./certs/www.supersite.com.key:/etc/ssl/certs/www.supersite.com.key"
      - "./certs/www.supersite.com.crt:/etc/ssl/certs/pma.supersite.com.crt"
      - "./certs/www.supersite.com.key:/etc/ssl/certs/pma.supersite.com.key"
      - "./nginx.conf:/etc/nginx/nginx.conf"


```

## C. HTTPS avec une CA maison

🌞 **Générer une clé et un certificat de CA**

```bash
# mettez des infos dans le prompt, peu importe si c'est fake
# on va vous demander un mot de passe pour chiffrer la clé aussi
$ openssl genrsa -des3 -out CA.key 4096
$ openssl req -x509 -new -nodes -key CA.key -sha256 -days 1024  -out CA.pem
$ ls
# le pem c'est le certificat (clé publique)
# le key c'est la clé privée
```

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php> ls .\ca_maison\


    Répertoire : C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php\ca_maison


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        15/01/2024     21:03           3468 CA.key
-a----        15/01/2024     21:03           1970 CA.pem
```

🌞 **Générer une clé et une demande de signature de certificat pour notre serveur web**

```bash
$ openssl req -new -nodes -out www.supersite.com.csr -newkey rsa:4096 -keyout www.supersite.com.key
$ ls
# www.supersite.com.csr c'est la demande de signature
# www.supersite.com.key c'est la clé qu'utilisera le serveur web
```

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php> ls .\ca_maison\


    Répertoire : C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php\ca_maison


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        15/01/2024     21:03           3468 CA.key
-a----        15/01/2024     21:03           1970 CA.pem
-a----        15/01/2024     21:03           1678 www.supersite.com.csr
-a----        15/01/2024     21:03           3324 www.supersite.com.key
```

🌞 **Faire signer notre certificat par la clé de la CA**

- préparez un fichier `v3.ext` qui contient :

- effectuer la demande de signature pour récup un certificat signé par votre CA :

```bash
$ openssl x509 -req -in www.supersite.com.csr -CA CA.pem -CAkey CA.key -CAcreateserial -out www.supersite.com.crt -days 500 -sha256 -extfile v3.ext
$ ls
# www.supersite.com.crt c'est le certificat qu'utilisera le serveur web
```

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php> ls .\ca_maison\


    Répertoire : C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\Linux_Tp2\php\ca_maison


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        15/01/2024     21:03           3468 CA.key
-a----        15/01/2024     21:03           1970 CA.pem
-a----        15/01/2024     21:03             42 CA.srl
-a----        15/01/2024     21:03            237 v3.ext
-a----        15/01/2024     21:03           2046 www.supersite.com.crt
-a----        15/01/2024     21:03           1678 www.supersite.com.csr
-a----        15/01/2024     21:03           3324 www.supersite.com.key
```

🌞 **Ajustez la configuration NGINX**

```
version: "3"

services:
 phpapache:
    image: php:8.0.0-apache
    volumes:
      - "./src/:/var/www/html"

 mysql:
    image: mysql
    restart: always
    environment:
      - MYSQL_DATABASE=mysqldb
      - MYSQL_ROOT_PASSWORD=oui
    volumes:
      - "./sql/:/docker-entrypoint-initdb.d"

 phpmyadmin:
    image: phpmyadmin
    restart: always
    environment:
      - PMA_ARBITRARY=1
      - PMA_HOST=mysql
      - PMA_USER=root
      - PMA_PASSWORD=oui

 nginx:
    image: nginx:stable-alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "./ca_maison/www.supersite.com.crt:/etc/ssl/certs/www.supersite.com.crt"
      - "./ca_maison/www.supersite.com.key:/etc/ssl/certs/www.supersite.com.key"
      - "./nginx.conf:/etc/nginx/nginx.conf"
      
volumes:
  db_data:

```

```nginx
events {}

http {
    server {

        listen       80;

        server_name www.supersite.com;

        return 301 https://$host$request_uri;

        # location / {
        #     proxy_pass   http://phpapache;
        # }

    }


    server {

        listen       443 ssl;

        server_name www.supersite.com;


        ssl_certificate      /etc/ssl/certs/www.supersite.com.crt;

        ssl_certificate_key /etc/ssl/certs/www.supersite.com.key;


        location / {

            proxy_pass   http://phpapache;

        }

    }

    server {
        listen       80;
        
        server_name  pma.supersite.com;
        
        # return 301 https://$host$request_uri;

        location / {
            proxy_pass   http://phpmyadmin;
        }
    }

}
```

🌞 **Prouvez avec un `curl` que vous accédez au site web**

- depuis votre PC
- avec un `curl -k` car il ne reconnaît pas le certificat là

```

```

🌞 **Ajouter le certificat de la CA dans votre navigateur**

- vous pourrez ensuite visitez `https://web.tp7.b2` sans alerte de sécurité, et avec un cadenas vert
- il est nécessaire de joindre le site avec son nom pour que HTTPS fonctionne (fichier `hosts`)
