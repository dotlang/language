# EBNF-like grammar

## Legend

Format: 


```
Result  ::= component1 ( component2 | component3 ) | component4 | [component5] component6
- /* comments */
- 'literal'
- (A|B): either of A or B
- A B: A then B
- [A]: Optional A
- (A)* : Repeating A zero or more times
- (A)+ : Repeating A one or more times
```

## Main parts

```ebnf
SourceFile              ::= Module  
Module                  ::= ( ImportDecl | BindingDecl | TypeDecl )*  
```

## Import

```ebnf
ImportDecl              ::= ImportAliasDecl | ImportSelectiveDecl  
ImportAliasDecl         ::= [ ModuleAlias '='] Import  
ModuleAlias             ::= Identifier  
Import                  ::= 'import' '(' StringLiteral ')'  
ImportSelectiveDecl     ::= IdentifierList '=' Import  
```

## BindingDecl

```ebnf
```
 


