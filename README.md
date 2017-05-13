# Electron Programming Language Reference
Version 0.9

May 8, 2017

## History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: May 3, 2017 - Clarifications for exception, Adding `where` keyword, explode operator, Sum types, new notation for hash-table and changes in defining tuples, removed `const` keyword, reviewed inheritance notation.
- **Version 0.9**: May 8 2017 - Define notation for tuple without fields names, hashmap, extended explode operator, refined notation to catch exception using `//` operator, clarifications about empty types and inheritance, updated templates to use empty types instead of `where` and moved `::` and `any` to core functions and types, replaced `switch` with `match` and extended the notation to types and values, allowed functions to be defined for literal input, redefined if to be syntax sugar for match, made `loop` a function instead of built-in keyword.
- **Version 0.95**: ??? ?? ???? - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to speciying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, added `with` keyword for compile-time type constraints

## Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

Electron programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Scala, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data types and functions. But most important features of OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent.

Three main goals are pursued in the design of this language:

1. **Simple**: The code written in Electron language should be consistent, easy to learn, read, write and understand. There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organise, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high (something like Java).

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  There are functions and types. Each function gets one or more input (each of it's own type) and gives an output. Types include primitive data types, tuple, sum types and a general type alias. Concurrency, templates (generics), lambda expression and exception handling are supported.

In summary, Electron is C language + Garabage collector + templates (generic programming) + first-class functions + sum data types + module system + composition and powerful polymorphism + simple and powerful standard library + immutability + built-in data validation + contracts + exception handling + lambda expressions + closure + powerful built-in data types (hash, string,...) + built-in concurrency + built-in memoization + sane defaults - ambiguities - pointers - macros - header files.

There is a runtime system which is responsible for memory allocation and management, interaction with OS and 
other external libraries and handling concurrency.
Also there is a `core` library which is used to implement some basic, low-level features which can not be 
simply implemented using pure Electron language.
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
- You can put multiple statements in the same line using `&`: `x++ & run & process`
- Anywhere you need a compile time literal (default and optional inputs or `with`) you can use functions with constant output.

*Notes:*
- If a name starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- The order of the contents of source code file matters: First `import` section, `type` section and finally functions. If the order is not met, compiler will give warnings.
- `any` denotes any type (It is defined in core). It is basically an empty type. Everything can be used for `any` type (primitives, tuples, unions, function pointers, ...). It can be something like an empty tuple. You have to initialize variables of type `any`.
- Immutability: All variables are immutable but can be re-assigned.

## Language in a nutshell
1. **Primitives**: `int`, `uint`, `string`, ...
2. **Tuple**: `type Point := (x: int, y:int)`
3. **Union**: `type OperationResult := Point | int | Error`
4. **Array**: `type JobQueue := int[]`
4. **Hashtable**: `type CountryPopulation := string => long`
5. **Function**: `func functionName (*INPUT_TUPLE*) -> *OUTPUT_TYPE* { *BODY* }`
6. **Variable**: `var location: Point = (x:10, y:20)`
7. **Import**: Is used to import types and functions defined in another file: `import /code/std/Queue`
8. **Validation**: For any custom type: `type Age := int where { $ > 0 }`
9. **Immutability**: Only local variables are mutable. Everything else is immutable.
10. **Assignment**: Primitives are assigned by value, other types are assigned by reference.
All other features (loop and considtionals, exception handling, validation, inheritance and subtyping, polymorphism, generics ...) are achieved using above constructs.

## Type System
### Primitives
There are only three primitive data types: `number` and `string`. All others are defined based on these two plus some restrictions on size and accuracy.
- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`, `none`, `any`

You can use core functions to get type identifier of a variable: `type` or `hashKeyType` or `hashValueType`.
`bool` and `none` are special types with only two and one possible values. `none` is used when a function returns nothing, so compile will change `return` to `return none`.
Some types are pre-defined in core but are not part of the syntax: `none`, `any`, `bool`.

### Array
- Array literals are specified using brackets: `[1, 2, 3]`
- `var x: int[] = [1, 2, 3];`
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

### Hashtable
Hashtables are sometimes called "associative arrays". So their syntax is similar to arrays:
- `A => B` is used to define hash type. Left of `=>` is type of key and on the right side is type of value. If key or value have multiple elements, a tuple should be used.
- `var hash1: string => int`
- `hash1 = ['OH' => 12, 'CA' => 33]`
- `hash1["B"] = 19`
- `var big_hash: (int, int) => (string, int) = [ (1, 4) => ("A", 5) ]` 
- `big_hash[3,4] = ("A", 5)`
- If your code expects a hash which has `int` keys: `func f(x: int => any)...`

### Tuple

You use this statement to define a new product data structure:
```
type Car := (
  color: int, 
  age: int = 19, ;setting default value
)
var x: Car = ()   ;init x with all default values based on definition of Car
var y: Car = (age=11) ;customize value
var z = Car(age=121) ;when we want to write a literal we can also specify its type with casting notation
var t : (int, string) = (1, "A")  ;you can have tuples with unnamed fields. They can be accessed like an array.
var number_one = t.0
t.1 = "G"
```
- Function output can be any type. Even a tuple or a tuple with unnamed fields.
- Fields that starts with underscore are considered internal state of the tuple and better not to be used outside the module that defines the type. 
- You can define a tuple with unnamed fields: `type Point := (int, int)` But fields of a tuple must be all either named or unnamed. You cannot mix them.
###Tuple (Product types)
```
type A :=  (x: int = 19) ;you can assign default value
type B := (a: A, y: int) ;B composes A
type C := ()             ;empty tuple
type C := (y: int = 9)   ;setting default value
type D := (int=9, string="G") ; unnamed fields. You can access them like an array. Also we can set default value.
```

To create a new tuple instance you just set it's type and assign it to an appropriate tuple:
```
var test: A = (x= 10)
var test2: A = () ;no init 
var test3: D = (1,"A")
var test4: C=(9)
test3[0]=9
test3[1]="A"
var t = (x=6, y=5) ;anonymous and untyped tuple
```
- Note that if there is a multiple tuple inheritance which results in function ambiguity, there will be a compiler error: 
`func x(p: P1)->int ...`
`func x(p: P2)->int ...`
`type A := (x:P1, y:P2)`
`var v: A; var t = x(A)   ;compiler error`

### Union or Sum types
When defining a sum type, you specify different types and labels that it can accept. Label can be any valid identifier.
`type Tree := Empty | int | (node: int, left: Tree, right: Tree)`
`type OptionalInt := None | int`
To match type, you can use match expression:
```
  result = my_tree :: {
    Empty -> 0
    y:int -> 1
    z:NormalTree -> ...
  }
```

You can define an enum using sum types.
```
type DoW := SAT | SUN | ...
```

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
For example in return statement `return Circle(radius:1)`.

- You can use `with` keyword to put some compile-time restrictions on a type. This can be used for generics.
A type `T with { :: X }` means type is T but has to match to X.
`T with { B :: X }` means B element which is used inside T must be matchable to X. B can be either anoter type or part of type T.
```
type StackElement
type Stack := (head: StackElement, data: StackElement[])
var my_stack: Stack with { StackElement :: int }
func push(s: Stack, x: StackElement with { :: s.head })
func pop(s: Stack) -> StackElement with { :: s.head }
func mpush(s1: Stack, s2: Stack, x1: StackElement with { :: s1.head }, x2: StackElement with { :: s2.head })
func checkOnlyLong(s: Stack with { StackElement :: long })
func reverseMap(s: Map) -> Map with { :: s.Target => s.source }
```
So you can have:
`var x: Stack = DefStack where { $ > 0 } with { StackElement :: DataItem }`


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
- You can define local const variables using: `var x: float = 3.14 where { false }`

## Functions
Function is a piece of code which accepts a tuple and can return a single value. So any feature of a tuple/types, is supported for input or output of a function. If you want to use a tuple instead of entries of a function, you must explode it first unless function input is the tuple itself.
```
func my_func1(x: int, y: int) -> float { return x/y }
func my_func1(int) -> float { return $/3 } ;you can omit input name (like an unnamed tuple)
func my_func(y:int, x:int) -> { 6+y+x } ;based on runtime arguments, one of implementations will be choosed
func my_func(5, x:int) -> { 6+x } ;if input is a literal, any call which evaluates to that literal, will call this version
func my_func(5:int) -> 9
func my_func2(x: int, y: int = 11 ) -> float { return x/y }  ;you can set default value
func my_func3(x: int, y: int) -> x/y  ;you can omit {} if its a single expression
func my_func7() -> int { return 10;} ;fn has no input but () is mandatory
func my_func7() -> 10  ;when function has just a return statement, there is a shortcut
func my_func8() -> (int, int) { return (10,20) } ;function can return multiple values
(x,y) = my_func8()
func myFunc9(x:int) -> y:int { y=12 } ;you can have named output

 ;below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

;We can enforce same type constraints, simply by using types. Like below. `mapTarget` is basically same as `any`.
type mapTarget
func map(arr: mapInput[], f: func(mapInput) -> mapTarget) -> mapTarget[]

;these calls are all the same
new_array = map(my_array, {$+1})
```
- `map` can work on any type that supports loop.
- If last input of function is a lambda, it can be put outside paren without a comma, when calling it. This useful to make code readable in cases we call `loop` or `map`.
```
new_array = map(my_array) {$+1} ;map will receive a tuple containing two elements: array and lambda
new_array = map(my_array) (x:int) -> {x+1}
```
- Everything is passed by reference but the callee cannot change any of its input arguments (implicit immutability).
- You can clone the data but have to do it manually using explode operator `@`. Note that assignment makes a clone for primitives, so you need cloning only for tuple, array and hash.
`var x: Point = (@original_var)`
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
  return (a=1, b=9) ;or return (1, 9)
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
;note that even when you have a literal for an input, you must specify name and type.
func f(t:int =12, y:int) -> ... ; this will be invoked if first argument is 12
func f(x:int, y:int=6) ... ;this will be invoked if secod argument is 6 or missing
...
var g = (x=10, y=12)
f(g) ; this is not correct. f expects a tuple with x and y not a tuple with another tuple.
f(1,9)
f(x=1, y=9)
f(@g)
```
- You can use `with` keywords with `::` operator to put compile-time constraints on a function:
`func dowork(x: int, y: any with { :: Shape)` y must be of type Shape


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
- If function input is not constrained but the argument is, it won't cause a problem. But the other way around, will need casting.

### Lambda expression

You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too, also  `func` keyword is not needed. This keyword is needed when defining a normal function.
```
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition
var rr = (x: int, y:int) -> { x + y }  ;return type can be inferred
var rr = { x + y } ;WRONG! - input is not specified
var f1 = (x: int, y:int) -> int { return x+y } ;the most complete definition

type adder := (x: int, y:int) -> int
var rr: adder = (a:int, b:int) -> { a + b } ;when you have a type, you can define new names for input
var rr: adder = func { x + y }   ;when you have a type, you can also omit input
var rr: adder = { x + y }      ;and also func keyword, but {} is mandatory
var rr:adder = { $0 + 2 }        ;you can use $0 or $ alone instead of name of first input
func test(x:int) -> plus2 { return { $0+ x} }
var modifier = { $1 + $2 }  ;if input/output types can be deduced, you can eliminate them
```
- You can access lambda input using `$0, ...` notation too.
- You can also use `$_` place holder to create a new lambda based on existing functions:
`var y = calculate(4,a, $_)` is same as `var y = (x:int) -> calculate(4,a,x);`
`var y = calculate(1, $_, $_)` is same as `var y = (x:int, y:int) -> calculate(4,x,y);`

## Operators
- Conditional: `and or not == != >= <=`
- Math: `+ - * % ++ -- **`
The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies only for number data type, makes a variable refer to the same object as another variable for any other type. If you need a copy, you have to clone the variable. 
- `x == y` will call `equals` functions is existing, by default compares field-by-field values. But you can o
- You can not override operators. 
- We don't have operators for bitwise operations. They are covered in core. 
- `a & b` is a shortcut for `x=a y=b if (y == none ) return x else return y`
- An expression which is combination of multiple statements with `&` will result in evaluation of the last non-none one.
`var g = x=6 & y=7` will make g equal to 7.


### Special Syntax
- `$i` function inputs
- `$` first input of the function (`$0`)
- `$_` input place-holder
- `:` tuple declaration, array slice
- `:=` custom type definition
- `>>,<<` chaining
- `=>` hash type and hash literals
- `|` sum types
- `.` access tuple fields
- `@` explode
- `//` catch exceptions
- `&` continue execution
- `[]` hash and array literals
- `::` matching

### Chaining
You can use `>>` and `<<` operators to chain functions. `a >> b` where a and b are expressions, mean evaluate a, then send it's value to b for evaluation. `a` can be a literal, variable, function call, or multiple items like `(1,2)`. If evaluation of `b` needs more input than `a` provides, they have to be specified in `b` and for the rest, `$_` will be used which will be filled in order from output of `a`.
Examples:
```
get_evens(data) >> sort(3, 4, $_) ==> save >> reverse($_, 5);
get_evens(data) >> sort >> save >> reverse .   ;assuming sort, save and reverse have only one input
5 >> add2 >> print  ;same as: print(add2(5))
(1,2) >> mul >> print  ;same as: print(mul(1,2))
(1,2) >> mul($_, 5, $_) >> print  ;same as: print(mul(1,5,2))
```
- You can also use `<<` for a top-to-bottom chaining, but this is a syntax sugar and compiler will convert them to `>>`.
`print << add2 << 5`

## Keywords

###match
```
MatchExp = '(' tuple ')' :: '{' (CaseStmt)+ '}'
```
- This is an expression. It is used to check if two variables can be matched according to matching rules.
- First case which is matching will be executed and others will be skipped.
- Case match can be based on value or type (used for sum types).
- Each match case is a lambda without parentheses for input. The first case that can accept the value inside match will be executed.
- Mechanism of match is the same as a function call is dispatched to an implementation. Each candidate will be examind against match input for type and values. The first one that can be matched will be invoked.
- Result of a match expression is the data in the last return executed (or `none` if none).
```
  result = my_tree ::
  {
    x:int, y:int=12 -> ...;this will match if input has two ints or one int (second one will default to 12)
    5 -> 11,
    "A" -> 19,
    local_var -> 22, ;check equality with a local variable's value
    Empty -> 0,
    y:int -> 1,
    z:NormalTree -> { return 1+z },
    any -> { -1 } ;this is default because it matches with anything
  }
  ;You can shorten this definition in one line:
  result = my_tree :: 5 -> 11, 6-> 12, Empty -> 0, any -> -1
```
- You can use `::` without `->` too which returns a bool: `if ( x :: int)`

###if, else
- If/Else is a syntax sugar for match.

```
IfElse = 'if' '(' condition ')' Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
Semantics of this keywords are same as other mainstream languages.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.
- You can also use suffix syntax for if: `Block if ( condition )`
`var max = if (x > y) x else y`

```
  if ( exp1 and exp2 ) 11 else -1
  result = ( exp1 and exp2 ) ::
  {
    true -> 11,
    any -> { -1 } 
  }
```


###assert

```
AssertStmt = 'assert' condition [':' expression]
```
- Assert makes sure the given `condition` is satisfied. 
- If condition is not satisfied, it will throw an exception (exception is a built-in type). This will exit current function and outer functions, until it is expected.
- You can return an exception directly too: `return exception(1,2,3)`
- There is no `throw` keyword and this is the only way to cause exception.
- Output of any function is automatically updated with `| exception`.
- You can use `assert false, X` to create exception and return from current method immediately.
```
;inside function adder
assert false, "Error!"  ;throw exception and exit
;outside: catching error
var g: int = func1() // 5
var h: int = func1() // { return -1 }
;accept and expect the exception
var g: int|exception = func1()   ;this is valid
```
- You can use `defer BLOCK` to tell the runtime to run a block of code after exiting from the function. If function output is named, it will be accessible in defer block.
- `//` is used to catch exceptions. In `A // B` if A evaluates to an exception, then B (A lambda without input specification and arrow operator) will be evaluated. Inside `B` we can refer to result of `A` using `$` notation. Note that A can be a block of code.

###loop, break, continue
`loop` is a function defined in core. It uses `map` native function.
`func loop(cond: int | any[] | anyHash | func(any)->bool, body: func(x:any)->loopOutput)->loopOutput`
`loop(5) { print('hello') }`
`loop(arr1) { print($) }`
`loop(arr1) (x: int) -> { print(x) }`
`break` and `continue` are handled as exceptions inside the `loop` functions.
- We have 3 types of loops: numeric (repeat `n` times), predicated (repeat while true) or iteartion.
- For iteration loop, you can also use `map` and other similar functions.
```
;general iterator type definition
type iteratorType;
func hasNext(x: iteratorType) -> bool;
func next(x: iteartorType) -> any

;example of an iterator for array
func getIterator(x: any[]) -> iteartorType {
  var result: ArrayIteartor = (array:x, index:0)
  return result
}
func hasNext(i: ArrayIterator) -> i.index < length(i.array)
func next(i: ArrayIteartor) -> (i.array[i.index], (array:x, index:i.index+1))

native map(x: iteartorType, lambda)

func loop(x: int, lambda) -> { 
  var iteartor = createIterator(x)
  map(iteartor, body)
}

func loop(pred: lambda, body: lambda) -> {
  var iterator = createIteartor(pred)
  map(iteartor, body)
}

func loop(a: array, body: lambda) -> {
  var iterator = getIterator(a)
  map(iterator, body)
}
```
- To break a loop execution from body -> return exception
- To continue a loop -> return inside case body lambda.

 ###import

You can import a source code file using below statement. Note that import, will add symbols (functions and types) inside that source code to the current symbol table:

```
//Starting a path with slash means its absolute path (relative to include path). Otherwise it is relative to the current file
import /core/st/Socket;  //functions and types inside core/st/Socket.e file are imported and available for call/use
import /core/st/*;       //import source files under st dir
import /core/st/**;      //import everything recursively
import /core/st/Socket/;  //if you add slash at the end, it means import symbols using fully qualified name. This is used for refering to the functions using fully qualified names.
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
`import file/a/b` import from local file system
`import http/github.com/adsad/dsada` import from github

### native
Denotes function is implemented by runtime or external libraries.
`native func file_open(path: string) -> File;`

## Miscellaneous
### Validation
When defining a custom type, you can define validation code/function. This is a block which will be executed/evaluated everytime variable gets a new value or function is executed. You can makes sure the data is in consistent and valid state.
`type m := int where {validate_month};`
`type m := int where validate_month . ;same as above`
Expression will be called with `$` pointing to the new value. If the expression evaluates to false, a runtime exception will be thrown.
`type x := (x: int, y:int) where { $.x < $.y };`
- You are not allowed to use `where` in function or lambda definition. It's only allowed in variable or type declaration.

### Exception Handling
### Inheritance and Polymorphism
- Tuples can inherit from other tuples by having their fields (Manually adding them or with explode operator (`@`). This is similar to "Duck typing" in other languages but with data. So A can be trated like B if for every fields in B, I can write `A.field`. This allows developer to write subtypes for types he doesn't have access to. 
`type Shape := ();`
`type Circle := (@Shape...)`
`type Square := (@Shape...)`
`type Polygon := (@Shape...)` 
- You can define functions on types and specialize them for special subtypes. This gives polymorphic behavior.
`func paint(o:Shape) {}`  
`func paint(o:any){}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
- If a function (`f1`) is implemented for parent type (`Shape`), and called with an instance of child (e.g. `Circle`) it will receive an instance of `Shape` which is a field of `Circle`. If `f1` function calls another function which is written for both parent and child types, it will be called for child (the most specialized type).
- We can keep a list of shapes in an array/collection of type Shape: `var o: Shape[] = [Circle(), Square()];`
- You can iterate over shapes in `o` array defined above, and call `paint` on them. With each call, appropriate `paint` method will be called (this appropriate method is identified using 3 dispatch rules explained below).
- Visible type (or static type), is the type of the variable which can be seen in the source code. Actual type or dynamic type, is it's type at runtime. For example:
`func create(x:type)->Shape { if ( type == 1 ) return Circle{}; else return Square{}; }`
Then `var x: Shape = create(y);` static type of `x` is Shape because it's output of `create` but it's dynamic type can be either `Circle` or `Square`. Note that we assume proper definition of casting for types `Square` and `Circle` to `Shape`.
- Note that if A inherits from B, upon changes in variables of type A, constraints for both child and parent type will be called.
- When there is a function call `f(a,b,c)` compiler will look for a function `f` with three input arguments. If there are multiple function candidates, below 3 rules will be used:
1. single match: if we have only one candidate function (based on name/number of inputs), then there is a match.
2. dynamic match: if we have a function with all types matching runtime type of variables, there is a match. Note that in this case, primitive types have same static and dynamic type.
3. static match: we reserve the worst case for call which is determined at compile time: the function that matches static types. 
Note that this binding is for an explicit function call. when we assign function to a variable, the actual function to be used, is determined at runtime with dynamic dispatch. so `var x = paint` where type of x is `func(Circle, Color)` will find a paint function body with matching input. you can have x of type `func(Shape, Color)` and assign a value to it and expect it to do dynamic dispatch when called at runtime. 
So if we have this:
`func paint(o: Square, c: SolidColor)`
`type Shape := (name: string)`
`type Circle := (x: *Shape)`
`type Square := (x:*Shape)`
`type Color := ();`
`type SolidColor := (x:*Color)`
a call to paint function with some inputs, will use above 3 rules to dispatch.
- suppose we have `Base` type and `Derived` types. Two methods `add` and `addAll` are implemented for both of them.
if `addAll(Derived)` calls `addAdd(Base)` which in turn calls `add(Base)` then a call to `addAll(Derived)` will NOT call `add(Derived)` but will call `add(Base)`. When `addAll(Base)` is called, it has a reference to `Base` not a `Derived`. 
- **Explode operator**: You can apply this operator to types (also used to define inheritance) or accumulated values (values of type tuple or array or hash). If this is applied to a value of any other type, there will be compiler error. 
`var g: int[] = [@my_three_int_tuple]`. It will explode or unpack its operator and be replaced by the inner definition. Explode on data types can be used anywhere you want to define a tuple even for function input or output. 
`func add(@point) -> ` So add function will accept according to `point` data type.
You can use `_` notation when using explode on values, to ignore part of the output:
`var x,y,_ = @my_three_ints`
`var first, _, last = @my_array`
To have a tuple with unnamed fields based on value of another tuple, just put `@` after the dot. So assume `Point` has x and y fields:
`@my_point` will translate to `x:10, y:20`
`my_point.@` will translate to `10, 20`
`@Point` will translate to `x:int, y:int`
`Point.@` will translate to `int, int`
You can combine explode operator with other data or type definition. `var g = (@my_point, z:20)`. g will be `(x:10, y:20, z:20)`. Explode on primitives has no effect (`@int` = `int`).
- If a type does not have any fields (empty types), you don't need to use explode to inherit from it. It is optional. You just need to implement appropriate methods (If not, and those methods are defined empty for base type, a compiler error will be thrown). So if we have `func check(x: Alpha)` and `Alpha` type does not have any field, any other data type which implements functions written for `Alpha` can be used instead.
- Empty types are like interfaces and are defined like `type Alpha`.

### Templates
- You can use empty types or types with minimum required features, to define a template.
- You can specialize a generic functions and runtime will choose the most specific candidate.
```
type storable

type Stack := storable[]
func push(s: Stack, i: storable) ...
func pop(s: Stack) -> storable ...
```
- This type of specialization is useful for simple types where there are clear subtypes. For more general case you can use `with`.
- You can also use `with` to put compile time restrictions on types.
```
type StackElement
type Stack := (head: StackElement, data: StackElement[])
var my_stack: Stack with { StackElement :: int }
func push(s: Stack, x: StackElement with { :: s.head })
func pop(s: Stack) -> StackElement with { :: s.head }
func mpush(s1: Stack, s2: Stack, x1: StackElement with { :: s1.head }, x2: StackElement with { :: s2.head })
func checkOnlyLong(s: Stack with { StackElement :: long })
func reverseMap(s: Map) -> Map with { :: s.Target => s.source }

func work(s: Record) -> any with { => int :: s } filter hash key
func work(s: Record) -> any with { int => :: s } filter hash value
func work(s: Record) -> any with { [] :: s } filter for array
```

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

- Calling C/C++ methods
- Reflection
- Data conversion
- Garbage collector
- Function level storage (to simulate static method-local variables in a safe mechanism)
- Serialization and Deserialization
- Mocking a function
- RegEx operators and functions

## Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in Electron). Here is a list of some of classes in this package collection:

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
Suppose someone downloads the source code for a project written in Electron which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.

Perl has a `MakeFile.PL` where you specify metadata about your package, requirements + their version, test requirements and packaging options.
Python uses same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dep, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version metadata but no dep management. For dep it has NuGet.
