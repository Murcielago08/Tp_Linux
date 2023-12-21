# Module 3 : Fail2Ban

Fail2Ban c'est un peu le cas d'école de l'admin Linux, je vous laisse Google pour le mettre en place.

C'est must-have sur n'importe quel serveur à peu de choses près. En plus d'enrayer les attaques par bruteforce, il limite aussi l'imact sur les performances de ces attaques, en bloquant complètement le trafic venant des IP considérées comme malveillantes

🌞 Faites en sorte que :

- si quelqu'un se plante 3 fois de password pour une co SSH en moins de 1 minute, il est ban
```
[murci@tp5db fail2ban]$ sudo cat jail.local | grep maxretry
# A host is banned if it has generated "maxretry" during the last "findtime"
# "maxretry" is the number of failures before a host get banned.
maxretry = 3

[murci@tp5db fail2ban]$ sudo cat jail.local | grep findtime
# A host is banned if it has generated "maxretry" during the last "findtime"
findtime  = 1m
```
- vérifiez que ça fonctionne en vous faisant ban

```
PS C:\Users\darkj> ssh murci@10.105.1.12
ssh: connect to host 10.105.1.12 port 22: Connection timed out
```
- utilisez une commande dédiée pour lister les IPs qui sont actuellement ban

```
[murci@tp5db ~]$ sudo fail2ban-client banned
[{'sshd': ['10.105.1.11']}]
```

- afficher l'état du firewal, et trouver la ligne qui ban l'IP en question

```
[murci@tp5db ~]$ sudo fail2ban-client status sshd
Status for the jail: sshd
|- Filter
|  |- Currently failed: 0
|  |- Total failed:     6
|  `- Journal matches:  _SYSTEMD_UNIT=sshd.service + _COMM=sshd
`- Actions
   |- Currently banned: 1
   |- Total banned:     2
   `- Banned IP list:   10.105.1.11
```

- lever le ban avec une commande liée à fail2ban

```
[murci@tp5db ~]$ sudo fail2ban-client set sshd unbanip 10.105.1.11
1
```