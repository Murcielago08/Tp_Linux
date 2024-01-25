# TP5 Admin : Haute-Dispo

Dans ce TP, on va s'intéresser à quelques **techniques de haute-disponibilité**, ou *high-availability* en anglais, **souvent abrégé *HA*.**

➜ Les outils et techniques de haute-disponibilité peuvent être répartis en deux groupes :

- **tolérance de panne** ou *fault tolerance*
  - on a N serveurs qui ont la charge d'un seul service
    - un seul, ou plusieurs d'entre eux, traitent le service à un instant T : ils sont actifs
    - les autres dorment, attendent : ils sont passifs
  - si l'un des serveurs meurt, un des serveurs qui étaient passif remplace le serveur qui vient de mourir et devient actif
- **répartition de charges** ou *loadbalancing*
  - on a N serveurs qui ont la charge d'un seul service
  - les requêtes que doivent traiter mes serveurs sont réparties entre les différentes serveurs
  - suivant un critère de charge (oupa : *round-robin*)
  - c'est à dire que + le serveur est actuellement "chargé" (en train de traiter des requêtes), moins ce serait malin qu'on lui envoie une requête de plus à traiter

➜ **Dans un cas comme dans l'autre, on appelle "cluster" ce groupe de serveurs qui sert le même service**

➜ Un outil de haute-disponibilité c'est donc, comme son nom l'indique, un outil qui va permettre d'augmenter le niveau de disponibilité d'un service.

Y'en a plein différents, qui reposent sur des principes différents. Certains reposent sur le réseau purement (IP virtuelle), d'autres sur des techniques spécifiques (base de données, Active Directory Windows, etc.).

![One IP](./img/one_ip_two_vms.png)

➜ Dans ce TP on va se concentrer sur quelques technos/techniques classiques dans le monde Linux. Le but donc dans ce TP : une app web hautement disponible

- répartition de charges sur plusieurs apps web grâce à des *reverse proxies*
- tolérance de panne au sein du cluster de *reverse proxies*
- tolérance de panne au sein *d'un cluster de base de données*

> *Ce setup permet de réagir instantanément aux pannes éventuelles. Il n'élimine pas des pannes complètes. Il peut aussi causer des problèmes quand un serveur B récupère tout le trafic d'un serveur A. Bref dans un cas réel, on affine la conf et aussi/surtout, on backup tout, tout le temps.*

---

➜ **c bardi, j'ai séparé le TP en deux parties :**

- [**Partie 1 : Setup initial**](./setup.md)
- [**Partie 2 : Haute Disponibilité**](./ha.md)