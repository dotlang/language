#include <jit/jit.h>
#include "common.h"

extern jit_state state;

void enter_function(char* name) 
{
   strcpy(state.current_function_name, name);
}

void leave_function()
{
    jit_function_compile(state.current_function);
    ht_set(state.function_table, state.current_function_name, state.current_function);
}
