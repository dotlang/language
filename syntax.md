This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.  
`[X]` means `X` is optional (can be seen zero or one times).  

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
ModuleLiteral     = "(" ModuleLiteral ")" | ExpressionLiteral | NUMBER
                    ModuleLiteral ("+"|"-"|"*"|"/"|"&") ModuleLiteral ) | StringLiteral
ExpressionLiteral = CharLiteral | BoolLiteral | StructLiteral | 
                      SequenceLiteral | MapLiteral | "nothing"
StringLiteral     = """ [ STRING ] """ | "`" STRING "`"
CharLiteral       = "'" character "'"
BoolLiteral       = "true" | "false"
StructLiteral     = [ TYPE_NAME ] "{" DynamicBinding { "," DynamicBinding } "}"
SequenceLiteral   = "[" [ Expression { "," Expression } ] "]"
MapLiteral        = "[" [ MapLiteralElement { "," MapLiteralElement } ] "]"
MapLiteralElement = Expression ":" Expression
```
Module:
```
Module            = { ( NamedType | StaticBinding ) }
```
Named type declaration:
```
NamedType             = TYPE_NAME ":=" TypeDecl
TypeDecl              =  TYPE_NAME | PrimitiveTypeDecl | SequenceTypeDecl | MapTypeDecl | UnionTypeDecl | 
                         StructTypeDecl | FnTypeDecl | ChannelTypeDecl
PrimitiveTypeDecl     = "int" | "float" | "char" | "string" | "nothing" | "bool"
SequenceTypeDecl      = "[" TypeDecl "]"
MapTypeDecl           = "[" TypeDecl "," TypeDecl "]"
UnionTypeDecl         = ( TYPE_NAME | PrimitiveTypeDecl ) { "|" ( TYPE_NAME | PrimitiveTypeDecl ) }
StructTypeDecl        = "{" [ ( UnnamedStructTypeDecl | NamedStructTypeDecl ) ] "}" 
UnnamedStructTypeDecl = TypeDecl { "," TypeDecl } 
NamedStructTypeDecl   = "{" ArgDef { "," ArgDef } [ "..." ] "}" 
ArgDef                = BINDING_NAME ":" TypeDecl
FnTypeDecl            = "(" [ TypeDecl { "," TypeDecl } ] ")" "-" ">" ["("] TypeDecl [")"]
ChannelTypeDecl       = ( TYPE_NAME | PrimitiveTypeDecl ) ("!"|"?")
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
StaticBinding  = BindingLhs { "," BindingLhs } ":" "=" ( ImportBinding |   
                      ModuleLiteral | FunctionDecl )
BindingLhs     = "_" | BINDING_NAME [ ":" TypeDecl ]
ImportBinding  = "@" "{" STRING { "," STRING } "}" 
                 [ "(" TypeDecl { "," TypeDecl } ")" ] [ "{" ImportRenames "}" ]
ImportRenames  = ImportRename { "," ImportRename }
ImportRename   = ( TYPE_NAME "=>" TYPE_NAME ) | ( BINDING_NAME "=>" BINDING_NAME )

FunctionDecl   = "(" [ ArgDef { "," ArgDef } ] ")" "-" ">" 
                      ( Expression | ["("] TypeDecl [")"] CodeBlock )
CodeBlock      = "{" { FnReturn | DynamicBinding  "}" } | "{" "..." "}"
FnReturn       = "::" Expression
DynamicBinding = BindingLhs { "," BindingLhs } ":" "=" ["="] Expression
```
Expressions:
```
Expression         = BINDING_NAME | FunctionDecl | FnCall | ExpressionLiteral | 
                     OperatorExpression | MathExpression | SequenceMapReadOp | StructAccess | BoolExpression
OperatorExpression = RangeOp | NothingCheckOp | CastOp | StructModify| 
                     SequenceMergeOp | LambdaCreatorOp | ChainOp | ChannelOp | SelectOp
MathExpression     = MathFactor ("+"|"-"|"*"|"/"|"%"|"%%") MathExpression | MathFactor
MathFactor         = "(" Expression ")" | NUMBER
FnCall             = Expression "(" [ Expression { "," Expression } ] ")"
SequenceMapReadOp  = Expression "[" Expression "]"
StructAccess       = Expression "." BINDING_NAME
BoolExpression     = BoolFactor (">"|"<"|"="|"!="|">="|"<=") BoolFactor | 
                     BoolFactor ("and"|"or"|"xor") BoolFactor | "not" BoolFactor
BoolFactor         = BoolLitearl | "(" Expression ")" | Expression
```
Advanced operators:
```
RangeOp         = Expression ".." Expression
CastOp          = ( TYPE_NAME | PrimitiveTypeDecl ) "(" [ Expression { "," Expression } ] ")"
SequenceMergeOp = Expression "&" Expression
NothingCheckOp  = Expression "/" "/" Expression
StructModify    = [ Expression ] "{" DynamicBinding { "," DynamicBinding } "}"
LambdaCreatorOp = Expression "(" [ ( Expression | "_" ) { "," ( Expression | "_" ) } ] ")"
ChainOp         = ( Expression | "(" Expression { "," Expression } ")" ) "." "{" ChainLambdas "}"
ChainLambdas    = ChainLambda { "," ChainLambda }
ChainLambda     = Expression | LambdaCreatorOp
ChannelOp       = Expression "?" | Expression "!" Expression
SelectOp        = "$" "{" SelectOpItem { "," SelectOpItem } "}"
SelectOpItem    = ChannelOp | "[" Expression { "," Expression "]" 
                       ("?" | "!" "[" Expression { "," Expression } "]" )
```
