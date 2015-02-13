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
	
	tINT tIDtENDINSTRID Variable

	tINT tID tEQUAL tINTEGERAffectation
Affectation Variable
tENDINSTR
	tINT tIDtSEPID Variable
 tID tEQUAL tINTEGERAffectation
Affectation Variable
tENDINSTRVariables

	tINT tID tEQUAL tINTEGERAffectation
Affectation Variable
tSEP tIDtSEPID Variable
 tIDtSEPID Variable
 tIDtSEPID Variable
 tID tEQUAL tINTEGERAffectation
Affectation Variable
tSEP tIDtENDINSTRID Variable
Variables
Variables
Variables
Variables
Variables

tBCBloc déclarations
Fonction main


Number of line(s) = 13
```
