%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tCONST tPRINTF tID tCOMA tSEMICOLON tNUMBER
%token tPLUS tMINUS tMULT tDIV tEQUAL
%token tBRAC_OPEN tBRAC_CLOSE
%token tPARENT_OPEN tPARENT_CLOSE

%start Start
%%

Start : Main tBRAC_OPEN Declarations Operations tBRAC_CLOSE

Main : tINT tMAIN tPARENT_OPEN tPARENT_CLOSE

Declarations : /* empty */
	     | Declarations tINT Variables tSEMICOLON

Variables : Variable
          | Variable tCOMA Variables

Variable : tID
         | Affectation 

Affectation : tID tEQUAL ExprArith

Operations : /* empty */
           | Operations Affectation tSEMICOLON

ExprArith : tID
		   | tNUMBER 
		   | tMINUS tNUMBER 
		   | ExprArith Operator ExprArith
		   | tPARENT_OPEN ExprArith tPARENT_CLOSE

Operator : tPLUS | tMINUS | tMULT | tDIV 

%%

yyerror (char *s) {
    fprintf (stderr, "line %d: %s\n", line, s);
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
