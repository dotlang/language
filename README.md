# dot Programming Language Reference

Make it as simple as possible, but not simpler. (A. Einstein) 

Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

Version 0.98

June 2, 2017

# History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 10 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: May 3, 2017 - Clarifications for exception, Adding `where` keyword, explode operator, Sum types, new notation for hash-table and changes in defining tuples, removed `const` keyword, reviewed inheritance notation.
- **Version 0.9**: May 8 2017 - Define notation for tuple without fields names, hashmap, extended explode operator, refined notation to catch exception using `//` operator, clarifications about empty types and inheritance, updated templates to use empty types instead of `where` and moved `::` and `any` to core functions and types, replaced `switch` with `match` and extended the notation to types and values, allowed functions to be defined for literal input, redefined if to be syntax sugar for match, made `loop` a function instead of built-in keyword.
- **Version 0.95**: May 23 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to speciying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow opertor overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numberic types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (^ and %)
- **Version 0.98**: June 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.99**: ??? ??? ???? - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` placeholder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is types statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`

# Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: dot (or dotLang). 

dot programming language (or dotLang for short) is an imperative, static-typed, general-purpose language based on author's experience and doing research on many programming languages (namely Go, Java, C\#, C, C++, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from functional approach.

Three main objectives are pursued in the design of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to learn, write, read and understand. There has been a lot of effort to make sure there are as few exceptions and rules as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Expressiveness**: It should give enough tools to the developer to produce readable and maintainable code. This requires a comprehensive standard library in addition to language notations.
3. **Performance**: The compiler will compile to native code which will result in high performance. We try to do as much as possible during compilation (optimizations, de-refrencing, type checking, type filters, phantom types, ...) so during runtime, there is not much to be done except mostly for memory management. Where performance is a concern, the corresponding functions in standard library will be implemented with a lower level language.

Achieving all of above goals at the same time is impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  There are functions and types, nothing else. Each function acts on a set of inputs and gives one or more outputs. Type system includes primitive data types, tuple, union, array and map. Polymorphism, template programming and lambda expression are also provided.

## Comparison with other languages

**Compared to C**: dotLang is C language + Garabage collector + first-class functions + template programming + better union data types + module system + powerful polymorphism + simple and powerful standard library + lambda expressions + closure + powerful built-in data types (map, string,...) + multiple dispatch + sane defaults + better immutability + concepts and axioms - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch + custom immutability + concepts and axioms  - dependency on JVM - cryptic syntax - trait - custom operators - variance - implicit.

**Compared to Go**: Go + generics + immutability + multiple dispatch + sum types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives + concepts and axioms  - pointers - interfaces - global variables.


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
- **Comments**: `;` is used to start a comment. It must be either first character of the line or follow a whitespace.
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number. You can separate digits using undescore: `1_000_000`.
- **Terminator**: Each statement must be in a separate line and must not end with semicolon.
- **Order**: Each source code file contains 3 sections: import, definitions and function. The order of the contents of source code file matters: `import` section must come first, then declarations and then functions come at the end. If the order is not met, compiler will give errors.
- Import section is used to reference other modules that are being used in this module.
- Definitions section is used to define data types and protocols.
- Function section is used to define function bodies.
- **Adressing**: Modules are addressed using `/` notation (e.g. `/code/st/net/create_socket`). Where `/` denotes include path.
- **Encapsulation**: If a name (of a type, protocol or function) starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- **Naming**: (Highly advised but not mandatory) `someFunctionName`, `my_var_name`, `SomeType`, `MyProtocol`, `my_package_or_module`. If these are not met, compiler will give warnings. Primitives (binary, int, float, char), and types defined in core (bool, array, map, string) are the only exceptions to naming rules.

## Language in a nutshell
1. **Primitives**: `int`, `float`, `char`, `union` (Extended primitives: `bool`, `array`, `string`, `map`).
2. **Tuple**: `type Point := {x: int, y:int, data: float}`.
3. **Variable**: `var location: Point = { x=10, y=20, data=1.19 }`.
4. **Inheritance**: By embedding (only for tuples), `type Circle := {Shape, radius: float}`.
5. **Array**: `var JobQueue: array[int] = [0, 1, 2, 3]`.
6. **Generics**: `type Stack[T] := { data: array[T], info: int }`.
7. **Union**: `type Optional[T] := union[Nothing, T]`.
8. **Map**: `var CountryPopulation: map[string,int] = [ "US": 300, "CA": 180, "UK":80 ]`.
9. **Function**: `func calculate(x: int, y: string) -> float { return if ( x > 0 ) 1.0 else 2.0  }`.
10. **Import**: `import /core/std/Queue`.
11. **Immutability**: `val x: int = 12` (no change or re-assignment to `x` is allowed).
12. **Assignment**: `A=B` makes a copy of B's data into A.
14. **Casting**: `var pt = @Shape(myCircle)`.
15. **Lambda**: `var adder: func(var:int,var:int)->val:int = (x,y) -> x+y`.
16. **Protocols**: `protocol Comparable[T] := { func compare(T, T)->int }`, `func sort[T](x:array[T]) +Comparable`.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Type System
dotLang support different types of data and almost all of them are implemented using `binary` data type. `binary` type represents a buffer allocated in memory. Although in some cases compiler provides syntax sugar for primitive types (e.g. defining an `int` variable will allocate 8 bytes of `binary` type), but you can directly use `binary` type to implement your own custom data types (instead of using existing pre-defined types).

## Variabe declaration

**Semantic**: Used to pre-declare the memory you need to store result of computations.

**Syntax**: `(var|val) IDENTIFIER (':' type | ':' type '=' exp | '=' exp)`

**Examples**

1. `var x:int = 12`
2. `val y:string = 'Hello world!'`
3. `var g = 19`
4. `var count : int`
5. `var:int`

**Notes**

- You cannot use an uninitialized variable. If you do, you will receive a compiler error.
- Every variable must have a type either explicitly specified or implicitly inferred from assignment.
- `var` or `val` are storage qualifiers and are explained in `Immutability` section.
- `exp` is an expression which means it can either be a literal, function call, another variable or a complex expression.
- There must be a single space between `var` or `val` keyword and the idenfitier (if there is an identifier).
- Example number 5 represents a case where only immutability and type is important. More explanation in `protocol` and `function` section.

## Assignment

**Semantics**: To make a copy of a piece of data (called rvalue) and put it somewhere else (called lvalue).

**Syntax**: `lvalue = rvalue`

**Examples**

1. `x = 10`
2. `x = y`
3. `x = y + 10 - z`
4. `x = func1(y) + func2(z) - 10`
5. `x,y = 1,2`

**Notes**:

1. `lvalue` is the identifier which is on the left side of assignment operator `=`. It must be a single identifier.
2. If assignment is done in a variable declaration statement, lvalue can be an immutable variable. Otherwise lvalue must be mutable.
3. In case rvalue is a temporary variable (a variable created during a computation which is transparent from the developer), compiler may decide to re-use that temporary variable to save space and increase performance.

## Primitives

**Semantics**: Provide basic tools to define most commonly used data types.

**Syntax**: `int`, `float`, `char`, `union`

**Examples**

1. `var x:int = 12`
2. `var x:float = 1.918`
3. `var x:char = 'c'`
4. `var day_of_week: union[SAT, SUN, MON, TUE, WED, THU, FRI]`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. The identifiers used in example number 4 is called "label types" and are explained in the corresponding section.
5. Character literals should be enclosed in single-quote.
6. For `union` type, refer to the next section.

## Union

**Semantics**: A primitive meta-type to provide same interface which can contain different types

**Syntax**: `union[type1, type2, ...]`

**Examples**

1. `var maybe_int: union[int, Nothing]`
2. `var int_or_float: unon[int, float]`
3. `int_or_float = 12`
4. `int_or_float = 1.212`
5. `var has_int: bool = int_or_float.(int)`
6. `var int_value, success = int_or_float.(int)`
7. 
```
var stringed = if ( int_or_float ) {
    (int) -> ["int" , toString(int_or_float)],  ;inside this block, int_or_float is automatically treated like an int
    else -> "Not_int"
}
```

**Notes**

1. `union` is a meta-type which can take form of different data types. It uses generic programming features which are explained in corresponding section. For more information refer to the next section.
2. Types inside union definition must be named types. Refer to corresponding section.
3. `union[int, floatOrString]` will be simplified to `union[int, float, string]`
4. Compiler will convert a union data type to corresponding `binary` type with appropriate tagging.
5. Example 5: In a boolean or single-var context, `x.(type)` evaluates to a bool indicating true if `x` contains given type.
6. Example 6: If `x.(int)` is used otherwise it evaluate to an integer and a boolean indicating desired type and a flag for whether casting is successfull or no.
7. You can use `x.(type)` notation in a block-if (Example 7). Refer to corresponding section for more information about `if`.

## Extended primitives

**Semantics**: Built on top of primitives and built-in language features, provide more advanced data types.

**Syntax**: `bool`, `array`, `string`, `map`

**Examples**

1. `var x: bool = true`
2. `var arr: array[int] = [1, 2, 3]`
3. `var x: string = 'Hello world!'`
4. `var my_map: map[string, int] = ["A":1, "B":2, "C":3]`
5. `arr(0) = 11`
6. `my_map("A") = 2`

**Notes**

1. All extended primitives are defined using language features and based on primitives and `binary` data type.
2. `string` is defined as an array of `char` data type. The conversion from/to string literals is handled by the compiler.
4. These types are part of `core` package. Please refer to this package documentation for more information about how they work.
5. String literals should be enclosed in double quotes. 
6. String litearls enclosed in backtick can be multi-line and escape character `\` will not be processed in them.

## Tuple

**Semantice**: As a product type, this data type is used to defined a set of coherent variables of different types.

**Syntax**: 
1. For declaration: `{field1: type1, field2: type2, field3: type3, ...}` 
2. For literals: `Type{field1=value1, field2=value2, field3=value3, ...}`

**Examples**

1. `var point: {x: int, y:int} = {x=100, y=200}`
2. `var point_x: int = point.x`
3. `point.y = point.x + 10`
4. `var another_point = Point{x=100, y=200}`
5. `var third_point = Point{200, 400}`
6. `var fourth_point: {x:int, y:int=123} = {300}`

**Notes**

1. Tuple literal does not need to include type name, if the type can be inferred from the context.
2. In examples number 4 and 5, we have used `Point` as a type name. Refer to corresponding section for more information about named types.
3. Compiler will translate tuples to `binary` type with appropriate size.
4. The example number 6, uses default value for `y` field.

- Fields that start with underscore are considered internal state of the tuple and better not to be used outside the module that defines the type. If you do so, compiler will issue a warning.
- You can define a tuple literal using `{}` notation: `var t = {field1=10, field2=20}`.
- If a function expects a specific input type, you can pass a tuple literal, if field order, names and types match.
- If function expects a specific input type and tuple uses unnamed fields, you can use tuple if order and types match.
- You can cast a tuple literal to a specific type. `var g = MyTuple{field=10, field2=20}`
- You can use cast operator to cast a variable initialized with tuple literal to a specific type.


## Composition

**Semantics**: To be able to re-use data defined in another tuple.

**Syntax**: `{Parent1Type, field1: type1, field2: type2, Parent2Type, ...}`

**Examples**

1. `type Shape := { id:int }`
2. `type Circle := { Shape, radius: float}`
3. `var my_circle: Circle = {id=100, radius=1.45}`

**Notes**
1. In the above example, `Shape` is the contained type and `Circle` is container type.
2. The language provides pure "contain and delegate" for a limited form of subtyping.
3. A tuple can embed as many other tuples as it wants and forward function calls to itself to functions to other embedded tuples. Refer to function section for more information about forwarding functions.
4. You can define a union type which accepts both `Shape` and `Circle`. It will detect the actual type.
5. To have dynamic polymorphism, you can use `union`: `var result: union[Circle, Square] = createShape()`
6. Note that polymorphism does not apply to generics. So `array[Circle]` cannot substitute `array[Shape]`.
7. We use closed recursion to dispatch function calls. This means if a function call is forwarded from `Circle` to `Shape` and inside that function another second function is called which has candidates for both `Circle` and `Shape` the one for `Shape` will be called.

## Type alias

**Semantics**: To define alternative names for a type

**Syntax**: `type NewName = CurrentName`

**Examples**

1. `type MyInt = int`

**Notes**

1. In the above example, `MyInt` will be exactly same as `int`, without any difference.
2. This can be used in refactoring process or when there is a name conflict between types imported from different modules. See `import` section for more information.

## Label types

**Semantics**: To define types that have only one value: Their name. These types are useful as part of enum or a union.

**Syntax**: `type LabelName`

**Examples**

1. `type true`
2. `type false`
3. `type Saturday, Sunday, Monday`
4. `type Nothing`
4. `var g: Nothing = Nothing`

**Notes**

1. You can define multiple label types at once (Example number 3).

## Named type

**Semantics**: To introduce new, different types based on existing types (called underlying type).

**Syntax**: `type NewType := UnderlyingType`

**Examples**

1. `type MyInt := int`
2. `type IntArray := array[int]`
3. `type Point := {x: int, y: int}`
4. `type bool := union[true, false]`
5. `var x: Point = {10, 20}`
6. `var t1:int = 12`, `var t2: MyInt = t1` - compiler error!


**Notes**

1. There must be a single space between `type` and name.
2. Example number 4, is the standard definition of `bool` extended primitive type based on `union` and label types.
3. In above examples (like example number 1), note that although their binary data representation is the same, `MyInt` and `int` are two separate types. This will affect function dispatch. Please refer to corresponding section for more information.
4. You can use casting operator to convert between a named type and it's underlying type. Please refer to corresponding section.
5. In example number 6, you cannot assign `int` to `MyInt` as they are completely different types.

 


## Variables
- You can declare and assign multiple variables in a single statement:
`var x,y = 1,2`
`var x, val y=1,2`
`var x:int, val y:float = 10, 1.12`

========================================

## Rules



A named type is completely different from it's underlying type and the only similarity is their internal memory representation.
```
type MyInt := int
;in a function
var t: int = 12   ;define a variable of type int and named 't'
var y: MyInt = t  ;wrong! You have to cast 't'
```

Two variables of same named types, have the same type. Two variables of unnamed types which is structurally similar, have the same type (e.g. `array[int]` vs `array[int]`).

Assignment between different variables is only possible if they have the same type. Otherwise, a casting is needed.
```
var x: int = 12
var y: int = 19
x=y  ;valid
```

- If function expects a named type, you cannot pass an equivalent unnamed type. 
- Similarly, when a function expects an unnamed type, you cannot pass a named type with same underlying type. 
- We never do implicit casts like int to float.
- Assigning a value of one named type to variable of a different named type is forbidden, even if the underlying type is the same. 

There are two named types which are called "Extended Primitives" because of their internal role in the lagnuage: `bool` and `string`:
```
type bool := true | false
type string := array[char]
```
`if ( @x == @SAT )` or `if ( x == SAT )`



## Array
This is a built-in data type:
`type array[T] := {...}`
```
var x:array[int] = [1,2,3]
x(0) = 100
x(1) = x(0)+1
```
- Type of slice is different from array.
slice is a meta-array. `type slice[T] = (length: int, start: T)`

- If an array is var, all it's elements are var. Same for hash and tuple. This means const is deep and transitive.
Arrays are a special built-in type. They are defined using generics. Compiler provides some syntax sugars to work with them.
`[0..3]` means `[0, 1, 2, 3]`

```
;define an array of integer number and initialize
var numbers: array[int] = [1, 2, 3, 4]

;t will be 1
var t:int = numbers(0)   

;this will change '2' to '3'
numbers(1)++             

;syntax sugar to create a range of values (inclusive)
var months: array[int] = [1..12] 

;you can use core function to allocate array
var allocated: array[int] = allocate[int](100)

;multi-dimensional arrays are created using nested generic type
var x: array[array[int]]

;note that you can use 'type' to simplify cases where type name is complicated
type TwoDimArray := array[array[int]]
var x: TwoDimArray
```
- **Slice**: You can use slicing notation to create a virtual array which is pointing to a location inside another array. You use `array_var[start:end]` notation to create a slice.
```
;a normal array
var x: array[int] = [11, 12, 13, 14, 15, 16, 17]

;defining a slice containintg '12' and '13'
var y: array[int] = x({1:2})

;this will make '12' change to '22'
y(0)+=10

;start and end are optional and if ommitted will default to beginning/end of the array
;here z will contain '15', '16' and '17'
var z: array[int] = x.[4:]

;here u will contain '11' and '12'
var u: array[int] = x.[:1]

;you can make slice a clone of original array by eliminating both start and end
var p: array[int] = x.[:]

;you can use a slice on the left side of an assignment
;it will put result of right side of '=' into the original array
mySlice = createValues()
```

## Map
`type map[K,V] := {...}`
```
var m:map[string, int] = ["A" => 1, "B"=>2]
m("C") = 12
```

Maps, hashtables or associative arrays are a data structure to keep a set of keys and their corresponding values.
```
;defining and initializing a map
var y: map[string, int] = ["a": 1, "b": 2]

;read/write from/to a map
y("a") = 100
var t: int = y("b")
```

- If you query a map for something which does not exist, it will return `Nothing`. Below shows two ways to read data from a map:
`var value = my_map("key1") if ( var i, success = @int(value), success )`
`var value = my_map("key1") if ( @value == @int )`
`var value = my_map("key1") if ( value @ int )`
`var t, _ = my_map("key1")`






>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Functions
- Function inputs are immutable. Only local variables can appear on the left side of `=`.
- Note that when I call `process(myIntOrFloat)` with union, it implies that there must be functions for both int and union (or a func with union type).
- explain fwd functions
- We solve expression problem by using open functions.
- If you want dispatch with static type, cast the argument to static type.
If a function expects `x: Stack[Shape]` you cannot send `Stack[Circle]`.

explain relation with subtyping
Example about inheritance, polymorphism and subtyping:
```
type Shape := {}
func Draw(Shape, int)->int

type BasicShape := (x: string)              ; a normal type
func Draw(x: BasicShape, y:int)             ; Now BasicShape is compatible with Shape type

type Circle := (BasicShape, name: string)   ; another type which inherits from BasicShape
func Draw(x: Circle, y:int)                 ; It has it's own impl of Draw which hides Human implementation

type Square := (BasicShape, age: int)       ; another type which embeds BasicShape.
;calling Draw on Square will call BasicShape version

type OtherShape := {}
function Draw(x: OtherShape, y:int)         ; OtherShape also implements Hobby

var all: Shape[] = [myBasicShape, myCircle, mySquare, myOtherShape]
for(Hobby h: all) Draw(h,1,"")
;implicit casting to empty type. Compiler can check if this is a valid casting or no.
;compiler can make sure that all currently defined empty functions which accept Shape
;are defined for MyOtherShape too
var t: Shape = myOtherShape
var r: BasicShape = myCircle ;automatic casting - because Circle inherits from BasicShape
```

- section: function pointer. state it's binding is explicit without dynamic dispatch.
- You can define functions on types and specialize them for special subtypes. This gives polymorphic behavior.
`func paint(o:Shape) {}`
`func paint(o:any){}`
`func paint(o:Circle)...`
`func paint(o:Square)...`


- `type NoReturnFunc[T] := func(T)`
- You can use `_` to ignore a function output: `var t, _ = my_map("key1")`
- A function can return multiple outputs:
```
func process()-> var:int, val:int
var x:int
val y:int
x,y = process
var x, val y = process()
var x, val y := process()
```
- You can define consts using functions: `func PI -> 3.14`
- Storage class: `var/val` of the function output is part of singature (but not output type). And you must capture a functin output.
`process/int/var.int/val.float/val` is a condensed view of the signature of the funtion: `func process(var x:int, val y: float)->val string`.


- There must be a single space between func and function name.
- A function can determine whether is expects var or val inputs. If function wants to promise it won't change the input but caller can send either var or val, it can do so with eliminating qualifier or using val: `func process(x: int)`.
- var/val qualifier is optional for function input/output. if missing, it is considered val and caller can send either val or var. But if it is `val`, caller can only send vals.
- If function output does not have a qualifier, it will be val.
`func process(var x:int) -> x` return is a val
`func process(var x:int) -> int x` return is a val
`func process(var x:int) -> val:int x` return is a val
- If function wants to return a var and use shortcut:
`func process(val x:int) -> var:int x+1`
`func process(val x:int) -> var x+1`
- A function can state it's output var/val. if qualifier is missing, function can return either var or val but caller can only assign the result to a val (unless it is making a copy). But if output is marked with `val`, function can only return a val.
- So missing qualifier: either var or val can be used by sender but receiver should assume val.
- function inputs should have val/var modifier so it won't be ambiguous whether something is potential for shared mutable state. If input modifier is missing, it is assumed to be var or val.
- If function output type misses `var/val` modifier, it will be assumed `val`.
`func add(x:int, y:int)->int`
`func add(val x:int, val y:int)->val:int`
These two definitions are different. var/val are part of function.
Compiler/runtime will handle whether to send a ref or a copy, for val arguments.
- You can omit `()` in function call if there is no local variable or argument with same name and function has no input. If there is local var with same name, compiler will issue warning: `var t:int = sizeof[int]`

function inputs must be named.
- Function output can be any type and any count. Even a tuple or a tuple with unnamed fields.
Function is a piece of code which accepts a series of inputs and can return a single value. 
If you use `{}` for the body, you must specify output type and use return keyword.

```
func my_func1(x: int, y: int) -> float { return x/y }
func my_func1(y:int) -> float { return y/3 } ;you must specify input name
func my_func(y:int, x:int) -> int { return 6+y+x } ;based on runtime arguments, one of implementations will be choosed
func my_func(5:int) -> 9
func my_func3(x: int, y: int) -> x/y  ;you can omit {} if its a single expression
func my_func7() -> int { return 10;} ;fn has no input but () is mandatory
func my_func7() -> 10  ;when function has just a return statement, there is a shortcut
func my_func8() -> (int, int) { return 10,20 } ;function can return multiple values
func myFunc9(x:int) -> {y:int} {y=12} ;you can have named output

 ;below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

func map<T, S>(arr: T[], f: func(T) -> S) -> S[]

;these calls are all the same
new_array = map(my_array, (x) -> x+1)
```
- `map` can work on any type that supports iterable.
```
new_array = map(my_array, (x) -> x+1) ;map will receive a tuple containing two elements: array and lambda
new_array = map(my_array , (x:int) -> {x+1})
```
- Paren is required when calling a function, even if there is no input.
- You can define variadic functions by having an array input as the last input. When user wants to call it, he can provide an array literal with any number of elements needed.
- `rest` is a normal array which is created by compiler for each call to `print` function.
- Functions are not allowed to change (directly or indirectly) any of their inputs.
```
func f(x:int, y:float) -> (a: int, b: string)
{
  ;returning anon-tuple
  return (a=1, b=9) ;or return (1, 9) or return 1,9
}

func read_customer(id:int) -> Nothing | CustomerData
{
  ;no customer was found
  return Nothing
  
  ;some customer found
  return c1
}
```
- You can define a function which does not have a body. This is like an abstract method. So calling it will throw error.
`func adder(x: int, y:int)->int`
- Normally you define general functions as abstract, and speciaize it for specific types in other functions with the same signature.
- Function definition specifies a contract which shows input tuple and output tuple. If input tuple is named, you must pass a set of input or tuple with the exact same name or an unnamed tuple. If input is unnamed, you can pass either unnamed or named tuple.
```
func f(x:int, y:int) -> ...
var g = {x:10, y:12}
f(g) ; this is not correct. f expects x and y not a tuple with another tuple.
f(1,9)
f(g.x, g.y)
```
- Note that you cannot use optional arguments in a function signature. Although you can have multiple functions with the same name:
```
func process(x: int, y:int, z:int) -> ...
func process(x: int) -> process(x, 10, 0)
```
- This is a function that accepts an input of any type and returns any type: `type Function[I,O] := func(I)->O`.
- This is a type for functions that don't return anything: `type NoReturnFunc[T] := func(T)`
- Functions can name their output. In this case, you can assign to it like a local variable and use empty return.
`func process() -> x:int `

## Method call resolution
- We can have dynamic dispatch by using union. When I call `process(intOrFloat)` based on the type inside union, either process for int or the one for float will be called.
- There will be no dynamic type. When you write `var s: Shape = createCircle()` you have only a Shape. Because `=` is supposed to make a data-copy. If you need to support both use union. For example for array storage define array of type `union[Circle, Square]`.
- explain named and underlying type role indispatch
If no function is defined for a named type but for it's underlying type, that one will be called.

Method call is done using full dynamic match. Developer has to define appropriate functions or forwarding functions. This will impose a bit of burden on developer but will simplify compiler, increase method call performance and make code more clear and understandable. No unexpected method call.
To define forwarding function you define a function signature without body, with `-> Target` for the types you want to forward:
You can have multiple forwading in the same definition and use sum type to group multiple functions.
`func process(Polygon|Square|Circle->Shape, GradientColor|SolidColor->Color)`
Above means, any call to `process` with any of `Polygon, Square, Circle` and any of `GradientColor, SolidColor` will be redirected to `process(Shape, Color)`.
You can mix forwarded arguments with normal arguments:
`func process(float, Polygon|Square|Circle->Shape, string, int, GradientColor|SolidColor->Color, int)`
Note that any argument can only be forwarded to a parent type.
- No forwarding function is automatically generated.
- Suppose that we have `binary -> Shape -> Polygon -> Square` types.
and: `type MyType := Square`
then: `MyType -> MyChild -> MyGrandChild`
then if a variabe of type MyGrandChild is passed to a function.
For static candaidate this is the ordered list: MGC, MC, MT, Square, Polygon, Shape, binary
if for example dynamic type of the variable is `MyGrandChild` and there is `func process(MyGrandChild)` it will be called (note that this can be a fwd function).
It not found, the static candidate will be called.

## Matching
`func add(x:int, y:int, z:int) ...`
`func add(x:int=15, y:int, z:int) ...`
`func add(x:int, y:int, z:int=9)...`
call:
`add(x,y)` will call 3rd version
`add(15, y)` will call 3rd version
`add(15, y, z)` where z is not 9, will call 2nd version
in function definition giving value to a parameters, means it should be exactly equal to that value or it should be missing.
order of match: for (a,b,c) tuple when calling function:
Functions with that name which have 3 or more inputs will be tested.
- Functions with exactly 3 inputs have higher priorirty than those with 3+ inputs with optional values.
- Functions with higher input value equal to values of a, b, c have higher priority.
So, first search for funcciont with 3 inputs then 4 input with last one optional, then 5 inputs ...
In each case, first check functions that have all 3 pre-set, then 2 pre-set then 1-preset then no pre-set.
If in each step, two cancidates are found, give error.
For example:
`func add(x:int=9, y:int)`
`func add(x:int, y:10)`
calling `add(9, 10)` will result in two candidates -> runtime error.
if input is unnamed then ok. If it is named, we have an extra condition: input names must match.
and `(a=15, x=10, y=20)` will match `(x:int)` which is foundation of subtyping.
With named inputs, you can ignore first or middle arguments: 
```
func add(x:int=10, y:int)...
add(y=19)
```
Each function call will be dispatched to the implementation with highest priority according to matching rules. 

## Lambda expression
A function type should not include parameter name because they are irrelevant.
A lambda variable can omit types because they can be inferred: `var x: comparer = (x,y) -> ...`
A function literal which does not have a type in the code, must include argument name and type. `(x:int)->int { return x+1 }(10)` or `var fp = (x:int)->int { return x+1}`

- closure capturing: It captures outside vars and vals. Can change vars.
- Even if a lambda has no input/output you should write other parts: `() -> { printf("Hello world" }`
You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too, also  `func` keyword is not needed. The essential part is input and `->`.
If you use `{}` for the body, you must specify output type and use return keyword.
```
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition
var rr = (x: int, y:int) -> x + y  ;return type can be inferred
var rr = { x + y } ;WRONG! - input is not specified
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition

type adder := (x: int, val y:int) -> var:int
var rr: adder = (a:int, b:int) -> { a + b } ;when you have a type, you can define new names for input
var rr: adder = (x,y) -> x + y   ;when you have a type, you can also omit input
var rr: adder = (x,y) -> int { return x + y }      ;and also func keyword, but {} is mandatory
var rr:adder = (x,y) -> x + 2      
func test(x:int) -> plus2 { return (y) -> y+ x }
var modifier = (x:int, y:int) -> x+y  ;if input/output types can be deduced, you can eliminate them
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

## Protocols
- You can use this notation to define a union which can accept any type that confirms to `ShpProtocol`: `type Shapes := union[+ShpProtocol]`. Compiler will generate list of types.
- There can be no impl on a protocol.
- If there is common behavior, use protocol. If there is common data, use composition.
- You can also include storage class in a function signature in a protocol:
`protocol Stringer[T] := { func toString(val:T) }`

- Syntax to enforce protocol (for protocol, function and type):
`protocol Eq[T] := +Ord[T] { ... }`
`func isInArray[T](x:T, y:array[T]) +Eq[T] -> bool { loop(var n: T <- y) {if ( equals(x,n) ) return true} return false }`
`type Set[T] := +comprbl[T] +prot2[T] array[T]`

- Bodyless functions in a protocol, imply they must be implemented by the developer.
- You can inherit from another protocol:
`protocol Eq[T] := +Ord[T] { ... }`
- There must be a single space between `protocol` keyword and the protocol name.
- So if a function plans to accept inputs which are not native array, it can be defined like this:
`func process[T](x: T, arrayFuncs: ArrAccessors[T])` which means `x` input will have appropriate methods to be accessed like an array. Then inside `process` function it can use `x[0]` and other methods to work with x.

If someone calls a generic function with some user-defined type, they really don't know what they should implement until they see the compiler error or the source code. Protocols are used to document this.
When writing a generic function, you may have expectations regarding behavior of the type T. These expectations can be defined using a protocol. When you call this function with a concrete type, compiler makes sure the protocol is satisfied.
General definition of function with protocol:
;S,T,X must comply with prot1, N,M with prot2, P,Q are free
`func process[S, T, X, N, M, P, Q] (x: T) +prot1[S,T,X] +prot2[N,M] -> {...}`
Note that one type can be part of more than one protocol:
`func process[S, X, N, M, Q, P, T] (x:int) +prot1[S,T,X] +prot2[N,M] +prot3[T,N] -> { ... }`

When defining a protocol, argument names shoud be eliminated.
```
;Also we can initialize tuple members, we have embedding
;Note that if T is a sum type, each function here can be multiple implemented functions
protocol Eq[T] := {
    func equals(T,T)->bool
    func notEquals(T,T)->bool
}
type Point := {x:int, y:int}
;here we are implementing protocol Eq[Point]
func equals(x: Point, y: Point)->bool { ... }
;this one is not necessary because it has a default implementation
func notEquals(x: Point, y: Point)->bool { ... }

;just like the way we define type for variables, we can define protocol for generic types
func isInArray[T] (x:T, y:T[]) +Eq[T] -> bool {
    if ( equals(x, y[0])...
}
;call:
isInArray(x, arr)
---
protocol Ord[T] := {
    func compare(x:T, y:T)->int
}
func sort[T: Ord](x:T[])
---
protocol Stringer[T] := {
    func toString(x:T)->string
}
func dump[T: Stringer](x:T)->string
---
protocol SerDe[T] := {
    func serialize(T)->string
    func deserialize(string)->T
    func reflectivity(x: T) -> des(ser(x)) == x
}
func process[T: Serializer](x: T) -> ...
---
protocol Adder[S,T,X] := {
    func add(x: S, y:T)->X
}
func process[S,T,X: Adder](x: S, y:T)->X { return add(x,y) }
---
protocol Failable[T, U] := {
    func oops() -> T[U]
    func pick(T[U], T[U])->T[U]
    func win(U)->T[U]
}
type Maybe[U] := U | Nothing
func oops[U]()->Maybe[U] { return Nothing }
func pick[U](x: Maybe[U], y: Maybe[U])-> Maybe[U]
func win[U](x: U) -> Maybe[U] { return x }

func safeDiv[T: Failable](x: double, y: double) -> T[double] {
    if ( y == 0 ) return oops
    return win(x/y)
}
;when calling above function, you must provide type of function
var t: Maybe[double] = safeDiv[Maybe](x, y)

---
protocol Factory[T] := {
    func create()->T
}
func create()->int { return 5 }
func create()->string { return "A" }
func generalCreate[T: Factory]() -> T { return create() }
;here we have to specify type because it cannot be inferred
var r = generalCreate[string]() ;will result "A"
var y = generalCreate[int]() ;will result 5
```
this will invoke `func item()->int` to provide value for this argument.
Protocols can embed other protocols to include their functions.
You can define and implement a protocol for a type outside your codebase, that's why you dont need to specify which protocols are implemented by a type upon declaration.
- Note that although a protocol may require a specific function, but actual function to be called is determined at runtime based on dynamic type.
```
;we can overload protocols
func sort[T] Ord[T](...)
func sort[T] StrictOrd[T](...)
```
If we call sort function, compiler will decide which protocl best matches.
- You can also define protocols for types:
For example you can define a set only for types which are comparable. We cannot define `Set[adder_function]`
`type Set[T] := comprbl[T] array[T]`
`type BinaryTree[T] := comparable[T] { ... }`
`type map[K,V] := Hashable[K] ...`
- If Circle[T] inherits from Shape[T], re-declaring protocols on Shape is optional but they will be enforced by the compiler.
- if a protocol has a default implementation for a function and generic type does not implement that function, the default implementation will be used. This can be used to check data of a generic type:
`protocol HasId[T] := { func getId[T](x: T)->x.id }`?
`func process[T] HasId[T]` you can only pass tuples that have `id` field (or simulate it with your own functions).

## Type filter
You can use type filter expression when specifying generic arguments (in protocol, function, type or union) to filter possible types that can be used.
You can use type filter to restrict valid generic types based on protocol or fields they have (for tuples).
General syntax: `[T1,T2,T3,... : Filter_1 + Filter_2 + Filter_3, ...]`
`Ti` are generic type names.
`Filter_i` are type filters.
`Filter_i = ProtocolFilter | FieldFilter`
`ProtocolFilter = ProtocolName(T1, T2, T3, ...)` if there is only one type can be shortcut to: `ProtocolName`
`FieldFilter = T1.Field1`
Note that for union you can only use one type.
For protocol, type filter specifies which types can implement this protocol (pre-requirements).
For function, it specifies which types can be used to call this function.
For types, it specifies which types can be used to instantiate this type.
For union, it specifies which types are possible options for this union.
Examples:
`type u5 := union[T: Prot1 + T.Tuple1]` 
`protocol Eq[T:Ord1, Ord2] := { func compare(T,T)->bool }`
`type Set[T,V : comprbl(T), prot2(T), prot3(T,V)] := array[T,V]`
`func isInArray[T,V: Eq(T), prot2(T,V), T.Field1](x:T, y:array[T]) -> bool { ... }`



>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Notations

## Operators
- Conditional: `and or not == != >= <= => =<`

- Math: `+ - * % %% (is divisible) ++ -- **`
- Note that `++` and `--` are statements which will update their operand and won't return anything. So you cannot use them in another statement or expression. Also these are only allowed as suffix.
The math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies data.
- `:=` opreator will make left side point to right-side variable or result of evaluation of the right-side expression.
- `x == y` will call `opEquals` functions is existing, by default compares field-by-field values. But you can override.
- We don't have operators for bitwise operations. They are covered in core functions. 
- `equals` functions is used for equality check.
- You can have multiple assignments at once: `x,y=1,2`
- Assignment semantics: `x=y` will duplicate contents of y into x (same as `*x=*y` in C++). So if rvalue is a temp variable (e.g. `x=1+y`), it will be a ref-assign handled by the compiler. If you want to ref-assign you should use `:=` notation. Note that for assignment lvalue and rvalue must be of the same type. You cannot assign circle to Shape because as copy is done, data will be lost (you can refer to `.Shape` field in the Circle).
`x=y` will duplicate y into x. So changes on x won't affect y. 
- Comparison semantics: `x==y` will compare data of the references for comparison. If you need to compare the references themselves for comparison you can use core function's ref: `ref(x) == ref(y)`

- Type operator (`@`): This can be used to cast: `var myInt = @int(myFloat)`. 
- Applications of casting:
cast between named type and underlying
cast between elements of union and union type
cast between subtype and super-type
cast int to float
cast from an untyped tuple variable to a specific type.
- Casting examples:
`@int(x)`
`@string(x)`
`@OptionalInt(x)`
`@Point(var)`
`@Point({x:10, y:20})` --cast a tuple literal
`@Point[int]({x:10, y:20})` -- casting combined with type specialization
Casting to a tuple, can accept either a tuple literal or tuple variable or an exploded tuple.
Note that there is no support for implicit casting functions. If you need a custom cast, write a separate function and explicitly call it.
- chaining: You can use `|` in the form of: `x | f` which means `f(x)`. You can customize behavior of this operator for your type by writing `opChain` function.


### Special Syntax
- `@` casting
- `|` chaining
- `+` type filter
- `_` placeholder for lambda or unknown variable
- `:` declaration for tuple, variable type and type filter
- `:=` custom type definition
- `=` type alias, copy value
- `=>` map literals
- `..` range generator
- `->` function declaration, block-if
- `[]` generics, array and map literals
- `{}` code block, tuple definition and tuple literal
- `()` function call, modify array and map
- `.` access tuple fields

Keywords: `import`, `func`, `var`, `type`, `protocol`, `if`, `else`
Special functions: `dispose`, `opChain`
Primitive data types: `int`, `float`, `char`, `union`, `array`, `map`
Extended data types: `bool`, `string`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

### match
```
;when result of x is not boolean
y = if ( x ) {
    1 -> "G",
    2 -> "H",
    3 -> "N",
    else -> "X"
}
y = if ( x ) {
    (int) -> "G",
    (string) -> "H",
    else -> "X"
}
```

###if, else
- You can use `if/else` block as an expression.
```
IfElse = 'if' '(' condition ')' Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
- Semantics of this keywords are same as other mainstream languages.
- If block is a single statement in one line, you dont need braces.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.
`var max = if (x > y) x else y`

```
  if ( exp1 and exp2 ) 11 else -1
```
- You can have one variable declarations before the condition.
These declarations will be only available inside if/else block.
`if (var x=getResult(), x>0) ... else ...`
`if (var x=1, x>y)...`
- `xyz if(cond)` is also possible.

### assert (removed)
- If condition is not satisfied, it will return an error. 
- We have RIAA approach. Anything which is allocated inside a function which is not part of return value will be disposed (by calling `dispose` function) when exiting the function.

- `Exception` is a simple tuple defined in core. 
- You can use suffix if for assertion: `return xyz if not (str.length>0)`
- To handle exceptions in a code in rare cases (calling a plugin or another thread), you can use `invoke` core function.
`func invoke[I,O](f: func, input: I)->O|Exception`. If your function has more than one input, you should define a wrapper function or a closure which has one input of type tuple.
- In order to handle possible errors in a chain of function calls, you can use `opChain` on a type (e.g. Maybe). 
`func opChain[T](m: Maybe[T], f: func(T)->Maybe[T]) -> { return if (@m == @Nothing) None else f(m) }`
`var input = 10`
`var finalResult: Maybe[int] = input | check1(5, _) | check2(_, "A") | check3(1,2,_)`

- **Nothing**: Nothing is a label type with only one value: `nothing`.
 You can use it's type for return value of a function.


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


### loop
You can use `loop` function with an array, hash, predicate or any type that has an iterator.
```
loop(10, () -> { printf("Hello world" })
loop([2..10], () -> { printf("Hello world" })
loop([2..10], (x:int) -> { printf("Hello world" })
loop(my_array, (s: string) -> ...)
loop(my_hash, (key: int) -> ...)
loop(x>0, () -> { ... }) ;if x is var, the loop body can change it
loop(my_iteratable, (iterator: int) -> ...)
loop(true () -> { ... })` infinite loop
;to return something:
;we can return explicitly to simulate break: return false means break outside the loop
;return true means continue to the next iteartion
loop([1..100], ()-> { if ( ... ) return false })
;to force return from inside loop: set a var outside
var result = 0
loop(... , () -> { if ( ... ) { result = 88; return false; })
```
- If expression inside loop evaluates to a value, `loop` can be used as an expression:
`var t:int[] = loop(var x <- {0..10}) x` or simply `var t:int[] = loop({0..10})` because a loop without body will evaluate to the counter, same as `var t:array[int] = {0..10}`

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
- possible add notation for function chaining
- Define notation to write low-level (Assembly or IR) code in a function body and also force inline.
- Function to get dynamic type of a tuple variable
- Add notation for axioms and related operators like `=>` to protocol to be able to define semantics of a protocol.
