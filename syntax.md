This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.
`[X]` means `X` is optional (can be seen zero or one times).

First we have the general definition for a module:
```
<module> ::= { ( <named_type> | <binding_decl> ) }
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
<named_struct> ::= "{" <arg_def> { "," <arg_def> } [ "..." ] "}" 
<arg_def> ::= <BINDING_NAME> ":" <type_decl>
<BINDING_NAME> ::= <VALUE_BINDING_NAME> | <FN_BINDING_NAME>
<VALUE_BINDING_NAME> ::= [underscore] lower_letter { lower_letter | underscore }
<FN_BINDING_NAME> ::= [underscore] lower_letter { letter }
<fn_type> ::= "(" [ <type_decl> { "," <type_decl> } ] ")" "-" ">" ["("] <type_decl> [")"]
```
Bindings at module-level can be either literal binding, function binding or an import:
```
<binding_decl> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" <import_binding> | <literal_binding> | <function_binding>
<binding_lhs> ::= "_" | <BINDING_NAME> [ ":" <type_decl> ]
<import_binding> ::= "@" "{" <import_paths> "}" [ "(" <type_decl> { "," <type_decl> } ")" ] [ "{" <import_renames> "}" ]
<import_paths> ::= <STRING> { "," <STRING> }
<STRING> ::= "\"" { character } "\""
<import_renames> ::= <import_rename> { "," <import_rename> }
<import_rename> ::= ( <TYPE_NAME> "=" ">" <TYPE_NAME> ) | ( <BINDING_NAME> "=" ">" <BINDING_NAME> )
<literal_binding> ::= <STRING> | <literal_expr>
<literal_expr> ::= <BINDING_NAME> | <NUMBER> | "(" <literal_expr> ")" | <NUMBER> ("+"|"-"|"*"|"/") <literal_expr> 

(* function_binding *)
<function_binding> ::= "(" [ <arg_def> { "," <arg_def> } ] ")" "-" ">" ( <expression> | ["("] <type_decl> [")"] <code_block> )
<code_block> ::= "{" { <fn_return> | <fn_binding>  "}" } | "{" "..." "}"
<fn_return> ::= "::" <expression>
<fn_binding> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" <expression> | <function_binding>
<expression> ::= <BINDING_NAME> | <fn_call> | <exp_literal> | <exp_op> | <exp_math> | <exp_read>
<exp_literal> ::= <numeric_literal> | <string_literal> | <struct_literal> | <seq_literal> | <map_literal> | <struct_modify>
<exp_op> ::= <chain_op> | <cast_op> | <range_op> | <channel_op> | <select_op> | <nothingcheck_op] | <lambdacreator_op>
<exp_read> ::= <seq_read> | <map_read> | <struct_access>

<fn_call> ::= <FN_BINDING_NAME> "(" [ <fn_call_args> ] ")"
<fn_call_args> ::= <expression> { "," <expression> }
```
