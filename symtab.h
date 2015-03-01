#ifndef SYMTAB_H
#define SYMTAB_H

#define TRUE 1
#define FALSE -1

enum var_type {
	TYPE_UNKNOWN,
	TYPE_INT,
	TYPE_CONST_INT
};

struct symbol {
	char *name;
	enum var_type type;
};

struct symtab {
	unsigned int size; // size of stack
	unsigned int top; // current id of top 0..size-1
	struct symbol **stack;
};

struct symtab *symtab_create(unsigned int size);
int symtab_get_symbol(struct symtab *tab, char *name);
int symtab_add_if_not_exists(struct symtab *tab, char *name);
int symtab_symbol_not_exists(struct symtab *tab, char *name);
int symtab_symbol_exists(struct symtab *tab, char *name);
int symtab_add_symbol_notype(struct symtab *tab, char *name);
int symtab_add_symbol(struct symtab *tab, char *name, enum var_type type);

#endif