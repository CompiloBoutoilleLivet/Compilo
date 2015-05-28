#ifndef SYMTAB_H
#define SYMTAB_H

#define TRUE 1
#define FALSE -1

enum var_type {
	TYPE_UNKNOWN,
	TYPE_INT,
	TYPE_CONST_INT,
	TYPE_TEMP_VAR,
	TYPE_BLOCK
};

struct symbol {
	char *name;
	enum var_type type;
	int is_param;
};

struct symtab {
	unsigned int size; // size of stack
	unsigned int top; // current id of top 0..size-1
	struct symbol **stack;
};

struct symtab *symtab_create(unsigned int size);
int symtab_get_symbol(struct symtab *tab, char *name);
int symtab_symbol_not_exists(struct symtab *tab, char *name);
int symtab_symbol_exists(struct symtab *tab, char *name);
int symtab_add_symbol_notype(struct symtab *tab, char *name);
int symtab_add_symbol_temp(struct symtab *tab);
int symtab_add_symbol_if_not_exists(struct symtab *tab, char *name, enum var_type type);
int symtab_add_symbol(struct symtab *tab, char *name, enum var_type type);
int symtab_pop(struct symtab *tab);
void symtab_push_block(struct symtab *tab);
void symtab_pop_block(struct symtab *tab);
void symtab_printf(struct symtab *tab);
char * symtab_text_type(enum var_type type);
int symtab_add_if_not_exists_in_block(struct symtab *tab, char *name);
int symtab_symbol_exists_in_block(struct symtab *tab, char *name);

struct simple_table {
	unsigned int size;
	unsigned int top;
	int *tab;
};

struct simple_table *table_create(unsigned int size);
int table_add(struct simple_table * tab, int value);
int table_get(struct simple_table * tab, int off);
void table_flush(struct simple_table *tab);

#endif
