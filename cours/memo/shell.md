# Mémo commandes

Ici se trouvent l'ensemble des commandes et fichiers élémentaires pour utiliser de façon naturelle le terminal.  
Plus spécifiquement, nous allons nous concentrer en cours sur l'utilisation du shell `bash`.

**NB :** RIEN ici n'est exhaustif. Ce doc a simplement pour but de vous fournir les commandes usuelles et leurs options les plus couramment utilisées.

> **L'exhaustivité, elle est dans le `man` de chaque commande.**

<!-- vim-markdown-toc GitLab -->

- [Mémo commandes](#mémo-commandes)
- [Introduction](#introduction)
  - [Raccourcis `bash`](#raccourcis-bash)
  - [Fonctionnement élementaire](#fonctionnement-élementaire)
  - [Interprétation d'une ligne de commande](#interprétation-dune-ligne-de-commande)
  - [Le `man`](#le-man)
  - [POSIX](#posix)
- [Commandes relatives à l'arborescence de fichiers](#commandes-relatives-à-larborescence-de-fichiers)
  - [Basics](#basics)
  - [More advanced](#more-advanced)
- [Lire des fichiers](#lire-des-fichiers)
  - [Commandes](#commandes)
- [Arrêt et redémarrage du système](#arrêt-et-redémarrage-du-système)
- [Gestion d'utilisateurs](#gestion-dutilisateurs)
  - [Commandes](#commandes-1)
- [Gestion de flux](#gestion-de-flux)
- [Manipulation et filtre de texte](#manipulation-et-filtre-de-texte)
- [`vim`](#vim)
- [Inspecter le système](#inspecter-le-système)
  - [Réseau](#réseau)
  - [Stockage et RAM](#stockage-et-ram)
  - [Gestion de processus](#gestion-de-processus)
    - [Théorie](#théorie)
    - [Commandes](#commandes-2)
    - [Processus en tâche de fond](#processus-en-tâche-de-fond)
- [Gestion de logs](#gestion-de-logs)
- [Environnement](#environnement)
  - [Variables d'environnement](#variables-denvironnement)
- [Gestion de services](#gestion-de-services)

<!-- vim-markdown-toc -->

# Introduction

## Raccourcis `bash`

| Description                                       | Raccourci                    |
|---------------------------------------------------|------------------------------|
| Reprendre la dernière commande tapée              | `!!`                         |
| Clear le terminal                                 | `CTRL + L`                   |
| Se déconnecter de la session actuelle             | `CTRL + D`                   |
| Aller au début de la ligne                        | `CTRL + A`                   |
| Aller à la fin de la ligne                        | `CTRL + E` (comme "End")     |
| Reculer d'un mot                                  | `ALT + B` (comme "Backward") |
| Avancer d'un mot                                  | `ALT + F` (comme "Forward")  |
| Supprimer du curseur jusqu'à la fin du mot actuel | `ALT + D` (comme "Delete")   |
| Supprimer du curseur jusqu'à la fin de la ligne   | `CTRL + K`                   |
| Supprimer du curseur jusqu'au début de la ligne   | `CTRL + U`                   |
| Recherche dans l'historique                       | `CTRL + R`                   |

Quelques combos pratiques :

| Description                            | Combo                                   |
|----------------------------------------|-----------------------------------------|
| Retaper la dernière commande en `sudo` | `sudo !!`
| Full clear le terminal                 | ` CTRL + A` -> `CTRL + K` -> `CTRL + L`

## Fonctionnement élementaire

Dans un système GNU/Linux, on appelle *commandes* les binaires auxquels ont fait appel depuis le shell (comme `bash`). **Ces commandes, ces binaires, ne sont donc que de simples fichiers exécutables.**

Pour qu'une commande puisse être exécutée, il est **obligatoire** de connaître son chemin dans l'arborescence de fichiers.

Pour éviter de taper le chemin complet des commandes très utilisées, on utilise la variable d'environnement `$PATH`. La variable `$PATH` contient les chemins où se trouvent les commandes très utilisées. Pour voir ces chemins, il faut afficher la variable `$PATH` depuis le terminal :

```bash
$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/sbin
```

**Exécuter une commande revient à lancer un processus sur le système.** Un processus est **forcément** exécuté sous l'identité d'un utilisateur de la machine.

**La commande qui permet d'obtenir des informations sur toutes les autres commandes est `man` pour *manuel***. En effet cette commande permet d'afficher le manuel d'une commande donnée (par exemple : `man ls`).

## Interprétation d'une ligne de commande

Avant d'exécuter la commande renseignée dans la ligne de commande, `bash` va d'abord regarder la ligne en entier afin de l'évaluer.

Par exemple :

- les différents éléments de la ligne de commande sont séparées par des espaces
  - ou des tabulations, ou encore d'autres caractères, suivant les OS
  - on appelle *IFS* pour *Internal Field Separator* la variable qui contient les carctères qui sont utilisés pour délimiter différents éléments sur la ligne de commande
  - donc, sur la plupart des OS, *l'IFS* contient notamment le caractère Espace et Tabulation
- si aucun chemin n'est précisé, `bash` va chercher la commande demandée dans les chemins précisés dans la variable `$PATH`
- les variables sont remplacées par leurs valeurs
- les métacaractères sont remplacés par la valeur correspondante
  - `.` fait référence au répertoire actuel
  - `..` fait référence au répertoire parent du répertoire actuel
  - `~` correspond au répertoire personnel de l'utilisateur actuel
  - `&` en fin de ligne indique la commande doit être lancée en tâche de fond
  - `$BAP` correspond à une variable appelée `BAP`
  - `$(ls)` corespond à une substitution de commande (on y revient plus bas)

## Le `man`

**Il est possible d'afficher le manuel d'une commande ou d'un fichier, ou encore d'un mécanisme Linux, à l'aide de la commande `man`.** Par exemple `man ls`.

Il existe souvent plusieurs pages de manuel liées à une entité donnée. Pour voir les pages de `man` dispo pour une entité donnée, on peut faire `whatis <ENTITE>`, par exemple `whatis ls`.

Pour ouvrir une page du manuel spécifique : `man <PAGE> <ENTITE>`. Par exemple : `man 1 ls`.

## POSIX

**POSIX désigne un ensemble de standards visant à uniformiser la gestion des systèmes d'exploitation.**

POSIX comprendre notamment :

- la gestion de permissions (les droits `rwx` sur les fichiers par exemple)
- l'utilisation des pipes
- la mémoire partagée
- etc.

Lorsqu'un système respecte les normes POSIX, on dit qu'il est POSIX-compliant. Il existe aujourd'hui très peu d'OS qui sont complètement POSIX-compliant, la plupart des distributions GNU/Linux connues ne le sont pas complètement.

# Commandes relatives à l'arborescence de fichiers

## Basics

| Commande | Description                                                                                               | Exemple(s)        |
|----------|-----------------------------------------------------------------------------------------------------------|-------------------|
| `pwd`    | Affiche le répertoire courant                                                                             | `pwd`             |
| `touch`  | Modifie la date de dernière modification d'un fichier. Peut aussi créer un fichier vide s'il n'existe pas | `touch /tmp/file` |
| `mkdir`  | Crée un dossier                                                                                           | <ul><li>`mkdir /tmp/new_dir` crée un nouveau répertoire `new_dir` dans le dossier `/tmp`</li><li>`mkdir -p /tmp/new_dir1/new_dir2` crée un nouveau répertoire `new_dir2`, contenu dans le répertoire `new_dir1`, lui-même contenu dans `/tmp`</li></ul>
| `cd`     | Change de répertoire                                                                                      | <ul><li>`cd /tmp` : se déplacer dans le répertoire `/tmp`</li><li>`cd -` : se déplacer dans le répertoire précédent (avant que l'on fasse un `cd`)</li></ul>                                                                                            |
| `cp`     | Copier un fichier                                                                                         | <ul><li>`cp /tmp/toto /tmp/tata` copie le fichier `/tmp/toto` vers `/tmp/tata`</li><li>`cp /tmp/toto /home/` copie le fichier `/tmp/toto` vers le dossier `/home`</li></ul>
| `mv`     | Identique à `cp` mais déplace au lieu de copier                                                           |                                                                                                                                                                                                                                                         |
| `ls`     | Liste les fichiers d'un répertoire donné. Sans argument, `ls` liste le contenu du répertoire actuel      | <ul><li>`ls /tmp` liste les fichiers du dossier `/tmp`</li><li>`ls` liste les fichiers du répertoire courant</li><li>`ls -al` liste les fichiers (y compris les fichiers cachés) du répertoire courant, sous forme de liste</li></ul>

## More advanced

| Commande | Description                                                                                                        | Exemple(s)                                                                                                                                                                                            |
|----------|--------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `find`   | Cherche un ou plusieurs fichier(s) suivant les critères fournis. Cette commande est très puissante et TRES rapide. | <ul><li>`find -name toto /` : cherche un fichier qui s'appelle `toto` en partant de `/`</li><li>`find -atime +10 /tmp` : cherche les fichiers qui ont été modifiés il y a 10 jours ou moins</li></ul> |
| `which`  | Retourne le chemin absolu d'une commande donnée                                                                    | `which sudo`                                                                                                                                                                                          |
| `ln` | Crée un lien (un "raccourci") vers un fichier donné. On l'utilise souvent avec l'option `-n` pour créer un *lien symbolique*. | `ln -s /bin/bash /tmp/toto` : crée un lien symbolique `/tmp/toto` qui pointe vers `/bin/bash`

# Lire des fichiers

## Commandes

| Commande | Description                                                 | Exemple(s)                                                                                                                                                                                                                                                                                       |
|----------|-------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `cat`    | (simplifié) Affiche le contenu d'un ou plusieurs fichier(s) | <ul><li>`cat /tmp/file1` : affiche le contenu du fichier `/tmp/file1`</li><li>`cat /tmp/file1 /tmp/file2` : affiche le contenu des fichiers `/tmp/file1` ET `/tmp/file2`</li></ul>                                                                                                               |
| `tail`   | Affiche la fin d'un fichier                                 | <ul><li>`tail /tmp/file1` : affiche la fin du fichier `/tmp/file1`</li><li>`tail -n 10 /tmp/file1` : affiche les 10 dernières lignes du fichier `/tmp/file1`</li><li>`tail -f /tmp/file1` (pour "Follow") : Suit en temps réel la fin du fichier (idéal pour suivre un fichier de log)</li></ul> |
| `head`   | Affiche le début d'un fichier                               | <ul><li>`head /tmp/file1` : affiche le début du fichier `/tmp/file1`</li><li>`head -n 10 /tmp/file1` : affiche les 10 premières lignes du fichier `/tmp/file1`</li></ul>                                                                                                                         |
| `more` et `less` | Affiche le contenu d'un fichier avec un pager 

> Les commandes `head`, `tail`, `more` et `less` peuvent aussi lire depuis STDIN. Exemple : `ps -ef | tail -n 10` ou encore `ps -ef | less`.

# Arrêt et redémarrage du système 

| Commande   | Description                                                                                     | Exemple(s)                                                                                                                   |
|------------|-------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------|
| `reboot`   | Permet de demander un redémarrage du système                                                    | `reboot`                                                                                                                     |
| `poweroff` | Permet de demander l'arrêt du système                                                           | `poweroff`                                                                                                                   |
| `shutdown` | Permet d'effectuer des opérations liées à l'allumage de la machine : veille, arrêt, redémarrage | <ul><li>`shutdown now` : arrête le système immédiatement</li><li>`shutdown 60` : arrête le système dans 60 minutes</li></ul> |

# Gestion d'utilisateurs

Quelques règles...

- tout utilisateur possède **forcément** au moins un groupe
- l'utilisateur `root` possède l'ID 0 est n'est pas supprimable du système

| Commande     | Description                                                                     | Exemple(s)                                                                                                                                                                                                                                                                                           |
|--------------|---------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `useradd`    | Ajoute un utilisateur                                                           | <ul><li>`useradd toto` : ajoute un utilisateur appelé "toto"</li><li>`useradd toto -m -s /bin/sh -u 2000` : crée un utilisateur "toto", crée automatiquement son répertoire personnel (`-m`), définit `/bin/sh` comme shell par défaut pour cet utilisateur et l'identifiant 2000 pour UID</ul></li>
| `groupadd`   | Ajoute un groupe                                                                | `groupadd toto` : ajoute un groupe "toto"                                                                                                                                                                                                                                                            |
| `userdel`    | Supprime un utilisateur                                                         | `userdel toto`                                                                                                                                                                                                                                                                                       |
| `groupdel`   | Supprime un groupe                                                              | `groupdel toto`                                                                                                                                                                                                                                                                                      |
| `usermod`    | Effectue des opérations liées aux utilisateurs et aux groupes **déjà créés**    | `usermod -aG admins toto` : ajoute l'utilisateur "toto" au groupe "admins".                                                                                                                                                                                                                          |
| `groups`     | Affiche les groupes dont est membre un utilisateur donné                        | `groups toto`                                                                                                                                                                                                                                                                                        |
| `w` et `who` | Affiche la liste des utilisateurs actuellement connectés à la machine           | `who`                                                                                                                                                                                                                                                                                                |
| `last`       | Affiche la liste des dernières connexions qui ont été effectuées sur le système | `last`                                                                                                                                                                                                                                                                                               |


| Fichier       | Description                                                                      |
|---------------|----------------------------------------------------------------------------------|
| `/etc/passwd` | Contient la liste des utilisateurs et certaines informations qui leur sont liées |
| `/etc/shadow` | Contient la liste des mots de passe hashés des utilisateurs                      |
| `/etc/group`  | Contient la liste des groupes du système                                         |

## Commandes

| Commande | Description                                                                                                                                        | Exemple(s)                                                                                                                                                                                                                                                                                |
|----------|----------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `chown`  | Modifie le propriétaire d'un fichier (utilisateur et/ou groupe)                                                                                    | <ul><li>`chown toto /tmp/file1` définit "toto" comme utilisateur propriétaire du fichier `/tmp/file1`</li><li>`chown toto:tata /tmp/file1` définit "toto" comme utilisateur propriétaire du fichier et "tata" comme groupe propriétaire</li></ul>                                         |
| `chgrp`  | Modifie le groupe propriétaire d'un fichier                                                                                                        | `chgrp tata` définit "tata" comme groupe propriétaire                                                                                                                                                                                                                                     |
| `chmod`  | Modifie les permissions POSIX d'un fichier                                                                                                         | <ul><li>`chmod 644 file1` définit les droits `rw-r--r--` sur un fichier `file1`</li><li>`chmod u+w file1` ajoute le droit `w` à l'utilisateur propriétaire du fichier `file1`</li><li>`chmod +r file1` ajoute le droit `r` à tout le monde (utilisateur, groupe, et les autres)</li></ul> |
| `ls -al` | Affiche des informations sur un fichier, y compris son utilisateur et groupe propriétaires ainsi que les permissions POSIX liés à un fichier donné | `ls -al /tmp`                                                                                                                                                                                                                                                                             |
# Gestion de flux

**Quelques règles...**

- toute commande peut accueillir des informations dans sa sortie standard
  - ce sont des infos que l'on envoie à une commande pour qu'elle puisse fonctionner
- une commande peut générer une sortie standard et une sortie d'erreur
  - c'est le texte qui est imprimé dans le terminal après l'exécution d'une commande (le résultat d'un `ls` par exemple)
- ces trois flux portent des noms raccourcis très souvent utilisés pour les désigner, ainsi qu'un numéro
  - entrée standard "STDIN" : flux 0
  - sortie standard "STDOUT" : flux 1
  - sortie d'erreur  "STDERR" : flux 2

| Caractère | Description                                                                               | Exemple(s)                                                                                |
|-----------|-------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------|
| `>`       | Redirige STDOUT vers un fichier (écrase le contenu du fichier s'il existe déjà)           | `echo 'toto' > /tmp/file1` : écrit 'toto' dans le fichier `/tmp/file1`
| `>>`      | Redirige STDOUT vers un fichier (ajoute le contenu au fichier s'il existe déjà)           | `echo 'toto' >> /tmp/file1` : ajoute 'toto' au fichier `/tmp/file1`
| `2>`      | Redirige STDERR vers un fichier (écrase le contenu du fichier s'il existe déjà)           | `dkzjdkzjdjzoidjz 2> /tmp/file1` : écrit un message d'erreur dans le fichier `/tmp/file1`
| `2>>`     | Redirige STDERR vers un fichier (ajoute le contenu au fichier s'il existe déjà)           |
| `&>`      | Redirige STDOUT et STDERR vers un fichier (écrase le contenu au fichier s'il existe déjà) |
| `&>>`     | Redirige STDOUT et STDERR vers un fichier (ajoute le contenu au fichier s'il existe déjà) |
| `\|`                                                                                         | Redirige STDOUT d'une commande vers STDIN d'une autre commande                            | `ps -ef \| grep python` : la commande `ps -ef` affiche une liste des processus actifs sur la machine en STDOUT. Grâce au ` | `, on envie tout cette liste en STDIN de `grep`.

# Manipulation et filtre de texte

| Commande | Description | Exemple |
| --- | --- | --- |
| `grep` | Votre meilleur ami. Permet de filtrer certaines lignes dans un texte donné. | <ul><li> `ps -ef \| grep python` : utilisé avec `\|`, il permet de filtrer l'output (STDOUT et/ou STDERR) d'une commande. Ici on cherche les lignes qui contiennent le mot "python" dans le STDOUT de `ps -ef`</li><li>`grep toto /tmp/file1` : retourne les lignes du fichier `/tmp/file1` qui contient le mot "toto"</li><li>`grep -nri toto` : la p'tite killer feature. Cherche, à partir du répertoire courant, dans tous les répertoires et sous-répertoires, un mot donné ; la commande retourne alors la liste des fichiers où apparaît le mot, ainsi que la ligne ou apparaît le mot.</li></ul>
| `cut` | Coupe un texte. Très souvent utilisé avec les options `-d` et `-f` | `cat /etc/passwd \| cut -d':' -f7` : affiche le contenu du fichier `/etc/passwd`, puis découpe le fichier au niveau du caractère `:` c'est le delimiter et récupère le 7ème champ (dans le fichier `/etc/passwd`, le 7ème champ c'est les shells de login :) ) |
| `sort` | Trie un texte | `cat /etc/passwd \| sort` : trie le contenu du fichier `/etc/passwd` par ordre alphabétique |
| `uniq` | Enlève les occurrences multiples d'un texte. Très souvent utilisé de concert avec `sort`. | `cat /etc/passwd \| cut -d':' -f7 \| sort \| uniq` : liste les shells par défaut de tous les utilisateurs, les trie par ordre alphabétique, puis enlève les doublons (cela ressort donc une liste exhaustive des shells qui sont utilisés comme shell par défaut sur la machine)

# `vim`

`vim` est un éditeur de texte extrêmement puissant et modulaire (des tonnes de plugins sont dispos sur l'internet).

Ici sont présentés certains raccourcis ou tricks `vim` très utiles.

> Vous pouvez aussi utiliser `emacs`. Un conseil : évitez `nano`.

| Raccourci/Commande | Description                                                                                                        |
|--------------------|--------------------------------------------------------------------------------------------------------------------|
| `i`                | Passer en mode `INSERT`                                                                                            |
| `A`                | Passer en mode `INSERT` à la fin de la ligne actuelle                                                              |
| `o`                | Insère une ligne vide sous la ligne actuelle du curseur et passe en mode `INSERT` sur cette nouvelle ligne         |
| `O`                | Insère une ligne vide au dessus de la ligne actuelle du curseur et passe en mode `INSERT` sur cette nouvelle ligne |
| `dd`               | Supprime la ligne actuelle du curseur (et la place dans le presse-papier)                                          |
| `dw`               | Supprime le mot sous le curseur (et le place dans le presse-papier)                                                |
| `x`                | Supprime le caractère sous le curseur (et le place dans le presse-papier)                                          |
| `D`                | Supprime tout du curseur jusqu'à la fin de la ligne actuelle                                                       |
| `yy`               | Place la ligne actuelle du curseur dans le presse-papier                                                           |
| `p`                | Colle le contenu du presse-papier                                                                                  |
| `gg`               | Aller au début du fichier                                                                                          |
| `G`                | Aller à la fin du fichier                                                                                          |
| `:q`               | Quitte `vim`                                                                                                       |
| `:w`               | Sauvegarde le fichier                                                                                              |
| `:q!`              | Force à quitter `vim` (par exemple pour quitter sans sauvegarder)                                                  |

# Inspecter le système

## Réseau

| Commande | Description                                                            | Exemple(s)                       |
|----------|------------------------------------------------------------------------|----------------------------------|
| `ip a`   | Liste les cartes réseau de la machine et des infos qui leur sont liées | `ip a` pour `ip address`         |
| `ip n s` | Affiche la table ARP (= affiche les voisins)                           | `ip n s` pour `ip neighbor show` |
| `ip r s` | Affiche la table de routage                                            | `ip r s` pour `ip route show`    |
| `ss` | Affiche les *sockets* utilisés par la machine | `sudo ss -alnpt` : liste tous les ports TCP en écoute sur la machine
| `dig` | Effectue des requêtes DNS | <ul><li>`dig google.com` : demande au système de résoudre le nom `google.com` à l'aide du serveur DNS paramétré par défaut</li><li>`dig google.com @8.8.8.8` : demande au serveur DNS `8.8.8.8` une résolution du nom `google.com` </li></ul> |
| `curl` et `wget` | Effectue des requêtes HTTP. `curl` est beaucoup plus puissant et flexible que `wget` | <ul><li>`wget google.com/index.html` : télécharge le fichier `index.html` qui se trouve à l'adresse `google.com/index.html` </li><li>`curl -SLO google.com/index.html` a le même effet que le `wget` précédent</li><li>`curl` permet aussi d'envoyer facilment des POST, UPDATE, DELETE, etc. Ou encore du contenu JSON, XML, etc. Il peut tout faire qui soit lié au protocole HTTP :) </li></ul> |

## Stockage et RAM

| Commande | Description                                                                 | Exemle(s)                                                                                                                                                                       |
|----------|-----------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `lsblk`  | Liste les périphérique de type bloc (= périphérique de stockage) du système | `lsblk`                                                                                                                                                                         |
| `mount`  | Gère des points de montage                                                  | <ul><li>`mount` : affiche tous les points de montage actifs du système</li><li>`mount /dev/sda2 /mnt/toto` : monte la partition `/dev/sda2` sur le point de montage `/mnt/toto` |
| `df`     | Affiche l'espace disque disponible, par partition                           | `df -h` : affiche l'espace disque disponible, dans un format human-readable                                                                                                     |
| `du`     | Affiche l'espace utilisé par un fichier donné                               | `du -h /tmp/toto` : affiche l'espace utilisé par le fichier `/tmp/toto` dans un format human-readable                                                                           |
| `free`   | Affiche l'état de la RAM                                                    | `free -mh` : affiche l'état de la RAM dans un format human-readable                                                                                                             |

## Gestion de processus

### Théorie

**Exécuter une commande revient à lancer un processus. Un processus est une tâche en cours d'exécution sur le système.**

Tout processus porte un identifiant unique : son PID. 

Tout processus a forcément un processus père. Le père de tous les processus et le processus qui porte le PID 1.

**Il est possible d'interagir avec un processus en cours d'exécution en lui envoyant des signaux.** Il existe un nombre fini de signaux, identifiés par un nom ou un numéro, ayant chacun leur utilité. Notamment :

- `SIGTERM` (15) et `SIGINT` (2) : demande à un processus de quitter proprement (ce signal peut être ignoré par le processus)
- `SIGKILL` (9) : demande au noyau de supprimer le processus (ce signal ne peut PAS être ignoré par le processus)
- `SIGHUP` (1) : demande au processus de recharger sa configuration

> Voir `man 7 signal` pour la liste des signaux et leurs identifiants.

### Commandes

| Commande        | Description                                                                                      | Exemple(s)                                                                                                                                                                    |
|-----------------|--------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ps`            | Liste les processus en cours d'exécution                                                         | `ps -ef` : liste les processus en cours d'exécution sur toute la machine                                                                                                      |
| `top` et `htop` | Ouvre un "gestionnaire des tâches" : liste des processus, utilisation CPU, utilisation RAM, etc. | `htop`                                                                                                                                                                        |
| `kill`          | Envoie un signal à un processus                                                                  | <ul><li>`kill 1337` : envoie SIGTERM au processus portant le PID 1337</li><li>`kill -9 1337` : envoie le signal numéro 9 (SIGKILL) au processus portant le PID 1337</li></ul> |

### Processus en tâche de fond

Flow classique d'une gestion de processus en tâche de fond :

1. `sleep 99991 &` : lance un processus `sleep` en tâche de fond
2. `sleep 99992 &` : lance un deuxième processus `sleep` en tâche de fond
3. `jobs` : affiche la liste des processus en tâche de fond
4. `fg 2` : met au premier plan *(foreground)* le deuxième processus en tâche de fond
5. `CTRL + Z` : envoie le signal SIGSTOP au processus. Il est donc stoppé et remis en arrière-plan
6. `bg 2` : relance le deuxième processus en tâche de fond *(background)*
7. `jobs -p` : liste les PID des processus en tâche de fond
8. `kill $(jobs -p)` : envoie SIGTERM à tous les processus en tâche de fond

# Gestion de logs

**Les logs de la machine sont disponibles dans `/var/log`.** On les consulte avec les outils de manipulation de fichiers habituels : `cd`, `ls`, `cat`, `tail -f`, etc.

Depuis que systemd a été adopté par les distributions majeures, **il est aussi bon de savoir utiliser la commande `journalctl`** qui permet de lister les fichiers journalisés par systemd. Par exemple :

- `journalctl -xe` : affiche tous les logs de la machine dans un pager
- `journalctl -xe -u sshd` : affiche tous les logs relatifs au service `sshd` dans un pager
- `journalctl -xe -u sshd -f` : affiche tous les logs relatifs au service `sshd` dans un pager, et affiche en temps réel les nouveaux logs qui arrivent

Il existe aussi la commande `dmesg` qui permet de lister les logs kernel. Les logs kernel contiennent les infos concernant la découverte des périphérique au boot, des alertes de sécurité, des problèmes de drivers, etc.

# Environnement

Par "environnement" on entend l'ensemble des éléments qui sont spécifiques à chacun des utilisateurs. Par exemple, le répertoire personnel d'un utilisateur fait partie de son environnement.

## Variables d'environnement

Les variables d'environnement sont des variables relatives à une session utilisateur donnée, et uniquement accessible au sein de cette session.

On peut **afficher les variables d'environnement avec la commande `env`** (il est aussi possible d'en ajouter).

Parmi les variables d'environnement importantes, on trouve notamment `$PATH`. Cette variable contient les chemins où on peut trouver des exécutables.  
Elle permet de ne pas faire appel systématiquement au chemin complet des commandes en ne tapant que le nom de la commande.

Par exemple, quand on tape `ls`, en réalité, le binaire `ls` se trouve au path `/bin/ls`. Si le système sait où trouver `ls` c'est parce que le chemin `/bin` est renseigné dans la variable `$PATH`.

On peut afficher le contenu d'une variable d'environnement comme n'importe quelle autre variable. Par exemple :

```bash
$ echo $PATH
/usr/local/bin:/usr/bin:/bin:/usr/local/sbin
```

# Gestion de services

Les services sont gérés par une application appelée systemd. La commande `systemctl` permet d'interagir avec systemd, pour lui demander, par exemple, de démarrer ou éteindre un service. De façon générale, systemd s'occupe du cycle de vie des services, et nous permet de le configurer pour affiner cette gestion.

| Commande                         | Description                                                     | Exemple(s)                                                                                                           |
|----------------------------------|-----------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------|
| `sudo systemctl start NAME`      | Permet de démarrer le service NAME                              | Démarrer le service Apache nommé `httpd` : `sudo systemctl start httpd`                                              |
| `sudo systemctl stop NAME`       | Permet de stopper le service NAME                               | Stopper le service Apache nommé `httpd` : `sudo systemctl stop httpd`                                                |
| `sudo systemctl enable NAME`     | Active le démarrage automatique du service NAME                 | Active le démarrage automatique du service Apache nommé `httpd` : `sudo systemctl enable httpd`                      |
| `sudo systemctl disable NAME`     | Désactive le démarrage automatique du service NAME              | Désactiver le démarrage automatique du service Apache nommé `httpd` : `sudo systemctl disable httpd`                 |
| `sudo systemctl cat NAME`        | Voir le fichier d'unité du service NAME                         | Voir le fichier d'unité du service Apache nommé `httpd` : `sudo systemctl cat httpd`                                 |
| `sudo systemctl is-active NAME`  | Déterminer simplement si le service NAME est actif actuellement | Déterminer simplement si le service Apache nommé `httpd` est actif actuellement : `sudo systemctl is-active httpd`   |
| `sudo systemctl is-enabled NAME` | Déterminer simplement si le service NAME démarre automatiquemnt | Déterminer simplement si le service Apache nommé `httpd` démarre automatiquement : `sudo systemctl is-enabled httpd` |
