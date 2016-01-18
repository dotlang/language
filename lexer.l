%option noyywrap

%{
#include <iostream>
#include "parser.tab.h"  // to get the token types that we return

using namespace std;
#define YY_DECL extern "C" int yylex()

%}

digit [0-9]

%%
[ \t]           { }
\n              { return ENDL; }
[0-9]+          { yylval=atoi(yytext); return NUMBER; }
[+\-*/]         { yylval=yytext[0]; return OPERATOR; }

%%
