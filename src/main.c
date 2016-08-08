
#include <stdio.h>
#include <stdlib.h>

#include "common.h"
#include "hash.h"
#include <jit/jit.h>
#include "parser.tab.h"  // to get the token types that we return

int processFile(char* filePath);

extern FILE *yyin;
jit_state state;

int main(int argc, char** argv) {
    begin_compilation();
    int status = processFile(argv[1]);

    int result = execute_main_function();

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

    if ( state.has_error ) {
        printf("Compilation failed!");
        return -1;
    }

    return 0;
}
