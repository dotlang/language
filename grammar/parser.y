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

extern void assertion_failure_handler();

%}

%locations
%define parse.error verbose
%define api.pure full
%expect 1

%union {
    char text[100];
    jit_value_t value;
    jit_label_t label;
}


%token <text> IDENTIFIER
%token <text> NUMBER
%token RETURN
%token IF
%token ELSE
%token TYPE
%token ASSERT

%type <value> Expression
%type <label> IfStmt
%type <value> Condition


/* source for operator settings: http://en.cppreference.com/w/c/language/operator_precedence */
/* higher = lower precedence */
%right '='
%left EQ_OP
%left '+' '-'
%left '*' '/'
%left INC_OP
%left '('
%left ')'

%start SourceFile

%%

SourceFile
    : MethodDecl
    {
        end_function();
    }
    ;

MethodDecl
    : TYPE IDENTIFIER 
    {
        start_function($2);
    } '(' ')' 
    {
        jit_type_t params[0];
        jit_type_t signature;
        signature = jit_type_create_signature
                    (jit_abi_cdecl, jit_type_int, params, 0, 1);

        CFN = jit_function_create(state.context, signature);
                jit_type_free(signature);
    } Block
    ;

Block
    : '{' StatementList '}'
    | Statement
    | '{' '}'
    ;

StatementList
    : Statement
    | StatementList Statement
    ;

Statement
    : ReturnStmt 
    | VarDecl
    | IfStmt
    | Expression ';'
    | AssignmentStmt
    | AssertStmt
    ;

AssertStmt
    : ASSERT Condition 
    {
        jit_value_t exp_result = $2;
        $<label>$ = jit_label_undefined;
        jit_insn_branch_if(CFN, exp_result, &$<label>$);
        //halt!
        jit_type_t handler_signature = jit_type_create_signature
                        (jit_abi_cdecl, jit_type_void, NULL, 0, 0);

        jit_insn_call_native(
                CFN,
                "assertion_failure_handler",
                (void*)assertion_failure_handler,
                handler_signature,
                NULL,
                0,
                JIT_CALL_NOTHROW|JIT_CALL_NORETURN);
    } ';'
    {
        jit_insn_label(CFN, &$<label>3);
    }
    ;

IfStmt
    : IF '(' Condition ')' 
    {
        $<label>$ = jit_label_undefined;
        jit_value_t condition_result = $3;

        jit_insn_branch_if_not(CFN, condition_result, &$<label>$);
    } Block
    {
        //when if block is finished, jump to after `else` section 
        $<label>$ = jit_label_undefined;
        jit_insn_branch(CFN, &$<label>$);

        //Here $<label>5 means the 'label' data item which was set by 5th component in this rule 
        //and the 5th component was the code block after "Condition ')'".
        jit_insn_label(CFN, &$<label>5);
    } IfElsePart
    {
       jit_insn_label(CFN, &$<label>7);
    }
    ;

IfElsePart
    : ELSE Block
    |
    ;

Condition
    : Expression EQ_OP Expression
    {
        $$ = jit_insn_eq(CFN, $1, $3);
    }
    | Expression '>' Expression
    {
        $$ = jit_insn_gt(CFN, $1, $3);
    }
    | Expression '<' Expression 
    {
        $$ = jit_insn_lt(CFN, $1, $3);
    }
    ;

AssignmentStmt
    : IDENTIFIER '=' Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_insn_store(CFN, variable, $3);
    }
    ;

VarDecl
    : TYPE IDENTIFIER ';'
    {
        define_local_var($2);
        jit_value_t r_value = jit_value_create_nint_constant(CFN, jit_type_int, 0);
        update_local_var($2, r_value);
    }
    | TYPE IDENTIFIER '=' NUMBER ';'
    {
        define_local_var($2);
        jit_value_t r_value = jit_value_create_nint_constant(CFN, jit_type_int, atoi($4));
        update_local_var($2, r_value);
    }
    ;

ReturnStmt
    : RETURN Expression ';'
    {
        jit_insn_return(CFN, $2);
    } 
    ;

Expression
    : IDENTIFIER INC_OP
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t one_const = jit_value_create_nint_constant(CFN, jit_type_int, 1);
        jit_value_t result = jit_insn_add(CFN, variable, one_const);

        update_local_var($1, result);
        $$ = variable;
    }
    | Expression '+' Expression
    {
        $$ = jit_insn_add(CFN, $1, $3);
    }
    | Expression '-' Expression
    {
        $$ = jit_insn_sub(CFN, $1, $3);
    }
    | Expression '*' Expression
    {
        $$ = jit_insn_mul(CFN, $1, $3);
    }
    | Expression '/' Expression
    {
        $$ = jit_insn_div(CFN, $1, $3);
    }
    | '(' Expression ')'
    {
        $$ = $2;
    }
    | NUMBER
    {
        $$ = jit_value_create_nint_constant(CFN, jit_type_int, atoi($1));
    }
    | IDENTIFIER
    {
        jit_value_t variable = get_local_var($1);
        $$ = variable;
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
