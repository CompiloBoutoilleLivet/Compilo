%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tBO tBC tPO tPC tCONST tPRINTF tID tPLUS tMINUS tMULT tDIV tEQUAL tSEP tENDINSTR tINTEGER 

%start Main
%%
Main : tINT tMAIN tPO tPC tBO Declarations tBC
		{
			printf("Fonction main\n");
		}

Declarations : tINT Variables tENDINSTR Declarations
		| 
		{
			printf("Bloc déclarations\n");
		}

Variables : Variable
		| Variable tSEP Variables
		{
			printf("Variables\n");
		}

Variable : tID {
			printf("ID Variable\n");
		}
		| Affectation 
		{
			printf("Affectation Variable\n");
		}

Affectation : tID tEQUAL tID 
		| tID tEQUAL tINTEGER 
		{
			printf("Affectation\n");
		}
		
%%

yyerror (char *s) {
    fprintf (stderr, "%s\n", s);
}

int main() {
	yyparse();
	printf("\n");
	printf("Number of line(s) = %d\n", line);
	return 0;
}
