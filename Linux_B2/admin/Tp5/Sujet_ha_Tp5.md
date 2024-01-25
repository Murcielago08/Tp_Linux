# Partie 2 : HA

![THE server](./img/the_server.jpg)

## Sommaire

- [Partie 2 : HA](#partie-2--ha)
  - [Sommaire](#sommaire)
- [I. Scaling serveur web](#i-scaling-serveur-web)
  - [1. Serveurs Web additionnels](#1-serveurs-web-additionnels)
  - [2. Loadbalancing vers les serveurs Web](#2-loadbalancing-vers-les-serveurs-web)
- [II. Scaling reverse proxy](#ii-scaling-reverse-proxy)
  - [0. Intro](#0-intro)
  - [1. Reverse proxy additionnel](#1-reverse-proxy-additionnel)
  - [2. Keepalived](#2-keepalived)
- [III. Scaling DB](#iii-scaling-db)
  - [0. Intro blablaaaa](#0-intro-blablaaaa)
  - [1. DB additionnelle](#1-db-additionnelle)
  - [2. Conf master slave](#2-conf-master-slave)

# I. Scaling serveur web

![Web Scale](./img/webscale.svg)

On va *scale* notre cluster actuel de serveur web :

- est-ce qu'on peut appeler ça un cluster s'il y a actuellement un seul serveur web ? On va dire que oui ! è_é
- *scale* ça veut dire augmenter le nombre de machines dans le cluster
- on va utiliser une répartition de charges entre les deux serveurs, grâce à notre proxy NGINX

Au menu donc :

- créer deux VMs supplémentaires : `web2.tp5.b2` et `web3.tp5.b2`
- y faire une conf similaire à celle de `web1.tp5.b2`
- adapter la conf du proxying sur `rp1.tp5.b2` pour qu'ils fasse du loadbalancing

## 1. Serveurs Web additionnels

➜ **Créez les deux VMs `web2.tp5.b2` et `web3.tp5.b2`**

- conf identique à `web1.tp5.b2` sauf :
  - l'IP d'écoute dans la conf Apache est différente
  - euh et c'est tout

| Node          | Adresse      | Rôle                       |
| ------------- | ------------ | -------------------------- |
| `web1.tp5.b2` | `10.5.1.11`  | Serveur Web (Apache + PHP) |
| `web2.tp5.b2` | `10.5.1.12`  | Serveur Web (Apache + PHP) |
| `web3.tp5.b2` | `10.5.1.13`  | Serveur Web (Apache + PHP) |
| `rp1.tp5.b2`  | `10.5.1.111` | Reverse Proxy (NGINX)      |
| `db1.tp5.b2`  | `10.5.1.211` | DB (MariaDB)               |

## 2. Loadbalancing vers les serveurs Web

🌞 **Modifier le fichier de conf dédié au reverse-proxy**

- vous avez normalement un fichier dédié à la conf du proxying : `/etc/nginx/conf.d/app_nulle.conf`
- il contient juste un bloc `server { }` qui lui-même contient un `proxy_pass http://web1.tp5.b2` normalemeeeeent
- adaptez votre fichier de conf comme suit :

```nginx
# on crée un groupe de serveurs avec la clause 'upstream'
upstream app_nulle_servers {
    server web1.tp5.b2:80;
    server web2.tp5.b2:80;
    server web3.tp5.b2:80;
}

server {
    [...]
    # on proxy_pass vers ce groupe de serveurs
    proxy_pass http://app_nulle_servers;
    [...]
}
```

> Le loadbalancing effectué par défaut sur NGINX comme beaucoup d'autres outils est un bête *round-robin* ou quelque chose qui s'en rapproche : première requête est envoyée au premier serveur, la deuxième au deuxième, troisième au troisième, et la quatrième de nouveau au premier. Chacun son tour quoi.

🌞 **Vous pouvez reload NGINX pour que votre conf prenne effet**

🌞 **Visitez l'app web depuis votre navigateur** (toujours avec `http://app_nulle.tp5.b2`)

- vous devriez constater que l'IP du serveur qui traite votre requête change à chaque requête effectuée (press F5)
- vous pouvez aussi consulter les logs des différents services pour voir par où passe la requête
  - logs NGINX pour voir qu'il a bien reçu la requête
  - les logs des trois Apache pour voir qui l'a effectivement traitée
- je veux bien un `curl` depuis votre PC dans le compte-rendu.

> *Avec une vraie app, une conf aussi simpliste peut poser soucis. En effet, une vraie app utilise souvent un concept de "session" (genre tu te co à Netflix, bah ensuite, peu importe le nombre de requêtes que tu fais, t'es toujours connecté non ? C'est parce que le serveur gère ta "session"). On fait donc souvent au moins en sorte qu'un client donné estr toujours renvoyé vers le même serveur pour sa session.*

➜ **Pour suivre l'arrivée des logs en temps réel**

- soit vous consultez les logs avec `journalctl`
  - on peut donc `journalctl -xe -u httpd -f`
  - `-x` pour le mode *pager* : on se balade dans les logs avec les flèches du clavier
  - `-e` comme *end* pour lire les logs depuis la fin : on consulte les derniers évènements
  - `-u` comme *unit* pour préciser sur quel unité (un service par exemple) on veut agir
  - `-f` comme *follow* qui permet de suivre en temps réel l'arrivée de nouveaux logs
- soit vous consultez les logs dans un fichier avec `cat` par exemple
  - on peut donc `tail -f <fichier>` pour suivre l'arrivée des logs en temps réel
  - les logs sont habituellement situés dans `/var/log/`

> *Vous pouvez vous équiper avec des beaux terminaux pour avoir 4 shells ouverts devant vos yeux (un sur le reverse proxy, et un sur chaque serveur web) avec l'arrivée des logs en temps réel.*

# II. Scaling reverse proxy

## 0. Intro

![SPOF](./img/spof.jpeg)

C'est bien d'augmenter la taille du cluster de serveurs Web mais bon, y'a toujours qu'un seul proxy devant ! **On dit que le proxy dans ce contexte est un *SPOF* : Single Point Of Failure** (ou en français : point unique de défaillance).

**Un *SPOF* dans une infra c'est quand y'a un moment où y'a qu'un seul chemin pour aller de A à B.** Ici qu'un seul tuyau pour que le client atteigne le serveur Web : le seul reverse proxy.

**On va donc ajouter un deuxième reverse proxy** qui pourra prendre la relève si le premier fail. Ici **pas de loadbalancing, mais plutôt de la tolérance de panne** donc.

**L'un des deux serveurs NGINX sera dit "actif" et l'autre "passif".** Si le serveur "actif" meurt, le "passif" prend le relais (et devient le serveur "actif").

Pour faire ça on va utilser...

- **une IP virtuelle**
  - ou VIP
  - une IP qui est portée par les deux serveurs en même temps
- **cette VIP est mise en place par le protocole VRRP**
  - bah il sert à ça
  - les deux machines se spamment avec le protocole VRRP pour connaître l'état du cluster
  - si "l'actif" arrête de répondre au "passif" en VRRP, il prend la relève et c'est lui qui répondra à la VIP
- **et on va setup ça avec la techno Keepalived**
  - un incontournable du monde Linux pour des setups HA

![Web Scale](./img/vip.svg)

## 1. Reverse proxy additionnel

➜ **Même musique : créez une nouvelle VM `rp2.tp5.b2`**

- conf identique à `rp1.tp5.b2` à part l'IP d'écoute du proxy

| Node          | Adresse      | Rôle                               |
| ------------- | ------------ | ---------------------------------- |
| `web1.tp5.b2` | `10.5.1.11`  | Serveur Web (Apache + PHP)         |
| `web2.tp5.b2` | `10.5.1.12`  | Serveur Web (Apache + PHP)         |
| `web3.tp5.b2` | `10.5.1.13`  | Serveur Web (Apache + PHP)         |
| `rp1.tp5.b2`  | `10.5.1.111` | Reverse Proxy (NGINX + Keepalived) |
| `rp2.tp5.b2`  | `10.5.1.112` | Reverse Proxy (NGINX + Keepalived) |
| VIP           | `10.5.1.110` | IP Virtuelle Keepalived            |
| `db1.tp5.b2`  | `10.5.1.211` | DB (MariaDB)                       |

## 2. Keepalived

🌞 **Installez Keepalived sur les deux serveurs reverse proxy**

- effectuez une conf basique pour désigner `rp1.tp5.b2` comme le serveur actif
  - Keepalived utilise les mots
    - "MASTER" pour le serveur "actif"
    - et il désigne par "BACKUP" le serveur "passif"
  - il a un système de priorité
    - plus elle est haute, plus le serveur est prioritaire pour porter la VIP
  - autrement dit, vous choisissez qui est le serveur "actif" en le désignant comme "MASTER" avec une priorité haute
  - et l'inverse pour le slave
- je vous laisse libre de fouiller sur internet pour des exemples de conf, ce sera toujours pareil hein :
  - install paquet
  - conf
  - démarrer le service
- **la VIP doit être `10.5.1.110`**

➜ **Modifier le fichier `hosts` de votre PC**

- `app_nulle.tp5.b2` doit désormais pointer vers la VIP `10.5.1.110`

➜ **Vérifier le bon fonctionnement**

- avec `ip a` vous devriez voir qui porte actuellement la VIP `10.5.1.110`
- faites un test en visitant l'app depuis votre navigateur (toujours `http://app_nulle.tp5.b2`)

🌞 **J'ai dit de tester que ça marchait**

- crasher `rp1.tp5.b2`
- constater que `rp2.tp5.b2` est devenu "actif" (il est passé "MASTER" et il porte la VIP)
- ***bonus*** : un truc chouette à faire ce serait une ptite boucle `for` ou un `watch`, qui lance des `curl` en boucle sur `http://app_nulle.tp5.b2` pour voir s'il y a une interruption de service ou non quand la VIP bascule
- ***bonus*** : vous pouvez aussi Wireshark entre les deux reverse proxy avant/pendant/après le crash, pour voir les paquets VRRP échangés

# III. Scaling DB

## 0. Intro blablaaaa

Et enfin, notre p'tite DB. On va ajouter un deuxième serveur DB, là encore pour proposer de la HA, cette fois-ci au niveau du service de base de données.

➜ Ici ça va être **du *"master/slave"*** encore comme setup, et cette fois j'attire votre attention sur **la complexité du problème** :

- on peut pas juste loadbalance le trafic entre les deux DB, think about it
- si on le faisait, ça voudrait dire quoi ? On fait un `INSERT` et ça modifie qu'une seule des deux bases ?
- **là on parle pas juste de partager une IP entre les deux serveurs, mais de partager des données**
- dès qu'un `INSERT` est effectué, il faut que les données arrivent sur les deux serveurs de db
- il se passe quoi si on insère une donnée en même temps qui se retrouve avec le même ID attribué ?
- **le setup le plus simple consiste donc en un *"master/slave"*** avec le *master* qui réceptionne les requêtes, et le *slave* qui est une copie du *master*
- on peut accéder aux données sur le *slave*, mais uniquement en *read-only*

➜ **On dit donc que c'est un setup avec un cluster de base de données et de la réplication** ("réplication" c'est le fait que le *slave* réplique les données du *master*).

> *La désignation **"master/slave"** porte un peu à débat aujourd'hui. Compréhensible, on pourrait choisir d'autres mots ptet !*

![DB Scale](./img/db_scale.svg)

## 1. DB additionnelle

➜ **Vous connaissez la chanson : créez une nouvelle VM `db2.tp5.b2`**

- conf identique à `db1.tp5.b2` à part l'IP d'écoute de la DB

| Node          | Adresse      | Rôle                               |
| ------------- | ------------ | ---------------------------------- |
| `web1.tp5.b2` | `10.5.1.11`  | Serveur Web (Apache + PHP)         |
| `web2.tp5.b2` | `10.5.1.12`  | Serveur Web (Apache + PHP)         |
| `web3.tp5.b2` | `10.5.1.13`  | Serveur Web (Apache + PHP)         |
| `rp1.tp5.b2`  | `10.5.1.111` | Reverse Proxy (NGINX + Keepalived) |
| `rp2.tp5.b2`  | `10.5.1.112` | Reverse Proxy (NGINX + Keepalived) |
| VIP           | `10.5.1.110` | IP Virtuelle Keepalived            |
| `db1.tp5.b2`  | `10.5.1.211` | DB (MariaDB)                       |
| `db2.tp5.b2`  | `10.5.1.212` | DB (MariaDB)                       |

## 2. Conf master slave

Avec MariaDB, c'est natif, rien à ajouter et on peut demander à deux DB de former un cluster *master/slave*.

🌞 **Configurer vos deux DBs pour former un cluster**

- je vous laisse trouver un ptit lien (ou plusieurs) poru configurer ça
- le [link server-world](https://www.server-world.info/en/note?os=Ubuntu_22.04) est pas mal, [la doc officielle](https://mariadb.com/kb/en/setting-up-replication/) aussi bien sûr
- pour constater que ça fonctionne bien :
  - vous pouvez vérifier l'état du cluster avec des commandes SQL
  - vous pouvez aussi utiliser l'app et consulter les logs des deux bases de données

![DB fails](./img/dbfails.png)