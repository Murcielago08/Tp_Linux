# Scripting

Dans ce document on va voir quelques bases autour du scripting dans un environnemnts GNU/Linux.

Un *script* c'est simplement un fichier texte qui contient une liste de commande à exécuter dans l'ordre.

Il est possible d'utiliser de l'algo (variables, if, else) ainsi que toute les commandes habituelles.

Ca fait du scripting `bash` un outil adapté et très puissant pour automatiser des tâches simples liées à l'OS.

## Sommaire

- [Scripting](#scripting)
  - [Sommaire](#sommaire)
  - [1. Shebang](#1-shebang)
  - [2. Variables](#2-variables)
  - [3. Structures confiditionnelles](#3-structures-confiditionnelles)
    - [A. If](#a-if)
    - [B. While](#b-while)
  - [4. Substitution de commandes](#4-substitution-de-commandes)
    - [A. Principe de la substitution](#a-principe-de-la-substitution)
    - [B. Boucle for](#b-boucle-for)
  - [5. Passer des arguments à un script](#5-passer-des-arguments-à-un-script)
  - [6. Ajouter des options au script](#6-ajouter-des-options-au-script)
  - [7. Commandes souvent utilisées](#7-commandes-souvent-utilisées)
    - [A. `grep`](#a-grep)
    - [B. `cut`](#b-cut)
    - [C. `tr`](#c-tr)
  - [8. Itérer proprement sur plusieurs lignes](#8-itérer-proprement-sur-plusieurs-lignes)

## 1. Shebang

➜ **Le *shebang* c'est la première ligne d'un script.**

Cette première ligne a une syntaxe particulière et sert à indiquer le chemin vers le programme qui va exécuter le script.

Dans le cas d'un script `bash` on précisera donc le chemin complet vers le programme `bash`.

Un *shebang* se présente sous la formze suivante :

```bash
#!/bin/bash
```

➜ Cette ligne devra donc toujours se trouver à la ligne 1 de vos scripts `bash`.

## 2. Variables

➜ **En utilisant le langage `bash` il est possible d'utiliser des variables.**

Syntaxe élémentaire :

```bash
$ ptite_variable=toto # pas d'espace dans l'affectation autour du symbole =
$ echo $ptite_variable
toto
```

> Vous pouvez tester ce genre de trucs directement dans le terminal, inutile de lancer un script pour ça. En effet, quand vous êtes dans votre terminal, c'est un peu comme si vous étiez en train d'écrire un long script, jusqu'à ce que vous fermiez le terminal.

➜ **Faites attention à l'utilisation des *quotes* et des *variables* :**

```bash
$ ptite_variable=toto
$ echo "$ptite_variable"
toto
$ echo '$ptite_variable'
$ptite_variable
```

> On dit que les double *quotes* permettent l'*interpolation*. C'est un mot barbare pour désigner l'action de remplacer un nom de variable par sa valeur quand le code est exécuté.

➜ **Question de bonnes pratiques et de sûreté**, on utilise toujours la notation `${}` pour appeler les variables, et on les appelle toujours avec des double-quotes

```bash
$ ptite_variable=toto

# Il faut éviter :
$ echo $ptite_variable
toto
$ echo "$ptite_variable"
toto

# Et préférer :
$ echo "${ptite_variable}"
toto

# Cela permet par exemple d'être safe dans des cas ambigüs comme :
$ echo $ptite_variablecollé # ne donne rien (la variable n'est pas définie)
$ echo "${ptite_variable}collé"
totocollé
```

## 3. Structures confiditionnelles

➜ En `bash`, on peut **utiliser des structures conditionnelles comme `if` ou `else`.**

### A. If

➜ Exemple de bloc `if` (qui s'accompagne toujours d'un `then` et `fi`)

```bash
number_1=1
number_2=2

if [[ ${number_1} -eq ${number_2} ]] # les espaces sont importants
then
  echo "Ce sont les même nombres."
else
  echo "Ce ne sont pas les mêmes nombres."
fi # fermeture du bloc if
```

➜ `eq` c'est pour *equal*. **Il existe plusieurs opérateurs de ce genre** :

- `eq`
  - pour *equal*
  - équivalent de `==`
- `ne`
  - pour *not equal*
  - équivalent de `!=`
- `gt`
  - pour *greater than*
  - équivalent de `>`
- `lt`
  - pour *lower than*
  - équivalent de `<`
- `le`
  - pour *lower or equal*
  - équivalent de `<=`
- `ge`
  - pour *greater or equal*
  - équivalent de `>=`
  
### B. While

➜ Exemple de bloc `while` (qui s'accompagne toujours d'un `do` et `done`)

```bash
number_1=1
number_2=10

while [[ ${number_1} -ne ${number_2} ]] # les espaces sont importants
do
  number_1=$(( number_1 + 1 )) # notez l'utilisation de $(( )) pour faire de l'arithmétique
done # fermeture du bloc while
echo "Les deux variables sont maintenant égales."
```

## 4. Substitution de commandes

### A. Principe de la substitution

➜ **Le principe de la substitution est d'effectuer une sous-commande sur la ligne.**

- on utilise la syntaxe `$(COMMAND)`.

> Ca paraît compliqué, mais c'est super simple et super utile n_n.

Exemple :

```bash
$ whoami
it4

$ echo "Je suis connecté en tant que l'utilisateur $(whoami)."
Je suis connecté en tant que l'utilisateur it4.
```

### B. Boucle for

➜ On utilise très souvent la boucle `for` avec une substitution de commande, bien qu'il existe plein d'autres cas d'utilisation.

Exemple :

```bash
$ seq 1 10
1
2
3
4
5
6
7
8
9
10
$ for i in $(seq 1 10)
do
  echo "${i} est le nombre actuel"
done
1 est le nombre actuel
2 est le nombre actuel
3 est le nombre actuel
4 est le nombre actuel
5 est le nombre actuel
6 est le nombre actuel
7 est le nombre actuel
8 est le nombre actuel
9 est le nombre actuel
10 est le nombre actuel
```

## 5. Passer des arguments à un script

➜ Il est possible de **passer des arguments à un script**. Les arguments sont accessibles dans le script dans les variables `$1`, `$2`, etc.

Exemple :

```bash
$ cat super_script.sh
echo "Le premier argument est ${1}."
echo "Le second argument est ${2}."

$ ./super_script.sh toto coucou
Le premier argument est toto.
Le second argument est coucou.
```

## 6. Ajouter des options au script

➜ Pour pouvoir **appeler votre scripts avec des options** (comme un beau `--help`), on utilise la commande `getopts`.

Je vais pas ré-écrire la roue là dessus, ça alourdirait beaucoup le doc, je vous renvoie vers ce lien qui est chouette : https://www.stackchief.com/tutorials/Bash%20Tutorial%3A%20getopts.

## 7. Commandes souvent utilisées

### A. `grep`

La commande `grep` permet de trouver un mot dans un texte donné. Il y a plein de façons de l'utiliser.

Exemple :

```bash
$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

$ cat /etc/passwd | grep root
root:x:0:0:root:/root:/bin/bash
```

### B. `cut`

La commande `cut` permet de découper un texte en colonne pour en extraire une partie spécifique.

On utilise l'option `-d` pour définir un *delimiter* : le caractère qui définit les colonnes.

Puis l'option `-f` qui permet de choisir numéro du champ (*field*) que l'on veut sélectionner.

> D'autres options existent, je vous livre ce qu'on utilise le plus souvent.

Exemple :

```
$ cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin

$ cat /etc/passwd | cut -d':' -f1
root
bin
daemon
adm
lp
```

### C. `tr`

La commande `tr` a plusieurs fonctionnalités afin de traiter des chaînes de caractères.

Quelque chose de très utile est la possibilité de *strip* un caractère c'est à dire de transformer plusieurs occurrences successives d'un caractère en une occurrence unique.

Un exemple vaut souvent mieux que des mots hein ?

```bash
$ echo "salut     à      vous"
salut     à      vous

# on strip le caractère ' '
$ echo "salut     à      vous" | tr -s ' '
salut à vous

# vraiment utile pour traiter la sortie de commandes comme ps, ou autres
$ ps -ef
it4         2808    2804  7 10:13 pts/1    00:00:09 vim README.md
root        2817       2  0 10:14 ?        00:00:00 [kworker/u9:1]
it4         2818    1102  0 10:15 pts/2    00:00:00 /bin/bash
it4         2819    2818  0 10:15 pts/2    00:00:00 ps -ef

# on peut strip les espaces multiples avec la commande tr
$ ps -ef | tr -s ' '
root 2817 2 0 10:14 ? 00:00:00 [kworker/u9:1]
it4 2818 1102 0 10:15 pts/2 00:00:00 /bin/bash
it4 2827 2818 0 10:15 pts/2 00:00:00 ps -ef
it4 2829 2818 0 10:15 pts/2 00:00:00 tr -s

# on peut alors, par exemple, facilement utiliser cut sur cette sortie
$ ps -ef | tr -s ' '  | cut -d' ' -f2
2830
2833
2834
2835
```

## 8. Itérer proprement sur plusieurs lignes

Petit trick qui permet d'itérer sur plusieurs lignes sorties par une commande.

➜ un exemple vaut mieux que mille mooooooots :

```bash
# partons d'une commande d'exemple connue
cat /etc/passwd
```

➜ utilisons **une syntaxe particulière permettant d'itérer sur chaque ligne** de la sortie de la commande :

```bash
# on va utiliser une boucle while et la commande read avec la syntaxe suivante :
while read super_line; do # déclaration de la variable super_line à la volée

  # à chaque itération de la boucle, $super_line contient une ligne donnée :
  echo "Voici une ligne du fichier : $super_line"

done <<< "$(cat /etc/passwd)" # c'est en face du mot-clé done qu'on envoie la commande sur la quelle itérer
```

➜ **admettons qu**'on veuille afficher le nom, l'id et le shell de chaque user

- ces infos sont stockée dans `/etc/passwd`
- chaque ligne contient les infos d'un utilisateur spécifique
- il faudrait donc itérer sur chaque ligne de la commande `cat /etc/passwd`
- une façon clean de le faire serait :

```bash
while read super_line; do

  name="$(echo $super_line | cut -d':' -f1)"
  id="$(echo $super_line | cut -d':' -f3)"
  shell="$(echo $super_line | cut -d':' -f7)"

  echo "User ${name} has the ID ${id} and its default shell is ${shell}."

done <<< "$(cat /etc/passwd)"
```

