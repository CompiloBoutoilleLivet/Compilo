#ifndef INSTRUCTIONS_H
#define INSTRUCTIONS_H

/*
Idée : faire une sorte d'instruction manager
Celui ci contient une liste chainée des instructions émisent par
le parser. A partir de cette liste chainée, il est possible de générer
un fichier avec les instructions sous forme textuelle ou alors
les instructions directement sous forme de bytecode. On pourrait imaginer
interpréter directement la liste d'instructions, on aurait alors un
langage interprété.
Je ne sais pas si y'a vraiment un intérêt mais j'aime bien le concept.
*/

enum instr_type {
	COP_INSTR,
	AFC_INSTR,
	ADD_INSTR
};

struct instr
{
	enum instr_type type;
	int *params;
	struct instr *next;
};

struct instr_manager
{
	unsigned int count;
	struct instr *first;
	struct instr *last;
};

void instr_manager_init();
void instr_manager_print_textual();
void instr_manager_print_textual_file(FILE *f);
void instr_emit_cop(int dest, int source);
void instr_emit_afc(int dest, int value);
void instr_emit_add(int dest, int op1, int op2);

#endif