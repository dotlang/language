# EBNF-like grammar

## Format

```ebnf
Result  ::= component1 ( component2 | component3 ) | component4 | [component5] component6
- /* comments */
- 'literal'
- (A|B): either of A or B
- A B: A then B
- [A]: Optional A
- (A)* : Repeating A zero or more times
- (A)+ : Repeating A one or more times
- {A}*  : Repeating A zero or more times, separated with comma
- {A}+  : Repeating A one or more times, separated with comma
```

## Top level

Module is a series of types (named or alias) or bindings (value or function).

```ebnf
Module                  ::= ( TypeDecl | BindingDecl )*  
```

## Naming basics

```ebnf
TypeName                ::= CAPITAL_LETTER (ALPHABET)*
BindingName             ::= ValueBindingName | TypeName | FunctionName
ValueBidningName        ::= (LOWERCASE) (LOWECASE | '_')*
FunctionName            ::= LOWERCASE (LOWERCASE | CAPITAL_LETTER)*
ModuleAlias             ::= ValueBidningName
```

## Type Declaration

Declaration of a named type or type alias

```ebnf
TypeDecl                ::= TypeName (':'|'=') TypeLiteral
TypeLiteral             ::= PrimitiveType | StructType | UnionType | FnType | SeqType | MapType | EnumType | TypeName
PrimitiveType           ::= 'int' | 'float' | 'string' | 'char' | 'byte' | 'bool' | 'nothing'
StructType              ::= 'struct' '{' {StructField}* '}'
StructField             ::= { Identifier ':' Type }
UnionType               ::= (Type '|' Type) | (Type '|' UnionType)
FnType                  ::= 'fn' '(' { Type }* '->' { Type }* ')'
SeqType                 ::= '[' Type ']'
MapType                 ::= '[' Type ':' Type ']'
EnumType                ::= 'enum' SeqLiteral
```
 
## Binding Declaration

Types of expressions you can define by combinindg other expressions (mathematical, struct access, boolean, function call, ...).

```ebnf
BindingDecl             ::= { BindingNameItem }* '=' Expression
BindingNameItem         ::= BindingName [ ':' Type ] | '_'
Expression              ::= EqExpression     { ('and'|'or') EqExpression }*
EqExpression            ::= CmpExpression    { ('=='|'!=') CmpExpression }*
CmpExpression           ::= ShiftExpression  { ('>'|'<'|'>='|'<=') ShiftExpression }*
ShiftExpression         ::= AddExpression    { ('>>'|'<<'|'^') AddExpression }*
AddExpression           ::= MulExpression    { ('+'|'-') MulExpression }*
MulExpression           ::= UnaryExpression  { ('*'|'/'|'%'|'%%') UnaryExpression }*
UnaryExpression         ::= ['not'|'-']      BasicExpression
BasicExpression         ::= ['('] PrimaryExpression [')']
PrimaryExpression       ::= Literal | Identifier | StructAccessExpression | MapSeqAccessExpression | 
                                FnCallExpression | StructExpression | LambdaCreatorExpression | FnDeclaration
StructAccessExpression  ::= Expression '.' Identifier
MapSeqAccessExpression  ::= Expression '[' Expression ']'
FnCallExpression        ::= Expression '(' { Expression }* ')'
StructExpression        ::= ( TypeName | StructType | '&' ) '{' {FieldValueList}* '}'
FieldValueList          ::= { [ Identifier ':' ] Expression }
LambdaCreatorExpression ::= Expression '(' { Expression | '_' }* ')'
FnDeclaration           ::= 'fn' ['(' { Identifier ':' Type } '->' {Type}+ ')'] '{' Expression+ '}'

Literal                 ::= IntLiteral | FloatLiteral | CharLiterl | StringLiteral | NothingLiteral | 
                                BoolLiteral | SeqLiteral | MapLiteral | StructLiteral | TypeLiteral
```


# To Be Added Later

- Generics
- Concurrency
- Modules and import
