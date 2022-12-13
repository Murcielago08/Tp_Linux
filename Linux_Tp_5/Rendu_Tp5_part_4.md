# Partie 4 : Automatiser la résolution du TP

Cette dernière partie fait le pont entre le TP scripting, et ce TP-ci qui est l'installation de NextCloud.

L'idée de cette partie 4 est simple : **écrire un script `bash` qui automatise la résolution de ce TP 5**.

Autrement dit, vous devez avoir un script qui :

- **déroule les éléments de la checklist** qui sont automatisables
  - désactiver SELinux
  - donner un nom à chaque machine
- **MariaDB** sur une machine
  - install
  - conf
  - lancement
  - préparation d'une base et d'un user que NextCloud utilisera
- **Apache** sur une autre
  - install
  - conf
  - lancement
  - télécharge NextCloud
  - setup NextCloud
- affiche des **logs** que vous jugez pertinents pour montrer que le script s'exécute correctement
- affiche, une fois terminé, **une phrase de succès** comme quoi tout a bien été déployé

# Tips & Tricks

Quelques tips pour la résolution du TP :

➜ vos scripts ne doivent contenir **AUCUNE** commande `sudo`

➜ utilisez des **variables** au plus possible pour 

- évitez de ré-écrire des choses plusieurs fois
- augmentez le niveau de clarté de votre script

➜ usez et abusez des **commentaires** pour les lignes complexes

➜ `mysql_secure_installation` effectue des configurations que vous pouvez reproduire à la main

➜ pour **les fichiers de conf**

- ne faites pas des `echo 'giga string super longue' > ficher.conf`
- mais plutôt **un simple `cp`** qui copie un fichier que vous avez préparé à l'avance

➜ usez et abusez du **code retour des commandes** pour **vérifier que votre script d'exécute correctement**

➜ utilisez **la commande `exit`** pour quitter l'exécution du script en cas de problème

➜ si vous **avez besoin d'un fichier ou dossier** spécifique pendant l'exécution du script, **votre script doit tester qu'il existe**