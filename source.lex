%{
#include <stdio.h>
#include "y.tab.h"
int line = 1;
%}


ENDLINE [\n]+
SEPARATOR (,)
ID [a-zA-Z][a-zA-Z0-9_]*
INTEGER [0-9]+([Ee][+-]?[0-9]+)?

%x COMMENT
%%

"/*" 				{BEGIN COMMENT;}
<COMMENT>\n {		line++;}
<COMMENT>[^\*][^\/] {}
<COMMENT>"*/" 		{BEGIN INITIAL;}


{ENDLINE} 	{printf("\n");line++;};
main 		{printf("tMAIN"); return(tMAIN);};
\{ 			{printf("tBO"); return(tBO);};
\} 			{printf("tBC"); return(tBC);};
const 		{printf("tCONST"); return(tCONST);};
int 		{printf("tINT"); return(tINT);};
printf 		{printf("tPRINTF"); return(tPRINTF);};
{ID} 		{printf("tID"); return(tID);};
\+ 			{printf("tPLUS"); return(tPLUS);};
\- 			{printf("tMINUS"); return(tMINUS);};
\* 			{printf("tMULT"); return(tMULT);};
\/ 			{printf("tDIV"); return(tDIV);};
= 			{printf("tEQUAL"); return(tEQUAL);};
\( 			{printf("tPO"); return(tPO);};
\) 			{printf("tPC"); return(tPC);};
{SEPARATOR} {printf("tSEP"); return(tSEP);};
; 			{printf("tENDINSTR"); return(tENDINSTR);};
{INTEGER} 	{printf("tINTEGER"); return(tINTEGER);};

%%