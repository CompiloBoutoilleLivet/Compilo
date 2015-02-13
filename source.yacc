%{
#include <stdio.h>
extern int line;
%}

%token tINT tMAIN tBO tBC tPO tPC tCONST tPRINTF tID tPLUS tMINUS tMULT tDIV tEQUAL tSEP tENDINSTR tINTEGER tINTEGER_EXP

%start Main
%%
Main : tINT tMAIN tPO tPC tBO {
			printf("Fonction main");
		}
%%


int main() {
	yyparse();
	printf("\n");
	printf("line = %d\n", line);
}
