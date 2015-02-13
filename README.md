# Compilo
Pour tester : 
``` 
$ make && ./bin/compilo < tests/basic.c
yacc -d source.yacc
lex source.lex
mkdir -p bin
gcc -o bin/compilo y.tab.c lex.yy.c -lfl -ly
tINT tMAINtPOtPC
tBO
	
	tINT tID  tENDINSTRID Variable

tBCBloc déclarations
Fonction main

line = 6
```
