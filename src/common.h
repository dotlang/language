#include <jit/jit.h>
#include "hash.h"

typedef struct
{
    jit_function_t  function;

    //this is updated when we enter the function and
    //re-used as the key when storing compiled function
    //in function table
    char            function_name[100];
    jit_value_t     exp_value;
    hashtable_t     *local_vars;
} jit_env;

typedef struct
{
    jit_context_t   context;
    hashtable_t     *function_table;
    int             has_error;
    jit_env         env;

} jit_state;

void begin_compilation();
void end_compilation();
void end_execution();
jit_function_t find_function(char* name);
int execute_main_function();

void begin_compile_function(char* name);
void end_compile_current_function();

