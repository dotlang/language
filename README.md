## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python) and being familiar with some others (including Go, D, Scala and Rust) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex with a lot of rules and exceptions. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating a new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Simple**: Easy to learn, read, write and understand. Consistent, orthogonal and logical, as much as possible with minimum number of exceptions to remember. There should preferably be only one way to do some task. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organize, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer using a set of pre-defined rules over keywords in the language.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptions and best practices)
2. An interpreter/compiler
2. Debugger tools
3. Package manager (Used to build, create, install and deploy packages, something like CPAN, PyPi + their client-side tools)
4. Development plugins (For vim, emacs and other popular code editors)

###Paradigm

Electron is an object-oriented and imperative programming language with automatic garbage collection memory management. 
The target use case of this programming language is server-side software.

###Keywords

1. **Conditional**: `if`, `else`, `switch`, `assert`
2. **Loop**: `for`, `break`, `continue`
3. **Control**: `return`, `defer`, `async`
4. **Exceptions**: `throw`, `catch`
5. **Type handling**: `auto`, `typename`, `const`, `type`, `struct`
6. **Other**: `import`, `void`

These are not keywords but have special meaning:
`this`, `true`, `false`, `nil`

Usage of most these keywords is almost same as C++ or Java, so I omit explanation for most of them in detail.

### Primitive data types

- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

### Operators

The operators are almost similar to C language:

- Conditional: `and or not == != >= <= ??`
- Bitwise `& | ^ << >> ~`
- Math `+ - * % ++ -- **`

The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.

*Special syntax*: `-> => () {} : <> :=` 
- `->` for anonymous
- `=>` for delegation
- `()` for casting and defining tuple literals
- `{}` instantiation
- `:` for hash, loop, assert, call by name, array slice and tuple values
- `<>` template syntax
- `:=` for typename default value, type alias and import alias

### Core principle

Everything is a class, even basic data types and everything is passed by value, but everything is a reference.
Every class has a special instance (static instance), which is created by the compiler. This instance can be used to create other instances of the class. But at very few cases does compiler do something for the developer automatically. Most of the time, developer should write the code or add some methods to do something.

###The most basic application

Here's what an almost empty application looks like:

file: `Simple.e`
```
int main()
{
    return 0; 
}
```

This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except no input it sent to the `main` function).

### Packages

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core.sys, core.net, core.net.http, core.net.tcp` are all packages.

###Classes

Each source code file represents one class and has two parts: `struct` part where fields are defined, and method definition.
Writing body for methods is optional (but of course if a body-less method is called, a runtime error is thrown). Classes with no method body are same as interfaces in other languages but in Electron we don't have the concept of interface.

Each class's instances can be referenced using instance notation (`varName.memberName`), or you can use static notation (`ClassName.memberName`) which will refer to the special instance of the class (static instance). There is an static instance for every class which will be created upon first reference. 

*Notes:*
- There is no inheritance. Composition (By using anonymous fields) is encouraged instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, `typename`s, `type`s, then `struct` and finally methods. 

###Class members

```
struct 
{
    const int _x = 12;
    int y;
    int h = 12;
}

int func1(int y) { return this.x + y; }
MyClass new() return {};
void _() this.y=9;

```
- You cannot assign values in `struct` section because it is not a place for code. You just define fields and possibly assign them to literals.
- Class members (fields, methods and types) starting with underscore are considered private and can only be accessed internally. So the only valid combination that can come before `_` is `this._xxx` not `obj._xxx`.
- Here we have `new` method as the constructor (it is without braces because it has only one statement), but the name is up to the developer.
- The private unnamed method is called by runtime service when static instance of the class is created and is optional.
- You can not have methods with the same name in a single class.
- There is no default value. If some parameter is not passed, it's value will be `nil`.
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`).
- Value of a variable before initialization is `nil`. You can also return `nil` when you want to indicate invalid state for a variable.
- When a variable is nil and we call one of it's type's methods, the method will be called normally with nil `this`. If we try to read it's fields, it will crash (like Objective-C).
- If a method has no body, you can still call it and it will return `nil`. You can also call methods on a `nil` variable and as long as methods don't need `this` fields, it's fine.

###Exposoing

- You can use `=>` notation when defining a variable to denote it will handle a set of method call/fields. This set is specified by one or more classes: `MyClass v1 => MetaClass1, MetaClass2;`  
In above example, all calls to public methods of `MetaClass1` and `MetaClass2` will be redirected to `v1`. You can use variable type as exposed type so this will expose all public methods and fields of the variable:
`MyClass c1 => MyClass;`

###Operators

Classes can override all the valid operators on them. `int` class defined operator `+` and `-` and many others (math, comparison, ...). This is not specific to `int` and any other class can do this. 

###Anonymous struct (tuple)

Functions can only return one value but that one value can be an anonymous struct containing multiple values. 
The only special thing that compiler does for it is to handle literals. Also compiler automatically creates them for you when you call a function or return something:

```
type myt := (int x, float f);  //defining tuple
myt func1(){ return (x: 1, f: 1.1); }  //return tuple literal
(int x, float f) func2() { return (x:1, f:2.3); }
x,y = func1();  //unpack tuple
auto x = (age:12, days:31);  //tuple literal
```

Tuples are automatically converted to classes by compiler. So they are basically classes but only have a struct section with all-public fields and no methods. 

###Async

This is like `go` in golang. It will start the code or statement in a separate parallel routine.

```
go obj1.func1(1, 2, 3);
go { x++; y = y + func(x); }
```

###Type aliasing

You can use `type` to define type alias:
```
type point := int[];
type x := const int&;
x a;  //=const int& a;
const x& a; //=const int& a, you cannot apply const or & more than once
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

###Templates

In a class file you can use `typename` keyword to indicate that the user of the class has to provide type names at compile time:

```
typename K: interface1, interface2;  //if omitted, empty interface is assumed
typename V: interface2 := MyClass; 

void put(K key, V value) ...
V get(K key) ...
```
This is how collections and ... will be implemented in core.

Note that `typename` must come before `struct` section.

###Exception handling

It is advised to return error code in case of an error:
Language provides `defer` keyword:
- You can use `defer` keyword (same as what golang has) to define code that must be executed upon exitting current method.
- You can check output of a function in defer (`defer result>0`) to do a post-condition check.


In case of exception, you can use `throw x` statement (where x can be anything) and `catch` in a defer statement to handle it. If there is no `catch` control will go up in the call hierarchy.

```
defer { auto r = catch(); if ( r ) return r.getCode(); }
this.method1();  //-> inside of which we have: throw "abcd"
defer catch(
```

###Anonymous function/class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface. If the interface has only one method, the definition can be in short form. 
Note that both short and long form, the code only has read-only access to variables in the parent method. No access is given to the parent class. In the short-form you cannot use `auto` to define these variables because compiler cannot deduce interface type from right side.

```
//short form, when interface has only one method
Interface1 intr = (int x, int y) -> x+y;  //specifying type for input is optional
Interface1 intr = (x, y) -> x+y;
auto x = (int x) -> x+1;   //compiler will automatically create/find appropriate interface and will init x
int t = x(10); //t will be 11. compiler will automatically invoke the only method of the interface.
Intr6 intr5 = () -> 5; //no input
Interface2 intr2 = x -> x+1;  //you can omit parantheses if you have only one variable
Interface1 intr = (x, y) -> { 
    method1();
    method2(x,y);
};

//name of class functions are read-only references to the implementation. You can use them as 
//anonymous interfaces
Intr5 pa = this.method1;  
//if no interface name is specified, compiler will find appropriate template interface "Function" for it
auto pp = this.method2;  //called later by: pp(1, 2, 3);
auto xp = (int x, int y) -> x+y;  //again compiler will find and assign appropriate Fucntion interface
//for example for above case type of xp will be Function<int, int, int>
//if returning multiple values, it will be an anonymous struct

//long form
auto intr = Interface1 
{
    int function1(int x,int y) 
    {
        return x+y;
    }
    
    int functio2(int x)
    {
        return x+1;
    }
};
```

*Closure*: All anonymous function and classes, have a `this` which will point to a read-only set of local variables in the enclosing method (including input arguments and `this` as the container class).

- As a short-cut provided by compiler, if the anonymous-class `x` has only one method, `x()` will call the only method of that class. You don't need to write the full syntax: `x.only_method()`.
- Anonymous classes don't have constructor or static instance. Because they don't have names.

###Misc

- **Naming rules**: Advised but not mandatory: `someMethodName`, `some_variable_arg_field`, `MyClass`, `MyPackage`.
- **Checking for implements**: You can use `(other_class)class1` to check if `class1` implements `other_class`.
- **const**: You can define class fields, local variables and function inputs as constant. If value of a const variable is compile time calculatable, it will be used, else it will be an immutable type definition.
- **Literals**: `0xffe`, `0b0101110101`, `true`, `false`, `119l` for long, `113.121f` for float64.
- **Digit separators**: `1_000_000`.
- **For**: You can use `for` to iterate over an array or hash `for(x:array1)` or `for(k,v:hash1)`.
- **if and for without braces**: `if (x>1) return 1;`, `for(y:array) x += y;`.
- **Arrays**: Same notation as Java `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]; int[2,2] x;`. We have slicing for arrays `x[start:step:end]` with support for negative index.
- **String interpolation**: You can embed variables inside a string to be automatically converted to string. If string is surrounded by single quotes it won't be interpolated. You need to use double quote for interpolation to work.
- **Ternary condition**: `iif(a, b, c) ` is same as `a ? b:c` in other languages.
- **Hashtable**: `int[String] hash1 = { 'OH': 12, 'CA': 33, ... };`.
- **import**: Include other packages.
- **Null operator**: `x ?? 5` will evaluate to 5 if x is `nil`.
- **assert**: You can use this to check for pre-condition and with `defer` it can be used to check for post-condition. `assert x>0 : 'error message'` will set error upon failure.
- **Documentation**: Any comment before method or field or first line of the file starting with `///` is special comment to be processed by IDEs and automated tools. 
- **Call by name**: `myClass.myMember(x: 10, y: 12);`
- **Literals**: compiler will handle object literals and create corresponding objects (in default arg value, initializations, enum, true, false, ...)
- **Casting**: `float f; int x = f.int();` this will call `int` method on class `int` to do casting.  
- You can write `auto x = myObj.method1;` and type of `x` will be anon-class of type `func<int, int>` (assuming method1 gets int and returns int).

###Core package

A set of core packages will be included in the language which provide basic and low-level functionality (This part may be written in C):

- Calling C/C++ methods
- Reflection
- Data conversion
- Garbage collector
- Exception handling

###Standard package

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

#Package Manager

The package manager is a separate utility which helps you package, publish, install and deploy packages (Like `maven` or `dub`).
Suppose someone downloads the source code for a project written in Electron which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.

Perl has a `MakeFile.PL` where you specify metadata about your package, requirements + their version, test requirements and packaging options.
Python uses same approach with a `setup.py` file containing similar data like Perl.
Java without maven has a packaging but not a dependency management system. For dep, you create a `pom.xml` file and describe requirements + their version. 
C# has dll method which is contains byte-code of the source package. DLL has a version metadata but no dep management. For dep it has NuGet.

#A sample file
```
import core.math;
import m := core.math;

struct
{
    int x = 12_000;
    int y;
    int z;
    DataManager;   //this class has anonymous field
}

//this is an anonymous block, used to initialize the static instance or enforce some compilation checks
{
    //static code when this class is instantiated for the first time ever
    this.z = 19; //init the static instance
}

int func1(int data=9) 
{
    Func<int> anonFunc = (u) -> u+1;
    this.z = data + anonFunc.apply(u: 6);
    
    int x = 1;
    switch(data)  //switch is for primitives
    {
        1: return 1; //if block is just one line, you can omit brces
        4, 5: { x++; }
        : { return 0; }  //default
    }
    retrun x;
}

//for single statement, you don't need braces
int func2(int r) return r+1;
```

A sample interface:
```
struct
{
    ParentInterface;
}

int method1(int x, int y);
```

#List of conventions
- Public/Private by using prefix underscore
- Default static instance

    
