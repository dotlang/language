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
<binding_decl> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" <import_binding> | <module_literal> | <function_binding>
<binding_lhs> ::= "_" | <BINDING_NAME> [ ":" <type_decl> ]
<module_literal> ::= ( "(" <module_literal> ")" | <exp_literal> | <exp_literal> ("+"|"-"|"*"|"*") <exp_literal> )
<import_binding> ::= "@" "{" <import_paths> "}" [ "(" <type_decl> { "," <type_decl> } ")" ] [ "{" <import_renames> "}" ]
<import_paths> ::= <STRING> { "," <STRING> }
<STRING> ::= "\"" { character } "\""
<import_renames> ::= <import_rename> { "," <import_rename> }
<import_rename> ::= ( <TYPE_NAME> "=" ">" <TYPE_NAME> ) | ( <BINDING_NAME> "=" ">" <BINDING_NAME> )

(* function_binding *)
<function_binding> ::= "(" [ <arg_def> { "," <arg_def> } ] ")" "-" ">" ( <expression> | ["("] <type_decl> [")"] <code_block> )
<code_block> ::= "{" { <fn_return> | <fn_binding>  "}" } | "{" "..." "}"
<fn_return> ::= "::" <expression>
<fn_binding> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" <expression> | <function_binding>
<expression> ::= <BINDING_NAME> | <fn_call> | <exp_literal> | <exp_op> | <exp_math> | <exp_read>
<exp_literal> ::= <numeric_literal> | <string_literal> | <char_literal> | 
                  <bool_literal> | <struct_literal> | <seq_literal> | <map_literal> | "nothing"
<exp_op> ::=  <range_op> | <nothingcheck_op> | <cast_op> | <struct_modify> | 
              <lambdacreator_op> | <chain_op> | <channel_op> | <select_op>
<exp_read> ::= <seq_read> | <map_read> | <struct_access>
<exp_math> ::= ( <expression> "+" <expression> 

<fn_call> ::= <FN_BINDING_NAME> "(" [ <expression> { "," <expression> } ] ")"
<numeric_literal> ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," } [ "." <DIGIT> { <DIGIT> | "," } ]
<string_literal> ::= "\"" [ { <CHAR> } ] "\"" | "`" { <CHAR> } "`"
<char_literal> ::= "'" <CHAR> "'"
<bool_literal> ::= "true" | "false"
<struct_literal> ::= [ <TYPE_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
<seq_literal> ::= "[" [ <expression> { "," <expression> } ] "]"
<map_literal> ::= "[" [ <map_literal_element> { "," <map_literal_element> } ] "]"
<map_literal_element> ::= <expression> ":" <expression>

<range_op> ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," } ".." ["+"|"-"] <DIGIT> { <DIGIT> | "," }
<nothingcheck_op> ::= <expression> "/" "/" <expression>
<cast_op> ::= ( <TYPE_NAME> | <primitive_type> ) "(" [ <expression> { "," <expression> } ] ")"
<struct_modify> ::= [ <VALUE_BINDING_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
<lambdacreator_op> ::= <FN_BINDING_NAME> "(" [ ( <expression> | "_" ) { "," ( <expression> | "_" ) } ] ")"
```

