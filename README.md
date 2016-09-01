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
5. **Other**: `import`, `void`, `expose`, `select`, `invoke`, `include`

These are not keywords but have special meaning:
`this`, `true`, `false`

Usage of most these keywords is almost same as C++ or Java, so I omit explanation for most of them in detail.

### Primitive data classes

- **Integer data types**: `char`, `short`, `int`, `long`
- **Unsigned data types**: `byte`, `ushort`, `uint`, `ulong`
- **Floating point data types**: `float`, `double`
- **Others**: `bool`

### Operators

The operators are almost similar to C language:

- Conditional: `and or not == != >= <= #`
- Bitwise: `~ & | ^ << >>`
- Math: `+ - * % ++ -- **`

The bitwise and math operators can be combined with `=` to do the calculation and assignment in one statement.

*Special syntax*:
- `->` for anonymous class declaration
- `()` for defining tuple literals and function call
- `@` for casting
- `{}` instantiation
- `:` for hash, loop, assert, call by name, array slice and tuple values
- `<>` template syntax
- `:=` for typename default value, type alias and import alias, ref-assignment for field and method
- `out`: representing function output in defer
- `exc`: representing current exception in defer
- `?=>` compare-and-swap
- `#` undef check


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
Writing body for methods is optional (but of course if a body-less method is called, nothing will happen and an empty response will be received). Classes with no method body are same as interfaces (or abstract class with all methods marked as virtual) in other languages but in Electron we don't have the concept of interface.

Each class's instances can be referenced using instance notation (`varName.memberName`), or you can use static notation (`ClassName.memberName`) which will refer to the special instance of the class (static instance). There is an static instance for every class which will be created upon first usage in the code and is not re-assignable.  

*Notes:*
- There is no inheritance. Composition is used instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, `typename`s, `type`s, `expose` then `struct` and finally methods. 

###Class members

```
struct 
{
    int _x = 12;  //private const, is not re-assignable
    int y;
    int h = 12;
    int gg := this.h;  //gg is a reference to h. any action on gg will be called on h.
    auto dsa := this.h;  //:= assignment in struct cannot be re-assigned. but in the code it can. 
    float ff := this.object1.field5;
}

int func1(int y) { return this.x + y; }
int func2(int x) := this.func1;  //redirect calls to func1, methods should have same signature
auto func3 := this.func2;  //compiler will infer the input/output types for func3 from func2 signature
MyClass new() return {};  //new is not part of syntax. You can choose whatever name you want,
void _() this.y=9;  //initialize code for static instance

```
- You cannot assign values in `struct` section because it is not a place for code. You just define fields and possibly assign them to literals.
- Class members (fields, methods and types) starting with underscore are considered private and can only be accessed internally. So the only valid combination that can come before `_` is `this._xxx` not `obj._xxx`.
- Here we have `new` method as the constructor (it is without braces because it has only one statement), but the name is up to the developer.
- The private unnamed method is called by runtime service when static instance of the class is created and is optional.
- You can not have multiple methods with body with the same name in a single class. 
- There is no default value for method arguments. If some parameter is not passed, it's value will be undef.
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`). `this` is not re-assignable variable so you cannot re-assign it.
- Value of a variable before initialization is undef which is denoted by `@MyClass` where MyClass is type of the variable. 
- You can also return `@MyClass` when you want to indicate invalid state for a variable.
- When a variable is in undefined state and we call one of it's type's methods, the method will be called normally with empty `this`. If we try to read it's fields, it will crash.
- If a method has no body, you can still call it and it will return undef. You can also call methods on an undef variable and as long as methods don't need `this` fields, it's fine.
- `int f(int x) return x+1;` braces can be eliminated when body is a single statement.
- You can define struct as `struct(n);` with `n` parameter and empty body to indicate that struct should have `n` bytes allocated from memory represented as `this`. This is used to implement built-in classes like `int`.
- **Variadic functions**: `bool bar(int... values)`
- You can use `var1 := var2;` notation to assign a var2 reference to var1. So basically var1 will be an alias for var2. Using normal `var1 = var2` may not do this because the class of var2 may have a duplication based assignment operator.

###Composing classes

- You can write `expose AA := MyClass;` to add a field named `AA`, expose all public members in MyClass and route them to `AA` (AA can be a private too). 
- You can write `include MyClass;` to have contents of MyClass included at the current class. This will simply copy all methods and fileds of the class.
- Both expose and include soft-copy members. This means, if there is a member with the same name, it won't be copied.
- You can hide/remove an exposed/included method by adding same method with/without body (methods of the current class always win).
- You can rename an exposed method by removing it and adding your own method.
- If a method is empty in `MyClass`, the exposer class can provide an implementation for it. This will cause calls to the empty method be redirected to the new implementation, even inside `MyClass` instance variable (same as virtual methods in other languages).
- Compiler will give error if there are be conflicts in exposed/included members (e.g. methods with same name and with body).
- In expose, you don't have access to private members of composed object while in include, you have.
- When exposing a variable, class is responsible for initialization and instantiation of the variable. Compiler just generates code to re-direct calls.

###Concurrency

We have `invoke` and `select` keywords. You can use `future<int> result = invoke obj.method1();` to execute `obj.method1` in another thread and the result will be available through future class (defined in core).
Also `select` evaluates a set of expressions and executes corresponding code block for the one which evaluates to true:
```
select
{
    rch1.tryRead(): { a = rch1.peek();}
    rch2.tryRead(): { b=rch2.peek();}
    wch1.tryWrite(x): {}
    wch2: tryWrite(y): {}
    true: {}  //default branch
}
```
You can use select to read from blocking channels.

###Operators

Classes can override all the valid operators on them. `int` class defines operator `+` and `-` and many others (math, comparison, ...). This is not specific to `int` and any other class can do this. 

- `=` operator, by default makes a variable refer to the same object as another variable (this is provided by runtime because classes cannot re-assign `this`). So when you write `int x = y` by default x will point to the same data as y. You can override this behavior by adding `op_assign` method to your class and clone the data. This is done for primitives like `int` so `int x=y` will duplicate value of y into x. If you need original behavior of `=` you have to embed those variables in holder classes which use default `=` behavior. On the other hand, if you need duplication for classes which do ref-assignment by default, you will need to do it manually in one of methods (like `clone` and call `MyClass x = y.clone()`).
- `x # 5` will evaluate to 5 if x is in undef, else will be evaluated to x.
- `bool changed = (x ? 1 => 2);` set x to 2 if it is 1 in an atomic compare-and-swap and return true if swap is done.


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
For each tempalte class, there is a base interface class which is equal to the class definition minus everything related to typenames. According to definition, all template class instances, conform to the base class, so base interface can be the base type for all template classes. This means `Stack` is the base interface for `Stack<int>, Stack<float>` and all other stacks and if you need to write a method accepting any stack you can use it: `void getStack(Stack s)`.

###Exception handling

- It is advised to return error code in case of an error and use exceptions in really exceptional cases.
- You can use `throw X` to create exception and return from current method.
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

defer(out) { if ( out != @int() ) out++; }  //manipulate function output
defer(out) assert out>0;  //post-condition check
```

###Anonymous class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface specifying one or more functions without any field. If the interface has only one method, the definition can be in short form and it is basically a function pointer. There is a general purpose template class `fn` which is used by compiler to set type of anon-class literals if type is to be inferred.

```
//short form, when interface has only one method
Interface1 intr = (int x, int y) -> x+y;  //specifying type for input is optional
auto ab = (int x) -> x+y; //type will be fn<int, int>
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

*Closure*: All anonymous function and classes, have a `this` which will point to a read-only (not re-assignable) set of local variables in the enclosing method (including input arguments and `this` as the container class).

- As a short-cut provided by compiler, if the anonymous-class `x` has only one method, `x()` will call the only method of that class. You don't need to write the full syntax: `x.only_method()`.
- Anonymous classes don't have constructor, fields or static instance. Because they don't have names.
- If anon-function does not have any input and there is only one function (in short-form), you can omit `() ->` part.

###Data structures

- `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]; int[2,2] x;`. We have slicing for arrays `x[start:step:end]` with support for negative index.
- `int[string] hash1 = { 'OH': 12, 'CA': 33};`.
- `for(x:array1)` or `for(int key,string val:hash1)`.

###Casting and undef state

- `@myclass(my_obj)` returns empty/undefined/not-initialized if myObj cannot be casted to myclass. Compiler will try 3 options for casting: first if `my_obj` conforms to `myclass` it will be casted without change in the data (means `my_obj` has all fields and methods that `myclass` has specified). second looks for a method called `myclass` defined in `my_obj` (This method will convert `my_obj` instance to an instance of `myclass`). third, looks for reverse: a method called `ObjType` in `myclass` static instance (ObjType is type of `my_obj` and this method will crete a new instance of myclass using given `ObjType` instance). All these options will be checked at compile time.
- `float f; int x = @int(f);` this will call `int` method on class `float` to do casting. This can be called automatically by compiler if needed. For template types (like array or hash), you should name the function according to full-name not short-name (`Array<char>` instead of `char[]`).
- empty/undefined/not-initialized state of a variable is named "undef" state and is shown by `@MyClass()` which means casting empty to `MyClass` (MyClass is type of the variable). You can shortcut this by `@MyClass` notation.

###Misc

- **Naming rules**: Advised but not mandatory: `someMethodName`, `some_variable_arg_field`, `MyClass`, `MyPackage` (For basic data types classes in `core` they can use `myClass` notation, like `int`).
- **const**: Class fields which are assigned a value inside `struct` section are constant (compiler handles assignment without invoking the code for assignment operator) and cannot be re-assigned later. Note that, they still can be mutated if they provide appropriate methods. If you need fully immutable classes, you have to implement the logic in your code.
- **Literlas**: `0xffe`, `0b0101110101`, `true`, `false`, `119l` for long, `113.121f` for float64, `1_000_000`. compiler will handle object literals and create corresponding objects (in default arg value, initializations, enum values, true, false, ...). `true` is a shortcut for `bool.true`, same for `false`.
- `///` before method or field or first line of the file is special comment to be processed by automated tools. 
- `myClass.myMember(x: 10, y: 12);`
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
This is a specification and the implementation may choose any strategy (compile to Java Bytecode, interpret, JIT, compile to native, ...).

- Version and history
- Introduction, paradigm and memory model
- Tokens and casing, whitespace, source code encoding, comments, literals
- General rules (underscore, ...) and conventions
- General structure of a source file (classes, methods and fields)
- Packages
- Keywords + brief explanation
- Operators and special syntax
- basic syntax rules + explanations
- Best practices, packaging, versioning, conventions, naming
- How to update this spec?

Sample:
Java [chrome-extension://oemmndcbldboiebfnladdacbdfmadadm/http://cr.openjdk.java.net/~mr/se/8/java-se-8-fr-spec-01/java-se-8-jls-fr-diffs.pdf]  
Rust [https://doc.rust-lang.org/book/]  
Go [https://golang.org/ref/spec]  
