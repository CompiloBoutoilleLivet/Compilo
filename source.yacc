%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tBO tBC tPO tPC tCONST tPRINTF tID tPLUS tMINUS tMULT tDIV tEQUAL tCOMA tSEMICOLON tINTEGER 

%start Main
%%
Main : tINT tMAIN tPO tPC tBO Declarations tBC

Declarations : tINT Variables tSEMICOLON Declarations
		| 

Variables : Variable
		| Variable tCOMA Variables

Variable : tID
		| Affectation 

Affectation : tID tEQUAL tID 
		| tID tEQUAL tINTEGER 
		
%%

yyerror (char *s) {
    fprintf (stderr, "%s\n", s);
}

int main(int argc, char **argv) {
	
	if(argc != 1) // debug
	{
		yydebug = 1;
	}

	yyparse();
	printf("Number of line(s) = %d\n", line);
	return 0;
}
