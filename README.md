# Compilo

## About

Ce petit compilateur a été développé dans le cadre du cours "Automates et langages" à l'INSA de Toulouse. Il compile un langage proche du C avec beaucoup de simplification. L'architecture cible est de type RISC avec pipe-line et sera conçu dans le cadre du cours "Architectures Matérielles".

Pour le moment le compilateur traduit le fichier source en instructions simples (cf plus bas).

## Compiler le compilo (compilception)
Vous devez avoir installé `flex` (ou `lex`) et `bison` (ou `yacc`). Les versions compatibles ne sont pas encore bien définies. Voici celles que j'utilise et qui fonctionnent :

```
[tlk:~]$ flex --version
flex 2.5.39
[tlk:~]$ bison --version
bison (GNU Bison) 3.0.4
Écrit par Robert Corbett et Richard Stallman.

Copyright © 2015 Free Software Foundation, Inc.
Ce logiciel est libre; voir les sources pour les conditions de
reproduction. AUCUNE garantie n'est donnée; tant pour des raisons
COMMERCIALES que pour RÉPONDRE À UN BESOIN PARTICULIER.
```

Pour compiler, il suffit de lancer le Makefile :
```
[tlk:~/INSA/S2/automates/Compilo]$ make
gcc -Wall -o symtab.o -c symtab.c
yacc -d --debug --verbose source.yacc
lex --header-file=lex.yy.h source.lex
gcc -Wall -o lex.yy.o -c lex.yy.c
lex.yy.c:1227:16: attention : ‘input’ defined but not used [-Wunused-function]
     static int input  (void)
                ^
gcc -Wall -o y.tab.o -c y.tab.c
gcc -o bin/compilo symtab.o lex.yy.o y.tab.o -lfl -ly
```

## Utilisation

Le binaire généré propose plusieurs options :
- `-h` : afficher l'aide
- `-d` : activer la sortie de debug du parser. La sortie est généré par défaut par yacc et permet de visualiser l'enchainement des différents shift/reduce
- `-s` : permet d'afficher la table des symboles à la fin de la compilation
- `-f` : permet de spécifier le fichier à parser. Par défaut `stdin` est lu.

Exemple :
```
[tlk:~/INSA/S2/automates/Compilo]$ cat tests/basic.c

int main()
{
	const int a = 1 + 2 + 3, x;
	int b = a + 1;
}
[tlk:~/INSA/S2/automates/Compilo]$ ./bin/compilo -f tests/basic.c -s
afc [$0], 1
afc [$1], 2
add [$0], [$0], [$1]
afc [$1], 3
add [$0], [$0], [$1]
cop [$0], [$0]
cop [$2], [$0]
afc [$3], 1
add [$2], [$2], [$3]
cop [$2], [$2]
Number of line(s) = 7
------ Symbole Table (3) -----
 Id  |      Type      |  Name
-----|----------------|-------
  0  | TYPE_CONST_INT |  a 
  1  | TYPE_CONST_INT |  x 
  2  | TYPE_INT       |  b 
  ```

