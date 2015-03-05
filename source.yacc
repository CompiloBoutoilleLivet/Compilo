%{
#include <stdio.h>
#include <unistd.h>
#include "lex.yy.h"
#include "symtab.h"
#include "instructions.h"

extern int line;
extern struct symtab *symbol_table;
extern struct simple_table *tmp_table;
extern struct instr_manager *instr_manager;
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
%token tIF tELSE
%token tEQUAL_BOOLEAN tDIFFERENT tSMALLER tGREATER
%token <number> tNUMBER
%token <name> tID

%left tPLUS tMINUS
%left tMULT tDIV

%start Start
%type <type> Type
%type <symtab_off> ExprArith
%type <symtab_off> Affectation
%type <symtab_off> AffectationDec
%type <symtab_off> Variable
%type <symtab_off> Condition

%%

Start : Main tBRAC_OPEN Declarations Operations tBRAC_CLOSE
      ;

Main : tINT tMAIN tPARENT_OPEN tPARENT_CLOSE
     ;

Printf : tPRINTF tPARENT_OPEN ExprArith tPARENT_CLOSE
         {
            symtab_pop(symbol_table);
            instr_emit_pri($3);
         }
       ;

Declarations : /* empty */
	     | Declarations Type Variables tSEMICOLON
            {
                struct symbol *tmp = NULL;
                int i, off;
                if(tmp_table->top != -1)
                {
                    for(i = 0; i<=tmp_table->top; i++)
                    {
                        off = table_get(tmp_table, i);
                        tmp = symbol_table->stack[off];
                        tmp->type = $2;
                    }
                    table_flush(tmp_table);
                }
            }
         ;

Variables : Variable
            {
                table_add(tmp_table, $1);
            }
          | Variable tCOMA Variables
            {
                table_add(tmp_table, $1);
            }
          ;

Variable : tID
           {
                int s = -1;
                if((s = symtab_add_if_not_exists(symbol_table, $1)) == FALSE)
                {
                        yyerror("variable already exists");
                } else {
                    $$ = s;
                }
           }
         | AffectationDec
           {
              $$ = $1;
           }
         ;

AffectationDec : tID Affectation /* declaration */
		 {
                        int new = -1;
                        int v = symtab_pop(symbol_table);
                        if((new = symtab_add_if_not_exists(symbol_table, $1)) == FALSE)
                        {
                                yyerror("variable already exists");
                        } else {
                                instr_emit_cop(new, v);
                                $$ = new;
                        }
                 }
	       ;

AffectationOp : tID Affectation /* operation */
		{
                	if(symtab_symbol_not_exists(symbol_table, $1) == TRUE)
                	{
                	        yyerror("variable not exists");
                	}

                    int dest = symtab_get_symbol(symbol_table, $1);
                    struct symbol *s = symbol_table->stack[dest];
                    int v = symtab_pop(symbol_table);
                    if(s->type == TYPE_CONST_INT)
                    {
                        yyerror("variable is assigned but it is a declared as a const");
                    } else {
                        instr_emit_cop(dest, v);
                    }

            	}
              ;

Affectation : tEQUAL ExprArith
              {
                $$ = $2;
              }
            ;

If : tIF tPARENT_OPEN Condition tPARENT_CLOSE tBRAC_OPEN Operations tBRAC_CLOSE 
            {
                instr_emit_jmp();
                instr_emit_end_if();
            }
Else : tELSE tBRAC_OPEN Operations tBRAC_CLOSE
            {
                instr_emit_end_else();
            }

IfElse : If
            {
                instr_emit_end_else();
            }
       | If Else
       ;

Condition : ExprArith tEQUAL_BOOLEAN ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                
                $$ = symtab_add_symbol_temp(symbol_table);
                symtab_pop(symbol_table);

                instr_emit_equ($$, $1, $3);
                instr_emit_jmf($$);
            }
            | ExprArith tDIFFERENT ExprArith
            {
              
            }
            | ExprArith tSMALLER ExprArith 
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_inf($$, $1, $3);
            }
            | ExprArith tGREATER ExprArith 
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_sup($$, $1, $3);
            } ;


Operations : /* empty */
           | Operations AffectationOp tSEMICOLON
           | Operations Printf tSEMICOLON
           | Operations IfElse
           ;

ExprArith : tID
            {
                  if(symtab_symbol_not_exists(symbol_table, $1) == TRUE)
                  {
                          yyerror("variable not exists");
                  } else {
                        int s = symtab_get_symbol(symbol_table, $1);
                        $$ = symtab_add_symbol_temp(symbol_table);
                        instr_emit_cop($$, s);
                  }
            }
          | tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_afc($$, $1);
            }
          | tMINUS tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_afc($$, $2*-1);
            }
          | ExprArith tPLUS ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_add($$, $1, $3);
            }
          | ExprArith tMINUS ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_sou($$, $1, $3);
            }
          | ExprArith tMULT ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_mul($$, $1, $3);
            }
          | ExprArith tDIV ExprArith
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                instr_emit_div($$, $1, $3);
            }
          | tPARENT_OPEN ExprArith tPARENT_CLOSE
            {
                $$ = $2;
            }
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
    printf("\t -S <filename>\t filename to write assembly\n");
}

int main(int argc, char **argv) {
    int dflag = 0;
    int sflag = 0;
    char *filename_in = NULL;
    char *filemane_out_asm = NULL;
    FILE *fin = NULL;
    FILE *fout_asm = NULL;
    int c = 0;

    while((c = getopt(argc, argv, "hd::s::f:S:")) != -1)
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

            case 'f': // stdin
                filename_in = optarg;
                break;

            case 'S': // asm stdout
                filemane_out_asm = optarg;
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

    if(filename_in != NULL)
    {
        fin = fopen(filename_in, "r");
        if(fin == NULL)
        {
            printf("[-] %s not found ...\n", filename_in);
            return EXIT_FAILURE;
        }
        printf("[+] Reading from file %s\n", filename_in);
        yyin = fin;
    }

    if(filemane_out_asm != NULL)
    {
        fout_asm = fopen(filemane_out_asm, "w+");
        if(fout_asm == NULL)
        {
            printf("[-] unable to create %s ...\n", filemane_out_asm);
            return EXIT_FAILURE;
        }
    }

    symbol_table = symtab_create(256);
    tmp_table = table_create(256);
    instr_manager_init();

	yyparse();

    if(sflag)
    {
        printf("[+] Number of line(s) = %d\n", line);
        symtab_printf(symbol_table);
    }

    printf("[+] %d instructions generated\n", instr_manager->count);
    if(fout_asm == NULL)
    {
        instr_manager_print_textual();
    } else {
        printf("[+] Writing asm to %s\n", filemane_out_asm);
        instr_manager_print_textual_file(fout_asm);
    }

	return EXIT_SUCCESS;
}
