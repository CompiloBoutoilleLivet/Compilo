%{
#include <stdio.h>
#include "symtab.h"
#include "y.tab.h"
int line = 1;
%}

%option nounput

WHITESPACE [ \t]
ENDLINE [\n]+
ID [a-zA-Z][a-zA-Z0-9_]*
NUMBER ([0-9]+\.)?[0-9]+([Ee][+-]?[0-9]+)?

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
if              {return tIF;};
else            {return tELSE;};
while           {return tWHILE;};
{ID} 		{
                        yylval.name = strdup(yytext);
                        return tID;
                };
"+" 		{return tPLUS;};
"-" 		{return tMINUS;};
"*" 		{return tMULT;};
"/" 		{return tDIV;};
"=="    {return tEQUAL_BOOLEAN;};
"!="    {return tDIFFERENT;};
"<"             {return tSMALLER;};
">"             {return tGREATER;};
= 		{return tEQUAL;};
\( 		{return tPARENT_OPEN;};
\) 		{return tPARENT_CLOSE;};
,		{return tCOMA;};
; 		{return tSEMICOLON;};
{NUMBER} 	{
                        yylval.number = atoi(yytext);
                        return tNUMBER;
                };

%%
