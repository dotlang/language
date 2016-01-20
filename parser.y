%{
#include <cstdio>
#include <iostream>
using namespace std;

#include "../include/instruction.h"

// stuff from flex that bison needs to know about:
extern "C" int yyparse();
extern "C" int yylex();
extern "C" FILE *yyin;
 
void yyerror(const char *s);

FILE* output_file;

void write_to_output(inst_type itype, 
            operand_type op1_type, operand_value* op1_value,
            operand_type op2_type, operand_value* op2_value, 
            operand_type op3_type, operand_value* op3_value) {

    instruction inst;

    inst.opcode = itype;
    inst.op1.type = op1_type;
    inst.op2.type = op2_type;
    inst.op3.type = op3_type;

    if (op1_value != NULL) inst.op1.value = *op1_value;
    if (op2_value != NULL) inst.op2.value = *op2_value;
    if (op3_value != NULL) inst.op3.value = *op3_value;

    fwrite(&inst, sizeof(instruction), 1, output_file);
}

void dump_instruction(instruction* inst) {
    switch ( inst->opcode ) {
        case ADD: printf("ADD"); break;
    }

    /*dump_operand(inst->op1);
    dump_operand(inst->op2);
    dump_operand(inst->op2);*/
}

%}

%token NUMBER
%token OPERATOR
%token ENDL

%start PROGRAM

%%

PROGRAM :   |
        PROGRAM LINE 
            ;

LINE:       ENDL {
    }
            |
            EXP ENDL
            ;

EXP:        NUMBER {
   }
            |
            NUMBER OPERATOR EXP { 
                if ( $2 == '+' ) {
                    $$ = $1+$3;
                    cout << $1 << '+' << $3 << '=' << $$ << endl;
                    
                    operand_value ov1;
                    ov1.int_value = $1;
                    operand_value ov2;
                    ov2.int_value = $2;

                    write_to_output(ADD, INT, &ov1, INT, &ov2, INT, NULL);
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

void dump_output_file() {
    FILE* dump_file = fopen("output", "rb");
    if (!dump_file) {
        cout << "I can't open output file!" << endl;
    }

    instruction inst;

    fread(&inst, sizeof(instruction), 1, dump_file);
    dump_instruction(&inst);
}

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

    output_file = fopen("output", "wb");
    if (!output_file) {
        cout << "I can't open output file!" << endl;
        return -1;
    }

    // parse through the input until there is no more:
    do {
        yyparse();
    } while (!feof(yyin));

    fclose(output_file);

    dump_output_file();

}

void yyerror(const char *s) {
    cout << "EEK, parse error!  Message: " << s << endl;
    // might as well halt now:
    exit(-1);
}
