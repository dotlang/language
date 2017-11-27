This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.  
`[X]` means `X` is optional (can be seen zero or one times).  

Tokens:
```
DIGIT              = [0-9]
TYPE_NAME          = [underscore] capital_letter { letter }
BINDING_NAME       = <VALUE_BINDING_NAME> | <FN_BINDING_NAME>
VALUE_BINDING_NAME = [underscore] lower_letter { lower_letter | underscore }
FN_BINDING_NAME    = [underscore] lower_letter { letter }
STRING             = { character } 
INT_NUMBER         = ["+"|"-"] <DIGIT> { <DIGIT> | "," }
NUMBER             = INT_NUMBER [ "." <DIGIT> { <DIGIT> | "," } ]
```
Basic literals:
```
ModuleLiteral     = "(" <module_literal> ")" | <exp_literal> | NUMBER
                    <module_literal> ("+"|"-"|"*"|"/"|"&") <module_literal> ) | <string_literal>
ExpressionLiteral = <char_literal> | <bool_literal> | <struct_literal> | 
                      <seq_literal> | <map_literal> | "nothing"
StringLiteral     = """ [ <STRING> ] """ | "`" <STRING> "`"
CharLiteral       = "'" <CHAR> "'"
BoolLiteral       = "true" | "false"
StructLiteral     = [ <TYPE_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
SequenceLiteral   = "[" [ <expression> { "," <expression> } ] "]"
MapLiteral        = "[" [ <map_literal_element> { "," <map_literal_element> } ] "]"
MapLiteralElement = <expression> ":" <expression>
```
Module:
```
Module            = { ( NamedType | StaticBinding ) }
```
Named type declaration:
```
NamedType             = <TYPE_NAME> ":=" <type_decl>
TypeDecl              =  <TYPE_NAME> | <primitive_type> | <sequence_type> | <map_type> | <union_type> | 
                         <struct_type> | <fn_type> | <channel_type>
PrimitiveTypeDecl     = "int" | "float" | "char" | "string" | "nothing" | "bool"
SequenceTypeDecl      = "[" <type_decl> "]"
MapTypeDecl           = "[" <type_declaration> "," <type_declaration> "]"
UnionTypeDecl         = ( <TYPE_NAME> | <primitive_type> ) { "|" ( <TYPE_NAME> | <primitive_type> ) }
StructTypeDecl        = "{" [ ( <unnamed_struct> | <named_strct> ) ] "}" 
UnnamedStructTypeDecl = <type_decl> { "," <type_decl> } 
NamedStructTypeDecl   = "{" <arg_def> { "," <arg_def> } [ "..." ] "}" 
ArgDef                = <BINDING_NAME> ":" <type_decl>
FnTypeDecl            = "(" [ <type_decl> { "," <type_decl> } ] ")" "-" ">" ["("] <type_decl> [")"]
ChannelTypeDecl       = ( TYPE_NAME | PrimitiveTypeDecl ) ("!"|"?")
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
StaticBinding  = <binding_lhs> { "," <binding_lhs> } ":" "=" ( <import_binding> |   
                      <module_literal> | FunctionDecl )
BindingLhs     = "_" | <BINDING_NAME> [ ":" <type_decl> ]
ImportBinding  = "@" "{" <STRING> { "," <STRING> } "}" 
                 [ "(" <type_decl> { "," <type_decl> } ")" ] [ "{" <import_renames> "}" ]
ImportRenames  = <import_rename> { "," <import_rename> }
ImportRename   = ( <TYPE_NAME> "=" ">" <TYPE_NAME> ) | ( <BINDING_NAME> "=" ">" <BINDING_NAME> )

FunctionDecl   = "(" [ <arg_def> { "," <arg_def> } ] ")" "-" ">" 
                      ( Expression | ["("] <type_decl> [")"] <code_block> )
CodeBlock      = "{" { <fn_return> | <dynamic_binding>  "}" } | "{" "..." "}"
FnReturn       = "::" <expression>
DynamicBinding = <binding_lhs> { "," <binding_lhs> } ":" "=" ["="] <expression>
```
Expressions:
```
Expression         = <BINDING_NAME> | FunctionDecl | FnCall | ExpressionLiteral | 
                     OperatorExpression | MathExpression | SequenceMapReadOp | StructAccess | BoolExpression
OperatorExpression = <range_op> | <nothingcheck_op> | <cast_op> | <struct_modify> | 
                     <seq_merge_op> | <lambdacreator_op> | <chain_op> | <channel_op> | <select_op>
MathExpression     = MathFactor ("+"|"-"|"*"|"/"|"%"|"%%") MathExpression | MathFactor
MathFactor         = "(" Expression ")" | NUMBER
FnCall             = Expression "(" [ Expression { "," Expression } ] ")"
SequenceMapReadOp  = Expression "[" Expression "]"
StructAccess       = Expression "." <BINDING_NAME>
BoolExpression     = BoolFactor (">"|"<"|"="|"!="|">="|"<=") BoolFactor | 
                     BoolFactor ("and"|"or"|"xor") BoolFactor | "not" BoolFactor
BoolFactor         = BoolLitearl | "(" Expression ")" | Expression
```
Advanced operators:
```
RangeOp         = <int_litearl> ".." <int_litearl>
CastOp          = ( <TYPE_NAME> | <primitive_type> ) "(" [ <expression> { "," <expression> } ] ")"
SequenceMergeOp = <expression> "&" <expression>
NothingCheckOp  = <expression> "/" "/" <expression>
StructModify    = [ <expression> ] "{" <fn_binding> { "," <fn_binding> } "}"
LambdaCreatorOp = <expression> "(" [ ( <expression> | "_" ) { "," ( <expression> | "_" ) } ] ")"
ChainOp         = ( <expression> | "(" <expression> { "," <expression> } ")" ) "." "{" <chain_lambdas> "}"
ChainLambdas    = <chain_lambda> { "," <chain_lambda> }
ChainLambda     = <expression> | <lambdacreator_op>
ChannelOp       = <expression> "?" | <expression> "!" <expression>
SelectOp        = "$" "{" <select_op_item> { "," <select_op_item> } "}"
SelectOpItem    = ChannelOp | "[" <expression> { "," <expression> "]" 
                       ("?" | "!" "[" <expression> { "," <expression> } "]" )
```
