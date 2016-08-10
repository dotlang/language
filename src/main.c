
#include <stdio.h>
#include <stdlib.h>

#include "common.h"
#include "hash.h"
#include <jit/jit.h>
#include "parser.tab.h"  // to get the token types that we return

int jit_file(char* filePath);

extern FILE *yyin;
jit_state state;
extern int yydebug;

int main(int argc, char** argv) {
    /* yydebug=1; */
    start_jit();
    int status = jit_file(argv[1]);
    end_jit();

    //exit if there is error
    if ( status != 0 ) return status;

    int result = start_execute();

    end_execute();
    
    return result;
}

int jit_file(char* filePath) {
    FILE *myfile = fopen(filePath, "r");
    // make sure it is valid:
    if (!myfile) {
        printf("cannot open input file %s\n", filePath);
        return -1;
    }

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

void assertion_failure_handler()
{
    printf("ASSERTION FAILED!\n");
    exit(254);
}
