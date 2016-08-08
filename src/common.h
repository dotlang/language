#include <jit/jit.h>
#include "hash.h"

typedef struct
{
    jit_context_t   context;
    jit_function_t  current_function;
    char            current_function_name[100];
    hashtable_t     *function_table;
    int             has_error;
} jit_state;

void enter_function(char* name);
void leave_function();

