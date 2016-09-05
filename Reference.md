#Electron Programming Language Reference Document
Version 0.1  
September 4, 2016

##History
- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 9 months of research, comparison and thinking.

##Introduction
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

1. **Consistency and Simplicity**: The code written in Electron language should be easy to learn, read, write and understand.
There has been a lot of effort to make sure there are as few exceptions as possible. Software development is complex enough. 
Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable (a team of) developers to organize, develop, test, maintain and operate a large and complex 
software project, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages and 
something like Java.

Achieving all of above goals at the same time is something impossible so there will definitely be trade-offs and exceptions.
The underlying rules of design of this language are 
[Principle of least astonishment](https://en.wikipedia.org/wiki/Principle_of_least_astonishment), 
[KISS rule] (https://en.wikipedia.org/wiki/KISS_principle) and
[DRY rule] (https://en.wikipedia.org/wiki/Don%27t_repeat_yourself).

As a 10,000 foot view of the language, code is written in files organized in directories (called packages). Each file represents one and
only one class (fields + methods). In Electron, class can be analogous to class or abstract class or interface in other languages. Classes can import other packages to use their classes. The entry point of an application is the `main` method.

##Lexical Syntax
- **Encoding**: Source code files are encoded in UTF-8 format.
- **Whitespace**: Any instance of space(' '), tab(\t), newline(\r and \n) are whitespace and will be ignored.
- **Comments**: C like comments are used (`//` for single line and `/* */` for multi-line).
- **Literals**: `123` integer literal, `'c'` character literal, `'this is a test'` string literal, `0xffe` hexadecimal number, `0x0101011101` binary number, `192.121f` double, `1234l` long. 
- **Adressing**: Each type, field or method can be address in the format of `A.B.(...).D` where `A`, `B` and other parts are each either name of a package or class. The last part `D` is name of the field or method or type which is being addressed.

##General Rules
Almost everything is an object, even basic data types and everything is passed by value, but everything is a reference. Every class has a special instance (static instance), which is created by the compiler. This instance can be used to create other instances of the class. But at very few cases compiler does something for the developer automatically. Most of the time, developer should do the job manually.

##Structure of source file
1. Imports: importing other packages
2. Type alias definitions: `type` statements
3. Fields of the class: fields definition
4. Methods of the class: method definition

##Keywords
###if, else
###switch
###assert
###for, break, continue
###return
###throw
###defer
###type
###import
###void
###auto
###invoke
###select

###Primitives
##Operators
Each class can provide implementation for operators. 
##Special syntax
###Anonymous classes `->`
###Tuples
###Casting and Undef
###Instantiation
###Templates
###Optional arguments
###Reference assignment
###Array slice
###Array and hash

##Best practice
###Naming
##Examples
