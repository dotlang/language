#define _XOPEN_SOURCE 500 /* Enable certain library functions (strdup) on linux.  See feature_test_macros(7) */

#include <stdlib.h>
#include <stdio.h>
#include <limits.h>
#include <string.h>


typedef struct entry_s {
	char *key;
	void *value;
	struct entry_s *next;
} entry_t;

typedef struct hashtable_s {
	int size;
	struct entry_s **table;	
} hashtable_t;

/* Create a new hashtable. */
hashtable_t *ht_create( int size );
int ht_set( hashtable_t *hashtable, char *key, void *value );
void *ht_get( hashtable_t *hashtable, char *key );

//private
int ht_hash( hashtable_t *hashtable, char *key );
//private
entry_t *ht_newpair( char *key, void *value );

