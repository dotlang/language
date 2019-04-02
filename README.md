# dot Programming Language (dotLang)

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 1.00-beta2

Nov 6, 2018

# Table of Contents

1. [Introduction](https://github.com/dotlang/language/blob/master/README.md#introduction)
2. [Language in a nutshell](https://github.com/dotlang/language/blob/master/README.md#language-in-a-nutshell)
3. [Bindings](https://github.com/dotlang/language/blob/master/README.md#bindings)
4. [Type system](https://github.com/dotlang/language/blob/master/README.md#type-system)
5. [Functions](https://github.com/dotlang/language/blob/master/README.md#functions)
6. [Modules](https://github.com/dotlang/language#modules)
7. [Concurrency](https://github.com/dotlang/language/blob/master/README.md#concurrency)
8. [Examples](https://github.com/dotlang/language/blob/master/README.md#examples)
9. [Other components](https://github.com/dotlang/language/blob/master/README.md#other-components)
10. [History](https://github.com/dotlang/language/blob/master/README.md#history)

# Introduction

After having worked with a lot of different languages (C\#, Java, Scala, Perl, Javascript, C, C++ and Python) and getting familiar with some others (including Go, D, Swift, Erlang, Rust, Zig, Crystal, Fantom, OCaml and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: **dotLang**.

dot programming language (or dotLang for short) is an imperative, static-typed, garbage collected, functional, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Erlang, Elixir, Elm, Falcon, Julia, Zig, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is an imperative language which is also very similar to Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. We have first-class and higher-order functions borrowed from the functional approach.

Two main objectives are pursued in the design and implementation of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few (but essential) things are done implicitly and transparently by the compiler or runtime system. Also, I have tried to reduce the need for nested blocks and parentheses, as much as possible. Another aspect of simplicity is minimalism in the language. It has very few keywords and rules to remember.
2. **Performance**: The source will be compiled to native code which will result in higher performance compared to interpreted languages. The compiler tries to do as much as possible (optimizations, dereferencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, disposing, reference counting GC, ...) so runtime performance will be as high as possible. Where performance is a concern, the corresponding functions in core library will be implemented in a lower level language.

Achieving both of the above goals at the same time is impossible, so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, the code is written in files (called modules) organized in directories (called packages). We have bindings (immutable data which can be functions or values) and types (Blueprints to create bindings). Type system includes primitive data types, sequence, map, enum, struct and union. Concurrency and lambda expression are also provided and everything is immutable.

## Comparison

Language | First-class functions | Sum types | Full Immutability| Garbage Collector | Module System | Lambda | Concurrency | built-in data types | Number of keywords
--- | --- | --- | --- | --- | --- | --- | --- | --- | --- 
C  |  Yes | Partial  | No  | No |  No | No | No | 14 | 32
Scala | Yes | Yes | No | Yes | Yes | Yes | Yes | 9 | ~27
Go | Yes | No | No | Yes | Yes | Yes | Yes | 19 | 25
Java | Yes | No | No | Yes | Yes | Yes | No | 8 | 50
Haskell | Yes | Yes | No | Yes | Yes | Yes | No | 63 | 28
dotLang | Yes | Yes | Yes | Yes | Yes | Yes | Yes | 8 | 0

## Components

dotLang consists of these components:

1. The language manual (this document).
2. `dot`: A command line tool to compile, debug and package code.
3. `core` library: This package is used to implement some built-in, low-level features which can not be simply implemented using pure dotLang.
4. `std` library: A layer above core which contains some general-purpose and common functions and data structures.

# Language in a nutshell

You can see the grammar of the language in EBNF-like notation [here](https://github.com/dotlang/language/blob/master/syntax.md).

## Main features

01. **Import a module**: `queue = import("/core/std/queue")` (you can also import from external sources like Github).
02. **Primitive types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`. 
03. **Bindings**: `my_var:int = 19` (type is optional, everything is immutable).
04. **Sequence**: `my_array = [1, 2, 3]` (type of `my_arr` is `[int]` or sequence of integers)
05. **Map**: `my_map = ["A":1, "B":2, "C":3]` (type of `my_map` is `[string:int]` or map of string to integers)
06. **Named type**: `MyInt = int` (Defines a new type `MyInt` with same binary representation as `int`).
07. **Type alias**: `IntType : int` (A different name for the same type).
08. **Struct type**: `Point = struct(x: int, y:int, data: float)` (Like `struct` in C).
09. **Struct literal**: `location = Point(x:10, y:20, data:1.19)`.
10. **Union type**: `MaybeInt = int | nothing` (Can store either of two types, note that this is a named type).
11. **Function**: `calculate = fn(x:int, y:int -> float) { x/y }` (Functions are all lambdas, the last expression in the body is return value).
12. **Lambda**: `sort(my_sequence, fn(x,y:int -> bool) { x-y })` (sort a sequence using given lambda for comparison)
13. **Concurrency**: `my_task := processData(x,y,z)` (Evaluate an expression in parallel).
14. **Generics**: `ValueKeeper = fn(T: type -> type) { struct(data: T) }` (A generic type is defined similar to a function)
15. **Generics**: `push = (x: T, stack: Stack(T), T: type -> Stack(T)) { ... }` (A generic function)
16. **Enum**: `DayOfWeek = enum [saturday, sunday, monday, tuesday, wednesday, thursday, friday]`

## Symbols

01. `#`  Comment
02. `.`  Access struct members
03. `()` Function declaration and call, struct declaration and literals
04. `{}` Code block, selective import
05. `[]` Sequence and map
06. `|`  Union data type 
07. `->` Function declaration
08. `//` Nothing-check operator
09. `:`  Type declaration (binding, struct field and function inputs), type alias, struct literal
10. `=`  Binding declaration, named type
11. `_`  Place-holder (lambda creator and assignment)
12. `:=` Parallel execution
13. `..` Access inside module

## Reserved keywords

**Primitive data types**: `int`, `float`, `char`, `byte`, `bool`, `string`

**Reserved identifiers**: `true`, `false`, `fn`, `import`, `and`, `or`, `not`, `struct`, `enum`, `type`, `nothing`

## Coding style

1. 4 spaces indentation.
2. You must put each statement on a separate line. 
3. Naming: `SomeDataType`, `someLambdaBinding`, `someFunction`, `any_binding`, `my_module`.
4. If a function returns a type (generic types) it should be named like a type.
5. If a binding is a pointer to a function, it should be named like a function.
6. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
7. You can use `_` as digit separator in number literals.
8. Any identifier starting with underscore, is supposed to be private at the declaration site (although this is not enforced by compiler).

## Operators

Operators are mostly similar to C language (Conditional operators: `and, or, not, ==, <>, >=, <=`, Arithmetic: `+, -, *, /, %, %%`, `>>`, `<<`, `**` power) and some of them which are different are explained in corresponding sections (Casting, underscore, ...).

Note that `==` will do a comparison based on contents of its operands.
`A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B (e.g. `y = x // y // z // 0`).
Conditional operators return `true` or `false` which are `1` and `0` when used as index of a sequence.

# Bindings

A binding assigns an identifier to an immutable memory location. A binding's value can be a literal value, an expression or another binding. The literal value can be of any valid type (integer number, function literal, struct literal, ...). Binding names must start with a lowercase letter.

You can define bindings at module-level or inside a function. Module-level bindings can only have literals as their value. Type of a binding can be inferred without ambiguity from right side value, but you also have the option to specify the type (Example 1 and 2).

If the right side is a struct, you can destruct it into it's elements by using comma separated values on the left side of `=` (Example 3). In this process, you can also use underscore to indicate you are not interested in one or more of those elements (Example 4).

You can call built-in dispose function to explicitly free resources allocated for a binding. Any reference to a binding after call to dispose will result in compiler error.

**Syntax**: 

1. `identifier = expression`
2. `identifier : type = expression`

**Examples**

1. `x : int = 12`
2. `g = 19.8 #type is inferred`
3. `a,b = struct(int,int){1, 100}`
4. `a,_ = point`, `a,_ = single_element_struct`
5. `process("A", age:21)`

## Binding name resolution

To resolve a binding name, first bindings in current function will be searched. If not found, search will continue to parent functions, then module-level. At any scope, if there are multiple candidates (with same name) there will be a compiler error.

# Type system

Types are blueprints which are used to create values for bindings. Types can be simple or compound (sequence, map, struct, ...).

Simple type is a type which can be described using an identifier without any characters (e.g `MyCustomer` is a simgple type but `[int]` is not).

## Basic types

**Syntax**: `int`, `float`, `char`, `byte`, `bool`, `string`, `nothing`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. String literals should be enclosed in double quotes. 
6. String literals enclosed in backtick can be multiline and escape character `\` will not be processed in them.
7. `bool` type is same as int and `true` is 1, `false` is 0.
8. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.
9. `byte` is an unsigned 8-bit number.

**Examples**

1. `x = 12`
2. `x = 1.918`
3. `x = 'c'`
4. `g = true`
5. `str = "Hello world!"`
6. `str2 = "Hello" + "World!"`

## Sequence

Sequence is similar to array in other languages. It represents a fixed-size block of memory with elements of the same type, `T` and is shows with `[T]` notation. You can initialize a sequence with a sequence literal (Example 1).

You refer to elements inside sequence using `x[i]` notation where `i` is index number. Referring to an index outside sequence will return `nothing`. Putting an extra comma at the end of a sequence literal is allowed. `[]` represents an empty sequence.

Core defines built-in functions for sequence for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...` plus functions for safe get where they return `T|nothing`.

**Examples**

1. `x = [1, 2, 3, 4]`
2. `x = [ [1, 2], [3, 4], [5, 6] ] #a 2-D sequence of integer numbers`
3. `x = [1, 2]+[3, 4]+[5, 6]] #merging multiple sequences`
4. `int_or_nothing = x[10]`

## Map

You can use `[KeyType:ValueType]` to define a map type. When reading from a map, you will get `nothing` if value does not exist in the map.

An empty map can be denoted using `[:]` notation. Putting an extra comma at the end of a map literal is allowed.

Core defines built-in functions for maps for common operations: `map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

1. `pop = ["A":1, "B":2, "C":3]`
2. `data = pop["A"]`

## Enum

You can prefix any compile time sequence and `enum` keyword and it will be an enum type: `NewTypeName = enum [sequence of literals]`
Note that sequence can have types too and it can be used with generics (Example 1). This is output of the core function that returns type of a union binding.
variables of enum type must accept values of exactly what is specified inside sequence, nothing else, even if they have same value.

You can use a map to decide something based on enum value. Compiler will make sure you have covered all possible types.

**Examples**

1. `NumericType = enum [int, float]` 
2.
```
saturday=1
sunday=2
...
DayOfWeek enum [saturday, sunday, ...]
```
3. `x = [saturday: "A", sunday: "B", ...][my_day_of_week]`

## Union

Bindings of a union type, have ability to hold multiple different types and are shown as `T1|T2|T3|...`.  You can destruct a binding of union type. This will give you a list of values each of type `T|nothing` for each type of the union (except nothing itself). You can use `_` to ignore one or more possible outputs.

**Examples**

1. `int_or_float: int|float = 11`
2. `int_or_nothing, float_or_nothing = int_or_float_or_nothing_value`
3. 
```
x: int|string|float = getData()
result = check(x, fn(i:int -> boolean) { ... }) //
         check(x, fn(s: string -> boolean) {...}) //
         check(x, fn(f:float->boolean){...})
```

## Struct

A struct (Similar to struct in C), represents a set of related binding definitions without values. To provide a value for a struct, you can use either a typed struct literal (e.g. `Type(field1:value1, field2:value2, ...)`, note that field names are mandatory. 

You can use destruction to access unnamed fields inside a struct(Example 7).

Struct literals must be prefixed by their type or parent value. When defining a struct type (either using named type or inline type) field types is mandatory but field names is optional (Example 11).

**Examples**

1. `Point = struct (x:int, y:int) #defining a struct type`
2. `point2 = Point(x:100, y:200) #create a binding of type Point`
3. `point1 = struct(int,int)(100, 200) #untyped struct`
4. `point4 = Point(x:point3.x, y : 101} #update a struct based on existing struct binding`
5. `x,y = point1 #destruction to access struct data`
6. `another_point = Point(x:11, y:my_point.y + 200)`
7. `_, x = point1 #another way to access untyped struct data`
11.
```
process = fn(x: struct (id:int, age:int) -> int) { x.age }
process = fn(x: struct (int, int) -> int) { 
	_,a = x
    a
}
```

## Named types

You can name a type so you will be able to refer to that type later in the code. Type names must start with a capital letter to be distinguished from bindings. You define a named type similar to a binding: `NewType = UnderlyingType`.The new type has same binary representation as the underlying type but it will be treated as a different type.

You can use casting operator to convert between a named type and its underlying type (Example 4). You can define named type inside a function.

**Examples**

1. `MyInt = int`
2. `IntArray = [int]`
3. `Point = struct {x: int, y: int}`
4. `x = 10`, `y = MyInt(10)`

## Type alias

You can use `T : X` notation to define `T` as another spelling for type `X`. In this case, `T` and `X` will be the same thing, so you cannot define two functions with same name for `T` and `X`.

You can use a type alias to prevent name conflict when importing modules or inside a function.

**Examples**

1. `MyInt : int`
2. `process = fn(x:int -> int) { 10}`
3. `process = fn(x:MyInt -> int)` Error! `process:(int->int)` is already defined.

## Type argument

These are binding of type `type`. You can use these bindings anywhere you need (inside function arguments, part of a struct, ...) but their value must be specified at compile time.
More in "Generics" section.

## Type name resolution

To resolve a type name, first closure level types and then module-level types will be searched for a type name or alias with the same name. At any scope, if there are multiple candidates there will be a compiler error.

Two named types are never equal. Otherwise, two types T1 and T2 are identical/assignable/exchangeable if they have the same structure (e.g. `int|string` vs `int|string`).

## Casting

In order to cast across named types, you will need to write an identity function (a function that only returns its input), but with correct types.

**Examples**

1. 
```
MyInt = int
toInt = fn(x: MyInt -> int) { x }
h: MyInt = ...
g:int = toInt(h)
```

## Generics

Generic types are defined using functions that return a `type` (a type argument) and use `[]` instead of `()` . These functions are compile time (because anything related to `type` must be) (Example 1). 

Note that arguments or functions of type `type` must be named like a type, not like a binding, and must receive value at compile time. This means that you cannot use a runtime dynamic binding value as a type. You also cannot assign a function that receives or return a type to a lambda. Because lambdas are a runtime concept. Note that a generic function's input of form `T|U` means caller can provide a union binding which has at least two options for the type, it may have 2 or more allowed types.

If a generic type is not passed in a function call (and it is at the end of argument list), compiler will infer it (Example 6). 

**Examples**

1. 
```
LinkedList = fn[T: type -> type]
{
	Node = struct (
		data: T,
		next: Node|nothing
	)
	Node|nothing
}
```
2. `process = fn(x: LinkedList[int] -> int)`
3. `process = fn(T: type, ll: LinkedList[T] -> ...`
4. 
```
process = (T: type, data: List[T] ...
pointer = process(int, _) #right, type of pointer is fn(int, List[int])
```
5. `process = fn(T: type, x: [T], index: int -> T) { x[index] }`
6. 
`push = fn(data: T, stack: Stack(T), T: type -> Stack[T]){...}`
`resutl = push(int_var, int_stack)`


# Functions

Functions are a type of binding which can accept a set of inputs and give an output. For example `(int,int -> int)` is a function type, but `(x:int, y:int -> int) { x+y}` is function literal. What comes after `->` must be a type.

A function will return the result of its last expression.

You can alias a function by defining another binding pointing to it (Example 8). 

If a function has no input, you can can eliminate input/output type declaration part (Example 13).

When calling a function, you can ommit arguments that are at the end and accept `nothing` (Example 14). This can be used to have optional arguments.

If a function is being called with literals (compile time known values), compiler will try to evaluate it during compilation. This is used in generic types (Example 15).

**Syntax**: 

- Defining a function:

`functionName = fn(name1: type1, name2: type2... -> OutputType) { code block ... out = expression }`

- Defining a function type (Examples 14, 15 and 16):
`FunctionType = fn(type1, type2, ... -> OutputType)`

**Examples**

01. `myFunc = fn(x:int, y:int -> int) { 6+y+x }`
02. `log = fn(s: string -> nothing) { print(s) } #this function returns nothing`
03. `process2 = fn(pt: Point -> struct {int,int}) { return {pt.x, pt.y} } #this function returns a struct`
04. `myFunc9 = fn(x:int -> {int}) { struct {int}{x+12} } #this function returns a struct literal`
05. `process = fn(x: int|Point -> int) ... #this function can accept either int or Point type as input or int|Point type`
06. `{_,b} = process2(myPoint) #ignore second output of the function`
07. 
```
process = fn(x:int -> int) 
{ 
  #if x<10 return 100, otherwise return 200
  [x<10: 100, x>=10: 200][true]
}
``` 
08. `process = fn(x:int -> int) { x+1 }`, `process2 = process`
09. `sorted = sort(my_sequence, fn(x,y -> int) { x-y} )`
10. `Adder = fn(int,int->int) #defining a named type based on a function type`
11. `sort = fn(x: [int], comparer: fn(int,int -> bool) -> [int]) {...} #this function accepts a function pointers`
12. `map = fn(input: [int], mapper: fn(int -> string) -> [string])`
13. `process = fn{ 100 }`
14.
```
seq = fn(start_or_length:int, end:int|nothing -> ...)
...
x = seq(10)
y = seq(1,10)
```
15. 
```
add = fn(a:int, b:int ->int) { a+b }
g = add(1,2)
```

## Function call resolution

We use a static dispatch for function calls. Also because you cannot have two functions with the same name, it is easier to find what happens with a function call.

If `MyInt = int` is defined in the code, you cannot call a function which needs an `int` with a `MyInt` binding, unless it is forwarded explicitly in the code (e.g. `process = fn(x:MyInt -> process(int(x)))`).

To resolve a function call, first bindings with that name in current function will be searched. If not found, search will continue to parent functions, then module-level. At any scope, if there are multiple candidates (matching with name) there will be a compiler error. Parameter types must be "compatible" with function arguments, or else there will be a compiler error. For example if function argument type is `int | nothing` and parameter is an `int` it is a valid function call.

## Lambda (Function literal)

Lambda or a function literal is used to specify value for a binding of function type. It is very similar to the way you define body of a function binding. Lambdas are closures and can capture bindings in the parent function which come before their definition (Example 1). They can also capture members of the parent struct, if the code is part of a binding inside a struct.

You can use `_` to define a lambda based on an existing function. Just make a normal call and replace the lambda inputs with `_` (Example 5).

If lambda is assigned to a variable, it can invoke itself from inside (Example 6). This can be used to implement recursive calls.

**Examples**

1. `rr = fn(nothing -> int) { x + y } #here x and y are captures from parent function/struct`
2. `test = fn(x:int -> PlusFunc) { fn(y:int -> int) { y + x} } #this function returns a lambda`
3. `fn(x:int -> int) { x+1} (10) #you can invoke a lambda at the point of declaration`
4. `process = (x:int, y:float, z: (string -> float)) { ... } #a function that accepts a lambda`
5. `lambda1 = process(10, _, _) #defining a lambda based on existing function`
6. `ff = fn(x:int -> int) { ff(x+1)}`

# Modules

Modules are source code files. You can import them into current module and use their declarations. You can import modules from local file-system, GitHub or any other external source which the compiler supports (If import path starts with `.` or `..` it is relative path, if it start with `/` it is based on project's root). If the specific absiolute module path does not exist, compiler will look into parent modules (if any). If still not found, compiler will try to download it from web. Compiler will support specifying specific branch/release/commit when importing a module. Compiler will keep track of current module root and all parent module roots. If a dependency is not found in any of parent roots, it will be downloaded into top most module root (If it is a zip file, it will be decompressed).

The result of importing a module is a module definition which if named, should be named like a binding and used with `..` notation to access definitons inside module. You can also ignore output of an import to have its definitions inside current namespace. You can also use `..{}` notation to only access some of module's symbols (Examples 9 and 10).

Absolute paths that start with http or https will be downloaded from the net if not available locally.

You can import at module level or inside a function. The output of import will be valid only inside its enclosing context.

You can use `@` notation to indicate required tag or branch name. This part allows using `+` and `*` to indicate versions equal or higher to x or any version are acceptable (Example 8).

**Syntax**

`ModuleName = import("/path/to/module")`

**Examples**

1. `Socket = import("/core/st/socket") #import everything, addressed module with absolute path`
2. `Socket = import("../core/st/socket") #import with relative path`
3. `Module = import("/http/github.com/net/server/branch1/dir1/dir2/module") #you need to specify branch/tag/commit name here`
4. `base_cassandra = "/http/github/apache/cassandra/mybranch"`
5. `Module = import(base_cassandra + "/path/module") #you can create string literals for import path`
6.
```
Set = import("/core/set")..SetType
process = fn(x: Set -> int) ...
```
7. `my_customer = import("/data/customer")..Customer(name:"mahdi", id:112)`
8.
`T = import("/https/github.com/uber/web/@v1.9+.*/request/parser")`
`T = import("/https/github.com/uber/web/@new_branch/request/parser")`
`T = import("/https/server.com/web/@v1.9+.*.zip/request/parser")`
9. `Set, process, my_data = import("/core/set")..{SetType, processFunc, my_data}`
10. `Set, process, my_data = imported_module..{SetType, processFunc, my_data}`

# Concurrency

We have `:=` for parallel execution of an expression. This will initiate a new task as a child of the current task. Any access to the output of `:=` will block current task until the child is finished.

Each task has an unbounded mailbox which can accept messages from any other task. Sending to an invalid task will return immediately with a false result indicating send has failed. Receive with an empty inbox, will block the current process. You can use built-in functions to access current task's functionality (pick a message from mailbox, send a message to another task, ...).

**Syntax**

1. Parallel execute `output := expression` 

**Examples**

1. `msg = receive(Message)`
2.
```
int_result := process(10)
task_id = getCurrentTaskChildren().last()
accepted = sendMessage(Message, my_message, task_id)
picked_up = sendAndWait(Message, my_message, task_id)
int_result = resolve(int, task_id) #wait until task is finished and get the result
```

# Patterns

Because a lot of non-essential features are removed from the language and core, the user has freedom to implement them however they want (using features provided in the language). In this section we provide some of possible solutions for these types of features.

## Polymorphism

Polymorphism can be achieved using cloure and lambdas. 

Pseudo code:
```swift
drawCircle = fn(s: Circle, Canvas, float -> int) {...}
drawSquare = fn(s: Square, Canvas, float -> int) {...}

Shape = struct { draw: fn(Canvas, float -> int)}
getShape = fn(name: String -> Shape) 
{
	if name is "Circle" 
		c = Circle{...}
		Shape{ draw = drawCircle(c, _, _) }
}
f = getShape("Circle")
f.draw(my_canvas, 1.12)
```

If you want to add a new shape (e.g. Triangle), you should add appropriate functions (And the case checks in `getShape` needs to be modified).
If you want to add a new operation (e.g. print), you will need to add a new function that returns a lambda to print.

Note that above `Shape` is very similar to "trait".

Another approach to implement polymorphism:

```
drawCircle = fn(s: Circle, Canvas, float -> int) {...}
drawSquare = fn(s: Square, Canvas, float -> int) {...}

getDraw = fn(x: T, T: type -> fn(Canvas, float -> int)) 
{
    vtable = [Circle : drawCircle, Square: drawSquare]
    cast(fn(T, Canvas, float), vtable[T])(x, _, _)
}
f = getDraw(my_circle)(my_canvas, 1.52)
```

## Exception handling

There is no explicit support for exceptions. You can return a specific `exception` type instead (or use `nothing` type to indicate exception).

If a really unrecoverable error happens, you should exit the application by calling `exit` function from core. 

In special cases like a plugin system, where you must control exceptions, you can use built-in function `invoke` which will return an error result if the function which it calls exits.

Example: `process = fn(nothing -> int|exception) { ... return exception{...} }`

## Conditionals

If and Else constructs can be implemented using the fact that booleans converted to integer will result to either 0 or 1 (for `false` and `true`).

```
ifElse = fn(T: type, cond: bool, true_case: T, true_case:T -> T) 
{
	[cond: true_case, !cond: false_case]
}
```

Another example:

```
process = fn(x:int -> string)
{
	temp = [x>0 : fn{ saveLargeFileToDB("SDSDASDA") }, 
		x<=0: fn(x:int->string) { innerProcess(x) },  ]

	temp[true]()
}
```

## Dependency management

It is advised to put all import paths in one module like `refs` and import it to specify import paths.

```
#refs
std_map = "/http/github.com/dotLang/std/v1.9.5/MapHelper"
```
and then use above:
```
#File1
Refs = import("/src/main")
MapHelper = import(Refs.std_map)

#File2
refs = import("/src/main"){}
MapHelper = import(refs.std_map)
```
When compiler sees first usage of `std_map` in import, it will notice it does not exist locally. So will convert string to URL (adding `://` and ...) and download and save it to corresponding directory relative to project root. The next time, module will be there.

## Pattern matching

You can do pattern matching on union types using map and type identifiers:

```
f = fopen("...") 
#now suppose that type of f is File|Identifier|nothing 
number_inside_the_file = [
	File:		fn{freadInt(f)}, 
	Identifier: 	fn{convert(int, Identifier)}, 
	nothing: 	fn{0}]
[getType(f)]()
```

# Examples

## Empty application

```
main = fn( -> int ) { 0 }
```

This is a function, called `main` which has no input and always returns `0` (very similar to C/C++ except `main` function has no input).

## Hello world

```
main = fn( -> int) 
{
	print("Hello world!")
	0
}
```

## Expression parser

We want to write a function which accepts a string like `"2+4-3"` and returns the result (`3`).

```
NormalExpression = {op: char, left: Expression, right: Expression}
Expression = int|NormalExpression

eval = fn(input: string -> float) 
{
  exp = parse(input) #assume we already have this
  innerEval(exp)
}

innerEval = fn(exp: Expression -> float) 
{
  hasType(int, exp) :: int(exp).0
  
  #now we are sure that exp is an expression
  y,_ = *NormalExpression{exp}
  
  y.op == '+' :: innerEval(y.left) + innerEval(y.right)
  y.op == '-' :: innerEval(y.left) - innerEval(y.right)
  y.op == '*' :: innerEval(y.left) * innerEval(y.right)
  y.op == '/' :: innerEval(y.left) / innerEval(y.right)
  
  #no exception handling for now
  :: 0
}
```

## Quick sort

```
quickSort = fn(list:[int], low: int, high: int -> [int])
{
  high<low :: list
  
  mid_index = (high+low)/2
  pivot = list[mid_index]
  
  #filter is a built-in function
  small_list = list.filter(fn(x -> x < pivot))
  big_list   = list.filter(fn(x -> x > pivot))
  
  :: quickSort(small_list) + [pivot] + quickSort(big_list)
}
```

## Sequence sum

A function which accepts a list of numbers and returns sum of numbers.

```
filteredSum = (data: [int] -> int)
{
  calc = (index: int, sum: int -> int)
  {
    index >= length(data) :: sum
    :: calc(index+1, sum+data[index])
  }
  
  :: calc(0,0)
}
```

## Digit extractor

A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.

```
extractor = (n: number, result: string -> string)
{
  n < 10 :: result + char(48+n)
  digit = n % 10
  :: extractor(n/10, result + char(48+digit)
}
```

## Max sum

A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.

```
maxSum = (a: [int], b: [int] -> int)
{
	calc = (idx1: int, idx2: int, current_max: int -> int)
	{
		idx2 >= length(b) :: current_max
		sum = a[idx1] + b[idx2]
		next1 = (idx1+1) % length(a)
		next2 = idx2 + int((idx1+1)/length(a))
		:: calc(next1, next2, max(current_max, sum))
	}
	
	:: calc(0, 0, 0)
}
```

## Fibonacci

```
fib = (n: int, cache: [int|nothing] -> int)
{
	cache[n] != nothing :: int(cache[n]).0
	seq_final1 = set(seq, n-1, fib(n-1, cache))
	seq_final2 = set(seq_final1, n-2, fib(n-2, seq_final1))

	:: seq_final2[n-1] + seq_final2[n-2]
}
```

## Cache

A cache can be implemented using a parallel task. Everytime cache is updated, it will call itself with the new state.

```
CacheState = [string: int]
cache = (cs: CacheState->)
{
    request = pick(Message[CacheStore])
    new_cache_state = update(cs, request)
    query = receive(Message[CacheQuery])
    result = lookup(new_cache_state, query)
    send(Message{my_wid, query.sender_wid, result})
    cache(new_cache_state)
}
```

### Guessing game

```
stdin = import("/http/github.com/dotLang/std/stdin"){}
stdout = import("/http/github.com/dotLang/std/stdout"){}
rand = import("/http/github.com/dotLang/std/random"){}

main = fn
{
	secret = rand(1,100)
	stdout.write("Please enter a number: ");
	guessRaw: int|nothing = tryParseString(int, stdin.readLine())
		
	ifElse(guessRaw == nothing, 
	fn{
		stdout.write("Invalid number")
	},
	fn {
		guess = cast(int, guessRaw)
		actions = [guess<secret: fn{ stdout.write("Too small!") },
				   guess>secret: fn{ stdout.write("Too large!") },
				   guess==secret: fn{ stdout.write("Well done!") }
				  ][true]()
	})
}
```

# Other components

## Core packages

A set of core packages will provide basic and low-level functionality (This part may be written in C or LLVM IR):

- Calling C/C++ methods
- Interacting with the OS
- Load code on the fly and hot swap
- Data conversion
- Garbage collector (Runtime)
- Serialization and Deserialization
- Dump an object
- RegEx functions
- Concurrency
- Security policy (how to call a code you don't trust)
- Bitwise operators (and, or, shift, ...)

Generally, anything that cannot be written in dotLang will be placed in this package.

## Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in dotLang). Here is a list of some of classes in this package collection:

- I/O (Network, Console, File, ...)
- Collections (Stack, Queue, Linked List, ...)
- Encryption
- Math
- ...

## Package Manager

The package manager is a utility which helps you package, publish, install and deploy packages (Like `maven`, `NuGet` or `dub`).
Suppose someone downloads the source code for a project written in dotLang which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent way to fetch dependencies at runtime and defining them at the time of development.

# History

- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 10 months of research, comparison and evaluation.
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
- **Version 0.99**: Dec 30, 2017 - Added `@[]` operator, Sequence and custom literals are separated by space, Use parentheses for custom literals, `~` can accept multiple candidates to chain to, rename `.[]` to custom process operator, simplified `_` and use `()` for multiple inputs in chain operator, enable type after `_`, removed type alias and `type` keyword, added some explanations about type assignability and identity, explain about using parenthesis in function output type, added `^` for polymorphic union type, added concurrency section with `:==` and notations for channels and select, added ToC, ability to merge multiple modules into a single namespace, import parameter is now a string so you can re-use existing bindings to build import path, import from github accepts branch/tag/commit name, Allow defining types inside struct, re-defined generics using module-level types, changed `.[]` to `[]`, comma separator is used in sequence literals, remove `$` prefix for struct literals, `[Type]` notation for sequence, `[K,V]` notation for map, `T!` notation for write-only channel and `T?` notation for read-only channel, Removed `.()` operator (we can use `//` instead), Replaced `.{}` notation with `()` for casting, removed `^` operator and replaced with generics, removed `@` (replaced with chain operator and casting), removed function forwarding, removed compound literal, changed notation for channel read, write and select (Due to changes in generics and sequence and removal of compound literal) and added `$` for select, add notation to filter imported identifiers in import, removed autoBind section and added a brief explanation for `TargetType()` notation in cast section, rename chain operator to `@`, replaced return keyword with `::`, replaced `import` with `@` notation and support for rename and filter for imported items, replaced `@` with `.[]` for chain operator, remove condition for return and replaced with rule of returning non-`nothing` values, change chain notation from `.[]` to `.{}` and import notation from `@[]` to `@()`, Added notation for polymorphic generic types, changed the notation for import generic module and rename identifiers, removed `func` keyword, extended general union type syntax to unnamed types with field type and names (e.g. `{id:int, name:string,...}`), Added shift-left and right `>>,<<` and power `**` operators, all litearls for seq and map and struct must be prefixed with `_`, in struct literals you can include other structs to implement struct update, changed notation for abstract functions, Allow access to common parts of a union type with polymorphic union types, use `nothing` instead of `...` for generic types and abstract functions, removed phantom types, change `=>` notation to `^T :=` notation to rename symbols, removed composition for structs and extended/clarified usage of polymorphic sum types for embedding and function forwarding, change map type from `[K,V]` to `[K:V]`, removed auto-bind `Type()`, remove abstract functions, remove `_` prefix for literals, remove `^` and add `=>` to rename types so as to fix issue with introducion of new named types when filtering an import operation, replace operators `:=` to `=` and `:==` to `==` and `=` (comparison) to `=?`, adding type alias notation `T:X`, change import operator to `@[]` and replace `=>` with type alias notation, use `:=` to calculate in parallel and `==` to equality check
- **Version 1.00-beta**: July 5, 2018 - Use `=` for type alias and `:=` for lazy (parallel) calculation and named type, More clarification about binding type inference, explain name resolution mechanism for types and bindings and function call, added explanation about using function name as a function pointer, explanation about public functions with private typed input/output, removed type specifier after binding name (it will be inferred from RHS), changed function type to `(input:type->output_type)`, removed chanin operator, some clarifications about casting operator and expressions, remove `::` and use bindings for output with future reference, allow calling lambda at the point of definition, allow omitting types if they can be inferred in defining functions, indicate that functions cannot have same name and introduce compile-time dynamic sequence to store multiple functions and treat the sequence as a function, restore using type name before struct literal, change `...` as a more general notation for polymorphic union types, re-write generics as code-generation + compile-time dynamic sequence for functions, add `*` destruct operator for struct explode which can also be used to call a function with named arguments or initialize a sequence, remove notation for casting a union to it's elements (replaced with use of sequence of functions), replace `...` notation with already defined `&` and `|`, removed `${}` notation for select and replaced with a function call on a sequence, removed concept of treating sequence of functions as a function, added `type` core function + ability to amend module level collections using `&`, explained loop built-in function for map, reduce and filter operations
- **Version 1.00-beta2**: Nov 6, 2018. Add support for **`type` keyword** and generics data types and generic functions, remove map and sequence from language, defined instance-level and type-level fields with values, added `byte` and `ptr` types to primitive types, add support for vararg functions, added Patterns section to show how basic tools can be used to achieve more complex features (polymorphism, sequence, map, ...), use **mailbox instead of channels** for concurrency, clarification about using unions as enums + concrete types, added `::` operator for return and conditional return, changed polymorphism method to avoid strange linked-list notations for VTable or functions with the same name and use closure instead, added `*` for struct types, Allow functions to return types and use it to implement generics, Return to `[]` notation for map and sequence and their literals, Allow defining types inside struct which are acceissble through struct type name, Import gives you a struct which you can assign to a name or alias or import into current namespace using `*`, Make task a type in core as `SelfTask` and `Task` which provide functions to work with mailbox, Add functions in core to seq and map for map/reduce/filter/anymatch, remove `ptr` type, remove vararg functions, clarification about tasks and exclusive resources, use core for file and console operations, use `$` to access current task, use dot notation to initialise a struct, support optional type specification when defining a binding, set `@` notation to **import a module as a struct type** which you can use just like any other type, we have closure at module level, review the whole spec, use `{}` for casting, use `:` for type alias, use `+` for concat and `&` for concurrency, destruct using `{}` on the left side, no more `:=`, remove range operator, use `:=` for concurrency, replace `$` with core function, `:=` returns a normal output and you should use `getCurrentTask().children()` to access newly created child task
- **Version 1.00**: replace `@` with import keyword, replace `::` with `return` keyword and remove conditional return, In function decl, after `->` it must be a type, use `fn` prefix for function type and literal, use `struct` for struct type declarations, clarification about module import and dependency management, remove return keyword, don't force braces to be on their own line, added optional arguments to pattern section, clarification about structs with field name but no named type, allow multiple module import, destruct without assignment gives you struct with unnamed fields which has both bindings and types, allow omit argument which are `|nothing` in function call, use `=` for type alias and `:=` for named type (because `:` for type alias caused confusion and ambiguity), use `$` to auto inference of generic types, clarification about dependency and version management, simplify concurrency by removing lambda when receiving messages, `check` core function, remove `$` and replace it with `|nothing` as optional generic type argument, remove `xor` keyword, make `_` as private rule a convention and not a rule, import gives us a Module identifier which is not a struct, struct can only have a list of fields without value (so no closure inside struct), make generic types always inferred by compiler if they are missing, use `:` for type alias and `=` for named type, treat type names as functions for casting, no `_` for untyped struct you must write type even if the type definition itself, no `.1` notation instead use destruction, do not use `{}` for destruction, no notation for modify existing struct as a new binding, use `()` for structs instead of `{}`, use `cast, tryCast` for casting, add `enum`s, use `..` to access inside module and allow import into current namespace, remove multiple import notation, use destruction for unions, cast for named types using identity functions, generic types using normal `()` functions, allow selective import, clarify about calling generic function with unions, state `_` is usable with union destruction
