%{
#include <stdio.h>
#include "y.tab.h"
int line = 1;
%}

WHITESPACE [ \t]
ENDLINE [\n]+
SEPARATOR (,)
ID [a-zA-Z][a-zA-Z0-9_]*
INTEGER [0-9]+([Ee][+-]?[0-9]+)?

%x COMMENT
%%

"/*" 				{BEGIN COMMENT;}
<COMMENT>\n 		{line++;}
<COMMENT>[^\*\/] 	{}
<COMMENT>"*/" 		{BEGIN INITIAL;}


{WHITESPACE} {};
{ENDLINE} 	{line++;};
main 		{return tMAIN;};
\{ 			{return tBO;};
\} 			{return tBC;};
const 		{return tCONST;};
int 		{return tINT;};
printf 		{return tPRINTF;};
{ID} 		{return tID;};
\+ 			{return tPLUS;};
\- 			{return tMINUS;};
\* 			{return tMULT;};
\/ 			{return tDIV;};
= 			{return tEQUAL;};
\( 			{return tPO;};
\) 			{return tPC;};
,			{return tSEP;};
; 			{return tENDINSTR;};
{INTEGER} 	{return tINTEGER;};

%%