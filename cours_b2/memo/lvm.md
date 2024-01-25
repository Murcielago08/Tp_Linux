# LVM

LVM *(Logical Volume Manager)* est un outil disponible sur les OS GNU/Linux qui permet de partitionner de façon logique les périphériques de stockage.

Le concept est le suivant :

- on ajoute les périphériques de stockage au gestionnaire LVM : ils deviennent des ***PV*** *(Physical Volumes)*
- les PVs peuvent être aggrégés en ***VG*** *(Volume Group)*
- les VGs peuvent alors être divisés en ***LV*** *(Logical Volume)* qui sont des partitions utilisables comme des partitions classiques

## 1. Partitionner

➜ **0. Repérer les disques à ajouter dans LVM**

```bash
$ lsblk
```

> Pour rappel, dans un système GNU/Linux, tous les périphériques branchés à la machine sont accessibles dans `/dev`. C'est le cas des disques durs qui seront par exemple visibles sou des noms comme `/dev/sda` pour le premier disque, puis `/dev/sdb` pour le deuxième disque, puis `/dev/sdc` pour le troisième, et ainsi de suite.

➜ **1. Ajouter le(s) disque(s) en tant que PV *(Physical Volume)* dans LVM**

```bash
$ sudo pvcreate /dev/<NEW_DISK>

# Par exemple
$ sudo pvcreate /dev/sdb
$ sudo pvcreate /dev/sdc
$ sudo pvcreate /dev/sdd1 # oui, on peut ajouter des disques, ou des partitions physiques à LVM

# Vérif
$ sudo pvs
$ sudo pvdisplay
```

➜ **2. Créer un VG *(Volume Group)***

```bash
$ sudo vgcreate <VG_NAME> <FIRST_PV>

# Par exemple
$ sudo vgcreate data /dev/sdb

# Vérif
$ sudo vgs
$ sudo vgdisplay
```

➜ **3. Ajouter d'autres PVs au VG nouvellement créé (facultatif : uniquement si vous avez d'autres PVs à ajouter)**

```bash
$ sudo vgextend <VG_NAME> <PV_PATH>

# Par exemple
$ sudo vgextend data /dev/sdc
$ sudo vgextend data /dev/sdd1

# Vérif
$ sudo vgs
$ sudo vgdisplay
```

➜ **4. Créer des LV *(Logical Volumes)***

```bash
$ sudo lvcreate -L <SIZE> <VG_NAME> -n <LV_NAME>

# Par exemple
$ sudo lvcreate -L 10G data -n ma_data_frer
$ sudo lvcreate -L 1500M data -n ta_data_frer
$ sudo lvcreate -l 100%FREE data -n last_data # crée un LV qui occupe la totalité de l'espace restant du Volume Group "data"

# Vérif
$ sudo lvs
$ sudo lvdisplay
```

Un LV **est** une partition. On peut alors travailler avec les LVs comme avec des partitions classiques ([voir plus bas](#formater-et-monter-des-partitions)).

# 2. Formater et monter des partitions

➜ **1. Formater une partition**

```bash
$ mkfs -t <FS> <PARTITION>

# Par exemple
$ mkfs -t ext4 /dev/data/ma_data_frer
```

➜ **2. Monter une partition**

```bash
$ mkdir <MOUNT_POINT>
$ mount <PARTITION> <MOUNT_POINT>

# Par exemple
$ mkdir /mnt/data1
$ mount /dev/data/ma_data_frer /mnt/data1

# Vérif 
$ mount # sans argument
$ df -h
```

➜ **3. Définir un montage automatique au boot de la machine**

```bash
$ vim /etc/fstab
[...]
<PARTITION> <MOUNT_POINT> <FS> <OPTIONS> 0 0

# Par exemple
$ vim /etc/fstab
[...]
/dev/data/ma_data_frer /mnt/data1 ext4 defaults 0 0

# Vérif
$ sudo umount /mnt/data1 # démonter la partition si elle est déjà montée
$ sudo mount -av # remonter la partition, en utilisant les infos renseignées dans /etc/fstab
$ sudo reboot # non nécessaire si le mount -av fonctionne correctement
```
