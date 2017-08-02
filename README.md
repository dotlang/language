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
- **Version 0.98**: ?? ??? ???? - implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to `~`, re-write and clean this document with correct structure and organization, added `autoBind`, change notation for union to `|` and `()` for lambda, simplify primitive types, handle conditional and pattern matching using map and array, renamed tuple to struct, `()` notation to read from map and array, made `=` a statement, added `return` and `assert` statement, updated definition of chaining operator, everything is now immutable, Added concept of namespace which also replaces `autoBind`, functions are all lambdas defined using `let`, `=` for comparison and `:=` for binding, move `map` data type out of language specs, made `seq` the primitive data type instead of `array` and provide clearer syntax for defining `seq` and compound literals (for maps and other data types), review the manual, Added `while` keyword, removed `assert` keyword and replace with conditional return,

# Time table

Aug 4th - Close language manual (this document including example section, up to Other components section).
Aug 25th - Write proposal for Apache incubator
Aug 31st - Write compiler skeleton which compiles most basic app

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

# Language in a nutshell

## Main features

01. **Import a module**: `import /core/std/queue` (you can also import from external sources like Github).
02. **Primitive types**: `int`, `float`, `char`, `seq`, `func`.
03. **Bindings**: `let my_var:int := 19` (type can be automatically inferred, everything is immutable).
04. **Sequence**: `let scores:seq[int] := [1,2,3,4]` (Similar to array).
05. **Named type**: `type MyInt := int` (Defines a new type with same binary representation as `int`).
06. **Struct type**: `type Point := {x: int, y:int, data: float}` (Like `struct` in C)
07. **Struct literal**: `let location := Point{x=10, y=20, data=1.19}`
08. **Composition**: `type Circle := {Shape, radius: float}` (`Circle` embeds fields of `Shape`)
09. **Generics**: `type Stack[T] := { data: array[T], info: int }` (Defines a blueprint to create new types)
10. **Union type**: `type Maybe[T] := T | nothing` (Can store either of possible types)
11. **Function**: `let calculate: func(int,string)->float := (x, y) -> float { return x/y  }`
12. **Loops**: `let countToTen := (x: int, _: int) -> x while (x:int|nothing) -> increaseUntil(x, 10)`

## Symbols

01. `~`  chain operator (To chain function calls)
02. `@`  type-id operator (Return unique identifier of types)
03. `|`  union data type (Define different possible types)
04. `_`  placeholder (lambda creator, unknown variable in assignments or function argument)
05. `:`  type declaration for struct and function input and values, custom literals, type alias
06. `:=` Binding declaration, named types
07. `..` range generator
08. `->` function declaration, module alias
09. `[]` generics, literals
10. `{}` code block, struct definition and struct literal, casting
11. `()` function declaration and call
12. `.`  access struct fields
13. `::` address inside a module alias

## Reserved identifiers

**Keywords**: 

1. `import`: Used to import types and bindings from another modules.
2. `type`: Used to specify a name for a type.
3. `let`: Used to define a binding (Assigning a typed-value to a name).
4. `return`: Used to specify return value of a function.
5. `while`: Loops.

**Primitive data types**: `int`, `float`, `char`, `seq`, `func`

**Extended primitive types**: `nothing`, `bool`, `string`

**Other reserved identifiers**: `true`, `false`

**Compound types**: Struct and Union

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
- **Encapsulation**: If name (of a type or binding) starts with underscore, means that it is private to the module. If not, it is public and can be used from outside using `import` statement.
- **Naming**: (Highly advised but not mandatory) `someFunctionName`, `my_binding_name`, `func_arg_name`, `SomeDataType`, `my_package_dir`, `my_modue_file`. If these are not met, compiler will give warnings. Primitive data types and basic types defined in core (`bool`, `string` and `nothing`) are the only exceptions to naming rules.
- **Spacing**: There must be a single space between `import`, `let` and `type` keywords with their argument that comes after them.

# import keyword

**Syntax**

1. `import /path/to/module`
2. `import /path/to/module -> Name`

**Notes**

1. This keyword is used to import definitions from another module into current module's namespace. After importing a module, you can use it's types, call it's functions or work with the bindings that are defined in that module.
2. You can import a module into a named namespace. If you do this, you can only access it's definitions by prefixing namespace name (`namespace::definition`) (Example 2)
3. Note that elements that start with underscore are considered private and will not be available when you import their module.
4. Any definition using `type` or `let` keywords at module-level, adds to the default namespace. This is what will be imported when you import the module.
5. `/` in the beginning is shortcut for `file/`. Namespace path starts with protocl which determines the location for file for namespace. You can also use other namespace protocols like `Github` (`import git/path/to/module`).
6. You can import multiple modules with same package using notation in Example 3.
7. If an import path starts with `./` or `../` means the module path is relative to the current module.
8. It is an error if as a result of imports, there are two exactly similar bindings (same name and type). In this case, none of conflicting bindings will be available for use.

**Examples**

1. `import /core/st/Socket` 
2. Import another module under a new namespace: `import /core/st/Socket -> mod1` 
3. Import multiple modules: `import /core/std/{Queue, Stack, Heap}`
4. `import git/github.com/adsad/dsada`
5. `import svn/bitcucket.com/adsad/dsada`
6. Import and rename multiple modules: `import /core/std/{Queue, Stack, Heap} -> A,B,C`
7. Assign a binding to a definition inside another namespace: `let createSocket := mod1::createSocket`
8. `type socketType := mod1::SocketType`

# Bindings (`let` keyword)

**Syntax**: 

1. `let identifier := definition`
2. `let identifier : type := definition`

**Notes**

1. `let` keyword is used to assign a unique name to a definition or value. By default type of the name (or binding) is inferred from the value but you can also explicitly specify the type.
2. Note that the result of `let` is an immutable value. So you cannot re-assign it.
3. The type of the rvalue (What comes on the right side of `:=`), can be any possible data type including function. Refer to following sections for explanation of different available data types.
4. If the rvalue is a struct (Refer to corresponding section for more info about struct), You can destruct it to it's elements using this keyword (Example 3 and 5).

**Examples**

1. `let x: int := 12`
2. `let g := 19.8`
3. `let a,b := process()`
4. `let x := y`
5. `let a,b := {1, 100}`

# Primitive data types

## Simple types

**Syntax**: `int`, `float`, `char`, `seq`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. Primitive data types include simple types and compound types (array, struct and union).
7. `seq` type represents a block of memory space with elements of the same type. You can use a sequence literal (Example 4) or a function from core to initialize these variables. This type can be used to represent an array or list or any other data structure.
8. You can use range generator operator `..` to create sequence literals (Example 5).
9. Any function call in the form of `variable(a,b,c)` will be converted to `get(variable, a, b, c)`. This can be used as a shortcut to read data from array or other data structures.
11. A sequence literal which contains other sequence literals, can either be parsed as is, or destruct inner sequences and create a larger sequence. (Example 6 and 7). In example 7, result is a seqence of integers `1, 2, 3, 4, 5, 6`.
12. Core provices functions to extract part of a sequence as another sequence (Like array slice).

**Examples**

1. `let x := 12`
2. `let x := 1.918`
3. `let x := 'c'`
4. `let x: seq[int] := [1,2,3,4]`
5. `let x := [1..10]`
6. `let x: seq[seq[int]] := [ [1,2], [3,4], [5,6] ]`
7. `let x: seq[int] := [ [1,2], [3,4], [5,6] ]`

## Compound types

### Union

**Syntax**: `type1 | type2 | IDENTIFIER1 | ...`

**Notes**

1. A primitive meta-type which can contain different types and identifiers.
2. You can use either types or identifiers for types of data a union can contain. If you use an identifier you must use a capital letter identifier and it's name should be unique.
3. Example 1 shows usage of union to define an enum type to represent days of week.
4. Example 2, defines a union with explicit type and changes it's value to other types in next two examples.
5. You can use the syntax in example 5 to cast a union to another type. Result will have two parts: data and a flag. If flag is set to false, the conversion is failed.
6. `int | flotOrString` will be simplified to `int | float | string`
7. Example 6 shows using `@` operator to get internal type of a union binding. This operator also can be applied on an actual type.
8. If all union cases are function pointers, you can treat it like a function, but must pass appropriate input (Example 7)

**Examples**

1. `type day_of_week := SAT | SUN | MON | TUE | WED | THU | FRI`
2. `let int_or_float: int | float = 11`
3. `let int_or_float := 12.91`
4. `let int_or_float := 100`
5. `int_value, done := int{my_union}`
6. `let has_int := (@my_int_or_float == @int)`
7. `let fn: func(int)->int|func(string)->int|func(float)->int := ...`
A union of type function pointer with three possible function types.
8. `let data: int|float|string := ...`, `let o := fn(data)`
You can call `fn` like a normal function with an input which should be any of possible input types 

### Struct

**Syntax**: 

1. Declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. Typed Literal: `Type{field1:=value1, field2:=value2, field3:=value3, ...}` 
3. Typed Literal: `Type{value1, value2, value3, ...}` 
4. Untyped literal: `{value1, value2, value3, ...}` 
5. Update: `original_var{field1=value1, field2=value2, ...}` 

**Notes**

1. Struct represents a set of related data items of different types.
1. Example 1 defines a named type for a 2-D point and next 2 examples show how to initialise variables of that type. See "Named Types" section for more info about named types.
2. If you define an untyped literal (Example 4), you can access it's component by destruction (Example 6).
3. Examples 6 and 7 show how to destruct a struct and extract it's data.
4. Example 8 and 9 are the same and show how to define a struct based on another struct.
5. Example 10 indicates you cannot choose field names for an untyped struct literal.
6. You can use `.0,.1,.2,...` notaion to access fields inside an untyped tuple (Example 11).

**Examples**

1. `type Point := {x:int, y:int}`
2. `let point2 := Point{x:=100, y:=200}`
3. `let point3 := Point{100, 200}`
4. `let point1 := {100, 200}`
5. `let point4 := point3{y:=101}`
6. `let x,y := point1`
7. `let x,y := {100,200}`
8. `let another_point := Point{x:=11, y:=my_point.y + 200}`
9. `let another_point := my_point`
10. `let new_point := {a=100, b=200} //WRONG!`
11. `let x := point1.1`

### Composition

**Syntax**: `{Parent1Type, field1: type1, Parent2Type, field2: type2, Parent2Type, ...}`

**Notes**

1. Composition is used to include (or embed) a struct in another struct. This can be used to represent "is-a" or "has-a" relationship. 
2. A struct can embed as many other structs as it wants.
3. The language provides pure "contain and delegate" mechanism as a limited form of polymorphism.
4. In Example 2, `Shape` is the contained type and `Circle` is container type.
5. To have polymorphism in function calls, you should forward function calls to embedded structs (Calls on a `Circle` should be forwarded to calls on it's `Shape`). Refer to function section for more information about forwarding functions.
6. You can define a union type which accepts all struct types which embed a specific struct type. See examples 4 and 5.
7. Note that polymorphism does not apply to generics. So `seq[Circle]` cannot substitute `seq[Shape]`. But you can have `seq[Circle|Square]` to have a mixed sequence of different types.
8. We use closed recursion to forward function calls. This means if a function call is forwarded from `Circle` to `Shape` and inside that function, a second function is called which has candidates for both `Circle` and `Shape` the one for `Shape` will be called.
9. `|{T}|` where T is a named type can be used to indicate all structs that embed that type (Example 4).

**Examples**

1. `type Shape := { id:int }`
2. `type Circle := { Shape, radius: float}`
3. `let my_circle := Circle{id=100, radius=1.45}`
4. `type AllShapes := |{Shape}|`
5. `let someShapes:AllShapes := [myCircle, mySquare, myRectangle, myTriangle]`

# Extended primitive types

**Syntax**: `nothing`, `bool`, `string`

**Notes**

1. These types are not built-in types and are defined using other types, but due to their important role, they are defined in the core.
2. `string` is defined as a sequence of `char` data type, represented as `seq[char]` type. The conversion from/to string literals is handled by the compiler.
3. String literals should be enclosed in double quotes. 
4. String litearls enclosed in backtick can be multi-line and escape character `\` will not be processed in them.
5. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.
6. `bool` type is a union of two special identifiers: `true` and `false`.

**Examples**

1. `let g: bool := true`
2. `let str: string := "Hello world!"`

# Type system

## Type alias

**Syntax**: `type NewName : ExistingTypeName`

**Notes**

1. This is used to define alternative names for the same type.
2. The alias type is exactly same as the existing type (Unlike named type declaration which creates a new type).
3. This can be used in refactoring process or when there is a name conflict between types imported from different modules. See `import` section for more information.

**Examples**

1. `type MyInt : int`

## Named type

**Syntax**: `type NewType := UnderlyingType`


**Notes**

1. To introduce new types based on existing types (called underlying type). The new type has same binary representation as the underlying type but it will be treated like a different type.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. Although their binary data representations are the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to corresponding section for more information.
4. You can use casting operator to convert between a named type and it's underlying type (Example 5).

**Examples**

1. `type MyInt := int`
2. `type IntArray := seq[int]`
3. `type Point := {x: int, y: int}`
4. `type bool := true | false`
5. `let x: MyInt = 10`, `let y: MyInt = MyInt{10}`

## Casting

**Syntax**: `TargetType{identifier}`

**Notes**

1. There is no implicit and automatic casting in the language. The only case is for `true` to be 1 and `false` to be 0 when used as a sequence index.
2. Casting is mostly used to cast between a union and it's internal type (Example 2) or between named and equal unnamed type (Example 4 and 5). 
3. If function expects a named type, you cannot pass an equivalent unnamed type. 
4. Similarly, when a function expects an unnamed type, you cannot pass a named type with same underlying type. 
5. Another usage of casting is to cast between primitives: `int` and `float` and `char` (Example 1).
6. When casting for union types, you get two outputs: Target type and a boolean flag indicating whether cast was successful (Example 2).
7. For literals, casting between named and underlying type can be done automatically (Example 4).

**Examples**

1. `let x:int = int{1.91}`
2. `let int_value, has_int := int{int_or_float}`
3. `type MyInt := int`
4. `let x:MyInt = 100`
5. `let y:int = x`

# Generics

**Syntax**: 

1. `let funcName[T1, T2, T3, ...] := (input1: type1, input2: T1, input3: T3, ...)->T2`
2. `type TypeName[T1, T2, T3, ...] := { field1: int, field2: T2, field3: float, ...}`

**Notes**:

1. To define a function or data type which has one or more types defined like variables. These types will get their values when the function is called or the data type is used to initialize a value.
2. Compiler will scan body of generic functions and extract their expected methods. If you invoke those functions with inappropriate types, it will give you list of required methods to implement. So if `process[T]` function calls `save[T]` and you call `process[int]` there must be a definition for `save[int]`, or else compiler will issue error.
3. When calling a generic function, you can include type specifier if it cannot be deduced from input or for purpose of documenting the code (Example 14 includes type to document that `yy` will be of type `string`).
4. You can specialize generic functions for a specific type or types (Example 9 specializes function defined in example 5).

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

## Phantom types

**Notes**

1. Phantom types are used to document compile time constrcints on the data without runtime cost using generics or named types (When generic type is not used on the right side of type definition, it will be only for compile time check)
1. Phantom are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. 
2. You can implement these labels using a named type or a generic type.
3. Examples 1 to 7 show a et of hash functions that returns a specific type which is derived from `string`. This will prevent the developer sending a md-5 hash to a function which expects sha-1 hash (Example 7 will give compiler error).
4. Examples 8 to 10 indicate using named functions to represent a "sanitized string" data type. Using this named type as the input for `work` function will prevent calling it with normal strings which are not sanitized through `processString` function.
5. Examples 11 to 14 indicate a door data type which can only be opened if it is already closed properly and vice versa.

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

# Functions

**Syntax**: 
`let functionName: func(type1, type2, type3, ...) -> OutputType := (name1: type1, name2: type2...) -> OutputType { code block }`

**Notes**

1. Functions are a specific type of binding which can accept a set of inputs and give an output.
2. Lambda or a function pointer is defined similar to a normal function in a module. They use the same syntax.
3. When defining a function, just like a normal binding, you can omit type which will be inferred from rvalue (Function literal).
4. Note that `func(int,int)->int` is a function type, but `(x:int, y:int)->{x+y}` is function literal.
5. You cannot define types inside a function (with `type` keywords). All types must be defined at module level.
6. As a syntax sugar, `var(1,2,3)` will be converted to `get(var, 1, 2, 3)` function call.
7. Every function must return something which is specified using `return`. If it doesn't, compiler marks output type as `nothing` (Example 2).
8. A function call with union data, means there must be functions defined for all possible types in the union. See Call resolution section for more information.
9. You can omit braces and `return` keyword if you only want to return an expression (Examples 4, 5 and 6).
10. The function in example 7 will be invoked if the input is either `int` or `Point` or `int|Point`.
11. There should not be ambiguity when calling a function. So having functions on examples 9 and 3 in same compilation is invalid.
12. You can use `_` as the name of function input to state you don't need it's value (Example 9).
13. You can use `_` to ignore a function output (Example 10).
14. Parentheses are required when calling a function, even if there is no input.
15. You can prefix `return` with a conditional in which case, return will be triggered only if consition is satisfied (Example 11).

**Examples**

01. `let myFunc:(int, int) -> int := func(x:int, y:int)-> int { return 6+y+x }`
02. `let log := (s: string) -> { print(s) }`
03. `let process := (pt: Point)->int pt.x`
04. `let process2 := (pt: Point) -> {pt.x, pt.y}`
05. `let my_func := (x:int) -> x+9`
06. `let myFunc9 := (x:int) -> {int} {12}`
07. `let process := (x: int|Point])->int`
08. `let fileOpen := (path: string) -> File {...}`
09. `let process := (_:int) -> 10`
10. `_,b = process2(myPoint)`
11. `let process := (x:int) -> { x<0 return 100, return 200}` 

## Call forwarding

**Syntax**: `func funcName(type1->type2, type3, type4->type5, ...)`

**Notes**

1. To forward a function call to another function, used to implement subtyping.
1. Example 1, indicates any call to function `draw` with a parameter of type `Circle` must be sent to a function with the same name and `Shape` input. In this process, the argument will be converted to a `Shape`.
2. Example 2, will forward any call to function `process` with first input of type `Polygon`, `Square` or `Circle` and second argument of `GradientColor` or `SolidColor` to the same name function with inputs `Shape` and `Color` type. All other inputs which are not forwarded are the same between original and forwarded function. This definition is for 6 functions and forwarding all of them to a single function.
3. Example 3, is like example 2 but uses a generic union to indicate all types that embed a Shape.
4. Note that left side of `->` must embed the type on the right side.

**Examples**

1. `let draw := (Circle->Shape)`
2. `let process := (Polygon|Square|Circle->Shape, GradientColor|SolidColor]->Color)`
3. `let process := (float, |{Shape}|->Shape, string, int, GradientColor|SolidColor->Color, int)`

## Function pointer

**Syntax**: `type Fp := func(type1, type2, ...)->OutputType`

1. A special data type which can hold a reference to a function.
2. Example 4 indicates a function which accepts a function pointer.
3. Example 5 indicates the definition for a mapping function. It is using generics features introduces in the corresponding section.
4. Value of a function pointer can be either an existing function or a lambda. 

**Examples**

1. `type adder := func(int,int)->int`
2. `let myAdder := (x:int, y:int) -> x+y`
3. `let adderPointer := adder{myAdder}`
4. `let sort := (x: array[int], comparer: func(int,int) -> bool) -> array[int]`
5. `let map[T, S] := (input: array[T], mapper: func(T) -> S) -> array[S]`

## Lambda

**Syntax**: `(name1: type1, name2: type2, ...) -> output_type { body }`


1. Lambda or function literal is used to define body of a function.
2. You can omit output type (Example 2 and 3).
3. Even if lambda has no input you must include `()` (Example 4).
4. Lambdas are closures and can capture variables (as read-only) in the parent function (Example 4 and 5).
4. Example 5 shows a function that returns a lambda.
5. Example 6 shows invoking a lambda at the point of definition.
6. You can use `_` to define a lambda based on an existing function or another lambda or function pointer value. Just make a normall call and replace the lambda inputs with `_`. Example 8 defines a lambda to call `process` functions with `x=10` but `y` and `z` will be inputs.
7. If lambda is assigned to a variable, you can invoke itself from inside (Example 9).

**Examples**

1. `let f1 := (x: int, y:int) -> int { x+y }`
2. `let f1 := (x: int, y:int) -> { x+y }` 
3. `let rr := (x: int, y:int) -> x + y`  
4. `let rr := () -> { return x + y }`
5. `let test := (x:int) -> plusFunc { |y:int| -> y + x }`
6. `(x:int)->int { x+1 } (10)`
7. `let process := (x:int, y:float, z: string) -> { ... }`
8. `letlambda1 := process(10, _, _)`
9. `let ff := (x:int) -> { ff(x+1) }`

## Chain operator

**Syntax**: 

1. `input ~ func(_,_,_,...)`
2. `input ~ {_,_,_,...}`
3. `input ~ var(_)`

**Notes**

1. To put arguments before function or struct.
2. You can treat `var(x,y,z)` shortcut like a function call and use it in chain operator. It will be converted to appropriate `get` function.
3.  `X ~ F(_)` will be translated to `F(X)` unless `F` cannot accept input of type `x`, in which case it will be evaluated to `X`. Note that `X` can be a single value or a struct.
4. right side of `~` must be either a function with expected inputs or a struct with underscores for substitition or a variable with appropriate `_` for placeholders.
5. If right-side expects a single input but left side is a struct with multiple items, it will be treated as a struct for the single input of the function (Example 4) but if function expects multiple inputs they will be extracted from left side (Example 3). 
6. You can also pass a single argument to right side of the chain by using non-struct value. If you pass a struct with single item to a function (Example 11) and there are two candidates for that call (one that accepts `int` and other accepts `{int}`) compiler will give error.
7. You can use chain operator with custom functions as a monadic processing operator. For example you can streamline calling mutiple error-prone functions without checking for error on each call (Example 6 and 7).

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
11. `{1} ~ process(_)`, `1 ~ process(_)`

# `while` keyword

**Syntax**: `let A := body(i, o) while pred(i)`

**Notes**

1. This is used to evaluate a lambda (body) until another lambda (pred) returns `nothing`, at which point, the last result of invoking `body` will be returned as the result of loop execution.
2. Simple workflow of loops:
  a. `O := nothing` (current loop result)
  b. `I := nothing` (current iterator value)
  c. `I := pred(I)`
  d. if `I` is nothing, return `O` as the output and finish the loop
  e. `O := body(I, O)`
  f. goto step 3
3. Example 1 creates a linked list starting from 0 up to `n` argument and stores it in `result` binding.

**Examples**

1. 
```
let n := 100
//I want result to be 0->1->2->...->99 as a linked list
let result := (x:int, lst: List[int]|nothing) -> 
{ 
  let newList := append(lst, x)
  return newList
} 
while (x:int|nothing) -> 
{ 
  x=nothing return 0
  x<n return nothing
  return int{x}.0+1 
}
```

# Operators

## Basic operators

**Syntax**:

1. Conditional operators: `and, or, not, =, !=, >=, <=`
2. Arithmetic: `+, -, *, /, %, %%, +=, -=, *=, /=`
3. Assignment: `=`
4. Type-id: `@`
5. Casting `{}`
6. Chain `~`
7. Compound literal `[:]`

**Notes**

1. All non-alpabetical notations operators used in the language. The meaning for most of them is like C-based languages except for `=` which is used to check for equality.
2. `:=` operator is used to define a named type or a binding.
3. `=` will do comparison on a binary-level. 
4. Operators for bitwise operations and exponentiation are defined as functions in core.
5. `@`: returns type-id of a named or primitive type as an integer number, or a union variable (Example 1).
6. `{}`: To cast from named to unnamed type you can use: `Type{value}` notation (Example 2).
7. `{}`: To cast from variable to a union-type (Example 3).
8. You can use compound literal to define a literal which is calculated by calling appropriate `set` functions. These literals have the form of `[a:b:c d:e:f ...]`. In this example the literal has a set of elements each of which has 3 items. This means that to calculate the value of the literal, compild will render `let x0 := set(nothing, a, b, c)`, then `let x1 := set(x0, d, e, f)` and continue until end of values. The final result will be the output value. This notation can be used to have map literals and other custom literals.

**Examples**

01. `let g = @int`, `g = @my_union`
02. `type MyInt := int`, `let x: MyInt = 12`
03. `let y:int = int{x}`
04. `let y: int|float = 12`

# Other Features

## Conditionals and pattern matching

**Notes**

1. You can use sequence literals to implement conditionals and pattern matching. This is also possible by using lambdas and conditional `return`.
2. Example 1 shows a simple case of implementing pattern matching.
3. You can also use sequence for conditionals. `true` will be mapped to index `1` and `false` to index `0`.
4. Example 2 shows equivalent of `x = if a>0 then 200 else 100` pseudo-code.

**Examples**

1.
```
let v: int|float|string = processData()
//check: if predicate is satisfied, return lambda result, else nothing
let x: int|nothing := check[int](@v=@int, ()->100)
let y: int|nothing := ...
let z: int|nothing := ...
//merge takes multiple T|nothing values and returns the only non-nothing one.
let result : int := merge(x,y,z)
//or: combine them together
let result : int := merge(check[int](@v=@int, ()->100), check[int](@v=@string, ()->200), check[int](true, ()->300))
```

2.
```
let x:int := [100,200](a>0)
```

## dispose

**Syntax**: `dispose(x)`

**Notes**

1. This function is used to invalidate a binding and release any memory or resources associated with it.
2. You cannot use a variable after calling dispose on it. 
3. You can call dispose on any variable.
4. Dispose function will properly handle any resource release like closing file or socket or ... .

## Exclusive resources

**Syntax**: Exclusive resources are defined in core (file descriptor, thread, sockets) and contain an identifier to indicate their owner thread.

**Notes**

1. These represent a system resource (file, network socket, database connection, ...) which needs to have an exclusive owner thread.
2. These types are not supposed to be shared between two threads, because of their inherent mutability. If this happens, runtime will throw error. They all contain an owner thread identifier which is checked by core functions.
3. If you are not returning an exclusive resource created in the current function, you must explicitly call `dispose` on it. Else compiler will issue error.

## Exception handling

**Syntax**: `func process() -> int|exception { ... return exception{...} }`

**Notes**

1. There is no explicit support for exceptions. You can return a specific `exception` type instead.
2. You can use chaining operator to streamling calling multiple functions without checking for exception output each time.
3. If a really unrecoverable error happens, you should exit the application by calling `exit` function in core.
4. In special cases like a plugin system, where you must control exceptions, you can use core function `invoke` which will return an error result if the function which it calls exits.

**Examples**

1. `result: int|exception = invoke(my_function)`

## autoBind

**Syntax**: `x = StructType{Alias}`, `x = StructType{::}`

**Notes**

1. There is a special usage for casting operator, when you cast a namespace (`::` or namespace alias) to a struct. This will map bindings with similar names to fields inside the struct.
1. Example 1 defines a general struct which contains a function pointer field.
2. Example 2 defines a function to sort any given array of any type. But to do the sort, it needs a function to compare data of that type. So it defines an input of type `Comparer[T]` to include a function to do the comparison.
3. Example 3 shows how to call `sort` function defined in example 2. You simply cast current namespace to `Comparer` to create appropriate struct of appropriate function pointers by the compiler. So `f.compare` field will contain a function pointer to a function with the same name and signature defined in the current namespace.
4. Example 4 is same as example 3 but with explicit types. You can omit these types as compiler will infer them.
5. This mechanism can be used to define expected protocol (a set of functions and data) as a function input.

**Examples**

1. `type Comparer[T] := { compare: func(T,T)->bool }`
2. `func sort[T](x: array[T], f: Comparer[T])->array[T] { ... }`
3. `sort(myIntArray, Comparer{::})`
4. `sort(myIntArray, Comparer[int]{::})`

# Examples

## Empty application

```
let main := () -> 0
```

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

## Core packages

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
- Add map and array data type to Std
- Loop functions in std using recursion and iterators
- Decide if we can provide std as an external package rather than a built-in.
- Std: Functions to call a union which has a set of function pointers by accepting all possible inputs.
`let fn: func(int)->int|func(string)->int|func(float)->int := ...`
`let o := invoke(fn, int_var, string_var, float_var)`
