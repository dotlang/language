%{
#include <cstdio>
#include <iostream>
using namespace std;

// stuff from flex that bison needs to know about:
extern "C" int yyparse();
extern "C" int yylex();
extern "C" FILE *yyin;
 
void yyerror(const char *s);
%}

%token NUMBER
%token OPERATOR

%start EXPR

%%

EXPR :  NUMBER OPERATOR NUMBER  { cout << "bison found triple: " << $1 << $2 << $3 << endl; }
        |
        NUMBER OPERATOR NUMBER EXPR   { cout << "bison found triple: " << $1 << $2 << $3 << endl; }
        ;

%%

int main(int, char**) {
    // open a file handle to a particular file:
    FILE *myfile = fopen("input", "r");
    // make sure it is valid:
    if (!myfile) {
        cout << "I can't open input file!" << endl;
        return -1;
    }
    // set flex to read from it instead of defaulting to STDIN:
    yyin = myfile;
    
    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));
    
}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
