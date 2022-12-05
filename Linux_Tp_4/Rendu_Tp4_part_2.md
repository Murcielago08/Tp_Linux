# Partie 2 : Serveur de partage de fichiers

**Dans cette partie, le but sera de monter un serveur de stockage.** Un serveur de stockage, ici, désigne simplement un serveur qui partagera un dossier ou plusieurs aux autres machines de son réseau.

Ce dossier sera hébergé sur la partition dédiée sur la machine **`storage.tp4.linux`**.

Afin de partager le dossier, **nous allons mettre en place un serveur NFS** (pour Network File System), qui est prévu à cet effet. Comme d'habitude : c'est un programme qui écoute sur un port, et les clients qui s'y connectent avec un programme client adapté peuvent accéder à un ou plusieurs dossiers partagés.

Le **serveur NFS** sera **`storage.tp4.linux`** et le **client NFS** sera **`web.tp4.linux`**.

L'objectif :

- avoir deux dossiers sur **`storage.tp4.linux`** partagés
  - `/storage/site_web_1/`
  - `/storage/site_web_2/`
- la machine **`web.tp4.linux`** monte ces deux dossiers à travers le réseau
  - le dossier `/storage/site_web_1/` est monté dans `/var/www/site_web_1/`
  - le dossier `/storage/site_web_2/` est monté dans `/var/www/site_web_2/`

🌞 **Donnez les commandes réalisées sur le serveur NFS `storage.tp4.linux`**

- contenu du fichier `/etc/exports` dans le compte-rendu notamment

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

> Je vous laisse vous inspirer de docs sur internet **[comme celle-ci](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-rocky-linux-9)** pour mettre en place un serveur NFS.

**Ok, on a fini avec la partie 2, let's head to [the part 3](./../part3/README.md).**