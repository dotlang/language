##Legend

Format: 
`Result: component1 ( component2 | component3 ) | component4 | [component5] component6`

- `/* comments */`
- `'literal'`
- `(A|B)`: one of A or B
- `A B`: A then B
- `[A]`: Optional A
- `(A)*` : Repeating A zero or more times
- `(A)+` : Repeating A one or more times

#Main parts

**`SourceFile`**: `[TemplateComment] ImportDecl (ClassDefinition | InterfaceDefinition)`  

**`TemplateComment`**: `'//' (TemplateParameterDecl)+`  
**`TemplateParameterDecl`**: `'<' CapitalIdentifier ['=' Identifier] '>'`  

**`ImportDecl`**: `('import' PackageName [ImportAlias] ';')*`  
**`PackageName`**: `Identifier ['.' PackageName]`  
**`ImportAlias`**: `'_' | PackageName`  

**`InterfaceDefinition`**: `[InterfaceStructDecl] (Type Identifier '(' [InterfaceMethodInputs] ');')+`  
**`InterfaceStructDecl`**: `'struct {' (Type ';')+ '}'`  
**`InterfaceMethodInputs`**: `Type Identifier [',' InterfaceMethodInputs]`  

**`ClassDefinition`**: `(StructDecl | EnumDecl) [{' (Statement)+ '}'] (MethodDecl)*`  
**`StructDecl`**: `'struct {' (FieldDecl)+ '}'`  
**`FieldDecl`**: `['const'] Type [Identifier] ['=' Literal] ';'`  
**`EnumDecl`**: `'enum {' (EnumValueDecl)+ '}'`  
**`EnumValueDecl`**: `'CapitalIdentifier ['=' IntLiteral] ';'`  

**`MethodDecl`**: `Type Identifier '(' [ParamDecls] ')' CodeBlock`  
**`ParamDecls`**: `Type Identifier ['=' Literal] ['.' ParamDecls ]`  
**`CodeBlock`**: `Statement ';' | '{' (Statement ';')+ '}'`  

**`Statement`**: `VarDecl | ReturnStmt | AssignmentStmt | CtlStmt`  
**`CtlStatement`**: `IfStmt | ForStmt | SwitchStmt | DeferStmt`  

**`VarDecl`**: `('auto' | Type) Identifier ['=' Expression] ';'`  
**`Expression`**: `MathExp | AnonFuncExp | AnonClassExp | NewClassExp | Literal | Variable | MethodCall`  
**`ReturnStmt`**: `'return' Expression ';'`  
**`AssignmentStmt`**: `Identifier '=' Expression`  
**`IfStmt`**: `'if (' Expression ')' CodeBlock [ElseStmt]`  
**`ElseStmt`**: `'else' (IfStmt | CodeBlock)`  
**`ForStmt`**: `ForWhileStmt | ForArrayLoopStmt | ForHashLoopStmt | ForStdStmt`  
**`SwitchStmt`**:`'switch(' Expression ')' '{' (CaseStmt)+ '}'`  
**`CaseStmt`**: `(Expression | '_'): CodeBlock`  
**`DeferStmt`**:`'defer' Statement ';'`  


