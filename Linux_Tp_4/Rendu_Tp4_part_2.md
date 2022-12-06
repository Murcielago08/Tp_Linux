# Partie 2 : Serveur de partage de fichiers

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


**[the part 3](Rendu_Tp4_part_3.md)**