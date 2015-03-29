%{
#include <stdio.h>
#include <unistd.h>
#include "lex.yy.h"
#include "symtab.h"
#include "instructionmanager/instructions.h"
#include "instructionmanager/label.h"

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
        int label_id;
        void (* comp_operator) (int,int,int);
        void (* arith_operator) (int,int,int);
}

%token tINT tCONST tPRINTF tCOMA tSEMICOLON
%token tPLUS tMINUS tMULT tDIV tEQUAL
%token tBRAC_OPEN tBRAC_CLOSE
%token tPARENT_OPEN tPARENT_CLOSE
%token tIF tELSE tWHILE
%token tEQUAL_BOOLEAN tDIFFERENT tSMALLER tGREATER
%token <number> tNUMBER
%token <name> tID

%right tEQUAL
%left tPLUS tMINUS
%left tMULT tDIV

%start Start
%type <type> Type
%type <symtab_off> ExprArith
%type <symtab_off> Affectation
%type <symtab_off> AffectationDec
%type <symtab_off> Variable
%type <label_id> Condition
%type <label_id> BeginWhile
%type <label_id> If
%type <label_id> IfElse
%type <comp_operator> ComparaisonOperator
%type <arith_operator> OperatorArithPlusMinus
%type <arith_operator> OperatorArithMultDiv

%%

Start : Functions
      ;

Functions : /* empty */
          | Functions Function
          ;

Function : Type tID tPARENT_OPEN tPARENT_CLOSE BasicBloc

BeginBasicBloc : /* empty */
               {
                    symtab_push_block(symbol_table);
               }

BasicBloc : BeginBasicBloc tBRAC_OPEN Declarations Operations tBRAC_CLOSE
            {
                // get out of block, pop all !
                symtab_pop_block(symbol_table);
            }

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
                if((s = symtab_add_if_not_exists_in_block(symbol_table, $1)) == FALSE)
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
                        if((new = symtab_add_if_not_exists_in_block(symbol_table, $1)) == FALSE)
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
                  int dest = symtab_get_symbol(symbol_table, $1);

                	if(dest == FALSE)
                	{
                	        yyerror("variable not exists");
                	}
                    
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

If : tIF tPARENT_OPEN Condition tPARENT_CLOSE BlocOp
            {
                $$ = label_get_next_tmp_label();
                instr_emit_jmp($$);
                instr_emit_label($3);
            }
Else : tELSE BlocOp

IfElse : If
            {
                instr_emit_label($1);
            }
       | If Else
            {
                instr_emit_label($1);
            }
       ;

ComparaisonOperator : tEQUAL_BOOLEAN
            {
                $$ = instr_emit_equ;
            }
            | tSMALLER
            {
                $$ = instr_emit_inf;
            }
            | tGREATER
            {
                $$ = instr_emit_sup;
            }
            ;

Condition : ExprArith ComparaisonOperator ExprArith
            {
                int tmp;

                symtab_pop(symbol_table);
                symtab_pop(symbol_table);

                tmp = symtab_add_symbol_temp(symbol_table);
                symtab_pop(symbol_table);
                ($2)(tmp, $1, $3);

                $$ = label_get_next_tmp_label();
                instr_emit_jmf(tmp,$$);

            }
            | ExprArith ComparaisonOperator tEQUAL ExprArith
            {
                int tmp;
                int label_equal, label_equal_end;

                tmp = symtab_add_symbol_temp(symbol_table);
                ($2)(tmp, $1, $4); // emit comp of ComparaisonOperator

                $$ = label_get_next_tmp_label();
                label_equal_end = label_get_next_tmp_label();
                label_equal = label_get_next_tmp_label();
                instr_emit_jmf(tmp, label_equal); // si on se plante, on test le equal
                instr_emit_jmp(label_equal_end); // sinon on va dans le corps

                instr_emit_label(label_equal); // debut du equal
                instr_emit_equ(tmp, $1, $4); // emit comp of = !
                instr_emit_jmf(tmp, $$); // si on se plante, on va à la fin
                instr_emit_label(label_equal_end);

                symtab_pop(symbol_table); // delete all temp vars
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
            }
            | ExprArith tDIFFERENT ExprArith
            {
                int tmp_const = 0;
                int tmp_res = 0;

                symtab_pop(symbol_table);
                symtab_pop(symbol_table);

                tmp_res = symtab_add_symbol_temp(symbol_table);
                instr_emit_equ(tmp_res, $1, $3);

                tmp_const = symtab_add_symbol_temp(symbol_table);
                instr_emit_afc(tmp_const, 1);

                instr_emit_sou(tmp_res, tmp_res, tmp_const);
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);

                $$ = label_get_next_tmp_label();
                instr_emit_jmf(tmp_res, $$);
            }
            ;

BeginWhile : /* empty */
    {
        // sert uniquement à mettre le label au tout début
        $$ = label_get_next_tmp_label();
        instr_emit_label($$);
    }
    ;

WhileLoop : BeginWhile tWHILE tPARENT_OPEN Condition tPARENT_CLOSE BlocOp
            {
                instr_emit_jmp($1);
                instr_emit_label($4);
            }
          ;

Operations : /* empty */
           | Operations Operation
           ;

Operation : AffectationOp tSEMICOLON
          | Printf tSEMICOLON
          | IfElse
          | WhileLoop
          ;

BlocOp : BasicBloc
       | Operation
       ;

OperatorArithPlusMinus : tPLUS
            {
                $$ = instr_emit_add;
            }
            | tMINUS
            {
                $$ = instr_emit_sou;
            }

OperatorArithMultDiv : tMULT
            {
                $$ = instr_emit_mul;
            }
            | tDIV
            {
                $$ = instr_emit_div;
            }
            ;

ExprArith : tID
            {
                  int s = symtab_get_symbol(symbol_table, $1);
                  if(s == FALSE)
                  {
                          yyerror("variable not exists");
                  } else {
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
          | ExprArith OperatorArithPlusMinus ExprArith %prec tMINUS
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                ($2)($$, $1, $3);
            }
           | ExprArith OperatorArithMultDiv ExprArith %prec tDIV
            {
                symtab_pop(symbol_table);
                symtab_pop(symbol_table);
                $$ = symtab_add_symbol_temp(symbol_table);
                ($2)($$, $1, $3);
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
