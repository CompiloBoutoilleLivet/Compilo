%{
#include <stdio.h>
#include "y.tab.h"
int line = 1;
%}

WHITESPACE [ \t]
ENDLINE [\n]+
ID [a-zA-Z][a-zA-Z0-9_]*
NUMBER ([0-9]+\.)?[0-9]([Ee][+-]?[0-9]+)?

%x COMMENT
%%

"/*" 			{BEGIN COMMENT;}
<COMMENT>\n 		{line++;}
<COMMENT>[^\*\/] 	{}
<COMMENT>"*/" 	        {BEGIN INITIAL;}


{WHITESPACE}    {};
{ENDLINE} 	{line++;};
main 		{return tMAIN;};
\{ 		{return tBRAC_OPEN;};
\} 		{return tBRAC_CLOSE;};
const 		{return tCONST;};
int 		{return tINT;};
printf 		{return tPRINTF;};
{ID} 		{return tID;};
"+" 		{return tPLUS;};
"-" 		{return tMINUS;};
"*" 		{return tMULT;};
"/" 		{return tDIV;};
= 		{return tEQUAL;};
\( 		{return tPARENT_OPEN;};
\) 		{return tPARENT_CLOSE;};
,		{return tCOMA;};
; 		{return tSEMICOLON;};
{NUMBER} 	{return tNUMBER;};

%%
