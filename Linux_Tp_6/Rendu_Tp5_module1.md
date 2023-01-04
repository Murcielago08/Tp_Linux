# Module 1 : Reverse Proxy

Un reverse proxy est donc une machine que l'on place devant un autre service afin d'accueillir les clients et servir d'intermédiaire entre le client et le service.

Dans notre cas, on va là encore utiliser un outil libre : NGINX (et oui, il peut faire ça aussi, c'est même sa fonction première).

L'utilisation d'un reverse proxy peut apporter de nombreux bénéfices :

- décharger le service HTTP de devoir effectuer le chiffrement HTTPS (coûteux en performances)
- répartir la charge entre plusieurs services
- effectuer de la mise en cache
- fournir un rempart solide entre un hacker potentiel et le service et les données importantes
- servir de point d'entrée unique pour accéder à plusieurs sites web

## Sommaire

- [Module 1 : Reverse Proxy](#module-1--reverse-proxy)
  - [Sommaire](#sommaire)
- [I. Setup](#i-setup)
- [II. HTTPS](#ii-https)

# I. Setup

🖥️ **VM `proxy.tp6.linux`**

**N'oubliez pas de dérouler la [📝**checklist**📝](Sujet_Tp6_complet.md/#checklist).**

🌞 **On utilisera NGINX comme reverse proxy**

- utiliser la commande `ss` pour repérer le port sur lequel NGINX écoute

```
[murci@proxytp6 ~]$ sudo ss -alnp | grep nginx
tcp   LISTEN 0      511                                       0.0.0.0:80               0.0.0.0:*     users:(("nginx",pid=10692,fd=6),("nginx",pid=10691,fd=6))
tcp   LISTEN 0      511                                          [::]:80                  [::]:*     users:(("nginx",pid=10692,fd=7),("nginx",pid=10691,fd=7))
```

- ouvrir un port dans le firewall pour autoriser le trafic vers NGINX

```
[murci@proxytp6 ~]$ sudo firewall-cmd --list-all | grep 80
  ports: 80/tcp 22/tcp
```

- utiliser une commande `ps -ef` pour déterminer sous quel utilisateur tourne NGINX

```
[murci@proxytp6 ~]$ ps -ef | grep nginx
root       10691       1  0 17:01 ?        00:00:00 nginx: master process /usr/sbin/nginx
nginx      10692   10691  0 17:01 ?        00:00:00 nginx: worker process
```

- vérifier que le page d'accueil NGINX est disponible en faisant une requête HTTP sur le port 80 de la machine

```
PS C:\Users\darkj> curl http://10.105.1.13:80


StatusCode        : 200
StatusDescription : OK
[...]
```

🌞 **Configurer NGINX**

- nous ce qu'on veut, c'pas une page d'accueil moche, c'est que NGINX agisse comme un reverse proxy entre les clients et notre serveur Web
- deux choses à faire :
  - créer un fichier de configuration NGINX
    - la conf est dans `/etc/nginx`
    - procédez comme pour Apache : repérez les fichiers inclus par le fichier de conf principal, et créez votre fichier de conf en conséquence
  - NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy
    - y'a donc un fichier de conf NextCloud à modifier
    - c'est un fichier appelé `config.php`

➜ **Modifier votre fichier `hosts` de VOTRE PC**

- pour que le service soit joignable avec le nom `web.tp6.linux`
- c'est à dire que `web.tp6.linux` doit pointer vers l'IP de `proxy.tp6.linux`
- autrement dit, pour votre PC :
  - `web.tp6.linux` pointe vers l'IP du reverse proxy
  - `proxy.tp6.linux` ne pointe vers rien
  - taper `http://web.tp6.linux` permet d'accéder au site (en passant de façon transparente par l'IP du proxy)

> Oui vous ne rêvez pas : le nom d'une machine donnée pointe vers l'IP d'une autre ! Ici, on fait juste en sorte qu'un certain nom permette d'accéder au service, sans se soucier de qui porte réellement ce nom.

🌞 **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy
- en effet, les clients ne doivent pas joindre en direct le serveur web : notre reverse proxy est là pour servir de serveur frontal
- **comment ?** Je vous laisser là encore chercher un peu par vous-mêmes (hint : firewall)

🌞 **Une fois que c'est en place**

- faire un `ping` manuel vers l'IP de `proxy.tp6.linux` fonctionne
- faire un `ping` manuel vers l'IP de `web.tp6.linux` ne fonctionne pas

# II. HTTPS

Le but de cette section est de permettre une connexion chiffrée lorsqu'un client se connecte. Avoir le ptit HTTPS :)

Le principe :

- on génère une paire de clés sur le serveur `proxy.tp6.linux`
  - une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais
  - l'autre est la clé publique : elle sera stockée dans un fichier appelé *certificat*
    - le *certificat* est donné à chaque client qui se connecte au site
- on ajuste la conf NGINX
  - on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic
  - on lui demande d'écouter sur le port convetionnel pour HTTPS : 443 en TCP

Je vous laisse Google vous-mêmes "nginx reverse proxy nextcloud" ou ce genre de chose :)

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**