%{
#include <stdio.h>
#include "lex.yy.h"
#include "symtab.h"

extern int line;
extern struct symtab *symbol_table;
int yyerror (char *s);

%}

%union
{
        /* specific to token */
        int number;
        char *name;
        /* specific to rules */
        enum enum_type {
                TYPE_INT,
                TYPE_CONST_INT
        } type;
}

%token tINT tMAIN tCONST tPRINTF tCOMA tSEMICOLON
%token tPLUS tMINUS tMULT tDIV tEQUAL
%token tBRAC_OPEN tBRAC_CLOSE
%token tPARENT_OPEN tPARENT_CLOSE
%token <number> tNUMBER
%token <name> tID

%left tPLUS tMINUS
%left tMULT tDIV

%start Start
%type <type> Type
%%

Start : Main tBRAC_OPEN Declarations Operations tBRAC_CLOSE
      ;

Main : tINT tMAIN tPARENT_OPEN tPARENT_CLOSE
     ;

Printf : tPRINTF tPARENT_OPEN tID tPARENT_CLOSE 
       ;

Declarations : /* empty */
	     | Declarations Type Variables tSEMICOLON
             ;

Variables : Variable
          | Variable tCOMA Variables
          ;

Variable : tID
           {
                if(symtab_symbol_exists(symbol_table, $1) == 0)
                {
                        yyerror("variable already exists");
                } else {
                        symtab_add_symbol_notype(symbol_table, $1);
                }
           }
         | AffectationDec 
         ;

AffectationDec : tID Affectation
		 {
			if(symtab_symbol_exists(symbol_table, $1) == 0)
                	{
                                yyerror("variable already exists");
                	} else {
                                symtab_add_symbol_notype(symbol_table, $1);
                	}
                 }
	       ;

AffectationOp : tID Affectation
		{
                	if(symtab_symbol_exists(symbol_table, $1) == 0)
                	{
                	        yyerror("variable not exists");
                	}
            	}
              ;

Affectation : tEQUAL ExprArith
            ;

Operations : /* empty */
           | Operations AffectationOp tSEMICOLON
           | Operations Printf tSEMICOLON
           ;

ExprArith : tID
            {
                if(symtab_symbol_exists(symbol_table, $1) == 0)
                {
                        yyerror("variable not exists");
                }
            }
          | tNUMBER 
          | tMINUS tNUMBER
          | ExprArith tPLUS ExprArith
          | ExprArith tMINUS ExprArith
          | ExprArith tMULT ExprArith
          | ExprArith tDIV ExprArith
          | tPARENT_OPEN ExprArith tPARENT_CLOSE
          ;

Type : tINT
       {
                $$ = TYPE_INT;
       }
     | tCONST tINT
       {
                $$ = TYPE_CONST_INT;
       }
     ;

%%

int yyerror (char *s) {
    fprintf (stderr, "line %d: %s\n", line, s);
    return -1;
}

int main(int argc, char **argv) {
	
	if(argc != 1) // debug
	{
		yydebug = 1;
	}

        symbol_table = symtab_create(256);

	yyparse();
	printf("Number of line(s) = %d\n", line);
	return 0;
}
