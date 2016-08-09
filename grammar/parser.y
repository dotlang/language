%{
#define YYDEBUG 1

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

%union {
    char *str;
    jit_value_t value;
    jit_label_t label;
}


%token <str> IDENTIFIER
%token <str> NUMBER
%token RETURN
%token IF
%token TYPE

%type <value> Expression
%type <label> IfStmt
%type <value> Condition


/* source for operator settings: http://en.cppreference.com/w/c/language/operator_precedence */
/* higher = lower precedence */
%right '='
%left EQ
%left '+' '-'
%left '*' '/'
%left '('
%left ')'

%start SourceFile

%%

SourceFile: MethodDecl
          {
                end_compile_current_function();
            }
            ;

MethodDecl: TYPE IDENTIFIER
          {
                begin_compile_function(yytext);
            } 
            '(' ')' 
            {
                jit_type_t params[0];

jit_type_t signature;
                signature = jit_type_create_signature
                    (jit_abi_cdecl, jit_type_int, params, 0, 1);

state.env.function = jit_function_create(state.context, signature);
                jit_type_free(signature);
            }
            CodeBlock
            ;

CodeBlock:  '{' 
         StmtGroup
            { 
            }
            ';' '}'
            {
            }
            ;

StmtGroup:  ReturnStmt StmtGroup
         |
            VarDecl StmtGroup
            |
            IfStmt StmtGroup
            {
            }
            |
            {} ;
IfStmt:     IF '(' Condition ')' 
      {
                $<label>$ = jit_label_undefined;
                jit_value_t condition_result = $3;

                jit_insn_branch_if_not(state.env.function, condition_result, &$<label>$);
            }
            ReturnStmt ';'
            {
            //Here $<label>5 means the 'label' data item which was set by 5th component in this rule 
            //and the 5th component was the code block after "Condition ')'".
               jit_insn_label(state.env.function, &$<label>5);
            };
Condition:  IDENTIFIER EQ Expression
         {
                jit_value_t variable = ht_get(state.env.local_vars, $1);
                jit_value_t exp = $3;

                $$ = jit_insn_eq(state.env.function, variable, exp);
            };
VarDecl:    TYPE IDENTIFIER '=' NUMBER ';'
       {
                jit_value_t variable = jit_value_create(state.env.function, jit_type_int);
                jit_value_t r_value = jit_value_create_nint_constant(state.env.function, jit_type_int, atoi($4));
                jit_insn_store(state.env.function, variable, r_value);

//keep track of 
                ht_set(state.env.local_vars, $2, variable);
            };
ReturnStmt: RETURN Expression
            {
                jit_insn_return(state.env.function, $2);
            } ;
Expression: Expression '+' Expression
            {
                $$ = jit_insn_add(state.env.function, $1, $3);
            }
            |
            Expression '-' Expression
            {
                $$ = jit_insn_sub(state.env.function, $1, $3);
            }
            |
            Expression '*' Expression
            {
                $$ = jit_insn_mul(state.env.function, $1, $3);
            }
            |
            Expression '/' Expression
            {
                $$ = jit_insn_div(state.env.function, $1, $3);
            }
            |
            '(' Expression ')'
            {
                $$ = $2;
            }
            |  
            NUMBER
            {
                $$ = jit_value_create_nint_constant(state.env.function, jit_type_int, atoi($1));
            }
            |
            IDENTIFIER
            {
                jit_value_t variable = ht_get(state.env.local_vars, $1);
                $$ = variable;
            } ;

%%

void yyerror(YYLTYPE *locp, const char *s) {
    if ( locp->first_line == locp->last_line ) {
        printf("Error at line %d column %d: %s\n", locp->first_line, locp->first_column, s);
    } else {
        printf("Error at lines (%d to %d) columns (%d to %d): %s\n", locp->first_line, locp->last_line, locp->first_column, locp->last_column, s);
    }

    state.has_error = 1;
}
