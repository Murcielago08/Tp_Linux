# TP1 : Premiers pas Docker

Dans ce TP on va appréhender les bases de Docker.

Etant fondamentalement une techno Linux, **vous réaliserez le TP sur une VM Linux** (ou sur votre poste si vous êtes sur Linux).

> *Oui oui les dévs, on utilisera Docker avec vos Windows/MacOS plus tard. Là on va se concentrer sur l'essence du truc.*

![Meo](./img/container.jpg)

## Sommaire

- [TP1 : Premiers pas Docker](#tp1--premiers-pas-docker)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
- [I. Init](#i-init)
  - [1. Installation de Docker](#1-installation-de-docker)
  - [2. Vérifier que Docker est bien là](#2-vérifier-que-docker-est-bien-là)
  - [3. sudo c pa bo](#3-sudo-c-pa-bo)
  - [4. Un premier conteneur en vif](#4-un-premier-conteneur-en-vif)
  - [5. Un deuxième conteneur en vif](#5-un-deuxième-conteneur-en-vif)
- [II. Images](#ii-images)
  - [1. Images publiques](#1-images-publiques)
  - [2. Construire une image](#2-construire-une-image)
- [III. Docker compose](#iii-docker-compose)

# 0. Setup

➜ **Munissez-vous du [mémo Docker](../../cours/memo/docker.md)**

➜ **Une VM Rocky Linux sitoplé, une seul suffit**

- met lui une carte host-only pour pouvoir SSH dessus
- et une carte NAT pour un accès internet

➜ **Checklist habituelle :**

- [x] IP locale, statique ou dynamique
- [x] hostname défini
- [x] SSH fonctionnel
- [x] accès Internet
- [x] résolution de nom
- [x] SELinux en mode *"permissive"* vérifiez avec `sestatus`, voir [mémo install VM tout en bas](../../cours/memo/install_vm.md)

# I. Init

## 1. Installation de Docker

Pour installer Docker, il faut **toujours** (comme d'hab en fait) se référer à la doc officielle.

**Je vous laisse donc suivre les instructions de la doc officielle pour installer Docker dans la VM.**

> ***Il n'y a pas d'instructions spécifiques pour Rocky dans la doc officielle**, mais rocky est très proche de CentOS. Vous pouvez donc suivre les instructions pour CentOS 9.*

## 2. Vérifier que Docker est bien là

```bash
# est-ce que le service Docker existe ?
systemctl status docker

# si oui, on le démarre alors
sudo systemctl start docker

# voyons si on peut taper une commande docker
sudo docker info
sudo docker ps
```

## 3. sudo c pa bo

On va faire en sorte que vous puissiez taper des commandes `docker` sans avoir besoin des droits `root`, et donc de `sudo`.

Pour ça il suffit d'ajouter votre utilisateur au groupe `docker`.

> ***Pour que le changement de groupe prenne effet, il faut vous déconnecter/reconnecter de la session SSH** (pas besoin de reboot la machine, pitié).*

🌞 **Ajouter votre utilisateur au groupe `docker`**

- vérifier que vous pouvez taper des commandes `docker` comme `docker ps` sans avoir besoin des droits `root`

```
[joris@dockertp1linux ~]$ getent group docker
docker:x:991:joris
```

➜ Vous pouvez même faire un `alias` pour `docker`

Genre si tu trouves que taper `docker` c'est long, et tu préférerais taper `dk` tu peux faire : `alias dk='docker'`. Si tu écris cette commande dans ton fichier `~/.bashrc` alors ce sera effectif dans n'importe quel `bash` que tu ouvriras plutar.

## 4. Un premier conteneur en vif

> *Je rappelle qu'un "conteneur" c'est juste un mot fashion pour dire qu'on lance un processus un peu isolé sur la machine.*

Bon trève de blabla, on va lancer un truc qui juste marche.

On va lancer un conteneur NGINX qui juste fonctionne, puis custom un peu sa conf. Ce serait par exemple pour tester une conf NGINX, ou faire tourner un serveur NGINX de production.

> *Hé les dévs, **jouez le jeu bordel**. NGINX c'est pas votre pote OK, mais on s'en fout, c'est une app comme toutes les autres, comme ta chatroom ou ta calculette. Ou Netflix ou LoL ou Spotify ou un malware. NGINX il est réputé et standard, c'est juste un outil d'étude pour nous là. Faut bien que je vous fasse lancer un truc. C'est du HTTP, c'est full standard, vous le connaissez, et c'est facile à tester/consommer : avec un navigateur.*

🌞 **Lancer un conteneur NGINX**

```bash
[joris@dockertp1linux ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
[joris@dockertp1linux ~]$ docker run -d -p 9999:80 nginx
Unable to find image 'nginx:latest' locally
latest: Pulling from library/nginx
af107e978371: Pull complete
336ba1f05c3e: Pull complete
8c37d2ff6efa: Pull complete
51d6357098de: Pull complete
782f1ecce57d: Pull complete
5e99d351b073: Pull complete
7b73345df136: Pull complete
Digest: sha256:bd30b8d47b230de52431cc71c5cce149b8d5d4c87c204902acf2504435d4b4c9
Status: Downloaded newer image for nginx:latest
77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee
```

🌞 **Visitons**

- vérifier que le conteneur est actif avec une commande qui liste les conteneurs en cours de fonctionnement

```bash
[joris@dockertp1linux ~]$ docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                                   NAMES
77e45c95b737   nginx     "/docker-entrypoint.…"   7 seconds ago   Up 7 seconds   0.0.0.0:9999->80/tcp, :::9999->80/tcp   recursing_carson
```

- afficher les logs du conteneur

```bash
[joris@dockertp1linux ~]$ docker logs recursing_carson
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
10-listen-on-ipv6-by-default.sh: info: Enabled listen on IPv6 in /etc/nginx/conf.d/default.conf
/docker-entrypoint.sh: Sourcing /docker-entrypoint.d/15-local-resolvers.envsh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/20-envsubst-on-templates.sh
/docker-entrypoint.sh: Launching /docker-entrypoint.d/30-tune-worker-processes.sh
/docker-entrypoint.sh: Configuration complete; ready for start up
2023/12/21 10:50:09 [notice] 1#1: using the "epoll" event method
2023/12/21 10:50:09 [notice] 1#1: nginx/1.25.3
2023/12/21 10:50:09 [notice] 1#1: built by gcc 12.2.0 (Debian 12.2.0-14)
2023/12/21 10:50:09 [notice] 1#1: OS: Linux 5.14.0-284.30.1.el9_2.x86_64
2023/12/21 10:50:09 [notice] 1#1: getrlimit(RLIMIT_NOFILE): 1073741816:1073741816
2023/12/21 10:50:09 [notice] 1#1: start worker processes
2023/12/21 10:50:09 [notice] 1#1: start worker process 28
```

- afficher toutes les informations relatives au conteneur avec une commande `docker inspect`

```bash
[joris@dockertp1linux ~]$ docker inspect recursing_carson
[
    {
        "Id": "77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee",
        "Created": "2023-12-21T10:50:09.144840049Z",
        "Path": "/docker-entrypoint.sh",
        "Args": [
            "nginx",
            "-g",
            "daemon off;"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 4369,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2023-12-21T10:50:09.567936496Z",
            "FinishedAt": "0001-01-01T00:00:00Z"
        },
        "Image": "sha256:d453dd892d9357f3559b967478ae9cbc417b52de66b53142f6c16c8a275486b9",
        "ResolvConfPath": "/var/lib/docker/containers/77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee/hostname",
        "HostsPath": "/var/lib/docker/containers/77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee/hosts",
        "LogPath": "/var/lib/docker/containers/77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee/77e45c95b737d1be91b1fa615464058f02e7cf6a6ccc30bfe5ae6933c91444ee-json.log",
        "Name": "/recursing_carson",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": null,
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "default",
            "PortBindings": {
                "80/tcp": [
                    {
                        "HostIp": "",
                        "HostPort": "9999"
                    }
                ]
            },
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "ConsoleSize": [
                39,
                76
            ],
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": false,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": null,
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": [],
            "BlkioDeviceWriteBps": [],
            "BlkioDeviceReadIOps": [],
            "BlkioDeviceWriteIOps": [],
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": [
                "/proc/asound",
                "/proc/acpi",
                "/proc/kcore",
                "/proc/keys",
                "/proc/latency_stats",
                "/proc/timer_list",
                "/proc/timer_stats",
                "/proc/sched_debug",
                "/proc/scsi",
                "/sys/firmware",
                "/sys/devices/virtual/powercap"
            ],
            "ReadonlyPaths": [
                "/proc/bus",
                "/proc/fs",
                "/proc/irq",
                "/proc/sys",
                "/proc/sysrq-trigger"
            ]
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/c6bc3745992f25ecb328c07aa2fdf0f35805d2c1c56594b773b03b2085c5c1b6-init/diff:/var/lib/docker/overlay2/4d0171b4db0e417225d5de3cb5d587dc11d699106b4b1b7e275a888a9ce2ffa2/diff:/var/lib/docker/overlay2/62f695cda460dc96a32bed622c2a90494b941419df14e38337c13f73b269da7a/diff:/var/lib/docker/overlay2/e3a7f49110a34dc7fce9240a884b14de28597a05139e4516598b1aa5722bf8f5/diff:/var/lib/docker/overlay2/e37589edb6fb6e5d2bf77e91301faf08d55d5caf7f03127e54953f38de618438/diff:/var/lib/docker/overlay2/f0196c6bdb41fdde37ab68420d9b6fd8dc9b52d4d449ffa78051c49a41d99720/diff:/var/lib/docker/overlay2/9bf1f5f8bd366510a165f0e9793a32a38318b1104c13ae6282d3083820b4d826/diff:/var/lib/docker/overlay2/7ef59a207b00d370374bdb397c5c5fa0f285c53b2621befafd9b606a3302c61e/diff",
                "MergedDir": "/var/lib/docker/overlay2/c6bc3745992f25ecb328c07aa2fdf0f35805d2c1c56594b773b03b2085c5c1b6/merged",
                "UpperDir": "/var/lib/docker/overlay2/c6bc3745992f25ecb328c07aa2fdf0f35805d2c1c56594b773b03b2085c5c1b6/diff",
                "WorkDir": "/var/lib/docker/overlay2/c6bc3745992f25ecb328c07aa2fdf0f35805d2c1c56594b773b03b2085c5c1b6/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [],
        "Config": {
            "Hostname": "77e45c95b737",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.25.3",
                "NJS_VERSION=0.8.2",
                "PKG_RELEASE=1~bookworm"
            ],
            "Cmd": [
                "nginx",
                "-g",
                "daemon off;"
            ],
            "Image": "nginx",
            "Volumes": null,
            "WorkingDir": "",
            "Entrypoint": [
                "/docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {
                "maintainer": "NGINX Docker Maintainers <docker-maint@nginx.com>"
            },
            "StopSignal": "SIGQUIT"
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "d7b9a3f19df01210a3109165deb6154061c8e047b18bf53c099b50ea2fdf0f8d",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "80/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "9999"
                    },
                    {
                        "HostIp": "::",
                        "HostPort": "9999"
                    }
                ]
            },
            "SandboxKey": "/var/run/docker/netns/d7b9a3f19df0",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "423a122adb3d41ab155185848317eda6c814221944b1c911f2d5e96fba7123b1",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.2",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:02",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "3f2cedfc4d47700682d3fc12f540803073b2de6aecb281646ab1eda148174cd3",
                    "EndpointID": "423a122adb3d41ab155185848317eda6c814221944b1c911f2d5e96fba7123b1",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.2",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:02",
                    "DriverOpts": null
                }
            }
        }
    }
]
```

- afficher le port en écoute sur la VM avec un `sudo ss -lnpt`

```bash
[joris@dockertp1linux ~]$ sudo ss -lnpt | grep docker
[sudo] password for joris:
LISTEN 0      4096         0.0.0.0:9999      0.0.0.0:*    users:(("docker-proxy",pid=4328,fd=4))
LISTEN 0      4096            [::]:9999         [::]:*    users:(("docker-proxy",pid=4333,fd=4))
```

- ouvrir le port `9999/tcp` (vu dans le `ss` au dessus normalement) dans le firewall de la VM

```bash
[joris@dockertp1linux ~]$ sudo firewall-cmd --list-all | grep 9999
  ports: 9999/tcp
```

- depuis le navigateur de votre PC, visiter le site web sur `http://IP_VM:9999`

➜ On peut préciser genre mille options au lancement d'un conteneur, **go `docker run --help` pour voir !**

➜ Hop, on en profite pour voir un truc super utile avec Docker : le **partage de fichiers au moment où on `docker run`**

- en effet, il est possible de partager un fichier ou un dossier avec un conteneur, au moment où on le lance
- avec NGINX par exemple, c'est idéal pour déposer un fichier de conf différent à chaque conteneur NGINX qu'on lance
  - en plus NGINX inclut par défaut tous les fichiers dans `/etc/nginx/conf.d/*.conf`
  - donc suffit juste de drop un fichier là-bas
- ça se fait avec `-v` pour *volume* (on appelle ça "monter un volume")

> *C'est aussi idéal pour créer un conteneur qui setup un environnement de dév par exemple. On prépare une image qui contient Python + les libs Python qu'on a besoin, et au moment du `docker run` on partage notre code. Ainsi, on peut dév sur notre PC, et le code s'exécute dans le conteneur. On verra ça plus tard les dévs !*

🌞 **On va ajouter un site Web au conteneur NGINX**

- créez un dossier `nginx`
  - pas n'importe où, c'est ta conf caca, c'est dans ton homedir donc `/home/<TON_USER>/nginx/`
- dedans, deux fichiers : `index.html` (un site nul) `site_nul.conf` (la conf NGINX de notre site nul)
- exemple de `index.html` :

```html
<h1>MEOOOW</h1>
```

- config NGINX minimale pour servir un nouveau site web dans `site_nul.conf` :

```nginx
server {
    listen        8080;

    location / {
        root /var/www/html/index.html;
    }
}
```

- lancez le conteneur avec la commande en dessous, notez que :
  - on partage désormais le port 8080 du conteneur (puisqu'on l'indique dans la conf qu'il doit écouter sur le port 8080)
  - on précise les chemins des fichiers en entier
  - note la syntaxe du `-v` : à gauche le fichier à partager depuis ta machine, à droite l'endroit où le déposer dans le conteneur, séparés par le caractère `:`
  - c'est long putain comme commande

```bash
docker run -d -p 9999:8080 -v /home/<USER>/nginx/index.html:/var/www/html/index.html -v /home/<USER>/nginx/site_nul.conf:/etc/nginx/conf.d/site_nul.conf nginx
```

🌞 **Visitons**

- vérifier que le conteneur est actif

```
[joris@dockertp1linux ~]$ sudo docker ps -a
CONTAINER ID   IMAGE     COMMAND                  CREATED          STATUS          PORTS                                               NAMES
a8521459b4dd   nginx     "/docker-entrypoint.…"   22 seconds ago   Up 21 seconds   80/tcp, 0.0.0.0:9999->8080/tcp, :::9999->8080/tcp   loving_pike
```

- aucun port firewall à ouvrir : on écoute toujours port 9999 sur la machine hôte (la VM)
- visiter le site web depuis votre PC

## 5. Un deuxième conteneur en vif

Cette fois on va lancer un conteneur Python, comme si on voulait tester une nouvelle lib Python par exemple. Mais sans installer ni Python ni la lib sur notre machine.

On va donc le lancer de façon interactive : on lance le conteneur, et on pop tout de suite un shell dedans pour faire joujou.

🌞 **Lance un conteneur Python, avec un shell**

- il faut indiquer au conteneur qu'on veut lancer un shell
- un shell c'est "interactif" : on saisit des trucs (input) et ça nous affiche des trucs (output)
  - il faut le préciser dans la commande `docker run` avec `-it`
- ça donne donc :

```bash
# on lance un conteneur "python" de manière interactive
# et on demande à ce conteneur d'exécuter la commande "bash" au démarrage
docker run -it python bash
```

> *Ce conteneur ne vit (comme tu l'as demandé) que pour exécuter ton `bash`. Autrement dit, si ce `bash` se termine, alors le conteneur s'éteindra. Autrement diiiit, si tu quittes le `bash`, le processus `bash` va se terminer, et le conteneur s'éteindra. C'est vraiment un conteneur one-shot quoi quand on utilise `docker run` comme ça.*

🌞 **Installe des libs Python**

- une fois que vous avez lancé le conteneur, et que vous êtes dedans avec `bash`
- installez deux libs, elles ont été choisies complètement au hasard (avec la commande `pip install`):
  - `aiohttp`
  - `aioconsole`
- tapez la commande `python` pour ouvrir un interpréteur Python
- taper la ligne `import aiohttp` pour vérifier que vous avez bien téléchargé la lib

> *Notez que la commande `pip` est déjà présente. En effet, c'est un conteneur `python`, donc les mecs qui l'ont construit ont fourni la commande `pip` avec !*

➜ **Tant que t'as un shell dans un conteneur**, tu peux en profiter pour te balader. Tu peux notamment remarquer :

- si tu fais des `ls` un peu partout, que le conteneur a sa propre arborescence de fichiers
- si t'essaies d'utiliser des commandes usuelles un poil évoluées, elles sont pas là
  - genre t'as pas `ip a` ou ce genre de trucs
  - un conteneur on essaie de le rendre le plus léger possible
  - donc on enlève tout ce qui n'est pas nécessaire par rapport à un vrai OS
  - juste une application et ses dépendances

# II. Images

## 1. Images publiques

🌞 **Récupérez des images**

- avec la commande `docker pull`
- récupérez :
  - l'image `python` officielle en version 3.11 (`python:3.11` pour la dernière version)
  - l'image `mysql` officielle en version 5.7
  - l'image `wordpress` officielle en dernière version
    - c'est le tag `:latest` pour récupérer la dernière version
    - si aucun tag n'est précisé, `:latest` est automatiquement ajouté
  - l'image `linuxserver/wikijs` en dernière version
    - ce n'est pas une image officielle car elle est hébergée par l'utilisateur `linuxserver` contrairement aux 3 précédentes
    - on doit donc avoir un moins haut niveau de confiance en cette image
- listez les images que vous avez sur la machine avec une commande `docker`

> Quand on tape `docker pull python` par exemple, un certain nombre de choses est implicite dans la commande. Les images, sauf si on précise autre chose, sont téléchargées depuis [le Docker Hub](https://hub.docker.com/). Rendez-vous avec un navigateur sur le Docker Hub pour voir la liste des tags disponibles pour une image donnée. Sachez qu'il existe d'autres répertoires publics d'images comme le Docker Hub, et qu'on peut facilement héberger le nôtre. C'est souvent le cas en entreprise. **On appelle ça un "registre d'images"**.

🌞 **Lancez un conteneur à partir de l'image Python**

- lancez un terminal `bash` ou `sh`
- vérifiez que la commande `python` est installée dans la bonne version

> *Sympa d'installer Python dans une version spéficique en une commande non ? Peu importe que Python soit déjà installé sur le système ou pas. Puis on détruit le conteneur si on en a plus besoin.*

## 2. Construire une image

Pour construire une image il faut :

- créer un fichier `Dockerfile`
- exécuter une commande `docker build` pour produire une image à partir du `Dockerfile`

🌞 **Ecrire un Dockerfile pour une image qui héberge une application Python**

- l'image doit contenir
  - une base debian (un `FROM`)
  - l'installation de Python (un `RUN` qui lance un `apt install`)
    - il faudra forcément `apt update` avant
    - en effet, le conteneur a été allégé au point d'enlever la liste locale des paquets dispos
    - donc nécessaire d'update avant de install quoique ce soit
  - l'installation de la librairie Python `emoji` (un `RUN` qui lance un `pip install`)
  - ajout de l'application (un `COPY`)
  - le lancement de l'application (un `ENTRYPOINT`)
- le code de l'application :

```python
import emoji

print(emoji.emojize("Cet exemple d'application est vraiment naze :thumbs_down:"))
```

- pour faire ça, créez un dossier `python_app_build`
  - pas n'importe où, c'est ton Dockerfile, ton caca, c'est dans ton homedir donc `/home/<USER>/python_app_build`
  - dedans, tu mets le code dans un fichier `app.py`
  - tu mets aussi `le Dockerfile` dedans

> *J'y tiens beaucoup à ça, comprenez que Docker c'est un truc que le user gère. Sauf si vous êtes un admin qui vous en servez pour faire des trucs d'admins, ça reste dans votre `/home`. Les dévs quand vous bosserez avec Windows, vous allez pas stocker vos machins dans `C:/Windows/System32/` si ? Mais plutôt dans `C:/Users/<TON_USER>/TonCaca/` non ? Alors pareil sous Linux please.*

🌞 **Build l'image**

- déplace-toi dans ton répertoire de build `cd python_app_build`
- `docker build . -t python_app:version_de_ouf`
  - le `.` indique le chemin vers le répertoire de build (`.` c'est le dossier actuel)
  - `-t python_app:version_de_ouf` permet de préciser un nom d'image (ou *tag*)
- une fois le build terminé, constater que l'image est dispo avec une commande `docker`

🌞 **Lancer l'image**

- lance l'image avec `docker run` :

```bash
docker run python_app:version_de_ouf
```

# III. Docker compose

Pour la fin de ce TP on va manipuler un peu `docker compose`.

🌞 **Créez un fichier `docker-compose.yml`**

- dans un nouveau dossier dédié `/home/<USER>/compose_test`
- le contenu est le suivant :

```yml
version: "3"

services:
  conteneur_nul:
    image: debian
    cmd: sleep 9999
  conteneur_flopesque:
    image: debian
    cmd: sleep 9999
```

Ce fichier est parfaitement équivalent à l'enchaînement de commandes suivantes (*ne les faites pas hein*, c'est juste pour expliquer) :

```bash
$ docker network create compose_test
$ docker run --name conteneur_nul --network compose_test debian sleep 9999
$ docker run --name conteneur_flopesque --network compose_test debian sleep 9999
```

🌞 **Lancez les deux conteneurs** avec `docker compose`

- déplacez-vous dans le dossier `compose_test` qui contient le fichier `docker-compose.yml`
- go exécuter `docker compose up -d`

> Si tu mets pas le `-d` tu vas perdre la main dans ton terminal, et tu auras les logs des deux conteneurs. `-d` comme *daemon* : pour lancer en tâche de fond.

🌞 **Vérifier que les deux conteneurs tournent**

- toujours avec une commande `docker`
- tu peux aussi use des trucs comme `docker compose ps` ou `docker compose top` qui sont cools dukoo
  - `docker compose --help` pour voir les bails

🌞 **Pop un shell dans le conteneur `conteneur_nul`**

- référez-vous au mémo Docker
- effectuez un `ping conteneur_flopesque` (ouais ouais, avec ce nom là)
  - un conteneur est aussi léger que possible, aucun programme/fichier superflu : t'auras pas la commande `ping` !
  - il faudra installer un paquet qui fournit la commande `ping` pour pouvoir tester
  - juste pour te faire remarquer que les conteneurs ont pas besoin de connaître leurs IP : les noms fonctionnent

![In the future](./img/in_the_future.jpg)