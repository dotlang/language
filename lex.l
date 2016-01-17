%option noyywrap

%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()

%}

digit [0-9]

%%
[ \t\n]         { cout << "Found newline or tab or space" << endl; }
[0-9]{1}        { cout << "Found a digit: " << yytext << endl; }
[+\-*/]          { cout << "Found an operator: " << yytext << endl; }

%%
int main(int, char**) {
    yylex();
}
