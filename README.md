# dot Programming Language (dotLang)

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 1.01

???? ?, 2018

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

After having worked with a lot of different languages (C\#, Java, Scala, Perl, Javascript, C, C++ and Python) and getting familiar with some others (including Go, D, Swift, Erlang, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: **dotLang**.

dot programming language (or dotLang for short) is an imperative, static-typed, garbage collected, functional, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Erlang, Elm, Falcon, Julia, Zig, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance, and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from the functional approach.

Two main objectives are pursued in the design and implementation of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few (but essential) things are done implicitly and transparently by the compiler or runtime system. Also, I have tried to reduce the need for nested blocks and parentheses as much as possible. Another aspect of simplicity is minimalism in the language. It has very few keywords and rules to remember.
2. **Performance**: The source will be compiled to native code which will result in higher performance compared to interpreted languages. The compiler tries to do as much as possible (optimizations, dereferencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, disposing, reference counting GC, ...) so runtime performance will be as high as possible. Where performance is a concern, the corresponding functions in core library will be implemented in a lower level language.

Achieving both of the above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, the code is written in files (called modules) organized in directories (called packages).  We have bindings (immutable data which include first-class functions and values) and types (Blueprints to create bindings). Type system includes primitive data types, struct and union. Concurrency and lambda expression are also provided and everything is immutable.

## Comparison

Language | Sum types | Full Immutability| Garbage Collector | Module System | Lambda | Polymorphism | Concurrency | Number of keywords |
--- | --- | --- | --- | --- | --- | --- |
C  |  Partial  | No  | No |  No | No | No | No | 32 |
Scala | Yes | No | Yes | Yes | Yes | Yes | Yes | ~27 |
Go | No | No | Yes | Yes | Yes | Yes | Yes | 25 |
Java | No | No | Yes | Yes | Yes | Yes | Yes | 50 |
dotLang | Yes | Yes | Yes | Yes | Yes | Partial | Yes | 11 |

## Components

dotLang consists of these components:

1. The language manual (this document).
2. `dot`: A command line tool to compile, debug and package code.
3. `core`: Core library: This package is used to implement some basic, low-level features which can not be simply implemented using pure dotLang.
4. `std`: Standard library: A layer above core which contains some general-purpose and common functions and data structures.

# Language in a nutshell

You can see the grammar of the language in EBNF-like notation [here](https://github.com/dotlang/language/blob/master/syntax.md).

## Main features

01. **Import a module**: `Queue = @("/core/std/queue")` (you can also import from external sources like Github).
02. **Primitive types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`. 
03. **Bindings**: `my_var = 19` (type will be automatically inferred, everything is immutable).
04. **Sequence**: `my_arr = [1,2,3]` (type of `my_arr` is `[int]`)
05. **Map**: `my_map = ["A":1,"B":2,"C":3]` (type of `my_map` is `[string:int]`)
06. **Named type**: `MyInt := int` (Defines a new separate type with same binary representation as `int`).
07. **Type alias**: `IntType = int` (A different name for the same type).
08. **Struct type**: `Point = {x: int, y:int, data: float}` (Like `struct` in C).
09. **Struct literal**: `location = Point{.x=10, .y=20, .data=1.19}`.
10. **Union type**: `MaybeInt = int | nothing` (Can store either of possible types).
11. **Function**: `calculate = (x:int, y:int -> z:float) { z = x/y  }` (Assigning to binding for output type means return).
12. **Lambda**: `sort( *{ source: my_sequence, compareFunction: (x,y -> x-y)} )` (If types can be inferred, you can omit them, `*` destructs a struct)
13. **Concurrency**: `result := processData(x,y,z)` (Evaluate an expression in parallel).
14. **Generics**: `ValueKeeper = (T: type -> {data: T})`

## Symbols

01. `#`   Comment
02. `.`   Access struct fields
03. `()`  Function declaration and call, cast
04. `{}`  Code block, struct definition and struct literal
05. `[]`  Sequence and map
06. `&`   Concatenation
07. `$`   Access current task
07. `*`   Destruct a struct (type or value)
08. `|`   Union data type 
09. `->`  Function declaration
10. `//`  Nothing-check operator
11. `:`   Type declaration (struct field and function inputs)
12. `=`   Binding declaration, type alias
13. `:=`  Named type, lazy/parallel evaluation
14. `_`   Place-holder (lambda creator, assignments and function declaration)
15. `@[]` Import
16. `::`  Return

## Reserved keywords

**Data types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`

**Reserved identifiers**: `true`, `false`

## Coding style

These rules are highly advised but not mandatory.

1. 4 spaces indentation.
2. You must put each statement on a separate line. 
3. Naming: `SomeDataType`, `someLambdaBindings`, `someFunction`, `any_simple_binding`, `my_package_dir`, `my_modue_file`.
4. If a function returns a type it should be named like a type.
5. If a binding is a pointer to a function, it should be named like a function.
6. Braces must appear on their own line. 
7. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
8. You can use `_` as digit separator in number literals.

## Operators

Operators are mostly similar to C language (Conditional operators: `and, or, not, xor, ==, <>, >=, <=`, Arithmetic: `+, -, *, /, %, %%`, `>>`, `<<`, `**` power) and some of them which are different are explained in corresponding sections (Casting, underscore, ...).

Note that `=` will do a comparison based on contents of bindings.
`A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B (e.g. `y = x // y // z // 0`).
Conditional operators return `true` or `false` which are `1` and `0` when used as index of a sequence.

# Bindings

A binding assigns an identifier to an immutable memory location. A binding's value can be a literal value, an expression or another binding. The literal value can be of any valid type (integer number, function literal, struct literal, ...). Bindings must start with a lowercase letter.

You can define bindings at module-level or inside a function. Module-level bindings can only have literals as their value. Type of a binding can be inferred without ambiguity from right side value, but you also have the option to specify that.

Note that all bindings are immutable. So you cannot manipulate or re-assign them. But module-level bindings can be updated as long as they are pure data.

If the value is a struct, you can destruct it into it's elements by using `*` operator which simply replaces it's operand with it's internal data (Example 5). In this process, you can also use underscore to indicate you are not interested in one or more of those elements (Example 6). You can use `*` in any place where a series of comma separated values are needed, but you have to consume the result of this operator (either via binding assignment or function call).

You can call built-in dispose function to explicitly free resources allocated for a binding. Any reference to a binding after call to dispose will result in compiler error.

**Syntax**: 

1. `identifier = expression`
2. `identifier : type = expression`

**Examples**

1. `x : int = 12`
2. `g = 19.8 #type is inferred`
3. `a,b = process() #call the function and store the result in two bindings: a and b`
4. `x = y`
5. `a,b = *{1, 100}`
6. `a,_ = *{1, 100}`

## Binding name resolution

To resolve a binding name, first bindings with given type in current function will be searched. If not found, search will continue to parent functions, then module-level and then imported modules. At any scope, if there are multiple candidates (with same name) there will be a compiler error.

# Type system

Types are blueprints which are used to create values for bindings.

Simple type is a type which can be described using an identifier without any characters (e.g `MyCustomer` is a simgple type but `[int]` is not).

## Basic types

**Syntax**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`

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

Sequence is similar to array in other languages. It represents a fixed-size block of memory space with elements of the same type, T and is shows with `[T]` notation. You can initialize a sequence with a sequence literal (Example 1) or range operator (Example 2). Sequence literal must be prefixed with underscore.

You refer to elements inside sequence using `x[i]` notation where `i` is index number. Referring to an index outside sequence will cause a runtime error. Putting an extra comma at the end of a sequence literal is allowed. `[]` represents an empty sequence.

Core defines built-in functions for sequence for common operations: `map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

1. `x = [1, 2, 3, 4]`
2. `x = [1..10] #initialize a sequence using range operator`
3. `x = [ [1, 2], [3, 4], [5, 6] ] #a 2-D sequence of integer numbers`
4. `x = [1, 2]&[3, 4]&[5, 6] #merging multiple sequences`
5. `n = x[10]`
6. `n = [*{100,200}]`

## Map

You can use `[KeyType:ValueType]` to define a map type. When reading from a map, you will also receive a flag indicating whether the key exists in the map. Map literals must be prefixed with underscore.

An empty map can be denoted using `[:]` notation. Putting an extra comma at the end of a map literal is allowed.

Core defines built-in functions for maps for common operations: `map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

1. `pop = ["A":1,"B":2,"C":3]`
2. `data, is_found = pop["A"]`

## Concrete types

These are types that have only one value which is specified when declaring the type. This can be used for enums.

**Examples**:

```
Success = 1
Failure = 0
```

## Union

Bindings of a union type, have ability to hold multiple different types and are shown as `T1|T2|T3|...`. If any of used types are not defined, they will be automatically defined by compiler as a named type for `nothing`. This can be used to define enumerations (Example 1). Note that you cannot use a complex type as a part of a union. You can only used named or primitive types.

When you convert a union variable to one of it's types (Example 3), you also get a boolean flag indicating whether conversion was successful.

**Examples**

1. 
```
#concrete types
Sat = 1
Sun = 2
Mon = 3
WeekDay = Sat | Sun | ...
x = Sat
```

2. `int_or_float: = 11`
3. `int_value, is_valid = *int(my_union)`

## Struct

A struct (Similar to struct in C), represents a set of related binding definitions which do not have values. To provide a value for a struct, you can use either a typed struct literal (e.g. `Type{.field1=value1, .field2=value2, ...}`, note that field names are mandatory) or an untyped struct literal (e.g. `{value1, value2, value3, ...}`). Struct literals must be prefixed either with underscore or type name.

You can update a struct binding and create a new binding (Example 4). You can include as many other bindings are you want in a struct litearls, as long as they are struct bindings too. Values will be applied in order, so anything you add at the end will overwrite what is already defined with the same name.

You can use `.0,.1,.2,...` notation to access fields inside an untyped struct (Example 7).

You can provide values for struct fields. If these values are functions, based on closure rules, they will have access to struct fields. If they don't access any of those fields, they will be type-level field (rather than instance-level field) and you can use them by using name of the type (Example 8) otherwise they are instance-level.

If a struct has a private field (starting with `_`), only type or instance level functions will have access to them. You can also use `*` operator when defining a struct to include fields from another struct into current one (Example 9).

You can also define types inside a struct. These types will be accessible by using struct type name (Example 10). When using struct type, you have access to inner types and value bindings. When using a struct value, you have access to everything defined inside its type.

If there are bindings defined in struct type declaration, you cannot override their values when instantiating the struct. These bindings however will be accessible both using struct type name and binding name (Example 12). Note that if there are fields inside a struct without value, you have to initialise them upon instantiation (Example 13) and you cannot change value of any field which already has a value.

**Examples**

1. `Point = {x:int, y:int}`
2. `point2 = Point{.x=100, .y=200}`
3. `point1 = {100, 200} #untyped struct`
4. `point4 = Point{point3, .y = 101} #update a struct`
5. `x,y = *point1 #destruction to access struct data`
6. `another_point = Point{.x=11, .y=my_point.y + 200}`
7. `x = point1.1 #another way to access untyped struct data`
8.
```
Customer = { name: string, getName = (->name), newCustomer = (->Customer{name: "Test"})}
#in the code:
my_customer.getName() #this gives you the name inside my_customer binding
cust = Customer.newCustomer()  #this will call type-level function
```
9.
```
Person = {name: string}
Employee = {*Person, employee_id: int}
```
10.
```
Customer = {name: string, Case: float}
process = (data: Customer.Case -> string) ...
```
11.
```
Point = {x:int, y:int, 
	mult = (p: Point, p2: Point -> p.x * p2.x + p.y * p2.y)
}
```
12.
```
Customer = {id: 12, name: string}
c = Customer{.name = "mahdi"}
id_12 = Customer.id
new_id_12 = c.id
```
13.
```
Point = {x:int, y:int, size:int = 2}
p = Point{} #invalid, we need values for x and y here
MathConst = { pi: float = 3.14 }
m = MathConst{} #valid
```

## Named types

You can name a type so you will be able to refer to that type later in the code. Type names must start with a capital letter to be distinguished from bindings. You define a named type similar to a binding: `NewType := UnderlyingType`.The new type has same binary representation as the underlying type but it will be treated as a different type.

You can use casting operator to convert between a named type and its underlying type (Example 5).

If a function is called which has no candidate for the named type, the candidate for underlying type will be invoked (if any).

**Examples**

1. `MyInt := int`
2. `IntArray := [int]`
3. `Point := {x: int, y: int}`
4. `bool := true | false`
5. `x = 10`, `y = MyInt(10)`

## Type alias

You can use `T = X` notation to define `T` as another spelling for type `X`. In this case, `T` and `X` will be the same thing, so you cannot define two functions with same name for `T` and `X`.

You can use a type alias to prevent name conflict when importing modules. Access level for a type alias must be same or more restricted as it's base type (If base type is public, alias can be either public or private, but if base is private, alias must be private).

**Examples**

1. `MyInt = int`
2. `process = (x:int -> 10)`
3. `process = (x:MyInt -> 10)` Error! `process:(int)->int` is already defined.

## Type argument

These are binding of type `type`. You can use these bindings anywhere you need (inside function arguments, part of a struct, ...) but their value must be specified at compile time.
More in "Generics" section.

## Type name resolution

To resolve a type name, first module-level types and then imported modules will be searched for a type name or alias with the same name. At any scope, if there are multiple candidates there will be a compiler error.

Two named types are never equal. Otherwise, two types T1 and T2 are identical/assignable/exchangeable if they have the same structure (e.g. `int|string` vs `int|string`).

## Casting

There is no implicit and automatic casting. The only exception is using boolean as a sequence index which will be translated to 0 and 1. You can use core functions to do casting to/from primitive types (e.g char to int or float to int). To cast to a compatible named type you can use `TypeName(value)` notation.

The `Type(nothing)` notation gives you the default value for the given type (empty/zero value). You can also cast using a type argument (Example 5).

**Syntax**: `TargetType(data)`

**Examples**

1. `x = int(1.91)`
2. `MyInt = int`, `x = MyInt(int_var)`
3. `y = x`
4. `x = MyFuncType(t)`
5. 
```
process = (T: type, my_shape: Shape -> ...)
{
	t_value, is_valid = T(my_shape)
	...
}
```

## Generics

Generic types are defined using functions that return a `type` (a type argument). These functions must be compile time calculatable (because anything related to `type` must be) (Example 1).

Note that arguments or functions of type `type` must be named like a type, not like a binding, and must receive value at compile time. This means that you cannot use a runtime dynamic binding value as a type. You also cannot assign a function that receives or return a type to a lambda. Because lambdas are dynamic and runtime concept.

**Examples**

1. 
```
LinkedList = (T: type -> type) 
{
	Node = {
		data: T,
		next: Node
	}
	:: Node
}
```
2. `process = (x: LinkedList(int) -> int)`
3. `process = (T: type, ll: LinkedList(T) -> ...`
4. 
```
process = (T: type, data: List[T] ...
pointer = process(_,_) #right, type of pointer is (T,List[T])
pointer = process(int, _) #right, type of pointer is (int, List[int])
```
5. `process = (T: type, x: [T], index: int -> x[index])`

# Functions

Functions are a type of binding which can accept a set of inputs and give an output. Lambda or a function pointer is defined similarly to a normal function in a module. They use the same syntax, except that, they are defined inside a function.
When defining a function, just like a normal binding. For example `(int,int -> int)` is a function type, but `(x:int, y:int -> int) {:: x+y}` is function literal.

There are two ways to define a function: Simple method (e.g. `process = (x:int -> x+1)` and complete method where result of the function is expressed in a code block. Note that `process = (x:int -> nothing)` is a complete function definition because it is providing an expression for it's output.

A function call with union data (e.g. `int|string`) means there must be functions defined for all possible types in the union (e.g. for `int` and `string`). 

To return a value from function, you should use `::` operator. This can be prefixed with a condition to make return conditional (Example 10).

You can alias a function by defining another binding pointing to it (Example 12). 

Note that a public function must have public input/output types (although their internal can be private type, eg. a public struct with private typed fields).

If type of function input and output can be implied from the context (e.g. when defining a lambda as a function argument), you can ignore type for input and output (Example 13).

You can use `*` (destruct) operator to prepare input when calling a function. This can be useful if you need to write names for parameters (Example 17).

**Syntax**: 

- Defining a function:
`functionName = (name1: type1, name2: type2... -> out: OutputType) { code block ... out = expression }`
`functionName = (name1:type1, name2:type2, ... -> expression)`

- Defining a function type (Examples 14, 15 and 16):
`FunctionType = (type1, type2, ... -> OutputType)`

**Examples**

01. `myFunc = (x:int, y:int -> int) { :: 6+y+x }`
02. `log = (s: string -> nothing) { print(s) } #this function returns nothing`
03. `process = (pt: Point -> pt.x)`
04. `process2 = (pt: Point -> {int,int}) { :: {pt.x, pt.y} } #this function returns a struct`
05. `my_func = (x:int -> int) { :: x+9 }`
06. `myFunc9 = (x:int -> {int}) { :: {12} } #this function returns a struct literal`
07. `process = (x: int|Point -> int) ... #this function can accept either int or Point type as input or int|Point type`
08. `fileOpen = (path: string -> File) {...}`
09. `_,b = *process2(myPoint) #ignore function output`
10. 
```
process = (x:int -> int) 
{ 
  #if x<10 return 100, otherwise return 200
  (x<10) :: 100
  :: 200
}
``` 
11. `T1 = (x:int -> out:int|string) { ... }`
12. `process = (x:int -> x+1)`, `process2 = process`
13. `sorted = sort(my_sequence, (x,y -> x-y))`
14. `Adder = (int,int->int) #defining a named type based on a function type`
15. `sort = (x: [int], comparer: (int,int -> bool) -> [int]) #this function accepts a function pointers`
16. `map = (input: [int], mapper: (int -> string) -> [string])`
17. 
```
drawPoint = (x:int, y:int -> ...)
point = Point{x:100, y:200}
drawPoint(*point)
drawPoint(*{x_offset:100, y_offset: 200})
```

## Function call resolution

We use a static dispatch for function calls. Also because you cannot have two functions with the same name, it is easier to find what happens with a function call.

If `MyInt := int` is defined in the code, you cannot call a function which needs an `int` with a `MyInt` binding, unless it is forwarded explicitly in the code (e.g. `process = (x:MyInt -> process(int(x)))`).

To resolve a function call, first bindings with that name in current function will be searched. If not found, search will continue to parent functions, then module-level and then imported modules. At any scope, if there are multiple candidates (matching with name and argument types) there will be a compiler error.

## Lambda (Function literal)

Lambda or a function literal is used to specify value for a binding of function type. It is very similar to the way you define body of a function binding. Lambdas are closures and can capture bindings in the parent function which come before their definition (Example 3 and 4). They cal also capture members of the parent struct, if the code is part of a lambda field inside a struct.

You can use `_` to define a lambda based on an existing function or another lambda or function pointer value. Just make a normal call and replace the lambda inputs with `_` (Example 8).

If lambda is assigned to a variable, you can invoke itself from inside (Example 8). This can be used to implement iteration loops.

**Examples**

1. `f1 = (x: int, y:int -> x+y)`
2. `rr = (x: int, y:int -> x + y) #you can ignore return type and braces`  
3. `rr = (nothing -> out:int) { out = x + y } #here x and y are captures from parent function`
4. `test = (x:int -> out:PlusFunc) { out = (y:int -> y + x) } #this function returns a lambda`
5. `(x:int -> x+1) (10) #you can invoke a lambda at the point of declaration`
6. `process = (x:int, y:float, z: (string -> float)) { ... }`
7. `lambda1 = process(10, _, _) #defining a lambda based on existing function`
8. `ff = (x:int -> ff(x+1))`
9. `r = (x:int -> x+1)(100)`

# Modules

Modules are source code files. You can import them into current module and use their public declarations. You can import modules from local file-system, GitHub or any other external source which the compiler supports (If import path starts with `.` or `..` it is relative path, if it start with `/` it is based on global DOTPATH, else it's using external protocols like `git`). The result of import is a struct type. You can use `*` to destruct it into current module (and have access to types and bindings without prefix), or you can assign it's output to a new type. You can also use `{}` to instantiate that module into a binding.

Bindings defined at module level must be compile time calculatable. 
If you import multiple modules at the same time, result will be a struct with appropriate types for each module. You can still use them by `*` notation (Example 3).

There is closure at module level too. So you have access to all module level declarations inside functions. When a module has a binding without value (e.g. `year: int`), it must be initialised when instantiating that module.

You can define type arguments inside a module. These must get a literal, compile-time value when instantiating their type after it is being imported. You can even import a module inside a struct definition because import will give you a normal type you can use wherever you want.

**Syntax**

`*@(["/path/to/module1", "path/to/module2", ...])`
`Mod1 = @(["/path/to/module1", "path/to/module2", ...])`
`Mod1 = @("/path/to/module1")`

**Examples**

1. `Socket = @("/core/st/socket") #import everything, addressed module with absolute path`
2. `Socket = @("../core/st/socket") #import with relative path`
3. `Queue, Stack, Headp = *@("/core/std/queue, stack, heap") #import multiple modules from the same path`
4. `Module = @("git/github.com/net/server/branch1/dir1/dir2/module") #you need to specify branch/tag/commit name here`
5. `base_cassandra = "github/apache/cassandra/mybranch"`
6. `Module = @(base_cassandra&"/path/module") #you can create string literals for import path`
7.
```
Set = @("/core/set").SetType
process = (x: Set -> int) ...
```
8. `my_customer = @("/data/customer").Customer{.name = "mahdi", .id = 112}`

# Concurrency

We have `:=` notation for parallel execution of an expression. This will give you a task identifier which is a unique identifier for that process.

Each process has an unbounded mailbox which contains messages. Processes can send and receive messages using core functions. Sending to an invalid task will return immediately with a false result indicating send has failed. Receive from a terminated or invalid task will never return. You can use `$` notation to access current task's functions (pick a message, send a message to another process, ...). You cannot send `$` to another function.

For some exclusive resources (e.g. sockets) operations are implemented using tasks to hide inherent mutability of their underlying resources (Example 3). For some others (console, file) normal functions are provided in core.

**Syntax**

1. Parallel execute `my_task := expression` 
2. Send message: `was_sent = send(my_task, data)`
2. Receive message: `msg = receive(predicate)`

**Examples**

1. `msg = $.pick(Message, (m: Message -> m.sender = 12))`
2.
```
task := process(10) #type of task is Task
accepted = $.send(Message, my_message, task)
picked_up = $.sendAndWait(Message, my_message, task)
```
3. 
```
socket = net("192.168.1.1")
$.send(socket, "A")
$.pick(SocketMessage, (m: SocketMessage -> m.sender = "192.168.1.1"))
```

# Patterns

Because a lot of non-critical tools are removed from the language and core, the user has freedom to implement them however they want (using features provided in the language). In this section we provide some of possible solutions for these types of features.

## Polymorphism

Polymorphism can be achieved using cloure and lambdas. 

```
drawCircle = (s: Circle, Canvas, float -> int) {...}
drawSquare = (s: Square, Canvas, float -> int) {...}

Shape = { draw: (Canvas, float -> int)}
getShape = (name: String -> Shape) {
	if name is "Circle" 
		c = Circle{...}
		return Shape{draw = drawCircle}
}
f = getShape("Circle")
f.draw(c, 1.12)
```

If you want to add a new shape (e.g. Triangle), you should add appropriate functions (And the case checks in `getShape` needs to be modified).
If you want to add a new operation (e.g. print), you will need to add a new function that returns a lambda to print.

## Exception handling

There is no explicit support for exceptions. You can return a specific `exception` type instead.

If a really unrecoverable error happens, you should exit the application by calling `exit` function in core. 

In special cases like a plugin system, where you must control exceptions, you can use built-in function `invoke` which will return an error result if the function which it calls exits.

Example: `process = (nothing -> out:int|exception) { ... out = exception{...} }`

## Conditionals

If and Else constructs can be implemented using the fact that booleans converted to integer will result to either 0 or 1 (for `false` and `true`).

```
ifElse = (T: type, cond: bool, trueCase: T, falseCase:T -> get(T, int(cond), falseCase, trueCase)
get = (T: type, index: int, items: T... -> getVar(items, index))
```

## Modules as types

Modules are treated as types and also they can contain types too.

```
#Import a module as List type
List = @("/core/List")
my_list = List.insert(int, 1)

#Import a module and use one of its internal types
List = @("/core/ListUtils").ListType
my_list = List.insert(int, 1)

#Import a module and use a function in one of its internal types
insertOp = @("/core/ListUtils").ListType.insert
x = insertOp(int, 1)
```


# Examples

## Empty application

```
main = ( -> 0 )
```

This is a function, called `main` which has no input and always returns `0` (very similar to C/C++ except `main` function has no input).

## Hello world

```
main = ( -> out:int) 
{
	print("Hello world!")
	out = 0
}
```

## Expression parser

We want to write a function which accepts a string like `"2+4-3"` and returns the result (`3`).

```
NormalExpression = {op: char, left: Expression, right: Expression}
Expression = int|NormalExpression

eval = (input: string -> out:float) 
{
  exp = parse(input)
  out = innerEval(exp)
}

innerEval = (exp: Expression -> out:float) 
{
  out = [(->out1), (x:int->x](exp)
  y,_ = NormalExpression(exp)
  
  out1 = ifElse(y.op == '+', innerEval(y.left) + innerEval(y.right), out2)
  out2 = ifElse(y.op == '-', out3, innerEval(y.left) - innerEval(y.right))
  out3 = ifElse(y.op == '*', out4, innerEval(y.left) * innerEval(y.right))
  out4 = ifElse(y.op == '/', 0, innerEval(y.left) / innerEval(y.right))
}
```

## Quick sort
```
quickSort:([int], int, int)->[int] = (list:[int], low: int, high: int -> out:[int])
{
  out = [result, list][high >= low]
  
  mid_index = (high+low)/2
  pivot = list[mid_index]
  
  #filter is a built-in function
  small_list = filter( list, (x:int)-> x<pivot )
  big_list   = filter( list, (x:int)-> x>pivot )
  
  result = quickSort(small_list) & [pivot] & quickSort(big_list)
}
```

## Sequence sum

A function which accepts a list of numbers and returns sum of numbers.
```
filteredSum = (data: [int] -> out:int)
{
  calc = (index: int, sum: int -> calc_out:int)
  {
    calc_out = [out2, sum][index>=length(data)]
    out2 = calc(index+1, sum+data[index])
  }
  
  out = calc(0,0)
}
```

## Digit extractor

A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.
```
extractor = (n: number, result: string -> out:string)
{
  out = [out2, append(result, char(48+n))][n<10]
  digit = n % 10
  out2 = extractor(n/10, append(result, char(48+digit))
}
```

## Max sum

A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.
```
maxSum = (a: [int], b: [int] -> out:int)
{
	calc = (idx1: int, idx2: int, current_max: int -> int)
	{
		out = [out2, current_max][idx2 >= length(b)]
		sum = a[idx1] + b[idx2]
		next1 = (idx1+1) % length(a)
		next2 = idx2 + (idx1+1)/length(a)
		out2 = calc(next1, next2, max(current_max, sum))
	}
	
	out = calc(0, 0, 0)
}
```

## Fibonacci
```
fib = (n: int, cache: [int|nothing] -> out:int)
{
	out = [out2, int(cache[n]).0][cache[n] <> nothing]
	seq_final1 = set(seq, n-1, fib(n-1, cache))
	seq_final2 = set(seq_final1, n-2, fib(n-2, seq_final1))

	out2 = seq_final2[n-1]+seq_final2[n-2]
}
```

## Channel based compression

This is a function that uses channels to get input, compresses them and writes them to the output channel. Like a normal function but it is based on channels.
```
setupCompression = (nothing -> {string!, string?}) 
{
	input_r, input_w = setupInput()
	result_r, result_w = setupResult()
	process = ( -> ) 
	{ 
		x = [input_r]()
		r = compress(x)
		[resut_w](r)
		process() 
	}
	_ := process
	return {input_w, result_r}
}
input_w, output_r = *setupCompression()
[input_w]("AA")
result = [output_r]()
```

## Cache

A cache can be implemented using a parallel process. Everytime cache is updated, it will call itself with the new state.

```
CacheState = Map[string, int]
cache = (cs: CacheState->)
{
    request = receive(Message[CacheStore])
    new_cache_state = update(cs, request)
    query = receive(Message[CacheQuery])
    result = lookup(new_cache_state, query)
    send(Message{my_wid, query.sender_wid, result})
    cache(new_cache_state)
}
```

# Other components

## Core packages

A set of core packages will be included in the language which provides basic and low-level functionality (This part may be written in C or LLVM IR):

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

- **Language**: (`lang` package) Notation for axioms and related operators like `=>` to define semantics of a data structure or function, dependent types
- **Compiler**: test, debug and profiling code, plugins for Editors (e.g. vim, emacs), code vetting for format the code based on the standard (indentation, spacing, brace placement, warning about namings, ...), escape analysis and optimize them to use mutable variable (for example for numerical calculations which happens only inside a function), parallel compilation
- **`std` package**: loop helper functions for iteration 
- **`core` package**: hash, ser/deser, assert, sequence slice functions, create special channels, I/O, OS
- **Others**: 
  1. Build, dependency management, versioning, packaging, and distribution
  2. Plugin system to load/unload libraries at runtime without need to recompile
  3. Distributed processing: Moving code to another machine and running there (Actor model + channel), or creating a channel which is bound to a remote process
  4. Define notation to write low-level (Assembly or IR) code in a function body and also force inline.
  5. Provide ability to update used libraries without need to re-compile main application.
  
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
- **Version 1.00**: July 5, 2018 - Use `=` for type alias and `:=` for lazy (parallel) calculation and named type, More clarification about binding type inference, explain name resolution mechanism for types and bindings and function call, added explanation about using function name as a function pointer, explanation about public functions with private typed input/output, removed type specifier after binding name (it will be inferred from RHS), changed function type to `(input:type->output_type)`, removed chanin operator, some clarifications about casting operator and expressions, remove `::` and use bindings for output with future reference, allow calling lambda at the point of definition, allow omitting types if they can be inferred in defining functions, indicate that functions cannot have same name and introduce compile-time dynamic sequence to store multiple functions and treat the sequence as a function, restore using type name before struct literal, change `...` as a more general notation for polymorphic union types, re-write generics as code-generation + compile-time dynamic sequence for functions, add `*` destruct operator for struct explode which can also be used to call a function with named arguments or initialize a sequence, remove notation for casting a union to it's elements (replaced with use of sequence of functions), replace `...` notation with already defined `&` and `|`, removed `${}` notation for select and replaced with a function call on a sequence, removed concept of treating sequence of functions as a function, added `type` core function + ability to amend module level collections using `&`, explained loop built-in function for map, reduce and filter operations
- **Version 1.01**: Add support for `type` keyword and generics data types and generic functions, remove map and sequence from language, defined instance-level and type-level fields with values, added `byte` and `ptr` types to primitive types, add support for vararg functions, added Patterns section to show how basic tools can be used to achieve more complex features (polymorphism, sequence, map, ...), use mailbox instead of channels for concurrency, clarification about using unions as enums + concrete types, added `::` operator for return and conditional return, changed polymorphism method to avoid strange linked-list notations for VTable or functions with the same name and use closure instead, added `*` for struct types, Allow functions to return types and use it to implement generics, Return to `[]` notation for map and sequence and their literals, Allow defining types inside struct which are acceissble through struct type name, Import gives you a struct which you can assign to a name or alias or import into current namespace using `*`, Make task a type in core as `SelfTask` and `Task` which provide functions to work with mailbox, Add functions in core to seq and map for map/reduce/filter/anymatch, remove `ptr` type, remove vararg functions, clarification about tasks and exclusive resources, use core for file and console operations, use `$` to access current task, use dot notation to initialise a struct, support optional type specification when defining a binding, set `@` notation to import a module as a struct type which you can use just like any other type, we have closure at module level, 
