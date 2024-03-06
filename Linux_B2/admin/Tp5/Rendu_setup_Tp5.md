# Partie 1 : Setup du lab

## Sommaire

- [Partie 1 : Setup du lab](#partie-1--setup-du-lab)
  - [Sommaire](#sommaire)
  - [1. Lab initial](#1-lab-initial)
    - [A. Présentation](#a-présentation)
  - [C. Monter le lab](#c-monter-le-lab)

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

pour lancer le vagrantfile rien de plus simple ^^
aller avec la commande ```cd``` dans le dossier où est le vagrantfile ^^
si vous avez clone faite la commande :
```
cd .\Linux_B2\admin\Tp5\ (Windows) 
ou
cd ./Linux_B2/admin/Tp5/ (Linux)
```

Puis lancer la commande ```vagrant up```

Et voilà vous avez tout de prêt ^^

[vagrant](./Vagrantfile)

[script web](./web1_setup.sh)

[script rp](./rp1_setup.sh)

[script db](./db1_setup.sh)