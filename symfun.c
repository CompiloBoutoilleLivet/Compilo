#include "symfun.h"


/*
  Create a symbol function table of size `size`
  Returns a ptr to the symfun created
*/
struct symfun *symfun_create(unsigned int size)
{
	unsigned int i;
	struct symfun *ret = NULL;

	ret = malloc(sizeof(struct symtab*));
	if(ret == NULL)
	{
		return NULL;
	}

	ret->size = size;
  ret->top = 0;
	ret->stack = malloc(sizeof(struct symbol_function *) * size);
	for(i=0; i<size; i++)
	{
		ret->stack[i] = NULL;
	}

	return ret;
}

/*
  Add function
*/
int symfun_add_function(struct symfun * table, char * name)
{
  struct symbol_function * ret = NULL;
  int pos = -1;

  if(pos = symfun_get_function(table, name) == -1){
    ret = malloc(sizeof(struct symbol_function));
    ret->name = name;

    pos = table->top;
    table->stack[pos] = ret;
    table->top++;
  }
  return pos;
}

int symfun_get_function(struct symbfun * table, char * name)
{
  int i;

  for(i=table->top; i>=0; i--)
  {

    if(table->stack[i]->name != NULL && strcmp(table->stack[i]->name, name) == 0)
    {
      return i;
    }
  }
  return -1;
}
