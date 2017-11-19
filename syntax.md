This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.  
`[X]` means `X` is optional (can be seen zero or one times).  

Tokens:
```
<DIGIT> ::= [0-9]
<TYPE_NAME> ::= [underscore] capital_letter { letter }
<BINDING_NAME> ::= <VALUE_BINDING_NAME> | <FN_BINDING_NAME>
<VALUE_BINDING_NAME> ::= [underscore] lower_letter { lower_letter | underscore }
<FN_BINDING_NAME> ::= [underscore] lower_letter { letter }
<STRING> ::= { character }  
```
Basic literals:
```
<module_literal> ::= ( "(" <module_literal> ")" | <exp_literal> | 
                     <exp_literal> ("+"|"-"|"*"|"*"|"&") <exp_literal> )
<exp_literal> ::= <numeric_literal> | <string_literal> | <char_literal> | 
                  <bool_literal> | <struct_literal> | <seq_literal> | <map_literal> | "nothing"
<numeric_literal> ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," } [ "." <DIGIT> { <DIGIT> | "," } ]
<string_literal> ::= """ [ <STRING> ] """ | "`" <STRING> "`"
<char_literal> ::= "'" <CHAR> "'"
<bool_literal> ::= "true" | "false"
<struct_literal> ::= [ <TYPE_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
<seq_literal> ::= "[" [ <expression> { "," <expression> } ] "]"
<map_literal> ::= "[" [ <map_literal_element> { "," <map_literal_element> } ] "]"
<map_literal_element> ::= <expression> ":" <expression>
```
Module:
```
<module> ::= { ( <named_type> | <binding_decl> ) }
```
Named type declaration:
```
<named_type> ::= <TYPE_NAME> ":=" <type_decl>
<type_decl> ::=  <TYPE_NAME> | <primitive_type> | <sequence_type> | <map_type> | <union_type> | 
                 <struct_type> | <fn_type> | <channel_type>
<primitive_type> ::= int | float | char | string | nothing | bool
<sequence_type> ::= "[" <type_decl> "]"
<map_type> ::= "[" <type_declaration> "," <type_declaration> "]"
<union_type> ::= <type_decl> { "|" <type_decl> }
<struct_type> ::= "{" [ ( <unnamed_struct> | <named_strct> ) ] "}" 
<unnamed_struct> ::= <type_decl> { "," <type_decl> } 
<named_struct> ::= "{" <arg_def> { "," <arg_def> } [ "..." ] "}" 
<arg_def> ::= <BINDING_NAME> ":" <type_decl>
<fn_type> ::= "(" [ <type_decl> { "," <type_decl> } ] ")" "-" ">" ["("] <type_decl> [")"]
<channel_type> ::= <type_decl> ("!"|"?")
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
<static_binding> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" ( <import_binding> | <module_literal> | <function_decl> )
<binding_lhs> ::= "_" | <BINDING_NAME> [ ":" <type_decl> ]
<import_binding> ::= "@" "{" <import_paths> "}" [ "(" <type_decl> { "," <type_decl> } ")" ] [ "{" <import_renames> "}" ]
<import_paths> ::= <STRING> { "," <STRING> }
<import_renames> ::= <import_rename> { "," <import_rename> }
<import_rename> ::= ( <TYPE_NAME> "=" ">" <TYPE_NAME> ) | ( <BINDING_NAME> "=" ">" <BINDING_NAME> )

<function_decl> ::= "(" [ <arg_def> { "," <arg_def> } ] ")" "-" ">" 
                    ( <expression> | ["("] <type_decl> [")"] <code_block> )
<code_block> ::= "{" { <fn_return> | <fn_binding>  "}" } | "{" "..." "}"
<fn_return> ::= "::" <expression>
<fn_binding> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" <expression>
```
Expressions:
```
<expression> ::= <BINDING_NAME> | <function_decl> | <fn_call> | <exp_literal> | <exp_op> | <exp_math> | 
                 <seq_map_read> | <struct_access> | <bool_exp>
<exp_op> ::=  <range_op> | <nothingcheck_op> | <cast_op> | <struct_modify> | 
              <seq_merge_op> | <lambdacreator_op> | <chain_op> | <channel_op> | <select_op>
<exp_math> ::= <expression> ("+"|"-"|"*"|"/"|"%"|"%%") <expression> 
<fn_call> ::= <expression> "(" [ <expression> { "," <expression> } ] ")"
<range_op> ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," } ".." ["+"|"-"] <DIGIT> { <DIGIT> | "," }
<nothingcheck_op> ::= <expression> "/" "/" <expression>
<cast_op> ::= ( <TYPE_NAME> | <primitive_type> ) "(" [ <expression> { "," <expression> } ] ")"
<struct_modify> ::= [ <VALUE_BINDING_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
<seq_merge_op> ::= <expression> "&" <expression>
<lambdacreator_op> ::= <FN_BINDING_NAME> "(" [ ( <expression> | "_" ) { "," ( <expression> | "_" ) } ] ")"
<chain_op> ::= ( <expression> | "(" <expression> { "," <expression> } ")" ) "." "{" <chain_lambdas> "}"
<chain_lambdas> ::= <chain_lambda> { "," <chain_lambda> }
<chain_lambda> ::= <FN_BINDING_NAME> | <lambdacreator_op>

<channel_op> ::= <VALUE_BINDING_NAME> "?" | <VALUE_BINDING_NAME> "!" <expression>
<select_op> ::= "$" "{" <select_op_item> { "," <select_op_item> } "}"
<select_op_item> ::= <channel_op> | "[" <VALUE_BINDING_NAME> { "," <VALUE_BINDING_NAME> "]" 
                     ("?" | "!" "[" <expression> { "," <expression> } "]" )

<seq_map_read> ::= <VALUE_BINDING_NAME> "[" <expression> "]"
<struct_access> ::= <VALUE_BINDING_NAME> "." <BINDING_NAME>

<bool_exp> ::= <expression> (">"|"<"|"="|"!="|">="|"<=") <expression> | 
               <bool_exp> ("and"|"or"|"xor") <bool_exp> | "not" <bool_exp>
```

