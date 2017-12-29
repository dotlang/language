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
ExpressionLiteral  = CharLiteral | BoolLiteral | StringLiteral | SequenceLiteral |
                     StructLiteral | MapLiteral | NumberLiteral | "nothing"
CharLiteral        = "'" character "'"
BoolLiteral        = "true" | "false"
StringLiteral      = """ [ STRING ] """ | "`" STRING "`"
SequenceLiteral    = "[" Expression* "]"
StructLiteral      = [ TYPE_NAME ] "{" DynamicBinding* "}"
MapLiteral         = "[" MapLiteralElement* "]"
MapLiteralElement  = Expression ":" Expression
NumberLiteral      = NUMBER
```
Module:
```
Module             = { ( Binding | NamedType | ImportBinding ) }
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
Binding            = BindingLhs+ "=" ["="] ( Expression | FunctionDecl )
BindingLhs         = "_" | BINDING_NAME [ ":" TypeDecl ]
ImportRename       = ( TYPE_NAME "=>" TYPE_NAME ) | ( BINDING_NAME "=>" BINDING_NAME )
FunctionDecl       = "(" TypedName* ")" "->" ( Expression | ["("] TypeDecl [")"] CodeBlock )
CodeBlock          = "{" { ReturnStatement | Binding } "}" | "{" "..." "}"
ReturnStatement    = "::" Expression
ImportBinding      = "@" "[" STRING+ "]" 
                     [ "{" ( NamedType | TypeAlias )+ "}" ]
```
Expressions:
```
Expression         = EqExpression     { ("and"|"or"|"xor") EqExpression }
EqExpression       = CmpExpression    { ("=?"|"<>") CmpExpression }
CmpExpression      = ShiftExpression  { (">"|"<"|">="|"<=") ShiftExpression }
ShiftExpression    = AddExpression    { (">>"|"<<"|"^") AddExpression }
AddExpression      = MulExpression    { ("+"|"-") MulExpression }
MulExpression      = UnaryExpression  { ("*"|"/"|"%"|"%%") UnaryExpression }
UnaryExpression    = ["not"|"-"]      PrimaryExpression
PrimaryExpression  = ( BINDING_NAME | "(" Expression ")" | ExpressionLiteral )
                     {  "(" Expression* ")" | "." Expression | "[" Expression "]" }
                     (*  function call      / struct access    / seq/map access    *)
```
Named type declaration:
```
NamedType          = TYPE_NAME "=" TypeDecl
TypeDecl           = TYPE_NAME | PrimitiveTypeDecl | SequenceTypeDecl | MapTypeDecl | 
                     UnionTypeDecl | StructTypeDecl | FnTypeDecl | ChannelTypeDecl
PrimitiveTypeDecl  = "int" | "float" | "char" | "string" | "nothing" | "bool"
SequenceTypeDecl   = "[" TypeDecl "]"
MapTypeDecl        = "[" TypeDecl "," TypeDecl "]"
UnionTypeDecl      = ( TYPE_NAME | PrimitiveTypeDecl ) { "|" ( TYPE_NAME | PrimitiveTypeDecl ) }
StructTypeDecl     = "{" ( TypeDecl* | TypedName* [ "..." ] ) "}" 
TypedName          = BINDING_NAME ":" TypeDecl
FnTypeDecl         = "(" TypeDecl* ") -> " ["("] TypeDecl [")"]
ChannelTypeDecl    = ( TYPE_NAME | PrimitiveTypeDecl ) ("!"|"?")
```

Advanced operators (to be added later):
```
TypeAlias = ???
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

### Implementation Notes

1. All functions that have inputs of sum-types, will be repeated for each matching type by the compiler. When calling that function, the one which matches dynamic type of the union binding will be matched.
So `process(int|float)->string` will be compiled into two functions:
`process(int)->string` and `process(float)->string`
And when it is called like `process(int_var)` or `process(float_var)` the corresponding function will be invoked which can be determined at compile time.
If it is called with `process(int_or_float_var)` compiler will inject a piece of code to determine whether the binding is int or float, then will call corresponding function.

2. Each function will be mangled with type of it's inputs. So `process(int)` will become `process|1821` where `1821` is typecode of `int`. Each type will have it's own type-code which depends on it's name and point of declaration.

3. Handling access to common parts: If we have `process = (x: {int,...})->int`, the expression `x.0` inside process can refere to different offsets. But compiler will generate the function for all matching types. So it can use appropriate offset when compiling `x.0` for every different type.

4. If struct Circle, embeds Shape, there will be a complete Shape object laid inside Circle. When fields of Shape, are referred directly, compiler will calculate appropriate offset. `Shape = {id:int}`, `Circle = {Shape, r: float}`. Referring to `my_circle.Shape` will return the whole object. `my_circle.Shape.id` will refer to id inside Shape. `my_circle.id` will be mapped to `my_circle.Shape.id`.
