#include <stdio.h>
#include <stdlib.h>
#include "label.h"
#include "instructions.h"

struct instr_manager *instr_manager = NULL;

void instr_manager_init()
{
	instr_manager = malloc(sizeof(struct instr_manager));
	if(instr_manager != NULL)
	{
		instr_manager->count = 0;
		instr_manager->first = NULL;
		instr_manager->last = NULL;
	 	instr_manager->stack_label_if = label_stack_init();
		instr_manager->stack_label_else = label_stack_init();
	}
}

void instr_manager_print_textual()
{
	instr_manager_print_textual_file(stdout);
}

void instr_manager_print_textual_file(FILE *f)
{
	struct instr *instr = NULL;
	if(instr_manager != NULL)
	{
		instr = instr_manager->first;
		while(instr != NULL)
		{
			switch(instr->type)
			{

				case COP_INSTR:
					fprintf(f, "\tcop [$%d], [$%d]\n", instr->params[0], instr->params[1]);
					break;

				case AFC_INSTR:
					fprintf(f, "\tafc [$%d], %d\n", instr->params[0], instr->params[1]);
					break;

				case ADD_INSTR:
					fprintf(f, "\tadd [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case SOU_INSTR:
					fprintf(f, "\tsou [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case MUL_INSTR:
					fprintf(f, "\tmul [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case DIV_INSTR:
					fprintf(f, "\tdiv [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;	

				case EQU_INSTR:
					fprintf(f, "\tequ [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;	


				case INF_INSTR:
					fprintf(f, "\tinf [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;	


				case SUP_INSTR:
					fprintf(f, "\tsup [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;	


				case PRI_INSTR:
					fprintf(f, "\tpri [$%d]\n", instr->params[0]);
					break;


				case JMP_INSTR:
					fprintf(f, "\tjmp label%d\n", instr->params[0]);
					break;	


				case JMF_INSTR:
					fprintf(f, "\tjmf [$%d], label%d\n", instr->params[0], instr->params[1]);
					break;	


				case LABEL_INSTR:
					fprintf(f, "label%d:\n", instr->params[0]);
					break;	


				default:
					printf("instr_manager : unknow opcode ...\n");
					exit(-1);
					break;
			}
			instr = instr->next;
		}
	}
}

struct instr *instr_init_instr(enum instr_type type, int psize)
{
	struct instr *ret = NULL;

	ret = malloc(sizeof(struct instr));
	if(ret != NULL)
	{
		ret->type = type;
		ret->params = malloc(sizeof(int)*2);
		if(ret->params == NULL)
		{
			free(ret);
			ret = NULL;
		}
	}

	return ret;
}

void instr_emit_instr(struct instr *instr)
{
	if(instr_manager != NULL)
	{
		instr_manager->count++;
		instr->next = NULL;
		if(instr_manager->first == NULL)
		{
			instr_manager->first = instr;
			instr_manager->last = instr;
		} else {
			instr_manager->last->next = instr;
			instr_manager->last = instr;
		}
	}
}

void instr_emit_cop(int dest, int source)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(COP_INSTR, 2)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = source;
		instr_emit_instr(instr);
	}
}

void instr_emit_afc(int dest, int value)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(AFC_INSTR, 2)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = value;
		instr_emit_instr(instr);
	}
}

void instr_emit_add(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(ADD_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_sou(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(SOU_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_mul(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(MUL_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_div(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(DIV_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_pri(int what)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(PRI_INSTR, 1)) != NULL)
	{
		instr->params[0] = what;
		instr_emit_instr(instr);
	}
}

void instr_emit_equ(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(EQU_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_sup(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(SUP_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_inf(int dest, int op1, int op2)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(INF_INSTR, 3)) != NULL)
	{
		instr->params[0] = dest;
		instr->params[1] = op1;
		instr->params[2] = op2;
		instr_emit_instr(instr);
	}
}

void instr_emit_jmf(int addr)
{
	struct instr *instr = NULL;
	if((instr = instr_init_instr(JMF_INSTR, 2)) != NULL)
	{
		instr->params[0] = addr;
		instr->params[1] = label_push(instr_manager->stack_label_if);
		instr_emit_instr(instr);
	}
}

void instr_emit_jmp(){
	struct instr *instr = NULL;
	if((instr = instr_init_instr(JMP_INSTR, 1)) != NULL)
	{
		instr->params[0] = label_push(instr_manager->stack_label_else);
		instr_emit_instr(instr);
	}
}

void instr_emit_end_if(){
	struct instr *instr = NULL;
	if((instr = instr_init_instr(LABEL_INSTR, 1)) != NULL)
	{
		instr->params[0] = label_pop(instr_manager->stack_label_if);
		instr_emit_instr(instr);
	}
}

void instr_emit_end_else(){
	struct instr *instr = NULL;
	if((instr = instr_init_instr(LABEL_INSTR, 1)) != NULL)
	{
		instr->params[0] = label_pop(instr_manager->stack_label_else);
		instr_emit_instr(instr);
	}
}

