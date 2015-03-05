#include <stdio.h>
#include <stdlib.h>
#include "label.h"

int num_label = 0;

int label_get_next_label(){
	num_label++;
	return num_label;
}

struct label_stack * label_stack_init(){
	return malloc(sizeof(struct label_stack));
}

int label_push(struct label_stack * stack){
	struct label_element * new = (struct label_element *) malloc(sizeof(struct label_element));

	if(stack == NULL){
		fprintf(stderr,"label pop : null stack ...\n");
		exit(-1);
	}

	new->num_label = label_get_next_label();
	new->next = stack->first;
	stack->first = new;
	return -1 * new->num_label;
}

int label_pop(struct label_stack * stack){
	struct label_element * old;
	
	if(stack == NULL){
		fprintf(stderr,"label pop : null stack ...\n");
		exit(-1);
	}

	if(stack->first == NULL){
		fprintf(stderr,"label pop : empty stack ...\n");
		exit(-1);
	}
	
	old = stack->first;
	stack->first = old->next;

	return -1 * old->num_label;
}
