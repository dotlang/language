# dot Programming Language (dotLang)

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 0.98

August 7, 2017

# Table of Contents

1. [Introduction](https://github.com/dotlang/language/blob/master/README.md#introduction)
2. [Language in a nutshell](https://github.com/dotlang/language/blob/master/README.md#language-in-a-nutshell)
3. [Bindings](https://github.com/dotlang/language/blob/master/README.md#bindings)
4. [Type system](https://github.com/dotlang/language/blob/master/README.md#type-system)
5. [Generics](https://github.com/dotlang/language/blob/master/README.md#generics)
6. [Functions](https://github.com/dotlang/language/blob/master/README.md#functions)
7. [Operators](https://github.com/dotlang/language/blob/master/README.md#operators)
8. [Concurrency](https://github.com/dotlang/language/blob/master/README.md#concurrency)
9. [Other features](https://github.com/dotlang/language/blob/master/README.md#other-features)
10. [Examples](https://github.com/dotlang/language/blob/master/README.md#examples)
11. [Other components](https://github.com/dotlang/language/blob/master/README.md#other-components)
12. [History](https://github.com/dotlang/language/blob/master/README.md#history)

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

As a 10,000 foot view of the language, the code is written in files (called modules) organized in directories (called packages).  We have bindings (immutable data definitions which include first-class functions and values) and types (Blueprints to create bindings). Type system includes primitive data types (`int`, `float`, `char`, `function`, `sequence` and `map`), struct and union. Generics, concurrency and lambda expression are also provided and everything is immutable.

## Comparison

**Compared to C**: C language + garbage collector + first-class functions + template programming + sum types + module system + simple and powerful standard library + lambda expressions + multiple dispatch + full immutability - undefined behavior - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + full immutability + simpler primitives - *dependency on JVM* - traits - custom operators - implicit parameters.

**Compared to Go**: Go + *generics* + full immutability + multiple dispatch + union types + simpler primitives - pointers - interfaces - global variables - `interface{}`.

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

In the above examples `/core, /core/sys, /core/net, /core/net/http, /core/net/tcp` are all packages. Each package can contain zero or more modules.

# Language in a nutshell

## Main features

01. **Import a module**: `import "/core/std/queue"` (you can also import from external sources like Github).
02. **Primitive types**: `int`, `float`, `char`, `sequence`, `map`, `func`.
03. **Bindings**: `my_var:int := 19` (type can be automatically inferred, everything is immutable).
04. **Sequence**: `scores:[int] := [1, 2, 3, 4]`.
05. **Map**: `scores:[string, int] := ["A",1, "B",2, "C",3, "D", 4]`.
06. **Named type**: `MyInt := int` (Defines a new type with same binary representation as `int`).
07. **Struct type**: `Point := {x: int, y:int, data: float}` (Like `struct` in C)
08. **Struct literal**: `location := Point{x:=10, y:=20, data:=1.19}`
09. **Composition**: `Circle := {Shape, radius: float}` (`Circle` embeds fields of `Shape`)
10. **Generics**: `import "/core/Stack[int]"` (Generics are defined as template modules)
11. **Union type**: `MaybeInt := int | nothing` (Can store either of possible types)
12. **Function**: `calculate: func(int,int)->float := (x, y) -> float { return x/y  }`
13. **Concurrency**: `result :== processData(x,y,z)` (Evaluate an expression in parallel)

## Symbols

01. `#`   Comment
02. `.`   Access struct fields (bindings and types)
03. `()`  Function declaration and call, cast
04. `{}`  Code block, struct definition and struct literal, return condition
05. `[]`  Types and literals (map, sequence), Generic modules, concurrency
06. `|`   Union data type 
07. `->`  Function declaration
08. `..`  Range generator for sequence
09. `//`  Nothing-check operator
10. `!`   Write-only channel
11. `?`   Read-only channel
12. `$`   Channel select operations
13. `:`   Type declaration (struct, function inputs and bindings)
14. `:=`  Binding declaration, named types
15. `:==` Parallel execution
16. `~`   Chain operator
17. `_`   Place holder (lambda creator and assignments)

## Reserved identifiers

**Keywords**: `return`, `import`

**Basic data types**: `int`, `float`, `char`, `string`, `bool`, `nothing`

**Compound data types**: `sequence`, `map`, struct and union

**Other data types**: `func`, `read-only channel`, `write-only channel`

**Reserved identifiers**: `true`, `false`

**Compound types**: Struct and Union

## Coding style

These rules are highly advised but not mandatory.

1. Indentation must be done using spaces, not tabs. Using 4 spaces is advised but not mandatory.
2. You must put each statement on a separate line. 
3. Naming: `SomeDataType`, `someFunctionName`, `my_binding_name`, `func_arg_name`, `my_package_dir`, `my_modue_file`.
4. Braces must appear on their own line. For lambdas that are a single expression you should omit braces.
5. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
6. You can use `,` as digit separator in number literals.

# Bindings

A binding assigns an identifier to a value. The value can be of any valid type (integer number, function, struct literal, ...). Bindings must start with a lowercase letter.

You can define bindings at module-level or inside a function. Module-level bindings can only have literals as their value, but function bindings can have expressions too. Type of a binding is automatically inferred from the value, but you can also explicitly state the type.

Note that all bindings are immutable. So you cannot manipulate or re-assign them.

If the value is a compound data structure, you can destruct it into it's elements (Example 5). In this process, you can also use underscore to indicate you are not interested in one or more of those elements (Example 6).

**Syntax**: 

1. `identifier := value/expression`
2. `identifier : type := value/expression`

**Examples**

1. `x: int := 12`
2. `g := 19.8 #type is inferred`
3. `a,b := process() #call the function and store the result in two bindings: a and b`
4. `x := y`
5. `a,b := {1, 100}`
6. `a,_ := {1, 100}`

# Type system

Types are blueprints which are used to create values for bindings.

Two types T1 and T2 are identical/assignable in any of below cases:
1. Both are named types defined in the same place in the code.
2. Both are unnamed types with similar definition (e.g. `int|string` vs `int|string` or `[int]` vs `[int]`).
2. T1 is named and T2 is identical to T1's underlying type, or vice versa.

Note that `func` is explain in the "Function" section and channel types are explained in "Concurrency" section.

## Basic types

**Syntax**: `int`, `float`, `char`, `string`, `bool`, `nothing`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. `string` is defined as a sequence of `char` data type, represented as `[char]` type. The conversion from/to string literals is handled by the compiler.
6. String literals should be enclosed in double quotes. 
7. String literals enclosed in backtick can be multiline and escape character `\` will not be processed in them.
8. `bool` type is same as int and `true` is 1, `false` is 0.
9. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.

**Examples**

1. `x := 12`
2. `x := 1.918`
3. `x := 'c'`
4. `g: bool := true`
5. `str: string := "Hello world!"`

## Sequence

Sequence is similar to array in other languages. It represents a fixed-size block of memory space with elements of the same type, T and is shows with `[T]` notation. You can initialize a sequence with a sequence literal (Example 1) or range operator (Example 2).

You refer to elements inside sequence using `x[i]` notation where `i` is index number. Referring to an index outside sequence will cause a runtime error.

**Examples**

1. `x: [int] := [1, 2, 3, 4]`
2. `x := [1..10] #initialize a sequence using range operator`
3. `x: [[int]] := [ [1, 2], [3, 4], [5, 6] ] #a 2-D sequence of integer numbers`
4. `x: [int] := [1, 2]&[3, 4]&[5, 6] #merging multiple sequences`
5. `n := x[10]`


## Map

You can use `[KeyType, ValueType]` to define a map type. When reading from a map, you will also receive a flag indicating whether the key exists in the map.

**Examples**

1. `pop: [string, int] := ["A",1,"B",2,"C",3]`
2. `data, is_found := pop["A"]`

## Union

Bindings of a union type, have ability to hold multiple different types and is shown as `T1|T2|T3|...`. You can also include identifiers as a valid value for a union type. These identifiers are types that have only one valid value which is same as their name. This can be used to define enumberations (Example 1).

When you convert a union variable to one of it's types (Example 3), you also get a boolean flag indicating whether conversion was successful.

**Examples**

1. `Day_of_week := SAT | SUN | MON | TUE | WED | THU | FRI`
2. `int_or_float: int | float := 11`
3. `int_value, is_valid := int(my_union)`

## Struct

A struct (Similar to struct in C), represents a set of related binding definitions which do not have values. To provide a value for a struct, you can use either a typed struct literal (e.g. `Type{field1:=value1, field2:=value2, ...}`, note that field names are optional) or an untyped struct literal (e.g. `{value1, value2, value3, ...}`).

You can update a struct binding and create a new binding (Example 5).

You can use `.0,.1,.2,...` notation to access fields inside an untyped struct (Example 11).

**Examples**

1. `Point := {x:int, y:int}`
2. `point2 := Point{x:=100, y:=200}`
3. `point3 := Point{100, 200}`
4. `point1 := {100, 200} #untyped struct`
5. `point4 := point3{y:=101} #update a struct`
6. `x,y := point1 #destruction to access struct data`
7. `another_point := Point{x:=11, y:=my_point.y + 200}`
8. `x := point1.1 #another way to access struct data`

### Composition

You can use struct composition to represent "is-a" or "has-a" relationship. In this case, all fields of the contained struct will be merged into container struct. The language provides pure "contain and delegate" mechanism as a limited form of polymorphism.

**Examples**

1. `Shape := { id:int }`
2. `Circle := { Shape, radius: float} #Shape is contained within a Circle`
3. `my_circle := Circle{id:100, radius:1.45} #creating a Circle binding`

## Named types

You can name a type so you will be able to refer to that type later in the code. Type names must start with a capital letter to be distinguished from bindings. You define a named type similar to a binding: `NewType := UnderlyingType`.The new type has same binary representation as the underlying type but it will be treated as a different type.

You can use casting operator to convert between a named type and its underlying type (Example 5).

If a function is called which has no candidate for the named type, the candidate for underlying type will be invoked (if any).

**Examples**

1. `MyInt := int`
2. `IntArray := [int]`
3. `Point := {x: int, y: int}`
4. `bool := true | false`
5. `x: MyInt := 10`, `y: MyInt := MyInt(10)`

## Casting

There is no implicit and automatic casting. The only exception is using boolean as a sequence index which will be translated to 0 and 1.

Casting is mostly used to cast between a union and its internal type (Example 2), between named and equal unnamed type (Example 4 and 5) or for numerical values (Example 1). 

Note that the target type should be either a primitive or a named type. You can also cast multiple items at once (Example 6).

The `Type(nothing)` notation gives you the default value for the given type (empty/zero value). The `Type()` notation is used for autoBind (Please refer to the corresponding section).

**Syntax**: `TargetType(data)`

**Examples**

1. `x:int := int(1.91)`
2. `int_value, has_int := int(int_or_float)`
3. `MyInt := int`, `x:MyInt := MyInt(int_var)`
4. `y:int := x`
5. `x := MyFuncType(t)`
6. `a, b, c := MyInt(x,y,z)`

# Modules

Modules are source code files. You can import them into current module and use their public types and bindings. You can import modules from local file-system, GitHub or any other external source which the compiler supports. You can also filter/rename imported identifiers to prevent name conflict.

**Syntax**

`import "/path/to/module"`
`import "/path/to/module" { name1 := name2, MyType := ModuleType, ... }`
`import "/path/to/module" { name2, MyType := ModuleType, ... }`
`import "/path/to/module" { _, MyType := ModuleType, ... }`

**Examples**

1. `import "/core/st/Socket" #import with absolte path`
2. `import "../core/st/Socket" #import with relative path`
3. `import "/core/std/{Queue, Stack, Heap}" #import multiple modules`
4. `import "git/github.com/net/server/branch1/dir1/dir2/module" #you need to specify branch/tag/commit name here`
5. `base_cassandra := "github/apache/cassandra/mybranch"`
6. `import base_cassandra&"/path/module"`
7. `import "/path/to/module" { ModuleType1 } #only import one type`
8. `import "/path/to/module" { _, MyType1 := ModuleType1 } #import everything but rename ModuleType1 to MyType1`

# Generics

Generics are implemented at module level. Just append generics types in lower case (e.g. `stack[t].dot`) to the module file name and you can use type `T` (all capital) in your code. Any module importing it, must provide concrete types for them or else there will be compiler error. So if a module imports `stack[int]`, compiler will re-write the module and replace any occurence of `T` with `int`.

If you provide any existing definition for the generic type or abstract functions based on it, the importer should provide a compliant type (Example 4).

You can specialize a generic module for known types by writing appropriately named module file (e.g. `module_name[string].dot`).

**Example**

1. `import "/core/Stack[int]"`
2. `x: Stack := createStack()`
3.
```
#set[t].dot
#T is not defined. This means T can be anything, but this function must be defined
compare := (a:T, b:T)->int
```
4.
```
#set[t].dot
#this means T must contain a data field of type string.
T := {data: string}
#and a function with below syntax
process := (a:T)->int
```

## Phantom types

Phantom types are used to document compile time constraints on the data without runtime cost of using generics or named types (When generic type is not used on the right side of type definition, it will be only for compile time check)
Phantoms are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. 

You can implement phantom types using a named type or a generic type.

**Examples**

1. `door[t].dot module file`: `Door := string`
2. `import "/Door[Open]" { OpenDoot := Door }`
3. `import "/Door[Closed]" { ClosedDoor := Doot }`
4. `closeDoor := (x: OpenDoor) -> ClosedDoor`
5. `openDoor := (x: ClosedDoor) -> OpenDoor`

# Functions

Functions are a type of binding which can accept a set of inputs and give an output. Lambda or a function pointer is defined similarly to a normal function in a module. They use the same syntax, except that, they are defined inside a function.
3. When defining a function, just like a normal binding, you can omit type which will be inferred from rvalue (Function literal). For example `func(int,int)->int` is a function type, but `(x:int, y:int) -> {return x+y}` is function literal.

If function does not return anything, it's return type will be marked as `nothing`. 

A function call with union data (e.g. `int|string`) means there must be functions defined for all possible types in the union (e.g. for `int` and `string`). 

You can prefix `return` with a conditional, enclosed in braces. Return will be triggered only if the condition is satisfied (Example 10).

If function output is a single identifier, you can omit parentheses in output type, otherwise they are mandatory (Example 11).

You can alias a function by defining another binding pointing to it (Example 12). You can define a function without body (Example 11). Calling these functions will result in runtime error. They are mostly used to define expected interfaces in generic modules.


**Syntax**: 

`functionName: func(type1, type2, type3, ...) -> (OutputType) := (name1: type1, name2: type2...) -> OutputType { code block }`

**Examples**

01. `myFunc:(int, int) -> int := func(x:int, y:int)-> int { return 6+y+x }`
02. `log := (s: string) -> { print(s) } #this function returns nothing`
03. `process := (pt: Point)->int pt.x #no need to use braces when body is a single expression`
04. `process2 := (pt: Point) -> {pt.x, pt.y} #this function returns a struct`
05. `my_func := (x:int) -> x+9 #no need to specify output type as it can be implied`
06. `myFunc9 := (x:int) -> {int} {12} #this function returns a struct literal`
07. `process := (x: int|Point])->int #this function can accept either int or Point type as input or int|Point type`
08. `fileOpen := (path: string) -> File {...}`
09. `_,b := process2(myPoint) #ignore function output`
10. 
```
process := (x:int) -> 
{ 
  {x<0} return 100
  return 200
}
``` 
11. `T1 := func(int)->(int|string)`
12. `process := (x:int)->x+1`, `process2 := process`

## Function pointer

Bindings of this type can hold a reference to a function or a lambda. You can send them to other functions or they can be used as output type of a function.

**Syntax**: `Fp := func(type1, type2, ...)->OutputType`

**Examples**

1. `Adder := func(int,int)->int #defining a named type based on a function type`
2. `myAdder := (x:int, y:int) -> x+y #initialize a binding with a function literal`
3. `adderPointer: Adder := myAdder #Store refernce to a function in a function pointer`
4. `sort := (x: [int], comparer: func(int,int) -> bool) -> [int] #this function accepts a function pointers`
5. `map := (input: [T], mapper: func(T) -> S) -> [S]`

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
9. If body of the lambda is a single expression you can omit braces and put it in front of `->`, else you need to include braces.

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

1. `input ~ (lambda1, lambda2), ...`
2. `(input1, input2, ...) ~ (lambda1, lambda2, ...)`

**Notes**

1. This operator is used to put arguments before a lambda.
2. `X ~ F(_)` will be translated to `F(X)`. You can have multiple candidates in place of `F` and the one which can accept type of `X` will be invoked (Example 12).
3. You can also have multiple inputs put inside parenthesis (Example 1).
4. If right-side expects a single input but the left side is a struct with multiple items, it will be treated as a struct for the single input of the function (Example 4) but if the function expects multiple inputs they will be extracted from the left side (Example 3). 
5. You can also pass a single argument to right side of the chain by using non-struct value. If you pass a struct with a single item to a function (Example 11) and there are two candidates for that call (one that accepts `int` and other accepts `{int}`) compiler will give error.

**Examples**

1. `g := (5,9) ~ add(_, _)` => `g := add(5,9)`
2. `(1,2) ~ processTwoData(_, _)` => `processTwoData(1,2)`
3. `({1,2}) ~ processStruct(_)` => `processStruct({1,2})`
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
5. Chain `~`
7. Nothing check operator `//`
8. Casting `()`

**Notes**

1. The meaning for most of the operators is like C-based languages except for `=` which is used to check for equality.
2. `:=` operator is used to define a named type or a binding.
3. `=` will do a comparison on a binary-level. 
6. `()`: To cast from named to unnamed type you can use: `Type(value)` notation (Example 2).
7. `()`: To cast from variable to a union-type (Example 7).
10. `A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B.
11. Conditional operators return `true` or `false` which actually are `1` and `0`.

**Examples**

02. `MyInt := int`, `x: MyInt := MyInt{int_var}`
03. `y:int := int{x}`
04. `y: int|float := 12`
05. `y := x // y // z // 0`
06. `result := [nothing, data][condition] // processBigBuffer(buffer)`
07. `data, successs := int{int_or_float}`

# Concurrency

**Syntax**

1. Parallel execute `result :== expression` 
2. Create `reader: T?, writer: T! := createChannel(buffer_size, r_lambda, w_lambda)`
3. Read data `data := reader?`
4. Write data `writer!data`
5. Select: `data, channel := ${rch1?, rch2?, wch1!data1, wch2!data2}`
6. Select: `data, channel := ${rch1?, [rch2,rch3]?, wch1!data1, [wch2,wch3]![data2, data3]}`

**Notes**

1. Channels are a data transportation mechanism which are open the moment they are created and closed when they are GC'd.
2. They can be read-only (`T?`) or write-only (`T!`). 
3. Channels can be buffered or have a transformation function (`func(T)->T`) which will be applied before write or after read.
4. You can use `:==` syntax to evaluate an expression in parallel and when its finished, store result in `result`. If expression creates a struct you can destruct it using `a,b,c :=` syntax or use `_` to ignore expression result. Any reference to `result` after parallel execution will pause the code until execution is finished.
5. You can refer to output of a parallel execution inside body of a lambda, and code won't be stopped unless the lambda is invoked (Example 2 and 3).
6. Any party can close/dispose their channel. Send or receive on a channel where there is no receiver or sender will cause blocking forever. If you want to prevent this, you need to implement this separately using another channel or any other mechanism.
7. There are utility functions to create timed or always on channels (to be used as default in a select)
8. Exclusive resources (sockets, file, ...) are implemented using channels to hide inherent mutability of their underlying resource.
9. Doing read/write operations outside `$` operator will make it non-blocking.

**Examples**

1. 
```
std_reader, std_writer := createStd[string]()
data := std_reader[]
std_write["Hello"]
reader, writer := createChannel[int](100) #specify buffer size

#Options for all channels: buffer size, transformation function.
getStdOut[T] := (lambda: (T)->T) -> T! ...
getStdIn[T] := (lambda: (T)->T) -> T? ...
getSocketReader[T] := (s: Socket, lambda: (T)->T) -> T- ...
getSocketWriter[T] := (s: Socket, lambda: (T)->T) -> T+ ...
getFileReader[T] := (path: string, lambda: (T)->T) -> T- ...
getFileWriter[T] := (path: string, lambda: (T)->T) -> T+ ...
```
2. `data :== processInfo(1,2,a)`
3. `getData := ()->data`

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
x: int|nothing := check[int](int(v).1, ()->100)
y: int|nothing := ...
z: int|nothing := ...
//merge takes multiple T|nothing values and returns the only non-nothing one.
result : int := merge(x,y,z)
//or: combine them together
result : int := merge(check[int](int(v).1, ()->100), check[int](string(v).1, ()->200), check[int](true, ()->300))
```

2.
```
x:int := [100, 200][a>0]
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

**Syntax**: `x := TragetType(Source)`

**Notes**

1. When you cast a struct value to another type, it will map fields defined inside that struct to fields inside TargetType which have the same name and type. So for example, if the source struct has `age:int` and the target type contains a binding the same name and type, the result of cast will have `age` assigned to `age` from within the struct.
2. Example 1 and 2 define a `Comparer` type and `sort` function. Example 3 and 4 show how you can call the function.
3. Example 3, shows you can capture existing functions with signature which matches with `Comparer` and store it in a struct, passed to `sort` function. If the source data for casting is not specified, it will be all currently defined bindings.
4. This mechanism can be used to define expected protocol (a set of functions and data) as a function input.

**Examples**

1. `Comparer := { compare: func(int,int)->bool }`
2. `sort := (x: [int], f: Comparer)->[int] { ... }`
3. `sort(myIntArray, Comparer())`

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
  {int(exp).1} return int(exp).0
  y,_ := NormalExpression{x}
  
  {y.op = '+'} return innerEval(y.left) + innerEval(y.right) 
  {y.op = '-'} return innerEval(y.left) - innerEval(y.right)
  {y.op = '*'} return innerEval(y.left) * innerEval(y.right)
  {y.op = '/'} return innerEval(y.left) / innerEval(y.right)
}
```

## Quick sort
```
quickSort:func([int], int, int)->[int] := (list:[int], low: int, high: int) ->
{
  {high >= low} return list
  
  mid_index := (high+low)/2
  pivot := list[mid_index]
  
  small_list := filter( list, (x:int)-> x<pivot )
  big_list   := filter( list, (x:int)-> x>pivot )
  
  return merge(quickSort(small_list), pivot, quickSort(big_list))
}
```

## Filtered sum
A function which accepts a list of numbers and returns sum of even numbers.
```
filteredSum := (data: [int]) -> int
{
  calc := (index: int, sum: int)->
  {
    {index>=length(data)} return sum
    return calc(index+1, sum+data[index])
  }
  
  return calc(0,0)
}
```

## Digit extractor
A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.
```
extractor := (n: number, result: [char]) ->
{
  {n<10} return append(result, char(48+n))
  digit := n % 10
  return extractor(n/10, append(result, char(48+digit))
}
```

## Max sum
A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.
```
maxSum := (a: [int], b: [int]) -> int
{
	calc := (idx1: int, idx2: int, current_max: int) -> 
	{
		{idx2 >= length(b)} return current_max
		sum := a[idx1] + b[idx2]
		next1 := (idx1+1) % length(a)
		next2 := idx2 + (idx1+1)/length(a)
		return calc(next1, next2, max(current_max, sum))
	}
	
	return calc(0, 0, 0)
}
```

## Fibonacci
```
fib := (n: int, cache: [int|nothing])->int
{
	{cache[n] != nothing} return int(cache[n]).0
	seq_final1 := set(seq, n-1, fib(n-1, cache))
	seq_final2 := set(seq_final1, n-2, fib(n-2, seq_final1))

	return seq_final2[n-1]+seq_final2[n-2]
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
- **`std` package**: `map` data type, loop helper functions for iteration 
- **`core` package**: sequence slice functions
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
- **Version 1.00**: ???? ?? ????? - Added `@[]` operator, Sequence and custom literals are separated by space, Use parentheses for custom literals, `~` can accept multiple candidates to chain to, rename `.[]` to custom process operator, simplified `_` and use `()` for multiple inputs in chain operator, enable type after `_`, removed type alias and `type` keyword, added some explanations about type assignability and identity, explain about using parenthesis in function output type, added `^` for polymorphic union type, added concurrency section with `:==` and notations for channels and select, added ToC, ability to merge multiple modules into a single namespace, import parameter is now a string so you can re-use existing bindings to build import path, import from github accepts branch/tag/commit name, Allow defining types inside struct, re-defined generics using module-level types, changed `.[]` to `[]`, comma separator is used in sequence literals, remove `$` prefix for struct literals, `[Type]` notation for sequence, `[K,V]` notation for map, `T!` notation for write-only channel and `T?` notation for read-only channel, Removed `.()` operator (we can use `//` instead), Replaced `.{}` notation with `()` for casting, removed `^` operator and replaced with generics, removed `@` (replaced with chain operator and casting), removed function forwarding, removed compound literal, changed notation for channel read, write and select (Due to changes in generics and sequence and removal of compound literal) and added `$` for select, add notation to filter imported identifiers in import.
