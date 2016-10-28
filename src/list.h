#define _XOPEN_SOURCE 500 /* Enable certain library functions (strdup) on linux.  See feature_test_macros(7) */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>


typedef struct node {
	void* value;
	struct node* next;
} node_t;

typedef struct list_t {
	struct node_t* head;
	struct node_t* tail;
} list_t;

/* Create a new hashtable. */
list_t *ll_create();
int ll_push( list_t *list, void *value );
void *ll_pop( list_t* list);

