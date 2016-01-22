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

%union {
    int ival;
    char *sval;
    char chr;
}

%token ENDL
%token EQ

%token  <sval>  IDENTIFIER
%token  <ival>  NUMBER
%token  <chr>   OPERATOR

%type   <ival>  EXP

%start PROGRAM

%%

PROGRAM :   |
            PROGRAM LINE ENDL
            ;

LINE:       |
            IDENTIFIER EQ EXP {
                cout << "Assigning " << $3 << " to " << $1 << endl;
            }
            |
            EXP {
            }
            ;

EXP:        NUMBER {
                $$ = $1;
            }
            |
            NUMBER OPERATOR EXP { 
                if ( $2 == '+' ) {
                    $$ = $1+$3;
                    cout << $1 << '+' << $3 << '=' << $$ << endl;
                }
                if ( $2 == '-' ) {
                    $$ = $1-$3;
                    cout << $1 << '-' << $3 << '=' << $$ << endl;
                }
                if ( $2 == '*' ) {
                    $$=$1*$3;
                    cout << $1 << '*' << $3 << '=' << $$ << endl;
                }
                if ( $2 == '/' ) {
                    $$=$1/$3;
                    cout << $1 << '/' << $3 << '=' << $$ << endl;
                }
            }
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
