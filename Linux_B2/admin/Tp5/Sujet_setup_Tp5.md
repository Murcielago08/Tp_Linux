# Partie 1 : Setup du lab

## Sommaire

- [Partie 1 : Setup du lab](#partie-1--setup-du-lab)
  - [Sommaire](#sommaire)
  - [0. Setup](#0-setup)
  - [1. Lab initial](#1-lab-initial)
    - [A. Présentation](#a-présentation)
  - [B. L'app web](#b-lapp-web)
  - [C. Monter le lab](#c-monter-le-lab)

## 0. Setup

➜ **Machines Rocky Linux 9**

- je vous recommande vivement de descendre à 1G par VM voire 512Mo ou entre les deux
- on va pop pas mal de VMs dans ce TP
- elles feront pas grand chose, donc vous pouvez *overprovision* : c'est à dire donner + de ressources que vous avez réellement

> Par exemple, créez 10 VMs avec 1G de RAM chacune, sur un PC qui n'a que 8Go de RAM, c'est de l'*overprovision*.

➜ **Vous DEVEZ utiliser uniquement les noms de vos machines**

- donc remplir le fichier `/etc/hosts` sur toutes les machines, y compris votre PC

➜ **Vous pouvez (ou pas) utiliser Vagrant pour lancer les VMs**

- notez que dans la vraie vie, les VMs sont omniprésentes
- aujourd'hui : on achète un biiiiig serveur, on installe un hyperviseur type 0, et on fait plein de VMs
- dans la plupart des infras c'est comme ça, la VM reste donc très importante
- ou utilise souvent aujourd'hui des outils analogues à Vagrant pour décrire les VMs avec du code afin de les allumer
- je vous recommande d'utiliser Vagrant pour toutes les VMs, libre à vous, et vous remettez le `Vagrantfile` dans le rendu de TP

➜ **Vous pouvez (ou pas) utiliser Docker pour lancer les apps**

- dans la vraie vie, ce qui peut être systématiquement lancé dans des conteneurs c'est les apps maison (celle où on a besoin de setup un environnement particulier, avec un langage dans une version particulière, ses dépendances, étou)
- à l'inverse, un service d'infra, comme les bases de données, le serveur DNS de l'infra, ou l'Active Directory, c'est moins courant de les voir dans un conteneur
- je vous indiquerai pour chaque application :
  - **🐋 Containerization recommended** si la conteneurisation est recommandée pour faire tourner l'app
  - **🚢 No containerization recommended** si à l'inverse, je vous recommande d'installer ça direct sur la VM

## 1. Lab initial

### A. Présentation

![Lab initial](./img/init.svg)

On va partir d'un setup sans HA classique autour d'une app web :

- **app web**
  - on l'appellera `app_nulle`
  - portée par une VM `web1.tp5.b2`
- **un ptit reverse proxy devant**
  - il sert l'application `app_nulle`
  - porté par une VM `rp1.tp5.b2`
- **une base de données derrière**
  - elle stocke les données de l'application `app_nulle`
  - portée par une VM `db1.tp5.b2`

Un client pourra saisir le nom `http://app_nulle.tp5.b2` pour accéder à l'application.

| Node          | Adresse      | Rôle                       |
| ------------- | ------------ | -------------------------- |
| `web1.tp5.b2` | `10.5.1.11`  | Serveur Web (Apache + PHP) |
| `rp1.tp5.b2`  | `10.5.1.111` | Reverse Proxy (NGINX)      |
| `db1.tp5.b2`  | `10.5.1.211` | DB (MariaDB)               |

## B. L'app web

**L'app web va être ultra simpliste** : un simple fichier PHP qui présente un formulaire HTML pour enregistrer une donnée en base, ou la récupérer. C'est juste une app qui nous permet de tester si notre setup fonctionne correctement !

➜ **Le code est dispo dans [le dossier `php/` du dépôt git](./php/)**

> Je vous ai packagé le tout avec Docker, y'a plus qu'à `docker compose up` et visiter `http://<IP_VM>` avec votre navigateur 🐋 J'ai pas écrit de `README.md` parce que j'suis un animal, démerdez-vous hihi. ALLEZ VOIR LA QUALITE DE MON PHP.

## C. Monter le lab

➜ **Je vais vous laisser monter le setup initial vous-mêmes**, ça commence à être la routine normalement. Les contraintes :

| Contrainte                        | Explication                                                                                                                                                                                                                                                                                                                                                                                                                                                                             | Quelle machine ?        |
| --------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- |
| **Système à jour**                |                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Toutes                  |
| **Fichiers `hosts`**              | Il contient la liste de toutes les VMs pour faire correspondre leur nom à leur IP. Sur Votre PC uniquement, ajoutez aussi `app_nulle.tp5.b2` qui pointe vers l'IP de `rp1.tp5.b2`                                                                                                                                                                                                                                                                                                       | Toutes + votre PC aussi |
| **Principe du moindre privilège** | <ul><li>chaque application doit utiliser un user applicatif</li><li>chaque user doit avoir des droits minimaux</li><li>respectez les bonnes pratiques pour les droits sur les fichiers/dossiers<li>aucun utilisateur `root` ne doit être utilisé directement dès que c'est possible de l'éviter</ul>                                                                                                                                                                                    | Toutes                  |
| **Firewall actif et configuré**   | Enlevez bien les services et les ports ouverts par défaut. N'ouvrez que le port 22/TCP.                                                                                                                                                                                                                                                                                                                                                                                                 | Toutes                  |
| **🐋 Conf serveur Web**          | <ul><li>Apache + PHP installés</li><li>un fichier de conf `app_nulle.conf` dédié à l'hébergement du site web</li><li>désactivez le site par défaut (vous ne devez servir que `app_nulle`)</li><li>le serveur doit écouter que sur l'IP locale (pas sur toutes les IPs, ni 127.0.0.1)</li><li>dans la conf serveur Web, on indique que l'app est hébergée sous le nom `app_nulle.tp2.b5`</li><li>**🐋 Containerization recommended**</li></ul>                                          | `web1.tp5.b2`           |
| **🚢 Conf reverse proxy**        | <ul><li>NGINX installé</li><li>un fichier de conf `app_nulle.conf` dédié au reverse proxying vers `web1.tp5.b2`</li><li>désactivez le site par défaut (vous ne devez servir que un reverse proxying vers pour `app_nulle`)</li><li>le serveur doit écouter que sur l'IP locale (pas sur toutes les IPs, ni 127.0.0.1)</li><li>dans la conf du reverse proxy, on indique que l'app est hébergée sous le nom `app_nulle.tp2.b5`</li><li>**🚢 No containerization recommended**</li></ul> | `rp1.tp5.b2`            |
| **🚢 Conf DB**                   | <ul><li>MariaDB installé</li><li>le serveur doit écouter que sur l'IP locale (pas sur toutes les IPs, ni 127.0.0.1)</li><li>créez une base de données appelée `app_nulle`</li><li>dans la DB toujours, créez un user SQL qui a tous les droits sur la DB `app_nulle` quand il se connecte depuis l'IP de `web1.tp5.b2`</li><li>**🚢 No containerization recommended**</li></ul>                                                                                                        | `db1.tp5.b2`            |
| **⭐Bonus : HTTPS**                   | Rendre disponible l'application en HTTPS plutôt qu'HTTP                                                                                           | `rp1.tp5.b2`            |

---

➜ **Une fois en place, vous devriez pouvoir ouvrir un navigateur sur votre PC et visiter `http://app_nulle.tp5.b2` pour accéder à l'app.**

- vérifier qu'elle fonctionne avant de passer à la suite (vous pouvez insérer et récupérer des données)

🌞 **A rendre**

- le `Vagrantfile`
- les **scripts** qui effectuent la conf
- le README explique juste qu'il faut `vagrant up` et éventuellement taper deux trois commandes après si nécessaire

➜ **Ui ui ui, des scripts**

- je veux des scripts `bash` qui font la conf à votre place
  - ce sera utile pour répliquer la conf sur d'autres machines
  - ça vous fait pratiquer le scripting
- avec Vagrant, vous pouvez faire un dossier partagé entre votre PC et la VM : idéal pour préparer des fichiers de conf ou des scripts et les déposer dans la VM
  - on peut même directement demander à Vagrant d'exécuter un script au démarrage de la VM
- je sais que vous en avez pas beaucoup fait des scripts, faites appel à moi avec plein de questions pour rendre le truc utile et efficace si besoin, c'est l'occasion de pratiquer justement

> *Je vous recommande de faire la conf à la main une première fois, avant de l'automatiser avec un script. Vagrant vous fournit un outil idéal pour détuire/refaire/retester sur une nouvelle VM.*