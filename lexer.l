%option noyywrap

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "parser.tab.h"  // to get the token types that we return

#define YY_DECL extern int yylex()

%}

digit [0-9]

%%
[ \t]           { }
\n              { return ENDL; }
[0-9]+          { yylval.ival=atoi(yytext);return NUMBER; }
[+\-*/]         { yylval.chr=yytext[0]; return OPERATOR; }
=               { return EQ; }
[a-zA-Z]        { yylval.sval = strdup(yytext); return IDENTIFIER; }
"//"[^\r\n]*    { /* skip comments */ }

%%
