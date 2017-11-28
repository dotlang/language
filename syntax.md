This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.  
`[X]` means `X` is optional (can be seen zero or one times).  
`X*` means `X` can be repeated zero or more times (separated by comma).  
`X+` means `X` can be repeated once or more times (separated by comma).

Tokens:
```
DIGIT              = [0-9]
TYPE_NAME          = [underscore] capital_letter { letter }
BINDING_NAME       = VALUE_BINDING_NAME | FN_BINDING_NAME
VALUE_BINDING_NAME = [underscore] lower_letter { lower_letter | underscore }
FN_BINDING_NAME    = [underscore] lower_letter { letter }
STRING             = { character } 
INT_NUMBER         = ["+"|"-"] DIGIT { DIGIT | "," }
NUMBER             = INT_NUMBER [ "." DIGIT { DIGIT | "," } ]
```
Basic literals:
```
ModuleLiteral      = "(" ModuleLiteral ")" | ExpressionLiteral | NUMBER
                     ModuleLiteral ("+"|"-"|"*"|"/"|"&") ModuleLiteral ) | StringLiteral
ExpressionLiteral  = CharLiteral | BoolLiteral | StructLiteral | NUMBER
                     SequenceLiteral | MapLiteral | "nothing"
StringLiteral      = """ [ STRING ] """ | "`" STRING "`"
CharLiteral        = "'" character "'"
BoolLiteral        = "true" | "false"
StructLiteral      = [ TYPE_NAME ] "{" DynamicBinding* "}"
SequenceLiteral    = "[" Expression* "]"
MapLiteral         = "[" MapLiteralElement* "]"
MapLiteralElement  = Expression ":" Expression
```
Module:
```
Module             = { ( NamedType | StaticBinding ) }
```
Named type declaration:
```
NamedType          = TYPE_NAME ":=" TypeDecl
TypeDecl           = TYPE_NAME | PrimitiveTypeDecl | SequenceTypeDecl | MapTypeDecl | 
                     UnionTypeDecl | StructTypeDecl | FnTypeDecl | ChannelTypeDecl
PrimitiveTypeDecl  = "int" | "float" | "char" | "string" | "nothing" | "bool"
SequenceTypeDecl   = "[" TypeDecl "]"
MapTypeDecl        = "[" TypeDecl "," TypeDecl "]"
UnionTypeDecl      = ( TYPE_NAME | PrimitiveTypeDecl ) { "|" ( TYPE_NAME | PrimitiveTypeDecl ) }
StructTypeDecl     = "{" ( TypeDecl* | ArgDef* [ "..." ] ) "}" 
ArgDef             = BINDING_NAME ":" TypeDecl
FnTypeDecl         = "(" TypeDecl* ") -> " ["("] TypeDecl [")"]
ChannelTypeDecl    = ( TYPE_NAME | PrimitiveTypeDecl ) ("!"|"?")
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
StaticBinding      = BindingLhs+ ":=" ( ImportBinding | ModuleLiteral | FunctionDecl )
BindingLhs         = "_" | BINDING_NAME [ ":" TypeDecl ]
ImportBinding      = "@" "{" STRING+ "}" 
                     [ "(" TypeDecl* ")" ] [ "{" ImportRename+ "}" ]
ImportRename       = ( TYPE_NAME "=>" TYPE_NAME ) | ( BINDING_NAME "=>" BINDING_NAME )
FunctionDecl       = "(" ArgDef* ")" "->" 
                     ( Expression | ["("] TypeDecl [")"] CodeBlock )
CodeBlock          = "{" { FnReturn | DynamicBinding } "}" | "{...}"
FnReturn           = "::" Expression
DynamicBinding     = BindingLhs+ ":=" ["="] ( Expression | FunctionDecl )
```
Expressions:
```
Expression         = CmpExpression    { ("and"|"or"|"xor") CmpExpression }
CmpExpression      = ShiftExpression  { (">"|"<"|"="|"!="|">="|"<=") ShiftExpression }
ShiftExpression    = AddExpression    { (">>"|"<<") AddExpression }
AddExpression      = MulExpression    { ("+"|"-") MulExpression }
MulExpression      = UnaryExpression  { ("*"|"/"|"%"|"%%") UnaryExpression }
UnaryExpression    = ["not"|"-"]      PrimaryExpression
PrimaryExpression  = BasicExpression  { "(" Expression* ")" | "." BINDING_NAME | "[" Expression "]" }
                                      (* function call      / struct access    / seq/map access    *)
BasicExpression    = BINDING_NAME | "(" Expression ")" | ExpressionLiteral
```
Advanced operators (to be added later):
```
(* Range op *)       PrimaryExpression ".." PrimaryExpression |
(* Nothing check*)   Expression "//" Expression |
(* Cast *)           ( TYPE_NAME | PrimitiveTypeDecl ) "(" Expression* ")" |
(* Struct modify *)  [ Expression ] "{" DynamicBinding* "}" |
(* Merge seq *)      PrimaryExpression "&" PrimaryExpression |
(* Lambda creator *) Lambda |
(* Chain *)          ( PrimaryExpression | "(" PrimaryExpression+ ")" ) "." "{" (Lambda|PrimaryExpression)+ "}" |
(* Select *)         "$" "{" SelectTerm+ "}" |
(* Channels *)       Expression "?" | Expression "!" Expression
Lambda             = PrimaryExpression "(" ( PrimaryExpression | "_" )* ")"
SelectTerm         = PrimaryExpression "?" | PrimaryExpression "!" PrimaryExpression | 
                     "[" PrimaryExpression+ "]" ("?" | "!" "[" PrimaryExpression+ "]" )
```
- Shall we prohibit calling a function literal at the point of declaration?
```
result := (x:int)->x+1(100) #store 101 into result
```
or
```
fn := (x:int)->x+1
result := fn(100) #store 101 into result
```
- Shall we add shift right and left?
