%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tCONST tPRINTF tID tPLUS tMINUS tMULT tDIV tEQUAL tCOMA tSEMICOLON tINTEGER
%token tBRAC_OPEN tBRAC_CLOSE
%token tPARENT_OPEN tPARENT_CLOSE

%start Main
%%
Main : tINT tMAIN tPARENT_OPEN tPARENT_CLOSE tBRAC_OPEN Declarations tBRAC_CLOSE

Declarations : /* empty */
	     | Declarations tINT Variables tSEMICOLON

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
