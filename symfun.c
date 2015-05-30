#include "symfun.h"

struct symfun *symbol_function = NULL;

/*
  Create a symbol function table of size `size`
  Returns a ptr to the symfun created
*/
struct symfun *symfun_create(unsigned int size)
{
	unsigned int i;
	struct symfun *ret = NULL;

	ret = malloc(sizeof(struct symfun));
	if(ret == NULL)
	{
		return NULL;
	}

	ret->size = size;
    ret->top = -1;
    ret->current_function = NULL;

	ret->stack = malloc(sizeof(struct symbol_function *) * size);
    if(ret->stack == NULL)
    {
        free(ret);
        return NULL;
    }

	for(i=0; i<size; i++)
	{
		ret->stack[i] = NULL;
	}

	return ret;
}

/*
  Add function
*/
int symfun_add_function(char * name)
{
    struct symbol_function *ret = NULL;
    int pos = -1;

    if((pos = symfun_get_function(name)) == -1)
    {
        ret = malloc(sizeof(struct symbol_function));
        ret->name = name;
        ret->max_symbol = 0;
        ret->symbol_table = symtab_create(64);
        ret->symbol_table_params = symtab_create(64);
        ret->prologue = NULL;
        ret->n_args = -1;
        symbol_function->top++;
        pos = symbol_function->top;
        symbol_function->stack[pos] = ret;
    }

    return pos;
}

void symfun_current_set_prologue(struct instr *instr)
{
    symbol_function->current_function->prologue = instr;
}

struct instr * symfun_current_get_prologue()
{
    return symbol_function->current_function->prologue;
}

int symfun_current_get_max_symbol()
{
    return symbol_function->current_function->max_symbol;
}

int symfun_get_function(char * name)
{
    int i;

    for(i=symbol_function->top; i>=0; i--)
    {
        if(symbol_function->stack[i]->name != NULL && strcmp(symbol_function->stack[i]->name, name) == 0)
        {
            return i;
        }
    }

    return -1;
}

struct symbol_function *symbol_get_function_struct(char *name)
{
    int f;
    if((f = symfun_get_function(name)) != -1)
    {
        return symbol_function->stack[f];
    }
    return NULL;
}

void symfun_current_update_max_symbol(int val)
{
    if(val > symbol_function->current_function->max_symbol)
    {
        symbol_function->current_function->max_symbol = val;
    }
}

void symfun_printf(struct symfun *tab)
{
    int i;
	struct symbol_function * s;

	printf("----------- Symbole Function (%d) -----------\n",tab->top+1);

	if(tab->top != -1)
	{
        for(i=0;i<=tab->top;i++)
        {
            s = tab->stack[i];
            printf(" * Name : %s\n",s->name);
            symtab_printf(s->symbol_table);
		}
	}
}

int symfun_current_add_parameter(char *name)
{
    return symtab_add_if_not_exists_in_block(symbol_function->current_function->symbol_table_params, name);
}

struct symbol * symfun_current_get_param_struct(int i)
{
    return symbol_function->current_function->symbol_table_params->stack[i];
}

struct symbol * symfun_current_get_symbol_struct(int i)
{
    return symbol_function->current_function->symbol_table->stack[i];
}

int symfun_current_get_n_args()
{
    return symbol_function->current_function->n_args;
}

void symfun_current_set_n_args(int i)
{
    symbol_function->current_function->n_args = i;
}

int symfun_current_resolve_n_args()
{
    return symbol_function->current_function->symbol_table_params->top + 1;
}

void symfun_current_flush_symbols()
{
    symtab_flush(symbol_function->current_function->symbol_table_params);
    symtab_flush(symbol_function->current_function->symbol_table);
}

void symfun_current_push_block()
{
    symtab_push_block(symbol_function->current_function->symbol_table);
}

void symfun_current_pop_block()
{
    symtab_pop_block(symbol_function->current_function->symbol_table);
}

int symfun_current_pop()
{
    return symtab_pop(symbol_function->current_function->symbol_table);
}

int symfun_current_parameter_exists(char *name)
{
    return symtab_symbol_exists(symbol_function->current_function->symbol_table_params, name);
}

int symfun_current_add_if_not_exists_in_block(char *name)
{
    int ret = symtab_add_if_not_exists_in_block(symbol_function->current_function->symbol_table, name);
    symfun_current_update_max_symbol(ret);
    return ret;
}

int symfun_current_get_symbol(char *name)
{
    return symtab_get_symbol(symbol_function->current_function->symbol_table, name);
}

int symfun_current_get_param(char *name)
{
    return symtab_get_symbol(symbol_function->current_function->symbol_table_params, name);
}

int symfun_current_add_symbol_temp()
{
    int ret = symtab_add_symbol_temp(symbol_function->current_function->symbol_table);
    symfun_current_update_max_symbol(ret);
    return ret;
}
