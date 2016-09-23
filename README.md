## Electron Programming Language Reference
Version 0.1  
September 4, 2016

##History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.

##Introduction
After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

Electron programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Scala, Objective-C, Python, Perl, Smalltalk, Ruby, Haskell, Clojure, F\#, Oberon-2). 
I call the paradigm of this language "Data-oriented". This is a combination of Object-Oriented and Functional approach. There are no objects or classes. Only structs and functions. But most important features of OOP (encapsulation, abstraction, inheritance and polymorphism) are provided to some extent.

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

As a 10,000 foot view of the language, code is written in files (called modules) organized in directories (called packages). Each file represents zero or more struct definitions (data fields) plus functions. Concurrency, templates (generics), lambda expression and exception handling are supported.

### Core principles

There are three main entities: Primitive data types (`int`, `float`, ...), complex data structures and functions.
At very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.
Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core.sys, core.net, core.net.http, core.net.tcp` are all packages.
Each package contains zero or more source code files, which are called modules.

##Lexical Syntax
- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(`\t`), newline(`\r` and `\n`) are whitespace and will be ignored.
- **Comments**: C like comments are used (`//` for single line and `/* */` for multi-line). `///` before function or field or first line of the file is special comment to be processed by automated tools. 
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0b0101011101` binary number, `192.121d` double, `1234l` long. Also `true`, `false` are literals.
- You can separate number digits using undescore: `1_000_000`.
- **Adressing**: Functions are called using `function_name(input1, input2, input3)` notation. Fields of a struct are addressed using `struct_name.field_name` notation.

##Keywords
Electron has a small set of basic keywords: 
`if, else, switch, assert, for, break, continue, return, defer, type, import, auto, select, native, defined, alloc, const`.

###if, else
```
IfElse = 'if' '(' condition ')' Block ['else' (IfElse | Block)]
Block  = Statement | '{' (Statement)* '}'
```
Semantics of this keywords are same as other mainstream languages.
- Note that condition must be a boolean expression.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a function with output of boolean) for condition.

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

###assert
```
AssertStmt = 'assert' condition [':' expression] ';'
```
- Assert makes sure the given `condition` is satisfied. 
- If condition is not satisfied, it will throw `expression` exception.
- There is no `throw` keyword and this is the only way to cause expression.

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
###throw
- It is advised to return error code in case of an error and use exceptions in really exceptional cases.
- You can use `assert false, X` to create exception and return from current method.
- You can use `defer` keyword (same as what golang has) for code that must be executed upon exitting current method.
- If defer has an input named `exc`, it will be mapped to the current exception. If there is no exception, defer won't be executed. If there are multiple defers with `exc` all of them will be executed.
- You can check output of a function in defer (`defer(out) out>0`) to do a post-condition check.

```
//inside function
assert false, "Error!";  //throw exception and exit
//outside: catching error
defer(exc) { ... }
```

###defer

###struct
You use this statement to define a new data structure:
```
type Car := struct {
  color: int;
  age: int;
};
```

###type
You can use `type` to define new type based on an existing type. 
You can also use it to define a type alias.

```
type point := int[];
type x := int;
x a;  //=int a;
```
To use a type:
```
point pt = {1, 10};
//you can alias it again
type mypt := point;
mypt xx = {1, 2};
```

You can use type alias to narrow valid values for an int-based (like enum):
```
type DoW := {SAT=0, SUN=1, ...};  //any data of DoW type can only accept one of these values
```

You can define functions based on `int` and `X` where `type X := int` and they will be different functions.

Note that when using type for alias to a function, you have to specify input names too.
`type comparer := func (x:int, y:int) -> bool;`

You can also use type to resolve type ambiguity. When you import two modules which have types with the same name.

###import

You can import a module using this statement:

```
import core.st.Socket;  //functions, types and structs inside core/st/Socket.e file are imported
```
It is an error if as a result of imports, there are two exactly similar functions (same name, input and output).
When you import a module, it's `_init` function will be called (if exists).

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
Denote fnuction is implemented by runtime or external libraries.
`native func f1(x:int, y:int) -> float;`

###defined
`if ( defined x)` returns true if x is not `nil`.


##Primitives
- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

##Source file

Source file contains a number of definitions for struct, type and functions.

*Notes:*
- If a function name starts with underscore, means that it is private to the module. If not, it is public.
- The order of the contents of source code file matters: First `import` section, `type` section, structs and finally functions.

###Structs
```
type A := struct { x: int; };  //you cannot assign value in struct
type B := struct { A; y: int; }; //B inherits from A, you can use b.x or b.A.x to refer to x field
type C := struct;   //empty struct
type C := struct { y: int = 9; }; //setting default value
type C := struct { y: const int; }; //y is immutable, you can only set its value upon creation
type C := struct { F; z: const int; };  //z is a reference to F.y
type Stack<T> := struct { }; //generic structure
```

To create a new struct instance:
```
var test : A{x: 10};
var test2 : A{};  //{} is mandatory
var test2 : Stack<int>{};
```
- If all fields of a struct are const, it is immutable.

###Functions

```
func my_func1(x: int, y: int) -> float { return x/y; }
func my_func2(x: int, y: int = 11 ) -> float { return x/y; }  //you can set default value
func my_func3(x: int, y: int) -> x/y;  //you can omit {} if its a single expression
func my_func4(x: int, y: const int) -> x/y;  //function will not change value of y
func _my_func6(x: int, y: int) -> x/y;  //this function won't be accessible outside the module
func my_func7(x: int, y: int) {} //functions returng nothing, so -> is optional
func my_func7() -> int { return 10;} //fn has no input but () is mandatory
func push<T>(T data, Stack<T> stack) {...}
func my_func8() -> (int, int) { return (10,20);} //function can return multiple values
(x,y) = my_func8();  //but there is no tuple

 //below function receives an array + a function and returns a function
func sort(x: int[], comparer: func(int,int) -> bool) -> func(int, bool) {}

func map<T>(f: func(T) -> T, arr: T[]) -> T[];  //map function
new_array = map<int>({$$+1}, my_array);
```
- Everything is passed by reference.
- When calling a function, if a single call is being made, you can omit `()`. So instead of `int x = f(1,2,3);` you can write `int x = f 1,2,3;`

###Variables
Variables are defined using `var name : type`. If you assign a value to the variable, you can omit the type part.
By default everything is mutable unless it's type has `const`.

```
var x:int;
var t = 12;
var y : const int = 19;
var t: const = 12;  //imply type from 12 and make it const
```
- You cannot pass a variable of type `const int` to a function which expects `int`. 
- You can send `const int` or `int` to a function which expects `const int`.

##Operators

- Conditional: `and or not == != >= <=`
- Bitwise: `~ & | ^ << >>`
- Math: `+ - * % ++ -- **`
The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.


- `=` operator, makes a variable refer to the same object as another variable.
- `x == y` will call `equals` functions is existing, by default compares field-by-field values.

##Special syntax
- `~x` makes a copy of x
- `#` for annotations on fields and structs
- `:` for hash, call by name, array slice, loop
- `<>` template syntax
- `$$` only input in lambda
- `$_` input place-holder in chaining
- `@` casting
- `:=` type alias

###Special variables
`true`, `false`

###Composition

- If struct contains a field defined using `::` the struct will be castable to those fields.

```
type x := struct {
    a: int;
    b: int;
    a:: A;
    :: C; //this struct supports functions written for C, but C has no field, so we don't need a field name
};
```
- You can cast instances of `x` to `A` and `C`.

###Annotations
You can annotate a struct or field with this syntax:
`#custom_name{key1:value1, key2:value2, ...}`
custom_name is whatever you want. `value(i)` is optional and is assumed to be `true` if omitted.
for example:
`x: int #json{ignore};`
`x: const int #json{ignore};`

- `core` provides functions to extract annotations.

###Array and slice

- `var x: int[] = {1, 2, 3};`
- `var y: int[3]; y[0] = 11;`
- `var t: int[n];`
- `var x: int[2,2];`. 
- We have slicing for arrays `x[start:step:end]` with support for negative index.

###Hashtable
- `var hash1: int[string] = { 'OH': 12, 'CA': 33};`.
- `for(x:array1)` or `for(int key,string val:hash1)`.
- 

###Casting
- `@MyStruct(my_obj)` will try to cast `my_obj` instance to `MyStruct` type. This is only possible if MyObj (type of `my_obj`) composes a field of type `MyStruct`.
- `float f; int x = @int(f);` this version is used for casting primitives.
- empty/undefined/not-initialized state of a variable is named "default" state and is shown by `nil`.
- Value of a variable before initialization is `nil`.
- You can also return `nil` when you want to indicate invalid state for a variable.

###Undef instance

###Chaining
You can use `=>` operator to chain functions. `a => b` where a and b are expressions, mean evaluate a, then send it's value to b for evaluation. `a` can be a literal, variable, function call, or multiple items like `(1,2)`. If evaluation of `b` needs more input than `a` provides, they have to be specified in `b` and for the rest, `$_` will be used which will be filled in order from output of `a`.
Examples:

`get_evens(data) => sort(3, 4, $_) => save => reverse($_, 5);`
`get_evens(data) => sort => save => reverse;` //assuming sort, save and reverse have only one input
`5 => add2 => print;`  //same as: print(add2(5))
`(1,2) => mul => print;`  //same as: print(mul(1,2))
`(1,2) => mul($_, 5, $_) => print;`  //same as: print(mul(1,5,2))

###Lambda expression

You can define a lambda expression or a function literal in your code. Syntax is similar to function declaration but you can omit output type (it will be deduced from the code), and if type of expression is specified, you can omit inputs too.

```
auto f1 = func(x: int, y:int) -> int { return x+y; } //the most complete definition
auto rr = func (x: int, y:int) -> { x + y };  //return type can be inferred
auto rr = func { x + y };` //WRONG! - input is not specified

type adder := func(x: int, y:int) -> int;
adder rr = func(a:int, b:int) -> { a + b }; //when you have a type, you can define new names for input
adder rr = func { x + y }; //when you have a type, you can also omit input
adder rr = { x + y };      //and also func keyword
adder rr = x + y;          //only if type is specified, you can omit {} too
plus2 rr = $$ + 2;          //if type has only one input, you can $$ instead of its name
```

##Best practice
###Naming
- **Naming rules**: Advised but not mandatory: `some_method_name`, `someVariableName`, `MyStruct`, `my_package_or_module`.

##Examples
###Empty application
```
func main() -> int
{
    return 0; 
}
```
This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

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
- Exception handling

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

