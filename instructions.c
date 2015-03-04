#include <stdio.h>
#include <stdlib.h>
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
					fprintf(f, "cop [$%d], [$%d]\n", instr->params[0], instr->params[1]);
					break;

				case AFC_INSTR:
					fprintf(f, "afc [$%d], %d\n", instr->params[0], instr->params[1]);
					break;

				case ADD_INSTR:
					fprintf(f, "add [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case SOU_INSTR:
					fprintf(f, "sou [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case MUL_INSTR:
					fprintf(f, "mul [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
					break;

				case DIV_INSTR:
					fprintf(f, "div [$%d], [$%d], [$%d]\n", instr->params[0], instr->params[1], instr->params[2]);
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

