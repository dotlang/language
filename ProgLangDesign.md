Notes from "Hints on programming language design" and 
"Everything you've wanted to know about programming languages but have been afraid to ask" and others:

A good PL will:
- help programming in most difficult parts of his tasks. This is the only and most important factor.
- not only helps you define how program is to run but what is it intended to accomplist.
- encourse and assist the programmer to write a clear and self documenting code.
- Notations should reduce scope of coding error as much as possible or catch them at compile time. 


A requirement for achieving above is simplicity of the language. e.g. machine or assembly format. A memory, small range of instructions each with a uniform format. effect of each instruction is clear. 

So five requirements:
1. Simplicity: Modularity or orthogonality are good as long as they contribute to this feature. 
2. Security (error handling)
3. fast translation
4. efficient object code
5. readability

Sign of simplicity: it is easy to use and understand

#Properties of a good PL
- *Generality*: One `for` statement for all loops.
- *Less exceptions*
- *Less rules*
- *Easily understandable*
- *Intruitive rules*: Least surprise
- *Consistency*: `const` should not have two different meanings
- *Regularity*
- *Orthogonality*: For example object vs primitive, statement vs expression, returning only one element from function, sealed classes, static methods, null, new & constructor syntax, operators, difference between methods and fields, are all different exceptions which imply different behavior/syntax for different elements.
- *Reasonable numbers*: They should be 0, 1 or infinity. That's why we have single inheritance.


Steps that need to be done:
- Decide which features we need (allocation, alias, tuple, macro, ...?)
- Define language syntax
- Define language bytecode instructions
- Given a source code, generate bytecode file
- Given a bytecode file, execute it by JIT

