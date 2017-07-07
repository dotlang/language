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
- **Version 0.95**: May 23, 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to speciying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow opertor overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numberic types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (`^` and `%`).
- **Version 0.96**: June 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.97**: June 26, 2017 - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` placeholder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is types statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`.
- **Version 0.98**: ?? ??? ???? - remove `++` and `--`, implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to dot, add `$` prefix for untyped tuple literals to make it more readable, added `switch` and `while` keywords, renamed `loop` to `for`, re-write and clean this document with correct structure and organization, added `autoBind`, ban re-assignment and use `val` for defining bindings (instead of variables), loops are functional

# Introduction

After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions to keep in mind. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: dot (or dotLang). 

dot programming language (or dotLang for short) is an imperative, static-typed, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Elm, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from functional approach.

Three main objectives are pursued in the design of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them. Very few things are done implicitly and transparently by the compiler or runtime system. Also I tried to reduce need for nested blocks and parentheses as much as possible.
2. **Expressiveness**: It should give enough tools to the developer to produce readable and maintainable code. This requires a comprehensive standard library in addition to language notations.
3. **Performance**: The compiler will compile to native code which will result in high performance. We try to do as much as possible during compilation (optimizations, de-refrencing, in-place mutation, sending by copy or reference, type checking, phantom types, inlining, exclusive resource handling, ...) so during runtime, there is not much to be done except mostly for memory management. Where performance is a concern, the corresponding functions in standard library will be implemented in a lower level language.

Achieving all of the above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  We have functions and types. Each function acts on a set of inputs and gives an output. Type system includes primitive data types, tuple, union, array and map. Polymorphism, generics and lambda expression are also provided and everything is immutable.

## Comparison with other languages

**Compared to C**: C language + Garabage collector + first-class functions + template programming + better union data types + module system + flexible polymorphism + simple and powerful standard library + lambda expressions + closure + powerful built-in data types (map, string,...) + simpler primitives + multiple dispatch + sane defaults + full immutability - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + full immutability + simpler primitives - *dependency on JVM* - *cryptic syntax* - trait - custom operators - variance - implicit.

**Compared to Go**: Go + *generics* + full immutability + multiple dispatch + union types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives - pointers - interfaces - global variables.

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

## Language in a nutshell

01. **Import**: `import /core/std/queue`.
02. **Primitives**: `int`, `float`, `char`, `union`, `array`, `map` (Extended primitives: `bool`, `string`, `nothing`).
03. **Binding**: `let my_var:int = 19` (type can be automatically inferred, everything is immutable).
04. **Named type**: `type MyInt := int`
05. **Tuple**: `type Point := {x: int, y:int, data: float}`.
06. **Tuple value**: `location = Point{ .x=10, .y=20, .data=1.19 }`
07. **Composition**: By embedding (only for tuples), `type Circle := {Shape, radius: float}`.
08. **Generics**: `type Stack[T] := { data: array[T], info: int }`.
09. **Array**: `let jobQueue: array[int] = $[0, 1, 2, 3]`.
10. **Map**: `let countryPopulation: map[string, int] := $[ "US": 300, "CA": 180, "UK": 80 ]`.
11. **Union**: `type Maybe[T] := union[nothing, T]`.
12. **Function**: `func calculate(x: int, y: string) -> float { return if x > 0 then 1.5 else 2.5  }`.
13. **Lambda**: `let adder = |x:int, y:int| -> x+y`.

# Type System

## Declaration

**Semantic**: Used to declare a unique name and bind it to an expression.

**Syntax**: `let identifier [: Type] = expression`

**Examples**

1. `let x: int = 12`
2. `let g = 19.8`
3. `let a,b = process()`
4. `let x = y`
5. 
```
let x = { 
    process(1,2,3)
    6 
}
```

**Notes**

1. Everything is immutable and non re-assignable. But if you are starting a new code block `{...}`, you can define new bindings with same name as bindings outside the block. After the block, those bindings will be invalid.
2. `expression` can be a literal, function call, another binding or a combination.
3. You can however re-assign a name to a new value using assignment notation (Refer to the next section).
4. Example 1 defines a binding called `x` which is of type `integer` and stores value of `12` in it.
5. Compiler automatically infers the type of binding from expression, so type is optional except in special cases (e.g. `unions`)
6. There should be one space after `let` and before binding name.
7. If right side of `=` is a tuple type, you can destruct it's type and assign it's value to different bindings (Example 3). See Tuple section for more information.
8. Declaration makes a copy of the right side if it is a simple identifier (Example 4). So any future change to `x` will not affect `y`.
9. You can use a block as the expression and the last evaluated value inside the block will be bound to the given identifier.

## Primitives

**Semantics**: Provide basic feature to define most commonly used data types.

**Syntax**: `int`, `float`, `char`, `union`, `array`, `map`

**Examples**

1. `let x = 12`
2. `let x = 1.918`
3. `let x = 'c'`

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
4. `let g = nothing`
5. `if ( x == nothing ) ...`

**Notes**

1. You can define multiple label types at once (Example number 3).
2. Labels types are a special kind of named types which are explained in the corresponding section.

## Union

**Semantics**: A primitive meta-type to provide same interface which can contain different types.

**Syntax**: `union[type1, type2, ...]`

**Examples**

1. `type day_of_week := union[SAT, SUN, MON, TUE, WED, THU, FRI]`
2. `let int_or_float: unon[int, float] = 11`
3. `let int_or_float = 12.91`
4. `let int_or_float = 100`
5. `let has_int = typeOf(int_or_float) == @int`
6. `let int_value, has_int = int{int_or_float}`
7.
```
stringed = switch ( int_or_float ) 
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
4. Example 2, defines a union binding with explicit type and changes it's value to other types in next two examples.
5. Example 5, uses `typeOf` function to check if there is an integer type inside previously defined union binding.
6. You can use the syntax in example 6 to cast a union to another type. It will also give a boolean to indicate if the casting was successful.
7. Example 7, uses `switch` expression to check and match for type of data inside union.
8. `union[int, union[float, string]]` will be simplified to `union[int, float, string]`

## Array

**Semantics**: Define a fixed-size sequence of elements of the same type.

**Syntax**: `array[type]`

**Examples**

1. `let arr = $[1, 2, 3]`
2. `let g = get(arr, 0)`
3. `let new_arr = set(arr, 0, 10)`
4. `let new_arr2 = set(arr, $[0,1,2], $[4,4,4])`
5. `let two_d_array = $[ $[1,2,3], $[4,5,6] ]`
6. `let p = get(two_d_array, 0, 0)`
7. `let arr2 = $[0..10]`
8. `let arr: array[int] = $[1, 2, 3]`

**Notes**

1. Above examples show definition and how to read/update array.
2. In example 7, the range operator `..` is used to generate an array literal.
3. You can explicitly state array literal type like in example 8.
4. A `$` sign must prefix array literals.

## Slice

**Semantices**: Represents an array which maps to a limited view into an existing array.

**Syntax**: `slice(array, start, end)`

**Examples**

1. `let arr = $[1..9]`
2. `let slice1 = slice(arr, 1, 2)`
3. `let slice2 = slice(arr, 0, -1)`

**Notes**

1. Example 2 will give a slice which contains `2, 3`.
2. Example 3 will give a slice which contains all elements. End parameter can be negative which is counted from end of the array (`-1` means last element). Same for start.

## Map

**Semantics**: Represent a mapping from key to value.

**Syntax**: `map[key, value]`

**Examples**

1. `let my_map = $["A": 1, "B": 2, "C": 3]`
2. `let item1 = get(my_map, "A")`
3. `let map2 = set(my_map, "A", 2)`
4. `let map3 = delete(map2, "B")`
5. `let my_map: map[string,int] = $["A": 1, "B": 2, "C": 3]`

**Notes**

1. You need to use core functions to manipulate a map, because (like everything else), they are immutable.
2. If you query a map for something which does not exist, it will return `nothing`.
3. You can explicitly state type of a map literal like example 5.
4. A `$` sign must prefix map literals.

## Extended primitives

**Semantics**: Built on top of primitives, these types provide more advanced data types.

**Syntax**: `bool`, `string`, `nothing`

**Examples**

1. `g = true`
3. `str = 'Hello world!'`

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
5. `let x: MyInt = 10`, `let y: MyInt = MyInt{x}`

**Notes**

1. There must be a single space between `type` and type name.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. Although their binary data representations are the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to corresponding section for more information.
4. You can use casting operator to convert between a named type and it's underlying type (Example 5).
5. If a type is implemented in the runtime, it's definition will be `{...}`. For example `type array[T] := {...}`
 
## Tuple

**Semantice**: As a product type, this data type is used to defined a set of coherent bindings of different types.

**Syntax**: 

1. Declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. Literal: `Type{.field1=value1, .field2=value2, .field3=value3, ...}` 
3. Update: `other_tuple{.field1=value1, .field2=value2, .field3=value3, ...}` 
4. Untyped literal: `${value1 value2, value3, ...}` 

**Examples**

1. `type Point := {x:int, y:int}`
2. `point = ${100, 200}`
3. `point = Point{.x=100, .y=200}`
4. `my_point = Point{100, 200}`
5. `x,y = point`
6. `x,y = ${100,200}`
7. `another_point = my_point{.x=11, .y=my_point.y + 200}`
8. `new_point = {a:100, b:200} //WRONG!`

**Notes**

1. Field names are not mandatory when defining a tuple literal.
2. `$` prefix is used as an indicator to indicate a tuple literal without type. In this case you cannot name fields.
2. Example 1 defines a named type for a 2-D point and next 3 examples show how to initialise bindings of that type.
3. Examples 5 and 6 show how to destruct a tuple and extract it's data.
4. Example 7 shows how to define a tuple based on another tuple.
5. Example 8 indicates names should match with the expected type.

## Composition

**Semantics**: To include (or embed) the data defined in another tuple type.

**Syntax**: `{Parent1Type, field1: type1, Parent2Type, field2: type2, Parent2Type, ...}`

**Examples**
1. `type Shape := { id:int }`
2. `type Circle := { Shape, radius: float}`
3. `my_circle = Circle{id=100, radius=1.45}`
4. `type AllShapes := union[Shape]`
5. `someShapes = AllShapes[myCircle, mySquare, myRectangle, myTriangle]`

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

1. `x:int = 1.91`
2. `int_value, has_int = int{int_or_float}`
3. `type MyInt := int`
4. `x:MyInt = 100`
5. `y:int = x`

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

01. `func myFunc(y:int, x:int) -> int { return 6+y+x }`
02. `func log(s: string) -> { print(s) }`
03. `func process(pt: Point)->int { return pt.x }`
04. `func process2(pt: Point) -> ${pt.x, pt.y}`
05. `func my_func8() -> {x:int, y:int} { return ${10,20} }`
06. `func my_func(x:int) -> x+9`
07. `func myFunc9(x:int) -> {int} ${12}`
08. `func PI -> 3.14`
09. `func process(x: union[int,Point])->int`
10. `func fileOpen(path: string) -> File {...}`

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
12. If a function is implemented in the runtime or core sub-system, it's body will be written as `{...}`

## Invocation

**Semantics**: Execute commands of a pre-declared function.

**Syntax**: `output = functionName(input1, input2, ...)`

**Examples**

1. `pi = PI()`
2. `a,b = process2(myPoint)`
3. `_,b = process2(myPoint)`
4. `tuple1 = myFun9();`

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
3. `adderPointer = adder{myAdder}`
4. `func sort(x: array[int], comparer: func(int,int) -> bool) -> array[int]`
5. `func map[T, S](input: array[T], mapper: func(T) -> S) -> array[S]`

**Notes**

1. Example 4 indicates a function which accepts a function pointer.
2. Example 5 indicates the definition for a mapping function. It is using generics features introduces in the corresponding section.
3. Value of a function pointer can be either an existing function or a lambda. Refer to corresponding section for more information.
4. In a function type, you should not include input parameter names.

## Lambda

**Semantics**: Define function literals of a specific function pointer type, inside another function's body.

**Syntax**: `|name1: type1, name2: type2, ...| -> output { body }`

**Examples**

1. `f1 = |x: int, y:int| -> int { return x+y }`
2. `f1 = |x: int, y:int| -> { return x+y }` ;the most complete definition
3. `rr = |x: int, y:int| -> x + y`  ;return type can be inferred
4. `rr = || -> { x + y }`
5. `func test(x:int) -> plusFunc { return |y:int| -> y + x }`
6. `|x:int|->int { return x+1 } (10)`
7. `func process(x:int, y:float, z: string) -> { ... }`
8. `lambda1 = process(10, _, _)`
9. `ff = |x:int| -> { ff(x+1) }`

**Notes**
1. You can omit output type (Example 2 and 3).
2. Even if lambda has no input you must include `||` (Example 4).
3. Lambdas are closures and can capture values in the parent function (Example 4 and 5).
4. Example 5 shows a function that returns a lambda.
5. Example 6 shows invoking a lambda at the point of definition.
6. You can use `_` to define a lambda based on an existing function or another lambda or function pointer value. Just make a normall call and replace the lambda inputs with `_`. Example 8 defines a lambda to call `process` functions with `x=10` but `y` and `z` will be inputs.
7. Note that `||` notation is used for a function literal and `()` notation for function type declaration.
8. If lambda is assigned to a binding, you can invoke itself from inside (Example 9).

# Generics

## Declaration

**Semantics**: To define a function or data type which has one or more types defined like bindings. These types will get their values when the function is called or the data type is used to initialize a value.

**Syntax**: 
1. `func funcName[T1, T2, T3, ...](input1: type1, input2: T1, input3: T3, ...)->T2`
2. `type TypeName[T1, T2, T3, ...] := { field1: int, field2: T2, field3: float, ...}`

**Example**

01. `type Stack[T] := array[T]`
02. `type Tree[T] := {x: T, left: Tree[T], right: Tree[T]}`
03. `type optional[T] := union[nothing, T]`
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
1. `type HashType := union[MD5, SHA1]`
2. `type HashStr[T] := string`
3. `type Md5Hash := HashStr[MD5]` 
4. `type Sha1Hash := HashStr[SHA1]`
5. `func md5(s: string)->Md5Hash { ... }`
6. `func sha1(s: string)->Sha1Hash { ... }`
7. `t = Md5Hash{sha1("A")} //ERROR!`
8. `type SafeString := string`
9. `func processString(s: string)->SafeString`
10. `func work(s: SafeString)`
11. `type DoorState := union[Open, Closed]`
12. `type Door[T] := string`
13. `func closeDoor(x: Door[Open]) -> Door[Closed]`
14. `func openDoor(x: Door[Closed]) -> Door[Open]`

**Notes**
1. Phantom are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. 
2. You can implement these labels using a named type or a generic type.
3. Examples 1 to 7 show a et of hash functions that returns a specific type which is derived from `string`. This will prevent the developer sending a md-5 hash to a function which expects sha-1 hash (Example 7 will give compiler error).
4. Examples 8 to 10 indicate using named functions to represent a "sanitized string" data type. Using this named type as the input for `work` function will prevent calling it with normal strings which are not sanitized through `processString` function.
5. Examples 11 to 14 indicate a door data type which can only be opened if it is already closed properly and vice versa.


# Operators

**Semantics**: All non-alpabetical notations operators used in the language.

**Syntax**:
1. Conditional operators: `and, or, not, ==, !=, >=, <=`
2. Arithmetic: `+, -, *, /, %, %%, +=, -=, *=, /=`
3. Assignment: `=`, `:=`
4. Type-id: `@`
5. Chaining: ` . `
6. Casting `{}`

**Examples**

01. `g = @int`
02. `y:int = x`
03. `y:union[int, float] = 12`
04. `${x,y,z} . ${_,_,_}` => `${x,y,z}`
05. `g = ${5,9} . add(_, _)` => `g = add(5,9)`
06. `${1,2} . processTwoData(_, _)` => `processTwoData(1,2)`
07. `${1,2} . processTuple(_)` => `processTuple(${1,2})`
08. `6 . addTo(1, _)` => `addTo(1, 6)`
09. `result = ${input, check1(5, _)} . pipe(_,_) . ${_, check3(1,2,_)} . pipe(_, _) . ${_, check5(8,_,1) } . pipe(_,_)`
10. `func pipe[T, O](input: Maybe[T], handler: func(T)->Maybe[O])->Maybe[O] ...`
11. `${1,2} . ${_, _, 5} . process(_,_,_)` => `process(1,2,5)`.

**Notes**:
1. `=` operator copies data from right-side value into the left-side value.
2. `==` will do comparison on a binary-level. If you need custom comparison, you can do in a custom function.
3. Operators for bitwise operations and exponentiation are defined as functions.
4. `@`: returns type-id of a named or primitive type as an integer number (Example 1).
5. `{}`: To cast from named to unnamed type you can use: `Type{value}` notation (Example 2).
6. `{}`: To cast from value to a union-type (Example 3).
7. ` . `: Chaining opertor (Note to the spaces around the dot). `X . F(_)` will be translated to `F(X)` function call. right side of dot must be either a closure with expected inputs or a tuple with underscores for substitition. If right-side expects a single input but left side is a tuple with multiple items, it will be treated as a tuple for the single input of the function (Example 7) but if function expects multiple inputs they will be extracted from left side (Example 6). 
8. You can also pass a single argument to right side of the chain by using non-tuple value.
9. You can use chain operator with custom functions as a monadic processing operator. For example you can streamline calling mutiple error-prone functions without checking for error on each call (Example 9 and 10).


# Syntax

## Special notations

01. `@`  type-id opertor
02. `$`  tuple, array and map literal declaration
03. `_`  something we don't know or don't care (placeholder for a lambda input or unknown binding in assignments or switch)
04. `:`  type declaration for tuple and function input and values, map literal
05. `:=` custom type definition
06. `=`  type alias, assignment
07. `..` range generator
08. `->` function declaration, switch
09. `[]` generics, array and map literals (with `$` prefix)
10. `{}` code block, tuple definition and tuple literal (with `$` prefix)
11. `()` function declaration and call
12. `||` lambda declaration
13. `.`  access tuple fields, function chaining (with spaces around)

Keywords: `import`, `func`, `return`, `type`, `let`, `if`, `then`, `else`, `switch` 

Primitive data types: `int`, `float`, `char`, `union`, `array`, `map`

Extended primitives: `bool`, `string`, `nothing`


# Keywords

## import

**Semantics**: Import public type definitions and functions from another module.

**Example**

1. `import /core/std/Queue`
2. `import /core/std/{Queue, Stack, Heap}`
3. `import /core/std/Data/`
4. `/core/std/data/Process(1,2,3)`
5. `let x: /core/std/data/Stack = ...`
6. `func myProcess(x: int, y:int, z:int) -> /core/std/data/process(x,y,z)`
7. `type myStack = /core/std/data/Stack`
8. `import git:/github.com/adsad/dsada`
9. `import svn:/bitcucket.com/adsad/dsada`

**Notes**

1. You cannot import multiple modules using wildcards. Each one must be imported in a separate command.
2. You can import multiple modules with same package using notation in Example 2.
3. There must be a single space between `import` keyword and it's parameter.
4. Import paths starting with `/` mean they are absolute path (Regarding dot's runtime import path).
5. If an import path does not start with `/` means the module path is relative to the current module.
6. It is an error if as a result of imports, there are two exactly similar functions (same name, input and output). In this case, none of conflicting functions will be available for call. 
7. If you add a slash at the end of import file, it means import symbols using fully qualified name (Example 3)
8. Functions imported with fully-qualified method won't be used in method dispatch mechanism. You must explicitly call them or use data types in the module using fully-qualified notation. (Example 4 and 5).
9. You can use function redirection to work with FQ functions (Example 6) or use type alias to work with FQ type names (Example 7).
10. `import` supports other systems too. By default it imports modules from local file-system. But depending on the prefix used you can import from other sources too (Example 8).

## if, then, else

**Semantics**: A basic control structure to execute a piece of code based on a condition.

**Syntax**: 
1. `if condition then { code block } else if condition then { code block } else { code block}`
2. `if condition then expression else if condition then expression else expression`

**Examples**

1. `let x = if y>0 then 10 else 20`
2. `if isFine and x>0 then process(x,y) else return 100`
3. `callSystem(100) if x>100`
4. `let f: maybe[int] = if x>0 then 100`

**Notes**

1. `if` is an expression so you can assign it's output to a value (Example 1). In this case, if you do not include `else` clause, the target must be able to accept `nothing` (Example 4) (Missing `else` means `else nothing`).
2. You can suffix any statement with `if` statement so it will only be executed if condition is met.
3. You should not include parentheses for if argument.

## switch

**Semantics**: A shortcut for multiple `if`s for values or a union data type.

**Syntax**: `switch expression { case1-> statements, case2-> statements, ..., _-> statement }`
`switch unionValue { type1 -> statements, name: type2 -> statements, ... }`

**Examples**

1.
```
y = switch operation_result 
{
    1 -> "G",
    2 -> "H",
    3 -> "N",
    _ -> "A"
}
```
2.
```
y = switch int_or_float_or_string
{
    g:int -> 1+g,
    s:string -> 10,
    _ -> "X"
}
```
3.
```
y = switch operation_result 
{
    1 or 5 or 9 -> "G",
    2 -> "H",
    3 -> "N",
    _ -> "A"
}
```
4.
```
y = switch operation_result, int_or_float 
{
    11, _ -> "R",
    1 or 5 or 9, x:int -> "G",
    _, y:float -> "H",
    3 -> "N",
    _,_ -> "A"
}
```

**Notes**

1. In the `switch` expression for union data type, the name assigned for each type in a case will capture the internal value of the union if it has that type.
2. You should not include parentheses for switch argument.
3. If result of switch is not used or it is assigned to a binding which can accept `nothing`, then switch does not need to be exhaustive. Else it must cover all cases or have `else` clause. (Missing `_` means `_ -> nothing`).
4. You can match a `union` binding with either a value or a type.
5. You can combine multiple values in `switch` with `or` (Example 3).
6. You can switch based on multiple bindings (Example 4).
7. You cannot use conditions with `switch`. In this case you should use `if`.

# Miscellaneous

## Exclusive resource

**Semantics**: Represents a system resource (file, network socket, database connection, ...) which needs to have an exclusive owner and cannot be duplicated like normal values.

**Syntax**: Exclusive resources are defined in core (file descriptor, thread, sockets) and contain an identifier to indicate their owner thread.

**Notes**

1. These types are not supposed to be shared between two threads, because of their inherent mutability. If this happens, runtime will throw error. They all contain an owner thread identifier which is checked by core functions.
2. If you are not returning an exclusive resource, you must explicitly call `dispose` on it. Else compiler will issue error.

## Exception handling

**Semantics**: Handle unexpected and rare conditions.

**Syntax**: `func process() -> union[int, exception] { ... return exception{...} }`

**Examples**

1. `result: union[int, exception] = invoke(my_function)`

**Notes**

1. There is no explicit support for exceptions. You can return a specific `exception` type instead.
2. You can use chaining opertor to streamling calling multiple functions without checking for exception output each time.
3. If a really unrecoverable error happens, you should exit the application by calling `exit` function in core.
4. In special cases like a plugin system, where you must control exceptions, you can use core function `invoke` which will return an error result if the function which it calls exits.

## autoBind

**Semantics**: A compiler-level supported mechanism to fetch funcion pointers to currently defined functions and create an appropriate tuple with them.

**Syntax**: `x = autoBind[Type1]()`

**Examples**

1. `type Comparer[T] := { compare: func(T,T)->bool }`
2. `func sort[T](x: array[T], f: Comparer[T])->array[T] { ... }`
3. `sort(myIntArray, autoBind())`
4. `sort(myIntArray, autoBind[Comparer[int]]())`

**Notes**

1. Example 1 defines a general tuple which only contains function pointer fields.
2. Example 2 defines a function to sort any given array of any type. But to do the sort, it needs a function to compare data of that type. So it defines an input of type `Comparer[T]` to include a function to do the comparison.
3. Example 3 shows how to call `sort` function defined in example 2. You simply call `autoBind` to create appropriate tuple of appropriate types by the compiler. So `f.compare` field will contain a function pointer to a function with the same name and signature.
4. Example 4 is same as example 3 but with explicit types. You can omit these types as compiler will infer them.
5. You can also create your own custom tuple with appropriate function pointers to be used in sort function. `autoBind` just helps you create this set of function pointers easier.
6. The tuple defined in example 1 is called a protocol tuple because it only contains function pointers. These tuples are just like normal tuples, so for example you can embed other tuples inside them and as long as they only contains function pointers, they will be protocol tuples.
7. `autoBind` works only on protocol tuples.

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

# Examples

## Empty application

```
func main() -> 
{
    return 0 
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
type Expression := union[int, NormalExpression]

func eval(input: string) -> float 
{
  exp = parse(input)
  return innerEval(exp)
}

func innerEval(exp: Expression) -> float 
{
  return switch exp
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
- Add notation for axioms and related operators like `=>` to protocol tuples to be able to define semantics of a protocol.
- Vet to format code based on the standard (indentation, spacing, brace placement, warning about namings, ...).
- Compiler will detect local binding updates which are not escape and optimize them to use mutable binding (for example for numerical calculations which happens only inside a function).
- Channels are the main tool for concurrency and coordination.
- Provide ability to update used libraries without need to re-compile main application.
- implementation for loops (while, for, iteration, map, ...) in core.
- Parallel compilation
