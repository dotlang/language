## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.
2. **Simple**: Easy to learn, read, write and understand. Consistent and logical, as much as possible. 
3. **Powerful**: It should enable developers to handle large and complex softwre projects, with relative ease.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer a set of pre-defined rules over keywords in the language.

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

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----math  
|-----io  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
|-----|-----socket  

In the above examples `core.math, core.io, core.sys, core.net, core.http, core.tcp, core.socket` are all packages. Each package can have zero or more source code files. Each source code file represents a module. There are three module types which are differentiated based on their contents: `class`, `static class` and `interface` (More exaplanation later). 

Name of the class/interface is same as the filename, so there is no need for a keyword to declare and specify start/end of a definition.

There are a set of compiler directives which you can use in the source code but they must be first elements in the file (before methods and fields definition).

Definition of fields and methods is very similar to other OOP languages like C# or Java.

###Hello World application

Here's how an almost empty application looks:

file: `simple.e`
```
@package

int main()
{
    return 0; 
}
```


