# Dotlang Programming Language Reference
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
- **Version 0.99**: ??? ??? ???? - Clarifications about primitive types and array/hash literals, ban embedding non-tuples, change chaining operator, changed notation for casting to be more readable, remove anything type, change notation for inference, removed lambda-maker and `$_` placeholder, clarifications about casting to function type and forwarding, removed opIndex, 

# Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Dotlang. 

Dotlang programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Scala, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most important features of OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent.

Three main goals are pursued in the design of this language:

1. **Simple**: The code written in Dotlang language should be consistent, easy to learn, read, write and understand. There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organise, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high (something like Java).

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  There are functions and types. Each function gets one or more input (each of it's own type) and gives an output. Types include primitive data types, tuple, sum types and a general type alias. Concurrency, lambda expression and exception handling are supported.

### Comparison
Compared with C: dotlang is C language + Garabage collector + first-class functions + template programming + sum data types + module system + composition and powerful polymorphism + simple and powerful standard library + immutability + exception handling + lambda expressions + closure + powerful built-in data types (hash, string,...) + multiple dispatch + sane defaults - ambiguities - pointers - macros - header files

dotLang compared to Scala: Scala - dependency on JVM - cryptic syntax - trait

dotLang compared to Go: Go + template programming + immutability + multiple dispatch + sum types + sane defaults + better orthogonality - pointers 


There is a runtime system which is responsible for memory allocation and management, interaction with OS and 
other external libraries and handling concurrency.
Also there is a `core` library which is used to implement some basic, low-level features which can not be 
simply implemented using pure Dotlang language.
The `std` library is a layer above runtime and `core` which contains some general-purpose and common functions and data structures.

### Code organization

There are three main entities: Primitive data types (`int`, `float`, ...), complex data structures and functions.
At very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.
Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `/core/sys, /core/net, /core/net/http, /core/net/tcp` are all packages.
Each package contains zero or more source code files, which are called modules. Modules contain data structure definitions and function definitions. Each module can reference other modules to call their functions or use their data structures.

### Structure of source code file

Each source code file contains 3 sections: import, types and function.
Import section is used to reference other modules that are being used in this module.
Type section is used to define data types.
Function section is used to define function bodies.

- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored.
- **Comments**: `;` is used to denote comment. It must be either first character of the line or follow a whitespace.
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number, `192.121d` double, `1234l` long. Also `true`, `false` are literals.
- You can separate number digits using undescore: `1_000_000`.
- **Adressing**: Functions are called using `function_name(input1, input2, input3)` notation. Fields of a tuple are addressed using `tuple_name.field_name` notation. Modules are addressed using `/` notation (e.g. `/code/st/net/create_socket`).
- Each statement must be in a separate line and must not end with semicolon.
Source file contains a number of definitions for types and functions.

*Notes:*
- If a name starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- The order of the contents of source code file matters: First `import` section, `type` section and finally functions. If the order is not met, compiler will give warnings.
- `any` denotes any type (It is defined in core). It is basically an empty type. Everything can be used for `any` type (primitives, tuples, unions, function pointers, ...). It can be something like an empty tuple. You have to initialize variables of type `any`.
- Immutability: All variables are immutable but can be re-assigned.

## Language in a nutshell

1. **Primitives**: `int`, `float`, `char`, `bool`
2. **Tuple**: `type Point := {x: int, y:int}`
3. **Union**: `type OperationResult := Point | int | Error`
4. **Array**: `type JobQueue := int[]`
4. **Hashtable**: `type CountryPopulation := string => int`
5. **Function**: `func functionName (x: int, y: string) -> float { *BODY* }`
6. **Variable**: `var location: Point = {x:10, y:20}`
7. **Import**: Is used to import types and functions defined in another file: `import /code/std/Queue`
8. **Generics**: `type Stack<T> := T[]`
9. **Immutability**: Only local variables are mutable. Everything else is immutable.
10. **Assignment**: Primitives are assigned by value, other types are assigned by reference.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Type System
We have two categories of types: named and unnamed.
Unnamed: `int, string[], float => int, (int,int)...` - They are created using language keywords and notations like 1. **Primitives**: `int`, `float`, `char`, `string`, ...
 type names, `any`, arry or hash, ....
Named: `type MyType := ?????` These are defined using `type` statement and on the right side we can have another named or unnamed type. Underlying type of a named type is the underlying type of declaration on the right side. Underlying type of unnamed types, is themselves. named type is a completely new type. it has no relation to the unnamed type except for underlying storage.
We have a special type: `Nothing`. 
We have 7 kinds of type: tuple, union, array, hash, primitive, function.
Subtyping is only defined for tuples.
- Tuple: C=(C1,...,Cn) and S=(S1,...,Sm) if Ci<:Si and n>=m and if both have named fields, they must match
`func process(x: int|string|float)`
You can pass int or string or float or `int|string` or `int|float` or `string|float` variables to it.
- two variables declared with the same named/unnamed type have the same type. 
- Two variables declared with two similar looking names but in different locations types have different types.
- Assignment of variables with similar looking (but different) named types to each other is forbidden.
- Assignment of variables with same named/unnamed types is allowed.
- Assignment from named to unnamed is possible with explicit cast.
- Assignment from unnamed to named is possible.
- Nothing variables have only one valid value: `nothing`.
- When a function expects a named type (`type SafeInt := int`), you have to pass a named type.
- But when a function expects an unnamed type, you can either pass named or unnamed type.
- Assigning a value of one named type to variable of a different named type is forbidden, even if the underlying type is the same. 

### Primitive
All others are defined based on these two plus some restrictions on size and accuracy.
- **Number data types**: `char`, `int`
- **Floating point data types**: `float`
- **Others**: `bool`, `Nothing`, `string`
Some other types are native types which are not primitive but are provided by compiler: `array`, `map`, `Nothing`, `string`

You can use core functions to get type identifier of a variable: `type` or `hashKeyType` or `hashValueType`.
`bool` and `none` are special types with only two and one possible values. `none` is used when a function returns nothing, so compile will change `return` to `return none`.
Some types are pre-defined in core but are not part of the syntax: `Nothing`, `bool`.
- `string` is an array of characters. And it is not a primitive.
- `byte` is 8 bit integer, but `char` can be larger to support unicode.

### Function type

### Array
Arrays are a special built-in type:
`type Array<T> := native`
But compiler provides syntax sugars for them:
1. `int[]` will be translated to `array<int>`
2. set and get of array elements is handled by the compiler.

- Array literals are specified using brackets: `[1, 2, 3]`
- `var x: int[] = [1, 2, 3];`
- `var x: int[] = [1..10];`
- `var y: int[3]; y[0] = 11;`
- `var t: int[n];`
- `var x: int[2,2];`. 
- `var pop: (string, int)[]` - dynamic array of tuples
- `var pop: string[4]` - static array of string
- We have slicing for arrays `x[start:step:end]` with support for negative index.
- we have built-in lists using same notation as array.
- every array can be extended by just adding elements to it (it will be a hybrid, array+list). 
- if you want to define a list from beginning, dont specify size.
- if you specify a size, it will be a mixed list (can be extended to become a list).
`var x: int[3]`  hybrid list
`var x: int[]`  pure list
`var x: int[3] = [1,2,3]` hybrid
`var x: int[] = [1,2,3]` pure
- Slice can be left side of an assignment.
- So if a function plans to accept inputs which are not native array, it can be defined like this:
`func process<T>(x: T, arrayFuncs: ArrAccessors<T>)` which means `x` input will have appropriate methods to be accessed like an array. Then inside `process` function it can use `x[0]` and other methods to work with x.

### Hashtable
Hashtable or Maps are built-in types:
`type Map<K,V> := native`
But compiler will provide syntax sugar for them:
`K=>V` => `Map<K,V>`
Hashtables are sometimes called "associative arrays". So their syntax is similar to arrays:
- `A => B` is used to define hash type. Left of `=>` is type of key and on the right side is type of value. If key or value have multiple elements, a tuple should be used.
- `var hash1: string => int`
- `hash1 = ['OH' => 12, 'CA' => 33]`
- `hash1["B"] = 19`
- `var big_hash: (int, int) => (string, int) = [ (1, 4) => ("A", 5) ]` 
- `big_hash[3,4] = ("A", 5)`
- If your code expects a hash which has `int` keys: `func f(x: int => any)...`
- If you query hash for something which does not exist, it will return `none`.

### Tuple or Product type

You use this statement to define a new product data structure:
```
type Car := {
  color: int, 
  age: int = 19, ;setting default value
}
var x: Car = {}   ;init x with all default values based on definition of Car
var y: Car = {age:11} ;customize value
var z = %Car(age:121) ;when we want to write a literal we can also specify its type with this notation
var z = %Car({age:121})
var t : {int, string} = {1, "A"}  ;you can have tuples with unnamed fields. They can be accessed like an array.
var number_one = t.0
t.1 = "G"
```
- Function output can be any type. Even a tuple or a tuple with unnamed fields.
- Fields that start with underscore are considered internal state of the tuple and better not to be used outside the module that defines the type. 
- You can define a tuple with unnamed fields: `type Point := {int, int}` But fields of a tuple must be all either named or unnamed. You cannot mix them.

### Tuple (Product types)
- Tuple definition: `type Point := {x: int, y: int}`
- Tuple literal: `var p: Point = %Point({x:10, y:20})`

```
type A :=  {x: int = 19} ;you can assign default value
type B := {A, y: int}    ;B inherits A. So in cases, it can be dynamically casted to A during method dispatch
type C := {}             ;empty tuple
type C := {y: int = 9}   ;setting default value
type D := {int=9, string="G"} ; unnamed fields. You can access them like an array. Also we can set default value.
```

To create a new tuple instance you just set it's type and assign it to an appropriate tuple:
```
var test: A = {x: 10}
var test2: A = {} ;no init 
var test3: D = {1,"A"}
var test4: C={9}
test3.0=9
test3.1="A"
var t = {x:6, y:5} ;anonymous and untyped tuple
```
- You cannot mix tuple literal with it's type. It should be inferred (type of lvalue or function output).

### Union or Sum type
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

### Custom Types
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
- Note that you cannot define your own casting function using `%TypeName{x}` name. Here `x` is a code block which will evaluate to something we want to cast. You can write cast functions using a standard name, however.
```
type A := (x:int, y: int)
type B := (x: int)
var t = A(x=10,y=20)
var w: B = (@A) ;this will fail, because type B does not have y
var w: B = B(@A) ;this will not fail because we are casting, so it will ignore extra data
```
- Casting examples:
`%int{x}`
`%string{x}`
`%OptionalInt{x}`
`%Point{var}`
`%Point{{x:10, y:20}}` --cast a tuple literal
`%Point{@t}` same as `%Point(t)`
`%Point<int>{{x:10, y:20}}` -- casting combined with type specialization
Casting to a tuple, can accept either a tuple literal or tuple variable or an exploded tuple.
Note that there is no support for implicit casting functions. If you need a custom cast, write a separate function and explicitly call it.
- `%Type{}` without input creates a default instance of the given type.
- When doing cast to a generic type, you can ignore type if it can be deduced. 

### Variables
Variables are defined using `var name : type`. If you assign a value to the variable, you can omit the type part (type can be implied).
Reasons for including type at the end:
- Due to type inference, type is optional and better not to be first part of the definition.
- More consistent with function declaration.
- Even C has `auto x = int{4}` declaration
- More readable and parseable
```
var x:int
var y : int = 19
var t = 12  ;imply type from 12
```
A function which has no input and returns `T` is treated like a variable of type `T`. This can be used to have lazy evaluation. So if you send the function/lambda to another function, to the outside world, it is int variable. inside they carry a lambda.
Cloning, passing, assigning to other vars does not change or evaluate the variable. But as soon as you have something like: `x=lazy_var+1` then function is being called.
- As soon as you declare a variable it will have some value. Even if it is a tuple, it will have all fields set to default value.
- You can define local variables using `var` keyword.
`var x: int = 19; x= 11 ;ok - can re-assign`
- You can define consts using functions: `func PI -> 3.14`

### Inheritance and Polymorphism
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
- **Explode operator**: You can apply this operator to data/variables. 
It will explode or unpack its operator and be replaced by the inner definition. 
You can use `_` notation when using explode on values, to ignore part of the output:
- Explode tuple: `var t,u = @p -> t=10, u=20`
`var x,y,_ = @my_three_ints`
`var first, _, last = @my_array`
- Explode operator: `@p ==> x:10,y:20`
To have a tuple with unnamed fields based on value of another tuple, just put `@` after the dot. So assume `Point` has x and y fields:
`@my_point` will translate to `x=10, y=20`
You can combine explode operator with other data or type definition as long as you change type of the field. `var g = {@my_point, z:20}`. g will be `{x:10, y:20, z:20}`. Explode on primitives has no effect (`@int` = `int`).
- If a type does not have any fields (empty types), you don't need to use embedding to inherit from it. It is optional. You just need to implement appropriate methods (If not, and those methods are defined empty for base type, a compiler error will be thrown). So if we have `func check(x: Alpha)` and `Alpha` type does not have any field, any other data type which implements functions written for `Alpha` can be used instead.
- Empty types are like interfaces and are defined like `type Alpha`.
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
- You can assign a variable any of it's subtypes (including empty type) variables. 
if a function expects `f: func()->Shape` you can send a function which returns a Circle, because there are implicitly castable.
If a function expects `x: Stack<Shape>` you cannot send `Stack<Circle>`.
- You can embed as many types as you want in your tuple, but the first field will be parent.
- To redirect a function to another one with types in the same hierarchy, you need to cast the argument.
`func process(Circle, SolidColor) -> process(%Shape{c}, %Color{sc})`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Functions
Function is a piece of code which accepts a series of inputs and can return a single value. If you want to use a tuple instead of entries of a function, you must explode it first unless function input is the tuple itself.
```
func my_func1(x: int, y: int) -> float { return x/y }
func my_func1(y:int) -> float { return $/3 } ;you must specify input name
func my_func(y:int, x:int) -> { 6+y+x } ;based on runtime arguments, one of implementations will be choosed
func my_func(5:int) -> 9
func my_func3(x: int, y: int) -> x/y  ;you can omit {} if its a single expression
func my_func7() -> int { return 10;} ;fn has no input but () is mandatory
func my_func7() -> 10  ;when function has just a return statement, there is a shortcut
func my_func8() -> (int, int) { return 10,20 } ;function can return multiple values
(x,y) = @my_func8()
func myFunc9(x:int) -> {y:int} {y:12} ;you can have named output

 ;below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

func map<T, S>(arr: T[], f: func(T) -> S) -> S[]

;these calls are all the same
new_array = map(my_array, {$+1})
```
- `map` can work on any type that supports iterable.
```
new_array = map(my_array, {$+1}) ;map will receive a tuple containing two elements: array and lambda
new_array = map(my_array , (x:int) -> {x+1})
```
- Everything is passed by reference but the callee cannot change any of its input arguments (implicit immutability) for parameters passed by reference.
- Parent is required when calling a function, even if there is no input.
- You can clone the data but have to do it manually using explode operator `@`. Note that assignment makes a clone for primitives, so you need cloning only for tuple, array and hash.
- Cloning: `var x = {@p}`
`var x: Point = {@original_var}`
`var x: Point = (@original_var, x=19)` clone and modify in-place
`var a = [1,2,3]`
`var b = [@a]`
`var h = string => int = ["A"=>1, "B"=>2]`
`var g = [@h]`
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
- Function input tuple can be accessed via `$` symbol.
- using type alias we can stress that some types must be equal in a function call.
```
type T
func add(x: T[], data: T)-> T    ;input must be an array and single var of the same type and same as output
add(int_array, "A") will fail
```
- This is a function that accepts an input of any type and returns any type: `type Function<I,O> := func(I)->O`.
- When calling a function, you can remove parentheses if there is no ambiguity (only a single call is being made).

### Matching
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

### Lambda expression
You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too, also  `func` keyword is not needed. 
```
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition
var rr = (x: int, y:int) -> { x + y }  ;return type can be inferred
var rr = { x + y } ;WRONG! - input is not specified
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition

type adder := (x: int, y:int) -> int
var rr: adder = (a:int, b:int) -> { a + b } ;when you have a type, you can define new names for input
var rr: adder = func { x + y }   ;when you have a type, you can also omit input
var rr: adder = { x + y }      ;and also func keyword, but {} is mandatory
var rr:adder = { $.0 + 2 }        ;you can use $.0 or $ alone instead of name of first input
func test(x:int) -> plus2 { return { $.0+ x} }
var modifier = { $.0 + $.1 }  ;if input/output types can be deduced, you can eliminate them
```
- You can access lambda input using `$.0, ...` notation too.
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

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Template
- When defining types, you can append `<A, B, C, ...>` to the type name to indicate it is a generic type. You can then use these symbols inside type definition.
- When defining functions, if input or output are of generic type, you must append `<A,B,C,...>` to the function name to match required generic types for input/output. 
- When you define a variable or another type, you can refer to a generic type using it's name and concrete values for their types. Like `Type<int, string>`
- Generic functions, must make use of their type argument in their input.
```
type Map<K,V> := K => V
type Stack<T> := T[]  ;define base type for generic type
func push<T>(s: Stack<T>, x: T)
func push<int>(s: Stack<int>, x: int) ;specialization
func pop<T>(s: Stack<T>) -> T
func len<T>(s: Stack<T>) -> int   ;general function for all instances
var t : Stack<int>
var h : Map<int, string>
push(t, 10) ;same as push<int>(t, 10)
var y = pop(t)
x = len(t)
```
`type optional<T> := Nothing | T`
`type Packet<T> :=   {status: T[], result: (x:int, y:int))`
`type IPPacket := Packet<int>`
`type Tree<T> := {x: T, left: Tree<T>, right: Tree<T>}`
`type ShapeTree := Tree<Shape>`
Example:
`func push<T>(x: Stack<T>, y: T)`
`func push(x: Stack<int>, y:int)`
if we call `push(a,6)` and `a` is `Stack<int>` second function will be called because there is full match.
if we call `stack<int>(a, b)` still the second one will be called.
- When calling a generic function, you can omit type specifier only if it can be deduced from input. If not, you must specify input.
Example: `func process<T>(x: int) -> T`
`process(10)` is wrong. You must specify type: `var g: string = process<string>(10)`
- If some types cannot be inferred from function input, you must specify them when calling the generic function.
```
type DepValue<T> := (value:T)
func magic<T>(that: DepValue<T>)->T that.value
var x = %DepValue<int>(1) ;x is int
var y = %DepValue<string>("a") ;y is string
var xx: int = magic(x)
var yy: string = magic(y)
```

## Protocol parameters
When writing a generic function, you may have expectations regarding behavior of the type `T`. These expectations can be defined in a tuple (called protocol tuple) as some function pointers. When calling this function, the code either should provide value or ask compiler to deduce values (using `^` notation)
```
;Also we can initialize tuple members, we have embedding
;Note that if T is a sum type, each function here can be multiple implemented functions
;This kind of type is called a protocol (specified a template for a group of functions)
type Eq<T> := {
    equals: func(x: T, y:T)->bool
    notEquals: func(x: Eq, y:Eq) -> bool = !equals(x,y)
    ;if any expected function does not have an input, we can declare it as a data field
    constValue: T ;will be calculated by calling constValue<T>()->int
}
;we can also use non-generic types to be later used as auto but its not very useful
;it can be used to have a handle to a function without method dispatch rules (exact match)
type Writer := {
    write: func(x: int, y:string)
    PI: func()->double
}

type Point := {x:int, y:int}
func equals(x: Point, y: Point)->bool { ... }
func notEquals(x: Point, y: Point)->bool { ... }

func isInArray<T>(x:T, y:T[], z: Eq<T>, g: Writer) -> bool {
    if ( z.equals(x, y[0])...
}
;when calling:
isInArray(x, arr, ^, ^)
---
type Ord<T> := {
    compare: func(x:T, y:T)->int
}
func sort<T>(x:T[], z: Ord<T>)
---
type Stringer<T> := {
    toString :func(x:T)->string
}
func dump<T>(x:T, z: Stringer<T>)->string
---
type Serializer<T> := {
    serialize: func(x:T)->string
    deserialize: func(x:string)->T
}
func process<T>(x: T, z: Serializer<T>) -> ...
---
type Adder<S,T,X> := {
    add: func(x: S, y:T)->X
}
func process<S,T,X>(x: S, y:T, z: Adder<S,T,X>)->X { return z.add(x,y) }
---
type Failable<T, U> := {
    oops: T<U>,
    pick: func(T<U>, T<U>)->T<U>,
    win: func(U)->T<U>
}
type Maybe<U> := U | Nothing
func oops<U>()->Maybe<U> { return Nothing }
func pick<U>(x: Maybe<U>, y: Maybe<U>)-> Maybe<U>
func win<U>(x: U) -> Maybe<U> { return x }

func safeDiv<T>(x: double, y: double, z: Failable<T, double>) -> T<double> {
    if ( y == 0 ) return z.oops
    return z.win(x/y)
}
;when calling above function, you must provide type of function
var t = safeDiv<Maybe>(x, y)

---
type Factory<T> := {
    create: func()->T
}
func create()->int { return 5 }
func create()->string { return "A" }
func generalCreate<T>(z: Factory<T>) { return z.create() }
;here we have to specify type because it cannot be inferred
var r = generalCreate<string>(^)
var y = generalCreate<int>(^)
---
;you can define primitives as auto
func process(auto item: int)
this will invoke `func item()->int` to provide value for this argument.
```
- Protocols can embed other types to include their fields.
- You can define and implement a protocol for a type outside your codebase, that's why you dont need to specify which protocols are implemented by a type upon declaration.
- You can use `^` anytime when calling a function to ask compiler to infer the parameter. For example if parameter is a function pointer, appropriate function with same name will be sent. If it is a primitive, a local variable with the same name or type (if not found, a function) will be used.


## Phantom types
Phantom are compile-time label/state attached to a type. You can use these labels to do some compile-time checks and validations. Here labels are implemented using generic types which are not used for data allocation.
For example we have a string which is result of md5 hash and another for sha-1. We should not be comparing these two although they are both strings. So how can we mark them?
```
type HashType := MD5 | SHA1
 ;when generic type is not used on the right side, it will be only for compile time check
type HashStr<T> := string     
type Md5Hash := HashStr<MD5> 
;Md5Hash type can be easily cast to string, but if in the code a string
;is expected to be of type Sha1Hash you cannot pass Md5Hash
type Sha1Hash := HashStr<SHA1>
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
type Expression<T> := (token: string)
func readIntExpression(...) -> Expression<INT>
func plus(left: Expression<INT>, right: Expression<INT>)...
func concat(left: Expression<STR>, right: Expression<STR>)...

;door
type DoorState := Open | Closed
type Door<T> := (string)
func closeDoor(x: Door<Open>) -> Door<Closed>
func openDoor(x: Door<Closed>) -> Door<Open>
```

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Notations

## Operators
- Conditional: `and or not == != >= <=`
- Math: `+ - * % %% (is divisible) ++ -- **`
The math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies only for primitive type, makes a variable refer to the same object as another variable for any other type. If you need a copy, you have to clone the variable. 
- `x == y` will call `opEquals` functions is existing, by default compares field-by-field values. But you can override.
- We don't have operators for bitwise operations. They are covered in core functions. 
- `equals` functions is used for equality check.
- You can have multiple assignments at once: `x,y=1,2`
- `+` can be used to merge two arrays. This can be used for string concatenation, because string is an array of chars.


### Special Syntax
- `@` explode 
- `#` chaining
- `$.i` function inputs tuple
- `%` casting
- `^` argument inference 
- `:` tuple declaration, array slice
- `:=` custom type definition
- `=>` hash type and hash literals
- `|` sum types
- `.` access tuple fields
- `[]` hash and array literals
- `::` matching
- `_` Placeholder for explode, anything catcher in pattern matching
- `{}` code block, tuple definition and literal
- `<>` generics
- `()` function call

Keywords: `import`, `func`, `var`, `type`, `defer`, `native`, `loop`, `break`, `continue`, `assert`
semi-Keywords: `if`, `else` (used in syntax sugar)
Operators: 
Primitive data types: `int`, `float`, `char` (int is signed and 64 bit, char is unsigned)
Helper data types: `bool`, `string`, `Array`, `Map`, `Nothing`
- `bool` is a simple sum type
- `string` is a named type based on char array.

### Chaining
Chain operators are just syntax sugars. They are transformed by compiler. 
`input#f(x,y)` means `f(input, x,y)`
`str#contains(":")`
So in above case for example, `contains` function must have two inputs. We just use this notation because sometimes it is easier to read. 
`[1,2,3]#map(square)#sum()`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

# Keywords

###match
```
MatchExp = '(' tuple ')' :: '{' (CaseStmt)+ '}'
```
- This is an expression. It is used to check if two variables can be matched according to matching rules.
- First case which is matching will be executed and others will be skipped.
- Case match can be based on value or type (used for sum types).
- Each match case is a lambda without parentheses for input. The first case that can accept the value inside match will be executed.
- Mechanism of match is the same as a function call is dispatched to an implementation. Each candidate will be examind against match input for type and values. The first one that can be matched will be invoked.
- The cases for match must cover all possible inputs or else there will be errors.
```
  result = my_tree ::
  {
    int, int -> ...;this will match if input has two ints 
    5 -> 11,
    "A" -> 19,
    local_var -> 22, ;check equality with a local variable's value
    Empty -> 0,
    int -> 1,
    y:float -> y,
    NormalTree -> { return 1+z },
    _ -> { -1 } ;this is default because it matches with anything
  }
  ;You can shorten this definition in one line:
  result = my_tree :: 5 -> 11, 6-> 12, Empty -> 0, x:int -> x, any -> -1
```
- Simple form: You can use `::` without `->` too to check for types which returns a bool: `if ( x :: int)`. In this format, you can check for a type or a literal.
- `if ( x :: y )` is invalid. Right side of match can either be a literal (e.g. 5) or a type (e.g. int) or a new variable with it's own type (e.g. `a:int`). you cannot use `::` to do `==` comparison. And in the shortcut form, you can only use type.

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
- You can also use suffix syntax for if: `Block if condition`
`var max = if (x > y) x else y`

```
  if ( exp1 and exp2 ) 11 else -1
  ;it is same as below:
  result = ( exp1 and exp2 ) ::
  {
    true -> 11,
    false -> { -1 } 
  }
```

###assert
This is a fucntion in core.
```
AssertStmt = 'assert' condition [':' exception]
```
- Assert makes sure the given `condition` is satisfied. 
- If condition is not satisfied, it will throw an exception (exception is a built-in type). This will exit current function and outer functions, until it is expected.
- In order to keep code more readable, you can not return an exception directly.
- There is no `throw` keyword and this is the only way to cause exception.
- Output of any function is automatically updated with `| exception` by the compiler (if needed).
- You can use `assert false, X` to create exception and return from current method immediately.
```
;inside function adder
assert false, "Error!"  ;throw exception and exit
;outside: catching error
;accept and expect the exception
var g: int|exception = func1()   ;this is valid
```
- You can use `defer BLOCK` to tell the runtime to run a block of code after exiting from the function. If function output is named, it will be accessible in defer block.
- Any assert which only uses `::` with generic types, will be evaluated at compile time. You can use this to implement generic bounds.
- Output of any code block `{...}` is evaluation of the last statement unless there is an exception. In which case, the block will exit immediately and this exit will cascade until some place that exception is bound to a variable.
```
var g = {
  func1()
  func2()
  func3()
}
return 100 if ( g :: exception)

var h : int|exception = get_number()
return x if ( h :: x:int)
```
- **Nothing**: Nothing is a sum type with only one value: `nothing`.
 You can use it's type for return value of a function.
 But there is no value you can return. `return` will do that.

###loop, break, continue
`loop(5) { ... }`
`loop(2,20) { ... }`
`loop(x:2,20) { ... }` assign a variable as loop counter value
`loop(x>5) { ... }`
`loop(x: array) { ... }`
`loop(k: hash) { ... }`
`loop(k,v: hash) { ...}`
`loop(x: IterableType) { ... }`
- `break` and `continue` are supported like C.
- If expression inside loop evaluates to a value, `loop` can be used as an expression:
`var t:int[] = loop(var x:10) x` or simply `var t:int[] = loop(10)` because a loop without body will evaluate to the counter.

### import
You can import a source code file using below statement. Note that import, will add symbols (functions and types) inside that source code to the current symbol table:
- You can only import one module in each import statement.

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
`native func file_open(path: string) -> File;`

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><

## Miscellaneous
### Validation
A predicate or label function is of the form `func predicate(x: any)->bool` (only one input and bool output). Any piece of data can have a number of labels attached to it which are results of calls to predicates on it. 
The important thing about labels is that they are transparently cached by runtime system. So further calls to the same label (predicate), will just re-use cached data. 
As a result, to implement predicate/validation/constraints/refinement types, you just call the function that checks the specific filter you need. Code becomes more readable and runtime makes the execution efficient. 
Another advantage: It won't interfer with method dispatch or subtyping.



### Best practice
### Naming
- **Naming rules**: Advised but not mandatory: `someFunctionName`, `my_var_name`, `SomeType`, `my_package_or_module`. If these are not met, compiler will give warnings.
- You can suffix if and for and `x loop(10)` will run x 10 times.

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
  return exp ::
  {
    x:int -> x,
    (op: char, left: Expression, right: Expression) -> op ::
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

Generally, anything that cannot be written in atomlang will be placed in this package.

## Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in dotlang). Here is a list of some of classes in this package collection:

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
Suppose someone downloads the source code for a project written in dotlang which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.

Perl has a `MakeFile.PL` where you specify metadata about your package, requirements + their version, test requirements and packaging options.
Python uses same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dep, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version metadata but no dep management. For dep it has NuGet.

## ToDo
- Runtime - use concept of c++ smart ptr to eliminate GC
- Add native concurrency and communication tools (green thread, channels) and async i/o
- Introduce caching of function output
- Build, versioning, packaging and distribution
- Dependency definition and management 
- Plugin system to load/unload libraries at runtime
- Debugger and plugins for Editors
- Atomic
- Testing

## Method call resolution
How runtime should handle a method call like: `f(x,y,z)`?
- Suppose that there is a call to function `f` with 3 input arguments. Here is the method dispatch process:
1. CL := find all functions with name `f` which have 3 inputs.
2. If inputs are named: remove from CL where there is name mismatch.
4. DT1, DT2, DT3 = dynamic type of 3 arguments specified in the call.
5. find x in CL where type of parameters are DT1, DT2, DT3
6. If found one, call `x` and finish. If found more than one -> Error and finish.
7. Look for a candidate which supports maximum number of dynamic types.

