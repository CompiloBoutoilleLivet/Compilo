%{
#include <stdio.h>
int line = 1;
%}


ENDLINE [\n]+
SEPARATOR (,)
ID [a-zA-Z][a-zA-Z0-9_]*
INTEGER [0-9]+
INTEGER_EXP {INTEGER}[Ee][+-]?{INTEGER}

%x COMMENT
%%

"/*" {BEGIN COMMENT;}
<COMMENT>\n {line++;}
<COMMENT>[^\*][^\/] {}
<COMMENT>"*/" {BEGIN INITIAL;}


{ENDLINE} {line++; printf("\n");};
main\(\) printf("tMAIN");
\{ printf("tBO");
\} printf("tBC");
const printf("tCONST");
int printf("tINT");
printf printf("tPRINTF");
{ID} printf("tID");
\+ printf("tPLUS");
\- printf("tMINUS");
\* printf("tMULT");
\/ printf("tDIV");
= printf("tEQUAL");
\( printf("tPO");
\) printf("tPC");
{SEPARATOR} printf("tSEP"); 
; printf("tENDINSTR");
{INTEGER} printf("tINTEGER");
{INTEGER_EXP} printf("tINTEGER_EXP");

%%

int main() {
	yylex();
	printf("\n");
	printf("line = %d\n", line);
}
