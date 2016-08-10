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
/* %expect 1 */

%union {
    char text[100];
    jit_value_t value;
    jit_label_t label;
}


%token <text> IDENTIFIER
%token <text> NUMBER
%token <text> TYPE
%token RETURN
%token STRUCT
%token TRUE
%token FALSE
%token AND OR NOT
%token IF
%token ELSE
%token ASSERT

%type <value> Expression
%type <value> BooleanExpression
%type <label> IfStmt
%type <value> Condition
%type <value> SimpleCondition


/* source for operator settings: http://en.cppreference.com/w/c/language/operator_precedence */
/* higher = lower precedence */
%right OP_ASHR
%right OP_ASHL
%right OP_AMOD
%right OP_APOW
%right OP_AAND
%right OP_AOR
%right OP_AXOR
%right OP_ADIV
%right OP_AADD
%right OP_AMUL
%right OP_ASUB
%right '='
%left OP_EQ
%left OP_NE
%left OP_LE
%left OP_GE
%left OP_SHR OP_SHL
%left '+' '-'
%left '*' '/' '%'
%left '|'
%left '^'
%left OP_POW
%left '&'
%right '~'
%left OP_INC
%left OP_DEC
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
        jit_label_t assertion_ok_label = jit_label_undefined;
        jit_insn_branch_if(CFN, $2, &assertion_ok_label);

        //define label for condition to jump to if condition is not met
        /* jit_insn_label(CFN, &$<label>2); */

        /* jit_value_t exp_result = $2; */
        /* $<label>$ = jit_label_undefined; */
        /* jit_insn_branch_if(CFN, exp_result, &$<label>$); */

        /* //halt! */
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

        jit_insn_label(CFN, &assertion_ok_label);
    } ';'
    {
    }
    ;

IfStmt
    : IF '(' Condition ')' 
    {
        $<label>$ = jit_label_undefined;
        jit_insn_branch_if_not(CFN, $3, &$<label>$);
    } Block
    {
        //when execution of if block is finished, jump to after `else` section 
        $<label>$ = jit_label_undefined;
        jit_insn_branch(CFN, &$<label>$);

        //setup label for the condition to jump if condition is failed
        jit_insn_label(CFN, &$<label>5);


        //Here $<label>5 means the 'label' data item which was set by 5th component in this rule 
        //and the 5th component was the code block after "Condition ')'".
        /* jit_insn_label(CFN, &$<label>5); */
    } IfElsePart
    {
       jit_insn_label(CFN, &$<label>7);
    }
    ;

IfElsePart
    : ELSE Block
    |
    ;

SimpleCondition
    : Expression OP_EQ Expression
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
    | Expression OP_LE Expression 
    {
        $$ = jit_insn_le(CFN, $1, $3);
    }
    | Expression OP_GE Expression 
    {
        $$ = jit_insn_ge(CFN, $1, $3);
    }
    | Expression OP_NE Expression 
    {
        $$ = jit_insn_ne(CFN, $1, $3);
    }
    ;

Condition
    : '(' Condition ')'
    {
        $$ = $2;
    }
    | SimpleCondition
    {
        $$ = $1;
        /* $<label>$ = jit_label_undefined; */
        /* jit_insn_branch_if_not(CFN, $1, &$<label>$); */
    }
    | SimpleCondition AND SimpleCondition
    {
        jit_value_t first = $1;
        jit_value_t second = $3;

        $$ = jit_insn_and(CFN, first, second);
    }
    | Condition AND Condition
    {
        jit_value_t first = $1;
        jit_value_t second = $3;

        $$ = jit_insn_and(CFN, first, second);
        /* $$ = jit_label_undefined; */

        /* jit_label_t label_all_pass = jit_label_undefined; */
        /* jit_insn_branch(CFN, &label_all_pass); */
        /* jit_insn_label(CFN, &$1); */
        /* jit_insn_label(CFN, &$3); */
        /* jit_insn_branch(CFN, &$$); */

        /* jit_insn_label(CFN, &label_all_pass); */

         
        
        /* //this label will be configured by parent statement */
        /* jit_insn_branch_if_not(CFN, $4, &$<label>2); */
        /* $$ = $<label>2; */

        /* // */
        /* jit_insn_label(CFN, &$1); */
    }
    | SimpleCondition OR SimpleCondition
    {
        jit_value_t first = $1;
        jit_value_t second = $3;

        $$ = jit_insn_or(CFN, first, second);
    }
    | Condition OR Condition
    {
        jit_value_t first = $1;
        jit_value_t second = $3;

        $$ = jit_insn_or(CFN, first, second);
    }
    | NOT Condition
    {
        jit_value_t first = $2;

        $$ = jit_insn_not(CFN, first);
    }
    ;

BooleanExpression
    : TRUE
    {
        $$ = create_const_by_data_type(find_type("bool"), "1");
    }
    | FALSE
    {
        $$ = create_const_by_data_type(find_type("bool"), "0");
    }
    | Condition
    {
        $$ = $1;
    };
                

AssignmentStmt
    : IDENTIFIER '=' BooleanExpression ';'
    {
        ONLY_BOOL($1)
        update_local_var($1, $3);
    }
    | IDENTIFIER '=' Expression ';'
    {
        update_local_var($1, $3);
    }
    | IDENTIFIER OP_AADD Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_add(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_ASUB Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_sub(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_AMUL Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_mul(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_ADIV Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_div(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_ASHL Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_shl(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_ASHR Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_shr(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_AMOD Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_rem(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_APOW Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_pow(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_AAND Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_and(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_AOR Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_or(CFN, variable, $3);
        update_local_var($1, temp);
    }
    | IDENTIFIER OP_AXOR Expression ';'
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t temp = jit_insn_xor(CFN, variable, $3);
        update_local_var($1, temp);
    }
    ;

VarDecl
    : TYPE IDENTIFIER ';'
    {
        define_local_var($1, $2);
    }
    | TYPE IDENTIFIER '=' Expression ';'
    {
        define_local_var($1, $2);
        update_local_var($2, $4);
    }
    | TYPE IDENTIFIER '=' BooleanExpression ';'
    {
        define_local_var($1, $2);
        ONLY_BOOL($2)
        update_local_var($2, $4);
    }
    ;

ReturnStmt
    : RETURN Expression ';'
    {
        jit_insn_return(CFN, $2);
    } 
    ;

Expression
    : IDENTIFIER OP_INC
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t one_const = create_const($1, "1");
        jit_value_t result = jit_insn_add(CFN, variable, one_const);

        update_local_var($1, result);
        $$ = variable;
    }
    | IDENTIFIER OP_DEC
    {
        jit_value_t variable = get_local_var($1);
        jit_value_t one_const = create_const($1, "1");
        jit_value_t result = jit_insn_sub(CFN, variable, one_const);

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
        //we don't have a variable here! assume int
        $$ = jit_value_create_nint_constant(CFN, jit_type_int, atoi($1));
    }
    | Expression OP_POW Expression
    {
        $$ = jit_insn_pow(CFN, $1, $3);
    }
    | Expression '%' Expression
    {
        $$ = jit_insn_rem(CFN, $1, $3);
    }
    | Expression '&' Expression
    {
        $$ = jit_insn_and(CFN, $1, $3);
    }
    | Expression '|' Expression
    {
        $$ = jit_insn_or(CFN, $1, $3);
    }
    | Expression '^' Expression
    {
        $$ = jit_insn_xor(CFN, $1, $3);
    }
    | '~' Expression
    {
        $$ = jit_insn_not(CFN, $2);
    }
    | Expression OP_SHR Expression
    {
        $$ = jit_insn_shr(CFN, $1, $3);
    }
    | Expression OP_SHL Expression
    {
        $$ = jit_insn_shl(CFN, $1, $3);
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
