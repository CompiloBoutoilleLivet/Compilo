%{
#include <stdio.h>
#include "y.tab.h"
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


{ENDLINE} {line++;};
main return(tMAIN);
\{ return(tBO);
\} return(tBC);
const return(tCONST);
int return(tINT);
printf return(tPRINTF);
{ID} return(tID);
\+ return(tPLUS);
\- return(tMINUS);
\* return(tMULT);
\/ return(tDIV);
= return(tEQUAL);
\( return(tPO);
\) return(tPC);
{SEPARATOR} return(tSEP); 
; return(tENDINSTR);
{INTEGER} return(tINTEGER);
{INTEGER_EXP} return(tINTEGER_EXP);

%%