#include <jit/jit.h>
#include "hash.h"

//shortcut for current function
#define CFN state.env.function


typedef struct
{
    jit_function_t  function;

    //this is updated when we enter the function and
    //re-used as the key when storing compiled function
    //in function table
    char            function_name[100];
    hashtable_t     *local_vars;
} jit_env;

typedef struct
{
    jit_context_t   context;
    hashtable_t     *function_table;
    int             has_error;
    jit_env         env;

} jit_state;

/* JIT Processing */
void start_jit();
void end_jit();
void end_execute();
int start_execute();

/* Function Processing */
void start_function(char* name);
void end_function();
jit_function_t find_function(char* name);

/* Local Variable Processing */
void define_local_var(char* name);
jit_value_t get_local_var(char* name);
void update_local_var(char* name, jit_value_t value);
