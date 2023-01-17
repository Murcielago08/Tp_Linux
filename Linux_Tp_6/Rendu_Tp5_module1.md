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

- deux choses à faire :

- créer un fichier de configuration NGINX

```
[murci@proxytp6 ~]$ sudo nano /etc/nginx/default.d/base_site.conf    
```

- NextCloud est un peu exigeant, et il demande à être informé si on le met derrière un reverse proxy

```
[murci@tp5web ~]$ sudo cat /var/www/tp5_nextcloud/config/config.php | grep web
    0 => 'web.tp5.linux',
    1 => 'web.tp6.linux',
```

🌞 **Faites en sorte de**

- rendre le serveur `web.tp6.linux` injoignable
- sauf depuis l'IP du reverse proxy

```
[murci@tp5web ~]$ sudo firewall-cmd --zone=public --add-rich-rule='rule family="ipv4" source address="10.105.1.13/32" invert="True" drop' --permanent
[sudo] password for murci:
success
```

🌞 **Une fois que c'est en place**

- faire un `ping` manuel vers l'IP de `proxy.tp6.linux` fonctionne

```
PS C:\Users\darkj> ping 10.105.1.13

Envoi d’une requête 'Ping'  10.105.1.13 avec 32 octets de données :
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64
Réponse de 10.105.1.13 : octets=32 temps<1ms TTL=64

Statistiques Ping pour 10.105.1.13:
    Paquets : envoyés = 4, reçus = 4, perdus = 0 (perte 0%),
Durée approximative des boucles en millisecondes :
    Minimum = 0ms, Maximum = 0ms, Moyenne = 0ms
```

- faire un `ping` manuel vers l'IP de `web.tp6.linux` ne fonctionne pas

```
PS C:\Users\darkj> ping 10.105.1.11

Envoi d’une requête 'Ping'  10.105.1.11 avec 32 octets de données :
Délai d’attente de la demande dépassé.
Délai d’attente de la demande dépassé.
Délai d’attente de la demande dépassé.
Délai d’attente de la demande dépassé.

Statistiques Ping pour 10.105.1.11:
    Paquets : envoyés = 4, reçus = 0, perdus = 4 (perte 100%),
```

# II. HTTPS

Le but de cette section est de permettre une connexion chiffrée lorsqu'un client se connecte. Avoir le ptit HTTPS :)

Le principe :

- on génère une paire de clés sur le serveur `proxy.tp6.linux`
  - une des deux clés sera la clé privée : elle restera sur le serveur et ne bougera jamais

    ```
    [murci@proxytp6 ~]$ ls
    certificat  server.key
    ```

  - l'autre est la clé publique : elle sera stockée dans un fichier appelé *certificat*
    - le *certificat* est donné à chaque client qui se connecte au site

      ```
      [murci@proxytp6 ~]$ ls certificat/
      server.crt
      ```

- on ajuste la conf NGINX
  - on lui indique le chemin vers le certificat et la clé privée afin qu'il puisse les utiliser pour chiffrer le trafic

    ```
    [murci@proxytp6 conf.d]$ sudo cat web.tp6.linux.conf | grep ssl
    listen 443 ssl;
    ssl_certificate     /etc/pki/tls/certs/web.tp6.linux.crt;
    ssl_certificate_key /etc/pki/tls/private/web.tp6.linux.key;
    ```

  - on lui demande d'écouter sur le port conventionnel pour HTTPS : 443 en TCP
    ```
    [murci@proxytp6 conf.d]$ sudo cat web.tp6.linux.conf | grep 443
    listen 443 ssl;
    ```

🌞 **Faire en sorte que NGINX force la connexion en HTTPS plutôt qu'HTTP**

```
[murci@proxytp6 conf.d]$ sudo cat web.tp6.linux.conf | tail -5
server {
    listen 80;
    server_name web.tp6.linux;
    return 301 https://web.tp6.linux$request_uri;
}
```