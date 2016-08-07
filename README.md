## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) and being familiar with some others (including Go, Scala and Rust) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Simple**: Easy to learn, read, write and understand. Consistent and logical, as much as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable developers to organize, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer using a set of pre-defined rules over keywords in the language.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptions and best practices)
2. A JIT interpreter/compiler
2. Debugger tools
3. Package manager (Used to build, create, install and deploy packages, something like CPAN, PyPi + their client-side tools)

Why not compile to native code using an ahead-of-time compiler? Because with the ever increasing range of open source software and Software as a Service revolution, almost always you either use an open source library/framework or use a web-based service. Two main benefits of AOT compiler are:

1. Hide some advanced algorithm or intellectual property
2. Performance

As I said, the benefits of the first one are more and more diminishing in the current IT world. For the second part, a JIT compiler can be at par with an ahead-of-time compiler (if not better). Moreover, the JIT compilation provides more flexibility and better optimization possibilities.

Of course the disadvantage of this approach is that the user of your software needs the the JIT compiler in addition to the source code. For the source code, we need to make this process as straightforward as possible.

###Paradigm

Electron is a object-oriented and imperative  programming language with garbage collection memory management. 
The target use case of this programming language is distributed server-side network software.

###Keywords

1. **Conditional**: `if`, `else`, `switch`, `default`, `assert`
2. **Loop**: `for`, `break`, `continue`
2. **Control**: `return`, `defer`
3. **Type handling**: `void`, `const`, `auto`, `null`, `struct`
4. **Other**: `this`, `import`

Usage of these keywords is almost same as C++ or Java, so I omit explanation for most of them in detail.

### Primitive data types

- **Integer data types**: `int8` (`char`), `int16`, `int32` (`int`), `int64`, `uint8` (`byte`), `uint16`, `uint32`, `uint64`
- **Floating point data types**: `float32` (`float`), `float64`
- **Others**: `bool`

### Operators

The operators are almost similar to C language:

- Conditional: `and or not == != >= <= ?`
- Bitwise `& | ^ << >> ~`
- Math `+ - * % ++ -- **`

*Special syntax*: `-> => () : <> *` 
- `->` for anonymous
- `=>` for hash and import
- `()` for casting
- `:` for loop and assert and call by name and array slice
- `<>` template syntax

### Data passing

Primitives are passed by value. Everything else (array, string, classes, ...) will be passed by reference.

Although `String` is not primitive, but all string literals will be handled by the compiler behind the scene.

### General structure

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  


In the above examples `core.sys, core.net, core.net.http, core.net.tcp` are all packages.

Syntax for definition of fields and methods is very similar to other OOP languages like C# or Java.

###Most basic application

Here's what an almost empty application looks like:

file: `Simple.e`
```
int main()
{
    return 0; 
}
```

This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except no input it sent to the `main` function).

###Classes

Each source code file represents either an interface or class. What separates these two is that, an interface has no fieds, and no method has a body. Everything else is considered a class. 

Each class's instances can be referenced using instance notation (`varName.memberName`), or you can use static notation (`ClassName.memberName`) which will refer to the special instance of the class (static instance). There is an static instance for every class which will be initialized upon first reference. 

*Notes:*
- Note that you cannot have bodies only for some of the class methods (no abstract class).
- There is no inheritance. Composition (By using anonymous fields) is encouraged instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, then `struct` and finally methods. 
- There is no constructor. Anyone can create a new instance of a class using C++ uniform initialization form: `auto x = Class1 {1,2}; auto y = Class2 {x:1, y:2}`

###Class members

```
struct 
{
    const int x = 12;
    int y;
    int h = 12;
}

int func1(int y) { return this.x + y; }

```

- Class members starting with underscore are considered private and can only be accessed by other class members.
- Some basic methods are provided by default for all classes: `equals`, `toString`, `getHashCode`. You can override the default implementation, simply by adding these methods to your class.
- You can define default values for method parameters (e.g. `int func1(int x, int y=0)`).
- You can not have methods with the same name.
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`).

###Templates

You can define template arguments and their default values using a comment in the beginning of the file. 

```
//tuple.e
//<T> <TNAME> <R> <RNAME=default>

struct 
{
    T TNAME;
    R RNAME;
}

//main.e code
tuple<int, 'age', String, 'name'> student;
```

To escape from all the complexities of generics in other languages, we have no other notation to limit template type or variable template types.

###Exception handling

We have a global variable names `error` which you can initialize (upon exception) or check for null (for catch).

```
//callee
...
//error variable is of the exception interface
error = MyException {'something went wrong'};
...

//caller
...
if ( error != null ) 
{  
    if ((MyException)error)) ...
    error = null;
}
```
- You can use `defer` keyword (same as what golang has) to define code that must be executed upon exitting current method.
- You can check output of a function in defer (`defer result>0`) to do a post-condition check.

###Anonymous function/class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface. If the interface has only one method, the definition can be in short form. 
Note that both short and long form, the code only has read-only access to variables in the parent method. No access is given to the parent class. In the short-form you cannot use `auto` to define these variables because compiler cannot deduce interface type from right side.

```
//short form, when interface has only one method
Interfac-e1 intr = (x, y) -> x+y;  //specifying type for input is not needed
Intr6 intr5 = () -> 5; //no input
Interface2 intr2 = x -> x+1;  //you can omit parantheses if you have only one variable
Interface1 intr = (x, y) -> { 
    method1();
    method2(x,y);
};

Intr5 pa = this.method1; //compiler handles change in the name, note that by default you don't have access to parent class in an anonymous function but in this case, compiler will handle that. 

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

*Closure*: All anonymous function and classes, have a `this` which will point to a read-only set of local variables in the enclosing method (including input arguments). If you need access to the parent class in your anonymous function, define a local variable of appropriate type in the enclosing method. 

###Enum type

```
//DayOfWeek.e file

//all enums are based on int
const
{
    SAT;  //value is not mandatory
    SUN = 1;
    MON = 2;
}

//no struct, only methods, you can use `this` to refer to the value of enum
void method1() { }

//main.e file
DayOfWeek dow = DayOfWeek.SAT;
dow.method1();
```

###Misc

- **Naming rules**: `camelCasing` for methods, fields and variables, `lower_case_with_underscore` for packages, `UpperCamelCase` for classese, `UPPERCASE` for enumerated names and template parameters.
- **Checking for implements**: You can use `(Interface1)class1` to check if `class1` variable implements `Interface1`.
- **const**: You can define class fields and local variables as constant. You can only delay value assignment for a const variable if it is non-primitive. If value of a const variable is compile time calculatable, it will be used, else it will be an immutable type definition.
- **Literals**: `0xffe`, `0b0101110101`, `true`, `false`.
- **Digit separators**: `1_000_000`.
- **For**: You can use `for` to iterate over an array or hash `for(x:array1)` or `for(k,v:hash1)`.
- **if and for without braces**: `if (x>1) return 1;`, `for(y:array) x += y;`.
- **Arrays**: Same notation as Java `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]; int[2,2] x;`. We have slicing for arrays `x[start:step:end]` with support for negative index.
- **String interpolation**: You can embed variables inside a string to be automatically converted to string. If string is surrounded by double quote it won't be interpolated. You need to use single quote for interpolation to work.
- **Ternary condition**: `iif(a, b, c) ` is same as `a ? b:c` in other languages.
- **Null**: `a = b ? 1` means `a=b if b is not null, else a=1`.
- **Hashtable**: `int[String] hash1 = { 'OH' => 12, 'CA' => 33, ... };`.
- **Const args**: All function inputs are `const`. So function cannot modify any of it's inputs' values.
- **import**: Include other packages.
- **assert**: You can use this to check for pre-condition and with `defer` it can be used to check for post-condition. `assert x>0 : 'error message'` will set error upon failure. `assert x>0 : exit('error message');` this will run the statement upon failure.
- **Documentation**: Any comment before method or field or first line of the file starting with `///` is special comment to be processed by IDEs and automated tools. 
- **Anonymous field**: Adding a field without name in a class, makes the class expose all public members of it. The class can however override them by adding it's own methods (But still it's possible to call overriden methods by `MyClass.MemberType.method()` notation. This can also be used in an interface to denote interface inheritance.
- **Call by name**: `myClass.myMember(x: 10, y: 12);`
- **Check is primitive**: If a variable can be cast to empty interface, it is not primitive. This can be useful in template when checking parameters.
- You cannot start local variable names with underscore.


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

#A sample file
```
import core.math;
import core.math => m;

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
        default: { return 0; }  //default
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
- Template naming (Type vs token)
- Function input are const
- Default static instance
