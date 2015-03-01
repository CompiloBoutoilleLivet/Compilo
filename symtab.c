#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct symtab *symbol_table = NULL;

/*
Create a symbol table of size `size`
Returns a ptr to the symtab created
*/
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

/*
Returns the first symbol offset in `tab` which had `name`
*/
int symtab_get_symbol(struct symtab *tab, char *name)
{
	int ret = FALSE;
	int i;

	for(i=tab->top; i>=0; i--)
	{
		if(tab->stack[i]->name != NULL && strcmp(tab->stack[i]->name, name) == 0)
		{
			ret = i;
			break;
		}
	}

	return ret;
}

/*
Add symbol `name` on `tab` only if it doesn't exists yet
The symbol had no specific type (TYPE_UNKNOWN)
Returns - FALSE if the symbol is not added for any reason
        - the offset on the symtab if there is no problem

*/
int symtab_add_if_not_exists(struct symtab *tab, char *name)
{
	int ret = FALSE;

	if(symtab_symbol_not_exists(tab, name) == TRUE)
	{
		ret = symtab_add_symbol_notype(tab, name);
	}

	return ret;
}

/*
Returns - TRUE if the symbol not exists in tab
		- FALSE if the symbol exists in tab
*/
int symtab_symbol_not_exists(struct symtab *tab, char *name)
{
	return symtab_symbol_exists(tab, name) == TRUE ? FALSE : TRUE;
}

/*
Returns - TRUE if the symbol exists in tab
		- FALSE if the symbol not exists in tab
*/
int symtab_symbol_exists(struct symtab *tab, char *name)
{
	int ret = FALSE;
	int i;

	for(i=tab->top; i>=0; i--)
	{
		if(tab->stack[i]->name != NULL && strcmp(tab->stack[i]->name, name) == 0)
		{
			ret = TRUE;
			break;
		}
	}

	return ret;
}

/*
Add symbol `name` on `tab` with no specific type (TYPE_UNKNOWN)
Returns - FALSE if the symbol is not added for any reason
        - the offset on the symtab if there is no problem
*/
int symtab_add_symbol_notype(struct symtab *tab, char *name)
{
	return symtab_add_symbol(tab, name, TYPE_UNKNOWN);
}

int symtab_add_symbol_temp(struct symtab *tab)
{
	return symtab_add_symbol(tab, NULL, TYPE_TEMP_VAR);
}

int symtab_pop(struct symtab *tab)
{
	int ret = tab->top;
	free(tab->stack[tab->top]);
	tab->top--;
	return ret;
}

/*
Add symbol `name` with type `type` to the symtab
Returns - FALSE if the symbol is not added for any reason
        - the offset on the symtab if there is no problem
*/
int symtab_add_symbol(struct symtab *tab, char *name, enum var_type type)
{
	struct symbol *s = malloc(sizeof(struct symbol));
	if(s == NULL)
	{
		return FALSE;
	}

	s->name = name;
	s->type = type;

	if(tab->top == tab->size+1) // full stack :(
	{
		free(s);
		return FALSE;
	}

	tab->top++;
	tab->stack[tab->top] = s;

	return tab->top;
}

void symtab_printf(struct symtab *tab){
	int i;
	struct symbol * s;

	printf("------ Symbole Table (%d) -----\n",tab->top+1);
	printf(" Id  |      Type      |  Name\n");
		printf("-----|----------------|-------\n");
	for(i=0;i<=tab->top;i++){
		s = tab->stack[i];
		printf("  %d  |%s|  %s \n", i, symtab_text_type(s->type), s->name);
	}
}

char * symtab_text_type(enum var_type type){
		switch(type){
				default:
				case TYPE_UNKNOWN:
					return " TYPE_UNKNOWN   ";
				case TYPE_INT:
					return " TYPE_INT       ";
				case TYPE_CONST_INT:
					return " TYPE_CONST_INT ";
				case TYPE_TEMP_VAR:
					return " TYPE_TEMP_VAR  ";
		}
}
