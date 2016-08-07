#include "list.h"

/* Create a new hashtable. */
list_t *ll_create() {
	list_t* list = NULL;

	/* Allocate the list itself. */
	if( ( list = malloc( sizeof( list_t ) ) ) == NULL ) {
		return NULL;
	}

	list->head = NULL;
	return list;
}

int ll_push( list_t *list, void *value ) {
    node_t * current = list->head;

    if ( current == NULL ) {
        current = malloc(sizeof(node_t));
        current->value = value;
        current->next = NULL;
        list->head = current;
        return;
    }

    while (current->next != NULL) {
        current = current->next;
    }

    /* now we can add a new variable */
    current->next = malloc(sizeof(node_t));
    current->next->value = value;
    current->next->next = NULL;
}

void *ll_pop( list_t* list) {
}

/* Hash a string for a particular hash table. */
int ht_hash( hashtable_t *hashtable, char *key ) {

	unsigned long int hashval;
	int i = 0;

	/* Convert our string to an integer */
	while( hashval < ULONG_MAX && i < strlen( key ) ) {
		hashval = hashval << 8;
		hashval += key[ i ];
		i++;
	}

	return hashval % hashtable->size;
}

/* Create a key-value pair. */
entry_t *ht_newpair( char *key, void *value ) {
	entry_t *newpair;

	if( ( newpair = malloc( sizeof( entry_t ) ) ) == NULL ) {
		return NULL;
	}

	if( ( newpair->key = strdup( key ) ) == NULL ) {
		return NULL;
	}

    newpair->value = value;
	newpair->next = NULL;

	return newpair;
}

/* Insert a key-value pair into a hash table. */
int ht_set( hashtable_t *hashtable, char *key, void *value ) {
	entry_t *newpair = NULL;
	entry_t *last = NULL;

	int bin = ht_hash( hashtable, key );

	entry_t* next = hashtable->table[ bin ];

	while( next != NULL && next->key != NULL && strcmp( key, next->key ) > 0 ) {
		last = next;
		next = next->next;
	}

	/* There's already a pair with the same key. this is an error */
	if( next != NULL && next->key != NULL && strcmp( key, next->key ) == 0 ) {
        return 0;
	/* Nope, could't find it.  Time to grow a pair. */
	} else {
		newpair = ht_newpair( key, value );

		/* We're at the start of the linked list in this bin. */
		if( next == hashtable->table[ bin ] ) {
			newpair->next = next;
			hashtable->table[ bin ] = newpair;
	
		/* We're at the end of the linked list in this bin. */
		} else if ( next == NULL ) {
			last->next = newpair;
	
		/* We're in the middle of the list. */
		} else  {
			newpair->next = next;
			last->next = newpair;
		}
	}

	return 1;
}

/* Retrieve a key-value pair from a hash table. */
void *ht_get( hashtable_t *hashtable, char *key ) {
	int bin = 0;
	entry_t *pair;

	bin = ht_hash( hashtable, key );

	/* Step through the bin, looking for our value. */
	pair = hashtable->table[ bin ];
	while( pair != NULL && pair->key != NULL && strcmp( key, pair->key ) > 0 ) {
		pair = pair->next;
	}

	/* Did we actually find anything? */
	if( pair == NULL || pair->key == NULL || strcmp( key, pair->key ) != 0 ) {
		return NULL;

	} else {
		return pair->value;
	}
}
