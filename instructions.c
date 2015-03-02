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
	struct instr *instr = NULL;
	if(instr_manager != NULL)
	{
		instr = instr_manager->first;
		while(instr != NULL)
		{
			switch(instr->type)
			{

				case COP_INSTR:
					printf("cop [$%d], [$%d]\n", instr->params[0], instr->params[1]);
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
	struct instr *instr = malloc(sizeof(struct instr));
	if(instr != NULL)
	{
		instr->type = COP_INSTR;
		instr->params = malloc(sizeof(int)*2);
		if(instr->params != NULL)
		{
			instr->params[0] = dest;
			instr->params[1] = source;
			instr_emit_instr(instr);
		}
	}
}

