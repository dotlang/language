This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated once or more.

`[X]` means `X` is optional.

First we have the general definition for a module:
```
<module> ::= <empty> | <type_def> <module> | <binding> <module>
```

Here is syntax for a type definition (e.g. `MyCustoer := {name: string, age:int}`)
```
<type_def> ::= <type_name> ":=" <type_declaration>
<arg_def> ::= <binding_name> ":" <type_declaration>

(* NAMES *)
<binding_name> ::= <value_binding_name> | <fn_binding_name>
<value_binding_name> ::= [_]{[a-z][_]}
<fn_binding_name> ::= [_][a-z]{[a-z][A-Z]
<type_name> ::= [_][A-Z][a-z]*

(* TYPES *)
<primitive_type> ::= int | float | char | nothing | string | bool
<sequence_type> ::= "[" <type_declaration> "]"
<map_type> ::= "[" <type_declaration> "," <type_declaration> "]"

(* UNION *)
<union_primitive> ::= <type_name> | <primitive_type>
<union_type> ::= <union_primitive> { "|" <union_primitive> }

(* STRUCT *)
<named_struct> ::= "{" { <arg_def> "," } "}" 
<unnamed_struct> ::= "{" { <type_declaration> "," } "}"
<struct_type> ::= <unnamed_struct> | <named_strct> | "{" "}" 

(* FN TYPE *)
<fn_result_type ::= ["("] <type_declaration> [")"]
<fn_type> ::= "(" { <type_declaration> | <binding_name> <type_declaration> } ")" "-" ">" ["("] <type_declaration> [")"]

<type_declaration> ::=  <primitive_type> | <sequence_type> | <map_type> | <union_type> | <struct_type> | <fn_type>
```
Binding can be either value binding, function binding or an import (can be only defined at module level).
```
<binding> ::= <binding_name> ":" "=" <binding_decl>
<binding_decl> ::= <import_binding> | <function_binding> | <value_binding>
```
