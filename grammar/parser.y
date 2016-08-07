%{
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include "parser.tab.h"  // to get the token types that we return

// stuff from flex that bison needs to know about:
extern int yyparse();
extern int yylex(YYSTYPE* yylval, YYLTYPE* yylloc);
extern FILE *yyin;

extern int yylineno;
extern char* yytext;

hashtable_t *symtable;

void yyerror(YYLTYPE *locp, const char *s);
%}

%locations
%define parse.error verbose
%define api.pure full

%token IDENTIFIER
%token NUMBER
%token RETURN
%token TYPE

%start PROGRAM

%%

PROGRAM :   MethodDecl
            {
            };

MethodDecl: TYPE IDENTIFIER '(' ')' CodeBlock
            {
            };

CodeBlock: '{' RETURN NUMBER ';' '}'
            {
            };

%%

int main(int argc, char** argv) {
    // open a file handle to a particular file:
    FILE *myfile = fopen(argv[1], "r");
    // make sure it is valid:
    if (!myfile) {
        printf("cannot open input file %s\n", argv[1]);
        return -1;
    }

    /* symtable = ht_create(1000); */

    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    return 0;
}

void yyerror(YYLTYPE *locp, const char *s) {
    if ( locp->first_line == locp->last_line ) {
        printf("Error at line %d column %d: %s\n", locp->first_line, locp->first_column, s);
    } else {
        printf("Error at lines (%d to %d) columns (%d to %d): %s\n", locp->first_line, locp->last_line, locp->first_column, locp->last_column, s);
    }
    
    exit(-1);
}
