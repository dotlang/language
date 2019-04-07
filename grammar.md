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
SourceFile              ::= Module  
Module                  ::= ( ImportDecl | BindingDecl | TypeDecl )*  
```

## Import

```ebnf
ImportDecl              ::= ImportAliasDecl | ImportSelectiveDecl  
ImportAliasDecl         ::= [ Identifier '=' ] Import  
Import                  ::= 'import' '(' StringLiteral ')'
ImportSelectiveDecl     ::= {Identifier} '=' Import '..' '{' IdentifierList '}'
StringLiteral           ::= STRING | Identifier | STRING '+' StringLiteral       
```

## TypeDecl

```ebnf
TypeDecl                ::= AliasTypeDecl | NamedTypeDecl
AliasTypeDecl           ::= TypeName ':' Type
NamedTypeDecl           ::= TypeName '=' Type
TypeIdentifier          ::= CAPITAL_LETTER ALNUM_LETTERS
Type                    ::= PrimitiveType | StructType | UnionType | FnType
PrimitiveType           ::= 'int' | 'float' | 'string' | 'char' | 'byte' | 'bool' | 'nothing' | 'type'
StructType              ::= 'struct' '(' FieldList ')'
FieldList               ::= { [ Identifier ':' ] Type }
UnionType               ::= (Type '|' Type) | (Type '|' UnionType)
FnType                  ::= 'fn' '(' { Type } '->' Type ')'
```
 


