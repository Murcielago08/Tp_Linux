# TP4 : Vers une maîtrise des OS Linux

Cette deuxième partie a donc pour but de vous (re)montrer **des techniques d'administration classique** :

- partitionnement
- gestion de users
- gestion du temps
- je vous épargne la gestion de services cette fois hehe

![Systemd breaks](./img/systemd.jpg)

## Sommaire

- [TP4 : Vers une maîtrise des OS Linux](#tp4--vers-une-maîtrise-des-os-linux)
  - [Sommaire](#sommaire)
- [I. Partitionnement](#i-partitionnement)
  - [1. LVM dès l'installation](#1-lvm-dès-linstallation)
  - [2. Scénario remplissage de partition](#2-scénario-remplissage-de-partition)
- [II. Gestion de users](#ii-gestion-de-users)
- [III. Gestion du temps](#iii-gestion-du-temps)

# I. Partitionnement

> *Pas de Vagrant possible ici, déso !*

Pour le coup ça l'est, ou ça doit le devenir : **élémentaire**. Concrètement dans cette section on va gérer des partitions dans un premier temps, pour ensuite gérer des users et faire une conf `sudo` maîtrisée.

Je vous ai remis [le cours sur le partitionnement de l'an dernier](../../../cours/partition/README.md) dans ce dépôt, et [le mémo LVM](../../../cours/memo/lvm.md).

## 1. LVM dès l'installation

🌞 **Faites une install manuelle de Rocky Linux**

- ouais vous refaites l'install depuis l'iso
- mais cette fois, vous gérez le partitionnement vous-mêmes
- c'est en GUI à l'install, profitez-en hehe
- **tout doit être partitionné avec LVM** (partitionnement logique)
- **donnez à votre VM un disque de 40G**
  - je rappelle qu'avec des disques virtuels "dynamiques" l'espace n'est pas consommé sur votre machine tant que la VM ne l'utilise pas
- je veux le schéma de partition suivant :

| Point de montage | Taille       | FS    |
| ---------------- | ------------ | ----- |
| /                | 10G          | ext4  |
| /home            | 5G           | ext4  |
| /var             | 5G           | ext4  |
| swap             | 1G           | swap  |
| espace libre     | ce qui reste | aucun |

> On sépare les données des applications (`/var`), ~~les pouvelles~~ les répertoires personnels des utilisateurs (`/home`) du reste du système (tout le reste est contenu dans `/`). systemd s'occupera de deux trois trucs en plus, comme séparer la partition `/tmp` pour qu'elle existe en RAM (truc2fou).

➜ Une fois installée, faites le tour du propriétaire :

```bash
# lister les périphériques de type bloc = les disque durs, clés usb et autres trucs
[joris@LinuxTp4B2 ~]$ lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda           8:0    0   20G  0 disk
├─sda1        8:1    0    1G  0 part /boot
└─sda2        8:2    0   17G  0 part
  ├─rl-root 253:0    0   10G  0 lvm  /
  ├─rl-swap 253:1    0    1G  0 lvm  [SWAP]
  ├─rl-var  253:2    0    3G  0 lvm  /var
  └─rl-home 253:3    0    3G  0 lvm  /home
sr0          11:0    1 1024M  0 rom

# montre l'espace dispo sur les partitions montées actuellement
[joris@LinuxTp4B2 ~]$   
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             868M     0  868M   0% /dev
tmpfs                888M     0  888M   0% /dev/shm
tmpfs                356M  5.0M  351M   2% /run
/dev/mapper/rl-root  9.8G  855M  8.4G  10% /
/dev/sda1           1014M  197M  818M  20% /boot
/dev/mapper/rl-var   2.9G   87M  2.7G   4% /var
/dev/mapper/rl-home  2.9G   44K  2.8G   1% /home
tmpfs                178M     0  178M   0% /run/user/1000

# interagir avec les LVM
## voir les physical volumes
[joris@LinuxTp4B2 ~]$ sudo pvs # short
  PV         VG Fmt  Attr PSize  PFree
  /dev/sda2  rl lvm2 a--  17.00g 4.00m
[joris@LinuxTp4B2 ~]$ sudo pvdisplay # beaucoup d'infos

  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               rl
  PV Size               <17.01 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              4353
  Free PE               1
  Allocated PE          4352
  PV UUID               5e4e2t-8OOa-UYOB-Jajs-CS47-Gzth-FT7afB 
  
## voir les volume groups
[joris@LinuxTp4B2 ~]$ sudo vgs
  VG #PV #LV #SN Attr   VSize  VFree
  rl   1   4   0 wz--n- 17.00g 4.00m

[joris@LinuxTp4B2 ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               rl
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                4
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               17.00 GiB
  PE Size               4.00 MiB
  Total PE              4353
  Alloc PE / Size       4352 / 17.00 GiB
  Free  PE / Size       1 / 4.00 MiB
  VG UUID               irTe0f-3Hek-CPt1-5eYT-WJR8-bmGE-01cQyC

## et les logical volumes
[joris@LinuxTp4B2 ~]$ sudo lvs
  LV   VG Attr       LSize  Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home rl -wi-ao----  3.00g

  root rl -wi-ao---- 10.00g

  swap rl -wi-ao----  1.00g

  var  rl -wi-ao----  3.00g

[joris@LinuxTp4B2 ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/rl/var
  LV Name                var
  VG Name                rl
  LV UUID                ky1cle-R7uZ-CDfl-juSd-1CAA-UOlr-7OiXrx
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-19 09:48:45 +0100
  LV Status              available
  # open                 1
  LV Size                3.00 GiB
  Current LE             768
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:2

  --- Logical volume ---
  LV Path                /dev/rl/root
  LV Name                root
  VG Name                rl
  LV UUID                MPylBn-6rlg-b0o9-Uu62-AcFW-ttJo-Pj6xEW
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-19 09:48:46 +0100
  LV Status              available
  # open                 1
  LV Size                10.00 GiB
  Current LE             2560
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:0

  --- Logical volume ---
  LV Path                /dev/rl/home
  LV Name                home
  VG Name                rl
  LV UUID                8Cp0qC-3GDk-D4cD-u84q-u1cX-TAsb-2GFOwf
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-19 09:48:46 +0100
  LV Status              available
  # open                 1
  LV Size                3.00 GiB
  Current LE             768
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:3

  --- Logical volume ---
  LV Path                /dev/rl/swap
  LV Name                swap
  VG Name                rl
  LV UUID                fxWHVM-c1Ts-X0ED-yUMW-TuW6-ifrx-2u7nzQ
  LV Write Access        read/write
  LV Creation host, time localhost.localdomain, 2024-01-19 09:48:47 +0100
  LV Status              available
  # open                 2
  LV Size                1.00 GiB
  Current LE             256
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:1
```

## 2. Scénario remplissage de partition

🌞 **Remplissez votre partition `/home`**

- on va simuler avec un truc bourrin :

```
[joris@LinuxTp4B2 ~]$ dd if=/dev/zero of=/home/<TON_USER>/bigfile bs=4M count=5000
-bash: TON_USER: No such file or directory
[joris@LinuxTp4B2 ~]$ dd if=/dev/zero of=/home/joris/bigfile bs=4M count=500
0
dd: error writing '/home/joris/bigfile': No space left on device
696+0 records in
695+0 records out
2916241408 bytes (2.9 GB, 2.7 GiB) copied, 11.5074 s, 253 MB/s
```

> 5000x4M ça fait 40G. Ca fait trop.

🌞 **Constater que la partition est pleine**

- avec un `df -h`

```bash
[joris@LinuxTp4B2 ~]$ df -h | grep home
/dev/mapper/rl-home  2.9G  2.8G     0 100% /home
```

🌞 **Agrandir la partition**

- avec des commandes LVM il faut agrandir le logical volume

```bash
[joris@LinuxTp4B2 ~]$ sudo lvextend -l +100%FREE /dev/rl/home
  Size of logical volume rl/home changed from 3.00 GiB (768 extents) to 3.00 GiB (769 extents).
```

- ensuite il faudra indiquer au système de fichier ext4 que la partition a été agrandie

```bash
[joris@LinuxTp4B2 ~]$ df -h
Filesystem           Size  Used Avail Use% Mounted on
devtmpfs             868M     0  868M   0% /dev
tmpfs                888M     0  888M   0% /dev/shm
tmpfs                356M  5.0M  351M   2% /run
/dev/mapper/rl-root  9.8G  855M  8.4G  10% /
/dev/sda1           1014M  197M  818M  20% /boot
/dev/mapper/rl-var   2.9G   88M  2.7G   4% /var
/dev/mapper/rl-home  2.9G  2.8G  1.9M 100% /home
tmpfs                178M     0  178M   0% /run/user/1000
```

- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

```bash
[joris@LinuxTp4B2 ~]$ df -h | grep home
/dev/mapper/rl-home  2.9G  2.8G  1.9M 100% /home
```

🌞 **Remplissez votre partition `/home`**

- on va simuler encore avec un truc bourrin :

```bash
[joris@LinuxTp4B2 ~]$ dd if=/dev/zero of=/home/joris/bigfile bs=4M count=500
0
dd: error writing '/home/joris/bigfile': No space left on device
696+0 records in
695+0 records out
2918166528 bytes (2.9 GB, 2.7 GiB) copied, 5.88068 s, 496 MB/s
```

> 5000x4M ça fait toujours 40G. Et ça fait toujours trop.

➜ **Eteignez la VM et ajoutez lui un disque de 40G**

🌞 **Utiliser ce nouveau disque pour étendre la partition `/home` de 40G**

- dans l'ordre il faut :
- indiquer à LVM qu'il y a un nouveau PV dispo

```bash
[joris@LinuxTp4B2 ~]$ sudo vgcreate disque2 /dev/sdb
  Volume group "disque2" successfully created
  
[joris@LinuxTp4B2 ~]$ sudo pvdisplay
  --- Physical volume ---
  PV Name               /dev/sdb
  VG Name               disque2
  PV Size               40.00 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              10239
  Free PE               10239
  Allocated PE          0
  PV UUID               i0QjXZ-C0g4-3XKt-5yNM-WcBr-2QJ3-cXpn9J

  --- Physical volume ---
  PV Name               /dev/sda2
  VG Name               rl
  PV Size               <17.01 GiB / not usable 4.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              4353
  Free PE               0
  Allocated PE          4353
  PV UUID               5e4e2t-8OOa-UYOB-Jajs-CS47-Gzth-FT7afB  
```

- ajouter ce nouveau PV au VG existant

```bash
[joris@LinuxTp4B2 ~]$ sudo vgdisplay
  --- Volume group ---
  VG Name               disque2
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  1
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                0
  Open LV               0
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <40.00 GiB
  PE Size               4.00 MiB
  Total PE              10239
  Alloc PE / Size       0 / 0
  Free  PE / Size       10239 / <40.00 GiB
  VG UUID               emf9Pp-4WzF-By4p-yV4b-0heO-To1J-Zy5M9f

  --- Volume group ---
  VG Name               rl
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  6
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                4
  Open LV               4
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               17.00 GiB
  PE Size               4.00 MiB
  Total PE              4353
  Alloc PE / Size       4353 / 17.00 GiB
  Free  PE / Size       0 / 0
  VG UUID               irTe0f-3Hek-CPt1-5eYT-WJR8-bmGE-01cQyC
```

- étendre le LV existant pour récupérer le nouvel espace dispo au sein du VG

```bash
[joris@LinuxTp4B2 ~]$ sudo lvcreate -l 100%FREE disque2 -n disque2
  Logical volume "disque2" created.
[joris@LinuxTp4B2 ~]$ sudo lvdisplay
  --- Logical volume ---
  LV Path                /dev/disque2/disque2
  LV Name                disque2
  VG Name                disque2
  LV UUID                ylPat6-b8ti-MpwU-cbn2-u6Q5-rLEJ-hgfEGk
  LV Write Access        read/write
  LV Creation host, time LinuxTp4B2, 2024-01-19 19:20:51 +0100
  LV Status              available
  # open                 0
  LV Size                <40.00 GiB
  Current LE             10239
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     256
  Block device           253:4
```

- indiquer au système de fichier ext4 que la partition a été agrandie

```bash
bloquer ici :/
```

- prouvez avec un `df -h` que vous avez récupéré de l'espace en plus

```bash

```

> Si vous avez assez d'espace libre, et que vous voulez montrer la taille de votre kiki, vous pouvez refaire la commande `dd` et vraiment créer le fichier de 40G.

# II. Gestion de users

Je vous l'ai jamais demandé, alors c'est limite un interlude obligé que j'ai épargné à tout le monde, mais les admins, vous y échapperez pas.

On va faire un petit exercice tout nul de gestion d'utilisateurs.

> *Si t'es si fort, ça prend même pas 2-3 min, alors fais-le :D*

🌞 **Gestion basique de users**

- créez des users en respactant le tableau suivant :

| Name    | Groupe primaire | Groupes secondaires | Password | Homedir         | Shell              |
| ------- | --------------- | ------------------- | -------- | --------------- | ------------------ |
| alice   | alice           | admins              | toto     | `/home/alice`   | `/bin/bash`        |
| bob     | bob             | admins              | toto     | `/home/bob`     | `/bin/bash`        |
| charlie | charlie         | admins              | toto     | `/home/charlie` | `/bin/bash`        |
| eve     | eve             | N/A                 | toto     | `/home/eve`     | `/bin/bash`        |
| backup  | backup          | N/A                 | toto     | `/var/backup`   | `/usr/bin/nologin` |

- prouvez que tout ça est ok avec juste un `cat` du fichier adapté (y'a pas le password dedans bien sûr)

```bash
[joris@LinuxTp4B2 ~]$ cat /etc/passwd | grep -E 'alice|bob|charlie|eve|backup'
eve:x:1001:1004::/home/eve:/bin/bash
backup:x:1002:1005::/var/backup:/usr/bin/nologin
alice:x:1003:1001::/home/alice:/bin/bash
bob:x:1004:1002::/home/bob:/bin/bash
charlie:x:1005:1003::/home/charlie:/bin/bash
```

🌞 **La conf `sudo` doit être la suivante**

| Qui est concerné | Quels droits                                                      | Doit fournir son password |
| ---------------- | ----------------------------------------------------------------- | ------------------------- |
| Groupe admins    | Tous les droits                                                   | Non                       |
| User eve         | Peut utiliser la commande `ls` en tant que l'utilisateur `backup` | Oui                       |

```bash
[joris@LinuxTp4B2 ~]$ sudo -l
User joris may run the following commands on LinuxTp4B2:
    (ALL : ALL) NOPASSWD: ALL

[joris@LinuxTp4B2 ~]$ sudo cat /etc/sudoers

## Allows people in group wheel to run all commands
%wheel  ALL=(ALL) NOPASSWD: ALL

# Exemple pour l'utilisateur eve
eve       ALL=(backup) /bin/ls, PASSWD: /bin/ls
 
```

🌞 **Le dossier `/var/backup`**

- créez-le

```bash
[joris@LinuxTp4B2 ~]$ sudo mkdir /var/backup
```

- choisir des permissions les plus restrictives possibles (comme toujours, la base quoi) sachant que :
  - l'utilisateur `backup` doit pouvoir évoluer normalement dedans

```bash
[joris@LinuxTp4B2 ~]$ sudo chmod 700 /var/backup
```

  - les autres n'ont aucun droit

```bash
[joris@LinuxTp4B2 ~]$ sudo chown backup:backup /var/backup
```

- il contient un fichier `/var/backup/precious_backup`
  - créez-le (contenu vide ou balec)

```bash
[joris@LinuxTp4B2 ~]$ sudo touch /var/backup/precious_backup
```

  - choisir des permissions les plus restrictives possibles sachant que
    - `backup` doit être le seul à pouvoir le lire et le modifier

```bash
[joris@LinuxTp4B2 ~]$ sudo chmod 600 /var/backup/precious_backup
```    
    
    - le groupe `backup` peut uniquement le lire

```bash
[joris@LinuxTp4B2 ~]$ sudo chown backup:backup /var/backup/precious_backup
```

🌞 **Mots de passe des users, prouvez que**

- ils sont hashés en SHA512 (c'est violent)
- ils sont salés (c'est pas une blague si vous connaissez pas le terme, on dit "salted" en anglais aussi)

```bash
[joris@LinuxTp4B2 ~]$ sudo cat /etc/shadow
eve:$1$zj8Jexif$CiCivrjO2a8Sbh0xrt3Tl1:19741:0:99999:7:::
backup:$1$LgFOPsWZ$ZiPVg0y0103t73z1ZepDg1:19741:0:99999:7:::
alice:$1$zgd9dUPb$obTZGh4jk6uWa.JS.q0Gq.:19741:0:99999:7:::
bob:$1$p5FnUWvd$8ZmAk/wZG8P5wGWqrxJ7n/:19741:0:99999:7:::
charlie:$1$bZ01KlXg$A0WFFb0PrY3vUES3D97/K1:19741:0:99999:7:::
```

🌞 **User eve**

- elle ne peut que saisir `sudo ls` et rien d'autres avec `sudo`
- vous pouvez faire `sudo -l` pour voir vos droits `sudo` actuels

```bash
[sudo] password for eve:
Matching Defaults entries for eve on LinuxTp4B2:
    !visiblepw, always_set_home, match_group_by_gid, always_query_group_plugin, env_reset, env_keep="COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS",
    env_keep+="MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE", env_keep+="LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES",
    env_keep+="LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE", env_keep+="LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY",
    secure_path=/sbin\:/bin\:/usr/sbin\:/usr/bin

User eve may run the following commands on LinuxTp4B2:
    (ALL) /bin/ls, PASSWD: /bin/ls

[eve@LinuxTp4B2 ~]$ sudo ls
[eve@LinuxTp4B2 ~]$ sudo ls -al
total 20
drwx------. 2 eve  eve  4096 Jan 25 10:07 .
drwxr-xr-x. 8 root root 4096 Jan 19 20:04 ..
-rw-------. 1 eve  eve     0 Jan 25 10:29 .bash_history
-rw-r--r--. 1 eve  eve    18 May 16  2022 .bash_logout
-rw-r--r--. 1 eve  eve   141 May 16  2022 .bash_profile
-rw-r--r--. 1 eve  eve   492 May 16  2022 .bashrc
[eve@LinuxTp4B2 ~]$ sudo ss
Sorry, user eve is not allowed to execute '/sbin/ss' as root on LinuxTp4B2.
```

# III. Gestion du temps

🌞 **Je vous laisse gérer le bail vous-mêmes**

- déterminez quel service sur Rocky Linux est le client NTP par défaut
  - demandez à google, ou explorez la liste des services avec `systemctl list-units -t service -a`, ou les deux

```bash
[joris@LinuxTp4B2 ~]$ systemctl list-units -t service -a | grep ntp
● ntpd.service                               not-found inactive dead    ntpd.service
● ntpdate.service                            not-found inactive dead    ntpdate.service
● sntp.service                               not-found inactive dead    sntp.service
```

- demandez à ce service de se synchroniser sur [les serveurs français du NTP Pool Project](https://www.ntppool.org/en/zone/fr)

```bash
[joris@LinuxTp4B2 ~]$ sudo cat /etc/chrony.conf | head -4
# Use public servers from the pool.ntp.org project.
# Please consider joining the pool (https://www.pool.ntp.org/join.html).
#pool 2.pool.ntp.org iburst
pool pool.ntp.org
```

- assurez-vous que vous êtes synchronisés sur l'heure de Paris

```bash
[joris@LinuxTp4B2 ~]$ sudo systemctl restart chronyd
[joris@LinuxTp4B2 ~]$ timedatectl
               Local time: Thu 2024-01-25 20:34:23 CET
           Universal time: Thu 2024-01-25 19:34:23 UTC
                 RTC time: Thu 2024-01-25 19:34:23
                Time zone: Europe/Paris (CET, +0100)
System clock synchronized: no
              NTP service: active
          RTC in local TZ: no
```

> systemd fournit un outil en ligne de commande `timedatectl` qui permet de voir des infos liées à la gestion du temps