%{
#include <stdio.h>
#include <unistd.h>
#include "lex.yy.h"
#include "symtab.h"
#include "symfun.h"
#include "instructionmanager/instructions.h"
#include "instructionmanager/label.h"

int n_args = 0;
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
        void (* comp_operator) (int,int,int,int);
        void (* arith_operator) (int,int,int,int);
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
                symfun_add_function("main");
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
                  $$ = symfun_add_function($2);
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

                      if((new = symfun_current_add_parameter($2)) == FALSE)
                      {
                          yyerror("parameter already exists");
                      } else {
                          tmp = symfun_current_get_param_struct(new);
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
              symfun_current_set_prologue(instr_manager_get_last_instr());

              int n = symfun_current_get_n_args();
              if(n == -1)
              {
                symfun_current_set_n_args(symfun_current_resolve_n_args());
              } else {
                if(n != symfun_current_resolve_n_args())
                {
                  yyerror("function doesn't match with prototype");
                }
              }
              
         }
           BasicBloc
         {
            
            if(symfun_current_get_max_symbol() > 0)
            {
              struct instr *prologue = symfun_current_get_prologue();
              instr_insert_sou_reg_val(prologue, SP_REG, SP_REG, symfun_current_get_max_symbol());
            }
            // pour revenir à la fonction appelante
            instr_emit_leave();
            instr_emit_ret();
         }
         | BeginFunction tPARENT_OPEN FunctionParameters tPARENT_CLOSE tSEMICOLON
         {
            // c'est un prototype. On s'interesse cependant au nombre d'arguments
            symfun_current_set_n_args(symfun_current_resolve_n_args());
            symfun_current_flush_symbols();
         }
         ;

BeginBasicBloc : /* empty */
               {
                    symfun_current_push_block();
               }
               ;

BasicBloc : BeginBasicBloc tBRAC_OPEN Declarations Operations tBRAC_CLOSE
            {
                // get out of block, pop all !
                symfun_current_pop_block();
            }
            ;

Printf : tPRINTF tPARENT_OPEN ExprArith tPARENT_CLOSE
         {
            symfun_current_pop();
            instr_emit_pri_rel_reg(BP_REG, $3);
         }
       ;

FunctionParametersCall : /* empty */
                   | FunctionParameterCall tCOMA FunctionParametersCall
                   | FunctionParameterCall
                   ;

FunctionParameterCall : ExprArith
                      {
                        symfun_current_pop();
                        isntr_emit_push_rel_reg(BP_REG, $1);
                        n_args++;
                      }
                      ;

CallFunction : tID {
                if(symfun_get_function($1) == -1){
                    yyerror("unknow function");
                }
              }
              tPARENT_OPEN FunctionParametersCall tPARENT_CLOSE
              {
                struct symbol_function *func = symbol_get_function_struct($1);
                if(n_args != func->n_args)
                {
                  yyerror("bad number of arguments in function call");
                }
                n_args = 0;
                instr_emit_call(label_table_hash_string($1));
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

                if(symfun_current_parameter_exists($1) == TRUE)
                {
                    yyerror("variable already exists as paramter");
                }

                if((s = symfun_current_add_if_not_exists_in_block($1)) == FALSE)
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
                        int v = symfun_current_pop();

                        if(symfun_current_parameter_exists($1) == TRUE)
                        {
                            yyerror("variable already exists as paramter");
                        }

                        if((new = symfun_current_add_if_not_exists_in_block($1)) == FALSE)
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
                  int dest = symfun_current_get_symbol($1);

                	if(dest == FALSE)
                	{
                    dest = symfun_current_get_param($1);
                    is_param = 1;
                    if(dest == FALSE)
                    {
                      yyerror("variable not exists");
                    }
                	}

                  if(is_param == 1)
                  {
                    s = symfun_current_get_param_struct(dest);
                  } else {
                    s = symfun_current_get_symbol_struct(dest);
                  }
                  
                  int v = symfun_current_pop();
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
                $$ = instr_emit_equ_rel_reg;
            }
            | tSMALLER
            {
                $$ = instr_emit_inf_rel_reg;
            }
            | tGREATER
            {
                $$ = instr_emit_sup_rel_reg;
            }
            ;

Condition : ExprArith ComparaisonOperator ExprArith
            {
                int tmp;

                symfun_current_pop();
                symfun_current_pop();

                tmp = symfun_current_add_symbol_temp();
                symfun_current_pop();

                ($2)(BP_REG, tmp, $1, $3);

                $$ = label_get_next_tmp_label();
                instr_emit_jmf_rel_reg(BP_REG, tmp, $$);

            }
            | ExprArith ComparaisonOperator tEQUAL ExprArith
            {
                int tmp;
                int label_equal, label_equal_end;

                tmp = symfun_current_add_symbol_temp();
                ($2)(BP_REG, tmp, $1, $4); // emit comp of ComparaisonOperator

                $$ = label_get_next_tmp_label();
                label_equal_end = label_get_next_tmp_label();
                label_equal = label_get_next_tmp_label();
                instr_emit_jmf_rel_reg(BP_REG, tmp, label_equal); // si on se plante, on test le equal
                instr_emit_jmp(label_equal_end); // sinon on va dans le corps

                instr_emit_label(label_equal); // debut du equal
                instr_emit_equ_rel_reg(BP_REG, tmp, $1, $4); // emit comp of = !
                instr_emit_jmf_rel_reg(BP_REG, tmp, $$); // si on se plante, on va à la fin
                instr_emit_label(label_equal_end);

                symfun_current_pop();
                symfun_current_pop();
                symfun_current_pop();
            }
            | ExprArith tDIFFERENT ExprArith
            {
                int tmp_const = 0;
                int tmp_res = 0;

                symfun_current_pop();
                symfun_current_pop();

                tmp_res = symfun_current_add_symbol_temp();
                instr_emit_equ(tmp_res, $1, $3);

                tmp_const = symfun_current_add_symbol_temp();

                instr_emit_afc_rel_reg(BP_REG, tmp_const, 1);

                instr_emit_sou_rel_reg(BP_REG, tmp_res, tmp_res, tmp_const);
                symfun_current_pop();
                symfun_current_pop();

                $$ = label_get_next_tmp_label();
                instr_emit_jmf_rel_reg(BP_REG, tmp_res, $$);
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
                $$ = instr_emit_add_rel_reg;
            }
            | tMINUS
            {
                $$ = instr_emit_sou_rel_reg;
            }

OperatorArithMultDiv : tMULT
            {
                $$ = instr_emit_mul_rel_reg;
            }
            | tDIV
            {
                $$ = instr_emit_div_rel_reg;
            }
            ;

ExprArith : tID
            {
                  int is_param = 0;
                  int s = symfun_current_get_symbol($1);

                  if(s == FALSE)
                  {
                     is_param = 1;
                     s = symfun_current_get_param($1);
                  }

                  if(s == FALSE)
                  {
                          yyerror("variable not exists");
                  } else {
                        $$ = symfun_current_add_symbol_temp();

                        if(is_param)
                        {
                          s += 2; // because we start at 0 and we have eip between the args and ebp.
                          s *= -1;
                        }
                        
                        instr_emit_cop_rel_reg(BP_REG, $$, BP_REG, s);
                  
                  }
            }
          | tNUMBER
            {
                $$ = symfun_current_add_symbol_temp();
                instr_emit_afc_rel_reg(BP_REG, $$, $1);
            }
          | tMINUS tNUMBER
            {
                $$ = symfun_current_add_symbol_temp();
                instr_emit_afc_rel_reg(BP_REG, $$, $2*-1);
            }
          | ExprArith OperatorArithPlusMinus ExprArith %prec tMINUS
            {
                symfun_current_pop();
                symfun_current_pop();
                $$ = symfun_current_add_symbol_temp();
                ($2)(BP_REG, $$, $1, $3);
            }
           | ExprArith OperatorArithMultDiv ExprArith %prec tDIV
            {
                symfun_current_pop();
                symfun_current_pop();
                $$ = symfun_current_add_symbol_temp();
                ($2)(BP_REG, $$, $1, $3);
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
