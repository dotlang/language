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

void begin_compilation();
void end_compilation();
void end_execution();
jit_function_t find_function(char* name);
int execute_main_function();

void begin_compile_function(char* name);
void end_compile_current_function();

