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

Ca pourrait aussi faciliter les jump conditionels ou non

Je ne sais pas si y'a vraiment un intérêt mais c'est cool
*/

enum instr_type {
	ADD_INSTR,
	MUL_INSTR,
	SOU_INSTR,
	DIV_INSTR,
	COP_INSTR,
	AFC_INSTR,
	JMP_INSTR,
	JMF_INSTR,
	INF_INSTR,
	SUP_INSTR,
	EQU_INSTR,
	PRI_INSTR
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
void instr_emit_sou(int dest, int op1, int op2);
void instr_emit_mul(int dest, int op1, int op2);

#endif