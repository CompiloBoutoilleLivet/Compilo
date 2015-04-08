#include "symfun.h"

struct symfun *symbol_function = NULL;

/*
  Create a symbol function table of size `size`
  Returns a ptr to the symfun created
*/
struct symfun *symfun_create(unsigned int size)
{
	unsigned int i;
	struct symfun *ret = NULL;

	ret = malloc(sizeof(struct symfun));
	if(ret == NULL)
	{
		return NULL;
	}

	ret->size = size;
  ret->top = -1;
  ret->current_function = NULL;
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

  if((pos = symfun_get_function(table, name)) == -1){
    ret = malloc(sizeof(struct symbol_function));
    ret->name = name;
    ret->symbol_table = symtab_create(64);
    table->top++;
    pos = table->top;
    table->stack[pos] = ret;
  }
  return pos;
}

int symfun_get_function(struct symfun * table, char * name)
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

void symfun_printf(struct symfun *tab){
	int i;
	struct symbol_function * s;

	printf("----------- Symbole Function (%d) -----------\n",tab->top+1);

	if(tab->top != -1)
	{
		for(i=0;i<=tab->top;i++){
			s = tab->stack[i];
    	printf(" * Name : %s\n",s->name);
      symtab_printf(s->symbol_table);
		}
	}
}
