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

As a 10,000 foot view of the language, code is written in files organized in directories. Each file represents one and
only one class (fields + methods). In Electron, class is equal to class or abstract class or interface in other languages. Classes can import other classes to use them. The entry point of an application is `main` method.

##Lexical Syntax
##Rules and Conventions
##Structure of source file
##Keywords
##Operators and special syntax
##Best practice
##Examples
