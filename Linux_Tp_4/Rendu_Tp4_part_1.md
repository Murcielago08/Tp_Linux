# Partie 1 : Partitionnement du serveur de stockage

> Cette partie est à réaliser sur 🖥️ **VM storage.tp4.linux**.

On va ajouter un disque dur à la VM, puis le partitionner, afin de créer un espace dédié qui accueillera nos sites web.

➜ **Ajouter un disque dur de 2G à la VM**

- cela se fait via l'interface graphique de virtualbox
- il faut éteindre la VM pour ce faire

> [**Référez-vous au mémo LVM pour réaliser le reste de cette partie.**](../../cours/memos/lvm.md)

**Le partitionnement est obligatoire pour que le disque soit utilisable.** Ici on va rester simple : une seule partition, qui prend toute la place offerte par le disque.

Comme vu en cours, le partitionnement dans les systèmes GNU/Linux s'effectue généralement à l'aide de *LVM*.

**Allons !**

![Part please](./pics/../../pics/part_please.jpg)

🌞 **Partitionner le disque à l'aide de LVM**

- créer un *physical volume (PV)* : le nouveau disque ajouté à la VM

```
[murci@tp4storage ~]$ sudo pvcreate /dev/sdb
  Physical volume "/dev/sdb" successfully created.
```

- créer un nouveau *volume group (VG)*

```
[murci@tp4storage ~]$ sudo vgcreate storage /dev/sdb
  Volume group "storage" successfully created
```

- créer un nouveau *logical volume (LV)* : ce sera la partition utilisable

```
[murci@tp4storage ~]$ sudo lvcreate -l 100%FREE storage -n lv_storage
  Logical volume "lv_storage" created.
```

🌞 **Formater la partition**

- vous formaterez la partition en ext4 (avec une commande `mkfs`)

```
[murci@tp4storage ~]$ sudo mkfs -t ext4 /dev/storage/lv_storage
mke2fs 1.46.5 (30-Dec-2021)
Creating filesystem with 523264 4k blocks and 130816 inodes
Filesystem UUID: 1e9b17e8-2c5f-4c3a-8399-70c53b9b4ecc
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912

Allocating group tables: done
Writing inode tables: done
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done
```

🌞 **Monter la partition**

- montage de la partition (avec la commande `mount`)
  - la partition doit être montée dans le dossier `/storage`
  - preuve avec une commande `df -h` que la partition est bien montée
    - utilisez un `| grep` pour isoler les lignes intéressantes
  - prouvez que vous pouvez lire et écrire des données sur cette partition
- définir un montage automatique de la partition (fichier `/etc/fstab`)
  - vous vérifierez que votre fichier `/etc/fstab` fonctionne correctement

Ok ! Za, z'est fait. On a un espace de stockage dédié pour stocker nos sites web.

**Passons à [la partie 2 : installation du serveur de partage de fichiers](./../part2/README.md).**