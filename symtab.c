#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct symtab *symbol_table = NULL;

struct symtab *symtab_create(unsigned int size)
{
	unsigned int i;
	struct symtab *ret = NULL;

	ret = malloc(sizeof(struct symtab*));
	if(ret == NULL)
	{
		return NULL;
	}

	ret->size = size;
	ret->top = -1;
	ret->stack = malloc(sizeof(struct symbol *) * size);
	for(i=0; i<size; i++)
	{
		ret->stack[i] = NULL;
	}

	return ret;
}

int symtab_symbol_exists(struct symtab *tab, char *name)
{
	int ret = -1;
	int i;

	for(i=tab->top; i>=0; i--)
	{
		if(strcmp(tab->stack[i]->name, name) == 0)
		{
			ret = 0;
			break;
		}
	}

	return ret;
}

int symtab_add_symbol_notype(struct symtab *tab, char *name)
{
	return symtab_add_symbol(tab, name, UNKNOWN);
}

int symtab_add_symbol(struct symtab *tab, char *name, enum var_type type)
{
	struct symbol *s = malloc(sizeof(struct symbol));
	if(s == NULL)
	{
		return -1;
	}

	s->name = name;
	s->type = type;

	if(tab->top == tab->size+1) // full stack :(
	{
		free(s);
		return -1;
	}

	tab->top++;
	tab->stack[tab->top] = s;

	return tab->top;
}
