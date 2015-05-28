#ifndef SYMFUN_H
#define SYMFUN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct symbol_function
{
	struct symtab * symbol_table;
	struct symtab * symbol_table_params;
	unsigned int max_symbol;
	char * name;
};

struct symfun
{
	unsigned int size; // size of stack
	unsigned int top;
	struct symbol_function *current_function;
	struct symbol_function **stack;
};

struct symfun *symfun_create(unsigned int size);
int symfun_add_function(struct symfun *table, char *name);
int symfun_get_function(struct symfun *table, char *name);
int symfun_function_is_max_symbol(struct symbol_function *table, int val);
void symfun_printf(struct symfun *tab);

#endif /* SYMFUN_H */
