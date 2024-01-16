# TP2 : Utilisation courante de Docker

Dans ce TP, on va aborder des utilisations un peu plus réalistes de Docker.

Les sujets sont assez courts, car après l'intro, vous avez normalement compris que savoir se servir de Docker c'est :

- savoir run des machins qui existent (run)
- savoir customiser des machins qui existent (Dockerfile + build)
- savoir run nos propres machins customisés (run + compose)

## Sommaire

- [TP2 : Utilisation courante de Docker](#tp2--utilisation-courante-de-docker)
  - [Sommaire](#sommaire)
- [I. Commun à tous : Stack PHP](#i-commun-à-tous--stack-php)
- [II Dév. Python](#ii-dév-python)
- [II Admin. Maîtrise de la stack PHP](#ii-admin-maîtrise-de-la-stack-php)
- [II Secu. Big brain](#ii-secu-big-brain)

# I. Commun à tous : Stack PHP

🌞 **`docker-compose.yml`**

- genre `tp2/php/docker-compose.yml` dans votre dépôt git de rendu
- votre code doit être à côté dans un dossier `src` : `tp2/php/src/tous_tes_bails.php`
- s'il y a un script SQL qui est injecté dans la base à son démarrage, il doit être dans `tp2/php/sql/seed.sql`
  - on appelle ça "seed" une database quand on injecte le schéma de base et éventuellement des données de test
- bah juste voilà ça doit fonctionner : je git clone ton truc, je `docker compose up` et ça doit fonctionne :)
- ce serait cool que l'app affiche un truc genre `App is ready on http://localhost:80` truc du genre dans les logs !

➜ **Un environnement de dév local propre avec Docker**

- 3 conteneurs, donc environnement éphémère/destructible
- juste un **`docker-compose.yml`** donc facilement transportable
- TRES facile de mettre à jour chacun des composants si besoin
  - oh tiens il faut ajouter une lib !
  - oh tiens il faut une autre version de PHP !
  - tout ça c'est np

[docker-compose](./php/docker-compose.yml)

# II Dév. Python

[Document dédié au lancement d'un environnement de dév Python avec Docker.](./Rendu_tp2_dev.md)

# II Admin. Maîtrise de la stack PHP

[Document dédié à la maîtrise de la stack PHP](./Rendu_Tp2_admin.md)

# II Secu. Big brain

Pour les sécus, vous faites tout : la partie "II Dév" et la partie et "II Admin".