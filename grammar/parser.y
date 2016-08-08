%{
#include <stdio.h>
#include <stdlib.h>

#include "hash.h"
#include "common.h"
#include <jit/jit.h>
#include "parser.tab.h"  // to get the token types that we return

void yyerror(YYLTYPE *locp, const char *s);

// stuff from flex that bison needs to know about:
extern int yyparse();
extern int yylex(YYSTYPE* yylval, YYLTYPE* yylloc);
extern FILE *yyin;
extern char* yytext;
extern jit_state state;

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
                leave_function();
            }
            ;

MethodDecl: TYPE { } IDENTIFIER 
            {
                enter_function(yytext);
            } '(' ')' 
            {
                jit_type_t params[0];

                jit_type_t signature;
                signature = jit_type_create_signature
                    (jit_abi_cdecl, jit_type_int, params, 0, 1);

                state.current_function = jit_function_create(state.context, signature);
            }
            CodeBlock
            {
            }
            ;

CodeBlock: '{' RETURN NUMBER 
            { 
                jit_value_t temp;
                int retVal = atoi(yytext);
                temp = jit_value_create_nint_constant(state.current_function, jit_type_int, retVal);

                jit_insn_return(state.current_function, temp);
            }';' '}'
            {
            }
            ;

%%

void yyerror(YYLTYPE *locp, const char *s) {
    if ( locp->first_line == locp->last_line ) {
        printf("Error at line %d column %d: %s\n", locp->first_line, locp->first_column, s);
    } else {
        printf("Error at lines (%d to %d) columns (%d to %d): %s\n", locp->first_line, locp->last_line, locp->first_column, locp->last_column, s);
    }

    state.has_error = 1;
}
