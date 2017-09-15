# dot Programming Language (dotLang)

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 0.98

August 7, 2017

# Table of Contents

1. [Introduction] (https://github.com/dotlang/language/blob/master/README.md#introduction)
2. [Comparison] (https://github.com/dotlang/language/blob/master/README.md#comparison-with-other-languages)
3. [Components] (https://github.com/dotlang/language/blob/master/README.md#components)
4. [Code organization] (https://github.com/dotlang/language/blob/master/README.md#code-organization)
5. 

# Introduction

After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: **dotLang**.

dot programming language (or dotLang for short) is an imperative, safe static-typed, functional, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Erlang, Elm, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance, and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from the functional approach.

Two main objectives are pursued in the design and implementation of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few things are done implicitly and transparently by the compiler or runtime system. Also, I tried to reduce the need for nested blocks and parentheses as much as possible. Another aspect of simplicity is minimalism in the language. It has very few keywords and rules to remember.
2. **Performance**: The source will be compiled to native code which will result in higher performance compared to interpreted languages. The compiler tries to do as much as possible (optimizations, dereferencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, disposing, ...) so during runtime, there is not much to be done except mostly for memory management. Where performance is a concern, the corresponding functions in core library will be implemented in a lower level language.

Achieving both of the above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, the code is written in files (called modules) organized in directories (called packages).  We have bindings (first-class functions and values) and types (Blueprints to create bindings). Each function acts on a set of inputs and returns an output. Type system includes primitive data types (`int`, `float`, `char`, `function` and `sequence`), struct and union. Polymorphism, generics and lambda expression are also provided and everything is immutable.

## Comparison with other languages

**Compared to C**: C language + Garbage collector + first-class functions + template programming + better union data types + module system + flexible polymorphism + simple and powerful standard library + lambda expressions + closure + simpler primitives + multiple dispatch + sane defaults + full immutability - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + full immutability + simpler primitives - *dependency on JVM* - cryptic syntax - trait - custom operators - variance - implicit parameters.

**Compared to Go**: Go + *generics* + full immutability + multiple dispatch + union types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives - pointers - interfaces - global variables.

## Components

dotLang consists of these components:

1. The language manual (this document).
2. A command line tool to compile, debug and package source code.
3. Runtime system: Responsible for memory allocation and management, interaction with the Operating System and other external libraries and handling concurrency.
4. Core library: This package is used to implement some basic, low-level features which can not be simply implemented using pure dotLang.
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
03. **Bindings**: `my_var:int := 19` (type can be automatically inferred, everything is immutable).
04. **Sequence**: `scores:seq[int] := [1 2 3 4]` (Similar to array).
05. **Named type**: `MyInt := int` (Defines a new type with same binary representation as `int`).
06. **Struct type**: `Point := {x: int, y:int, data: float}` (Like `struct` in C)
07. **Struct literal**: `location := Point{x:10, y:20, data:1.19}`
08. **Composition**: `Circle := {Shape, radius: float}` (`Circle` embeds fields of `Shape`)
09. **Generics**: `Stack[T] := { data: array[T], info: int }` (Defines a blueprint to create new types)
10. **Union type**: `Maybe[T] := T | nothing` (Can store either of possible types)
11. **Function**: `calculate: func(int,int)->float := (x, y) -> float { return x/y  }`

## Symbols

01. `#`   Comment
02. `.`   Access struct fields
03. `()`  Function declaration and call, condition for return
04. `{}`  Code block, struct definition and struct literal
05. `[]`  Generics, literals (for sequence and custom literals)
06. `|`   Union data type (Define different possible types)
07. `->`  Function declaration, module alias
08. `..`  Range generator for sequence literal
09. `::`  Address inside a module alias
10. `//`  Nothing-check operator
11. `$`   Prefix for struct literals
12. `:`   Type declaration for struct, function inputs and bindings, struct literals
13. `:=`  Binding declaration, named types
14. `:==` Parallel execution
15. `@`   Get internal type of union 
16. `~`   Chain operator (To chain function calls)
17. `_`   Place holder (lambda creator, place-holder in assignments)
18. `.{}` Casting
19. `.()` Optional call (call if it is a function pointer, do nothing otherwise)
20. `.[]` Custom process
21. `^`   Generic union (Union of a group of types)

## Reserved identifiers

**Keywords**: 

1. `import`: Used to import types and bindings from other modules.
2. `return`: Used to specify result of a function.

**Primitive data types**: `int`, `float`, `char`, `seq`, `func`

**Extended primitive types**: `nothing`, `bool`, `string`

**Other reserved identifiers**: `true`, `false`

**Compound types**: Struct and Union

## Coding style

These rules are highly advised but not mandatory.

1. Indentation must be done using spaces, not tabs. Using 4 spaces is advised but not mandatory.
2. It is advised to put each statement on a separate line. 
3. `import` statements must come first, then type definitions, then bindings.
4. Naming: `someFunctionName`, `my_binding_name`, `func_arg_name`, `SomeDataType`, `my_package_dir`, `my_modue_file`.
5. Braces should appear on their own line except when the whole expression is one-line.

# import keyword

**Syntax**

1. `import /path/to/module`
2. `import /path/to/module -> Name`

**Notes**

1. This keyword is used to import definitions from another module into current module's namespace. After importing a module, you can use its types, call its functions or work with the bindings that are defined in that module.
2. You can import a module into a named namespace. If you do this, you can only access its definitions by prefixing namespace name (`namespace::definition`) (Example 2)
3. Note that definitions that start with an underscore are considered private and will not be available when you import their module.
4. Any binding definition at module-level, is added to the default namespace. This is what will be imported when you import the module.
5. `/` in the beginning is a shortcut for `file/`. Namespace path starts with a protocol which determines the location of the file for a namespace. You can also use other namespace protocols like `Github` (`import git/path/to/module`).
6. You can import multiple modules with the same package using notation in Example 3.
7. If an import path starts with `./` or `../` means the module path is relative to the current module.
8. It is an error if as a result of imports, there are two exactly similar bindings (same name and type) in use. In this case, none of conflicting bindings will be available for use.

**Examples**

1. `import /core/st/Socket` 
2. Import another module under a new namespace alias: `import /core/std/Socket -> mod1` 
3. Import multiple modules: `import /core/std/{Queue, Stack, Heap}`
4. `import git/github.com/net/server`
5. `import svn/bitbucket.com/net/server`
6. Import and rename multiple modules: `import /core/std/{Queue, Stack, Heap} -> A, B, C`
7. Assign a binding to a definition inside another namespace: `createSocket := mod1::createSocket`
8. `SocketType := mod1::SocketType`

# Bindings

**Syntax**: 

1. `identifier := definition`
2. `identifier : type := definition`

**Notes**

1. By default, type of the binding is inferred from the value but you can also explicitly specify the type.
2. Note that bindings are immutable, so you cannot re-assign them.
3. The type of the rvalue (What comes on the right side of `:=`), can be any possible data type including function. Refer to following sections for an explanation of different available data types.
4. If the rvalue is a struct (Refer to the corresponding section for more info about struct), You can destruct it to its elements using this keyword (Example 3 and 5).
5. You can use place holder symbol `_` to denote you are not interested in a specific value (Example 6).
6. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
7. You can use `,` as digit separator in number literals.

**Examples**

1. `x: int := 12`
2. `g := 19.8`
3. `a,b := process()`
4. `x := y`
5. `a,b := ${1, 100}`
6. `a,_ := ${1, 100}`

# Primitive data types

## Simple types

**Syntax**: `int`, `float`, `char`, `seq`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. Primitive data types include simple types and compound types (array, struct, and union).
7. `seq` type represents a block of memory space with elements of the same type. You can use a sequence literal (Example 4) or a function from core to initialize these variables. This type can be used to represent an array or list or any other data structure.
8. You can use range generator operator `..` to create sequence literals (Example 5).
9. A sequence literal which contains other sequence literals, can either be parsed as is or destruct inner sequences and create a larger sequence. (Example 6 and 7). In example 7, the result is a sequence of integers `1, 2, 3, 4, 5, 6`.
10. Core provides functions to extract part of a sequence as another sequence (Like array slice).
11. Referring to an index outside sequence will cause a runtime error.(Example 8 for reading from a sequence).

**Examples**

1. `x := 12`
2. `x := 1.918`
3. `x := 'c'`
4. `x: seq[int] := [1 2 3 4]`
5. `x := [1..10]`
6. `x: seq[seq[int]] := [ [1 2] [3 4] [5 6] ]`
7. `x: seq[int] := [ [1 2] [3 4] [5 6] ]`
8. `n := x.[10]`

## Compound types

### Union

**Syntax**: `type1 | type2 | Identifier1 | ...`

**Notes**

1. A primitive meta-type which can contain different types and identifiers.
2. You can use either types or identifiers for types of data a union can contain. If you use an identifier, its name should be unique.
3. Example 1 shows usage of a union to define an enum type to represent days of a week.
4. Example 2, defines a union with explicit type and changes it's value to other types in next two examples.
5. You can use the syntax in example 5 to cast a union to another type. The result will have two parts: data and a flag. If the flag is set to false, the conversion is failed.
6. `int | flotOrString` will be simplified to `int | float | string`
7. Example 6 shows using `@` operator to get the internal type of a union binding. 
8. If all union cases are function pointers, you can treat it like a function but must pass appropriate input (Example 7)

**Examples**

1. `Day_of_week := SAT | SUN | MON | TUE | WED | THU | FRI`
2. `int_or_float: int | float := 11`
3. `int_or_float := 12.91`
4. `int_or_float := 100`
5. `int_value, done := int{my_union}`
6. `has_int := (@my_int_or_float = @[int])`
7. `fn: func(int)->int|func(string)->int|func(float)->int := ...`
A union of type function pointer with three possible function types.
8. `data: int|float|string := ...`, `o := fn(data)`
You can call `fn` like a normal function with an input which should be any of possible input types 

### Struct

**Syntax**: 

1. Declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. Typed Literal: `Type{field1:value1, field2:value2, field3:value3, ...}` 
3. Typed Literal: `Type{value1, value2, value3, ...}` 
4. Untyped literal: `${value1, value2, value3, ...}` 
5. Update: `original_var{field1:value1, field2:value2, ...}` 

**Notes**

1. Struct represents a set of related data items of different types.
1. Example 1 defines a named type for a 2-D point and next 2 examples show how to initialize variables of that type. See "Named Types" section for more info about named types.
2. If you define an untyped literal (Example 4), you can access its component by destruction (Example 6).
3. Examples 6 and 7 show how to destruct a struct and extract its data.
4. Example 8 and 9 are the same and show how to define a struct based on another struct.
5. Example 10 indicates you cannot choose field names for an untyped struct literal.
6. You can use `.0,.1,.2,...` notation to access fields inside an untyped tuple (Example 11).

**Examples**

1. `Point := {x:int, y:int}`
2. `point2 := Point{x:100, y:200}`
3. `point3 := Point{100, 200}`
4. `point1 := ${100, 200}`
5. `point4 := point3{y:101}`
6. `x,y := point1`
7. `x,y := ${100,200}`
8. `another_point := Point{x:11, y:my_point.y + 200}`
9. `another_point := my_point`
10. `new_point := ${a:100, b:200} //WRONG!`
11. `x := point1.1`

### Composition

**Syntax**: `{Parent1Type, field1: type1, Parent2Type, field2: type2, Parent2Type, ...}`

**Notes**

1. Composition is used to include (or embed) a struct in another struct. This can be used to represent "is-a" or "has-a" relationship. 
2. A struct can embed as many other structs as it wants.
3. The language provides pure "contain and delegate" mechanism as a limited form of polymorphism.
4. In Example 2, `Shape` is the contained type and `Circle` is container type.
5. To have polymorphism in function calls, you should forward function calls to embedded structs (Calls on a `Circle` should be forwarded to calls on its `Shape`). Refer to function section for more information about forwarding functions.
6. You can define a union type which accepts all struct types which embed a specific struct type. See examples 4 and 5.
7. Note that polymorphism does not apply to generics. So `seq[Circle]` cannot substitute `seq[Shape]`. But you can have `seq[Circle|Square]` to have a mixed sequence of different types.
8. We use closed recursion to forward function calls. This means if a function call is forwarded from `Circle` to `Shape` and inside that function, a second function is called which has candidates for both `Circle` and `Shape` the one for `Shape` will be called.
9. `^T` where T is a named type can be used to indicate all structs that embed that type (Example 4).

**Examples**

1. `Shape := { id:int }`
2. `Circle := { Shape, radius: float}`
3. `my_circle := Circle{id:100, radius:1.45}`
4. `AllShapes := ^Shape`
5. `someShapes:AllShapes := [myCircle, mySquare, myRectangle, myTriangle]`

# Extended primitive types

**Syntax**: `nothing`, `bool`, `string`

**Notes**

1. These types are not built-in types and are defined using other types, but due to their important role, they are defined in the core.
2. `string` is defined as a sequence of `char` data type, represented as `seq[char]` type. The conversion from/to string literals is handled by the compiler.
3. String literals should be enclosed in double quotes. 
4. String literals enclosed in backtick can be multiline and escape character `\` will not be processed in them.
5. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.
6. `bool` type is same as int and `true` is 1, `false` is 0.

**Examples**

1. `g: bool := true`
2. `str: string := "Hello world!"`

# Type system

Two types T1 and T2 are identical/assignable in any of below cases:
1. Both are named types defined in the same place in the code.
2. Both are unnamed types with similar definition (e.g. `int|string` vs `int|string` or `seq[int]` vs `seq[int]`).
2. T1 is named and T2 is identical to T1's underlying type, or vice versa.


## Named type

**Syntax**: `NewType := UnderlyingType`

**Notes**

1. To introduce new types based on existing types (called underlying type). The new type has same binary representation as the underlying type but it will be treated as a different type.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. Although their binary data representations are the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to the corresponding section for more information.
4. You can use casting operator to convert between a named type and its underlying type (Example 5).
5. You can define multiple named types in one type statement (Example 6).
6. If a function is called which has no candidate for the named type, the candidate for underlying type will be invoked.
7. Visually, the naming differentiates a named type from a binding (type names start with a capital letter).

**Examples**

1. `MyInt := int`
2. `IntArray := seq[int]`
3. `Point := {x: int, y: int}`
4. `bool := true | false`
5. `x: MyInt := 10`, `y: MyInt := MyInt{10}`
6. `Socket[Open], Socket[Closed] := { data: int }`

## Casting

**Syntax**: `TargetType{identifier}`

**Notes**

1. There is no implicit and automatic casting in the language. The only case is for `true` to be 1 and `false` to be 0 when used as a sequence index.
2. Casting is mostly used to cast between a union and its internal type (Example 2) or between named and equal unnamed type (Example 4 and 5). 
3. If a function expects a named type, you cannot pass an equivalent unnamed type. 
4. Similarly, when a function expects an unnamed type, you cannot pass a named type with same underlying type, unless there is no function with that name expecting the named type.
5. Another usage of casting is to cast between primitives: `int` and `float` and `char` (Example 1).
6. When casting for union types, you get two outputs: Target type and a boolean flag indicating whether cast was successful (Example 2).
7. For literals, casting between named and underlying type can be done automatically (Example 4).
8. If the target type is not a simple identifier, you should enclose it in parentheses (Example 6).
9. You can cast multiple items at once (Example 7).
10. The `Type.{}` notation gives you the default value for the given type (empty/zero value).

**Examples**

1. `x:int := int.{1.91}`
2. `int_value, has_int := int.{int_or_float}`
3. `MyInt := int`
4. `x:MyInt := 100`
5. `y:int := x`
6. `x := (func()->T).{t}`
7. `a, b, c := MyInt.{x,y,z}`

# Generics

**Syntax**: 

1. `funcName[T1, T2, T3, ...] := (input1: type1, input2: T1, input3: T3, ...)->T2`
2. `TypeName[T1, T2, T3, ...] := { field1: int, field2: T2, field3: float, ...}`

**Notes**:

1. To define a function or data type which has one or more types defined like variables. These types will get their values when the function is called or the data type is used to initialize a value.
2. The compiler will scan the body of generic functions and extract their expected methods. If you invoke those functions with inappropriate types, it will give you a list of required methods to implement. So if `process[T]` function calls `save[T]` and you call `process[int]` there must be a definition for `save[int]`, or else the compiler will issue an error.
3. When calling a generic function, you can include type specifier if it cannot be deduced from input or for purpose of documenting the code (Example 14 includes type to document that `yy` will be of type `string`).
4. You can specialize generic functions for a specific type or types (Example 9 specializes function defined in example 5).

**Example**

01. `Stack[T] := array[T]`
02. `Tree[T] := {x: T, left: Tree[T], right: Tree[T]}`
03. `optional[T] := nothing|T`
04. `BoxedValue[T] := {value:T}`
05. `push[T] := (s: Stack[T], data: T) ...`
06. `pop[T] := (s: Stack[T])->T...`
07. `length[T] := (s: Stack[T])->int`
08. `extract[T] := (that: BoxedValue[T])->T that.value`
09. `push[int] := (s: Stack[int], data:int)...`
10. `x := optional[int]{12}`
11. `x := BoxedValue[int]{1}`
12. `y := BoxedValue[string]{value: "a"}`
13. `xx := extract(x)`
14. `yy := extract[string](y)`

## Phantom types

**Notes**

1. Phantom types are used to document compile time constraints on the data without runtime cost using generics or named types (When generic type is not used on the right side of type definition, it will be only for compile time check)
1. Phantoms are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. 
2. You can implement these labels using a named type or a generic type.
3. Examples 1 to 7 shows a set of hash functions that returns a specific type which is derived from `string`. This will prevent the developer sending a md-5 hash to a function which expects sha-1 hash (Example 7 will give compiler error).
4. Examples 8 to 10 indicate using named functions to represent a "sanitized string" data type. Using this named type as the input for `work` function will prevent calling it with normal strings which are not sanitized through `processString` function.
5. Examples 11 to 14 indicate a door data type which can only be opened if it is already closed properly and vice versa.

**Examples**

1. `HashType := MD5|SHA1`
2. `HashStr[T] := string`
3. `Md5Hash := HashStr[MD5]` 
4. `Sha1Hash := HashStr[SHA1]`
5. `md5 := (s: string)->Md5Hash { ... }`
6. `sha1 := (s: string)->Sha1Hash { ... }`
7. `t := Md5Hash{sha1("A")} //ERROR!`
8. `SafeString := string`
9. `processString := (s: string)->SafeString`
10. `work := (s: SafeString)`
11. `DoorState := Open|Closed`
12. `Door[T] := string`
13. `closeDoor := (x: Door[Open]) -> Door[Closed]`
14. `openDoor := (x: Door[Closed]) -> Door[Open]`

# Functions

**Syntax**: 
`functionName: func(type1, type2, type3, ...) -> (OutputType) := (name1: type1, name2: type2...) -> OutputType { code block }`

**Notes**

1. Functions are a specific type of binding which can accept a set of inputs and give an output.
2. Lambda or a function pointer is defined similarly to a normal function in a module. They use the same syntax.
3. When defining a function, just like a normal binding, you can omit type which will be inferred from rvalue (Function literal).
4. Note that `func(int,int)->int` is a function type, but `(x:int, y:int)->{x+y}` is function literal.
5. You can define types inside a function. These types will only be available inside the function.
6. As a syntax sugar, `var.[1,2,3]` will be converted to `process(var, 1, 2, 3)` function call.
7. Every function must return something which is specified using `return`. If it doesn't, compiler marks output type as `nothing` (Example 2).
8. A function call with union data means there must be functions defined for all possible types in the union. See Call resolution section for more information.
9. You can omit braces and `return` keyword if you only want to return an expression (Examples 4, 5 and 6).
10. The function in example 7 will be invoked if the input is either `int` or `Point` or `int|Point`.
11. There should not be ambiguity when calling a function. So having functions in examples 9 and 3 in the same compilation is invalid.
12. You can use `_` to ignore a function output (Example 9).
13. Parentheses are required when calling a function, even if there is no input.
14. You can prefix `return` with a conditional, enclosed in parentheses. Return will be triggered only if the condition is satisfied (Example 10).
15. If function output is a single identifier, you can omit parentheses in output type, otherwise they are mandatory (Example 11).

**Examples**

01. `myFunc:(int, int) -> int := func(x:int, y:int)-> int { return 6+y+x }`
02. `log := (s: string) -> { print(s) }`
03. `process := (pt: Point)->int pt.x`
04. `process2 := (pt: Point) -> {pt.x, pt.y}`
05. `my_func := (x:int) -> x+9`
06. `myFunc9 := (x:int) -> {int} {12}`
07. `process := (x: int|Point])->int`
08. `fileOpen := (path: string) -> File {...}`
09. `_,b := process2(myPoint)`
10. 
```
process := (x:int) -> 
{ 
  (x<0) return 100
  return 200
}
``` 
11. `T1 := func(int)->(int|string)`

## Call forwarding

**Syntax**: `funcName := (type1->type2, type3, type4->type5, ...)`

**Notes**

1. To forward a function call to another function with the same name used to implement subtyping (This notation provides a syntax sugar).
2. Example 1, indicates any call to function `draw` with a parameter of type `Circle` must be sent to a function with the same name and `Shape` input. In this process, the argument will be converted to a `Shape` (Example 4 represents equivalent definition without using call forwarding notations).
3. Example 2, will forward any call to function `process` with the first input of type `Polygon`, `Square` or `Circle` and second argument of `GradientColor` or `SolidColor` to the same name function with inputs `Shape` and `Color` type. All other inputs which are not forwarded are the same between original and forwarding function. This definition is for 6 functions and forwarding all of them to a single function.
4. Example 3, is like example 2 but uses a generic union to indicate all types that embed a Shape.
5. Note that left side of `->` must embed the type on the right side.

**Examples**

1. `draw := (Circle->Shape)`
2. `process := (Polygon|Square|Circle->Shape, GradientColor|SolidColor]->Color)`
3. `process := (float, ^Shape->Shape, string, int, GradientColor|SolidColor->Color, int)`
4. `draw: func(Circle) := (c: Circle) -> draw(c.Shape)`

## Function pointer

**Syntax**: `Fp := func(type1, type2, ...)->OutputType`

1. A special data type which can hold a reference to a function.
2. Example 4 indicates a function which accepts a function pointer.
3. Example 5 indicates the definition for a mapping function. It is using generics features introduces in the corresponding section.
4. The value of a function pointer can be either an existing function or a lambda. 

**Examples**

1. `adder := func(int,int)->int`
2. `myAdder := (x:int, y:int) -> x+y`
3. `adderPointer := adder{myAdder}`
4. `sort := (x: array[int], comparer: func(int,int) -> bool) -> array[int]`
5. `map[T, S] := (input: array[T], mapper: func(T) -> S) -> array[S]`

## Lambda

**Syntax**: `(name1: type1, name2: type2, ...) -> output_type { body }`

**Notes**

1. Lambda or function literal is used to define the body of a function.
2. You can omit output type (Example 2 and 3).
3. Even if a lambda has no inputs, you must include `()` (Example 4).
4. Lambdas are closures and can capture variables (as read-only) in the parent function (Example 4 and 5).
4. Example 5 shows a function that returns a lambda.
5. Example 6 shows invoking a lambda at the point of definition.
6. You can use `_` to define a lambda based on an existing function or another lambda or function pointer value. Just make a normal call and replace the lambda inputs with `_`. Example 8 defines a lambda to call `process` functions with `x:=10` but `y` and `z` will be inputs.
7. You can use `:Type` after `_` when creating lambda, to remove ambiguity (Example 10).
8. If lambda is assigned to a variable, you can invoke itself from inside (Example 9). This is used to implement iteration loops.

**Examples**

1. `f1 := (x: int, y:int) -> int { x+y }`
2. `f1 := (x: int, y:int) -> { x+y }` 
3. `rr := (x: int, y:int) -> x + y`  
4. `rr := () -> { return x + y }`
5. `test := (x:int) -> plusFunc { |y:int| -> y + x }`
6. `(x:int)->int { x+1 } (10)`
7. `process := (x:int, y:float, z: string) -> { ... }`
8. `lambda1 := process(10, _, _)`
9. `ff := (x:int) -> { ff(x+1) }`
10. 
```
process := (x:int)->...
process := (y:string)->...
...
g := process(_:int)
```

## Chain operator

**Syntax**: 

1. `input ~ lambda1, lambda2, ...`
2. `(input1, input2, ...) ~ lambda1, lambda2, ...`
3. `input ~ var.[_,_,...]`
4. `input ~ var.(_,_,...)`

**Notes**

1. This operator is used to put arguments before a lambda.
2. `X ~ F(_)` will be translated to `F(X)`. You can have multiple candidates in place of `F` and the one which can accept type of `X` will be invoked (Example 12).
3. You can also have multiple inputs put inside parenthesis (Example 1).
4. If right-side expects a single input but the left side is a struct with multiple items, it will be treated as a struct for the single input of the function (Example 4) but if the function expects multiple inputs they will be extracted from the left side (Example 3). 
5. You can also pass a single argument to right side of the chain by using non-struct value. If you pass a struct with a single item to a function (Example 11) and there are two candidates for that call (one that accepts `int` and other accepts `{int}`) compiler will give error.
6. `input ~ var.[_]` is same as `process(var, input)`.

**Examples**

1. `g := (5,9) ~ add(_, _)` => `g := add(5,9)`
2. `(1,2) ~ processTwoData(_, _)` => `processTwoData(1,2)`
3. `(${1,2}) ~ processStruct(_)` => `processStruct(${1,2})`
4. `(6) ~ addTo(1, _)` => `addTo(1, 6)`
5. `result := (input, check1(5, _)) ~ pipe(_,_) ~ pipe(_, check3(1,2,_)) ~ pipe(_,check5(8,_,1))`
6. `pipe[T, O] := (input: Maybe[T], handler: func(T)->Maybe[O])->Maybe[O] ...`
7. `inc := (x:int) -> x+1`, `eleven := 10 ~ inc(_)`
8. `add := (x:int, y:int) -> x+y`, `(10, 20) ~ add(_,_)`
9. `(1) ~ process(_)`, = `1 ~ process(_)`
10. `result := error_or_int ~ (x:error)->10, (y:int)->20`

# Operators

**Syntax**:

1. Conditional operators: `and, or, not, =, !=, >=, <=`
2. Arithmetic: `+, -, *, /, %, %%`
3. Assignment: `:=`
4. Type-id: `@` and `@[TypeName]`
5. Casting `.{}`
6. Chain `~`
7. Custom literal `[()]`
8. Nothing check operator `//`
9. Optional call `.()`
10. Custom process `.[]`

**Notes**

1. The meaning for most of the operators is like C-based languages except for `=` which is used to check for equality.
2. `:=` operator is used to define a named type or a binding.
3. `=` will do a comparison on a binary-level. 
5. `@`: returns type-id of the data inside a union binding, `@[T]` returns a unique identifier of the `T` type (Example 1). Both operators return an integer number which can be used to compare with another type identifier.
6. `{}`: To cast from named to unnamed type you can use: `Type{value}` notation (Example 2).
7. `{}`: To cast from variable to a union-type (Example 7).
8. `[(a,b,c) (d,e,f) ...]`: You can use compound literal to define a literal which is calculated by calling appropriate `set` functions repeatedly. These literals have the form of `[(a,b,c) (d,e,f) ...]`. In this example the literal has a set of elements each of which has 3 items. This means that to calculate the value of the literal, the compiler will render `x0 := set(nothing, a, b, c)`, then `x1 := set(x0, d, e, f)` and continue until end of values. The final result will be the output value. This notation can be used to have map literals and other custom literals.
10. `A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B.
11. Conditional operators return `true` or `false` which actually are `1` and `0`.
12. Optional call: `a.(b,c,d)` will call `a` if it is a function pointer, else it will do nothing. This is useful in conditionals where you have a value in some case but for the other case you want a lambda (Maybe due to high computation cost). And want to merge them both after the condition is evaluated (Example 6).
13. Custom get: `a.[b,c,d]` is a syntax sugar for calling: `process(a,b,c,d)`. For sequence, it is used to fetch element at a specific index.

**Examples**

01. `g := @[int]`, `g := @int_or_float`
02. `MyInt := int`, `x: MyInt := MyInt{int_var}`
03. `y:int := int{x}`
04. `y: int|float := 12`
05. `y := x // y // z // 0`
06. `result := [data, () -> processBigBuffer(buffer)].[condition].()`
07. `data, successs := int{int_or_float}`

# Concurrency

**Syntax**
1. Parallel execute `result :== expression` 
2. Create `reader: rchan[T], writer: wchan[T] := createChannel[T](buffer_size, r_lambda, w_lambda)`
3. Read data `data := reader.[]`
4. Write data `writer.[data]`
5. Select `data, channel := [wch1 wch2].[data1 data2].[rch1 rch2].[]`
6. Select `data, channel := [rch1 rch2].[wch1 wch2].[data1 data2].[]`

**Notes**
1. Channels are a data transportation mechanism which are open the moment they are created and closed when they are GC'd.
2. They can be read-only (`rchan[T]`) or write-only (`wchan[T]`). 
3. Channels can be buffered or have a transformation function (`func(T)->T`) which will be applied before write or after read.
4. You can use `:==` syntax to evaluate an expression in parallel and when its finished, store result in `result`. If expression creates a struct you can destruct it using `a,b,c :=` syntax or use `_` to ignore expression result. Any reference to `result` after parallel execution will pause the code until execution is finished.
5. Any party can close/dispose their channel. Send or receive on a channel where there is no receiver or sender will cause blocking forever. If you want to prevent this, you need to implement this separately using another channel or any other mechanism.
6. There are utility functions to create timed or always on channels (to be used as default in a select)
7. Exclusive resources (sockets, file, ...) are implemented using channels to hide inherent mutability of their underlying resource.
8. In select notation, you provide a list of read-only channels and a list of write-only channels + same number of data to write and append `.[]` to the list. The result will be the data which is being sent/received and the channel which executed that operation. Select will try any of given channels for read/write operation and will do the operation on the first available channel.

**Examples**
1. 
```
std_reader, std_writer := createStd[string]()
data := std_reader.[]
std_write.["Hello"]
reader, writer := createChannel[int](100) #specify buffer size

#Options for all channels: buffer size, transformation function.
getStdOut[T] := (lambda: (T)->T) -> wchan[T] ...
getStdIn[T] := (lambda: (T)->T) -> rchan[T] ...
getSocketReader[T] := (s: Socket, lambda: (T)->T) -> rchan[T] ...
getSocketWriter[T] := (s: Socket, lambda: (T)->T) -> wchan[T] ...
getFileReader[T] := (path: string, lambda: (T)->T) -> rchan[T] ...
getFileWriter[T] := (path: string, lambda: (T)->T) -> wchan[T] ...
```
2. `data :== processInfo(1,2,a)`

# Other Features

## Conditionals and pattern matching

**Notes**

1. You can use sequence literals to implement conditionals and pattern matching. This is also possible by using lambdas and conditional `return`.
2. Example 1 shows a simple case of implementing pattern matching.
3. Example 2 shows equivalent of `x := if a>0 then 200 else 100` pseudo-code.

**Examples**

1.
```
v: int|float|string := processData()
//check: if predicate is satisfied, return lambda result, else nothing
x: int|nothing := check[int](@v=@[int], ()->100)
y: int|nothing := ...
z: int|nothing := ...
//merge takes multiple T|nothing values and returns the only non-nothing one.
result : int := merge(x,y,z)
//or: combine them together
result : int := merge(check[int](@v=@[int], ()->100), check[int](@v=@[string], ()->200), check[int](true, ()->300))
```

2.
```
x:int := [100 200].[a>0]
```

## dispose

**Syntax**: `dispose(x)`

**Notes**

1. This function is used to invalidate a binding and release any memory or resources associated with it.
2. You cannot use a variable after calling dispose on it. 
3. You can call dispose on any variable.
4. Dispose function will properly handle any resource release like closing file or socket or ... .

## Exception handling

**Syntax**: `process := () -> int|exception { ... return exception{...} }`

**Notes**

1. There is no explicit support for exceptions. You can return a specific `exception` type instead.
2. You can use chaining operator to streamline calling multiple functions without checking for exception output each time.
3. If a really unrecoverable error happens, you should exit the application by calling `exit` function in core.
4. In special cases like a plugin system, where you must control exceptions, you can use core function `invoke` which will return an error result if the function which it calls exits.

**Examples**

1. `result: int|exception := invoke(my_function)`

## autoBind

**Syntax**: `x := StructType.{Alias}`, `x := StructType.{::}`

**Notes**

1. There is a special usage for casting operator, when you cast a namespace (`::` or namespace alias) to a struct. This will map bindings with similar name and type to fields inside the struct. So for example, if the struct has `age:int` and the namespace contains a binding the same name and type, the result of cast will have `age` assigned to `age` from within the namespace.
1. Example 1 defines a general struct which contains a function pointer field.
2. Example 2 defines a function to sort any given array of any type. But to do the sort, it needs a function to compare data of that type. So it defines an input of type `Comparer[T]` to include a function to do the comparison.
3. Example 3 shows how to call `sort` function defined in example 2. You simply cast current namespace to `Comparer` to create an appropriate struct of appropriate function pointers by the compiler. So `f.compare` field will contain a function pointer to a function with the same name and signature defined in the current namespace.
4. Example 4 is same as example 3 but with explicit types. You can omit these types as compiler will infer them.
5. This mechanism can be used to define expected protocol (a set of functions and data) as a function input.

**Examples**

1. `Comparer[T] := { compare: func(T,T)->bool }`
2. `sort[T] := (x: array[T], f: Comparer[T])->array[T] { ... }`
3. `sort(myIntArray, Comparer.{::})`
4. `sort(myIntArray, Comparer[int].{::})`

# Examples

## Empty application

```
main := () -> 0
```

This is a function, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

## Hello world

```
main := () -> print("Hello world!")
```

## Expression parser

We want to write a function which accepts a string like `"2+4-3"` and returns the result (`3`).

```
NormalExpression := {op: char, left: Expression, right: Expression}
Expression := int|NormalExpression

eval := (input: string) -> float 
{
  exp := parse(input)
  return innerEval(exp)
}

innerEval := (exp: Expression) -> float 
{
  (@exp = @[int]) return int.{exp}.0
  y,_ := NormalExpression{x}
  
  (y.op = '+') return innerEval(y.left) + innerEval(y.right) 
  (y.op = '-') return innerEval(y.left) - innerEval(y.right)
  (y.op = '*') return innerEval(y.left) * innerEval(y.right)
  (y.op = '/') return innerEval(y.left) / innerEval(y.right)
}
```

## Quick sort
```
quickSort:func(seq[int], int, int)->seq[int] := (list:seq[int], low: int, high: int) ->
{
  (high >= low) return list
  
  mid_index := (high+low)/2
  pivot := list.[mid_index]
  
  small_list := filter( list, (x:int)-> x<pivot )
  big_list   := filter( list, (x:int)-> x>pivot )
  
  return merge(quickSort(small_list), pivot, quickSort(big_list))
}
```

## Filtered sum
A function which accepts a list of numbers and returns sum of even numbers.
```
filteredSum := (data: seq[int]) -> int
{
  calc := (index: int, sum: int)->
  {
    (index>=length(data)) return sum
    return calc(index+1, sum+data.[index])
  }
  
  return calc(0,0)
}
```

## Digit extractor
A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.
```
extractor := (n: number, result: seq[char]) ->
{
  (n<10) return append(result, char.{48+n})
  digit := n % 10
  return extractor(n/10, append(result, char.{48+digit})
}
```

## Max sum
A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.
```
maxSum := (a: seq[int], b: seq[int]) -> int
{
	calc := (idx1: int, idx2: int, current_max: int) -> 
	{
		(idx2 >= length(b)) return current_max
		sum := a.[idx1] + b.[idx2]
		next1 := (idx1+1) % length(a)
		next2 := idx2 + (idx1+1)/length(a)
		return calc(next1, next2, max(current_max, sum))
	}
	
	return calc(0, 0, 0)
}
```

## Fibonacci
```
fib := (n: int, cache: seq[int|nothing])->int
{
	(seq[n] != nothing) return int.{seq[n]}.0
	seq_final1 := set(seq, n-1, fib(n-1, cache))
	seq_final2 := set(seq_final1, n-2, fib(n-2, seq_final1))

	return seq_final2.[n-1]+seq_final2.[n-2]
}
```

# Other components

## Core packages

A set of core packages will be included in the language which provides basic and low-level functionality (This part may be written in C):

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

Generally, anything that cannot be written in dotLang will be placed in this package.

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
Python uses the same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dependency, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version meta data but no dependency management. For dependency it has NuGet.

## ToDo
- **Language**: Notation for axioms and related operators like `=>` to define semantics of a data structure or function, dependent types
- **Compiler**: test, debug and profiling code, plugins for Editors (e.g. vim, emacs), code vetting for format the code based on the standard (indentation, spacing, brace placement, warning about namings, ...), escape analysis and optimize them to use mutable variable (for example for numerical calculations which happens only inside a function), parallel compilation
- **`std` package**: `map` data type, loop helper functions for iteration, 
- **`core` package**: sequence slice functions
- **Concurrency and parallelism**: Add native concurrency and communication tools (green thread, channels, spinlock, STM, mutex) and async i/o, Channels are the main tool for concurrency and coordination.
- **Others**: 
  1. Build, dependency management, versioning, packaging, and distribution
  2. Plugin system to load/unload libraries at runtime without need to recompile
  3. Distributed processing: Moving code to another machine and running there (Actor model + channel), or creating a channel which is bound to a remote process
  4. Define notation to write low-level (Assembly or IR) code in a function body and also force inline.
  5. Provide ability to update used libraries without need to re-compile main application.
  
# History

- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 10 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism, and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple-dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: May 3, 2017 - Clarifications for exception, Adding `where` keyword, explode operator, Sum types, new notation for hash-table and changes in defining tuples, removed `const` keyword, reviewed inheritance notation.
- **Version 0.9**: May 8, 2017 - Define notation for tuple without fields names, hashmap, extended explode operator, refined notation to catch exception using `//` operator, clarifications about empty types and inheritance, updated templates to use empty types instead of `where` and moved `::` and `any` to core functions and types, replaced `switch` with `match` and extended the notation to types and values, allowed functions to be defined for literal input, redefined if to be syntax sugar for match, made `loop` a function instead of built-in keyword.
- **Version 0.95**: May 23, 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to specifying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow operator overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numeric types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (`^` and `%`).
- **Version 0.96**: Jun 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.97**: Jun 26, 2017 - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` place holder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is typed statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`.
- **Version 0.98**: Aug 7, 2017 - implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to `~`, re-write and clean this document with correct structure and organization, added `autoBind`, change notation for union to `|` and `()` for lambda, simplify primitive types, handle conditional and pattern matching using map and array, renamed tuple to struct, `()` notation to read from map and array, made `=` a statement, added `return` and `assert` statement, updated definition of chaining operator, everything is now immutable, Added concept of namespace which also replaces `autoBind`, functions are all lambdas defined using `let`, `=` for comparison and `:=` for binding, move `map` data type out of language specs, made `seq` the primitive data type instead of `array` and provide clearer syntax for defining `seq` and compound literals (for maps and other data types), review the manual, removed `assert` keyword and replace with `(condition) return..`, added `$` notation, added `//` as nothing-check, changed comment indicator to `#`, removed `let` keyword, changed casting notation to `Type.{}`, added `.[]` instead of `var()`, added `.()` operator
- **Version 1.00**: ???? ?? ????? - Added `@[]` operator, Sequence and custom literals are separated by space, Use parentheses for custom literals, `~` can accept multiple candidates to chain to, rename `.[]` to custom process operator, simplified `_` and use `()` for multiple inputs in chain operator, enable type after `_`, removed type alias and `type` keyword, added some explanations about type assignability and identity, explain about using parenthesis in function output type, added `^` for polymorphic union type, added concurrency section with `:==` and notations for channels and select

# Time table

