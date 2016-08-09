%option noyywrap
%option yylineno

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <jit/jit.h>

#include "parser.tab.h"  // to get the token types that we return
extern YYLTYPE yylloc;
#define YY_USER_ACTION \
    yylloc->first_line = yylloc->last_line; \
    yylloc->first_column = yylloc->last_column; \
    for(int i = 0; yytext[i] != '\0'; i++) { \
        if(yytext[i] == '\n') { \
            yylloc->last_line++; \
            yylloc->last_column = 0; \
        } \
        else { \
            yylloc->last_column++; \
        } \
    }

#define YY_DECL extern int yylex(YYSTYPE* yylval, YYLTYPE* yylloc)
%}

%option yylineno

digit [0-9]

%%
[ \t]          {}
"//".*         {}
\n             {}
int            { return TYPE; }
==             { return EQ; }
[0-9]+         { yylval->str = strdup(yytext); return NUMBER; }
return         { return RETURN;}
if              { return IF; }
[_a-zA-Z]+     { yylval->str = strdup(yytext); return IDENTIFIER; }
[=(){};+\-*/]       { return yytext[0];}

%%
