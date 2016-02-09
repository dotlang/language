typedef enum {
    ENTR,
    PROC,
    RETN
} inst_type;

typedef union {
    char*           string_value;//FOR STRING
    signed int      int_value;
    unsigned int    var_index;  //this is 5 for %5 

    //for deref*
    struct {
        unsigned int    var_index;
        union {
            unsigned int    offset_var_index;
            unsigned int    offset_immediate_value;
        };
    };
} operand_value;

typedef enum {
    STRING,     //for label and proc names
    IMM_SNUM    //literal unsigned integer numbers
    VARIABLE    // %x notation, variable on stack or heap
    DEREF       // [%x] notation, dereference a memory-allocated variable (heap/string/array/...)
    DEREF_IMM_OFFSET  //[%x+12] notation, base + immediate offset value
    DEREF_VAR_OFFSET  //[%x+%y] notation, offset is variable too
} operand_type;

typedef struct {
    operand_type type;
    operand_value value;
} operand;

typedef struct {
    inst_type   opcode;
    int         data_length;
    

    operand op1;
    operand op2;
    operand op3;
} instruction;
