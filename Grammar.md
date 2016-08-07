##Legend

Format: 
`Result: component1 ( component2 | component3 ) | component4 | [component5] component6`

- `/* comments */`
- `'literal'`
- `(A|B)`: one of A or B
- `A B`: A then B
- `[A]`: Optional A

#Main parts

**`SourceFile`**: `[TemplateComment] [ImportSection] (ClassDefinition | InterfaceDefinition)`  

//(StructSection | EnumSection) MethodSection] (InterfaceSection | MethodSection)`

**`TemplateComment`**: `'///<' TemplateParameters '>'`  
**`TemplateParameters`**: `TemplateParameterName '=' TemplateParameterValue [',' TemplateParameters]`  
**`TemplateParameterName`**: `CapitalLetterToken`  
**`TemplateParameterValue`**: `Token`  

**`ImportSection`**: `'import' PackageName [ImportAlias] ';' [ImportSection]`  
**`PackageName`**: `Token ['.' PackageName]`  
**`ImportAlias`**: `'_' | PackageName`  
