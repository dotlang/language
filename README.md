## Electron Programming Language Reference
Version 0.5 

November 13, 2016 

##History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization

##Introduction
After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

Electron programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Scala, Objective-C, Python, Perl, Smalltalk, Ruby, Haskell, Clojure, F\#, Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach and it designed to work with data. There are no objects or classes. Only structs and functions. But most important features of OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent.

There is a runtime system which is responsible for memory allocation and management, interaction with OS and 
other external libraries and handling concurrency.
Also there is a `core` library which is used to implement some basic, low-level features which can not be 
simply implemented using pure Electron language.
The `std` library is a layer above runtime and `core` which contains some general-purpose and common functions.

Three main goals are pursued in the design of this language:

1. **Simple**: The code written in Electron language should be consistent, easy to learn, read, write and understand.
There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organize, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high (something like Java).

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files (called modules) organized in directories (called packages).  There are functions and types. Each function gets one or more input (each of it's own type) and gives an output. Types include primitive data types, struct, union, enum and a general type alias. Concurrency, templates (generics), lambda expression and exception handling are supported.

In summary, Electron is C language + Garabage collector + templates (generic programming) + first-order functions + advanced unions + module system + inheritance and polymorphism + simple and powerful standard library + immutability + built-in data validation + exception handling + lambda expressions + closure + powerful built-in data types (hash, string,...) + built-in concurrency + built-in memoization + sane defaults - ambiguity in type declaration - pointers - macros - header files.

### Core principles

There are three main entities: Primitive data types (`int`, `float`, ...), complex data structures and functions.
At very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.
Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core::sys, core::net, core::net::http, core::net::tcp` are all packages.
Each package contains zero or more source code files, which are called modules.

##Lexical Syntax
- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored.
- **Comments**: C like comments are used (`//` for single line and `/* */` for multi-line). `///` before function or field or first line of the file is special comment to be processed by automated tools. 
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number, `192.121d` double, `1234l` long. Also `true`, `false` are literals.
- You can separate number digits using undescore: `1_000_000`.
- **Adressing**: Functions are called using `function_name(input1, input2, input3)` notation. Fields of a struct are addressed using `struct_name.field_name` notation. Modules are addressed using `::` notation.

##Keywords
Electron has a small set of reserved keywords: 
`if, else, switch, assert, for, break, continue, return, type, import, var, func, invoke, select, native, struct`.

###if, else
```
IfElse = 'if' '(' condition ')' Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
Semantics of this keywords are same as other mainstream languages.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.
- You can also use suffix syntax for if: `Block if ( condition );`

###switch
```
SwitchStmt = 'switch' '(' expression ')' '{' (CaseStmt)+ '}'
CaseStmt = (IdentifierList | 'else') ':' Block
```
- `switch` is similar to what we have in C language.
- First case which is matching will be executed and others will be skipped.
- `else` case is executed if none of other cases match.
- You cannot use expressions for case statements. 
- Case identifiers should be either literals or simple identifiers (variable names).

You can also use switch without input in which case, all case blocks will be evaluated and the first one which evaluates to true will be executed.

###assert
```
AssertStmt = 'assert' condition [':' expression] ';'
```
- Assert makes sure the given `condition` is satisfied. 
- If condition is not satisfied, it will throw `expression` exception.
- There is no `throw` keyword and this is the only way to cause exception.
- It is advised to return error code in case of an error and use exceptions in really exceptional cases.
- You can use `assert false, X` to create exception and return from current method.
- You can use `#` as a suffix to define statement to be executed in case of exception. `$!` refers to the thrown exception.
```
//inside function adder
assert false, "Error!";  //throw exception and exit
//outside: catching error
`var x = adder(5,6) # adder(1,0) # { log("error occured " + $!); exit(5); };`
```
- There is no `finally` in Electron. Each variable which is not part of return value of the function, will be cleaned-up upon function exit (even if there is an exception). This is done by calling `dispose` function on that type. You can also manually call this function in case you need to cleanup the resource earlier.

###for, break, continue
```
ForStmt = 'for' ( Condition ) Block
ForStmt = 'for' ([Init ';'] Condition ';' Update) Block
ForStmt = 'for' (var ':' Identifier) Block
ForStmt = 'for' (var1, var2 ':' Identifier) Block
BreakStmt = 'break' [Number] ';'
ContinueStmt = 'continue' [Number] ';'
```
- `for` statement is used for running a block of code multiple times.
- First case: Run the block while the condition is met.

`break 2` to break outside 2 nested loops. same for `continue`.
 
###return

###struct
You use this statement to define a new data structure:
```
type Car := struct {
  color: int;
  age: int;
};
var x: Car;   //init x with all default values
var y: Car{age:11}; //customize value
x.age=19;   //as long as its not marked as const
```
- Fields that starts with underscore are considered internal state of the struct and better not to be used outside the module that defines the type. 

###type
You can use `type` to define new type based on an existing type. 
You can also use it to define a type alias.

```
type point := int[];
type x := int;
var a: x;  //=var a: int;
```
To use a type:
```
var pt: point = {1, 10};
//you can alias it again
type mypt := point;
var xx: mypt = {1, 2};
```

You can use type alias to narrow valid values for an int-based (like enum):
```
type DoW := enum {SAT=0, SUN=1, ...};  //any data of DoW type can only accept one of these values
```

You can define functions based on `int` and `X` where `type X := int` and they will be different functions.

Note that when using type for alias to a function, you have to specify input names too.
`type comparer := func (x:int, y:int) -> bool;`

###import

You can import a module using below statement:

```
import core`st::Socket;  //functions and types inside core/st/Socket.e file are imported
```
It is an error if as a result of imports, there are two exactly similar functions (same name, input and output). In this case, none of conflicting functions will be available for call. 

###invoke
We have `invoke` and `select` keywords. You can use `future<int> result = invoke function1();` to execute `function1` in another thread and the result will be available through future class (defined in core).

Also `select` evaluates a set of expressions and executes corresponding code block for the one which evaluates to true:
```
select
{
    read(rch1): { a = peek(rch1);}
    read(rch2): { b=peek(rch2);}
    tryWrite(wch1, x): {}
    tryWrite(wch2, y): {}
    true: {}  //default branch
}
```
You can use select to read/write from/to blocking channels.

###select

###native
Denote function is implemented by runtime or external libraries.
`native func file_open(path: string) -> File;`

##Primitives
- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

##Source file

Source file contains a number of definitions for struct, type and functions.

*Notes:*
- If a name starts with underscore, means that it is private to the module. If not, it is public. This applies to functions and types.
- The order of the contents of source code file matters: First `import` section, `type` section, structs and finally functions.

###Structs
```
type A := struct { x: int = 19; };  //you can assign default value
type B := struct { a: A; y: int; }; //B composes A
type C := struct;   //empty struct
type C := struct { y: int = 9; }; //setting default value
type Stack!T := struct { head: T; }; //generic structure.
type Stack<T: MyType> := struct { }; //generic structure with type constraint
```

To create a new struct instance:
```
var test : A = {x: 10};
var test2 : A{};  //{} is mandatory
var test2 : Stack<int>{};
```
- Note that if there is a multiple struct inheritance which results in function ambiguity, there will be a compiler error: 
`func x(p: P1)->int ...`
`func x(p: P2)->int ...`
`type A := struct extends P1, P2;`
`var v: A{}; var t = x(A); //compiler error`

###Enum
Enums are considered variables with a limited set of possible values.

```
//values are optional but if you specify, you have to set value for all - you can use any literal for the values
type DoW := enum { SAT=0, SUN=1,... };
x: DoW = DoW.SAT;
if ( int(x) == 0 ) ...
if ( x == DoW.SUN ) ...
type State := enum { ACTIVE='active', DISABLED='disabled' };
```
- You can attach constraints to enums.

###Union
Unions are also known as sum types. Variables of type union can accept only one of specified types at each time. You can use `var.field?` notation to check if variable contains value for a specific field. Other operations are same as struct. 

```
type sumtype := union {
  Nothing: bool;
  data: int;
  total: int;
};

x: sumtype = sumtype{data:12};  //total and Nothing will be empty/not-assigned
assert false == x.Nothing?;
assert false == x.total?;
assert true == x.data;

x.total = 0; //now x.data? will return false
//upon assigning a value to any of fields of a union type, all others will become empty.

type nullable_int := union { x: int; nil: bool; };
```
- You can attach constraints to union or it's fields just like structs.
- When you assign a value to any of fields of a union, all other fields are un-initialized automatically.
- If you only need to check if a field is set or not, you can ignore it's type:
```
type Maybe_int := union {
  data: T;
  Nothing;  //this is considered bool, but you cannot read it's value
};
var x = Maybe_int{data:12};  //data is set, Nothing is not set
var y = Maybe_int{Nothing}; //Nothing is set, data is not set

if ( y.Nothing? ) //y does not have data
if ( x.data? ) int r = x.data;

//you can use switch statement to check for fields.
switch { 
case x.Nothing?: {...}
case x.data?: {...}
```

###Functions

```
func my_func1(x: int, y: int) -> float { return x/y; }
func my_func2(x: int, y: int = 11 ) -> float { return x/y; }  //you can set default value
func my_func3(x: int, y: int) -> x/y;  //you can omit {} if its a single expression
func my_func7() -> int { return 10;} //fn has no input but () is mandatory
func my_func7() -> 10; //when function has just a return statement, there is a shortcut
func push!T(T data, Stack!T stack) {...}  //T is implicity specified by inputs to the function. so we don't need to specify them explicitly when calling push.
func my_func8() -> (int, int) { return (10,20);} //function can return multiple values
(x,y) = my_func8(); 

 //below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

func map!T(f: func(T) -> T, arr: T[]) -> T[];  //map function
//these calls are all the same
new_array = map!int({$1+1}, my_array);
new_array = map({$1+1}, my_array);
new_array = map {$1+1}, my_array;
```
- Everything is passed by reference but the callee cannot change any of its input arguments (implicit immutability). You can make a copy using `{}` operator: 
`x : MyType = {x:1, y:2};`
`y : MyType; y = x{};`
`y : MyType; y = x{y: 5};`  //clone with modification
- When calling a function, if a single call is being made, you can omit `()`. So instead of `int x = f(1,2,3);` you can write `int x = f 1,2,3;`
- You can use `params` to hint compiler to create appropriate array for a variadic function: `func print(x: int, params int[] rest) {...}` 
- `rest` is a normal array which is created by compiler for each call to `print` function.
- Optional arguments and default values are not built-in but you can simply implement them:
`func f(x: int, y: int) ...`
`func f(x: int) -> f(x, 10);`
- You can prefix function body with `cached` so runtime will cache output per input set and handle memory usage, cache clearing and ...: `func risk_markup(c: Contract)->float cached { //a lot of calculations; return result; }`
- Note that cached is not part of the type of the function.
- Functions are not allowed to change (directly or indirectly) any of their inputs. They can only change their local variables + return value.
- You cannot ignore return value of a non-void function. This affects resource cleanup mechanism at runtime.

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

##Templates
- You can define a struct/function using `!(T,U,V,...)` notation which means it is a template.
- If template has only one input, you can omit parents: `Stack!int`.
Definition:
`func adder!T(T a, T b) -> T { return a+b; }` => `var x = adder(10); OR var x - adder!int(10);`
`func adder!(T,S)(T a, S b) -> T { return a+b; }`
`type tuple!(S,T) := struct { a: S; b:T; };`
Usage:
`var t = adder(10,15);`
`var t = adder!(int,int)(10,15);`  //you can optionally state types or let compiler infer them
`var t: tuple!(int, string);`
- You can specializa a template.
`func adder!int(x:int)...`
`func adder!float(x:float)...`
When specializing a template, you can omit input/output part because they can be inferred from original signature. But in this case, you must use `$i` notation to refer to inputs.
`func adder!float -> {return 1+$1;}`
- You can define parent type of a template parameter using same notation we use for variable declaration:
`func paint!(T: Shape)(obj:T)`

##Operators

- Conditional: `and or not == != >= <=`
- Bitwise: `~ & | ^ << >>`
- Math: `+ - * % ++ -- **`
The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.
- `=` operator, makes a variable refer to the same object as another variable, by defaut. It is overriden for primitives to make a copy.
- You can clone a variable when doing assignment to be sure it will not be assign by ref.
- `x == y` will call `equals` functions is existing, by default compares field-by-field values.
- You can only override these operators: `==` (`equals`), `=>` (`bind`).

##Special syntax
- `$i` function inputs
- `$_` input place-holder in chaining
- `:` for hash, call by name, array slice, loop
- `!()` template syntax
- `:=` type definition
- `#` catch
- `$0` current exception
- `=>,<=` chaining
- `?` check for value existence in fields of union type

Kinds of types: `struct`, `union`, `enum`, `primitives`.

###Special variables
`true`, `false`

###Inheritance and polymorphism
- Struct, union and enum can inherit from same type. This will cause all members of the parent move to the child type. In case of name clash, there will be a compiler error.
`type Shape := struct;`
`type Circle := struct {...} extends Shape;`
`type Square := struct {...} extends Shape;`
`type Polygon := struct extends Shape;`
- You can define functions on types and specialize them for special subtypes. This gives polymorphic behavior.
`func paint(o:Shape) {}`  //you can even omit this definition if you want to disable `paint` for types which don't inherit from Object
`func paint(o:Object){}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
- We can keep a list of shapes in an array/collection of type Shape: `var o: Shape[] = {Circle{}, Square{}};`
- You can iterate over shapes in `o` array defined above, and call `paint` on them. With each call, appropriate `paint` method will be called (this appropriate method is identified using 3 dispatch rules explained below).
- Example: Equality check: `func equals(a:object, b:object)...` and specialize for types that you want to accept `==` operator: `func equals(a:Customer, b: Customer)...`
- Example: sorting a mix of objects: `func compare(a:object, b:object)` and `func compare(a: Record, b:Record)`;
- Example: Collission checking: `func check(a:S, b:T)...` and `func check(a: Asteroid, b: Earth)...` 
Then we can define an array of objects and in a loop, check for collissions.
- Visible type (or static type), is the type of the variable which can be seen in the source code. Actual type or dynamic type, is it's type at runtime. For example:
`func create(x:type)->Shape { if ( type == 1 ) return Circle{}; else return Square{}; }`
Then `var x: Shape = create(y);` static type of `x` is Shape because it's output of `create` but it's dynamic type can be either `Circle` or `Square`.
- Note that if A inherits from B, upon changes in variables of type A, constraints for both child and parent type will be called.
- When there is a function call `f(a,b,c)` compiler will look for a function `f` with three input arguments. If there are multiple function candidates, below 3 rules will be used:
1. single match: if we have only one candidate function (based on name/number of inputs), then there is a match.
2. dynamic match: if we have a function with all types matching runtime type of variables, there is a mtch. Note that in this case, primitive types have same static and dynamic type.
3. static match: we reserve the worst case for call which is determined at compile time: the function that matches static types. 
Note that this binding is for an explicit function call. when we assign function to a variable, the actual function to be used, is determined at compile time according to static type. so `var x = paint` where type of x is `func(Circle, Color)` will find a paint function body with matching input. you cannot have x of type `func(Shape, Color)` and assign a value to it and expect it to do dynamic dispatch when called at runtime. There is a work-around which involves assigning a lambda to the variable which calls the function by name and passes inputs. in that case, invocation will include a dynamic dispatch.
So if we have this:
`func paint(o: Square, c: SolidColor)`
`type Shape := struct { name: string; }`
`type Circle := struct extends Shape;`
`type Square := struct extends Shape;`
`type Color := struct {};`
`type SolidColor := struct extends Color;`
a call to paint function with some inputs, will use above 3 rules to dispatch.

###Array and slice
- `var x: int[] = {1, 2, 3};`
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
`var x: int[3] = {1,2,3}` //hybrid
`var x: int[] = {1,2,3}` //pure
`add_element(x, 10);`

###Hashtable
- `var hash1: int[string] = { 'OH': 12, 'CA': 33};`.
- `for(x:array1)` or `for(int key,string val:hash1)`.

###Casting
- There is a general function `func cast!(S,T)(source:S)->T` which is called to cast from `S` to `T`. You can specializa this function for your purposes (e.g `func cast!(BigInt, int)`).
- Casting of type to their parents is automatically provided. `var x: Parent = cast(childData);`
- For example, you can write `func cast!(DoW,int)(d: DoW)->int ...` function to provide custom code to convert Day-of-Week type to int.
- Value of a variable which is not explicitly initialized is given by a call to default function: `func default!T()->T`.
- You can also specialize this function for your types.
- You can ignore `T` part if type can be inferred: `var x: int = default;`. This can be useful in template functions.

###Anonymous struct/union

`var t: struct{x: int, y: int, z: float} = {1,2, 3.1};`  
`t.x = 8;`  
`var t: struct{x: int, y: int, z: float};`  
`t = {1, 9, 1.1};`  
Definition is same as a normal struct, only fields are separated using comma.

Functions can considered as a piece of code which accepts a tuple and returns a tuple. 
```
func f(x:int, y:float) -> struct{a: int, b: string} 
{
  //returning anon-struct
  return {a:1, b:9};
}

func read_customer(id:int) -> union { Nothing; custmer: CustomerData }
{
  //no customer was found
  return {Nothing};
  
  //some customer found
  return {customer: c1};
}
```

###Observers/Validation
When defining types, you can define an observer function for the type or some of it's parts. This is a function which will be notified everytime state of the bound variable changes. You can makes sure the data is in consistent and valid state, or inform a set of observers or anything.
`m: int [validate_month]` 
Above definition means, each update to the value of `m` will call `validate_month` function with the new value.
`type x := struct { month: int [validate_month] } [validate_data_func];`
Above means in addition to `validate_month`, we have another observer bound to the `x` type which will be called when value of any fields inside that type is changed or when the variable is re-assigned.
- This can be done for all types.

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
var rr = { $1 + 2 };          //you can $1 instead of name of first input
func test(x:int) -> plus2 { return { $1+ x}; }
```
- You can access lambda input using `$1, ...` notation too.
- You can also use `$_` place holder to create a new lambda based on existing functions:
`var y = calculate(4,a, $_)` is same as `var y = func(x:int) -> calculate(4,a,x);`
`var y = calculate(1, $_, $_)` is same as `var y = func(x:int, y:int) -> calculate(4,x,y);`
- You can define cached lambda: `plus2 rr = cached { $1 + 2 };` or `var f1 = func(x: int, y:int)->int cached{ return x+y; }`

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
