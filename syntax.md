This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more times.
`[X]` means `X` is optional (can be seen zero or one times).
`X*` means `X` can be repeated zero or more times (separated by comma).  
`X+` means `X` can be repeated once or more times (separated by comma).

Tokens:
```
DIGIT              = [0-9]
TYPE_NAME          = [underscore] capital_letter { letter }
BINDING_NAME       = VALUE_BINDING_NAME | FN_BINDING_NAME | TYPE_NAME
VALUE_BINDING_NAME = [underscore] lower_letter { lower_letter | underscore }
FN_BINDING_NAME    = [underscore] lower_letter { letter }
STRING             = { character }
INT_NUMBER         = ["+"|"-"] DIGIT { DIGIT | "_" }
NUMBER             = INT_NUMBER [ "." DIGIT { DIGIT | "_" } ]
```

Basic literals (`Expression` is a general purpose expression defined later):
```
ExpressionLiteral  = CharLiteral | BoolLiteral | StringLiteral | SequenceLiteral |
                     StructLiteral | MapLiteral | NumberLiteral | "nothing"
CharLiteral        = "'" character "'"
BoolLiteral        = "true" | "false"
StringLiteral      = """ [ STRING ] """ | "`" [ MULTI_LINE_STRING ] "`"
SequenceLiteral    = "[" Expression* "]"
NumberLiteral      = NUMBER
MapLiteral         = "[" MapLiteralElement* "]"
MapLiteralElement  = Expression ":" Expression
StructLiteral      = [ TYPE_NAME ] "{" DotFieldValue* "}" | "{" Expression* "}"
DotFieldValue      = "." BINDING_NAME "=" Expression
```

Module:
```
Module             = { Element }
StructTypeDecl     = "{" Element* "}" 
Element            = ( Argument | NamedType | TypeAlias | Binding )
Argument           = ( "_" | BINDING_NAME )+ ":" TypeDecl
NamedType          = ( "_" | TYPE_NAME )+ ":=" TypeDecl
TypeAlias          = ( "_" | TYPE_NAME )+ "=" TypeDecl
```

Bindings at module-level can be either literals or functions. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
Binding            = BindingLhs+ "=" Expression
BindingLhs         = "_" | BINDING_NAME [ ":" TypeDecl ]
```

Syntax for type declaration:
```
TypeDecl           = SimpleTypeDecl | CompoundTypeDecl | "*" CompoundTypeDecl | SequenceTypeDecl | 
                     MapTypeDecl | UnionTypeDecl | FnTypeDecl
SimpleTypeDecl     = TYPE_NAME | PrimitiveTypeDecl
CompoundTypeDecl   = Import | StructTypeDecl
Import             = "@" "(" STRING+ ")"
PrimitiveTypeDecl  = "int" | "float" | "char" | "string" | "nothing" | "bool" | "byte" | "type"
SequenceTypeDecl   = "[" TypeDecl "]"
MapTypeDecl        = "[" TypeDecl ":" TypeDecl "]"
UnionTypeDecl      = SimpleTypeDecl { "|" SimpleTypeDecl }
FnTypeDecl         = "(" TypeDecl* "->" TypeDecl ")"
```

Expressions:
```
Expression         = EqExpression     { ("and"|"or"|"xor") EqExpression }
EqExpression       = CmpExpression    { ("=="|"<>") CmpExpression }
CmpExpression      = ShiftExpression  { (">"|"<"|">="|"<=") ShiftExpression }
ShiftExpression    = AddExpression    { (">>"|"<<"|"^") AddExpression }
AddExpression      = MulExpression    { ("+"|"-") MulExpression }
MulExpression      = UnaryExpression  { ("*"|"/"|"%"|"%%") UnaryExpression }
UnaryExpression    = ["not"|"-"]      PrimaryExpression
PrimaryExpression  = ( BINDING_NAME | "(" Expression ")" | ExpressionLiteral )  | FunctionDecl
                     {  "(" Expression* ")" | "." Expression | "[" Expression "]" }
                     (*  function call      / struct access    / seq/map access    *)
                     
FunctionDecl       = "(" TypedName* ")" "->" ( Expression | ["("] TypeDecl [")"] CodeBlock )
CodeBlock          = "{" { ReturnStatement | Binding } "}" | "{" "..." "}"
ReturnStatement    = "::" Expression

```
Named type declaration:
add support for `*` in typedecl
```
NamedType          = TYPE_NAME "=" TypeDecl




StructTypeDecl     = "{" ( TypeDecl* | TypedName* [ "..." ] ) "}" 


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

1. Each function will be mangled with type of it's inputs. So `process(int)` will become `process|1821` where `1821` is typecode of `int`. Each type will have it's own type-code which depends on it's name and point of declaration.

2. Handling access to common parts: If we have `process = (x: {int,...})->int`, the expression `x.0` inside process can refere to different offsets. But compiler will generate the function for all matching types. So it can use appropriate offset when compiling `x.0` for every different type.

3. If struct Circle, embeds Shape, there will be a complete Shape object laid inside Circle. When fields of Shape, are referred directly, compiler will calculate appropriate offset. `Shape = {id:int}`, `Circle = {Shape, r: float}`. Referring to `my_circle.Shape` will return the whole object. `my_circle.Shape.id` will refer to id inside Shape. `my_circle.id` will be mapped to `my_circle.Shape.id`.
