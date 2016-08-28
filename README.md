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

### Core principle

Almost everything is an object, even basic data types and everything is passed by value, but everything is a reference.
Every class has a special instance (static instance), which is created by the compiler. This instance can be used to create other instances of the class. But at very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.

###Keywords

1. **Conditional**: `if`, `else`, `switch`, `assert`
2. **Loop**: `for`, `break`, `continue`
3. **Control**: `return`, `defer`, `throw`
4. **Type handling**: `auto`, `typename`, `type`, `struct`
5. **Other**: `import`, `void`

These are not keywords but have special meaning:
`this`, `true`, `false`, `nil`

Usage of most these keywords is almost same as C++ or Java, so I omit explanation for most of them in detail.

### Primitive data classes

- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

### Operators

The operators are almost similar to C language:

- Conditional: `and or not == != >= <= ??`
- Bitwise: `& | ^ << >>`
- Math: `+ - * % ++ -- **`

The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.

*Special syntax*:
- `->` for anonymous class declaration
- `=>` for delegation (expose)
- `()` for casting and defining tuple literals and function call
- `{}` instantiation
- `:` for hash, loop, assert, call by name, array slice and tuple values
- `<>` template syntax
- `:=` for typename default value, type alias and import alias
- `out`: representing function output in defer
- `exc`: representing current exception in defer


###The most basic application

Here's what an almost empty application looks like:

file: `Simple.e`
```
int main()
{
    return 0; 
}
```

This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except `main` function has no input).

### Packages

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core.sys, core.net, core.net.http, core.net.tcp` are all packages.

###Classes

Each source code file represents one class and has two important parts: `struct` part where fields are defined, and method definition.
Writing body for methods is optional (but of course if a body-less method is called, nothing will happen and an empty response will be received). Classes with no method body are same as interfaces in other languages but in Electron we don't have the concept of interface.

Each class's instances can be referenced using instance notation (`varName.memberName`), or you can use static notation (`ClassName.memberName`) which will refer to the special instance of the class (static instance). There is an static instance for every class which will be created upon first usage in the code. 

*Notes:*
- There is no inheritance. Composition is used instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, `typename`s, `type`s, then `struct` and finally methods. 

###Class members

```
struct 
{
    int _x = 12;  //private const, is not re-assignable
    int y;
    int h = 12;
}

int func1(int y) { return this.x + y; }
MyClass new() return {};  //new is not part of syntax. You can choose whatever name you want,
void _() this.y=9;  //initialize code for static instance

```
- You cannot assign values in `struct` section because it is not a place for code. You just define fields and possibly assign them to literals.
- Class members (fields, methods and types) starting with underscore are considered private and can only be accessed internally. So the only valid combination that can come before `_` is `this._xxx` not `obj._xxx`.
- Here we have `new` method as the constructor (it is without braces because it has only one statement), but the name is up to the developer.
- The private unnamed method is called by runtime service when static instance of the class is created and is optional.
- You can not have methods with the same name in a single class.
- There is no default value for method arguments. If some parameter is not passed, it's value will be `nil`.
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`). `this` is not re-assignable variable so you cannot re-assign it.
- Value of a variable before initialization is `nil`. You can also return `nil` when you want to indicate invalid state for a variable.
- When a variable is nil and we call one of it's type's methods, the method will be called normally with nil `this`. If we try to read it's fields, it will crash.
- If a method has no body, you can still call it and it will return `nil`. You can also call methods on a `nil` variable and as long as methods don't need `this` fields, it's fine.
- `int f(int x) return x+1;` braces can be eliminated when body is a single statement.
- You can define struct as `struct(n);` with `n` parameter and empty body to indicate that struct should have `n` bytes allocated from memory represented as `this`. This is used to implement built-in classes like `int`.
- **Variadic functions**: `bool bar(int... values)`

###Exposoing

- You can use `=>` notation when defining a variable to denote it will handle a set of method call/fields. This set is specified by one or more classes: `MyClass v1 => MetaClass1, MetaClass2;`  
In above example, all public methods/fields of `MetaClass1` and `MetaClass2` will be added to current class and will be delegated to method with same signature in `v1` field. It is assumed that `MyClass` conforms to `MetaClass1` and `MetaClass2`.
- You can use exposed type same as variable type, so this will expose all public methods and fields of the variable:
`MyClass c1 => MyClass;` or `MyClass c1 =>;` for shortcut.
- If a method is empty in `MyClass`, the container class can provide an implementation for it. This will cause calls to the empty method be redirected to the new implementation, even inside `MyClass`. For other methods, the parent class can define methods with the same name to hide them.

###Operators

Classes can override all the valid operators on them. `int` class defines operator `+` and `-` and many others (math, comparison, ...). This is not specific to `int` and any other class can do this. 

- `=` operator, by default makes a variable refer to the same object as another variable (this is provided by runtime because classes cannot re-assign `this`). So when you write `int x = y` by default x will point to the same data as y. You can override this behavior by adding `op_assign` method to your class and clone the data. This is done for primitives like `int` so `int x=y` will duplicate value of y into x. If you need original behavior of `=` you have to embed those variables in holder classes which use default `=` behavior. On the other hand, if you need duplication for classes which do ref-assignment by default, you will need to do it manually in one of methods (like `clone` and call `MyClass x = y.clone()`).

###Anonymous struct (tuple)

Functions can only return one value but that one value can be an anonymous struct (tuple) containing multiple values. Note that field names are required and should be mentioned or inferable.
The only special thing that compiler does here is to handle literals. Also compiler automatically creates them for you when you call a function or return something:

```
type myt := (int x, float f);  //defining tuple, field names are required
myt func1(){ return (x: 1, f: 1.1); }  //return tuple literal
myt func1(){ return (1, 1.1); }    //tuple literal with implicit field names
(int x, float f) func1() { return (x:1, f:2.3); }
(int x, float f) func1() { return (1, 2.3); }
x,y = func1();  //unpack tuple

(int x) func3() { return (1); }  //even with one value
(int x) func3() { return (x:1); }  //even with one value
x = func3();

auto x = (age:12, days:31);  //tuple literal, here field name is needed
auto x = (1, 2); //WRONG! we need field names
int f(myt input) ... //you can pass tuple to a function
int f((int x, float f) input) ... //passing tuple to function
int x = f((x:1, f:1.1)); //calling above function
```

Tuples are automatically converted to classes by compiler. So they are basically classes but only have a struct section (without any assignment) with all-public fields and no methods. 

###Type aliasing

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

Same as other members, types starting with underscore are private.

###Templates

In a class file you can use `typename` keyword to indicate that the user of the class has to provide type names at compile time:

```
typename K: interface1, interface2;  //K type should conform to these two interfaces. 
typename V: interface2 := MyClass;   //default value is MyClass

void put(K key, V value) ...
V get(K key) ...
```
This is how collections and ... will be implemented in core.

Note that `typename` section must come before `struct` section.

###Exception handling

- It is advised to return error code in case of an error. 
- You can use `defer` keyword (same as what golang has) for code that must be executed upon exitting current method.
- If defer has an input named `out`, it will be mapped to the function output.
- If defer has an input named `exc`, it will be mapped to the current exception. If there is no exception, defer won't be executed. If there are multiple defers with `exc` all of them will be executed.
- You can check output of a function in defer (`defer(out) out>0`) to do a post-condition check.

```
//inside function
throw "Error!";  //throw exception and exit
//outside: catching error
defer(exc) { ... }
defer(out, exc) { ... }

defer(out) { if ( out != nil ) out++; }  //manipulate function output
defer(out) assert out>0;  //post-condition check
```

###Anonymous class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface specifying one or more functions. If the interface has only one method, the definition can be in short form and it is considered a function pointer. There is a general purpose template class `fp` which is used by compiler to set type of anon-class literals if type is to be inferred.


```
//short form, when interface has only one method
Interface1 intr = (int x, int y) -> x+y;  //specifying type for input is optional
auto ab = (int x) -> x+y; //type will be fp<int, int>
auto ab = (x) -> 2*x; //WRONG! input type is not specified which is invalid with auto
Interface1 intr = (x, y) -> x+y;
Interface1 intr = (x, y) -> (r1:x+y, r2:x);  //returning a tuple from anon-func
auto x = (int x) -> x+1;   //compiler will automatically map to fn<int, int> interface and will init x
int t = x(10); //t will be 11. compiler will automatically invoke the only method of the interface.
Intr6 intr5 = () -> 5; //no input
Intr6 intr6 = { 5; }; //same as above, first part can be omitted
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
//if returning multiple values, it will be an anonymous struct
auto xp = (int x, int y) -> return (a:1, b:3); //type of xp will be fn<(int, int), int, int>

//long form, full implementation of empty methods of a class
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
- If anon-function does not have any input and there is only one function (in short-form), you can omit `() ->` part.

###Data structures

- `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]; int[2,2] x;`. We have slicing for arrays `x[start:step:end]` with support for negative index.
- `int[string] hash1 = { 'OH': 12, 'CA': 33};`.
- `for(x:array1)` or `for(int key,string val:hash1)`.

###Misc

- **Naming rules**: Advised but not mandatory: `someMethodName`, `some_variable_arg_field`, `MyClass`, `MyPackage` (For classes in `core` they can use `myClass` notation, like `int` or `fp`).
- `iclass1(my_obj)` returns `nil` if myObj does not conform to iclass1 or else, result will be casted object.
- **const**: Class fields which are assigned a value inside `struct` section are constant (compiler handles assignment without invoking the code for assignment operator) and cannot be re-assigned later. Note that, they still can be mutated if they provide appropriate methods. If you need fully immutable classes, you have to implement the logic in your code.
- **Literlas**: `0xffe`, `0b0101110101`, `true`, `false`, `119l` for long, `113.121f` for float64, `1_000_000`
- `x ?? 5` will evaluate to 5 if x is `nil`.
- `///` before method or field or first line of the file is special comment to be processed by automated tools. 
- `myClass.myMember(x: 10, y: 12);`
- **Literals**: compiler will handle object literals and create corresponding objects (in default arg value, initializations, enum values, true, false, ...).
- `float f; int x = f.int();` this will call `int` method on class `float` to do casting. This can be called automatically by compiler if needed.
- `break 2` to break outside 2 nested loops. same for `continue`.
- `import core.st` or `import aa := core.st` to import with alias.

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


#Language Reference ToC
- Version and history
- Introduction, memory model
- Tokens and casing, whitespace, source code encoding, comments, literals
- General rules (underscore, ...)
- Classes, methods and fields
- Packages
- Keywords + brief explanation
- Operators and special syntax
- basic syntax rules + explanations
- Best practices, packaging, versioning, conventions, naming
- How to update this spec?
