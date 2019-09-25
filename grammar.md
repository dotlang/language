# EBNF-like grammar

## Legend

Format: 

```ebnf
Result  ::= component1 ( component2 | component3 ) | component4 | [component5] component6
- /* comments */
- 'literal'
- (A|B): either of A or B
- A B: A then B
- [A]: Optional A
- (A)* : Repeating A zero or more times
- (A)+ : Repeating A one or more times
- {A}  : Repeating A zero or more times, separated with comma
```

## Main parts

```ebnf
Module                  ::= ( ImportDecl | TypeDecl | BindingDecl )*  
```

## Naming basics

```ebnf
TypeName                ::= CAPITAL_LETTER CHAR*
BindingName             ::= ['_test'] (CHAR|'_')*
ModuleAlias             ::= (CHAR|'_')*
```

## Import

```ebnf
ImportDecl              ::= ImportAliasDecl | ImportSelectiveDecl  
ImportAliasDecl         ::= [ ModuleAlias '=' ] Import  
Import                  ::= 'import' '(' ImportString ')'
ImportSelectiveDecl     ::= { BindingName } '=' Import '..' '{' { BindingName } '}'
ImportString            ::= STRING | BindingName | STRING '+' StringLiteral       
```

## Type Declaration

```ebnf
TypeDecl                ::= TypeName (':'|'=') Type
Type                    ::= PrimitiveType | StructType | UnionType | FnType | SeqType | MapType | EnumType | TypeName
PrimitiveType           ::= 'int' | 'float' | 'string' | 'char' | 'byte' | 'bool' | 'nothing' | 'type'
StructType              ::= 'struct' '(' FieldList ')'
FieldList               ::= { [ Identifier ':' ] Type }
UnionType               ::= (Type '|' Type) | (Type '|' UnionType)
FnType                  ::= 'fn' '(' { Type } '->' Type ')'
SeqType                 ::= '[' Type ']'
MapType                 ::= '[' Type ':' Type ']'
EnumType                ::= 'enum' SeqLiteral
```
 
## Binding Declaration

```ebnf
BindingDecl             ::= { BindingNameList } ('='|':=') Expression
BindingNameList         ::= BindingName [ ':' Type ]
Expression              ::= EqExpression     { ('and'|'or') EqExpression }
EqExpression            ::= CmpExpression    { ('=='|'!=') CmpExpression }
CmpExpression           ::= ShiftExpression  { ('>'|'<'|'>='|'<=') ShiftExpression }
ShiftExpression         ::= AddExpression    { ('>>'|'<<'|'^') AddExpression }
AddExpression           ::= MulExpression    { ('+'|'-') MulExpression }
MulExpression           ::= UnaryExpression  { ('*'|'/'|'%'|'%%') UnaryExpression }
UnaryExpression         ::= ['not'|'-']      BasicExpression
BasicExpression         ::= ['('] PrimaryExpression [')']
PrimaryExpression       ::= Literal | Identifier | StructAccessExpression | MapSeqAccessExpression | 
                                ModuleAccessExpression | FnCallExpression | StructExpression | LambdaCreatorExpression | FnDeclaration
StructAccessExpression  ::= Expression '.' Identifier
MapSeqAccessExpression  ::= Expression '[' Expression ']'
ModuleAccessExpression  ::= ( Import | Identifier ) '..' Expression
FnCallExpression        ::= Expression '(' { Expression } ')'
StructExpression        ::= ( TypeName | StructType) '(' FieldValueList ')'
FieldValueList          ::= { [ Identifier ':' ] Expression }
LambdaCreatorExpression ::= Expression '(' { Expression | '_' } ')'
FnDeclaration           ::= 'fn' ['(' { Identifier ':' Type } '->' Type ')'] '{' Expression+ '}'

Literal                 ::= IntLiteral | FloatLiteral | CharLiterl | StringLiteral | NothingLiteral | 
                                BoolLiteral | SeqLiteral | MapLiteral | StructLiteral | TypeLiteral
```
