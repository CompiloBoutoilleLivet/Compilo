#include <stdio.h>
#include <stdlib.h>
#include "label.h"

int num_label = 0;

int label_get_next_label(){
	num_label++;
	return num_label;
}

int label_get_next_tmp_label(){
	return label_get_next_label() * -1;
}
