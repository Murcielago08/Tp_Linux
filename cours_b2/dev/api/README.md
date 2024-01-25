# API REST HTTP simpliste avec Flask

Dans ce cours, présentation rapide des API REST HTTP.

## Sommaire

- [API REST HTTP simpliste avec Flask](#api-rest-http-simpliste-avec-flask)
  - [Sommaire](#sommaire)
  - [1. Terminologie](#1-terminologie)
    - [A. API](#a-api)
    - [B. REST](#b-rest)
    - [C. HTTP](#c-http)
    - [D. API REST HTTP](#d-api-rest-http)
    - [E. Et JSON dans tout ça](#e-et-json-dans-tout-ça)
  - [2. Avec Python](#2-avec-python)
    - [A. Intro](#a-intro)
    - [B. stfu show me the code](#b-stfu-show-me-the-code)

## 1. Terminologie

### A. API

Une **API** pour *Application Programming Interface* c'est un moyen que deux programmes utilisent pour échanger des données.

Très peu de programmes évoluent seuls, la plupart dépendent de données externes.

**Une API c'est donc un programme** (ou une partie d'un programme si vous êtes sales et que tout est codé dans un seul programme) qui agit comme un serveur et qui attend la connexion de clients.

Un client pourra alors faire une requête vers une route précise (une route c'est l'adresse d'une ressource) afin de déclencher une action sur le serveur, ou récupérer des données.

### B. REST

**REST** pour *Representation State Transfer* **est un standard** qui désigne comment certaines applications du Web doivent se comporter pour pas que ce soit un giga bordel.

Dans le contexte des APIs, c'est particulièrement intéressant de respecter un standard : le but d'une API est souvent d'être facilement accessible et utilisable, puisque son but-même est de rendre disponible les fonctions d'une application.

Respecter c'est un standard, c'est accepter de parler une langue commune avec les autres dévs.

> REST est un ensemble de standards divers, [la page Wikipedia est pas mal](https://en.wikipedia.org/wiki/REST).

**On parle donc d'API REST si l'API respecte (au moins un peu) ce standard.**

### C. HTTP

HTTP vous commencez à le connaître un peu nan ? C'est un protocole qui est encapsulé dans du TCP, et qui permet de télécharger des fichiers.

Il existe des clients HTTP particuliers qu'on appelle *navigateurs web* et qui permettent d'afficher (de *render*) les pages HTML qui sont téléchargés.

Dans le contexte des APIs, c'est super pratique HTTP ! On a besoin que notre programme agisse comme un serveur, et réagisse en fonction des requêts d'un client. BIM ! HTTP est parfait pour ça : notre programme API HTTP c'est un serveur Web.

**On parle donc d'API HTTP si l'API se présente sous la forme d'un serveur Web.**

### D. API REST HTTP

**Une API REST HTTP c'est donc un programme, un serveur web pour être plus précis, qui expose des routes précises. Chaque route permet de déclencher une action ou récupérer des infos.**

Voilà j'ai tout dit en fait.

### E. Et JSON dans tout ça

**Le format standard pour échanger des infos avec une API, c'est devenu JSON.**

> Respecter un format standard pour échanger des infos, c'est notamment un des aspects de REST.

A l'instar de HTML, XML, YML, le **JSON est juste un langage de structure de données** : on peut pas écrire d'algo avec, juste stocker des données.

C'est moins archaïque que le HTML ou XML qui gaspillent énormément de caractères avec un système de balises.

## 2. Avec Python

### A. Intro

Avec Python y'a plein de façons de faire, comme toujours.

- à la main bien sûr (avec juste la lib `requests` native qui permet de gérer des requêtes HTTP)
- à la main encore plus avec `socket` si vous êtes des oufs, et vous ré-implémentez le protocole HTTP
- parlons sérieusement, côté frameworks, y'en a plein
  - **nous on va utiliser [Flask](https://flask.palletsprojects.com/en/3.0.x/)**, qui se veut minimaliste, parfait pour les cours
  - y'en a d'autres en Python, j'suis pas expert, y'a [Django](https://www.django-rest-framework.org) aussi
  - on va pas utiliser le "sous-framework" de Flask dédié aux APIs : [FlaskRESTFul](https://flask-restful.readthedocs.io/en/latest/), juste Flask tout seul

### B. stfu show me the code

On suppose l'existence du fichier `data/users.json` avec le contenu :

```json
{
  "1": {
    "name": "john",
    "email": "john@meo.com"
  },
  "2": {
    "name": "martin",
    "email": "martin@meo.com"
  }
}
```

API minimaliste avec Python Flask (le code est si simple que j'vais pas beaucoup le commenter).

```python
from flask import Flask, abort, jsonify
import json

# on crée un ptit objet Flask, nécessaire pour ajouter des routes
app = Flask(__name__)
app.secret_key = b'SECRET_KEY'

# utilisation d'un décorateur Python avec @ pour donc décorer une fonction
# c'est l'ajout de ce décorateur qui permet d'ajouter une route
# c'est dans la doc de Flask, nous on obéit :D
@app.route('/users', methods=['GET'])
def get_users():
    file = open("data/users.json")
    users = json.load(file)
    file.close()

    # Flask fournit une méthode jsonify() qui permet de retourner des objets Python sous format JSON de façon adaptée
    return jsonify(users)

@app.route('/users/<user_id>', methods=['GET'])
def get_user(user_id=None):
    file = open("data/users.json")
    users = json.load(file)
    file.close()

    if user_id in users:
        results = jsonify(users[user_id])
        return results
    else:
        # la ptite 404 clean quand on demande une ressource qui n'existe pas
        abort(404)

    return jsonify(users)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80, debug=True)
```

Et ça donne :

```bash
❯ curl localhost/users
{
  "1": {
    "email": "john@meo.com",
    "name": "john"
  },
  "2": {
    "email": "martin@meo.com",
    "name": "martin"
  }

❯ curl localhost/users/1
{
  "email": "john@meo.com",
  "name": "john"

❯ curl localhost/users/2
{
  "email": "martin@meo.com",
  "name": "martin"

❯ curl localhost/users/3
<!doctype html>
<html lang=en>
<title>404 Not Found</title>
<h1>Not Found</h1>
<p>The requested URL was not found on the server. If you entered the URL manually please check your spelling and try again.</p>
```

**Incroyable.**

Evidemment, il arrive souvent que dans un contexte réel, la donnée ne soit pas stockée dans un simple fichier JSON, mais quelque part en base de données par exemple.

Bah ça change rien : on récupère les données là où elles sont, on les convertit en JSON, et on balance ça au client.
