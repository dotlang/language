#include "hash.h"

/* Create a new hashtable. */
hashtable_t *ht_create( int size ) {

	hashtable_t *hashtable = NULL;
	int i;

	if( size < 1 ) return NULL;

	/* Allocate the table itself. */
	if( ( hashtable = malloc( sizeof( hashtable_t ) ) ) == NULL ) {
		return NULL;
	}

	/* Allocate pointers to the head nodes. */
	if( ( hashtable->table = malloc( sizeof( entry_t * ) * size ) ) == NULL ) {
		return NULL;
	}
	for( i = 0; i < size; i++ ) {
		hashtable->table[i] = NULL;
	}

	hashtable->size = size;

	return hashtable;	
}

void ht_destroy(hashtable_t* ht) {
    if ( ht == NULL ) return;

    for(int i=0;i<ht->size;i++) {
        entry_t* list = ht->table[i];
        entry_t* temp = NULL;

        while ( list != NULL ) {
            temp = list;
            list = list->next;
            free(temp);
        }
    }

    free(ht->table);
    free(ht);
    ht = NULL;
}

/* Hash a string for a particular hash table. */
int ht_hash( hashtable_t *hashtable, char *key ) {

	unsigned long int hashval = 0;
	int i = 0;

	/* Convert our string to an integer */
	while( hashval < ULONG_MAX && i < strlen( key ) ) {
		hashval = hashval << 8;
		hashval += key[ i ];
		i++;
	}

	/* printf("hash value for %s(%d) is %d\n", key, strlen(key), hashval); */

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
	/* printf("ht_set at bin %d\n", bin); */

	entry_t* next = hashtable->table[ bin ];

	while( next != NULL && next->key != NULL && strcmp( key, next->key ) > 0 ) {
		last = next;
		next = next->next;
	}

	/* There's already a pair with the same key. this is an error */
	if( next != NULL && next->key != NULL && strcmp( key, next->key ) == 0 ) {
	    /* printf("ret0 for %s\n", key); */
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
	/* printf("get from bin %d\n", bin); */

	/* Step through the bin, looking for our value. */
	pair = hashtable->table[ bin ];
	while( pair != NULL && pair->key != NULL && strcmp( key, pair->key ) > 0 ) {
		pair = pair->next;
	}

	/* Did we actually find anything? */
	if( pair == NULL || pair->key == NULL || strcmp( key, pair->key ) != 0 ) {
	    /* printf("get - not found for %s\n", key); */
		return NULL;

	} else {
	    /* printf("get - found for %s\n", key); */
		return pair->value;
	}
}
