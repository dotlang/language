
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include <jit/jit.h>
#include "parser.tab.h"  // to get the token types that we return

int processFile(char* filePath);

extern FILE *yyin;
extern hashtable_t *symtable;
int hasError = 0;
jit_context_t context = NULL;
jit_function_t function = NULL;
jit_function_t main_function = NULL;

int main(int argc, char** argv) {
    symtable = ht_create(1000);

    context = jit_context_create();
    int status = processFile(argv[1]);

    jit_context_build_end(context);

    jit_int result;
    jit_function_t main_function = (jit_function_t) ht_get(symtable, "main");
    if ( main_function == NULL ) {
        printf("No function 'main' found!");
        exit(-1);
    }

    jit_function_apply(main_function, NULL, &result);

    jit_context_destroy(context);

    return (int)result;
}

int processFile(char* filePath) {
    FILE *myfile = fopen(filePath, "r");
    // make sure it is valid:
    if (!myfile) {
        printf("cannot open input file %s\n", filePath);
        return -1;
    }

    /* symtable = ht_create(1000); */

    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    if ( hasError ) {
        printf("Compilation failed!");
        return -1;
    }

    return 0;
}
