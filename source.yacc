%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tBO tBC tPO tPC tCONST tPRINTF tID tPLUS tMINUS tMULT tDIV tEQUAL tSEP tENDINSTR tINTEGER 

%start Main
%%
Main : tINT tMAIN tPO tPC tBO Declarations tBC

Declarations : tINT Variables tENDINSTR Declarations
		| 

Variables : Variable
		| Variable tSEP Variables

Variable : tID
		| Affectation 

Affectation : tID tEQUAL tID 
		| tID tEQUAL tINTEGER 
		
%%

yyerror (char *s) {
    fprintf (stderr, "%s\n", s);
}

int main() {
	yyparse();
	printf("Number of line(s) = %d\n", line);
	return 0;
}
