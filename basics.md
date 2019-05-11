# Basics

## Introduction

After having worked with a lot of different languages (C\#, Java, Scala, Perl, Javascript, C, C++ and Python) and getting familiar with some others (including Go, D, Swift, Erlang, Rust, Zig, Crystal, Fantom, OCaml and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: **dotLang**.

dot programming language (or dotLang for short) is an imperative, static-typed, garbage collected, functional, general-purpose language based on author's experience and doing research on many programming languages (namely 
[Go](https://golang.org/), 
[Java](https://docs.oracle.com/javase/tutorial/), 
[C\#](https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/), 
[C](https://en.cppreference.com/w/c), 
[C++](https://en.cppreference.com/w/), 
[Scala](https://www.scala-lang.org/), 
[Rust](https://www.rust-lang.org/), 
[Objective-C](https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ProgrammingWithObjectiveC/Introduction/Introduction.html), 
[Swift](https://swift.org/),
[Python](https://python.org/), 
[Perl](https://www.perl.org/), 
[Smalltalk](https://en.wikipedia.org/wiki/Smalltalk), 
[Ruby](https://www.ruby-lang.org/en/),
[Haskell](https://www.haskell.org/),
[Clojure](https://clojure.org/),
[Eiffel](https://www.eiffel.org/),
[Erlang](https://www.erlang.org/),
[Elixir](https://elixir-lang.org/),
[Elm](https://elm-lang.org/),
[Falcon](http://www.falconpl.org/),
[Julia](https://julialang.org/),
[Zig](https://ziglang.org/),
[F\#](https://fsharp.org/) and
[Oberon-2](https://cseweb.ucsd.edu/~wgg/CSE131B/oberon2.htm)). 
I call the paradigm of this language "Data-oriented". This is an imperative language which is also very similar to Functional approach and it is designed to work with data. There are no objects or classes. Only data structures and functions. We have first-class and higher-order functions borrowed from the functional approach.

Two main objectives are pursued in the design and implementation of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few (but essential) things are done implicitly and transparently by the compiler or runtime system. Also, I have tried to reduce the need for nested blocks and parentheses, as much as possible. Another aspect of simplicity is minimalism in the language. It has very few keywords and rules to remember.
2. **Performance**: The source will be compiled to native code which will result in higher performance compared to interpreted languages. The compiler tries to do as much as possible (optimizations, dereferencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, disposing, reference counting GC, ...) so runtime performance will be as high as possible. Where performance is a concern, the corresponding functions in core library will be implemented in a lower level language.

Achieving both of the above goals at the same time is impossible, so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, the code is written in files (called modules) organized in directories (called packages). We have bindings (immutable data which can be functions or values) and types (Blueprints to create bindings). Type system includes primitive data types, sequence, map, enum, struct and union. Concurrency and lambda expression are also provided.

## Comparison

Language | First-class functions | Sum types | Full Immutability| Garbage Collector | Module System | Concurrency* | Generics | built-in data types | Number of keywords
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- 
C  |  No | Partial  | No  | No |  No | No | No | 14 | 32
Scala | Yes | Yes | No | Yes | Yes | Yes | Yes | 9 | ~27
Go | Yes | No | No | Yes | Yes | Yes | No | 19 | 25
Java | Yes | No | No | Yes | Yes | No | Yes | 8 | 50
Haskell | Yes | Yes | No | Yes | Yes | No | Yes | 63 | 28
dotLang | Yes | Yes | Yes | Yes | Yes | Yes | Yes | 8 | 9

* Concurrency means built-in language level support.

## Components

dotLang consists of these components:

1. The language manual (this website).
2. `dot`: A command line tool to compile, debug and package source code.
3. `core` library: This package is used to implement some built-in, low-level features which can not be simply implemented using pure dotLang. This will be a built-in feature of the compiler/runtime.
4. `std` library: A layer above core which contains some general-purpose and common functions and data structures. This is optional to use by developers.

## Grammar

You can see the grammar of the language in EBNF-like notation [here](https://github.com/dotlang/language/blob/master/syntax.md).

## Main features

01. **Import a module**: `queue = import("/core/std/queue")` (you can also import from external sources like Github).
02. **Primitive types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`. 
03. **Bindings**: `my_var:int = 19` (type is optional, everything is immutable).
04. **Sequence**: `my_array = [1, 2, 3]` (type of `my_arr` is `[int]`, sequence of integers).
05. **HashMap**: `my_map = ["A":1, "B":2, "C":3]` (type of `my_map` is `[string:int]`, hash map of string to integer)
06. **Named type**: `MyInt = int` (Defines a new type `MyInt` with same binary representation as `int`).
07. **Type alias**: `IntType : int` (A different name for the same type).
08. **Struct type**: `Point = struct(x: int, y:int, data: float)` (Like C `struct`).
09. **Struct literal**: `location = Point(x:10, y:20, data:1.19)`.
10. **Union type**: `MaybeInt = int | nothing` (Can store either of two types, note that this is a named type).
11. **Function**: `calculate = fn(x:int, y:int -> float) { x/y }` (Functions are all lambdas, the last expression in the body is return value).
12. **Concurrency**: `my_task := processData(x,y,z)` (Start a new micro-thread and evaluate an expression in parallel).
13. **Generics**: `ValueKeeper = fn(T: type -> type) { struct(data: T) }` (A generic type is defined similar to a function that returns a type)
14. **Generics**: `push = (x: T, stack: Stack(T), T: type -> Stack(T)) { ... }` (A generic function)
15. **Enum**: `DayOfWeek = enum [saturday, sunday, monday, tuesday, wednesday, thursday, friday]`

## Symbols

01. `#`  Comment
02. `.`  Access struct members
03. `()` Function declaration and call, struct declaration and literals
04. `{}` Code block, selective import
05. `[]` Sequence and hashMap
06. `|`  Union data type 
07. `->` Function declaration
08. `//` Nothing-check operator
09. `:`  Type declaration (binding, struct field and function inputs), type alias, struct literal
10. `=`  Binding declaration, named type
11. `_`  Place-holder (lambda creator and assignment)
12. `:=` Parallel execution
13. `..` Access inside module

## Reserved keywords

**Primitive data types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `nothing`, `type`

**Operators**: `and`, `or`, `not`

**Data type identifiers**: `fn`, `struct`, `enum`

**Reserved identifiers**: `true`, `false`, `import`

## Coding style

1. Use 4 spaces indentation.
2. You must put each statement on a separate line. Newline is statement separator.
3. Naming: `SomeDataType`, `someFunction`, `some_data_binding`, `my_module_alias`.
4. If a function returns a type (generic types) it should be named like a type.
5. If a binding is a reference to a function, it should be named like a function.
6. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
7. You can use `_` as digit separator in number literals.

## Operators

Operators are mostly similar to C language:

* Conditional operators: `and, or, not, ==, <>, >=, <=`
* Arithmetic: `+, -, *, /, %, %%`, `>>`, `<<`, `**` for power)
* Note that `==` will do a comparison based on contents of its operands.
* `A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B (e.g. `y = x // y // z // 0`).
* Conditional operators return `true` or `false` which are `1` and `0` when used as index of a sequence.
* Comments can appear anywhere in the code and start with `#`. Anything after `#` till end of the line is comment.
