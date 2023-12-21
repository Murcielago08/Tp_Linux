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

```
[murci@tp4storage ~]$ cat /etc/exports
/mnt/storage/site_web_1/    192.168.56.5(rw,sync,no_subtree_check)
/mnt/storage/site_web_2/    192.168.56.5(rw,sync,no_root_squash,no_subtree_check)

[murci@tp4storage ~]$ sudo systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/usr/lib/systemd/system/nfs-server.service; enabled; v>
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Tue 2022-12-06 15:07:25 CET; 39min ago
   Main PID: 11302 (code=exited, status=0/SUCCESS)
        CPU: 18ms

Dec 06 15:07:25 tp4storage systemd[1]: Starting NFS server and services...
Dec 06 15:07:25 tp4storage exportfs[11283]: exportfs: /etc/exports:1: unkno>
Dec 06 15:07:25 tp4storage systemd[1]: Finished NFS server and services.

[murci@tp4storage ~]$ sudo firewall-cmd --permanent --list-all | grep services
  services: cockpit dhcpv6-client mountd nfs rpc-bind ssh


```

🌞 **Donnez les commandes réalisées sur le client NFS `web.tp4.linux`**

- contenu du fichier `/etc/fstab` dans le compte-rendu notamment

```
[murci@tp4web ~]$ df -h
Filesystem                            Size  Used Avail Use% Mounted on
devtmpfs                              462M     0  462M   0% /dev
tmpfs                                 481M     0  481M   0% /dev/shm
tmpfs                                 193M  5.2M  187M   3% /run
/dev/mapper/rl-root                   6.2G  1.2G  5.1G  18% /
/dev/sda1                            1014M  210M  805M  21% /boot
tmpfs                                  97M     0   97M   0% /run/user/1000
192.168.56.4:/mnt/storage/site_web_2  2.0G     0  1.9G   0% /var/www/site_web_2
192.168.56.4:/mnt/storage/site_web_1  2.0G     0  1.9G   0% /var/www/site_web_1

[murci@tp4web ~]$ cat /etc/fstab
[...]
192.168.56.4:/mnt/storage/site_web_1    /var/www/site_web_1     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
192.168.56.4:/mnt/storage/site_web_2    /var/www/site_web_2     nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
```


**[the part 3](Rendu_Tp4_part_3.md)**