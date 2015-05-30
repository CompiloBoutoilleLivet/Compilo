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
	struct instr * prologue;
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
void symfun_printf(struct symfun *tab);

int symfun_current_get_max_symbol();
void symfun_current_set_prologue(struct instr *instr);
struct instr * symfun_current_get_prologue();
int symfun_current_add_parameter(char *name);
struct symbol * symfun_current_get_param_struct(int i);
struct symbol * symfun_current_get_symbol_struct(int i);
int symfun_current_get_symbol(char *name);
int symfun_current_get_param(char *name);
void symfun_current_flush_symbols();
void symfun_current_push_block();
void symfun_current_pop_block();
int symfun_current_pop();
int symfun_current_parameter_exists(char *name);
int symfun_current_add_if_not_exists_in_block(char *name);
void symfun_current_update_max_symbol(int val);
int symfun_current_add_symbol_temp();

#endif /* SYMFUN_H */
