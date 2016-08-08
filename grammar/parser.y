%{
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include <jit/jit.h>
#include "parser.tab.h"  // to get the token types that we return

// stuff from flex that bison needs to know about:
extern int yyparse();
extern int yylex(YYSTYPE* yylval, YYLTYPE* yylloc);
extern FILE *yyin;
extern jit_function_t main_function;
extern int yylineno;
extern char* yytext;
extern jit_context_t context;
extern jit_function_t function;

hashtable_t *symtable;
char current_function_name[100];
extern int hasError;

void yyerror(YYLTYPE *locp, const char *s);
%}

%locations
%define parse.error verbose
%define api.pure full


%token IDENTIFIER
%token NUMBER
%token RETURN
%token TYPE

%start SourceFile

%%

SourceFile: MethodDecl
            {
                ht_set(symtable, current_function_name, function);
            }
            ;

MethodDecl: TYPE { } IDENTIFIER 
            {
                strcpy(current_function_name, yytext);
            } '(' ')' 
            {
                jit_type_t params[0];

                jit_type_t signature;
                signature = jit_type_create_signature
                    (jit_abi_cdecl, jit_type_int, params, 0, 1);

                function = jit_function_create(context, signature);
            }
            CodeBlock
            {
            }
            ;

CodeBlock: '{' RETURN NUMBER 
            { 
                jit_value_t temp;
                int retVal = atoi(yytext);
                temp = jit_value_create_nint_constant(function, jit_type_int, retVal);

                jit_insn_return(function, temp);
                /* printf("number to return is %s\n", yytext); */ 
            }';' '}'
            {
                jit_function_compile(function);
                main_function = function;
            }
            ;

%%

void yyerror(YYLTYPE *locp, const char *s) {
    if ( locp->first_line == locp->last_line ) {
        printf("Error at line %d column %d: %s\n", locp->first_line, locp->first_column, s);
    } else {
        printf("Error at lines (%d to %d) columns (%d to %d): %s\n", locp->first_line, locp->last_line, locp->first_column, locp->last_column, s);
    }

    hasError = 1;
}
