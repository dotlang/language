# dot Programming Language (dotLang)

Please refer to the main [website](https://dotlang.org).

# Other components

## Core packages

A set of core packages will provide basic and low-level functionality (This part may be written in C or LLVM IR):

- Calling C/C++ methods
- Interacting with the OS
- Load code on the fly and hot swap
- Data conversion
- Garbage collector (Runtime)
- Serialization and Deserialization
- Dump an object
- RegEx functions
- Concurrency
- Security policy (how to call a code you don't trust)
- Bitwise operators (and, or, shift, ...)

Generally, anything that cannot be written in dotLang will be placed in this package.

## Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in dotLang). Here is a list of some of classes in this package collection:

- I/O (Network, Console, File, ...)
- Collections (Stack, Queue, Linked List, ...)
- Encryption
- Math
- ...

## Package Manager

The package manager is a utility which helps you package, publish, install and deploy packages (Like `maven`, `NuGet` or `dub`).
Suppose someone downloads the source code for a project written in dotLang which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent way to fetch dependencies at runtime and defining them at the time of development.

# History

Below is history of changes (time + summary of what changed) to the dotLang spec.

- **Version 0.1**: Sep 4, 2016 - Initial document created after more than 10 months of research, comparison and evaluation.
- **Version 0.2**: Sep 22, 2016 - Leaning towards Functional Programming.
- **Version 0.3**: Oct 13, 2016 - Added clarifications for inheritance, polymorphism, and templates
- **Version 0.4**: Oct 27, 2016 - Removed some less needed features (monad), defined rules for multiple-dispatch.
- **Version 0.5**: Nov 13, 2016 - Some cleanup and better organization
- **Version 0.6**: Jan 18, 2017 - Cleanup, introduce object type and changed exception handling mechanism.
- **Version 0.7**: Feb 19, 2017 - Fully qualified type name, more consistent templates, `::` operator and `any` keyword, unified enum and union, `const` keyword
- **Version 0.8**: May 3, 2017 - Clarifications for exception, Adding `where` keyword, explode operator, Sum types, new notation for hash-table and changes in defining tuples, removed `const` keyword, reviewed inheritance notation.
- **Version 0.9**: May 8, 2017 - Define notation for tuple without fields names, hashmap, extended explode operator, refined notation to catch exception using `//` operator, clarifications about empty types and inheritance, updated templates to use empty types instead of `where` and moved `::` and `any` to core functions and types, replaced `switch` with `match` and extended the notation to types and values, allowed functions to be defined for literal input, redefined if to be syntax sugar for match, made `loop` a function instead of built-in keyword.
- **Version 0.95**: May 23, 2017 - Refined notation for loop and match, Re-organize and complete the document, remove pre and post condition, add `defer` keyword, remove `->>` operator in match, change tuple assignment notation from `:` to `=`, clarifications as to specifying type of a tuple literal, some clarifications about `&` and `//`, replaced `match` keyword with `::` operator, clarified sub-typing, removed `//`, discarded templates, allow operator overloading, change name to `dotlang`, re-introduces type specialization, make `loop, if, else` keyword, unified numeric types, dot as a chain operator, some clarifications about sum types and type system, added `ref` keyword, replace `where` with normal functions, added type-copy and local-anything type operator (`^` and `%`).
- **Version 0.96**: Jun 2, 2017 - Removed operator overloading, clarifications about casting, renamed local anything to `!`, removed `^` and introduced shortcut for type specialization, removed `.@` notation, added `&` for combine statements and changed `^` for lambda-maker, changed notation for tuple and type specialization, `%` for casting, removed `!` and added support for generics, clarification about method dispatch, type system, embedding and generics, changed inheritance model to single-inheritance to make function dispatch more well-defined, added notation for implicit and reference, Added phantom types, removed `double` and `uint`, removed `ref` keyword, added `!` to support protocol parameters.
- **Version 0.97**: Jun 26, 2017 - Clarifications about primitive types and array/hash literals, ban embedding non-tuples,  changed notation for casting to be more readable, removed `anything` type, removed lambda-maker and `$_` place holder, clarifications about casting to function type, method dispatch and assignment to function pointer, removed opIndex and chaining operator, changed notation for array and map definition and generic declaration, remove `$` notation, added throw and catch functions, simplified loop, introduced protocols, merged `::` into `@`, added `..` syntax for generating array literals, introduced `val` and it's effect in function and variable declaration,  everything is a reference, support type alias, added `binary` type, unified assignment semantic, made `=` data-copy operator, removed `break` and `continue`, removed exceptions and assert and replaced `defer` with RIAA, added `_` for lambda creation, removed literal and val/var from template arguments, simplify protocol usage and removed `where` keyword, introduced protocols for types, changed protocol enforcement syntax and extend it to types with addition of axioms, made `loop` a function in core, made union a primitive type based on generics, introduced label types and multiple return values, introduced block-if to act like switch and type match operator, removed concept of reference/pointer and handle references behind the scene, removed the notation of dynamic type (everything is typed statically), introduced type filters, removed `val` and `binary` (function args are immutable), added chaining operator and `opChain`.
- **Version 0.98**: Aug 7, 2017 - implicit type inference in variable declaration, Universal immutability + compiler optimization regarding re-use of values, new notation to change tuple, array and map, `@` is now type-id operator, functions can return one output, new semantics for chain operator and no `opChain`, no `opEquals`, Disposable protocol, `nothing` as built-in type, Dual notation to read from array or map and it's usage for block-if, Closure variable capture and compiler re-assignment detection, use `:=` for variable declaration, definition for exclusive resource, Simplify type filters, chain using `>>`, change function and lambda declaration notation to use `|`, remove protocols and new notation for polymorphic union, added `do` and `then` keywords to reduce need for parens, changed chaining operator to `~`, re-write and clean this document with correct structure and organization, added `autoBind`, change notation for union to `|` and `()` for lambda, simplify primitive types, handle conditional and pattern matching using map and array, renamed tuple to struct, `()` notation to read from map and array, made `=` a statement, added `return` and `assert` statement, updated definition of chaining operator, everything is now immutable, Added concept of namespace which also replaces `autoBind`, functions are all lambdas defined using `let`, `=` for comparison and `:=` for binding, move `map` data type out of language specs, made `seq` the primitive data type instead of `array` and provide clearer syntax for defining `seq` and compound literals (for maps and other data types), review the manual, removed `assert` keyword and replace with `(condition) return..`, added `$` notation, added `//` as nothing-check, changed comment indicator to `#`, removed `let` keyword, changed casting notation to `Type.{}`, added `.[]` instead of `var()`, added `.()` operator
- **Version 0.99**: Dec 30, 2017 - Added `@[]` operator, Sequence and custom literals are separated by space, Use parentheses for custom literals, `~` can accept multiple candidates to chain to, rename `.[]` to custom process operator, simplified `_` and use `()` for multiple inputs in chain operator, enable type after `_`, removed type alias and `type` keyword, added some explanations about type assignability and identity, explain about using parenthesis in function output type, added `^` for polymorphic union type, added concurrency section with `:==` and notations for channels and select, added ToC, ability to merge multiple modules into a single namespace, import parameter is now a string so you can re-use existing bindings to build import path, import from github accepts branch/tag/commit name, Allow defining types inside struct, re-defined generics using module-level types, changed `.[]` to `[]`, comma separator is used in sequence literals, remove `$` prefix for struct literals, `[Type]` notation for sequence, `[K,V]` notation for map, `T!` notation for write-only channel and `T?` notation for read-only channel, Removed `.()` operator (we can use `//` instead), Replaced `.{}` notation with `()` for casting, removed `^` operator and replaced with generics, removed `@` (replaced with chain operator and casting), removed function forwarding, removed compound literal, changed notation for channel read, write and select (Due to changes in generics and sequence and removal of compound literal) and added `$` for select, add notation to filter imported identifiers in import, removed autoBind section and added a brief explanation for `TargetType()` notation in cast section, rename chain operator to `@`, replaced return keyword with `::`, replaced `import` with `@` notation and support for rename and filter for imported items, replaced `@` with `.[]` for chain operator, remove condition for return and replaced with rule of returning non-`nothing` values, change chain notation from `.[]` to `.{}` and import notation from `@[]` to `@()`, Added notation for polymorphic generic types, changed the notation for import generic module and rename identifiers, removed `func` keyword, extended general union type syntax to unnamed types with field type and names (e.g. `{id:int, name:string,...}`), Added shift-left and right `>>,<<` and power `**` operators, all litearls for seq and map and struct must be prefixed with `_`, in struct literals you can include other structs to implement struct update, changed notation for abstract functions, Allow access to common parts of a union type with polymorphic union types, use `nothing` instead of `...` for generic types and abstract functions, removed phantom types, change `=>` notation to `^T :=` notation to rename symbols, removed composition for structs and extended/clarified usage of polymorphic sum types for embedding and function forwarding, change map type from `[K,V]` to `[K:V]`, removed auto-bind `Type()`, remove abstract functions, remove `_` prefix for literals, remove `^` and add `=>` to rename types so as to fix issue with introducion of new named types when filtering an import operation, replace operators `:=` to `=` and `:==` to `==` and `=` (comparison) to `=?`, adding type alias notation `T:X`, change import operator to `@[]` and replace `=>` with type alias notation, use `:=` to calculate in parallel and `==` to equality check
- **Version 1.00-beta**: July 5, 2018 - Use `=` for type alias and `:=` for lazy (parallel) calculation and named type, More clarification about binding type inference, explain name resolution mechanism for types and bindings and function call, added explanation about using function name as a function pointer, explanation about public functions with private typed input/output, removed type specifier after binding name (it will be inferred from RHS), changed function type to `(input:type->output_type)`, removed chanin operator, some clarifications about casting operator and expressions, remove `::` and use bindings for output with future reference, allow calling lambda at the point of definition, allow omitting types if they can be inferred in defining functions, indicate that functions cannot have same name and introduce compile-time dynamic sequence to store multiple functions and treat the sequence as a function, restore using type name before struct literal, change `...` as a more general notation for polymorphic union types, re-write generics as code-generation + compile-time dynamic sequence for functions, add `*` destruct operator for struct explode which can also be used to call a function with named arguments or initialize a sequence, remove notation for casting a union to it's elements (replaced with use of sequence of functions), replace `...` notation with already defined `&` and `|`, removed `${}` notation for select and replaced with a function call on a sequence, removed concept of treating sequence of functions as a function, added `type` core function + ability to amend module level collections using `&`, explained loop built-in function for map, reduce and filter operations
- **Version 1.00-beta2**: Nov 6, 2018 - Add support for **`type` keyword** and generics data types and generic functions, remove map and sequence from language, defined instance-level and type-level fields with values, added `byte` and `ptr` types to primitive types, add support for vararg functions, added Patterns section to show how basic tools can be used to achieve more complex features (polymorphism, sequence, map, ...), use **mailbox instead of channels** for concurrency, clarification about using unions as enums + concrete types, added `::` operator for return and conditional return, changed polymorphism method to avoid strange linked-list notations for VTable or functions with the same name and use closure instead, added `*` for struct types, Allow functions to return types and use it to implement generics, Return to `[]` notation for map and sequence and their literals, Allow defining types inside struct which are acceissble through struct type name, Import gives you a struct which you can assign to a name or alias or import into current namespace using `*`, Make task a type in core as `SelfTask` and `Task` which provide functions to work with mailbox, Add functions in core to seq and map for map/reduce/filter/anymatch, remove `ptr` type, remove vararg functions, clarification about tasks and exclusive resources, use core for file and console operations, use `$` to access current task, use dot notation to initialise a struct, support optional type specification when defining a binding, set `@` notation to **import a module as a struct type** which you can use just like any other type, we have closure at module level, review the whole spec, use `{}` for casting, use `:` for type alias, use `+` for concat and `&` for concurrency, destruct using `{}` on the left side, no more `:=`, remove range operator, use `:=` for concurrency, replace `$` with core function, `:=` returns a normal output and you should use `getCurrentTask().children()` to access newly created child task
- **Version 1.00**: April 4, 2019 - replace `@` with import keyword, replace `::` with `return` keyword and remove conditional return, In function decl, after `->` it must be a type, use `fn` prefix for function type and literal, use `struct` for struct type declarations, clarification about module import and dependency management, remove return keyword, don't force braces to be on their own line, added optional arguments to pattern section, clarification about structs with field name but no named type, allow multiple module import, destruct without assignment gives you struct with unnamed fields which has both bindings and types, allow omit argument which are `|nothing` in function call, use `=` for type alias and `:=` for named type (because `:` for type alias caused confusion and ambiguity), use `$` to auto inference of generic types, clarification about dependency and version management, simplify concurrency by removing lambda when receiving messages, `check` core function, remove `$` and replace it with `|nothing` as optional generic type argument, remove `xor` keyword, make `_` as private rule a convention and not a rule, import gives us a Module identifier which is not a struct, struct can only have a list of fields without value (so no closure inside struct), make generic types always inferred by compiler if they are missing, use `:` for type alias and `=` for named type, treat type names as functions for casting, no `_` for untyped struct you must write type even if the type definition itself, no `.1` notation instead use destruction, do not use `{}` for destruction, no notation for modify existing struct as a new binding, use `()` for structs instead of `{}`, use `cast, tryCast` for casting, add `enum`s, use `..` to access inside module and allow import into current namespace, remove multiple import notation, use destruction for unions, cast for named types using identity functions, generic types using normal `()` functions, allow selective import, clarify about calling generic function with unions, state `_` is usable with union destruction, support for test built-in
- **Version 1.00**: Aug 1, 2019 - Clarification about using functions that accept more or return less that type-set we expect, back to channels for concurrency and use `///` for select, support validation using fn after struct type 
- Apr 13, 2020: Added support for early return and error handling via `@{}` notation.
- Apr 23, 2020: Added `${}` notation for union checks.
- Apr 25, 2020: Some clarification about select and default option in concurrency
- May 11, 2020: Channels are structs, select is done via std, struct with functions makes more sense that esoteric notations like `f() vs. f(data)` and runtime arg.
- May 13, 2020: Remove `${}` notation. We can use casting to achieve almost the same thing. Casting is done via `T(value)` notation.
