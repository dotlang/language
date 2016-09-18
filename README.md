## Electron Programming Language Reference
Version 0.1  
September 4, 2016

##History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.

##Introduction
After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

Electron programming language is a general purpose language based on author's experience and doing research on 
other languages (namely Java, C\#, C, C++, Rust, Go, Python, Perl, Smalltalk and Ruby). This language is 
Object-oriented, although some of more common OOP techniques are implemented differently. 

There is a runtime system which is responsible for memory allocation and management, interaction with OS and 
other external libraries and handling concurrency.
Also there is a `core` library which is used to implement some basic, low-level classes and operators which can not be 
simply implemented using pure Electron language.
The `std` library is a layer above runtime and `core` which contains some general-purpose and common classes.
This document explains about 

Three main goals are pursued in the design of this language:

1. **Simple**: The code written in Electron language should be consistent, easy to learn, read, write and understand.
There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organize, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages and something like Java.

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files organized in directories (called packages). Each file represents one and
only one class (fields + methods). In Electron, class can be analogous to class or abstract class or interface in other languages. Classes can import other packages to use their classes. Concurrency, templates (generics), anonymous functions/classes and exception handling are supported.

### Core principles

Almost everything is an object, even basic data types and everything is passed by value, but everything is a reference.
Every class has a special, default instance, which is created by the compiler. This instance can be used to create other instances of the class.
At very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.
Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core.sys, core.net, core.net.http, core.net.tcp` are all packages.

##Lexical Syntax
- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(\t), newline(\r and \n) are whitespace and will be ignored.
- **Comments**: C like comments are used (`//` for single line and `/* */` for multi-line). `///` before method or field or first line of the file is special comment to be processed by automated tools. 
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0x0101011101` binary number, `192.121d` double, `1234l` long. - **Literlas**: `0xffe`, `0b0101110101`, `true`, `false`, `119l` for long, `113.121f` for float64.
- You can separate number using undescore: `1_000_000`
- Compiler will handle object literals and create corresponding objects (for field and variable assignment, default argument value, enum values, tuple initialization, ...).
- `true` is a shortcut for `bool.true`, same for `false`.
- **Adressing**: Each type, field or method can be address in the format of `A.B.(...).D` where `A`, `B` and other parts are each either name of a package, class or field. The last part `D` is name of the field or method or type which is being addressed.

##Keywords
Electronc has a small set of basic keywords: `if, else, switch, assert, for, break, continue, return, defer, type, import, auto, select, native, defined, typename, alloc`.



###if, else
```
IfElse = 'if' ( condition ) Block ['else' ( IfElse | Block)]
Block = Statement | { (Statement)* }
```
Semantics of this keywords are same as other mainstream languages.
- Note that condition must be of type `bool`.
- You can use any of available operators for condition part. 
- Also you can use a simple boolean variable (or a method with output of boolean) for condition.

###switch
```
SwitchStmt = 'switch' ( expression ) { (CaseStmt)+ }
CaseStmt = (IdentifierList | 'else') ':' Block
```
- `switch` is same as what we have in C language except you can have any expression in the cast list.
- First case which is matching will be executed and others will be skipped.
- `else` case is executed if none of other cases match.
- You cannot use expressions (which implies a side-effect) for case statements. 
- Case identifiers should be either literals or simple identifiers (variable names).
- For each case, the `==` operator will be called on the result of the expression for comparison.

###assert
```
AssertStmt = 'assert' condition [',' expression] ';'
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
- If defer has an input named `out`, it will be mapped to the function output.
- If defer has an input named `exc`, it will be mapped to the current exception. If there is no exception, defer won't be executed. If there are multiple defers with `exc` all of them will be executed.
- You can check output of a function in defer (`defer(out) out>0`) to do a post-condition check.

```
//inside function
assert false, "Error!";  //throw exception and exit
//outside: catching error
defer(exc) { ... }
defer(out, exc) { ... }

defer(out) { if ( out != $int ) out++; }  //manipulate function output
defer(out) assert out>0;  //post-condition check
```

###defer
###type
You can use `type` to define type alias:
```
type point := int[];
type x := int;
x a;  //=int a;
```
To use a type from outside the defining class:
```
MyClass.point pt = (1, 10);
//you can alias it again
type mypt := MyClass.point;
mypt xx = (1, 2);
```

You can use type alias to narrow valid values for a type (like enum):
```
type DoW := int (SAT=0, SUN=1, ...);
```

###import

Same as other members, types starting with underscore are private.

```
import core.st;
import core.st => cst;  //alias import
```

###auto
###invoke
We have `invoke` and `select` keywords. You can use `%future(int) result = invoke obj.method1();` to execute `obj.method1` in another thread and the result will be available through future class (defined in core).

Also `select` evaluates a set of expressions and executes corresponding code block for the one which evaluates to true:
```
select
{
    rch1.tryRead(): { a = rch1.peek();}
    rch2.tryRead(): { b=rch2.peek();}
    wch1.tryWrite(x): {}
    wch2.tryWrite(y): {}
    true: {}  //default branch
}
```
You can use select to read/write from/to blocking channels.

###select

###native
Denote method is implemented by runtime or external libraries.

###defined
`if ( defined x)` returns true if x is default instance.


###typename
for templates

##Primitives
- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

##Class file

Each source code file represents one class and has two important parts: part where fields are defined, and method definition.
Writing body for methods is optional (but of course if a body-less method is called, nothing will happen and an empty response will be received). Classes with no method body are same as interfaces (or abstract class with all methods marked as virtual) in other languages but in Electron we don't have the concept of interface.

*Notes:*
- There is no inheritance. Composition is used instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, `type` section, `struct` and finally methods.

###Class members

```
//you can define class fields only in struct section
//note that all class fields are accessible only by class methods.
struct {
int _x = 12;  //private
int qq = 19;  //public
int qw = this[qq] //WRONG! there is no `this`
const int x; //this is not re-assignable. after object is created using alloc.

int h = 12;
int gg;
}
//below we simulate const!
float PI() { return 3.14; } //calling obj.PI() is same as obj.PI because PI method does not have any input
PI :: 3.14;  //another way to implement above
PI :: this.get_pi_value; //another way to implement above
float get_pi_value() { return 3.14;}

int func1(int y) { return this.x + y; }
func2 :: this.func1;  //redirect calls to func1, methods must have same/compatible signature
:: this.func5;  //same as above but left side of :: has the same name as right side
//for any more complex case, write the body.
ff :: this.function2; //redirect to another function
//note that you can only "assign" to a function, when declaring it.
func3 :: this.func2;  //compiler will infer the input/output types for func3 from func2 signature
this new() return alloc();  //new is not part of syntax. You can choose whatever name you want,

```
- Any class without fields is immutable from compiler's perspective (this includes primitive types). This will help runtime to optimize the code. Also if all fields are const, and their type is immutable, then class is immutable.
- Class members (methods and types) starting with underscore are considered private and can only be accessed by methods of the same class. So `obj._x` is ok if the code is inside the class type of `obj`.
- Here we have `new` method as the constructor (it is without braces because it has only one statement), but the name is up to the developer. Ctor returns `this` which basically of the same type as the current class. The only difference is that you can call it on the default instance: `MyClass mc = $MyClass.my_ctor(10, 20)`. You cannot use `this` inside ctor because they may be called on the default instance.
- If class does not have a ctor, compiler will generate a default no-input ctor, named `new`. You can call it by `auto x = $MyClass.new`.
- You can not have multiple methods with body with the same signature in a single class. 
- You can define optional arguments: `int f(int x,int y=1)` the value must be a literal or undef.
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this[x] = 12` instead of `x = 12`). `this` is not re-assignable variable.
- When a variable is in undefined state and we call one of it's type's methods, the method will be called normally with empty `this`. If we try to read it's fields, it will crash.
- If a method has no body, you can still call it and it will return undef. You can also call methods on an undef variable and as long as methods don't need `this` fields, it's fine.
- `int f(int x) return x+1;` braces can be eliminated when body is a single statement.
- **Variadic functions**: `bool bar(int... values)`. values will be an array of int.
- Method argument names or local variables cannot start with underscore. 
- You can call a method with arg names: `myClass.myMember(x: 10, y: 12);`
- `alloc{};` allocates memory for a new instance of the current class. `alloc{4};` will allocate 4 bytes of memory (used for primitive data types where there is no field defined, e.g. Int).
- `f :: g`, when g is name of a method, is a shortcut for `out f(all_inputs) { return g(all_inputs); }`. You cannot change any input/output when calling g. if `g` is name of a field or literal, then `f :: g` means `g_type f() { return g;}`. Note that no `()` or output type needs to be specified for function redirection. You can use this notation when output of function is only a expression (`return expression`). `f(int x) :: x+1;`. When using `::` you should not specify output type because it will be inferred by compiler.
- Using `::` notation you can simplify calling long named methods: `p :: core.io.screen.printf;`
- If name of our function is same as right side of `::` we can ignore it: `:: core.io.screen.printf` defined printf method in the current class.
- Simplest constructor: `new :: alloc{};`
- You can define ctor methods on the default instance or on normal instances.
- You can define public or private ctors.
- Including parantheses is optional when calling a function which has no inputs. 
- When you are assigning value to fields upon declaration, you don't have access to `this`. So either you need to use literals or call outside methods.
- Functions should have an output type (there is no `void`). If they don't return anything, you can use `this` as their return type which means current class. If a function is defined using `this`, compiler will automatically add `return this` to the function.
- We can have `INum create(INum a, INum b) { if(x) return a.new() else return return b.new();}`
and call it: `auto x = create($ComplexNumber, $NormalNumber);`
- All class fields are private. They don't need a prefix.
- You can assign value to fields in alloc: `alloc{x:11, y:12}`. This is the last place where you can set value for const fields.
- 


##Operators

- Conditional: `and or not == != >= <= ??`
- Bitwise: `~ & | ^ << >>`
- Math: `+ - * % ++ -- **`
The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.


Each class can provide implementation for operators. 
Classes can override all the valid operators on them. `int` class defines operator `+` and `-` and many others (math, comparison, ...). This is not specific to `int` and any other class can do this. 

- `=` operator, makes a variable refer to the same object as another variable (this is provided by runtime because classes cannot re-assign `this`). So when you write `int x = y` by default x will point to the same data as y. If you want to clone, you need to use custom methods (e.g. `int x = int.new(y);`). You cannot override this operator.
- `x ?? 5` will evaluate to 5 if x is in undef, else will be evaluated to x.
- `x == y` will call `equals` method, which by default compares field-by-field values but classes can override this. 
- `&x` is a short-cut for `assert defined x;` which can be used to ensure x is not default instance.
- `~x` creates a shallow clone of x. so you can write `auto y = ~x` and y will point to a copy of x.
- `^x` returns unique ref-id of the object. so you can write `if(^x == ^y)` and be sure references will be compared.

##Special syntax
- `->` for lambda expression
- `_` input place-holder for anon-func
- `()` for defining tuple literals and function call
- `$` for casting and default instance
- `alloc` instantiation
- `@` for annotations
- `[]` for field access
- `:` for hash literal, loop, call by name, array slice and tuple values
- `%` template syntax
- `:=` type alias and typename
- `::` function and field redirection
- `&` assert defined variable.
- `out`: representing function output in defer
- `exc`: representing current exception in defer
- `??` undef check

###Special variables
this, true, false

###Exposure

- A field starting with `__` will be promoted/exposed. 
- An exposed field's public members will be soft-copied at compile-time (includng ctors). This means, if there is a member (field or method) with the same name in main class, it won't be copied (main class members always win).
- If you expose two classes that have a public fields with the same name, you must define a field with that name in main class (or else there will be a compiler error). 
- You can hide/remove an exposed method by adding same method with/without body.
- You can rename an exposed method by removing it and adding your own method.
- A container class can provide implementation for methods of contained class if it is allowed:
```
//contained class
%fn(int) m1;  
int method1() :: this@m1;  //method1 is redirected to m1, we can even remove this and only use m1
this new(%fn(int) m) return alloc{};  //construct an instance using given value

//container class
this@__member = MyClass.new(this.implementation);  //pass my method as an implementation 
```

- In expose, you don't have access to private members of exposed object.
- When exposing a variable, class is responsible for initialization and instantiation of the variable. Compiler just generates code to re-direct calls.

###Annotations
You can annotate a class, field or method with this syntax:
`@custom_name{key1:value1, key2:value2, ...}`
custom_name is whatever you want. value(i) is optional and is assumed to be true if omitted.
for example:
`@json{ignore} int x;`
Later you can extract annotations for a member in the form of: `List<Annotation>` where `Annotation` is a tuple of `(name:string, hash_args)`.
- Methods will be added to core to fetch annotations for a class, method or field.

###Array and slice

- `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]; int[2,2] x;`. We have slicing for arrays `x[start:step:end]` with support for negative index.
- `int[string] hash1 = { 'OH': 12, 'CA': 33};`.
- `for(x:array1)` or `for(int key,string val:hash1)`.

###Hashtable

###Casting
- `$myclass(my_obj)` is the casting operator and returns empty/undefined/not-initialized if myObj cannot be casted to myclass. Compiler will try 3 options for casting: first if `my_obj` conforms to `myclass` it will be casted without change in the data (means `my_obj` has all fields and methods that `myclass` has specified). second, looks for a method called `myclass` defined in `my_obj` (This method will convert `my_obj` instance to an instance of `myclass`). third, looks for reverse: a method called `ObjType` in `myclass` static instance (ObjType is type of `my_obj` and this method will crete a new instance of myclass using given `ObjType` instance). All these options will be checked at compile time.
- Example: Converting MyClass to YourClass: `yclass = $YourClass(mclass);`
1) call `mclass.YourClass` method: `yclass = mclass.YourClass();`
2) call `YourClass.MyClass` static constructor method: `yclass = YourClass.MyClass(mclass);`
- The only case where `<` and `,` is allowed in method name is for above purpose. 
- `float f; int x = $int(f);` this will call `int` method on class `float` to do casting. This can be called automatically by compiler if needed. For template types (like array or hash), you should name the function according to full-name not short-name (`Array<char>` instead of `char[]`).
- empty/undefined/not-initialized state of a variable is named "default" state and is shown by `$MyClass` which is a shortcut for casting nothing to MyClass: `$MyClass()`.
- Value of a variable before initialization is default.
- You can also return `$MyClass` when you want to indicate invalid state for a variable.
- Calling a method or field on a default object, returns default instance of the output type (except for ctors). Settings field value for default object does nothing.
- When input of cast is `fn` type and output is a class with just-one name, runtime will handle the name change.

###Default instance
###Aspects
You can prefix a method, with a set of `weave` keywords each with an expression which specifies a set of methods to be called before/after/around/... of the current method.
```
#weave {obj1} int f(int x) { return x;} //function members of obj1 named before, after, around, ... will be called if they are defined
#weave {$OnlyAfter(obj1)} int f(} { return 5;} //obj1 is cast to OnlyAfter interface. so only it's after method will be called.
#weave {this[obj1]} int f() { return 5;} //the weave code is result of evaluation of the expression. so in this case this[obj1] will be re-used for all call
#weave {MyClass.new} int f() { return 5;} //create a new instance per each call
```
- you can combine weaves and they will be applied from outer-most to inner-most
- Weave expression is evaluated and checked for appropriate functions by compiler. So you can include any expression including assertions. These will be run before function run: `#weave {assert x>0}`
- For example you can write a weave to retry method call 3 times in case of exception.

###Instantiation
###Return multiple values
Functions can return multiple values: 
`(int a, float f) f() { return 1, 3.1;}`
calling those functions: `iv, fv = f();`
that's all we have for multiple-return.

###Lambda expression

Lambda expression provides a short-cut to define an object with only one method, which possibly returns an expression. You can specify a type (A class with only one method) for Lambda expression which will be used to infer type of input/output of the expression.

```
Interface1 intr = (int x, int y) -> x+y;  //specifying type for input is optional
auto ab = (int x) -> x+y; //type will be fn<int, int>
Interface2 ac = _+1;  //Interface2 has only one method which has only one input. for the input we use place-holder
auto ab = (x) -> 2*x; //WRONG! input type cannot be inferred
Interface1 intr = (x, y) -> x+y;
Interface1 intr = (x, y) -> (r1:x+y, r2:x);  //returning a tuple from anon-func
auto x = (int x) -> x+1;   //compiler will automatically map to fn<int, int> interface and will init x
int t = x(10); //t will be 11. compiler will automatically invoke the only method of the interface.
Intr6 intr5 = () -> 5; //no input
Intr6 intr6 = { return 5; }; //same as above, first part can be omitted
Interface2 intr2 = x -> x+1;  //you can omit parantheses if you have only one variable
Interface1 intr = (x, y) -> { 
    method1();
    method2(x,y);
};

//name of functions are read-only references to the implementation. You can use them as 
//anonymous interfaces of type fn<>
Intr5 pa = this.method1;
//if no interface name is specified, compiler will find appropriate template interface "fn" for it
auto pp = this.method2;  //can be called later through: pp(1, 2, 3);
auto xp = (int x, int y) -> x+y;  //again compiler will assign appropriate fn interface
//for example for above case type of xp will be fn<int, int, int>
//if returning multiple values, it will be an anonymous class
auto xp = (int x, int y) -> return (a:1, b:3); //type of xp will be fn<(int, int), int, int>
```
- Note that you can use `object.method` notation as an object with only one method pointing to the implementation.
*Closure*: All anonymous function and classes, have a `this.__closure` which will point to a set of methods for each of the variables in enclosing method (including input arguments and `this` as the container class). These methods will be promoted if possible (no method with the same name is defined).

- If anon-function does not have any input and there is only one function (in short-form), you can omit `() ->` part.

###Extension methods
- Members of MyClass class are defined in `MyClass.e` file.
- There can be more than `MyClass.e` file in list of imported packages. Each of them can have their own sutrct + methods.
- When using `MyClass` in the code, compiler will merge all of them into one class.
- Each file has access to it's own private members + public members of the other files (whic it has imported).
- You can even define ctor in extension methods.
- Note that using this feature can be dangerous as developer can modify an interface and afterwards, all casting will be broken to that interface.
- You cannot define fields or ctor in extension methods file.

###Templates
In a class file you can use `typename` keyword, to indicate that the user of the class has to provide type names at compile time:

```
typename K := int;  //K is a template type (default is int), which will be provided at compile time.

typename V := float ${Type1, Type2}; //type V is float by default and must conform to Type1 and Type2

void put(K key, V value) ...
V get(K key) ...
```
This is how collections and ... will be implemented in core.

Note that `typename` section must come before struct section.
For each tempalte class like `Stack`, there is a base interface class `Stack` which is equal to the class definition minus everything related to typenames (declaration, usage, ...) which is created by the compiler. According to definition, all template class instances, conform to this base interface. This means `Stack` is the base interface for `Stack<int>, Stack<float>` and all other stacks and if you need to write a method accepting any stack you can use it: `void getStack(Stack s)`. 
Note that `Stack` is not the same as `Stack<>` which has type set to it's default.
- When creating instances of template class you can explicitly speciy type name: `Stack<T:int, V:float>`
- `%Stack` means the stack class with all default values of typenames.
- `Stack` means stack class without any code related to typename. (non-template version of the class)

###Optional arguments

##Best practice
###Naming
- **Naming rules**: Advised but not mandatory: `some_method_name`, `someVariableName`, `MyClass`, `MyPackage`.
- constructor is called `new` in core classes.
- For primitive classes, name starts with lowercase to denote they are primitive and have no fields.

##Examples
###Empty application
```
int main()
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

