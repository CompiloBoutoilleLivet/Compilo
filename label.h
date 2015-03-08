#ifndef LABEL_H
#define LABEL_H

/*
Gère les labels ...
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