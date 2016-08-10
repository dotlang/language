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

D   [0-9]
L   [a-zA-Z_]
H   [a-fA-F0-9]

%%

"//".*          {/* comment */}

int             { return TYPE; }
return          { return RETURN;}
if              { return IF; }
assert          { return ASSERT; }
else            { return ELSE;}
and             { return AND; }
or              { return OR; }
not             { return NOT; }

{D}+            { strcpy(yylval->text, yytext); return NUMBER; }

"+="            { return OP_AADD; }
"-="            { return OP_ASUB; }
"*="            { return OP_AMUL; }
"/="            { return OP_ADIV; }
"=="            { return OP_EQ; }
">="            { return OP_GE; }
"<="            { return OP_LE; }
"!="            { return OP_NE; }
"++"            { return OP_INC; }
{L}({L}|{D})*   { strcpy(yylval->text, yytext); return IDENTIFIER; }
[+\-*/=]        { return yytext[0];}
[(){};<>]       { return yytext[0];}

[ \n\f]         {}
[\t\v]          {}
.               {/* ignore bad characters */}
%%
