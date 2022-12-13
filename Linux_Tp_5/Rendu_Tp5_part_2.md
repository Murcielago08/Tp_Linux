# Partie 2 : Mise en place et maîtrise du serveur de base de données

🖥️ **VM db.tp5.linux**



🌞 **Install de MariaDB sur `db.tp5.linux`**

- je veux dans le rendu **toutes** les commandes réalisées

```
[murci@tp5db ~]$ sudo dnf install mariadb-server
[...]
Complete!

[murci@tp5db ~]$ sudo systemctl enable mariadb
Created symlink /etc/systemd/system/mysql.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/mysqld.service → /usr/lib/systemd/system/mariadb.service.
Created symlink /etc/systemd/system/multi-user.target.wants/mariadb.service → /usr/lib/systemd/system/mariadb.service.

[murci@tp5db ~]$ sudo systemctl start mariadb

[murci@tp5db ~]$ sudo systemctl status mariadb
● mariadb.service - MariaDB 10.5 database server
     Loaded: loaded (/usr/lib/systemd/system/mariadb.service; enabled; vend>
     Active: active (running) since Tue 2022-12-13 14:57:42 CET; 2min 19s a>
       Docs: man:mariadbd(8)
             https://mariadb.com/kb/en/library/systemd/
   Main PID: 12720 (mariadbd)
     Status: "Taking your SQL requests now..."
      Tasks: 9 (limit: 5907)
     Memory: 79.2M
        CPU: 939ms
     CGroup: /system.slice/mariadb.service
             └─12720 /usr/libexec/mariadbd --basedir=/usr

Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: you need to be the sys>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: After connecting you c>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: able to connect as any>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: See the MariaDB Knowle>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: Please report any prob>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: The latest information>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: Consider joining Maria>
Dec 13 14:57:41 tp5db mariadb-prepare-db-dir[12678]: https://mariadb.org/ge>
Dec 13 14:57:41 tp5db mariadbd[12720]: 2022-12-13 14:57:41 0 [Note] /usr/li>
Dec 13 14:57:42 tp5db systemd[1]: Started MariaDB 10.5 database server.

[murci@tp5db ~]$ sudo mysql_secure_installation
Thanks for using MariaDB!
```

- faites en sorte que le service de base de données démarre quand la machine s'allume

```
[murci@tp5db ~]$ sudo systemctl enable mariadb
```

🌞 **Port utilisé par MariaDB**

- vous repérerez le port utilisé par MariaDB avec une commande `ss` exécutée sur `db.tp5.linux`

```
[murci@tp5db ~]$ sudo ss -altnp | grep mariadb
LISTEN 0      80                 *:3306            *:*    users:(("mariadbd",pid=12720,fd=19))
```

- il sera nécessaire de l'ouvrir dans le firewall

```
[murci@tp5db ~]$ sudo firewall-cmd --list-all | grep port
  ports: 80/tcp 22/tcp 3306/tcp
```

🌞 **Processus liés à MariaDB**

- repérez les processus lancés lorsque vous lancez le service MariaDB
- utilisz une commande `ps`

```
[murci@tp5db ~]$ sudo ps -ef | grep mariadb
mysql      12720       1  0 14:57 ?        00:00:00 /usr/libexec/mariadbd --basedir=/usr
```

➜ **Une fois la db en place, go sur [la partie 3.](Rendu_Tp5_part_3.md)**