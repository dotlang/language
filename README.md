## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.
2. **Simple**: Easy to learn, read, write and understand. Consistent and logical, as much as possible. Software development is complex enough. Let's keep is as simple as possible and save complexities for when we really need it.
3. **Powerful**: It should enable developers to handle large and complex softwre projects, with relative ease.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer a set of pre-defined rules over keywords in the language.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptios and best practices)
2. A source code compiler (Pre-processor + Interpreter at the first stage, as writing a compiler needs much more time)
2. Debugger tools (for future)
3. Package manager (for future, used to create, install and deploy packages, something like CPAN, PyPi + their client-side tools)
 
###Paradigm

Electron is a declarative, object-oriented programming language.

###Keywords

1. **Conditional**: if, else, switch, case, default
2. **Loop**: for, while, break, continue
2. **Control**: return, defer, throw
3. **Type handling**: void, const, auto, null

Usage of these keywords is almost same as C++ or Java.

### Primitive data types

- **integer data types**: int8 (char), int16, int32 (int), int64, uint8 (byte), uint16, uint32, uint64
- **floating point data types**: float32 (float), float64 (double)
- **others**: bool

### Operators

The operators are almost similar to C language:
- Conditional: `&& || ! == != >= <=`
- Bitwise: `& | ^ ~ << >>`
- Math `\+ \- \* % ++ -- ** `

### Data passing

Primitives are passed by value. Everything else (arrays, string, classes, ...) will be passed by reference.

Although `string` is not primitive, but all string literals will be handled by the compiler behind the scene.

### General structure

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----math  
|-----io  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
|-----|-----socket  

In the above examples `core.math, core.io, core.sys, core.net, core.net.http, core.net.tcp, core.net.socket` are all packages. Each package can have a number of source code files. Each source code file represents one class. Because some OSs have case insensitive naming for file/directory, it is suggested that name of packages and source code files be all lower case. You can separate parts of a name using underscore (e.g. `data_structures`).

There are three types of classes: `simple class`, `static class` and `interface class` (or `interface`). 

Syntax for definition of fields and methods is very similar to other OOP languages like C# or Java.

###Hello World application

Here's how an almost empty application looks:

file: `simple.e`
```
int main()
{
    return 0; 
}
```

This is a static class with only one method, called `main` which returns `0` (Very similar to C/C++ except no input it sent to the `main` function).

###Classes

Each source code file represents a class which can be a simple class (like a normal class in other OOP languages), static class (exactly as the name suggests, you cannot instantiate them and their fields are shared globally) and interface class (same as interface in other languages). 

You don't need to use any keyword or directive to explicitly indicate type of the class.

- If class has no fields or constructor, and none of the methods have a body, then it's an `interface class`.
- If class has a constructor method, it is a `simple class`.
- If class has no constructor method, it is a `static class`. 

Notes:
- It is invalid for a class to have bodies only for some of methods. Either all of methods should have bodies or none of them should have (no abstract class).
- There is no inheritance. We provide composition instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is considered public.


###Class members

- Class members starting with underscore are considered private and can only be accessed by other class members.
- Some basic methods are provided by default for all classes: `toString`, `getHashCode`. You can override the default implementation, simply by adding these methods to your class.
- You can define default values for method parameters (e.g. `int func1(int x, int y=0)`).
- You can call a method using named arguments (e.g. `func1(x=4, y=9)`).
- Constructors are special methods named `new` with implicit return type (e.g. `new() { return core.init.create<myclass>(); }`).
- The syntax to initialize variables is like C++ uniform initialization (e.g. `class1 c = class1 {10, 4};` or `interface1 intr = class1 {3, 5}` or `class1 c = {}` to use default constructor)
- When accessing local class fields, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`).

###Compiler directives and annotation

You can add compiler directives to the code. These are like Java's annotations or C# attributes. They all start with at sign (`@`). Below is a list of them:

- `@assert`: Insert runtime assertations (pre-requisite for a method) defined before function definition.
- `@import`: Include another package (e.g. `@import(core.data.*)` to include all classes inside a package, `@import(core.data.util)` to include a static class, `@import(core.data.* -> .)` to include members of `core.data` inside current namespace).
- `@implements`: Indicate this class should implement methods of another interface.
- `@annotate` (or `@@`): Apply a custom annotation (e.g. `@@class1 {1, 2, 3}`).
- `@ctor`: Auto implement a default constructor for current class.
- `@expose`: Delegate some method calls to a class member. This can be done for all public methods of the class member (`@expose`), some of them (`@expose(method1, method2)`) or all except some (`@expose(!method1, !method2)`).
- `@enum`: Define enum type (Used in it's own file). `@enum(int) sat=1; sun=2; mon; tue; wed; thu; fri;`.
- `@template`: Explained in the corresponding section.

###Generics

You can use compiler directive `@template` to indicate current class is a generic class. You can define arguments of the template like `@template(T)` and use `T` inside the class body.

To use the generic class you use this syntax: `class1<int> c = class1<int> {}`. When you instantiate a generic class, compiler will re-write it's whole file using provided data, then compile your code. You can even use template for passing a data which is not a type name:

```
@template(T)

int x = T;
```

Assuming above code is in a file named `class1` you can use `class1 c1 = class1<10>{}` to have `c1.x` equal to 10.

To escape from all the complexities of generics in other languages, we have no other notation to limit template type or variable template types.

? - Maybe we provide default value for template arguments.

###Exception handling

- You can use `throw` keywords to throw an exception object and exit current method: `throw {1, 2}`
- You can catch thrown exception in your code using `if` command: `int y = func1(); if ( $ ) ...`.
- You can use `defer` keywords (same as what golang has) to define code that must be executed even in case of exception.

###Anonymous class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface. If the interface has only one method, the definition can be in short form.

```
//short form
interface1 intr = (x, y) -> { x+y; };

//long form
interface1 intr = interface1 
{
    int function1(int x,int y) 
    {
        return x+y;
    }
};
```

###Misc

- It is suggested to use camelCasing for methods, fields and local variables.
- It is suggested to name package and classes using lower case names, connecting words using underscore (e.g. `thread_manager`).
- **Operator overloading**: A class can overload `[]` and `==` operators for it's instances by having methods called `setData`, `getData` and `equals`.
- **Checking for implements**: You can use `(interface1)class1` to check if `class1` implements `interface1`.
- **const**: You can define class fields, function arguments, local variables and function output as constant.
- **Literals**: `0xffe`, `0b0101110101`.
- **Digit separators**: `1_000_000`.
- **Suffixed if and for**: `return 1 if x>1;`, `x++ for(10)`, `x += y for (y: array)`.
- **Arrays**: Same notation as Java `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]`.
- **For**: You can use `for` to iterate over an array `for(x:array1)` or repeat something `n` times `for(n)`.

###Core package

A set of core packages will be included in the language which provide basic and low-level functionality:

- Calling OS services
- Calling C/C++ methods
- Reflection and extracting annotations
- Data conversion
- Exception handling

###Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language. Here is a list of some of classes in this package collection:

- I/O (Network, Console, File, ...)
- Thread and synchronization management
- Serialization/Deserialization
- Functional programming: map/reduce/filter
- String and Regex
- Collections (Stack, Queue, Linked List, ...)
- Encryption
- Math
- ...

#Package Manager

The package manager is a separate utility which helps you package, publsh, install and deploy packages (Like `maven` or `dub`).
