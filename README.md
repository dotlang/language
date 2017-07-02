# dot Programming Language Reference

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
- **Version 0.95**: May 23, 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to speciying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow opertor overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numberic types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (`^` and `%`).
- **Version 0.96**: June 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.97**: June 26, 2017 - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` placeholder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is types statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`.
- **Version 0.98**: ?? ??? ???? - remove `++` and `--`, implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to dot, add `$` prefix for untyped tuple literals to make it more readable, added `switch` and `while` keywords, renamed `loop` to `for`

# Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: dot (or dotLang). 

dot programming language (or dotLang for short) is an imperative, static-typed, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Elm, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from functional approach.

Three main objectives are pursued in the design of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few things are done implicitly and transparently by the compiler or runtime system. Also I tried to reduce need for nested blocks and parentheses as much as possible.
2. **Expressiveness**: It should give enough tools to the developer to produce readable and maintainable code. This requires a comprehensive standard library in addition to language notations.
3. **Performance**: The compiler will compile to native code which will result in high performance. We try to do as much as possible during compilation (optimizations, de-refrencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, ...) so during runtime, there is not much to be done except mostly for memory management. Where performance is a concern, the corresponding functions in standard library will be implemented in a lower level language.

Achieving all of the above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  We have functions and types. Each function acts on a set of inputs and gives an output. Type system includes primitive data types, tuple, union, array and map. Polymorphism, template programming and lambda expression are also provided and everything is immutable.

## Comparison with other languages

**Compared to C**: C language + Garabage collector + first-class functions + template programming + better union data types + module system + flexible polymorphism + simple and powerful standard library + lambda expressions + closure + powerful built-in data types (map, string,...) + simpler primitives + multiple dispatch + sane defaults + full immutability - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + full immutability + simpler primitives - dependency on JVM - cryptic syntax - trait - custom operators - variance - implicit.

**Compared to Go**: Go + generics + full immutability + multiple dispatch + union types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives - pointers - interfaces - global variables.

## Components

dotLang consists of these components:
1. The language specification (this document)
2. A command line tool to compile, debug and package applications
3. Runtime system: Responsible for memory allocation and management, interaction with the Operating System and other external libraries and handling concurrency.
4. Core library: This package is used to implement some basic, low-level features which can not be simply implemented using pure dotLang language.
5. Standard library: A layer above runtime and `core` which contains some general-purpose and common functions and data structures.

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
In the above examples `/core, /core/sys, /core/net, /core/net/http, /core/net/tcp` are all packages.
- Unlike many other languages, modules are stateless. Meaning there is no variable or static code defined in a module-level.

## General rules
- **Encoding**: Modules are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored. 
- **Indentation**: Indentation must be done using spaces, not tabs. Using 4 spaces is advised but not mandatory.
- **Comments**: `//` is used to start a comment.
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number. You can separate digits using undescore: `1_000_000`.
- **Terminator**: Each statement must be in a separate line and must not end with semicolon.
- **Order**: Each source code file contains 3 sections: import, definitions and function. The order of the contents of source code file matters: `import` section must come first, then declarations and then functions come at the end. If the order is not met, compiler will give errors.
- Import section is used to reference other modules that are being used in this module.
- Definitions section is used to define data types.
- Function section is used to define function bodies.
- **Adressing**: Modules are addressed using `/` notation (e.g. `/code/st/net/create_socket`). Where `/` denotes include path.
- **Encapsulation**: If a name (of a type or function) starts with underscore, means that it is private to the module. If not, it is public.
- **Naming**: (Highly advised but not mandatory) `someFunctionName`, `my_var_name`, `SomeType`, `my_package_or_module`. If these are not met, compiler will give warnings. Primitive data types and basic types defined in core (`bool`, `string` and `nothing`) are the only exceptions to naming rules.

## Language in a nutshell
01. **Import**: `import /core/std/queue`.
02. **Primitives**: `int`, `float`, `char`, `union`, `array`, `map` (Extended primitives: `bool`, `string`, `nothing`).
03. **Values**: `my_var := 19` (type is automatically inferred, everything is immutable).
04. **Named type**: `type MyInt := int`
05. **Tuple**: `type Point := {x: int, y:int, data: float}`.
06. **Tuple value**: `location := Point{ x:=10, y:=20, data:=1.19 }`
07. **Composition**: By embedding (only for tuples), `type Circle := {Shape, radius: float}`.
08. **Generics**: `type Stack[T] := { data: array[T], info: int }`.
09. **Array**: `jobQueue := [0, 1, 2, 3]` (type is `array[int]`).
10. **Map**: `countryPopulation := [ "US" => 300, "CA" => 180, "UK" =>80 ]` (type is `map[string, int]`).
11. **Union**: `type Maybe[T] := union[nothing, T]`.
12. **Function**: `func calculate(x: int, y: string) -> float { return if x > 0 then 1.5 else 2.5  }`.
13. **Lambda**: `adder := |x:int, y:int| -> x+y`.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Type System

## Declaration

**Semantic**: Used to declare a unique name and assign an expression to it.

**Syntax**: `identifier := expression`

**Examples**

1. `x := 12`
2. `g := 19.8`
3. `a,b := process()`
4. `x := y`

**Notes**

1. `expression` can be a literal, function call, another variable or a combination.
2. Everything is immutable.
3. You can however re-assign a name to a new value using `=` notation (Refer to operator section).
4. Example 1 defines a variable called `x` which is of type `integer` and stores value of `12` in it.
5. Compiler automatically infers the type of variable from expression.
6. (Recommendation) Put a single space around `:=`.
7. You can explicitly state type by using `Type{expression}` syntax.
8. If right side of `:=` is a tuple type, you can destruct it's type and assign it's value to different variables (Example 3). See Tuple section for more information.
9. Declaration makes a copy of the right side if it is a simple identifier (Example 4). So any future change to `x` will not affect `y`.

## Assignment

**Semantics**: To make a copy of result of an expression and assign it to a pre-declared identifier.

**Syntax**: `identifier = expression`

**Examples**

1. `x = 10`
2. `x = y`
3. `x = y + 10 - z`
4. `x = func1(y) + func2(z) - 10`
5. `x,y := func6()`

**Notes**:

1. `identifier` must be previously declared using `:=` notation.
2. Type of expression in assignment, must be the same as original type of the identifier.
3. Note that you cannot change current value of an identifier, but you can use `=` to assign a new value to it.
4. You can use `=` to do multiple assignment if right side is a function call which returns a tuple. See Functions section for more information.
5. If right side of `:=` is a tuple type, you can destruct it's type and assign it's value to different variables (Example 5). See Tuple section for more information.

## Primitives

**Semantics**: Provide basic feature to define most commonly used data types.

**Syntax**: `int`, `float`, `char`, `union`, `array`, `map`

**Examples**

1. `x := 12`
2. `x := 1.918`
3. `x := 'c'`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. For `union`, `array` and `map` types, refer to the next sections.

## Label types

**Semantics**: To define types that have only one value: Their name. These types are useful as part of a union.

**Syntax**: `type LabelName`

**Examples**

1. `type true`
2. `type Saturday, Sunday, Monday`
3. `type nothing`
4. `g := nothing`
5. `if ( x == nothing ) ...`

**Notes**

1. You can define multiple label types at once (Example number 3).
2. Labels types are a special kind of named types which are explained in the corresponding section.

## Union

**Semantics**: A primitive meta-type to provide same interface which can contain different types.

**Syntax**: `union[type1, type2, ...]`

**Examples**

1. `var day_of_week: union[SAT, SUN, MON, TUE, WED, THU, FRI]`
2. `int_or_float := unon[int, float]{11}`
3. `int_or_float = 12.91`
4. `int_or_float = 100`
5. `has_int := typeOf(int_or_float) == @int`
6. `int_value, has_int := int{int_or_float}`
7.
```
stringed := switch ( int_or_float ) 
{
    x:int -> ["int" , toString(1+x)],
    y:float -> "is_float",
    else: "Not_int"
}
```

**Notes**

1. `union` is a meta-type which can take form of different data types. It uses generic programming features which are explained in corresponding section. For more information refer to the next section.
2. Types inside union definition must be named types. Refer to corresponding section.
3. Example number 1 shows usage of label types to define an enum type to represent days of week.
4. Example 2, defines a union variable with explicit type and changes it's value to other types in next two examples.
5. Example 5, uses `typeOf` function to check if there is an integer type inside previously defined union variable.
6. You can use the syntax in example 6 to cast a union to another type. It will also give a boolean to indicate if the casting was successful.
7. Example 7, uses `switch` expression to check and match for type of data inside union.
8. `union[int, union[float, string]]` will be simplified to `union[int, float, string]`

## Array

**Semantics**: Define a fixed-size sequence of elements of the same type.

**Syntax**: `array[type]`

**Examples**

1. `arr := $[1, 2, 3]`
2. `g := arr(0)` or `g := get(arr, 0)`
3. `new_arr := set(arr, 0, 10)`
4. `new_arr2 := set(arr, [0,1,2], [4,4,4])`
5. `two_d_array := [ [1,2,3], [4,5,6] ]`
6. `p := two_d_array(0)(0)`
7. `arr2 := [0..10]`
8. `arr := array[int]$[1, 2, 3]`

**Notes**

1. Above examples show definition and how to read/update array.
2. In example 7, the range operator `..` is used to generate an array literal.
3. You can explicitly state array literal type like in example 8.
4. A `$` sign must prefix array literals.

## Slice

**Semantices**: Represents an array which maps to a limited view into an existing array.

**Syntax**: `array(start, end)`

**Examples**

1. `arr := [1..9]`
2. `slice1 := arr(1, 2)`
3. `slice2 := arr(0, -1)`

**Notes**

1. Example 2 will give a slice which contains `2, 3`.
2. Example 3 will give a slice which contains all elements. End parameter can be negative which is counted from end of the array (`-1` means last element). Same for start.

## Map

**Semantics**: Represent a mapping from key to value.

**Syntax**: `map[key, value]`

**Examples**

1. `my_map := $["A"=>1, "B"=>2, "C"=>3]`
2. `item1 := my_map("A")`
3. `map2 := set(my_map, "A", 2)`
4. `map3 := delete(map2, "B")`
5. `my_map := map[string,int]$["A"=>1, "B"=>2, "C"=>3]`

**Notes**

1. You need to use core functions to manipulate a map, because (like everything else), they are immutable.
2. If you query a map for something which does not exist, it will return `nothing`.
3. You can explicitly state type of a map literal like example 5.
4. A `$` sign must prefix map literals.

## Extended primitives

**Semantics**: Built on top of primitives, these types provide more advanced data types.

**Syntax**: `bool`, `string`, `nothing`

**Examples**

1. `g := true`
3. `str := 'Hello world!'`

**Notes**

1. `string` is defined as an array of `char` data type. The conversion from/to string literals is handled by the compiler.
2. String literals should be enclosed in double quotes. 
3. String litearls enclosed in backtick can be multi-line and escape character `\` will not be processed in them.
4. `nothing` is a label type which is used in union types, specially `maybe` type.
5. `bool` type is a union of two label types: `true` and `false`.

## Type alias

**Semantics**: To define alternative names for a type.

**Syntax**: `type NewName = CurrentName`

**Examples**

1. `type MyInt = int`

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
4. `type bool := union[true, false]`
5. `x := MyInt{10}`, `y := MyInt{x}`

**Notes**

1. There must be a single space between `type` and type name.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. Although their binary data representations are the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to corresponding section for more information.
4. You can use casting operator to convert between a named type and it's underlying type (Example 5).
 
## Tuple

**Semantice**: As a product type, this data type is used to defined a set of coherent variables of different types.

**Syntax**: 

1. Type declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. Literal: `Type{field1:=value1, field2:=value2, field3:=value3, ...}` 
3. Untyped literal: `${field1:=value1, field2:=value2, field3:=value3, ...}` 

**Examples**

1. `type Point := {x:int, y:int}`
2. `point := ${x:=100, y:=200}`
3. `point := ${100, 200}`
4. `point := Point{x:=100, y:=200}`
5. `point := Point{100, 200}`
6. `x,y := point`
7. `x,y := ${100,200}`
8. `another_point := point{x:=11, y:=point.y + 200}`
9. `new_point := {a:100, b:200} //WRONG!`

**Notes**

1. Field names are not mandatory when defining a tuple literal.
2. `$` prefix is used as an indicator to indicate a tuple litera without type.
2. Example 1 defined a named type for a 2-D point and next 4 examples show how to initialise variables of that type.
3. Examples 6 and 7 show how to destruct a tuple and extract it's data.
4. Example 8 shows how to update a tuple and create a new tuple.
5. Example 9 indicates names should match with the expected type.

## Composition

**Semantics**: To include (or embed) the data defined in another tuple type.

**Syntax**: `{Parent1Type, field1: type1, Parent2Type, field2: type2, Parent2Type, ...}`

**Examples**
1. `type Shape := { id:int }`
2. `type Circle := { Shape, radius: float}`
3. `my_circle := Circle{id=100, radius=1.45}`
4. `type AllShapes := union[Shape]`
5. `someShapes := AllShapes[myCircle, mySquare, myRectangle, myTriangle]`

**Notes**
1. In the above example, `Shape` is the contained type and `Circle` is container type.
2. The language provides pure "contain and delegate" mechanism as a limited form of polymorphism.
3. A tuple type can embed as many other tuple types as it wants and forward function calls to embedded tuples. Refer to function section for more information about forwarding functions.
4. You can define a union type which accepts all tuple types which embed a specific tuple type. See examples 4 and 5.
5. Note that polymorphism does not apply to generics. So `array[Circle]` cannot substitute `array[Shape]`. But you can have `array[union[Circle, Square]]` to have a mixed array of different types.
6. We use closed recursion to dispatch function calls. This means if a function call is forwarded from `Circle` to `Shape` and inside that function another second function is called which has candidates for both `Circle` and `Shape` the one for `Shape` will be called.

## Casting

**Semantics**: To change type of data without changing the semantics of the data

**Syntax**: `Type{identifier}`

**Examples**

1. `x := int{1.91}`
2. `int_value, has_int := int{int_or_float}`
3. `type MyInt := int`
4. `x := MyInt{100}`
5. `y := int{x}`

**Notes**
1. There is no implicit and automatic casting in the language.
2. Casting is mostly used to cast between a union and it's internal type (Example 2) or between named and equal unnamed type (Example 4 and 5).
3. If function expects a named type, you cannot pass an equivalent unnamed type. 
4. Similarly, when a function expects an unnamed type, you cannot pass a named type with same underlying type. 
5. Another usage of casting is to cast between `int` and `float` and `char` (Example 1).

# Functions

## Declaration

**Semantics**: To group a set of coherent commands into a group with a specific name, input and output.

**Syntax**: `func functionName(input1: type1, input2: type2, ...) -> OutputType { code block }`

**Examples**

1. `func myFunc(y:int, x:int) -> int { return 6+y+x }`
2. `func log(s: string) -> { print(s) }`
3. `func process(pt: Point)->int { return pt.x }`
4. `func process2(pt: Point) -> ${pt.x, pt.y}`
5. `func my_func8() -> {x:int, y:int} { return ${10,20} }`
6. `func my_func(x:int) -> x+9`
7. `func myFunc9(x:int) -> {int} ${12}`
8. `func PI -> 3.14`
9. `func process(x: union[int,Point])->int`


**Notes**:

1. Every function must return something. If it doesn't compiler marks output type as `nothing` (Example 2).
2. A function call with union data, means there must be functions defined for all possible types in the union. See Call resolution section for more information.
3. You can define consts using functions (Example 6).
4. There must be a single space between func and function name.
5. You can omit function output type and let compiler infer it, only if it has no body (Examples 4, 6 and 8).
6. You can omit braces and `return` keyword if you only want to return an expression (Examples 4, 6, 7 and 8).
7. Each function must have an output type. Even if it does not return anything, output type will be `nothing`.
8. Function output can be tuple type with or without field names (Examples 5 and 7).
9. You can define variadic functions by having an array input as the last input. When user wants to call it, he can provide an array literal with any number of elements needed.
10. The function in example 9 will be invoked if the input is either `int` or `Point` or `union[int, Point]`.
11. There should not be ambiguity when calling a function. So having functions on examples 9 and 3 in same compilation is invalid.

## Invocation

**Semantics**: Execute commands of a pre-declared function.

**Syntax**: `output = functionName(input1, input2, ...)` or `output := ...`

**Examples**

1. `pi := PI()`
2. `a,b := process2(myPoint)`
3. `_,b := process2(myPoint)`
4. `tuple1 := myFun9();`

**Notes**

1. You can use `_` to ignore a function output (Example 3).
2. Parentheses are required when calling a function, even if there is no input.

## Call forwarding

**Semantics**: To forward a function call to another function, used to implement subtyping.

**Syntax**: `func funcName(type1->type2, type3, type4->type5, ...)`

**Examples**

1. `func draw(Circle->Shape)`
2. `func process(union(Polygon, Square, Circle)->Shape, union[GradientColor, SolidColor]->Color)`
3. `func process(float, union[Shape]->Shape, string, int, union[GradientColor,SolidColor]->Color, int)`

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
3. `adderPointer := adder{myAdder}`
4. `func sort(x: array[int], comparer: func(int,int) -> bool) -> array[int]`
5. `func map[T, S](input: array[T], mapper: func(T) -> S) -> array[S]`

**Notes**

1. Example 4 indicates a function which accepts a function pointer.
2. Example 5 indicates the definition for a mapping function. It is using template programming features introduces in the corresponding section.
3. Value of a function pointer can be either an existing function or a lambda. Refer to corresponding section for more information.
4. In a function type, you should not include input parameter names.


===================

## Lambda

**Semantics**: Define function literals of a specific function pointer type, inside another function's body.

**Syntax**: `|name1: type1, name2: type2, ...| -> expression | body`

**Examples**

1. `f1 := |x: int, y:int| -> { return x+y }` ;the most complete definition
2. `rr := |x: int, y:int| -> x + y`  ;return type can be inferred
var rr = { x + y } ;WRONG! - input is not specified
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition

type adder := (x: int, val y:int) -> var:int
var rr: adder = (a:int, b:int) -> { a + b } ;when you have a type, you can define new names for input
var rr: adder = (x,y) -> x + y   ;when you have a type, you can also omit input
var rr: adder = (x,y) -> int { return x + y }      ;and also func keyword, but {} is mandatory
var rr:adder = (x,y) -> x + 2      
func test(x:int) -> plus2 { return (y) -> y+ x }
var modifier = (x:int, y:int) -> x+y  ;if input/output types can be deduced, you can eliminate them


**Notes**
1. You should not specify output type for a lambda.
2. If a lambda captures a value in the parent function, that value cannot be re-assigned. Compiler will detech this. This is to prevent possible data race in which case, a data is modified outside a thread (which is the closure) while the code inside the thread is reading it. Use channels to communicate between threads.



A lambda variable can omit types because they can be inferred: `var x: comparer = |x,y| -> ...`
A function literal which does not have a type in the code, must include argument name and type. `|x:int|->int { return x+1 }(10)` or `var fp = |x:int|->int { return x+1}`

- closure capturing: It captures outside vars and vals. Can change vars.
- Even if a lambda has no input/output you should write other parts: `() -> { printf("Hello world" }`
You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too, also  `func` keyword is not needed. The essential part is input and `->`.
If you use `{}` for the body, you must specify output type and use return keyword.
```
```
- Lambdas have read-only access to free variables in their parent semantic scope.
- Function pointers cannot take part in method dispatch. They must point to a specific function. This is specified using their type. 
- Another way to forward a call to another function but without loosing dynamic type:
```
func process(c: Circle) -> int {
;you cannot infer type from a function name, unless there is only one function with that name
 var f: func(s: Shape) = process 
 var g = process ;this is wrong
 return f(c)
}
```

`var g: func(x:int)->int...`
`var g: func[T](x:T)->T...`
`var g: func[T:Stringer](x:T)->T...`
`g("A") g(2) g(1.2)`
- You can use `_` as a shortcut to define a lambda:
If we have `func f(int,int,int)->int` then:
`var t = f(a1, a2, _)` is same as `var t: func(int)->int = (x:int) -> f(a1, a2, x)`
- Lambdas can also use protocols in their type or their value definition.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Generics
- This is a function that accepts an input of any type and returns any type: `type Function[I,O] := func(I)->O`.

- Compiler will scan body of generic functions and extract their expected methods. If you call them with inappropriate types, it will give you list of required methods to implement.
- Note that a generic function can only have generic types. About immutability or mutability, it cannot be generic. The function signature is responsible about defining whether an argument should be immutable or mutable or doesn't care. Also same for types. You cannot have mutability or immutability as a generic argument.
- Generic arguments can only be types.
- When defining types, you can append `[A, B, C, ...]` to the type name to indicate it is a generic type. You can then use these symbols inside type definition.
- When defining functions, if input or output are of generic type, you must append `[A,B,C,...]` to the function name to match required generic types for input/output. 
- When you define a variable or another type, you can refer to a generic type using it's name and concrete values for their types. Like `Type{int, string]`
- Generic functions, must make use of their type argument in their input.
```
type Map[K,V] := K => V
type Stack[T] := array[T]  ;define base type for generic type
func push[T](s: Stack[T], x: T)
func push[int](s: Stack[int], x: int) ;specialization
func pop[T](s: Stack[T]) -> T
func len[T](s: Stack[T]) -> int   ;general function for all instances
var t : Stack[int]
var h : Map[int, string]
push(t, 10) ;same as push[int](t, 10)
var y = pop(t)
x = len(t)
```
`type optional[T] := Nothing | T`
`type Packet[T] :=   {status: T[], result: (x:int, y:int))`
`type IPPacket := Packet[int]`
`type Tree[T] := {x: T, left: Tree[T], right: Tree[T]}`
`type ShapeTree := Tree[Shape]`
Example:
`func push[T](x: Stack[T], y: T)`
`func push(x: Stack[int], y:int)`
if we call `push(a,6)` and `a` is `Stack[int]` second function will be called because there is full match.
if we call `stack[int](a, b)` still the second one will be called.
- When calling a generic function, you can omit type specifier only if it can be deduced from input. If not, you must specify input.
Example: `func process[T](x: int) -> T`
`process(10)` is wrong. You must specify type: `var g: string = process[string](10)`
- If some types cannot be inferred from function input, you must specify them when calling the generic function.
```
type DepValue[T] := (value:T)
func magic[T](that: DepValue[T])->T that.value
var x = %DepValue[int](1) ;x is int
var y = %DepValue[string]("a") ;y is string
var xx: int = magic(x)
var yy: string = magic(y)
```

For generic functions, any call to a function which does not rely on the generic type, will be checked by compiler even if there is no call to that generic function. Any call to another function relying on generic argument, will be checked by compiler to be defined.

## Phantom types
Phantom are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. Here labels are implemented using generic types which are not used for data allocation. For example we have a string which is result of md5 hash and another for sha-1. We should not be comparing these two although they are both strings. So how can we mark them?

```
type HashType := MD5 | SHA1
 ;when generic type is not used on the right side, it will be only for compile time check
type HashStr[T] := string     
type Md5Hash := HashStr[MD5] 
;Md5Hash type can be easily cast to string, but if in the code a string
;is expected to be of type Sha1Hash you cannot pass Md5Hash
type Sha1Hash := HashStr[SHA1]
func md5(s: string)->Md5Hash {
    var result: string = "ddsadsadsad"
    return %Md5Hash(result)  ;create a new string of type md5-hash
}
func sha1(s: string)->Sha1Hash
var t: Md5Hash  = sha1("A")  ;will give compiler error because output of sha1 is Sha1Hash
func testMd5(s: string, t: Md5Hash) -> md5(s) == t

;if there is only one case, you can simply use named type
type SafeString := string
func processString(s: string)->SafeString
func work(s: SafeString)

;another example: expressions
type ExpType := INT | STR
type Expression[T] := (token: string)
func readIntExpression(...) -> Expression[INT]
func plus(left: Expression[INT], right: Expression[INT])...
func concat(left: Expression[STR], right: Expression[STR])...

;door
type DoorState := Open | Closed
type Door[T] := (string)
func closeDoor(x: Door[Open]) -> Door[Closed]
func openDoor(x: Door[Closed]) -> Door[Open]
```

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Notations

## Operators
- Conditional: `and or not == != >= <= => =<`

- Math: `+ - * % %% (is divisible) **`
- There is no `++` and `--` operators.
- The math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies data.
- `:=` opreator will make left side point to right-side variable or result of evaluation of the right-side expression.
- `x == y` will compare two variables field by field.
- We don't have operators for bitwise operations. They are covered in core functions. 
- Assignment semantics: `x=y` will duplicate contents of y into x (same as `*x=*y` in C++). So if rvalue is a temp variable (e.g. `x=1+y`), it will be a ref-assign handled by the compiler. If you want to ref-assign you should use `:=` notation. Note that for assignment lvalue and rvalue must be of the same type. You cannot assign circle to Shape because as copy is done, data will be lost (you can refer to `.Shape` field in the Circle).
`x=y` will duplicate y into x. So changes on x won't affect y. 
- Comparison semantics: `x==y` will compare data.
- Type-id (`@`): returns type-id of a named or primitive type: `@int`
- To cast from named to unnamed type you can use: `Type{value}` notation: `y = int{x}`
- For union: `x=union[int,float]{12}`
- chaining: 
`A . F(_)` (not to spaces around the dot) will be translated to `F(A)`. right side of dot must be either a closure or a tuple with underscores for substitition.
`${x,y,z} . ${_,_,_}` becomes `${x,y,z}`. A tuple litearl without field names. You can extract it's data, use it in a chaining or send it to a function which expects a tuple with same size and type.
`finalResult := pipe(input, check1(5,_)) . pipe(_, check3(1,2,_)) . pipe(_, check5(8,_,1))`
`finalResult := {input, check1(5, _)} . pipe(_,_) . pipe(_, check3(1,2,_)) . pipe(_, check5(8,_,1))`
`finalResult := ${input, check1(5, _)} . pipe(_,_) . ${_, check3(1,2,_)} . pipe(_, _) . ${_, check5(8,_,1) } . pipe(_,_)`
`g := {5,9} . add(_, _)`
`g := 5 . add(_, 9)`
`{1,2} . processTwoData(_, _)` calling function with two inputs (1 and 2).
`{1,2} . processTuple(_)` calling function with a single argument of type tuple.
`data := array1(10).default(_, 0)`
`data := circle . process(_)` ~ `process(circle)`
`data := circle . process()` calling a function pointer which is a field inside circle tuple
`data := circle . process` accessing `process` field inside `circle` tuple
`default` function in core will return second argument if first one is nothing. if `map["A"]` is not nothing, the expression will evaluate to `map["A"]`
on the right side of dot, you can have a tuple with underscore which will be filled based on the left side.
`{1,2}.{_, _, 5}` will be `{1, 2, 5}`
`{1,2}.{_, 5}` will be `{ {1, 2} , 5}`
`{1,2}.{_, _, 5}.process(_,_,_)` will become `process(1,2,5)`.
`{1,2}.{_, _, 5}.process(_,_)` is error. left of dot we have a tuple with 3 elements. So on the right side we should either have one or three expected inputs.


### Special Syntax
- `@`  type-id
- `$`  tuple literal
- `_`  placeholder for lambda or unknown variable in assignments
- `:`  type declaration for tuple and function input, switch
- `:=` custom type definition, variable declaration, tuple literal, for
- `=`  type alias, copy value
- `=>` map literals and block-if
- `..` range generator
- `->` function declaration, switch for union
- `[]` generics, array and map literals
- `{}` code block, tuple definition and tuple literal
- `()` function declaration and call, read from array and map
- `||` lambda declaration
- `.`  access tuple fields, function chaining

Keywords: `import`, `func`, `return`, `type`, `if`, `then`, `else`, `for`, `do`, `switch`, `while`
Primitive data types: `int`, `float`, `char`, `union`, `array`, `map`
Pre-defined types: `bool`, `string`, `nothing`
Important concepts: ExclusiveResource

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

### switch
```
y = switch x 
{
    1: "G",
    2: "H",
    3: "N",
    else: "A"
}
```
To type match for a union:
```
y = switch x
{
    g:int -> 1+g,
    s:string -> 10,
    else -> "X"
}
```

###if, else
- You can use `if/then/else` block as an expression.
- If/else are keywords so their blocks can freely access and re-assign local variables.
- You can use if/else as an expression: `a=if cond then 1 else 2`
```
IfElse = 'if' '(' condition ')' then Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
- Semantics of this keywords are same as other mainstream languages.
- If block is a single statement in one line, you dont need braces.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.
`var max = if x > y then x else y`

```
  if exp1 and exp2 then 11 else -1
```
- `a=xyz if(cond)` is also possible.
`a=(cond)[true=>xyz, false=>a]`
- But if `if` is used as a suffix to a statement, it won't be translated to map lookup:
`return 1 if x`

### Exclusive resource
??? Note that using `=` for resources (like threads or files) will not create new resource. Just create new variables pointing to the same resource.

 every tuple that embeds `ExclusiveResource` is treated like an exclusive resource.
If some data type represents a resource which needs to be handled only by one function or thread at time, it's type must embed with `ExclusiveResource` (for example file handle, db connection, network socket, ...). These types are not supposed to be shared because of their inherent mutability. This protocol has a single `dispose` function to release the resource.
These types have some properties which are enforced by the compiler:
1. Any function which creates them, has to either call dispose on them or pass them to another function.
2. Any function that has an input of their type, must either call dispose or pass it to another function.
3. Any use of them after being passed to another function is forbidden.
4. Closures cannot capture them (but you can pass resources to them).
```
type FileHandle := {ExclusiveResource, handle: int}
func closeFile(x:FileHandle)->bool { ... }
f = openFile(...) 
...
closeFile(f)
```
- If the resource is part of a union, there must be appropriate `dispose` function for other types in the union, so that a call to `dispose` on that union will be guaranteed to work.

### assert (removed)
- `Exception` is a simple tuple defined in core. 
- You can use suffix if for assertion: `return xyz if not (str.length>0)`
- To handle exceptions in a code in rare cases (calling a plugin or another thread), you can use `invoke` core function.
`func invoke[I,O](f: func, input: I)->O|Exception`. If your function has more than one input, you should define a wrapper function or a closure which has one input of type tuple.
`var finalResult: Maybe[int] = input >> check1(5, _) >> check2(_, "A") >> check3(1,2,_)`

- **Nothing**: Nothing is a label type with only one value: `nothing`.
 You can use it's type for return value of a function. If a function does not return anything, it returns `nothing`.

## import

This can be used to resolve conflict types when importing modules.
`type Stack1 = /core/mode1/Stack`
`type Stack2 = /code/mode2/Stack`
`type S[T] = Stack[T]`
`type ST = Stack[int]`

- Exaplein how type alias can be used.
- There must be a single space between `import` keyword and it's contents.
You can import a source code file using below statement. Note that import, will add symbols (functions and types) inside that source code to the current symbol table:
- You can only import one module in each import statement (No wildcard).

```
;Starting a path with slash means its absolute path (relative to include path). Otherwise it is relative to the current file
import /core/st/Socket  ;functions and types inside core/st/Socket.e file are imported and available for call/use
import /core/st/Socket/ ;if you add slash at the end, it means import symbols using fully qualified name. This is used for refering to the functions using fully qualified names. Functions imported with this method won't be used in method dispatch mechanism.
```
It is an error if as a result of imports, there are two exactly similar functions (same name, input and output). In this case, none of conflicting functions will be available for call. 
The paths in import statement are relative to the runtime path specified for libraries.
In case of conflicting function names, you can get a function point to another function in another module without importing it.
`func myFunc(x:int) -> /core/pack2/myFunction;`
So when `myFunc` is called, it will call another function with name `myFunction` located in `/core/pack2` source file.
Note that you must have imported the module before.
Also you can call a function or refer to a type with fully qualified name:
`var x: int = /core/pack2/myFunction(10, 20);`
`var t: /core/pack2/myStruct;`
- By default, `import` works on local file system but you can work on other types too:
`import /a/b` import from local file system
`import file:/a/b` import from local file system
`import git:/github.com/adsad/dsada` import from github
`import /core/std/{ab, cd, ef}` to import multiple modules

### native
`type array[T] := {...}`

Denotes function is implemented by runtime or external libraries.
`func file_open(path: string) -> File {...}`
`type Test := {...}`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><


## Examples
### Empty application
```
func main() -> 
{
    return 0 
}
```
or even simper: `func main() -> 0`

This is a function, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

### Hello world
### Quick sort
### Graph class
### Expression parser
We want to write a function which accepts a string like "2+4/3" and returns result (2)
```
type Expression := int | (op: char, left: Expression, right: Expression)
func eval(input: string) -> float 
{
  var exp: Expression = parse(input)
  return innerEval(exp);
}
func innerEval(exp: Expression) -> float 
{
  return exp @
  {
    x:int -> x,
    (op: char, left: Expression, right: Expression) -> op @
    {
      '+' -> innerEval(left) + innerEval(right),
      '-' -> innerEval(left) - innerEval(right),
      '*' -> innerEval(left) * innerEval(right),
      '/' -> innerEval(left) / innerEval(right),
    }
  }
}
```

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


### for, while
This is a keyword:
`loop var := exp do block`
var must not declared before. it will be declared here and only valid inside loop block.

```
while x>0 do printf(x)
while x>0 do {
...
}
while true do ...
for x     := [2..10] do printf("Hello world")
for item  := my_array do printf(item)
for g     := my_iterable do ...
for g     := my_iterable do {
...
}
for {x,y} := [2..10], [1..9] do printf("Hello world " +x +y)
```
You can also use iterator type with loop:
```
type Iterator[T] := {...}
iterator := getIterator(myBitSet)
for g <- iterator do ...
```
there is no break or continue. You should implement them as condition inside loop block or inside loop exp.
- If expression inside loop evaluates to a value, `loop` can be used as an expression:
??? `var t:int[] = loop(var x <- {0..10}) x` or simply `var t:int[] = loop({0..10})` because a loop without body will evaluate to the counter, same as `var t:array[int] = {0..10}`

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
- Introduce caching of function output
- Build, versioning, packaging and distribution
- Dependency definition and management 
- Plugin system to load/unload libraries at runtime
- Debugger and plugins for Editors
- Atomic operations, mutex and other locking features.
- Testing facilities
- Define a notation to access a location inside a binary and sizeof function
- Actor/Message passing helpers for concurrency.
- Helper functions to work with binary (memcpy, memmove, ...)
- Details of inline assembly flags and their values (OS, CPU, ...)
- Distributed processing: Moving code to another machine and running there (Actor model + channel)
- Define notation to write low-level (Assembly or IR) code in a function body and also force inline.
- Function to get dynamic type of a tuple variable
- Add notation for axioms and related operators like `=>` to protocol to be able to define semantics of a protocol.
- Vet to format code based on the standard (indentation, spacing, warning about namings, ...). And force it before compilation.
- Compiler will detect local variable updates which are not escape and optimize them to use mutable variable (for example for numerical calculations which happens only inside a function).
- Channels are the main tool for concurrency and coordination.
- Protocol/type-class/concepts
