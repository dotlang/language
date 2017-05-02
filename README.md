# Electron Programming Language Reference
Version 0.7 

Feb 19, 2017

## History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: ??? ??, 2017 - Clarifications for exception, unify type checking with pre/post condition, Adding `where` keyword, Sum types, New notation for hash-table and changes in defining struct, removed `const` due to adding sum types, reviewed inheritance notation and added explode operator.

##Introduction
##Code organization
##Structure of source code file
##Variable
##Struct
##Union
##Enum
##Functions
##Lambdas
##Templates
##Polymorphism
##Keywords
##Miscellaneous
###Special Syntax
###Validation
###Operators
###Casting
###Best practice




## Introduction
After having worked with a lot of different languages (C\#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

Electron programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Scala, Objective-C, Python, Perl, Smalltalk, Ruby, Swift, Haskell, Clojure, F\# and Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach and it is designed to work with data. There are no objects or classes. Only data structs and functions. But most important features of OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent.


Three main goals are pursued in the design of this language:

1. **Simple**: The code written in Electron language should be consistent, easy to learn, read, write and understand. There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organise, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high (something like Java).

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organised in directories (called packages).  There are functions and types. Each function gets one or more input (each of it's own type) and gives an output. Types include primitive data types, struct, union, enum and a general type alias. Concurrency, templates (generics), lambda expression and exception handling are supported.

In summary, Electron is C language + Garabage collector + templates (generic programming) + first-class functions + advanced unions + module system + composition and powerful polymorphism + operator customization + simple and powerful standard library + immutability + built-in data validation + contracts + exception handling + lambda expressions + closure + powerful built-in data types (hash, string,...) + built-in concurrency + built-in memoization + sane defaults - ambiguities - pointers - macros - header files.

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

## Structure of source code file

Each source code file contains 3 sections: import, types and function.
Import section is used to reference other modules that are being used in this module.
Type section is used to define data types.
Function section is used to define function bodies.

- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored.
- **Comments**: `;` is used to denote comment. It must be either first character of the line or follow a whitespace.
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number, `192.121d` double, `1234l` long. Also `true`, `false` are literals.
- You can separate number digits using undescore: `1_000_000`.
- **Adressing**: Functions are called using `function_name(input1, input2, input3)` notation. Fields of a struct are addressed using `struct_name.field_name` notation. Modules are addressed using `/` notation (e.g. `/code/st/net/create_socket`).
- Each statement must be in a separate line and must not end with semicolon.

## Variables



##Keywords
Electron has a small set of reserved keywords: 
`if, else, switch, 
, for, break, continue, return, type, import, var, val, func, invoke, select, native, struct`.

###if, else
```
IfElse = 'if' '(' condition ')' Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
Semantics of this keywords are same as other mainstream languages.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.
- You can also use suffix syntax for if: `Block if ( condition )`

###switch
```
SwitchExp = 'switch' '(' expression ')' '{' (CaseStmt)+ '}'
CaseStmt = (IdentifierList | 'else') '->' Block
```
- `switch` is an expression.
- First case which is matching will be executed and others will be skipped.
- Case match can be based on value or type (used for sum types).
- `else` case is executed if none of other cases match.
- You cannot use expressions for case statements. 
- Case identifiers should be either literals or simple identifiers (variable names).

You can also use switch without input in which case, all case blocks will be evaluated and the first one which evaluates to true will be executed.

###assert

```
AssertStmt = 'assert' condition [':' expression]
```
- Assert makes sure the given `condition` is satisfied. 
- If condition is not satisfied, it will throw `expression` exception.
- There is no `throw` keyword and this is the only way to cause exception.
- It is advised to return error code in case of an error and use exceptions in really exceptional cases.
- You can use `assert false, X` to create exception and return from current method immediately.
```
//inside function adder
assert false, "Error!"  //throw exception and exit
//outside: catching error
func ... var x = adder(5,6) ... } assert { var x: Exception = get_exception() if ( x.has_value ) ... }
```
- There is no `finally` in Electron. Each variable which is not part of return value of the function, will be cleaned-up upon function exit (even if there is an exception). This is done by calling `dispose` function on that type. You can also manually call this function in case you need to cleanup the resource earlier. 
- You can do custom cleanup or exception catching in post-conditions defined using assert keyword. This needs to be done after function body (post-condition) and in that block you can make a call to `get_exception` to check if there has been an exception.

###loop, break, continue
```
LoopStms = 'loop' ( Condition ) Block
LoopStms = 'loop' (number | variable) Block
LoopStms = 'loop' (var in Identifier) Block
BreakStmt = 'break' [Number] ';'
ContinueStmt = 'continue' [Number] ';'
```
- `loop` statement is used for running a block of code multiple times.
- First case: Run the block while the condition is met.
- Second case: Loop a specific number of times
- Third case: Iterate over elements of an array or keys of a hash.

`break 2` to break outside 2 nested loops. same for `continue`.
 
###return

###struct
You use this statement to define a new data structure:
```
type Car := struct {
  color: int, 
  age: int,
};
var x: Car;   //init x with all default values
var y: Car{age:11}; //customize value
x.age=19;  //invalid. x is immutable, you cannot change it's value. 
```
- Fields that starts with underscore are considered internal state of the struct and better not to be used outside the module that defines the type. 

###type
You can use `type` to define new type based on an existing type. 
You can also use it to define a type alias.

```
type point := int[];
type x := int;  //x will be an alias for int type
var a: x;  //=var a: int;
```
To use a type:
```
var pt: point = {1, 10};
//you can alias it again
type mypt := point;
var xx: mypt = {1, 2};
```

You can define an enum using sum types.
```
type DoW := SAT | SUN | ...
```

You can define functions based on `int` and `X` where `type X := int` and they will be different functions.

Note that when using type for alias to a function, you have to specify input names too.
`type comparer := func (x:int, y:int) -> bool;`

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

###native
Denotes function is implemented by runtime or external libraries.
`native func file_open(path: string) -> File;`

##Primitives
There are only three primitive data types: `any`, `number` and `string`. All others are defined based on these two plus some restrictions on size and accuracy.
- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`, `any`

##Source file

Source file contains a number of definitions for struct, type and functions.

*Notes:*
- If a name starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- The order of the contents of source code file matters: First `import` section, `type` section, structs and finally functions.
- `any` denotes any type. Everything can be used for `any` type (primitives, structs, unions, function pointers, ...). It can be something like an empty struct. You have to initialize variables of type `any`.
- Immutability: All variables are immutable but can be re-assigned.

###Tuple (Product types)
```
type A :=  (x: int = 19) ;you can assign default value
type B := (a: A, y: int) ;B composes A
type C := ()             ;empty struct
type C := (y: int = 9)   ;setting default value
type D := (int=9, string="G") ; unnamed fields. You can access them like an array. Also we can set default value.
```

To create a new struct instance you just set it's type and assign it to an appropriate tuple:
```
var test: A = (x: 10)
var test2: A = () ;no init 
var test3: D = (1,"A")
var test4: C=(9)
test3[0]=9
test3[1]="A"
var t = (x:6, y:5) ;anonymous and untyped tuple
```
- Note that if there is a multiple struct inheritance which results in function ambiguity, there will be a compiler error: 
`func x(p: P1)->int ...`
`func x(p: P2)->int ...`
`type A := struct{ x:P1, y:P2;}`
`var v: A{}; var t = x(A); //compiler error`
- You can access tuple fields, if all of the fields are unnamed.

###Sum types
When defining a sum type, you specify different types and labels that it can accept. Label can be any valid identifier.
`type Tree := Empty | int | (node: int, left: Tree, right: Tree)`
`type OptionalInt := None | int`
To match type, you can use switch expression:
```
  result = switch ( my_tree ) {
    case Empty -> 0
    case y:int -> 1
    case z:NormalTree -> ...
  }
```

###Functions

```
func my_func1(x: int, y: int) -> float { return x/y; }
func my_func2(x: int, y: int = 11 ) -> float { return x/y; }  //you can set default value
func my_func3(x: int, y: int) -> x/y;  //you can omit {} if its a single expression
func my_func7() -> int { return 10;} //fn has no input but () is mandatory
func my_func7() -> 10; //when function has just a return statement, there is a shortcut
func my_func8() -> (int, int) { return (10,20);} //function can return multiple values
(x,y) = my_func8(); 

 //below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

func map(f: func(T) -> T, arr: T[]) -> T[];  //map function
//these calls are all the same
new_array = map({$0+1}, my_array);
new_array = map({$0+1}, my_array);
new_array = map {$0+1}, my_array;
```
- Everything is passed by reference but the callee cannot change any of its input arguments (implicit immutability).
- You can clone the data but have to do it manually using explode operator `*`:
`var x: Point = (*original_var)`
- When calling a function, if a single call is being made, you can omit `()`. So instead of `int x = f(1,2,3);` you can write `int x = f 1,2,3;`
- You can define variadic functions by having an array input as the last input. When user wants to call it, he can provide an array literal with any number of elements needed.
- `rest` is a normal array which is created by compiler for each call to `print` function.
- Optional arguments and default values are not built-in but you can simply implement them:
`func f(x: int, y: int) ...`
`func f(x: int) -> f(x, 10);`
- Functions are not allowed to change (directly or indirectly) any of their inputs.
- You cannot ignore return value of a non-void function. This affects resource cleanup mechanism at runtime.
Functions can considered as a piece of code which accepts a tuple and returns a tuple. 
```
func f(x:int, y:float) -> (a: int, b: string)
{
  //returning anon-struct
  return (a:1, b:9) ;or return (1, 9)
}

func read_customer(id:int) -> Nothing | CustomerData
{
  ;no customer was found
  return Nothing
  
  ;some customer found
  return c1
}
```

###Variables
Variables are defined using `var name : type`. If you assign a value to the variable, you can omit the type part (type can be implied).
Reasons for including type at the end:
- Due to type inference, type is optional and better not to be first part of the definition.
- More consistent with function declaration.
- Even C has `auto x = int{4}` declaration
- More readable and parseable

```
var x:int;
var t = 12;
var y : int = 19;
var t = 12;  //imply type from 12
```

A function which returns `T` is treated like a variable of type `T`. This can be used to have lazy evaluation. So if you send the function/lambda to another function, to the outside world, it is int variable. inside they carry a lambda.
Cloning, passing, assigning to other vars does not change or evaluate the variable. But as soon as you have something like: `x=lazy_var+1` then function is being called.
- As soon as you declare a variable it will have some value. Even if it is a struct, it will have all fields set to default value.
- You can define local variables using `var` keyword.
`var x: int = 19; x= 11; //ok - can re-assign`
- You can define consts using functions: `func PI -> 3.14`
- You can define local const variables using: `var x: float = 3.14 where { false }`

## Templates
- You can use `where` keyword with types and functions to enforce template constraints. 
- You can specialize a generic functions and runtime will choose the most specific candidate.
```
type Stack := (x: any[])
type IntStack := Stack where { $.x :: int };
func pop(s: Stack) -> any { ... } where { $ :: s.x }
func push(x: any, s: Stack) where { x :: s.x[] }) -> ...
```

## Operators

- Conditional: `and or not == != >= <=`
- Bitwise: `~ & | ^ << >>`
- Math: `+ - * % ++ -- **`
The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator: copies only for number data type, makes a variable refer to the same object as another variable for any other type. If you need a copy, you have to clone the variable. 
- `x == y` will call `equals` functions is existing, by default compares field-by-field values. But you can o
- You can not override operators. 
- `x :: y` returns true if `x` can be cast to type of `y`. `y` can be either a variable or name of a type.
- `func add(x: any, y: any) assert { x :: y } ...`. For array `a[]` means type of elements of the array. For hash `h[]` means type of values inside hashtable, and `[h]` means type of keys of the hashtable.

## Special syntax
- `$i` function inputs
- `$` first input of the function (`$0`)
- `$_` input place-holder
- `:` for hash, call by name, array slice, loop
- `::` type check
- `:=` type definition
- `=>,<=` chaining
- `|` sum types

Kinds of types: `primitives`, `product`, `sum` and function.

###Inheritance and polymorphism
- Tuples can inherit from other structs by composing a variable of that type with explode operator (*). 
`type Shape := struct;`
`type Circle := struct {x:*Shape...}`
`type Square := struct {x:*Shape...}`
`type Polygon := struct {x:*Shape...}` 
- You can define functions on types and specialize them for special subtypes. This gives polymorphic behavior.
`func paint(o:Shape) {}`  
`func paint(o:any){}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
- If a function (`f1`) is implemented for parent type (`Shape`), and called with an instance of child (e.g. `Circle`) it will receive an instance of `Shape` which is a field of `Circle`. If `f1` function calls another function which is written for both parent and child types, it will be called for child (the highest ranked type).
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
Note that this binding is for an explicit function call. when we assign function to a variable, the actual function to be used, is determined at compile time according to static type. so `var x = paint` where type of x is `func(Circle, Color)` will find a paint function body with matching input. you cannot have x of type `func(Shape, Color)` and assign a value to it and expect it to do dynamic dispatch when called at runtime. There is a work-around which involves assigning a lambda to the variable which calls the function by name and passes inputs. in that case, invocation will include a dynamic dispatch.
So if we have this:
`func paint(o: Square, c: SolidColor)`
`type Shape := struct { name: string; }`
`type Circle := struct {x: Shape;}`
`type Square := struct {x:Shape;}`
`type Color := struct {};`
`type SolidColor := struct {x:Color;}`
a call to paint function with some inputs, will use above 3 rules to dispatch.
- suppose we have `Base` struct and `Derived` structs. Two methods `add` and `addAll` are implemented for both of them.
if `addAll(Derived)` calls `addAdd(Base)` which in turn calls `add(Base)` then a call to `addAll(Derived)` will NOT call `add(Derived)` but will call `add(Base)`. When `addAll(Base)` is called, it has a reference to `Base` not a `Derived`. 
- **Explore operator**: You can apply this operator to types (to define inheritance) and values. `var g: int[] = *my_three_int_tuple`. This operator can only be applied to product type (tuple) to have any effect. Otherwise it has no effect.

### Array and slice
- Array literals are specified using brackets: `[1, 2, 3]`
- `var x: int[] = [1, 2, 3];`
- `var y: int[3]; y[0] = 11;`
- `var t: int[n];`
- `var x: int[2,2];`. 
- We have slicing for arrays `x[start:step:end]` with support for negative index.
- we have built-in lists using same notation as array.
- every array can be extended by just adding elements to it (it will be a hybrid, array+list). 
- if you want to define a list from beginning, dont specify size.
- if you specify a size, it will be a mixed list (can be extended to become a list).
`var x: int[3]`  //hybrid list
`var x: int[]`  //pure list
`var x: int[3] = [1,2,3]` //hybrid
`var x: int[] = [1,2,3]` //pure
`add_element(x, 10);`

###Hashtable and Array
- `(A % B)` is ued to define hash type. Left of `%` is type of key and on the right side is type of value.
- `var hash1: (string % int) = { 'OH': 12, 'CA': 33};`.
- `loop(x in array1)` or `loop(key in hash1)`.
- `var num = hash1["A"]`
- `hash1["B"] = 19`
- `var pop: (string, int)[]` - dynamic array of tuples
- `var pop: string[4]` - static array of string
- `var big_hash: (int, int % string, int)` 
- `big_hash[3,4] = ("A", 5)`


###Validation
When defining types or functions, you can define validation code/function. This is a block which will be executed/evaluated everytime variable gets a new value or function is executed. You can makes sure the data (or function intput/output) is in consistent and valid state.
`var m: int where {validate_month};`
`var m: int where validate_month; //same as above`
Expression will be called with `$` pointing to the new value. If the expression evaluates to false, a runtime exception will be thrown.
`var x: int where {$>10} where {$<100} where { check_value($) };`
`type x := struct { x: int; y:int; } where { $.x < $.y };`
- This can be done for all types and variables.
- Example for functions:
`func AA(x: int) where { pre_check } -> int { ... } where { post_check }`
In post_check section, you can refer to the function output using `$` or `$0` notation.

###Chaining
You can use `=>` operator to chain functions. `a => b` where a and b are expressions, mean evaluate a, then send it's value to b for evaluation. `a` can be a literal, variable, function call, or multiple items like `(1,2)`. If evaluation of `b` needs more input than `a` provides, they have to be specified in `b` and for the rest, `$_` will be used which will be filled in order from output of `a`.
Examples:
```
get_evens(data) => sort(3, 4, $_) => save => reverse($_, 5);
get_evens(data) => sort => save => reverse; //assuming sort, save and reverse have only one input
5 => add2 => print;  //same as: print(add2(5))
(1,2) => mul => print;  //same as: print(mul(1,2))
(1,2) => mul($_, 5, $_) => print;  //same as: print(mul(1,5,2))
```
- You can also use `<=` for a top-to-bottom chaining, but this is a syntax sugar and compiler will convert them to `=>`.
`print <= add2 <= 5`

###Lambda expression

You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too.

```
var f1 = func(x: int, y:int) -> int { return x+y; } //the most complete definition
var rr = func (x: int, y:int) -> { x + y };  //return type can be inferred
var rr = func { x + y };` //WRONG! - input is not specified

type adder := func(x: int, y:int) -> int;
var rr: adder = func(a:int, b:int) -> { a + b }; //when you have a type, you can define new names for input
var rr: adder = func { x + y }; //when you have a type, you can also omit input
var adder = { x + y };      //and also func keyword, but {} is mandatory
var rr = { $0 + 2 };          //you can $0 or $ alone instead of name of first input
func test(x:int) -> plus2 { return { $0+ x}; }
```
- You can access lambda input using `$0, ...` notation too.
- You can also use `$_` place holder to create a new lambda based on existing functions:
`var y = calculate(4,a, $_)` is same as `var y = func(x:int) -> calculate(4,a,x);`
`var y = calculate(1, $_, $_)` is same as `var y = func(x:int, y:int) -> calculate(4,x,y);`

##Best practice
###Naming
- **Naming rules**: Advised but not mandatory: `some_function_name`, `someVariableOrFieldName`, `SomeType`, `my_package_or_module`.
- You can suffix if and for and `x for(10)` will run x 10 times.

##Examples
###Empty application
```
func main() -> 
{
    return 0; 
}
```
or even simper: `func main() -> 0`

This is a functrion, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

###Hello world
###Quick sort
###Graph class
###Expression parser

##Core packages

A set of core packages will be included in the language which provide basic and low-level functionality (This part may be written in C):

- Calling C/C++ methods
- Reflection
- Data conversion
- Garbage collector
- Function level storage (to simulate static method-local variables in a safe mechanism)

##Standard packages

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

##Package Manager

The package manager is a separate utility which helps you package, publish, install and deploy packages (Like `maven` or `dub`).
Suppose someone downloads the source code for a project written in Electron which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.

Perl has a `MakeFile.PL` where you specify metadata about your package, requirements + their version, test requirements and packaging options.
Python uses same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dep, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version metadata but no dep management. For dep it has NuGet.

##Misc

- Compiler will decide which methods should be inlined.
- Rule of locality: You should write a piece of code at the nearest location to where it applies (e.g. constraints). 

