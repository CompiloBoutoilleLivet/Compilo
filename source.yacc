%{
#include <stdio.h>
#include <unistd.h>
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
        enum var_type type;
        int symtab_off;
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
%type <symtab_off> ExprArith
%type <symtab_off> Affectation

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
                if(symtab_add_if_not_exists(symbol_table, $1) == FALSE)
                {
                        yyerror("variable already exists");
                }
           }
         | AffectationDec
         ;

AffectationDec : tID Affectation /* declaration */
		 {
                        int new = -1;
                        int v = symtab_pop(symbol_table);
                        if((new = symtab_add_if_not_exists(symbol_table, $1)) == FALSE)
                        {
                                yyerror("variable already exists");
                        } else {
                                printf("cop [$%d], [$%d]\n", new, v);
                        }
                 }
	       ;

AffectationOp : tID Affectation /* operation */
		{
                	if(symtab_symbol_not_exists(symbol_table, $1) == TRUE)
                	{
                	        yyerror("variable not exists");
                	}
            	}
              ;

Affectation : tEQUAL ExprArith
              {
                $$ = $2;
              }
            ;

Operations : /* empty */
           | Operations AffectationOp tSEMICOLON
           | Operations Printf tSEMICOLON
           ;

ExprArith : tID
            {
                  if(symtab_symbol_not_exists(symbol_table, $1) == TRUE)
                  {
                          yyerror("variable not exists");
                  } else {
                        $$ = symtab_get_symbol(symbol_table, $1);
                  }
                  $$ = symtab_add_symbol_temp(symbol_table);
                  printf("cop [$%d], [$%s]\n",$$,$1);
            }
          | tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_table);
                printf("afc [$%d], %d\n", $$, $1);
            }
          | tMINUS tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_table);
                printf("afc [$%d], %d\n", $$, $2*-1);
            }
          | ExprArith tPLUS ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                printf("add [$%d], [$%d], [$%d]\n", $$, $1, $3);
            }
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
        exit(-1);
}

void print_usage(char *s)
{
    printf("usage : %s \n", s);
    printf("\t -h \t\t print this help\n");
    printf("\t -d \t\t enable parser debug\n");
    printf("\t -s \t\t enable symtab debug\n");
    printf("\t -f <filename>\t filename to parse\n");
    printf("\t\t\t if -f is not specified, stdin is parsed\n");
}

int main(int argc, char **argv) {
    int dflag = 0;
    int sflag = 0;
    char *filename = NULL;
    FILE *f = NULL;
    int c = 0;

    while((c = getopt(argc, argv, "hd::s::f:")) != -1)
    {
        switch(c)
        {
            case 'h':
                print_usage(argv[0]);
                return EXIT_SUCCESS;
                break;

            case 'd': // debug
                dflag = 1;
                break;

            case 's': // symbol debug
                sflag = 1;
                break;

            case 'f':
                filename = optarg;
                break;

            case '?':
                return EXIT_FAILURE;
                break;

        }
    }

    if(dflag)
    {
        yydebug = 1;
    }

    if(filename != NULL)
    {
        f = fopen(filename, "r");
        if(f == NULL)
        {
            printf("%s not found ...\n", filename);
            return EXIT_FAILURE;
        }
        yyin = f;
    }

    symbol_table = symtab_create(256);

	yyparse();

    if(sflag)
    {
        printf("Number of line(s) = %d\n", line);
        symtab_printf(symbol_table);
    }

	return EXIT_SUCCESS;
}
