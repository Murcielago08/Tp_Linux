# TP1 : Are you dead yet ?

- [TP1 : Are you dead yet ?](#tp1--are-you-dead-yet-)
- [I. Intro](#i-intro)
  - [II. Feu](#ii-feu)

# I. Intro

**Le but va être de péter la machine virtuelle.**

Par "péter" on entend la rendre inutilisable :

➜ Si la machine boot même plus, c'est valide  
➜ Si la machine boot, mais que en mode *rescue*, et qu'on peut pas rétablir, c'est valide  
➜ Si la machine boot, mais que l'expérience utilisateur est tellement dégradée qu'on peut rien faire, c'est valide

**Bref si on peut pas utiliser la machine normalement, c'est VA-LI-DE.**  

---

Le but c'est de casser l'OS ou le noyau en soit, ou surcharger les ressources matérielles (disque, ram, etc), ce genre de choses.

Pour rappel : **parmi les principaux composants d'un OS on a :**

- un *filesystem* ou *système de fichiers*
  - des partitions quoi, des endroits où on peut créer des dossiers et des fichiers
- des *utilisateurs* et des *permissions*
- des *processus*
- une *stack réseau*
  - genre des cartes réseau, avec des IP dessus, toussa
- un *shell* pour que les humains puissent utiliser la machine
  - que ce soit une interface graphique (GUI) ou un terminal (CLI)
- des *devices* ou *périphériques*
  - écran, clavier, souris, disques durs, etc.


## II. Feu

🌞 **Trouver au moins 4 façons différentes de péter la machine**

```
Idée N°1 : sudo rm /boot/grub2/grub.cfg (supression du fichier cherger des amorçages de l'os)

Idée N°2 : 

Idée N°3 : 

Idée N°4 : sudo rm -Rf /* (Supression pure et simple des fichier de partition principale)
```

- elles doivent être **vraiment différentes**
- je veux le procédé exact utilisé
  - généralement une commande ou une suite de commandes (script)
- il faut m'expliquer avec des mots comment ça marche
  - pour chaque méthode utilisée, me faut l'explication qui va avec
- tout doit se faire depuis un terminal

Quelques commandes qui peuvent faire le taff :

- `rm` (sur un seul fichier ou un petit groupe de fichiers)
- `nano` ou `vim` (sur un seul fichier ou un petit groupe de fichiers)
- `echo`
- `cat`
- `python`
- `systemctl`
- un script `bash`
- plein d'autres évidemment

