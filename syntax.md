This is the EBNF-like formal definition for dotLang syntax.

`{X}` means `X` can be repeated zero or more.  
`[X]` means `X` is optional (can be seen zero or one times).  

Tokens:
```
DIGIT              ::= [0-9]
TYPE_NAME          ::= [underscore] capital_letter { letter }
BINDING_NAME       ::= <VALUE_BINDING_NAME> | <FN_BINDING_NAME>
VALUE_BINDING_NAME ::= [underscore] lower_letter { lower_letter | underscore }
FN_BINDING_NAME    ::= [underscore] lower_letter { letter }
STRING             ::= { character } 
INT_NUMBER         ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," }
NUMBER             ::= INT_NUMBER [ "." <DIGIT> { <DIGIT> | "," } ]
```
Basic literals:
```
<module_literal>  ::= "(" <module_literal> ")" | <exp_literal> | NUMBER
                      <module_literal> ("+"|"-"|"*"|"/"|"&") <module_literal> ) | <string_literal>
<exp_literal>     ::= <char_literal> | <bool_literal> | <struct_literal> | 
                      <seq_literal> | <map_literal> | "nothing"
<int_literal>     ::= ["+"|"-"] <DIGIT> { <DIGIT> | "," }
<string_literal>  ::= """ [ <STRING> ] """ | "`" <STRING> "`"
<char_literal>    ::= "'" <CHAR> "'"
<bool_literal>    ::= "true" | "false"
<struct_literal>  ::= [ <TYPE_NAME> ] "{" <fn_binding> { "," <fn_binding> } "}"
<seq_literal>     ::= "[" [ <expression> { "," <expression> } ] "]"
<map_literal>     ::= "[" [ <map_literal_element> { "," <map_literal_element> } ] "]"
<map_literal_element> ::= <expression> ":" <expression>
```
Module:
```
Module ::= { ( <named_type> | StaticBinding ) }
```
Named type declaration:
```
<named_type>     ::= <TYPE_NAME> ":=" <type_decl>
<type_decl>      ::=  <TYPE_NAME> | <primitive_type> | <sequence_type> | <map_type> | <union_type> | 
                      <struct_type> | <fn_type> | <channel_type>
<primitive_type> ::= int | float | char | string | nothing | bool
<sequence_type>  ::= "[" <type_decl> "]"
<map_type>       ::= "[" <type_declaration> "," <type_declaration> "]"
<union_type>     ::= ( <TYPE_NAME> | <primitive_type> ) { "|" ( <TYPE_NAME> | <primitive_type> ) }
<struct_type>    ::= "{" [ ( <unnamed_struct> | <named_strct> ) ] "}" 
<unnamed_struct> ::= <type_decl> { "," <type_decl> } 
<named_struct>   ::= "{" <arg_def> { "," <arg_def> } [ "..." ] "}" 
<arg_def>        ::= <BINDING_NAME> ":" <type_decl>
<fn_type>        ::= "(" [ <type_decl> { "," <type_decl> } ] ")" "-" ">" ["("] <type_decl> [")"]
<channel_type>   ::= <type_decl> ("!"|"?")
```
Bindings at module-level can be either literals, functions or an import. We call these static bindings (vs dynamic bindings which include expressions and runtime calculations which you can define inside a function):
```
StaticBinding  ::= <binding_lhs> { "," <binding_lhs> } ":" "=" ( <import_binding> |   
                      <module_literal> | FunctionDecl )
<binding_lhs>     ::= "_" | <BINDING_NAME> [ ":" <type_decl> ]
<import_binding>  ::= "@" "{" <import_paths> "}" [ "(" <type_decl> { "," <type_decl> } ")" ] 
                      [ "{" <import_renames> "}" ]
<import_paths>    ::= <STRING> { "," <STRING> }
<import_renames>  ::= <import_rename> { "," <import_rename> }
<import_rename>   ::= ( <TYPE_NAME> "=" ">" <TYPE_NAME> ) | ( <BINDING_NAME> "=" ">" <BINDING_NAME> )

FunctionDecl   ::= "(" [ <arg_def> { "," <arg_def> } ] ")" "-" ">" 
                      ( Expression | ["("] <type_decl> [")"] <code_block> )
<code_block>      ::= "{" { <fn_return> | <dynamic_binding>  "}" } | "{" "..." "}"
<fn_return>       ::= "::" <expression>
<dynamic_binding> ::= <binding_lhs> { "," <binding_lhs> } ":" "=" ["="] <expression>
```
Expressions:
```
Expression      ::= <BINDING_NAME> | <function_decl> | <fn_call> | <exp_literal> | 
                       <exp_op> | MathExpression | <seq_map_read> | <struct_access> | <bool_exp>
<exp_op>           ::=  <range_op> | <nothingcheck_op> | <cast_op> | <struct_modify> | 
                        <seq_merge_op> | <lambdacreator_op> | <chain_op> | <channel_op> | <select_op>
MathExpression         ::= MathFactor ("+"|"-"|"*"|"/"|"%"|"%%") MathExpression | MathFactor
MathFactor  ::= "(" Expression ")" | NUMBER
<fn_call>          ::= <expression> "(" [ <expression> { "," <expression> } ] ")"
<range_op>         ::= <int_litearl> ".." <int_litearl>
<cast_op>          ::= ( <TYPE_NAME> | <primitive_type> ) "(" [ <expression> { "," <expression> } ] ")"
<seq_merge_op>     ::= <expression> "&" <expression>
<seq_map_read>     ::= <expression> "[" <expression> "]"
<struct_access>    ::= <expression> "." <BINDING_NAME>
<bool_exp>         ::= <expression> (">"|"<"|"="|"!="|">="|"<=") <expression> | 
                       <bool_exp> ("and"|"or"|"xor") <bool_exp> | "not" <bool_exp>
```
Advanced operators:
```
<nothingcheck_op>  ::= <expression> "/" "/" <expression>
<struct_modify>    ::= [ <expression> ] "{" <fn_binding> { "," <fn_binding> } "}"
<lambdacreator_op> ::= <expression> "(" [ ( <expression> | "_" ) { "," ( <expression> | "_" ) } ] ")"
<chain_op>         ::= ( <expression> | "(" <expression> { "," <expression> } ")" ) "." "{" <chain_lambdas> "}"
<chain_lambdas>    ::= <chain_lambda> { "," <chain_lambda> }
<chain_lambda>     ::= <expression> | <lambdacreator_op>
<channel_op>       ::= <expression> "?" | <expression> "!" <expression>
<select_op>        ::= "$" "{" <select_op_item> { "," <select_op_item> } "}"
<select_op_item>   ::= <channel_op> | "[" <expression> { "," <expression> "]" 
                       ("?" | "!" "[" <expression> { "," <expression> } "]" )
```
