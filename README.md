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
- **Version 0.99**: ??? ??? ???? - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, remove anything type, change notation for inference, removed lambda-maker and `$_` placeholder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, defined `opCall` to support indexing array and hash, unified assignment semantic, added inline assembly, introduced `:=` ref-assign operator and make `=` data-copy operator, removed `break` and `continue`, removed Phantom types setion as they can be implemented with named types, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, update protocol enforcement syntax and extend it to types with addition of axioms

# Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala, Rust and Haskell) it still irritates me that most of these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is simple, powerful and fast.

That's why I am creating a new programming language: dot (or dotLang). 

dotLang programming language is an imperative, static-typed general-purpose language based on author's experience and doing research on many languages (namely Java, C\#, C, C++, Go, Scala, Rust, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, Eiffel, Falcon, Julia, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most useful features of the OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent. On the other hand, we have first-class and higher-order functions borrowed from functional approach.

Three main objectives are pursued in the design of this programming language:

1. **Simplicity**: The code written in dotLang should be consistent, easy to learn, read, write and understand. There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Expressiveness**: It should give enough facilities to the developer to produce readable and maintainable code. This requires a comprehensive standard library in addition to language rules.
3. **Performance**: The compiler will compile to native code which will result in high performance. We try to do as much as possible during compilation (optimizations, de-refrencing, type checking, ...) so during runtime, there is not much to be done except for GC. The standard library functions will be implemented in the assembly language where the performance is the main concern.

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule](https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  There are functions and types, nothing else. Each function receives input and gives an output. Types include primitive data types, tuple, union types and a general type alias. Polymorphism, templates, lambda expression and exception handling are also supported.

## Comparison with other languages

**Compared to C**: dotLang is C language + Garabage collector + first-class functions + template programming + sum data types + module system + powerful polymorphism + simple and powerful standard library + exception handling + lambda expressions + closure + powerful built-in data types (hash, string,...) + multiple dispatch + sane defaults - ambiguities - pointers - macros - header files.

**Compared to Scala**: Scala + multiple dispatch - dependency on JVM - cryptic syntax - trait - custom operators - variance and implicit.

**Compared to Go**: Go + generics + immutability + multiple dispatch + sum types + sane defaults + better orthogonality (e.g. creating maps) + simpler primitives - pointers - interfaces - global variables.


## Subsystems

- Runtime system: Responsible for memory allocation and management, interaction with the Operating System and other external libraries and handling concurrency.
- Core: This package is used to implement some basic, low-level features which can not be simply implemented using pure dotLang language.
- Std: A layer above runtime and `core` which contains some general-purpose and common functions and data structures.

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
In the above examples `/core/sys, /core/net, /core/net/http, /core/net/tcp` are all packages.
- Unlike many other languages, modules are stateless. Meaning there is no variable or static code defined in a module-level.

## General rules
- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored. - **Indentation**: Indentation must be done using spaces, not tabs. 
- **Comments**: `;` is used to denote comment. It must be either first character of the line or follow a whitespace.
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number. You can separate digits using undescore: `1_000_000`.
- **Terminator**: Each statement must be in a separate line and must not end with semicolon.
- **Order**: Each source code file contains 3 sections: import, definitions and function. The order of the contents of source code file matters: `import` section must come first, then type and protocol declarations and then functions come at the end. If the order is not met, compiler will give warnings.
- Import section is used to reference other modules that are being used in this module.
- Definitions section is used to define data types and protocols.
- Function section is used to define function bodies.
- **Adressing**: Modules are addressed using `/` notation (e.g. `/code/st/net/create_socket`). Where `/` denotes include path.
- **Encapsulation**: If a name (of a type, protocol or function) starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- **Naming**: (Highly advised but not mandatory) `someFunctionName`, `my_var_name`, `SomeType`, `my_package_or_module`. If these are not met, compiler will give warnings. Primitives (binary, int, float, char), and types defined in core (bool, array, map, string) are the only exceptions to naming rules.

## Language in a nutshell
1. **Primitives**: `binary` (extended primitives: `int`, `float`, `char`, `string`, `bool`).
2. **Tuple**: `type Point := {x: int, y:int, data: float}`.
3. **Variable**: `var location: Point = { x=10, y=20, data: 1.19 }`.
4. **Inheritance**: By embedding (only for tuples), `type Circle := {Shape, radius: float}`.
5. **Array**: `var JobQueue: array[int] = [0, 1, 2, 3]`.
6. **Generics**: `type Stack[T] := { data: array[T], info: int }`.
7. **Union**: `type Tree[T] := Empty | T | { root: T, left: Tree[T], right: Tree[T] }`.
8. **Map**: `var CountryPopulation: map[string,int] = [ "US": 300, "CA": 180, "UK":80 ]`.
9. **Function**: `func calculate(x: int, y: string) -> float { return if ( x > 0 ) 1.0 else 2.0  }`.
10. **Import**: `import /core/std/Queue`.
11. **Immutability**: `val x: int = 12`, no change or re-assignment to `x` is allowed.
12. **Assignment**: `A=B` makes a copy of B's data into A.
13. **Reference assignment**: `A:=B` makes A point to the same things that B is pointing to.
14. **Casting**: `var pt = @Point[int]({ x=10, y=20, data=1.11 })`.
15. **Lambda**: `var adder: func(var int,var int)->val int = (x,y) -> x+y`.
16. **Protocols**: `protocol Comparable[T] := { func compare(x:T, y:T)->int }`, `func sort[T: Comparable](x:array[T])`.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Type System

## Variabe definition
- Every variable must have a type. You define variables using `var` keyword: `var x: int` (This defined a new variable named `x` which is an integer number).
- Each variable must have a value upon declaration. Either you assign a value explicitly or compiler will set default value of that type.

## Immutability

## Assignment

## Primitives

## Extended primitives

## Tuple

## Polymorphism

## Union

## Type alias

## Named type

## Variables

========================================

## Rules
- Note that you cannot re-assign `val` to something else with `=`. Because other parts of the code may have a copy of it and re-assign may change their data: `val x = 12, process(x), x=19` this will change what x points to. so any thread inside process will have a value which point to 19 instad of 12.
- There must be a single space between `type` keyword and type name.
- You can not have a read-only view of a read-write memory cell: `val x := otherVar` is invalid!
variables are initialized upon declaration. for val you must assign value, for var, compiler will set default value (everything zero, empty, ...)
`var x: array[int]` will create an empty array

Note that `val` can only appear on the left side of `=` when it is being declared. What comes on the right side of `=` must be either another val or made val using `@val` or a literal
Every type is allocated and a reference is put inside the variable. Compiler may optimize this for cases when a local variable like an int, is not sent outside.
val is like a memory cell with a lock on it.
var is like a memory cell without lock.
The most primitive type is `binary` which denotes an allocated memory buffer.
`type array[T] = (size:int, data: binary)` binary means a buffer with size specified at runtime.
`type array[N: int, T] = (size:int, data: binary[N])` `binary[N]` means N bytes allocated.
```
func get[T](val arr: array[T], index: int) -> val T {
    vax T result := arr.data + index*sizeof[T]
    return result ;we cannot shortcut this by writing something like "return *(arr.data + index*a)"
}
```
If we use `get` to read data as `var` from an array which contains value types, we won't have direct access to inside the array. We will receive a copy.
`type int := binary` compiler will allocate 8 bytes as a binary buffer for int
`type binary := native`
We have two categories of types: value-type (or valtype) and reference-type (or reftype). binary is the only valtype. Any named type with binary underlying type is valtype. Every other type (tuple or union with tuples) is reftype.
Union which has only labels (called enum) or has labels and other valtypes, is a valtype, because compiler uses int or a binary buffer to implement it. If it has tuples, it is reftype.
`function` type is a valtype. Underlying, it is a pointer to a memory location. It is implemented as `int`.
- You can manage inside a binary buffer and use it as differetn variables.
```
var x: buffer = allocate(16)
var p1: int = getOffset[int](buffer, 0)
var p2: int = getOffset[int](buffer, 8)
;you can use @ to cast a pointer to the type you want
;if buffer was defined as val, you could only create val here.
var i1: int = @int(p1)
var i2: int = @int(p2)
val i3: int = @val(@int(p1)) ;you can combine @ and remove paren: @val@int(x)
```
- Note that you can even use `getOffset` to place a whole tuple on top of a binary. This might be useful in some performance cases.
There are two categories of types: Named and unnamed. An unnamed type is defined using existing language constructs.
For example these are some unnmaed types: `int, array[string], {x:int, y:float}, int|string`.
A named type is defined using `type` statement: `type MyInt := int`. 
Underlying type is the internal structure of a type. For unnamed types, their underlying type is the same as themselves but for named types, their underlying type is what comes after `:=` in their declaration.
There are 4 kinds of unnamed types: primitive, function, tuple and union. These will be explained in next sections.
```
;you can define a new named type using type keyword
type MyInt := int
;you can define a variable using var keyword
var x: MyInt
var y: int
var z: string
```

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

## Primitive
There are three primitive data types: `int`, `char` and `float`.
- **int**: Represents signed integer numbers with 64-bits of data (or 32-bits in 32-bit systems)
- **float**: Represents a double-precision floating point number (64-bits)
- **char**: Represents a single character or an unsigned integer number (0 to 255).
There are two named types which are called "Extended Primitives" because of their internal role in the lagnuage: `bool` and `string`:
```
type bool := true | false
type string := array[char]
```

## Tuple
- Tuples are translated to binary type by compiler: e.g. `type Point := {x:int, y:int}` will become:
`type Point := binary[16], x_offset=0, y_offset=8`
A tuple is a collection of variables combined together under a single type. This is similar to an array but with different data types for fields. 
```
;defining a named type for a tuple
type Car := { color: int, age: int }
;defining variables of 'Car' type, initialized with default values
var x: Car = {}
;if you omit {} part, variable will be initialized with default values automatically
var d: Car
;But you can assign values upon declaration:
var y: Car = { color:100, age=11 }
;you can cast an anonymous tuple to a specific type
var z = @Car({age=121})
;you can define an anonymous tuple
var t1 : {field1: int, field2: string} = {1, "A"}
;field name is optional for anonymous tuples
var t2 : {int, string} = {1, "A"}
;you can use dot notation to assign value for unnamed tuple fields
t2.1 = "AG"
;You can specify default values for tuple
type Car := { color: int, age: int=100 }

var myCar: Car = {color=100, age=20}
;compiler will handle this regarding type inference and assignment
var x,y = myCar
```
- Fields that start with underscore are considered internal state of the tuple and better not to be used outside the module that defines the type. If you do so, compiler will issue a warning.
- You can define a tuple literal using `{}` notation: `var t = {field1=10, field2=20}`.
- If a function expects a specific input type, you can pass a tuple literal, if field order, names and types match.
- If function expects a specific input type and tuple uses unnamed fields, you can use tuple if order and types match.
- You can cast a tuple literal to a specific type. `var g = @MyTuple({field=10, field2=20})`

## Union
- Also union types are translated to a binary with size=largest choice.
- unions are types based on dynamic type so `type A := Shape | Circle` is valid.
`type MaybeInt := int | Nothing`
Labels define a new type which has only one value with the same notation (or use them).
`type UnionType := Type1 | Type2 | Type3 | ...`
`type Nothing` - defines a type which has only one valid value: Nothing

Union is a specific data type which defines a set of possible other types it can contain. Variables of union type, can only contain one of their possible types at any time. You use `|` to separate different possible types.

```
type IntOrFloat := int | float
var f: IntOrFloat
;you can assign an int to f
f = 1
;or a floating point number
f = 3.59
;note that you cannot assign f to a floating point variable, even if it has a float, you must cast
var fl: float = f  ;wrong!
var fl: float = @float(f)

;note that for union and other non-primitive types, assignment is by reference
var g: IntOrFloat = f
;this will change value of 'f' too
g = 66
;this won't change value of f:
g = 99
;You can define 'labels' for valid values of a union:
type MaybeInt := int | Nothing
var t: MaybeInt
t = Nothing
t = 12
```
- A union variable can accept values of any of it's valid types.
- You cannot assign a union value to another one, without casting, even if their types match:
```
var a: int| string = 12
a = "A"
var b: int | string | float
```
You can have `myIntOrFloat = 12` or `myIntOrFloat = floatVar` as long as type or rvalue is included in union type.
But for anything else, you must cast.

To cast union to it's internal types: `if ( myIntOrFloat @ var x:int)`

You can pass int or string or float or `int|string` or `int|float` or `string|float` variables to it.


When defining a sum type, you specify different types and labels that it can accept. Label can be any valid identifier. Labels can be thought of as a special type which has only one valid value: The label itself. 
`type Tree := Empty | int | (node: int, left: Tree, right: Tree)`
`type OptionalInt := None | int`
To match type, you can use match expression:
```
  result = my_tree :: {
    Empty -> 0
    int -> 1+int(my_tree)
    NormalTree -> ...
  }
```

You can define an enum using sum types.
```
type DoW := SAT | SUN | ...
```
- Note that types inside a union type must not completely overlap (e.g. `Shape | Circle`) is not a valid type.
- If you try to use a value as a sum type which covers more than one of it's choices there will be an error.
```
type First := (x:int)
type Second := (y: string)
type S := First | Second ;this is valid because F and S do not overlap
var t : (x:int, y: string) = (1, "G")
;t is satisfying both First and Second
if ( t :: First ) ... true
if ( t :: Second ) ... true
var x: S = t ;error
```
- You must initialize sum type variables upon initialization.

## Named Types
You can use `type` to define new type based on an existing type. 
You can also use it to define a type alias.

```
type point := int[]
type x := int    ;x will be an alias for int type
var a: x  ;=var a: int;
```
To use a type:
```
var pt: point = (1, 10);
;you can alias it again
type mypt := point;
var xx: mypt = (1, 2);
```
You can define functions based on `int` and `X` where `type X := int` and they will be different functions.

Note that when using type for alias to a function, you have to specify input names too.
`type comparer := func (x:int, y:int) -> bool;`
If types are compatible (e.g. long and int) you can cast them using: `TypeName(x)` notation. Note that this notation can also be used to specify type of a literal when we can't or don't want to do it using normal notation:
For example in return statement `return Circle(radius=1)`.
- Note that you cannot define your own casting function using `@TypeName(x)` name. Here `x` is a code block which will evaluate to something we want to cast. You can write cast functions using a standard name, however.
- You can use casting syntax to cast between named and unnamed types, downcast (from Circle to Shape) or cast a sum type to one of it's elements or a compatible sum type.
- Applications of casting:
cast between named type and underlying
cast between elements of union and union type
cast between subtype and suprtype
cast anonymous tuple to typed
cast int to float
- Casting examples:
`@int(x)`
`@string(x)`
`@OptionalInt(x)`
`@Point(var)`
`@Point({x:10, y:20})` --cast a tuple literal
`@Point[int]({x:10, y:20})` -- casting combined with type specialization
Casting to a tuple, can accept either a tuple literal or tuple variable or an exploded tuple.
Note that there is no support for implicit casting functions. If you need a custom cast, write a separate function and explicitly call it.
- `@Type()` without input creates a default instance of the given type.
- When doing cast to a generic type, you can ignore type if it can be deduced. 

## Alias
You can use `type MyInt = int` to define a type alias.
Type alias is exactly the same as what comes on the right side. There is absolutely no difference.
This can be used to resolve conflict types when importing modules.
`type Stack1 = /core/mode1/Stack`
`type Stack2 = /code/mode2/Stack`
`type S[T] = Stack[T]`
`type ST = Stack[int]`


## Inheritance and Polymorphism
- Tuples can inherit from a single other tuple by having it as their first field and defined as anonymous.
`type Circle := (Shape, ...)`
- You can define functions on types and specialize them for special subtypes. This gives polymorphic behavior.
`func paint(o:Shape) {}`
`func paint(o:any){}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
- Any variable has two types: Static (what is visible in the source code), and dynamic.
`var c: Shape = createCircle()` - static type is Shape but dynamic type is Circle. 
- We can keep a list of shapes in an array/collection of type Shape: `var o: Shape[] = [myCircle, mySquare];`
- You can iterate over shapes in `o` array defined above, and call `paint` on them. With each call, appropriate `paint` method will be called (this appropriate method is identified using 3 dispatch rules explained below).
- Visible type (or static type), is the type of the variable which can be seen in the source code. Actual type or dynamic type, is it's type at runtime. For example:
`func create(x:type)->Shape { if ( type == 1 ) return Circle{}; else return Square{}; }`
Then `var x: Shape = create(y);` static type of `x` is Shape because it's output of `create` but it's dynamic type can be either `Circle` or `Square`.
Note that this binding is for an explicit function call. when we assign function to a variable, the actual function to be used, is determined at runtime with dynamic dispatch. so `var x = paint` where type of x is `func(Circle, Color)` will find a paint function body with matching input. you can have x of type `func(Shape, Color)` and assign a value to it and expect it to do dynamic dispatch when called at runtime. 
So if we have this:
`func paint(o: Square, c: SolidColor)`
`type Shape := (name: string)`
`type Circle := (x: Shape)`
`type Square := (x:Shape)`
`type Color := ();`
`type SolidColor := (Color, )`
a call to paint function with some inputs, will use above 3 rules to dispatch.
- suppose we have `Base` type and `Derived` types. Two methods `add` and `addAll` are implemented for both of them.
if `addAll(Derived)` calls `addAdd(Base)` which in turn calls `add(Base)` then a call to `addAll(Derived)` will NOT call `add(Derived)` but will call `add(Base)`. When `addAll(Base)` is called, it has a reference to `Base` not a `Derived`. 
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
if a function expects `f: func()->Shape` you can send a function which returns a Circle, because there are implicitly castable.
If a function expects `x: Stack[Shape]` you cannot send `Stack[Circle]`.
- You can embed as many types as you want in your tuple, but the first field will be parent.
- To redirect a function to another one with types in the same hierarchy, you need to cast the argument.
`func process(Circle, SolidColor) -> process(%Shape{c}, %Color{sc})`
```
type Dot := { x: int }
type Point := { data: string, x: int }
func process(p: Dot) ...
```
How can I pass a Dot to process function? You need to write a proxy function:
`func process(p: Point) -> process(@Dot(p.x))`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Functions
- You can define consts using functions: `func PI -> 3.14`
- `var/val` of the function output is part of singature (but not output type). And you must capture a functin output.
`process/int/var.int/val.float/val` is a condensed view of the signature of the funtion: `func process(var x:int, val y: float)->val string`.
- You can write body of a function using assembly: use `{| ... |}` notation. If you want your assembly to be inlined, use `{|| ... ||}`. You can use `(A=B)` or `(A!=B)` notation to do conditional compilation based on OS and hardware.
```
func process(x:int) -> int 
{|
   (OS == WIN)
   {
     mov ax, 10
     mov bx, 20
     add ax, bx
   }
   (CPU != Intel)
   {
      mov ax, 12
   }
|}
```

- There must be a single space between func and function name.
- A function can determine whether is expects var or val inputs. If function wants to promise it won't change the input but caller can send either var or val, it can do so with eliminating qualifier or using val: `func process(x: int)`.
- var/val qualifier is optional for function input/output. if missing, it is considered val and caller can send either val or var. But if it is `val`, caller can only send vals.
- You can use `@var/val` in shortcut functions to explicitly indicate output type:
`func process(val x:int, var y:int) -> @var(x+y+1)`
- If function output does not have a qualifier, it will be val.
`func process(var x:int) -> x` return is a val
- If function wants to return a var and use shortcut:
`func process(val x:int) -> var int x+1`
`func process(val x:int) -> var x+1`
- When you pass var or val to a function, the reference is being sent and compiler makes sure vals are not changed.
- when a function returns var/val it returns a reference to a locally allocated data.
- A function can state it's output var/val. if qualifier is missing, function can return either var or val but caller can only assign the result to a val (unless it is making a copy). But if output is marked with `val`, function can only return a val.
- So missing qualifier: either var or val can be used by sender but receiver should assume val.
- function inputs should have val/var modifier so it won't be ambiguous whether something is potential for shared mutable state. If input modifier is missing, it is assumed to be var or val.
- If function output type misses `var/val` modifier, it will be assumed `val`.
`func add(x:int, y:int)->int`
`func add(val x:int, val y:int)->val int`
These two definitions are different. var/val are part of function.
Compiler/runtime will handle whether to send a ref or a copy, for val arguments.
- You can omit `()` in function call if there is no local variable or argument with same name and function has no input. If there is local var with same name, compiler will issue warning: `var t:int = sizeof[int]`

function inputs must be named.
- Function output can be any type. Even a tuple or a tuple with unnamed fields.
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
(x,y) = @my_func8()
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
- Everything is passed by reference but the callee cannot change any of its input arguments (implicit immutability) for parameters passed by reference.
- Parent is required when calling a function, even if there is no input.
- You can use `@var` and `@val` to cast to var/val: `var x = @var(y)`. If you use this to convert from val to val or var to var, it will become a reference assignment. Otherwise, it will clone. You can have an expression inside `@var` or `@val`.
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
- Functions can name their output. In this case, you can assign to it like a local variable and use empty return.
`func process() -> x:int `

## Method call resolution
If no function is defined for a named type but for it's underlying type, that one will be called.

Method call is done using full dynamic match. Developer has to define appropriate functions or forwarding functions. This will impose a bit of burden on developer but will simplify compiler, increase method call performance and make code more clear and understandable. No unexpected method call.
To define forwarding function you define a function signature without body, with `-> Target` for the types you want to forward:
You can have multiple forwading in the same definition and use sum type to group multiple functions.
`func process(Polygon|Square|Circle->Shape, GradientColor|SolidColor->Color)`
Above means, any call to `process` with any of `Polygon, Square, Circle` and any of `GradientColor, SolidColor` will be redirected to `process(Shape, Color)`.
You can mix forwarded arguments with normal arguments:
`func process(float, Polygon|Square|Circle->Shape, string, int, GradientColor|SolidColor->Color, int)`
Note that any argument can only be forwarded to a parent type.
- For functions that have only one input of type tuple, forwarding functions are automatically generated by the compiler.
e.g. `func process(Circle->Shape)`.
So forwarding function is automatically generated for `func process(x: Shape|int, y: float)`.
For `func process(x: Shape|int, y: Color|float)` forwarding is generated for cases where either x is int or y is float.
`func process(x: Circle->Shape, y:float)`
`func process(x:int, y:SolidColor->Color)`
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
- closure capturing: It captures outside vars and vals. Can change vars.

You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too, also  `func` keyword is not needed. The essential part is input and `->`.
If you use `{}` for the body, you must specify output type and use return keyword.
```
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition
var rr = (x: int, y:int) -> x + y  ;return type can be inferred
var rr = { x + y } ;WRONG! - input is not specified
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition

type adder := (x: int, y:int) -> int
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
- Generic arguments should types.
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

## Protocols
- A type definition can require a protocol without input type which implies that protocol is enforced with the parent type meaning there are functions based on that protocol for the given type:
```
protocol Disposable[T] := { func dispose(T) }
type FileHandle := +Disposable int
```
- Syntax to enforce protocol:
`protocol Eq[T] := +Ord[T] { ... }`
`func isInArray[T](x:T, y:array[T]) +Eq[T] -> bool { loop(var n: T <- y) {if ( equals(x,n) ) return true} return false }`
`type Set[T] := +comprbl[T] +prot2[T] array[T]`

- Bodyless functions in a protocol, imply they must be implemented by the developer. Functions that have a body, must have bool output and are called axioms. They are called to explain the semantics of the protocol.
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
    func default(x: T, y: T) -> equals(x,y) => not notEquals(x,y)
    func identity(x: T) -> equals(x,x)
    func reflectivity(x: T, y:T) -> equals(x,y) => equals(y,x)
    func transitivity(x,y,z: T) -> (equals(x,y) and equals(y,z)) => equals(x,z)
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
    func reflectivity(x: T) -> des(ser(x)) <=> x
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


>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Notations

## Operators
- Conditional: `and or not == != >= <= => =<`
- Logical: `=>` (implication) and `<=>` (equivalence of behavior/computation). mostly used in axioms.
`t=x<=>y` means `t=x iff y`
`var t = x=>y` implies operator, means `t=if x then y else true`

- Math: `+ - * % %% (is divisible) ++ -- **`
The math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies data.
- `:=` opreator will make left side point to right-side variable or result of evaluation of the right-side expression.
- `x == y` will call `opEquals` functions is existing, by default compares field-by-field values. But you can override.
- We don't have operators for bitwise operations. They are covered in core functions. 
- `equals` functions is used for equality check.
- You can have multiple assignments at once: `x,y=1,2`
- Assignment semantics: `x=y` will duplicate contents of y into x (same as `*x=*y` in C++). So if rvalue is a temp variable (e.g. `x=1+y`), it will be a ref-assign handled by the compiler. If you want to ref-assign you should use `:=` notation.
- Ref-Assignment: This is mostly used to work with very large data structures where assignment by copy is expensive: `var x = getLargeBuffer()` -> `var x := getLargeBuffer()`. Other use cases: working with binary data, array and slice implementation, re-use an existing val. Right side of `:=` must be a simple expression (an identifier or a function call).
- Almost everywhere, we deal with values not references. So `x=y+1` means increase value of y by one and copy the result into the memory location to which x is pointing to. `x:=y+1` means increase value of y by one and store the result in a memory location and make x point to that memory location. If you want to work with addresses you should use core functions.
`val x = otherVal` copy (or ref-assign due to optimization)
`var x = otherVar` copy
`val x = otherVar` copy (or ref-assign due to optimization)
`var x = otherVal` copy 
`= = = = = = = = = = =`
`val x := otherVal` ref-assign
`var x := otherVar` ref-assign
`val x := otherVar` invalid. val cannot point to var.
`var x := otherVal` invalid. You cannot have a var pointer to a val memory area.
- `a:=b+c+d+8` add right side values, store result somewhere and make a point to that location.
- what comes on the right side of `:=` is any expression. The address of that expression will be copied onto the left side.
`x=y` will duplicate y into x. So changes on x won't affect y. 
- Comparison semantics: `x==y` will compare data of the references for comparison. If you need to compare the references themselves for comparison you can use core function's ref: `ref(x) == ref(y)`
- Assignment: If left and right are val/var, user must use `@val/var` to cast.
`myVar=@var(myVal)` (clone if needed)
- When assigning between var and val, you must clone rvalue.
`var x: Point = ...`
bin-type example:
`val x: int = 12`
`var z: int = @(x)`
`val t: int = @(z)`
- Each type can implement `opCall` function which will be called when the type is used like a function. If this function returns a `var` result, it's result can be used as an lvalue to do assignment.

### Special Syntax
- `@` casting/type check
- `+` protocol enforcement
- `|` sum types
- `_` placeholder for lambda
- `:` tuple declaration, variable type declaration, hash literal
- `:=` custom type definition, reference assignment
- `=` type alias, copy value
- `..` range generator
- `<-` loop
- `->` function declaration
- `[]` generics, array and map literals
- `{}` code block, tuple definition and tuple literal
- `()` function call
- `.` access tuple fields

Keywords: `import`, `func`, `var`, `val`, `type`, `native`, `loop`, `protocol`
Semi-Keywords: `if`, `else`
Special functions: `opCall` , `dispose`
Primitive data types: `binary`, `int`, `float`, `char`
Extended data types: `bool`, `string`, `array`, `map`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Keywords
- `@` is an operator which can be used in two ways:
- with a type and a value to cast value to this type: `var t = @int(12.0)`
- As a binary infix operator to check for type matching.
- You can use `!@` to check for not matching.

### match
```
MatchExp = '(' tuple ')' @ '{' (CaseStmt)+ '}'
```
- This is an expression. It is used to check if two variables can be matched according to matching rules.
- First case which is matching will be executed and others will be skipped.
- Case match can be based on value or type (used for sum types).
- Each match case is a lambda without parentheses for input. The first case that can accept the value inside match will be executed.
- Mechanism of match is the same as a function call is dispatched to an implementation. Each candidate will be examind against match input for type and values. The first one that can be matched will be invoked.
- The cases for match must cover all possible inputs or else there will be errors.
```
  result = my_tree @
  {
    {int, int} -> ...;this will match if input has two ints 
    5 -> 11,
    "A" -> 19,
    local_var -> 22, ;check equality with a local variable's value
    Empty -> 0,
    int -> 1,
    var y:float -> y,
    NormalTree -> { return 1+z },
    else -> { -1 } ;this is default because it matches with anything
  }
  ;You can shorten this definition in one line:
  result = my_tree @ 5 -> 11, 6-> 12, Empty -> 0, x:int -> x, any -> -1
```
- Simple form: You can use `@` without `->` too to check for types which returns a bool: `if ( x @ int)`. In this format, you can check for a type or a literal.
- `if ( x @ var t:int)` inside if block you have a local variable `t` which is `int` value of `x`.
- `if ( x @ y )` is invalid. Right side of match can either be a literal (e.g. 5) or a type (e.g. int) or a new variable with it's own type (e.g. `a:int`).

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
  ;it is same as below:
  result = ( exp1 and exp2 ) @
  {
    true -> 11,
    false -> { -1 } 
  }
```
- You can have one variable declarations before the condition.
These declarations will be only available inside if/else block.
`if (var x=getResult(), x>0) ... else ...`
`if (var x=1, x>y)...`
- `xyz if(cond)` is also possible.

### assert (removed)
- If condition is not satisfied, it will return an error. 
- We have RIAA approach. Anything which is allocated inside a function which is not part of return value will be disposed (by calling `dispose` function) when exiting the function.
- Any assert which only uses `@` with generic types, will be evaluated at compile time. You can use this to implement generic constraints.
- `Exception` is a simple tuple defined in core. 
- You can use suffix if for assertion: `return xyz if !(str.length>0)`
- To handle exceptions in a code in rare cases (calling a plugin or another thread), you can use `invoke` core function.
`func invoke[I,O](f: func, input: I)->O|Exception`. If your function has more than one input, you should define a wrapper function or a closure which has one input of type tuple.
- In order to handle possible errors in a chain of function calls, you can use `opCall` on a type (e.g. Maybe). 
`func opCall[T](m: Maybe[T], f: func(T)->Maybe[T]) -> { return if m @ Nothing None else f(m) }`
`var input = 10`
`var finalResult: Maybe[int] = input(check1(5, _))(check2(_, "A"))(check3(1,2,_))`

- **Nothing**: Nothing is a sum type with only one value: `nothing`.
 You can use it's type for return value of a function.

### loop
You can use `loop` keyword with an array, hash, predicate or any type that has an iterator.
`loop(x <- [0..10])` or `loop([0..10])`
`loop(x <- [a..b])`
`loop(x <- my_array)`
`loop(k <- my_hash)`
`loop(n <- x>0)` or `loop(x>0)`
`loop(x <- IterableType) { ... }`
`loop(true) { ... }` infinite loop
- `break` and `continue` are supported like C.
- If expression inside loop evaluates to a value, `loop` can be used as an expression:
`var t:int[] = loop(var x <- {0..10}) x` or simply `var t:int[] = loop({0..10})` because a loop without body will evaluate to the counter, same as `var t:array[int] = {0..10}`
- Like if, you can have a variable declaration before main part. These varsiables will only be available inside loop block.
`loop(var t=getData(), t>0)...`
`loop(var t=getList(), x <- t)...`

## import
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
`type Map[K,V] := native` ;same for array
Denotes function is implemented by runtime or external libraries.
`native func file_open(path: string) -> File;`

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

## Array
- `string` is an array and like an array, compiler handles literals and string concatenation:
`var str: string = ["Hello ", str2, "World!"]`
`var str: string = [str1, str2]`

- Type of slice is different from array.
`myArray(10)` is translated to this function call: `opCall(myArray, 10)`. If it returns `var int` you can assign another value to it: `myArray(1) = g` will copy value of g to the array.
`func opCall[T](x: array[T], index: int) -> T`
slice is a meta-array. `type slice[T] = (length: int, start: T)`
- Upon initial value setting, operation is handled by the compiler, without calling opCall. Because opCall cannot set any value for a val array.
`func opCall[T](s: array[T], start: int, end: int) -> slice[T]`
means: `myArray(10,20)` will return a slice while `myArray(10)` will return a single element.
This function is overriden to support optional end.

- If an array is var, all it's elements are var. Same for hash and tuple. This means const is deep and transitive.
Arrays are a special built-in type. They are defined using generics. Compiler provides some syntax sugars to work with them.
`[0, ..., 3]` means `[0, 1, 2, 3]`
`[2, 4, ... , 100]` step=2, can be negative
`[0, 0, ... , 0x100]` repeat 0 for 100 times.
- In fact, anywhere that compiler detects these literals, it will call `opCall` for the expected type with index and value. So you can use this type of literal for your custom types too. If type is marked with `val`, a temporary var will be created for these operations.

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
- Upon initial value setting, operation is handled by the compiler, without calling opCall. Because opCall cannot set any value for a val map.

`myMap(10)` is translated to this function call: `opCall(myMap, 10)`
`myMap(10) = 19` is translated to: `opCall(myMap, 10, 19)`
`func opCall[K, V](x: map[K, V], index: K) -> V`

Maps, hashtables or associative arrays are a data structure to keep a set of keys and their corresponding values.
```
;defining and initializing a map
var y: map[string, int] = ["a": 1, "b": 2]

;read/write from/to a map
y("a") = 100
var t: int = y("b")
```
- In fact, anywhere that compiler detects these literals, it will call `opCall` for the expected type with key and value. So you can use this type of literal for your custom types too. If type is marked with `val`, a temporary var will be created for these operations.

- If you query a map for something which does not exist, it will return `Nothing`. Below shows two ways to read data from a map:
`if ( var t = my_map("key1"), t @ var x:int )`
`if ( var t = my_map("key1"), t !@ Nothing )`

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
- Testing
- Define a notation to access a location inside a binary and sizeof function
- Actor/Message passing helpers for concurrency.
- Helper functions to work with binary (memcpy, memmove, ...)
- Details of inline assembly flags and their values (OS, CPU, ...)
- Distributed processing: Moving code to another machine and running there (Actor model + channel)
- possible add notation for function chaining
