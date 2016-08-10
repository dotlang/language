#include <jit/jit.h>
#include <jit/jit-dump.h>
#include "common.h"

extern jit_state state;

void start_function(char* name)
{
   strcpy(state.env.function_name, name);
}

void end_function()
{
    jit_dump_function(stdout, state.env.function, state.env.function_name);

    jit_function_compile(state.env.function);
    ht_set(state.function_table, state.env.function_name, state.env.function);
    ht_destroy(state.env.local_vars);
}

void start_jit()
{
    state.function_table = ht_create(1000);
    state.env.local_vars = ht_create(1000);
    state.context = jit_context_create();
}

void end_jit()
{
    jit_context_build_end(state.context);
}

void end_execute()
{
    jit_context_destroy(state.context);
    ht_destroy(state.function_table);
}

int start_execute()
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

jit_function_t find_function(char* name)
{
    return (jit_function_t) ht_get(state.function_table, name);
}

jit_value_t create_const_by_data_type(jit_type_t data_type, char* value)
{
    return jit_value_create_nint_constant(state.env.function, data_type, atoi(value));
}

jit_value_t create_const(char* var_name, char* value)
{
    jit_type_t data_type = get_local_var_type(var_name);
    return create_const_by_data_type(data_type, value);
}

void define_local_var(char* type_name, char* name)
{
    jit_type_t data_type = find_type(type_name);

    jit_value_t zero = create_const_by_data_type(data_type, "0");
    jit_value_t variable = jit_value_create(state.env.function, data_type);
    jit_insn_store(state.env.function, variable, zero);

    ht_set(state.env.local_vars, name, variable);
}

jit_type_t get_local_var_type(char* name) 
{
    jit_value_t var = get_local_var(name);
    return jit_value_get_type(var);
}

jit_value_t get_local_var(char* name)
{
    return ht_get(state.env.local_vars, name);
}

void update_local_var(char* name, jit_value_t new_value)
{
    jit_value_t current = get_local_var(name);

    jit_insn_store(state.env.function, current, new_value);
}

jit_type_t find_type(char* type_name)
{
    if ( !strcmp(type_name, "int") ) return jit_type_int;
    if ( !strcmp(type_name, "bool") ) return jit_type_ubyte;


    exit(41);
}
