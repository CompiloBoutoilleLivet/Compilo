%{
#include <stdio.h>
#include <unistd.h>
#include "lex.yy.h"
#include "symtab.h"
#include "symfun.h"
#include "instructionmanager/instructions.h"
#include "instructionmanager/label.h"

extern int line;
extern struct symfun *symbol_function;
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
%type <symtab_off> BeginFunction
%%

BeginStart : /* empty */
           {
                symfun_add_function(symbol_function, "main");
                instr_emit_afc_reg(BP_REG, 0xFF);
                instr_emit_afc_reg(SP_REG, 0xFF);
                instr_emit_call(label_table_hash_string("main"));
                instr_emit_stop();
           }
           ;

Start : BeginStart Functions;

Functions : /* empty */
          | Functions Function
          ;

BeginFunction : Type tID
              {
                  $$ = symfun_add_function(symbol_function, $2);
                  symbol_function->current_function = symbol_function->stack[$$];
              }
              ;

FunctionParameters : /* empty */
                   | FunctionParameter tCOMA FunctionParameters
                   | FunctionParameter
                   ;

FunctionParameter : Type tID
                  {
                      int new = 0;
                      struct symbol *tmp = NULL;

                      if((new = symtab_add_if_not_exists_in_block(symbol_function->current_function->symbol_table_params, $2)) == FALSE)
                      {
                          yyerror("parameter already exists");
                      } else {
                          tmp = symbol_function->current_function->symbol_table_params->stack[new];
                          tmp->type = $1;
                      }
                  }
                  ;

Function : BeginFunction tPARENT_OPEN FunctionParameters tPARENT_CLOSE
         {
              // symtab_printf(symbol_function->current_function->symbol_table_params);
              int label = label_add(symbol_function->current_function->name); // Get the last symbol added, corresponding to the current function
              instr_emit_label(label);
              instr_emit_push_reg(BP_REG);
              instr_emit_cop_reg(BP_REG, SP_REG);
         }
           BasicBloc
         {
            // pour revenir à la fonction appelante
            instr_emit_leave();
            instr_emit_ret();
         }
         | BeginFunction tPARENT_OPEN FunctionParameters tPARENT_CLOSE tSEMICOLON
         {
            symtab_flush(symbol_function->current_function->symbol_table_params);
         }
         ;

BeginBasicBloc : /* empty */
               {
                    symtab_push_block(symbol_function->current_function->symbol_table);
               }
               ;

BasicBloc : BeginBasicBloc tBRAC_OPEN Declarations Operations tBRAC_CLOSE
            {
                // get out of block, pop all !
                symtab_pop_block(symbol_function->current_function->symbol_table);
            }
            ;

Printf : tPRINTF tPARENT_OPEN ExprArith tPARENT_CLOSE
         {
            symtab_pop(symbol_function->current_function->symbol_table);
            instr_emit_pri_rel_reg(BP_REG, $3);
         }
       ;

CallFunction : tID tPARENT_OPEN tPARENT_CLOSE
              {
                  if(symfun_get_function(symbol_function,$1) == -1){
                    yyerror("unknow function");
                  }
                  else{
                    instr_emit_call(label_table_hash_string($1));
                  }
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
                        tmp = symbol_function->current_function->symbol_table->stack[off];
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

                if(symtab_symbol_exists(symbol_function->current_function->symbol_table_params, $1) == TRUE)
                {
                    yyerror("variable already exists as paramter");
                }

                if((s = symtab_add_if_not_exists_in_block(symbol_function->current_function->symbol_table, $1)) == FALSE)
                {
                    yyerror("variable already exists");
                } else {

                    if(symfun_function_is_max_symbol(symbol_function->current_function, s) == 0)
                    {
                         instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                    }

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
                        int v = symtab_pop(symbol_function->current_function->symbol_table);

                        if(symtab_symbol_exists(symbol_function->current_function->symbol_table_params, $1) == TRUE)
                        {
                            yyerror("variable already exists as paramter");
                        }

                        if((new = symtab_add_if_not_exists_in_block(symbol_function->current_function->symbol_table, $1)) == FALSE)
                        {
                                yyerror("variable already exists");
                        } else {
                                instr_emit_cop_rel_reg(BP_REG, new, BP_REG, v);
                                $$ = new;
                        }
                 }
	       ;

AffectationOp : tID Affectation /* operation */
		{
                  struct symbol *s = NULL;
                  int is_param = 0;
                  int dest = symtab_get_symbol(symbol_function->current_function->symbol_table, $1);

                	if(dest == FALSE)
                	{
                    dest = symtab_get_symbol(symbol_function->current_function->symbol_table_params, $1);
                    is_param = 1;
                    if(dest == FALSE)
                    {
                      yyerror("variable not exists");
                    }
                	}

                  if(is_param == 1)
                  {
                    s = symbol_function->current_function->symbol_table_params->stack[dest];
                  } else {
                    s = symbol_function->current_function->symbol_table->stack[dest];
                  }
                  
                  int v = symtab_pop(symbol_function->current_function->symbol_table);
                  if(s->type == TYPE_CONST_INT)
                  {
                      yyerror("variable is assigned but it is a declared as a const");
                  } else {

                    if(is_param == 1)
                    {
                      dest += 2;
                      dest *= -1;
                    }
                  
                    instr_emit_cop_rel_reg(BP_REG, dest, BP_REG, v);
                  
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

                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);

                tmp = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);

                if(symfun_function_is_max_symbol(symbol_function->current_function, tmp) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }

                ($2)(tmp, $1, $3);

                $$ = label_get_next_tmp_label();
                instr_emit_jmf(tmp,$$);

            }
            | ExprArith ComparaisonOperator tEQUAL ExprArith
            {
                int tmp;
                int label_equal, label_equal_end;

                tmp = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, tmp) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
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

                symtab_pop(symbol_function->current_function->symbol_table); // delete all temp vars
                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);
            }
            | ExprArith tDIFFERENT ExprArith
            {
                int tmp_const = 0;
                int tmp_res = 0;

                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);

                tmp_res = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, tmp_res) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
                instr_emit_equ(tmp_res, $1, $3);

                tmp_const = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, tmp_const) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
                instr_emit_afc_rel_reg(BP_REG, tmp_const, 1);

                instr_emit_sou(tmp_res, tmp_res, tmp_const);
                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);

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
          | CallFunction tSEMICOLON
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
                  int is_param = 0;
                  int s = symtab_get_symbol(symbol_function->current_function->symbol_table, $1);

                  if(s == FALSE)
                  {
                     is_param = 1;
                     s = symtab_get_symbol(symbol_function->current_function->symbol_table_params, $1);
                  }

                  if(s == FALSE)
                  {
                          yyerror("variable not exists");
                  } else {
                        $$ = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                        
                        if(is_param == 0 && symfun_function_is_max_symbol(symbol_function->current_function, s) == 0)
                        {
                          instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                        }

                        if(symfun_function_is_max_symbol(symbol_function->current_function, $$) == 0)
                        {
                          instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                        }

                        if(is_param)
                        {
                          s += 2; // because we start at 0 and we have eip between the args and ebp.
                          instr_emit_cop_rel_reg(BP_REG, $$, BP_REG, s*-1);
                        } else {
                          instr_emit_cop_rel_reg(BP_REG, $$, BP_REG, s);
                        }
                        
                  }
            }
          | tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, $$) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
                instr_emit_afc_rel_reg(BP_REG, $$, $1);
            }
          | tMINUS tNUMBER
            {
                $$ = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, $$) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
                instr_emit_afc_rel_reg(BP_REG, $$, $2*-1);
            }
          | ExprArith OperatorArithPlusMinus ExprArith %prec tMINUS
            {
                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);
                $$ = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, $$) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
                ($2)($$, $1, $3);
            }
           | ExprArith OperatorArithMultDiv ExprArith %prec tDIV
            {
                symtab_pop(symbol_function->current_function->symbol_table);
                symtab_pop(symbol_function->current_function->symbol_table);
                $$ = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
                if(symfun_function_is_max_symbol(symbol_function->current_function, $$) == 0)
                {
                  instr_emit_add_reg_val(SP_REG, SP_REG, 1);
                }
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
