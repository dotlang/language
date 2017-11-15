This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.
`[X]` means `X` is optional (can be seen zero or one times).

First we have the general definition for a module:
```
<module> ::= { ( <named_type> | <binding> ) }
```

Here is syntax for a type definition (e.g. `MyCustoer := {name: string, age:int}`)
```
<named_type> ::= <TYPE_NAME> ":=" <type_decl>
<TYPE_NAME> ::= [underscore] capital_letter { letter }
<type_decl> ::=  <TYPE_NAME> | <primitive_type> | <sequence_type> | <map_type> | <union_type> | <struct_type> | <fn_type>
<primitive_type> ::= int | float | char | string | nothing | bool
<sequence_type> ::= "[" <type_decl> "]"
<map_type> ::= "[" <type_declaration> "," <type_declaration> "]"
<union_type> ::= <type_decl> { "|" <type_decl> }
<struct_type> ::= "{" [ ( <unnamed_struct> | <named_strct> ) ] "}" 
<unnamed_struct> ::= <type_decl> { "," <type_decl> } 
<named_struct> ::= "{" <arg_def> { <arg_def> "," } "}" 
<arg_def> ::= <BINDING_NAME> ":" <type_decl>
<BINDING_NAME> ::= <VALUE_BINDING_NAME> | <FN_BINDING_NAME>
<VALUE_BINDING_NAME> ::= [underscore] lower_letter { lower_letter | underscore }
<FN_BINDING_NAME> ::= [underscore] lower_letter { letter }
<fn_type> ::= "(" [ <type_decl> { "," <type_decl> } ] ")" "-" ">" ["("] <type_decl> [")"]
```
Binding can be either value binding, function binding or an import (can be only defined at module level).
```
<binding> ::= <binding_name> ":" "=" <binding_decl>
<binding_decl> ::= <import_binding> | <function_binding> | <value_binding>
<binding_name> ::= { "_" "," } | { <value_binding_name> "," } | { <fn_binding_name> "," }

(* IMPORT *)
<import_binding> ::= "@" "{" <import_path> "}" [ "(" <type_list> ")" ] [ "{" <import_map_list> "}" ]
<import_map_list> ::= { <import_map> "," }
<import_map> ::= IDENTIFIER "=" ">" IDENTIFIER
<type_list> ::= { <type_name> | <primitive_type> }
<import_path> ::= <string_literal>

(* VALUE *)
<value_binding> ::= <expression>

(* FUNCTION *)
<function_binding> ::= "(" <fn_arg_list> ")" "-" ">" ( <expression> | <fn_output_type> <block> )
<fn_output_type> ::= <type_declaration>
<block> ::= "{" <fn_binding_list> "}" | "{" "}"
<fn_binding_list> ::= <fn_binding> | <fn_binding> <fn_binding_list>
<fn_binding> ::=
```
