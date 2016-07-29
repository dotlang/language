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
2. A source code compiler (Pre-processor + Interpreter at the first stage, as wiring a compiler needs much more time)
2. Debugger tools
3. Package manager (used to create, install and deploy packages, something like CPAN, PyPi + their client-side tools)
 
###Paradigm

Electron is a declarative, object-oriented programming language.

###Keywords

1. **Conditional**: if, else, switch, case, default
2. **Loop**: for, break, continue
2. **Control**: return, defer, throw
3. **Type handling**: void, const, auto, null

### Primitive data types

- **integer data types**: int8 (char), int16, int32 (int), int64, uint8 (byte), uint16, uint32, uint64
- **floating point data types**: float32 (float), float64 (double)
- **others**: bool

### Operators

The operators are almost similar to C language:
- Conditional: `&& || ! ==`
- Bitwise: `& | ^ ~ << >>`

### Data passing

Primitives are passed by value. Everything else (arrays, string, classes, ...) will be passed by reference.

### General structure of source code files

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----math  
|-----io  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
|-----|-----socket  

In the above examples `core.math, core.io, core.sys, core.net, core.http, core.tcp, core.socket` are all packages. Each package can have zero or more source code files. Each source code file represents a class. Because some OSs have case insensitive naming for file/directory, it is suggested that name of packages and source code files be all lower case. You can separate parts of a name using underscore (e.g. `data_structures`).

There are three types of classes: `simple class`, `static class` and `interface class` (More exaplanation later). 

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

###Class

Each source code file represents a class which can be a simple class (like a normal class in other OOP languages), static class (exactly as the name suggests, you cannot instantiate them and their fields are shared globally) and interface class (same as interface in other languages). 

You don't need to use any keyword or directive about type of class.
- If class has no fields and none of methods have a body, then it's an `interface class`.
- If class has a constructor method, it is a `simple class` and no one can use it as a static class.
- If class has no constructor method, it is a `static class`. 

Notes:
- It is invalid for a class to have bodies only for some of methods. Either all of methods should have bodies or none of them should have.
- There is no inheritance. We provide composition features instead.
- If a class name (filename) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is considered public. This rule applies to methods and fields of the class too.
- 
###Class members

- Class members starting with underscore are considered private and can only be accessed by other class members.
- Some basic methods are provided by default for all classes: `toString`, `getHashCode`. You can override the default implementation by adding these methods to your class.
- constructor
- You can define default values for method parameters (e.g. `int func1(int x, int y=0)`).
- You can call a method using named arguments (e.g. `func1(x=4, y=9)`).

###Compiler directives and annotation
###Generics
###Exception handling
###Naming
- It is suggested to use camelCasing for methods, fields and local variables.

###Misc
- A class can overload `[]` and `==` operators for it's instances by having methods called `setData`, `getData` and `equals`.
- 
