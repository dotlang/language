typedef enum {
    ADD,
    SUB,
    MUL,
    DIV
} inst_type;


typedef enum {
    NONE,
    INT
} operand_type;

typedef union {
    //immediate values of different types
    signed char     byte_value;
    unsigned char   ubyte_value;
    signed short    short_value;
    unsigned short  ushort_value;
    signed int      int_value;
    unsigned int    uint_value;
    signed long     long_value;
    unsigned long   ulong_value;
    float           float_value;
    double          double_value;
    char*           string_value;
    unsigned char   bool_value;

    //a variable (x) or array with immediate index (a[1]) or array with variable index (a[t])
    struct {
        unsigned int    var_index;
        union {
            unsigned int    offset_var_index;
            unsigned int    offset_immediate_value;
        };
    };
} operand_value;


typedef struct {
    //which of different types of operand_value are used? immediate int or variable or ...
    operand_type type;
    operand_value value;
} operand;

typedef struct {
    inst_type opcode;

    operand op1;
    operand op2;
    operand op3;
} instruction;
