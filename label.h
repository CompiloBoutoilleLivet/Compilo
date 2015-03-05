#ifndef LABEL_H
#define LABEL_H

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

struct label_element
{
	unsigned int num_label;
	struct label_element * next;
};

struct label_stack
{
	struct label_element * first;
};


int label_get_next_label();
struct label_stack * label_stack_init();
int label_push(struct label_stack * stack);
int label_pop(struct label_stack * stack);

#endif 