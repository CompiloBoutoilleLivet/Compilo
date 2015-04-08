#ifndef SYMFUN_H
#define SYMFUN_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "symtab.h"

struct symbol_function {
  struct symtab * symbol_table;
  char * name;
};

struct symfun {
	unsigned int size; // size of stack
  unsigned int top;
	struct symbol_function **stack;
};

struct symfun *symtab_create(unsigned int size);
int symfun_add_function(struct symfun * table, char * name);
int symfun_get_function(struct symbfun * table, char * name);

#endif /* SYMFUN_H */
