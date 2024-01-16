# TP3 Admin : Vagrant

## Sommaire

- [TP3 Admin : Vagrant](#tp3-admin--vagrant)
  - [Sommaire](#sommaire)
  - [2. Repackaging](#2-repackaging)
  - [3. Moult VMs](#3-moult-vms)

🌞 **Générer un `Vagrantfile`**

- vous bosserez avec cet OS pour le restant du TP
- vous pouvez générer une `Vagrantfile` fonctionnel pour une box donnée avec les commandes :

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> vagrant init test

A `Vagrantfile` has been placed in this directory. You are now
ready to `vagrant up` your first virtual environment! Please read
the comments in the Vagrantfile as well as documentation on
`vagrantup.com` for more information on using Vagrant.

PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> ls  



    Répertoire : C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----        12/01/2024     10:41           4648 Rendu_Tp3.md
-a----        12/01/2024     10:35           8636 Sujet_Tp3.md
-a----        12/01/2024     11:45           3455 Vagrantfile


PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> cat .\Vagrantfile

# -*- mode: ruby -*-
  .....
  # SHELL
end
```

🌞 **Modifier le `Vagrantfile`**

- les lignes qui suivent doivent être ajouter dans le bloc où l'objet `config` est défini
- ajouter les lignes suivantes :

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> cat .\Vagrantfile

Vagrant.configure("2") do |config|
  config.vm.box = "test"
  config.vm.box_check_update = false
  config.vm.synced_folder ".", "/vagrant", disabled: true
```
[Vagrantfile](./1.%20Une%20première%20VM/Vagrantfile)

🌞 **Faire joujou avec une VM**

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> vagrant up                     
Bringing machine 'default' up with 'virtualbox' provider...
==> default: Box 'generic/ubuntu2204' could not be found. Attempting to find and install...
    ...
    default: Guest Additions Version: 6.1.38
    default: VirtualBox Version: 7.0
```

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> vagrant status
Current machine states:

default                   running (virtualbox)
```

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> vagrant ssh   
vagrant@ubuntu2204:~$ 
```

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

```
vagrant@ubuntu2204:~$ sudo apt update
Hit:1 https://mirrors.edge.kernel.org/ubuntu jammy InRelease
...
Fetched 8,547 kB in 5s (1,638 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
96 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

  - disposer des commandes `vim`, `ip`, `dig`, `ss`, `nc`

```
vagrant@ubuntu2204:~$ vim --version
VIM - Vi IMproved 8.2 (2019 Dec 12, compiled Aug 18 2023 04:12:26)

vagrant@ubuntu2204:~$ ip -c a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:e8:48:7c brd ff:ff:ff:ff:ff:ff
    altname enp0s3
    inet 10.0.2.15/24 metric 100 brd 10.0.2.255 scope global dynamic eth0
       valid_lft 81305sec preferred_lft 81305sec
    inet6 fe80::a00:27ff:fee8:487c/64 scope link
       valid_lft forever preferred_lft forever

vagrant@ubuntu2204:~$ dig
; <<>> DiG 9.18.12-0ubuntu0.22.04.3-Ubuntu <<>>

vagrant@ubuntu2204:~$ ss -version
ss utility, iproute2-5.15.0

vagrant@ubuntu2204:~$ nc -
nc: missing port number
```

  - avoir un firewall actif

```
vagrant@ubuntu2204:~$ sudo systemctl status ufw
● ufw.service - Uncomplicated firewall
     Loaded: loaded (/lib/systemd/system/ufw.service; enabled; vendor preset: enabled)
     Active: active (exited) since Sun 2024-01-14 13:08:46 UTC; 1h 27min ago
       Docs: man:ufw(8)
   Main PID: 551 (code=exited, status=0/SUCCESS)
        CPU: 6ms

Jan 14 13:08:46 ubuntu2204.localdomain systemd[1]: Starting Uncomplicated firewall...
Jan 14 13:08:46 ubuntu2204.localdomain systemd[1]: Finished Uncomplicated firewall.
```

  - SELinux (systèmes RedHat) et/ou AppArmor (plutôt sur Ubuntu) désactivés

```
vagrant@ubuntu2204:~$ sestatus
SELinux status:                 disabled
```

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

[Vagrantfile](./2.%20Repackaging/Vagrantfile)

- et testez que ça fonctionne !

```
PS C:\Users\darkj\OneDrive\Bureau\Doc Ynov\Programmation\Tp_Linux\Linux_B2\admin\Tp3> vagrant status
Current machine states:

default                   running (virtualbox)
```

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