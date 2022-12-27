# Partie 4 : Automatiser la résolution du TP

Information :
Les scripts [db.sh](db.sh) et [web.sh](web.sh) peuvent mettre un moment à s'éxecuter. C'est normal il y a des installations pour que tous soit correctament configurées et utilisables pour avoir votre joli base de données ^^.

Etape 1 sur la machine `db.tp5.linux` :

Copier coller le scipt du fichier [db.sh](db.sh) dans un fichier `<nom_de_votre_fichier>`, avec la commande `sudo nano <nom_de_votre_fichier>`
Puis executer le avec `sudo bash <nom_de_votre_fichier>`

Etape 2 sur la machine `web.tp5.linux` :

avec la commande `sudo nano /srv/conf_for_nextcloud` copier coller le script suivant :

```
<VirtualHost *:80>
  # on indique le chemin de notre webroot
  DocumentRoot /var/www/tp5_nextcloud/
  # on précise le nom que saisissent les clients pour accéder au service
  ServerName  web.tp5.linux

  # on définit des règles d'accès sur notre webroot
  <Directory /var/www/tp5_nextcloud/> 
    Require all granted
    AllowOverride All
    Options FollowSymLinks MultiViews
    <IfModule mod_dav.c>
      Dav off
    </IfModule>
  </Directory>
</VirtualHost>
```

Puis copier coller le scipt du fichier [web.sh](web.sh) dans un fichier `<nom_de_votre_fichier>`, avec la commande `sudo nano <nom_de_votre_fichier>`
Puis executer le avec `sudo bash <nom_de_votre_fichier>`

Etape 3 :
aller sur le site avec l'url `http://<votre_ip>` rentrer les informations et c'est fini ^^ (mdp du user nextcloud `pewpewpew`)