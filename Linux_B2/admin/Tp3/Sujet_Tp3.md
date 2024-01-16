# TP3 Admin : Vagrant

Vagrant est un outil qui permet de créer des VMs automatiquement. Finis les clics partout dans l'interface de VirtualBox :D

Dans ce TP on va **découvrir Vagrant**

- un outil pour créer des VMs automatiquement
- idéal pour créer des environnements virtuels temporaires
- et aussi/surtout des environnements reproductibles !
- le tout, de manière programmatique (avec du code quoi)
- rapide de créer 3 VMs préconfigurées, rapide de les détruire et refaire, pratique quoi !

C'est un outil qui est utilisé pour faire des labs locaux, des POC, tester des trucs quoi ! Mais sur votre PC. C'est pas un outil qu'on utilise en milieu pro pour vraiment créer des VMs.

En milieu pro on utilise des outils très similaires, qui font à peu près la même chose, mais c'est juste qu'on utilise pas VirtualBox en prod quoi n_n

## Sommaire

- [TP3 Admin : Vagrant](#tp3-admin--vagrant)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
  - [Sommaire](#sommaire-1)
  - [0. Intro blabla](#0-intro-blabla)
  - [1. Une première VM](#1-une-première-vm)
  - [2. Repackaging](#2-repackaging)
  - [3. Moult VMs](#3-moult-vms)

# 0. Setup

➜ **Installez Vagrant sur votre PC**

- en suivant la doc officielle
- je vous file pas le lien cette fois, vous la chercheeeez meow

➜ **VirtualBox** ou autre hyperviseur supporté par Vagrant

## Sommaire

- [TP3 Admin : Vagrant](#tp3-admin--vagrant)
  - [Sommaire](#sommaire)
- [0. Setup](#0-setup)
  - [Sommaire](#sommaire-1)
  - [0. Intro blabla](#0-intro-blabla)
  - [1. Une première VM](#1-une-première-vm)
  - [2. Repackaging](#2-repackaging)
  - [3. Moult VMs](#3-moult-vms)

## 0. Intro blabla

Vagrant est une surcouche à votre hyperviseur, il le pilote à votre place. Genre il utilise VirtualBox à ta place pour créer des VMs.

Une fois téléchargé, Vagrant s'utilise de la manière qui suit :

- on crée un fichier `Vagrantfile`
  - le nom est standard (avec la majuscule)
  - le contenu, c'est du Ruby un peu custom
  - on définit des VMs avec une syntaxe standard
- puis, depuis un terminal
  - on se déplace dans le dossier qui contient le `Vagrantfile`
  - et on utilise `vagrant up` pour allumer les VMs définies dans le `Vagrantfile`

**Nice & easy.**

Les bénéfices sont multiples :

- **c'est cross-platform**
- **créer une VM ou 10 VMs, c'est (presque) pareil**
  - on fait une boucle `for` dans le `Vagrantfile` et let's go
  - on peut même faire des bails genre se servir d'une variable qui s'incrémente à chaque itération de la boucle pour définir des IPs qui s'incrémentent pour chaque VM
- **Vagrant fournit ce qu'il faut pour facilement...**
  - définir des IP aux VMs
  - choisir si elles ont une carte NAT ou non
  - partager un dossier entre l'hôte et la VM
  - lancer automatiquement un script au premier boot de la VM
  - définir des paramètres élémentaires sur la conf de la VM (CPU, RAM, disque, etc)
  - allumer toutes les VMs, les stopper, les détruire, les relancer
  - et même SSH dans les VMs c'est fourni !
- **ça supporte plusieurs hyperviseurs courants**
  - notamme Hyper-V, VirtualBox, Workstation
- **c'est un fichier texte le Vagrantfile, c'est du code !**
  - donc la définition de nos VMs tient dans un fichier de quelques Ko
  - facile à partager
  - on le met dans un dépôt git pour le versionneré évidemment ! C'est du code !
- vos premiers pas dans l'infrastructure-as-code (iac)

## 1. Une première VM

> Avant de continuez, assurez-vous d'avoir téléchargé Vagrant sur votre PC en suivant la doc officielle.

Les mecs/meufs/non-binaires de chez HashiCorp (les gens qui dév Vagrant) hébergent un site web : le [Vagrant Cloud](https://app.vagrantup.com/boxes/search).

C'est un site qui héberge et répertorie des *Boxes Vagrant*. Une ***box Vagrant*** c'est juste une image d'une VM packagée au format que Vagrant attend. A partir d'une *box* on peut instancier plusieurs VMs.

> Par exemple, [il existe cette box](https://app.vagrantup.com/generic/boxes/ubuntu2204) qui semble être une box pour lancer un Ubuntu 22.04.

🌞 **Générer un `Vagrantfile`**

- vous bosserez avec cet OS pour le restant du TP
- vous pouvez générer une `Vagrantfile` fonctionnel pour une box donnée avec les commandes :

```bash
# création d'un répertoire de travail
$ mkdir ~/work/vagrant/test
$ cd ~/work/vagrant/test

# génération du Vagrantfile
$ vagrant init <NOM_DE_LA_BOX>

# on peut constater d'un Vagrantfile a été créé
$ ls
Vagrantfile
$ cat Vagrantfile
[...]
```

🌞 **Modifier le `Vagrantfile`**

- les lignes qui suivent doivent être ajouter dans le bloc où l'objet `config` est défini
- ajouter les lignes suivantes :

```ruby
# Désactive les updates auto qui peuvent ralentir le lancement de la machine
config.vm.box_check_update = false 

# La ligne suivante permet de désactiver le montage d'un dossier partagé (ne marche pas tout le temps directement suivant vos OS, versions d'OS, etc.)
config.vm.synced_folder ".", "/vagrant", disabled: true
```

🌞 **Faire joujou avec une VM**

```bash
# on peut allumer tout de suite une VM issue de cette box, le Vagrantfile est censé être fonctionnel
$ vagrant up

# une fois la VM allumée...
$ vagrant status
$ vagrant ssh


# on peut éteindre la VM avec
$ vagrant halt

# et la détruire avec
$ vagrant destroy -f
```

> Je vous conseille **vivement** d'avoir l'interface de VirtualBox ouverte en même temps pour voir ce que Vagrant fait. Pour mieux capter :)

![Vagrant up](./img/vagrantup.png)

## 2. Repackaging

Il est possible de repackager une *box* Vagrant, c'est à dire de prendre une VM existante, et d'en faire une nouvelle *box*. On peut ainsi faire une box qui contient notre configuration préférée.

Le flow typique :

- on allume une VM avec Vagrant
- on se connecte à la VM et on fait de la conf
- on package la VM en une box Vagrant
- on peut instancier des nouvelles VMs à partir de cette box
- ces nouvelles VMs contiendront tout de suite notre conf

🌞 **Repackager la box que vous avez choisie**

- elle doit :
  - être à jour
  - disposer des commandes `vim`, `ip`, `dig`, `ss`, `nc`
  - avoir un firewall actif
  - SELinux (systèmes RedHat) et/ou AppArmor (plutôt sur Ubuntu) désactivés
- pour repackager une box, vous pouvez utiliser les commandes suivantes :

```bash
# On convertit la VM en un fichier .box sur le disque
# Le fichier est créé dans le répertoire courant si on ne précise pas un chemin explicitement
$ vagrant package --output super_box.box

# On ajoute le fichier .box à la liste des box que gère Vagrant
$ vagrant box add super_box super_box.box

# On devrait voir la nouvelle box dans la liste locale des boxes de Vagrant
$ vagrant box list
```

🌞 **Ecrivez un `Vagrantfile` qui lance une VM à partir de votre Box**

- et testez que ça fonctionne !

## 3. Moult VMs

Pour cette partie, je vous laisse chercher des ressources sur Internet pour les syntaxes. Internet regorge de `Vagrantfile` d'exemple, hésitez po à m'appeler si besoin !

🌞 **Adaptez votre `Vagrantfile`** pour qu'il lance les VMs suivantes (en réutilisant votre box de la partie précédente)

- vous devez utiliser une boucle for dans le `Vagrantfile`
- pas le droit de juste copier coller le même bloc trois fois, une boucle for j'ai dit !

| Name           | IP locale   | Accès internet | RAM |
| -------------- | ----------- | -------------- | --- |
| `node1.tp3.b2` | `10.3.1.11` | Ui             | 1G  |
| `node2.tp3.b2` | `10.3.1.12` | Ui             | 1G  |
| `node3.tp3.b2` | `10.3.1.13` | Ui             | 1G  |

📁 **`partie1/Vagrantfile-3A`** dans le dépôt git de rendu

🌞 **Adaptez votre `Vagrantfile`** pour qu'il lance les VMs suivantes (en réutilisant votre box de la partie précédente)

- l'idéal c'est de déclarer une liste en début de fichier qui contient les données des VMs et de faire un `for` sur cette liste
- à vous de voir, sans boucle `for` et sans liste, juste trois blocs déclarés, ça fonctionne aussi

| Name           | IP locale    | Accès internet | RAM |
| -------------- | ------------ | -------------- | --- |
| `alice.tp3.b2` | `10.3.1.11`  | Ui             | 1G  |
| `bob.tp3.b2`   | `10.3.1.200` | Ui             | 2G  |
| `eve.tp3.b2`   | `10.3.1.57`  | Nan            | 1G  |

📁 **`partie1/Vagrantfile-3B`** dans le dépôt git de rendu

> *La syntaxe Ruby c'est vraiment dégueulasse.*