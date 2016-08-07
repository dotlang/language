%{
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"

// stuff from flex that bison needs to know about:
extern int yyparse();
extern int yylex();
extern FILE *yyin;

hashtable_t *symtable;

 
void yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
    char chr;
}

%token ENDL
%token EQ

%token  <sval>  IDENTIFIER
%token  <ival>  NUMBER
%token  <chr>   OPERATOR

%type   <ival>  postfix_expression
%type   <ival>  primary_expression

%start PROGRAM

%%

PROGRAM :   |
            LINE PROGRAM ENDL
            ;

LINE:       |
            IDENTIFIER EQ postfix_expression {
                printf("Assigning %d to %s\n", $3, $1);
                int* value = (int*)malloc(sizeof(int));
                (*value) = $3;

                ht_set(symtable, $1, value);


                void* xvalue = ht_get(symtable, $1);
                if ( xvalue == NULL ) {
                    printf("WOWCannot find symbol %s", $1);
                    exit(-1);
                }
                printf("value of %s is %d\n", $1, *(int*)xvalue); 
            }
            |
            postfix_expression {
            }
            ;
primary_expression
            : NUMBER {
                $$ = $1;
            }
            | IDENTIFIER {
                void* value = ht_get(symtable, $1);

                if ( value == NULL ) {
                    printf("Cannot find symbol %s", $1);
                    exit(-1);
                }

                $$ = *(int*)value;
                printf("Assigned $$ to $1\n");
            }
            ;
postfix_expression
            : primary_expression {
                $$ = $1;
            }
            | postfix_expression OPERATOR postfix_expression { 
                if ( $2 == '+' ) {
                    $$ = $1+$3;
                    printf("%d + %d = %d\n", $1, $3, $$);
                }
                if ( $2 == '-' ) {
                    $$ = $1-$3;
                    printf("%d - %d = %d\n", $1, $3, $$);
                }
                if ( $2 == '*' ) {
                    $$=$1*$3;
                    printf("%d * %d = %d\n", $1, $3, $$);
                }
                if ( $2 == '/' ) {
                    $$=$1/$3;
                    printf("%d / %d = %d\n", $1, $3, $$);
                }
            }
            ;

%%

int main(int argc, char** argv) {
    // open a file handle to a particular file:
    FILE *myfile = fopen(argv[1], "r");
    // make sure it is valid:
    if (!myfile) {
        printf("cannot open input file %s\n", argv[1]);
        return -1;
    }

    symtable = ht_create(1000);

    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
}

void yyerror(const char *s) {
    printf("EEK. parse error! message: %s\n", s);
    // might as well halt now:
    exit(-1);
}
