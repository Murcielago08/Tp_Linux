# Mémo Docker

P'tit mémo pour la ligne de commandes Docker.

- [Mémo Docker](#mémo-docker)
- [1. Commandes usuelles](#1-commandes-usuelles)
- [2. `docker run`](#2-docker-run)
  - [A. Daemon ou interactif](#a-daemon-ou-interactif)
  - [B. Partage de port](#b-partage-de-port)
  - [C. Partage de fichiers](#c-partage-de-fichiers)
- [3. Construire des images](#3-construire-des-images)
  - [A. Le `Dockerfile`](#a-le-dockerfile)
  - [B. `docker build`](#b-docker-build)
  - [C. Cas concret](#c-cas-concret)
- [4. Compose](#4-compose)

# 1. Commandes usuelles

| Commande        | Description                                                    | Exemples courants d'utilisation                                                                                                                                                                                                                                                                                            |
| --------------- | -------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `docker info`   | Affiche des infos sur Docker lui-même (genre sa version)       | x                                                                                                                                                                                                                                                                                                                          |
| `docker ps`     | Affiche la liste des conteneurs actuellement créés             | <ul><li>`docker ps` : liste les conteneurs actifs</li><li>`docker ps -a` : liste aussi les conteneurs inactifs (terminés, éteints, crashed, etc) (`-a` comme `all`)</li><li>`docker ps -aq` : affiche uniquement l'ID des conteneurs (`-q` comme `quiet`)</li><li>`docker container ls` : pareil que `docker ps`</li></ul> |
| `docker images` | Affiche la liste des images actuellement dispos sur la machine | Pareil que `docker image ls`                                                                                                                                                                                                                                                                                               |
| `docker run`    | Permet de lancer un conteneur                                  | Voir section dédiée plus bas                                                                                                                                                                                                                                                                                               |
| `docker rm`     | Permet de supprimer un conteneur                               | `docker rm <NAME_or_ID>` : on peut supprimer un conteneur en indiquant soit son nom, soit son ID                                                                                                                                                                                                                           |
| `docker logs`   | Permet d'obtenir les logs d'un conteneur                       | `docker logs <NAME_or_ID>` : on peut consulter les logs d'un conteneur en indiquant soit son nom, soit son ID                                                                                                                                                                                                              |
| `docker exec`   | Permet d'exécuter une commande dans un conteneur               | <ul><li>`docker exec <NAME_OR_ID> sleep 10` pour exécuter un `sleep 10` dans un conteneur</li><li>pour pop un shell dans un conteneur existant on utilise souvent : `docker exec -it <NAME_or_ID> bash` (on précise bien `-it` pour interactif)</li></ul>                                                                  |
# 2. `docker run`

Bon le `docker run` c'est le coeur du truc, il permet de lancer des conteneurs.

Syntaxe de base :

```bash
# usage
docker run <options> <image>

# exemple simple
docker run debian

# plus avancé
docker run -d -p 8080:80 nginx
```

Voyons donc les options les plus utilisées.

## A. Daemon ou interactif

Quasiment tout le temps, on lance un conteneur avec soit `docker run -d` soit `docker run -it`.

- `docker run -d` permet de lancer le conteneur en tâche de fond
  - on pourra consulter ses logs avec `docker logs` plutôt que de les avoir dans le terminal
  - idéal pour lancer un truc en fond et bosser avec
- `docker run -it` permet de lancer un conteneur en mode "interactif"
  - on pourra alors taper des commandes et avoir leur résultat
  - idéal pour tester un truc one shot

## B. Partage de port

Si le conteneur met à disposition un service réseau, il faudra partager un port pour le rendre accessible.

Concrètement, le conteneur a ses propres intrerfaces réseau, avec ses IPs, alors un programme qui écoute sur un port, il est dispo que si tu connais l'IP du conteneur. Et que si tu peux la ping, c'est à dire que t'es la machine hôte, ou un autre conteneur local.

**Le partage de port permet de rendre le service accessible en contactant un port de la machine qui héberge le conteneur.**

Par exemple : je lance un conteneur Web sur mon PC, et j'aimerai que le serveur Web soit joignable sur l'IP de mon PC (parce que si c'est que le conteneur, personne peut accéder au site web).

Petit exemple de commande :

- je lance un conteneur NGINX qui écoute sur le port 80
- j'aimerai écouter avec mon PC sur le port 9999, et si quelqu'un contacte ce port, je le redirige vers le port 80 du conteneur
- syntaxe :

```bash
docker run -p 9999:80 nginx
```

## C. Partage de fichiers

On peut partager un ou plusieurs fichier/dossiers depuis la machine hôte vers l'intérieur du conteneur.

C'est un partage de fichier, pas une copie, donc c'est genre "physiquement" le même fichier sur l'hôte et dans le conteneur à chaque instant.

On appelle ça un "volume" et ça se fait avec le `-v` du `docker run`.

Par exemple, si on veut partager un fichier `app.py` de l'hôte vers le conteneur :

```bash
# ptite prise d'info pour comprendre l'exemple
$ ls
app.py
$ pwd
/home/it4/test_nul

# on lance un conteneur
$ docker run -v /home/it4/test_nul/app.py:/opt/app.py -it python bash

# à partir de là, ce qui suit c'est dans le conteneur
$ cd opt
$ ls
app.py
$ python app.py
```

> Si le fichier `app.py` est modifié sur l'hôte ou dans le conteneur, il est modifié des deux côtés. 'fin j'l'ai déjà dit t'façon : **c'est le même fichier**, pas une copie.

# 3. Construire des images

Pour constuire une image il faut :

- écrire un fichier `Dockerfile`
- exécuter la commande `docker build`

## A. Le `Dockerfile`

Un fichier `Dockerfile` est un simple fichier texte.

Il doit être écrit dans une syntaxe standard qui indique comment construire l'image qu'on souhaite.

Le contenu d'un `Dockerfile` suit la logique suivante :

- on part d'une image existante comme "base"
  - avec l'instruction `FROM`
- on ajoute des choses dans cette image
  - avec des instructions comme `RUN` ou `COPY` (ou d'autres)
- on peut configurer l'environnement
  - définir des variables d'environnement avec `ENV`
  - définir sous quel user les commandes doivent s'exécuter avec `USER`
  - etc.
- on définit quelle commande doit être lancée quand un conteneur sera lancé à partir de cette image
  - par exemple, si on lance un conteneur à partir de l'image `nginx`, on s'attend à ce qu'un serveur NGINX soit lancé automatiquement dans le conteneur quand il démarre
  - avec une instruction `ENTRYPOINT` ou `CMD`

> [Voir la page de la doc officielle dédiée](https://docs.docker.com/engine/reference/builder/) pour savoir les instructions dispos dans le `Dockerfile`.

Trêve de blabla, un exemple !

- on crée un répertoire de build

```bash
mkdir build_nul
cd build_nul
```

- et on y crée un fichier `Dockerfile` avec le contenu suivant

```Dockerfile
FROM debian

RUN apt update -y && apt install -y vim

ENTRYPOINT ["sleep", "9999"]
```

Reste plus qu'à construire notre image avec `docker build`, go section suivante.

## B. `docker build`

La commande `docker build` permet de construire une image à partir d'un Dockerfile.

On doit lui préciser :

- un répertoire de build
  - c'est là où y'a le fichier `Dockerfile`
  - éventuellement d'autres fichiers nécessaires au build
- le nom de l'image qu'on veut créer

Syntaxe :

```bash
$ docker build <BUILD_DIR> -t <IMAGE_NAME>
```

Genre :

```
$ cd build_nul
$ docker build . -t app_nul_qui_sleep
```

Une fois que l'image est build, on peut :

```bash
# voir l'image
$ docker images
# lancer un conteneur à partir de l'image
$ docker run app_nul_qui_sleep
```

## C. Cas concret

Supposons qu'on vous livre une application Python `calc.py` qui est une calculatrice réseau. Exemple complètement fictif hein.

Vu que c'est fictif, complètement fictif, je vous décrit l'app :

- un serveur qui écoute sur un port TCP
- on peut lui envoyer des opérations arithmétiques
- il les résout et renvoie le résultat

Vous êtes chargés de la packager dans un conteneur pour le lancer en production au sein du réseau de votre école. Désolé, l'exemple est nul je sais, c'est complètement fictif.

Ce qu'on doit faire c'est donc :

- écrire un Dockerfile
  - il décrit une image qui contient Python installé
  - aussi les dépendances de l'application si elle en a
  - quand on lance le conteneur, il faut lancer l'application `calc.py`
- build l'image
  - avec un `docker build`
- lancer un conteneur à partir de l'image
  - avec un `docker run`

Il existe évidemment des millions de choix possibles, mais un exemple fonctionnel peut ressembler à ça :

- création d'un répertoire de build
  
```bash
# cd sans argument ça ramène dans votre homedir ;)
$ cd
$ mkdir calc_build
$ cd calc_build
```

- on récupère le code `calc.py` dans le dossier de build

```bash
$ cd
$ cd calc_build
$ mv /la/où/est/le/code/calc.py .
```

- création d'un `Dockerfile`

```bash
$ vim Dockerfile
```

- avec le contenu suivant :
  - j'ai surcommenté le truc pour tout expliquer
  - hésitez pas à copier/coller le truc dans votre IDE et épurer les commentaires pour voir clair
  - après les avoir lus n_n

```Dockerfile
# on part de l'image debian, elle est réputée légère et clean
FROM debian

# on met à jour et on installe python
RUN apt update -y && apt install -y python

# on installe une lib python, c'est une dépendance de l'app calc.py
RUN python -m pip install aiohttp

# ceci est une pratique souvent détestée car détestable, mais pour l'exemple, allons
# on crée un répertoire à la racine du conteneur pour stocker notre app
RUN mkdir /app

# ça, ça indique que toutes les commandes suivantes seront lancées depuis ce dossier
# genre comme si on avait cd dans ce dossier à partir de cette ligne du Dockerfile
WORKDIR /app

# l'instruction suivante fonctionne si calc.py existe dans le même dossier que ce Dockerfile
COPY calc.py /app/calc.py

# on suppose pour cet exemple que l'app calc.py écoute sur le port 13337/tcp
# l'instruction suivante NE FAIT RIEN à part poser une métadonnée sur l'image
# genre ça indique aux utilisateurs de l'image que le conteneur lancera un service sur ce port
# mais CA FAIT RIEN (juste une métadonnée)
EXPOSE 13337/tcp

# l'instruction suivante fonctionne car on a WORKDIR /app
# donc calc.py est dans le dossier actuel, pas besoin de préciser le chemin entier
ENTRYPOINT ["python", "calc.py"]
```

- on a donc à ce stade :

```bash
$ cd
$ cd calc_build
$ ls
calc.py  Dockerfile
```

- on build :

```bash
# je sais que je répète les cd mais au moins le message passe non ?
# tout doit être daite depuis le répertoire de build
$ cd
$ cd calc_build
$ docker build . -t calc
```

- on peut ensuite par exemple lancer l'app pour l'héberger avec :

```bash
# on met un -d pour que le conteneur run en fond
# et un -p pour partager un port
# juste pour flex, on partage le port 5000 de l'hôte
$ docker run -d -p 5000:13337 calc

# on peut ensuite visiter l'app
$ nc localhost:5000
3+3
6

# incroyable cette app complètement fictive quand même
```

- si je suis le développeur de l'app, et que j'utilise le conteneur pour juste avoir Python et ses libs pour exécuter mon app, je vais plutôt utiliser ce `docker run` :
  - ainsi, on crée un montage du fichier `calc.py` de l'hôte vers le conteneur qui run
  - si je modifie le `calc.py` de mon PC, ça le modifie aussi dans le `calc.py`
  - `-v` c'est pas une copie : c'est vraiment le même fichier dans le conteneur et sur votre PC

```bash
$ docker run -d -p 5000:13337 -v /home/user/calc_build/calc.py:/app/calc.py calc
```

# 4. Compose

`docker compose` est un outil qui permet de :

- lancer N conteneurs en même temps
- ne plus utiliser `docker run` et écrire des commandes à rallonge

Il repose sur l'utilisation de fichiers `docker-compose.yml`.

> [Voir la page de la doc officielle dédiée](https://docs.docker.com/compose/compose-file/compose-file-v3/) pour savoir les instructions dispos dans le `docker-compose.yml`.

Pour aller droit au but, on va se contenter d'un exemple avancé.

On passe de l'enchaînement de commandes suivantes, sans compose :

> Exemple fictif, mais très proche de la réalité.

```bash
# on crée un réseau pour que deux conteneurs puissent avoir des IPs dedans et se joindre
$ docker network create super_wordpress

# on lance une base de données
$ docker run --network super_wordpress --name db -e DB_NAME=wordpress -e DB_USER=wordpress -e DB_PASSWORD=wp_is_secure -d mysql

# on lance un wordpress qui utilise la base de données
$ docker run --network super_wordpress --name wordpress -v /home/user/whatever/:/var/www/html -p 443:443 -p 80:80 -e WORDPRESS_DB=wordpress -e WORDPRESS_USER=wordpress -e WORDPRESS_PASSWORD=wp_is_secure -d wordpress
```

A quelque chose comme ça avec compose :

```bash
# propre, on crée un ptit répertoire dédié
$ mkdir super_wordpress
$ cd super_wordpress

# on crée notre docker-compose.yml
$ vim docker-compose.yml
$ cat docker-compose.yml
version: "3"

services:
  wordpress:
    image: wordpress
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/home/user/whatever/:/var/www/html"
    environment:
      - WORDPRESS_DB=wordpress
      - WORDPRESS_USER=wordpress
      - WORDPRESS_PASSWORD=wp_is_secure
  db:
    image: mysql
    environment:
      - DB_NAME=wordpress
      - DB_USER=wordpress
      - DB_PASSWORD=wp_is_secure

# on peut run la stack ("stack" ici = nom vulgaire de tech pour désigner plusieurs apps)
$ docker compose up -d
```

C'est tout pour compose, mais c'est déjà beaucoup :

- les commandes `docker run` étaient interminables
- reloues à modifier, et à maintenir dans le temps
- là c'était deux conteneurs
  - mais y'a des stacks avec 3, 4, 10, 15 conteneurs
  - woah le bordel avec des `docker run`
- c'est un fichier texte plutôt qu'une commande
  - ouais ok on peut écrire la commande dans un fichier, merci
  - mais là c'est pas un fichier qui contient une commande, le fichier en lui-même est utile
  - alors on peut le mettre dans git et le versionner :D et ouais John.
