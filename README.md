# dot Programming Language (dotLang)

Make it as simple as possible, but not simpler. (A. Einstein) 

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 0.97

June 26, 2017

# History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 10 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: May 3, 2017 - Clarifications for exception, Adding `where` keyword, explode operator, Sum types, new notation for hash-table and changes in defining tuples, removed `const` keyword, reviewed inheritance notation.
- **Version 0.9**: May 8, 2017 - Define notation for tuple without fields names, hashmap, extended explode operator, refined notation to catch exception using `//` operator, clarifications about empty types and inheritance, updated templates to use empty types instead of `where` and moved `::` and `any` to core functions and types, replaced `switch` with `match` and extended the notation to types and values, allowed functions to be defined for literal input, redefined if to be syntax sugar for match, made `loop` a function instead of built-in keyword.
- **Version 0.95**: May 23, 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to speciying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow operator overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numberic types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (`^` and `%`).
- **Version 0.96**: June 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.97**: June 26, 2017 - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` placeholder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is types statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`.
- **Version 0.98**: ?? ??? ???? - implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to `~`, re-write and clean this document with correct structure and organization, added `autoBind`, change notation for union to `|` and `()` for lambda, simplify primitive types, handle conditional and pattern matching using map and array, renamed tuple to struct, `()` notation to read from map and array, made `=` a statement, added `return` and `assert` statement, updated definition of chaining operator, everything is now immutable, Added concept of namespace which also replaces `autoBind`, functions are all lambdas defined using `let`, `=` for comparison and `:=` for binding

# Introduction

After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: **dotLang**.

dot programming language (or dotLang for short) is an imperative, static-typed, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Elm, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from functional approach.

Two main objectives are pursued in the design and implementation of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few things are done implicitly and transparently by the compiler or runtime system. Also I tried to reduce need for nested blocks and parentheses as much as possible. Another aspect of simplicity is minimaism in the language. It has very few keywords and rules to remember.
2. **Performance**: The compiler will compile to native code which will result in higher performance compared to interpreted languages. Compiler tries to do as much as possible (optimizations, de-refrencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, disposing, ...) so during runtime, there is not much to be done except mostly for memory management. Where performance is a concern, the corresponding functions in core library will be implemented in a lower level language.

Achieving both of the above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  We have bindings (functions and immutable values) types (Blueprints to create bindings). Each function acts on a set of inputs and gives an output. Type system includes primitive data types, struct, union, array and map. Polymorphism, generics and lambda expression are also provided and everything is immutable.

## Comparison with other languages

**Compared to C**: C language + Garabage collector + first-class functions + template programming + better union data types + module system + flexible polymorphism + simple and powerful standard library + lambda expressions + closure + powerful built-in data types (map, string,...) + simpler primitives + multiple dispatch + sane defaults + full immutability - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + full immutability + simpler primitives - *dependency on JVM* - *cryptic syntax* - trait - custom operators - variance - implicit parameters.

**Compared to Go**: Go + *generics* + full immutability + multiple dispatch + union types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives - pointers - interfaces - global variables.

## Components

dotLang consists of these components:

1. The language manual (this document).
2. A command line tool to compile, debug and package source code.
3. Runtime system: Responsible for memory allocation and management, interaction with the Operating System and other external libraries and handling concurrency.
4. Core library: This package is used to implement some basic, low-level features which can not be simply implemented using pure dotLang language.
5. Standard library: A layer above runtime and core which contains some general-purpose and common functions and data structures.

## Code organization

- **Module**: Source code is written inside files which are called "Modules". Modules contain definitions of data structures and functions. Each module can reference other modules to call their functions or use their data structures.
- **Package**: Modules are organized into directories which are called packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:
```
core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
```

In the above examples `/core, /core/sys, /core/net, /core/net/http, /core/net/tcp` are all packages. Each package can potentially contain zero or more modules.

## Language in a nutshell

01. **Import a module**: `import /core/std/queue` (you can also import from external sources like Github)
02. **Primitive types**: `int`, `float`, `char`, `array`, `map`, `func`
03. **Bindings**: `let my_var:int = 19` (type can be automatically inferred, everything is immutable)
04. **Named type**: `type MyInt := int` (This defines a new type with same binary representation as `int`).
05. **Struct type**: `type Point := {x: int, y:int, data: float}` (Like `struct` in C)
06. **Struct literal**: `let location := Point{x=10, y=20, data=1.19}`
07. **Composition of structs**: By embedding, `type Circle := {Shape, radius: float}`
08. **Array**: `let jobQueue: array[int] := [0, 1, 2, 3]`
09. **Map**: `let countryPopulation: map[string, int] := [ "US": 300, "CA": 180, "UK": 80 ]`
10. **Generics**: `type Stack[T] := { data: array[T], info: int }`
11. **Union type**: `type Maybe[T] := T | nothing`
12. **Function**: `let calculate: func(int,string)->float := (x, y) -> float { return x/y  }`

# Summary of notations

**List of symbols**

01. `~`  chain operator (To chain function calls)
02. `@`  type-id operator (Return unique identifier of types)
03. `|`  union data type (Define different possible types)
04. `_`  placeholder (lambda creator, unknown variable in assignments or function argument)
05. `:`  type declaration for struct and function input and values, map literal, type alias
06. `:=` Binding declaration, named types
07. `..` range generator
08. `->` function declaration, module alias
09. `[]` generics, array and map literals, reading from array and map
10. `{}` code block, struct definition and struct literal, casting
11. `()` function declaration and call
12. `.`  access struct fields
13. `::` address inside a module alias

**Keywords**: `import`, `type`, `let`, `return`, `assert`

**Primitive data types**: `int`, `float`, `char`, `array`, `map`, `func`

**Extended primitive types**: `nothing`, `bool`, `string`

**Other reserved identifiers**: `true`, `false`

## General rules

- **Encoding**: Modules are encoded in UTF-8 format.
- **Indentation**: Indentation must be done using spaces, not tabs. Using 4 spaces is advised but not mandatory.
- **Comments**: `//` is used to start a comment.
- **Literals**: `123` is integer literal, `'c'` is character literal, `"this is a test"` string literal, `0xffe` hexadecimal number, `0b0101011101` for binary number. You can separate digits using undescore: `1_000_000`.
- **Terminator**: Each statement must be in a separate line and must not end with semicolon.
- **Order**: Each module contains 3 sections: imports, types and binding. The order of the contents of source code file matters: `import` section must come first, then types and lastly bindings. If the order is not met, compiler will give errors.
- Import section is used to reference other modules that are being used in this module.
- Type section is used to define data types.
- Bindings section is used to define function bodies.
- **Encapsulation**: If a name (of a type or binding) starts with underscore, means that it is private to the module. If not, it is public and can be used from outside using `import` statement.
- **Naming**: (Highly advised but not mandatory) `someFunctionName`, `my_var_name`, `SomeDataType`, `my_package_dir`, `my_modue_file`. If these are not met, compiler will give warnings. Primitive data types and basic types defined in core (`array`, `map`, `bool`, `string` and `nothing`) are the only exceptions to naming rules.

# import

1. This keyword is used to import another module into current module's namespace. After importing a module, you can use it's types, call it's functions or work with the baindings in the module in any way.
2. You can import a module into a separate named namespace. If you do this, you can only access the definitions by prefixing namespace name.
3. Note that elements that start with underscore are considered private and will not be available when you import their module.

**Syntax**

1. `import /path/to/module`
2. `import /path/to/module -> Name`

**Example**

1. `import /core/st/Socket` 

Imports all type and bindings in this module into current namespace

2. `import /core/st/Socket -> mod1` 

same as above but import into `mod1` namespace
2. `import /core/std/{Queue, Stack, Heap} -> A,B,C`, we have three new modules imported under A,B,C names
`let createSocket := mod1::createSocket`
`type socketType := mod1::SocketType`
2. `import /core/std/{Queue, Stack, Heap}`
8. `import git/github.com/adsad/dsada`
9. `import svn/bitcucket.com/adsad/dsada`

**Notes**

0. Each module has it's own namespace which is called default namespace. You can define new namespaces using `import`.
Any definition using type or let, adds to the default namespace. You can also merge other modules into default namespace using `import _ := ...` statement.
`/` in the beginning is shortcut for `file/`. Namespace path starts with protocl which determines the location for file for namespace.
`A::B` means A is alias name and B is name of a type or function or binding.
**TODO Update**
1. You cannot import multiple modules using wildcards. Each one must be imported in a separate command.
2. You can import multiple modules with same package using notation in Example 2.
3. There must be a single space between `import` keyword and it's parameter.
4. Import paths starting with `/` mean they are absolute path (Regarding dotLang's runtime import path).
5. If an import path does not start with `/` means the module path is relative to the current module.
6. It is an error if as a result of imports, there are two exactly similar functions (same name, input and output). In this case, none of conflicting functions will be available for call. 
7. If you add a slash at the end of import file, it means import symbols using fully qualified name (Example 3)
8. Functions imported with fully-qualified method won't be used in method dispatch mechanism. You must explicitly call them or use data types in the module using fully-qualified notation. (Example 4 and 5).
9. You can use function redirection to work with FQ functions (Example 6) or use type alias to work with FQ type names (Example 7).
10. `import` supports other systems too. By default it imports modules from local file-system. But depending on the prefix used you can import from other sources too (Example 8).

# Binding

**Semantic**: Used to declare a unique binding name and assign an expression to it.

**Syntax**: `let identifier [: Type] = expression`, `identifier = expression`

**Examples**

1. `let x: int := 12`
2. `let g := 19.8`
3. `let a,b := process()`
4. `let x := y`
6. `let x := y`
7. `let a,b := {1, 100}`

**Notes**

1. `expression` can be a literal, function call, another binding or a combination.
2. You cannot re-assign a name to a new value, because everything is immutable.
3. Example 1 defines a binding called `x` which is of type `integer` and stores value of `12` in it.
4. Compiler automatically infers the type of binding from expression, so type is optional except in special cases (e.g. `unions`)
5. There should be one space after `let` and before binding name.
6. If right side of `=` is a struct type, you can destruct it's type and assign it's value to different bindings (Example 3 and 7). See struct section for more information.
7. Declaration makes a copy of the right side if it is a simple identifier (Example 4). So any future change to `x` will not affect `y`.
8. You can use a block as the expression and the last evaluated value inside the block will be bound to the given identifier (Example 5).
9. Note that assignment operator, makes a copy of the right side variable and assign it to the left side variable.
10. Assignment is a statement and not an operator. So you cannot combine it with other things in one line.

# Simple types

**Semantics**: Provide basic feature to define most commonly used data types.

**Syntax**: `int`, `float`, `char`

**Examples**

1. `let x = 12`
2. `let x = 1.918`
3. `let x = 'c'`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.

## Basic types

**Semantics**: These important data types are some basic and well known types with simple definition.

**Syntax**: `nothing`, `bool`, `string`

**Examples**

1. `let g: bool = true`
3. `let str: string = "Hello world!"`

**Notes**

1. `string` is defined as an array of `char` data type. The conversion from/to string literals is handled by the compiler.
2. String literals should be enclosed in double quotes. 
3. String litearls enclosed in backtick can be multi-line and escape character `\` will not be processed in them.
4. `nothing` is a label type which is used in union types, specially `maybe` type.
5. `bool` type is a union of two label types: `true` and `false`.

# Compound types

## Array

**Semantics**: Define a fixed-size sequence of elements of the same type.

**Syntax**: `array[type]`

**Examples**

1. `let arr = [1, 2, 3]`
2. `let g = arr(0)`, `arr = set(arr, 0, 100)`
4. `let two_d_array: array[array[int]] = [ [1,2,3], [4,5,6] ]`
5. `let two_d_array = [ [1,2,3], [4,5,6] ]`
6. `let p = two_d_array(0, 0)`
7. `let arr2 = [0..10]`
8. `let arrx: array[int] = [1, 2, 3]`

**Notes**

1. Above examples show definition and how to read/update array.
2. In example 7, the range operator `..` is used to generate an array literal. Note that the end number is not included in the result.
3. You can explicitly state array literal type like in example 8.
5. You can use array name as a lambda and use chaining operator to read it's data (Example 9) for more information refer to operators and lambda sections.
6. array is not a function. It acts like a function when reading or writing data.
7. If you refer to an index outside array bounds, it will give you zero-value + a false flag. Similar to `map`.

## Map

**Semantics**: Represent a mapping from key to value.

**Syntax**: `map[key, value]`

**Examples**

1. `let my_map = ["A": 1, "B": 2, "C": 3]`
2. `let item1, found = my_map("A")`
3. `set(my_map, "A", 2)`
4. `let my_map: map[string,int] = ["A": 1, "B": 2, "C": 3]`
5. `"A" ~ myMap(_)`


**Notes**

1. You need to use core functions to manipulate a map, because (like everything else), they are immutable.
2. If you query a map for something which does not exist, it will return zero-value for that type + a false flag.
3. You can explicitly state type of a map literal like example 4.
4. You can use prefix or suffix notation to read from map (Example 2).
5. You can use map name as a lambda and use chain operator to read or write values (Example 5). For more information refer to operators and lambda sections.
6. map is not a function. It acts like a function when reading or writing data.

## Union

**Semantics**: A primitive meta-type to provide same interface which can contain different types.

**Syntax**: `type1 | type2 | IDENTIFIER1 | ...`

**Examples**

1. `type day_of_week := SAT | SUN | MON | TUE | WED | THU | FRI`
2. `let int_or_float: int | float = 11`
3. `let int_or_float = 12.91`
4. `let int_or_float = 100`
5. `int_value, done = int{my_union}`
6. `let has_int = (@my_int_or_float == @int)`

**Notes**

1. You can use either types or identifiers for union cases. If you use an identifier you must use a capital identifier and it's name should be unique.
2. Example number 1 shows usage of label types to define an enum type to represent days of week.
3. Example 2, defines a union with explicit type and changes it's value to other types in next two examples.
4. You can use the syntax in example 5 to cast a union to another type. Result will have two parts: data and a flag.
5. `int | flotOrString` will be simplified to `int | float | string`
6. Example 6 shows using `@` operator to fetch real type of a union variable.

## Struct

**Semantice**: As a product type, this data type is used to defined a set of coherent variables of different types.

**Syntax**: 

1. Declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. Typed Literal: `Type{field1=value1, field2=value2, field3=value3, ...}` 
3. Untyped literal: `{value1, value2, value3, ...}` 
4. Update: `original_var{field1=value1, field2=value2, ...}` 

**Examples**

1. `type Point := {x:int, y:int}`
4. `point1 = {100, 200}`
2. `point2 = Point{x=100, y=200}`
3. `point3 = Point{100, 200}`
3. `point4 = point3{y=101}`
5. `x,y = point1`
6. `x,y = {100,200}`
7. `another_point = Point{x=11, y=my_point.y + 200}`
8. `another_point = my_point`
9. `new_point = {a=100, b=200} //WRONG!`
10. `let x = point1.1`

**Notes**

1. Example 1 defines a named type for a 2-D point and next 2 examples show how to initialise variables of that type.
2. If you define an untyped literal (Example 4), you can access it's component by destruction (Example 5).
3. Examples 5 and 6 show how to destruct a struct and extract it's data.
4. Example 7 and 8 are the same and show how to define a struct based on another struct.
5. Example 9 indicates you cannot choose field names for an untyped struct literal.
6. You can use `.0,.1,.2,...` notaion to access fields inside an untyped tuple (Example 10).

## Composition

**Semantics**: To include (or embed) the data defined in another struct type.

**Syntax**: `{Parent1Type, field1: type1, Parent2Type, field2: type2, Parent2Type, ...}`

**Examples**
1. `type Shape := { id:int }`
2. `type Circle := { Shape, radius: float}`
3. `my_circle = Circle{id=100, radius=1.45}`
4. `type AllShapes := |{Shape}|`
5. `someShapes = AllShapes[myCircle, mySquare, myRectangle, myTriangle]`

**Notes**
1. In the above example, `Shape` is the contained type and `Circle` is container type.
2. The language provides pure "contain and delegate" mechanism as a limited form of polymorphism.
3. A struct type can embed as many other struct types as it wants and forward function calls to embedded structs. Refer to function section for more information about forwarding functions.
4. You can define a union type which accepts all struct types which embed a specific struct type. See examples 4 and 5.
5. Note that polymorphism does not apply to generics. So `array[Circle]` cannot substitute `array[Shape]`. But you can have `array[Circle|Square]` to have a mixed array of different types.
6. We use closed recursion to dispatch function calls. This means if a function call is forwarded from `Circle` to `Shape` and inside that function another second function is called which has candidates for both `Circle` and `Shape` the one for `Shape` will be called.
7. `|{T}|` where T is a named type can be used to indicate all structs that embed that type (Example 4).

# Type system

## Type alias

**Semantics**: To define alternative names for a type.

**Syntax**: `type NewName : CurrentName`

**Examples**

1. `type MyInt : int`

**Notes**

1. In the above example, `MyInt` will be exactly same as `int`, without any difference.
2. This can be used in refactoring process or when there is a name conflict between types imported from different modules. See `import` section for more information.
3. There must be a single space between `type` and alias name.

## Named type

**Semantics**: To introduce new types based on existing types (called underlying type).

**Syntax**: `type NewType := UnderlyingType`

**Examples**

1. `type MyInt := int`
2. `type IntArray := array[int]`
3. `type Point := {x: int, y: int}`
4. `type bool := true | false`
5. `let x: MyInt = 10`, `let y: MyInt = MyInt{10}`

**Notes**

1. There must be a single space between `type` and type name.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. Although their binary data representations are the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to corresponding section for more information.
4. You can use casting operator to convert between a named type and it's underlying type (Example 5).
5. If a type is implemented in the runtime, it's definition will be `{...}`. For example `type array[T] := {...}`

## Casting

**Semantics**: To change type of data without changing the semantics of the data (Used for union, named types and primitives)

**Syntax**: `Type{identifier}`

**Examples**

1. `x:int = 1.91`
2. `int_value, has_int = int{int_or_float}`
3. `type MyInt := int`
4. `x:MyInt = 100`
5. `y:int = x`

**Notes**

1. There is no implicit and automatic casting in the language. The only case is for `true` to be 1 and `false` to be 0 when used as an array index.
2. Casting is mostly used to cast between a union and it's internal type (Example 2) or between named and equal unnamed type (Example 4 and 5). 
3. If function expects a named type, you cannot pass an equivalent unnamed type. 
4. Similarly, when a function expects an unnamed type, you cannot pass a named type with same underlying type. 
5. Another usage of casting is to cast between `int` and `float` and `char` (Example 1).
6. When casting for union types, you get two outputs: Target type and a boolean flag indicating whether cast was successful.

## Type-id operator

# Generics

## Declaration

**Semantics**: To define a function or data type which has one or more types defined like variables. These types will get their values when the function is called or the data type is used to initialize a value.

**Syntax**: 

1. `func funcName[T1, T2, T3, ...](input1: type1, input2: T1, input3: T3, ...)->T2`
2. `type TypeName[T1, T2, T3, ...] := { field1: int, field2: T2, field3: float, ...}`

**Example**

01. `type Stack[T] := array[T]`
02. `type Tree[T] := {x: T, left: Tree[T], right: Tree[T]}`
03. `type optional[T] := nothing|T`
04. `type BoxedValue[T] := {value:T}`
05. `func push[T](s: Stack[T], data: T) ...`
06. `func pop[T](s: Stack[T])->T...`
07. `func length[T](s: Stack[T])->int`
08. `func extract[T](that: BoxedValue[T])->T that.value`
09. `func push[int](s: Stack[int], data:int)...`
10. `x = optional[int]{12}`
11. `x = BoxedValue[int]{1}`
12. `y = BoxedValue[string]{value: "a"}`
13. `xx = extract(x)`
14. `yy = extract[string](y)`

**Notes**:

1. Compiler will scan body of generic functions and extract their expected methods. If you invoke those functions with inappropriate types, it will give you list of required methods to implement.
2. When calling a generic function, you can include type specifier if it cannot be deduced from input or for purpose of documenting the code (Example 13 includes type to document that `yy` will be of type `string`).
3. You can specialize generic functions for a specific type or types (Example 9 specializes function defined in example 5).

## Phantom types

**Semantics**: To document compile time constrcints on the data without runtime cost using generics or named types (When generic type is not used on the right side of type definition, it will be only for compile time check)

**Syntax**: Like generic data types

**Examples**

1. `type HashType := MD5|SHA1`
2. `type HashStr[T] := string`
3. `type Md5Hash := HashStr[MD5]` 
4. `type Sha1Hash := HashStr[SHA1]`
5. `func md5(s: string)->Md5Hash { ... }`
6. `func sha1(s: string)->Sha1Hash { ... }`
7. `t = Md5Hash{sha1("A")} //ERROR!`
8. `type SafeString := string`
9. `func processString(s: string)->SafeString`
10. `func work(s: SafeString)`
11. `type DoorState := Open|Closed`
12. `type Door[T] := string`
13. `func closeDoor(x: Door[Open]) -> Door[Closed]`
14. `func openDoor(x: Door[Closed]) -> Door[Open]`

**Notes**

1. Phantom are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. 
2. You can implement these labels using a named type or a generic type.
3. Examples 1 to 7 show a et of hash functions that returns a specific type which is derived from `string`. This will prevent the developer sending a md-5 hash to a function which expects sha-1 hash (Example 7 will give compiler error).
4. Examples 8 to 10 indicate using named functions to represent a "sanitized string" data type. Using this named type as the input for `work` function will prevent calling it with normal strings which are not sanitized through `processString` function.
5. Examples 11 to 14 indicate a door data type which can only be opened if it is already closed properly and vice versa.

# Functions
When type of the function indicates input types, in the literal part just mention input names.

## Declaration

**Semantics**: To group a set of coherent commands into a named lambda, with specific input and output.

**Syntax**: `let functionName: func(type1, type2, type3, ...) -> OutputType := (name1: type1, name2: type2...) -> OutputType { code block }`

Note that `func(int,int)->int` is a type. `(x:int, y:int)->{x+y}` is value.

**Examples**

01. `let myFunc(int, int) -> int := func(x:int, y:int)-> int { return 6+y+x }`
02. `let log(s: string) -> { print(s) }`
03. `let process(pt: Point)->int { pt.x }`
04. `let process2(pt: Point) -> {pt.x, pt.y}`
06. `let my_func(x:int) -> x+9`
07. `let myFunc9(x:int) -> {int} {12}`
08. `let PI -> 3.14`
09. `let process(x: int|Point])->int`
10. `let fileOpen(path: string) -> File {...}`
11. `let process(_:something) -> 10`

**Notes**:

0. Functions are defined like lambdas. Note that `func` is part of type of a function. But for a function literal (the expression that comes after `:=` in function definition, it does not need `func` keyword).
1. Every function must return something which is specified using `return`. If it doesn't, compiler marks output type as `nothing` (Example 2).
2. A function call with union data, means there must be functions defined for all possible types in the union. See Call resolution section for more information.
3. You can define consts using functions (Example 6).
4. There must be a single space between func and function name.
5. You can omit function output type and let compiler infer it, only if it has no body (Examples 4, 6 and 8).
6. You can omit braces and `return` keyword if you only want to return an expression (Examples 4, 6, 7 and 8).
7. Each function must have an output type. Even if it does not return anything, output type will be `nothing`.
8. Function output can be struct type without field names or with a named struct type (Examples 5 and 7). In other words, you cannot define a new type at the time of function definition.
9. You can define variadic functions by having an array input as the last input. When user wants to call it, he can provide an array literal with any number of elements needed.
10. The function in example 9 will be invoked if the input is either `int` or `Point` or `int|Point`.
11. There should not be ambiguity when calling a function. So having functions on examples 9 and 3 in same compilation is invalid.
12. If a function is implemented in the runtime or core sub-system, it's body will be written as `{...}`
13. Only local variables are mutable. So function cannot modify it's inputs.
14. You can call a function that accepts `int|string` with either `int` or `string` or `int|string`.
15. You can use `_` as the name of function input to state you don't need it's value.

## Invocation

**Semantics**: Execute commands of a pre-declared function.

**Syntax**: `output = functionName(input1, input2, ...)`

**Examples**

1. `pi = PI()`
2. `a,b = process2(myPoint)`
3. `_,b = process2(myPoint)`
4. `struct1 = myFun9();`

**Notes**

1. You can use `_` to ignore a function output (Example 3).
2. Parentheses are required when calling a function, even if there is no input.

## Call forwarding

**Semantics**: To forward a function call to another function, used to implement subtyping.

**Syntax**: `func funcName(type1->type2, type3, type4->type5, ...)`

**Examples**

1. `func draw(Circle->Shape)`
2. `func process(union(Polygon, Square, Circle)->Shape, GradientColor|SolidColor]->Color)`
3. `func process(float, |{Shape}|->Shape, string, int, GradientColor|SolidColor->Color, int)`

**Notes**

1. Example 1, indicates any call to function `draw` with a parameter of type `Circle` must be sent to a function with the same name and `Shape` input. In this process, the argument will be converted to a `Shape`.
2. Example 2, will forward any call to function `process` with first input of type `Polygon`, `Square` or `Circle` and second argument of `GradientColor` or `SolidColor` to the same name function with inputs `Shape` and `Color` type. All other inputs which are not forwarded are the same between original and forwarded function. This definition is for 6 functions and forwarding all of them to a single function.
3. Example 3, is like example 2 but uses a generic union to indicate all types that embed a Shape.
4. Note that left side of `->` must embed the type on the right side.

## Function pointer

**Semantics**: A special data type which can hold a reference to a function.

**Syntax**: `type Fp := func(type1, type2, ...)->OutputType`

**Examples**

1. `type adder := func(int,int)->int`
2. `func myAdder(x:int, y:int) -> x+y`
3. `adderPointer = adder{myAdder}`
4. `func sort(x: array[int], comparer: func(int,int) -> bool) -> array[int]`
5. `func map[T, S](input: array[T], mapper: func(T) -> S) -> array[S]`

**Notes**

1. Example 4 indicates a function which accepts a function pointer.
2. Example 5 indicates the definition for a mapping function. It is using generics features introduces in the corresponding section.
3. Value of a function pointer can be either an existing function or a lambda. Refer to corresponding section for more information.
4. In a function type, you should not include input parameter names.

## Lambda
Merge with function?

**Semantics**: Define function literals of a specific function pointer type, inside another function's body.

**Syntax**: `(name1: type1, name2: type2, ...) -> output_type { body }`

**Examples**

1. `f1 = (x: int, y:int) -> int { x+y }`
2. `f1 = (x: int, y:int) -> { x+y }` ;the most complete definition
3. `rr = (x: int, y:int) -> x + y`  ;return type can be inferred
4. `rr = () -> { x + y }`
5. `func test(x:int) -> plusFunc { |y:int| -> y + x }`
6. `(x:int)->int { x+1 } (10)`
7. `func process(x:int, y:float, z: string) -> { ... }`
8. `lambda1 = process(10, _, _)`
9. `ff = (x:int) -> { ff(x+1) }`
10. `(x:int)-> {print(x), x-1}`

**Note**

1. You can omit output type (Example 2 and 3).
2. Even if lambda has no input you must include `()` (Example 4).
3. Lambdas are closures and can capture variables (as read-only) in the parent function (Example 4 and 5).
4. Example 5 shows a function that returns a lambda.
5. Example 6 shows invoking a lambda at the point of definition.
6. You can use `_` to define a lambda based on an existing function or another lambda or function pointer value. Just make a normall call and replace the lambda inputs with `_`. Example 8 defines a lambda to call `process` functions with `x=10` but `y` and `z` will be inputs.
7. If lambda is assigned to a variable, you can invoke itself from inside (Example 9).
8. You can put multiple statements in a lambda and separate them with comma (Example 10).
9. In a range operator, you can specify two lambdas. In this case, the first lambda will return the next element and the second lambda will return output of the current iteration round. The second lambda will not be called if output of the first lambda is same as the end marker.

## assert

**Semantics**: Early return if a condition is not satisfied

**Syntax**: `assert predicate, expression`

**Examples**

1. `assert x>0, error("x must be positive")` 

## Chain operator

**Semantics**: To put arguments before function or struct or map or array.

**Syntax**: 

1. `input ~ func(_,_,_,...)`
2. `input ~ {_,_,_,...}`
3. `input ~ arr(_)`
4. `input ~ map(_)`

**Examples**

1. `{x,y,z} ~ {_,_,_}` => `{x,y,z}`
2. `g = {5,9} ~ add(_, _)` => `g = add(5,9)`
3. `{1,2} ~ processTwoData(_, _)` => `processTwoData(1,2)`
4. `{1,2} ~ processStruct(_)` => `processStruct({1,2})`
5. `6 ~ addTo(1, _)` => `addTo(1, 6)`
6. `result = {input, check1(5, _)} ~ pipe(_,_) ~ {_, check3(1,2,_)} ~ pipe(_, _) ~ {_, check5(8,_,1) } ~ pipe(_,_)`
7. `func pipe[T, O](input: Maybe[T], handler: func(T)->Maybe[O])->Maybe[O] ...`
8. `{1,2} ~ {_, _, 5} ~ process(_,_,_)` => `process(1,2,5)`.
9. `func inc(x:int) -> x+1`, `let eleven = 10 . inc(_)`
10. `func add(x:int, y:int) -> x+y`, `{10, 20} . add(_,_)`

**Notes**

1.  `X ~ F(_)` will be translated to `F(X)` unless `F` cannot accept input of type `x`, in which case it will be evaluated to `X`.
2. right side of `~` must be either a closure with expected inputs or a struct with underscores for substitition, a map or an array.
3. If right-side expects a single input but left side is a struct with multiple items, it will be treated as a struct for the single input of the function (Example 4) but if function expects multiple inputs they will be extracted from left side (Example 3). 
8. You can also pass a single argument to right side of the chain by using non-struct value.
9. You can use chain operator with custom functions as a monadic processing operator. For example you can streamline calling mutiple error-prone functions without checking for error on each call (Example 6 and 7).
11. You can use chain operator to read from map and array too.
12. The approach of Example 6 and 7 can also be used to do error checking and early return in case of invalid inputs. For example `return validate_data(x,y,z) ~ process1(_)`. If output of `validate_data` is not what `process1` expects, it will be result of the expression.

# Operators

## Basic operators

**Semantics**: All non-alpabetical notations operators used in the language.

**Syntax**:

1. Conditional operators: `and, or, not, =, !=, >=, <=`
2. Arithmetic: `+, -, *, /, %, %%, +=, -=, *=, /=`
3. Assignment: `=`
4. Type-id: `@`
6. Casting `{}`

**Examples**

01. `g = @int`, `g = @my_union`
02. `y:int = x`
03. `y: int|float = 12`

**Notes**:

1. `=` operator copies data from right-side into the left-side.
2. `==` will do comparison on a binary-level. If you need custom comparison, you can do in a custom function.
3. Operators for bitwise operations and exponentiation are defined as functions.
4. `@`: returns type-id of a named or primitive type as an integer number, or a union variable (Example 1).
5. `{}`: To cast from named to unnamed type you can use: `Type{value}` notation (Example 2).
6. `{}`: To cast from variable to a union-type (Example 3).


# Features

## Conditionals and pattern matching

**Semantics**: We use array and map literals to implement conditionals, loops and pattern matching.

**Examples**

1.
```
let y:int = switch(int_or_float_or_string, [@int: (x:int)->1+x, @string: (s:string)->10], ()->100)
...
type FF[T,X] := func(T)->X
func switch[S,T,U,X](v: S|T|U, mp: map[int, FF[S,X]|FF[T,X]||FF[U,X]], else: func()->X)->X {
  let func_to_call: FF[S,X]|FF[T,X]||FF[U,X], found:bool = [@S: mp[@S], @T: mp[@T], @U: mp[@U]](@v)
  //reading from map, returns a maybe
  let result,_ = [true: func_to_call(v), false: else()](found)
  
  result
}
```
2.
```
let y:int = switch(int_or_float_or_string, [@int: (x:int)->1+x, @string: (s:string)->10], ()->100)
...
type FF[T,X] := func(T)->X
func switch[S,T,U,X](v: S|T|U, mp: map[int, FF[S,X]|FF[T,X]||FF[U,X]], else: func()->X)->X {
  let func_to_call: FF[S,X]|FF[T,X]||FF[U,X], found:bool = [@S: mp[@S], @T: mp[@T], @U: mp[@U]](@v)
  //reading from map, returns a maybe
  let result,_ = [else(), func_to_call(v)](found)
  
  result
}
```

**Notes**

1. Example 1 shows a simple case of implementing pattern matching.
2. You can also use array for conditionals. `true` will be mapped to index `1` and `false` to index `0`.

## dispose

**Semantics**: This function is used to invalid a binding and release any memory or resources associated with it.

**Syntax**: `dispose(x)`

**Notes**

1. You cannot use a variable after calling dispose on it. 
2. You can call dispose on any variable.
3. Dispose function will properly handle any resource release like closing file or socket or ... .


## Exclusive resource

**Semantics**: Represents a system resource (file, network socket, database connection, ...) which needs to have an exclusive owner and cannot be duplicated like normal values.

**Syntax**: Exclusive resources are defined in core (file descriptor, thread, sockets) and contain an identifier to indicate their owner thread.

**Notes**

1. These types are not supposed to be shared between two threads, because of their inherent mutability. If this happens, runtime will throw error. They all contain an owner thread identifier which is checked by core functions.
2. If you are not returning an exclusive resource, you must explicitly call `dispose` on it. Else compiler will issue error.

## Exception handling

**Semantics**: Handle unexpected and rare conditions.

**Syntax**: `func process() -> int|exception { ... exception{...} }`

**Examples**

1. `result: int|exception] = invoke(my_function)`

**Notes**

1. There is no explicit support for exceptions. You can return a specific `exception` type instead.
2. You can use chaining operator to streamling calling multiple functions without checking for exception output each time.
3. If a really unrecoverable error happens, you should exit the application by calling `exit` function in core.
4. In special cases like a plugin system, where you must control exceptions, you can use core function `invoke` which will return an error result if the function which it calls exits.

## autoBind

**Semantics**: We can cast a namespace to a struct. This act will map bindings with similar names to fields inside the struct.

**Syntax**: `x = StructType{Alias}`, `x = StructType{::}`

**Examples**

1. `type Comparer[T] := { compare: func(T,T)->bool }`
2. `func sort[T](x: array[T], f: Comparer[T])->array[T] { ... }`
3. `sort(myIntArray, Comparer{::})`
4. `sort(myIntArray, Comparer[int]{::})`

**Notes**

TODO: update
1. Example 1 defines a general struct which only contains function pointer fields.
2. Example 2 defines a function to sort any given array of any type. But to do the sort, it needs a function to compare data of that type. So it defines an input of type `Comparer[T]` to include a function to do the comparison.
3. Example 3 shows how to call `sort` function defined in example 2. You simply call `autoBind` to create appropriate struct of appropriate types by the compiler. So `f.compare` field will contain a function pointer to a function with the same name and signature.
4. Example 4 is same as example 3 but with explicit types. You can omit these types as compiler will infer them.
5. You can also create your own custom struct with appropriate function pointers to be used in sort function. `autoBind` just helps you create this set of function pointers easier.
6. The struct defined in example 1 is called a protocol struct because it only contains function pointers. These structs are just like normal structs, so for example you can embed other structs inside them and as long as they only contains function pointers, they will be protocol structs.
7. `autoBind` works only on protocol structs.


# Examples

## Empty application

```
func main() -> 
{
    0 
}
```

or even simpler: `func main() -> 0`

This is a function, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

## Hello world

## Quick sort

## Graph class

## Expression parser

We want to write a function which accepts a string like "2+4-3" and returns result (`3`).

```
type NormalExpression := {op: char, left: Expression, right: Expression}
type Expression := int|NormalExpression

func eval(input: string) -> float 
{
  exp = parse(input)
  innerEval(exp)
}

func innerEval(exp: Expression) -> float 
{
  switch exp
  {
    x: int -> x,
    y: NormalExpression ->
    {
        switch y.op
        {
          '+': innerEval(y.left) + innerEval(y.right),
          '-': innerEval(y.left) - innerEval(y.right),
          '*': innerEval(y.left) * innerEval(y.right),
          '/': innerEval(y.left) / innerEval(y.right),
      }
    }
  }
}
```

# Other components

## Core package

A set of core packages will be included in the language which provide basic and low-level functionality (This part may be written in C):

- Security policy (how to call a code you don't trust)
- Calling C/C++ methods
- Interacting with the OS
- Load code on the fly and hot swap
- Data conversion
- Garbage collector (Runtime)
- Serialization and Deserialization
- Dump an object
- RegEx operators and functions
- Cast binary to unsigned number

Generally, anything that cannot be written in atomlang will be placed in this package.

## Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in dotLang). Here is a list of some of classes in this package collection:

- I/O (Network, Console, File, ...)
- Thread and synchronization management
- Serialization/Deserialization
- Functional programming: map/reduce/filter
- String and Regex
- Collections (Stack, Queue, Linked List, ...)
- Encryption
- Math
- Bitwise operators (and, or, shift, xor, ...)
- Methods to help work with natively mutable data structures and algorithms (sort, tree, ...)
- ...

## Package Manager

The package manager is a separate utility which helps you package, publish, install and deploy packages (Like `maven` or `dub`).
Suppose someone downloads the source code for a project written in dotLang which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.

Perl has a `MakeFile.PL` where you specify metadata about your package, requirements + their version, test requirements and packaging options.
Python uses same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dep, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version metadata but no dep management. For dep it has NuGet.

## ToDo
- Add native concurrency and communication tools (green thread, channels, spinlock, STM, mutex) and async i/o, 
- Build, dependency management, versioning, packaging and distribution
- Plugin system to load/unload libraries at runtime without need to re-compile
- Debugger and plugins for Editors
- Testing and profiling features
- Distributed processing: Moving code to another machine and running there (Actor model + channel)
- Define notation to write low-level (Assembly or IR) code in a function body and also force inline.
- Add notation for axioms and related operators like `=>` to protocol structs to be able to define semantics of a protocol.
- Vet to format code based on the standard (indentation, spacing, brace placement, warning about namings, ...).
- Compiler will detect local variable updates which are not escape and optimize them to use mutable variable (for example for numerical calculations which happens only inside a function).
- Channels are the main tool for concurrency and coordination.
- Provide ability to update used libraries without need to re-compile main application.
- Parallel compilation
- Managing name conflict in large projects
- Add slice functions to core to return array as a pointer to another array
- Loop functions in core
- Decide if we can provide std as an external package rather than a built-in.
