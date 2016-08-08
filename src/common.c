#include <jit/jit.h>
#include "common.h"

extern jit_state state;

void begin_compile_function(char* name) 
{
   strcpy(state.env.function_name, name);
}

void end_compile_current_function()
{
    jit_function_compile(state.env.function);
    ht_set(state.function_table, state.env.function_name, state.env.function);
}

void begin_compilation()
{
    state.function_table = ht_create(1000);
    state.context = jit_context_create();
}

void end_compilation()
{
    jit_context_build_end(state.context);
}

void end_execution()
{
    jit_context_destroy(state.context);
    ht_destroy(state.function_table);
}

jit_function_t find_function(char* name)
{
    return (jit_function_t) ht_get(state.function_table, name);
}

int execute_main_function()
{
    jit_int result;
    jit_function_t main_function = find_function("main");

    if ( main_function == NULL ) {
        printf("No function 'main' found!");
        exit(-1);
    }

    jit_function_apply(main_function, NULL, &result);

    return (int)result;
}
