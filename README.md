## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) it still irritates me that these languages are sometimes seem to intend to be overly complex. This doesn't mean I don't like them but still doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. Fast: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.
2. Simple: Easy to learn, read, write and understand. Consistent and logical, as much as possible. 
3. Powerful: It should let developer(s) handle large and complex softwre projects, with relative ease.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve design goals.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptios and best practices)
2. A source code compiler (Pre-processor + Interpreter at the first stage, as wiring a compiler needs much more time)
2. Debugger tools
3. Package manager (used to create, install and deploy packages, something like CPAN, PyPi + their client-side tools)
 
###Paradigm

Electron is an declarative, object-oriented programming language.

###Keywords

1. **Conditional**: if, else, switch, case, default
2. **Loop**: for, break, continue
2. **Control**: return, defer, throw
3. **Type handling**: void, const, auto, null

### Primitive data types

- integer data types: int8 (char), int16, int32 (int), int64, byte
- floating point data types: float32 (float), float64 (double)
- others: bool

### Operators

The operators are almost similar to C language:
- Conditional: `&& || ! ==`
- Bitwise: `& | ^ ~`

### Data passing

Primitives are passed by value. Everything else (arrays, string, classes, ...) will be passed by reference.

### General structure of source code files

Code is organized into modules. Each module is represented by a directory in the filesystem. Modules have a hierarchical structure:

core  
|-----math  
|-----io  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
|-----|-----socket  

In the above examples `core.math, core.io, core.sys, core.net, core.http, core.tcp, core.socket` are all modules. Each module can have zero or more source code files. Each source code file must contains definition for one of `class` or `package` or `interface`. Class and Interface are same as what we have in other PLs. Package is like a static class (so it does not have state). More exaplanation later. Name of the class/interface/package is same as the file-name, so there is no need for a keyword to declare and specify start/end of class definition.

There are a set of compiler directives which you can use in the source code but they must be first elements in the file (before methods and fields definition).

Definition of fields and methods is very similar to other OOP languages like C# or Java.

