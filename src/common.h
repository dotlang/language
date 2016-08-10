#include <jit/jit.h>
#include "hash.h"

//shortcut for current function
#define CFN state.env.function

#define ONLY_BOOL(x) if ( get_local_var_type((x)) != find_type("bool")) {\
                         printf("Only bool is accepted for %s", x); \
                         exit(5); \
                     }

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
void define_local_var(char* type_name, char* name);
jit_value_t get_local_var(char* name);
void update_local_var(char* name, jit_value_t value);

jit_type_t find_type(char* type_name);
jit_type_t get_local_var_type(char* name);
jit_value_t create_const(char* var_name, char* value);
jit_value_t create_const_by_data_type(jit_type_t data_type, char* value);

