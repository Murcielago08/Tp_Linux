# Module 2 : Sauvegarde du système de fichiers

## Sommaire

- [Module 2 : Sauvegarde du système de fichiers](#module-2--sauvegarde-du-système-de-fichiers)
  - [Sommaire](#sommaire)
  - [I. Script de backup](#i-script-de-backup)
    - [1. Ecriture du script](#1-ecriture-du-script)
    - [2. Service et timer](#2-service-et-timer)
  - [II. NFS](#ii-nfs)
    - [1. Serveur NFS](#1-serveur-nfs)
    - [2. Client NFS](#2-client-nfs)

## I. Script de backup

Partie à réaliser sur `web.tp6.linux`.

### 1. Ecriture du script

🌞 **Ecrire le script `bash`**

- il s'appellera `tp6_backup.sh`

[tp6_backup.sh ^^](tp6_backup.sh)

➜ **Environnement d'exécution du script**

- créez un utilisateur sur la machine `web.tp6.linux`

```
[murci@tp5web ~]$ sudo useradd backup -d /srv/backup/ -s /usr/bin/nologin
```

### 2. Service et timer

🌞 **Créez un *service*** système qui lance le script

```
[murci@tp5web ~]$ sudo cat /etc/systemd/system/backup.service
[Unit]
Description=Service de sauvegarde des fichiers du système nextcloud ^^

[Service]
ExecStart=/srv/tp6_backup.sh
User=backup
Type=oneshot

[Install]
WantedBy=multi-user.target
```

```
[murci@tp5web ~]$ sudo systemctl status backup
○ backup.service - Service de sauvegarde des fichiers du système nextcloud ^^
     Loaded: loaded (/etc/systemd/system/backup.service; disabled; vendor preset: disabled)
     Active: inactive (dead)

Jan 30 14:48:24 tp5web systemd[1]: backup.service: Deactivated successfully.
Jan 30 14:48:24 tp5web systemd[1]: Finished Service de sauvegarde des fichiers du système nextcloud ^^.
```

🌞 **Créez un *timer*** système qui lance le *service* à intervalles réguliers

```
[murci@tp5web ~]$ sudo cat /etc/systemd/system/backup.timer
[Unit]
Description=Run service backup

[Timer]
OnCalendar=*-*-* 4:00:00

[Install]
WantedBy=timers.target
```

🌞 Activez l'utilisation du *timer*

- vous vous servirez des commandes suivantes :

```
[murci@tp5web ~]$ sudo systemctl start backup.timer

[murci@tp5web ~]$ sudo systemctl enable backup.timer
Created symlink /etc/systemd/system/timers.target.wants/backup.timer → /etc/systemd/system/backup.timer.

[murci@tp5web ~]$ sudo systemctl status backup.timer
● backup.timer - Run service backup
     Loaded: loaded (/etc/systemd/system/backup.timer; enabled; vendor preset: di>
     Active: active (waiting) since Mon 2023-01-30 14:58:07 CET; 18s ago
      Until: Mon 2023-01-30 14:58:07 CET; 18s ago
    Trigger: Tue 2023-01-31 04:00:00 CET; 13h left
   Triggers: ● backup.service

Jan 30 14:58:07 tp5web systemd[1]: Started Run service backup.

[murci@tp5web ~]$ sudo systemctl list-timers | grep backup
Tue 2023-01-31 04:00:00 CET 13h left     n/a                         n/a
backup.timer                 backup.service
```

## II. NFS

### 1. Serveur NFS

> On a déjà fait ça au TP4 ensemble :)

🖥️ **VM `storage.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](../../2/README.md#checklist).**

🌞 **Préparer un dossier à partager sur le réseau** (sur la machine `storage.tp6.linux`)

- créer un dossier `/srv/nfs_shares`
- créer un sous-dossier `/srv/nfs_shares/web.tp6.linux/`

```
[murci@tp6storage ~]$ sudo mkdir -p /srv/nfs_shares/web.tp6.linux

[murci@tp6storage ~]$ sudo chown nobody /srv/nfs_shares/web.tp6.linux/

[murci@tp6storage ~]$ sudo chown nobody /srv/nfs_shares/

[murci@tp6storage ~]$ ls -al /srv
total 0
drwxr-xr-x.  3 root   root  24 Jan 30 15:54 .
dr-xr-xr-x. 18 root   root 235 Oct 10 15:11 ..
drwxr-xr-x.  3 nobody root  27 Jan 30 15:54 nfs_shares
```

🌞 **Installer le serveur NFS** (sur la machine `storage.tp6.linux`)

- installer le paquet `nfs-utils`

```
[murci@tp6storage ~]$ sudo dnf install nfs-utils
```

- créer le fichier `/etc/exports`

```
[murci@tp6storage ~]$ sudo cat /etc/exports
/srv/nfs_shares/web.tp5.linux 10.105.1.11(rw,sync,no_subtree_check)
```

- ouvrir les ports firewall nécessaires

```
[murci@tp6storage ~]$ sudo firewall-cmd --permanent --add-service=nfs
success

[murci@tp6storage ~]$ sudo firewall-cmd --permanent --add-service=mountd
success

[murci@tp6storage ~]$ sudo firewall-cmd --permanent --add-service=rpc-bind
success

[murci@tp6storage ~]$ sudo firewall-cmd --reload
success

[murci@tp6storage ~]$ sudo firewall-cmd --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh
```

- démarrer le service

```
[murci@tp6storage ~]$ sudo systemctl enable nfs-server
Created symlink /etc/systemd/system/multi-user.target.wants/nfs-server.service → /usr/lib/systemd/system/nfs-server.service.

[murci@tp6storage ~]$ sudo systemctl start nfs-server

[murci@tp6storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; v>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Mon 2023-01-30 17:26:10 CET; 3s ago
    Process: 11566 ExecStartPre=/usr/sbin/exportfs -r (code=exited, status=>
    Process: 11567 ExecStart=/usr/sbin/rpc.nfsd (code=exited, status=0/SUCC>
    Process: 11585 ExecStart=/bin/sh -c if systemctl -q is-active gssproxy;>
   Main PID: 11585 (code=exited, status=0/SUCCESS)
        CPU: 17ms

Jan 30 17:26:10 tp6storage systemd[1]: Starting NFS server and services...
Jan 30 17:26:10 tp6storage exportfs[11566]: exportfs: Failed to stat /srv/n>
Jan 30 17:26:10 tp6storage systemd[1]: Finished NFS server and services.
```

### 2. Client NFS

🌞 **Installer un client NFS sur `web.tp6.linux`**

```
[murci@tp5web ~]$ sudo mount 10.105.1.14:/srv/nfs_shares/web.tp6.linux /srv/backup

[murci@tp5web ~]$ df -h | grep 10.105.1.14
10.105.1.14:/srv/nfs_shares/web.tp6.linux  6.2G  1.3G  4.9G  21% /srv/backup
```

🌞 **Tester la restauration des données** sinon ça sert à rien :)

- livrez-moi la suite de commande que vous utiliseriez pour restaurer les données dans une version antérieure

```
# déziper le dossier .zip ^^
unzip /srv/backup/nextcloud_yyyywwddhhmmss.zip

# copie les dossiers de backup dans les dossiers nextcloud ^^
cp -a /srv/backup/config/. /var/www/tp6_nextcloud/config/
cp -a /srv/backup/data/. /var/www/tp6_nextcloud/data/
cp -a /srv/backup/themes/. /var/www/tp6_nextcloud/themes/

# suppression puis création de la base de données comme avant ^^
mysql -h 10.105.1.12 -u nextcloud -p'pewpewpew' -e "DROP DATABASE nextcloud"
mysql -h 10.105.1.12 -u nextcloud -p'pewpewpew' -e "CREATE DATABASE nextcloud"
mysql -h 10.105.1.12 -u nextcloud -p'pewpewpew' nextcloud < nextcloud-db_yyyymmddhhmmss.bak
```