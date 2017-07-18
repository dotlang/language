Y - syntax to fetch from map is not extendable:
`["A"]myMap(1)` map key is string and value is function pointer.
The dual behavior (key before or after map name) is a bit confusing.
The reason we bring key before is for readability when implementing if conditions,
`[key]map`
`map[key]`
`$[1:2, 3:4][1]`
`[1]$[1:2, 3:4]`
solution 1: only use suffix syntax.

Y - `myMap["A"](1,2)[0]`
`myMap["A"]`
`"A" . myMap`
Can't we use notation for function chaining on a map or array?
If we use `myMap("A")` notation, it will be more straight forward.
`myMap("A")` ~ `"A" . myMap(_)`
Also if function has only one input, we can omit `_`?
We can say `process` as an identifier, is same as `process(_)`.
what about: `${1,2} . add`? not possible. if add expects two inputs we have to write:
`${1,2} . add(_,_)`
But if we use same notation for setting values, it will be confusing.
if we make reading from array and map, like calling a function, it will be easier for implementing loop and conditionals.
but then we need a separate notation for setting values.
`arr(0)` reads
`arr(0, 10)` writes
`map("A")` reads
`map("A", 5)` writes
advantage: even more orthogonal. As it is like a function call. we can chain it or ....
advantage: prefix and suffic notation are both possible with chaining.
con: it will be confusing with function call. Let's have a special function `$` for reading and writing from array and map.
`var x = $(arr, 0)`
`$(arr, 0, 10)` set
`$(map, "A")`
we already have a flat namespace. Adding an extra level of names might be confusing.
proposal 1: use array of map name as a function.
proposal 2: use a special function like `$` to get or set.
let's go with proposal 1. more orthgonality, less new syntax.
what about slice and 2d array?
`matrix(0, 0)` read
`matrix(0, 0, 10)` write
slice: we can use a function in core. do we really need slice? Why should they be mapped to the original array? can't we just create a new array? Just forget about it. we will use core functions.
1. array: get using `arr(0)` set using `arr(0, 1)`
2. map: get using `map("A")` set using `map("A", 1)`
3. remove slices altogether. add todo to be added for core functions.

Y - Let's say, function name without `()` means a lambda for all it's inputs.
so `twoArgFunc` is a shortcut for `twoArgFunc(_,_)`

N - Can we use map as a real function and send it to another function to enable it to modify my map by calling that function?
NO. map is not a function. It acts like a function.

Y - Now that read/write for array and map uses `()` notation can we use literals without `$`?
What about tuple? For tuple it is different. we need it because we use `{}` for code block too and if a function only returns a tuple literal it will be confusing.
We can remove it for array and map.

? - Rename tuple to struct.

? - one negative thing about literals is that they are not orthogonal.
can we make them + tuple orth?
`var arr = $[1, 2, 3]`.
we can say `$` is a special function which creates array and map literals.
`$` creates array literals.
`%` map literals
`^` tuple literals.
why not use their type name?
`var t = array(1, 2, 3)`
`var m = map("A", 1, "B", 2)`
But if we use same notation for literal as for reading, then conditional implementation will not be very readable:
`map("A", 1, "B", 2)("A")`
vs.
`$["A": 1, "B": 2]("A")`
We use `[]` for array and map literals.
Why not use it for tuple literal? Because it can be mistaken with map literal.
`var t = [a: 1, b:2]`
is above a map with keys of values of a and b. or a tuple with a and b fields?
what if we use `.field`?
`var t = [.a: 1, .b:2]`
Then `{}` will be only for code block.
`var pt = Point[10, 20]`
Examples:
1. `type Point := [x:int, y:int]`
2. `var point = [100, 200]`???
3. `var point = Point[x:100, y:200]`
4. `my_point = Point[100, 200]`
5. `x,y = point`
6. `x,y,z = [100,200, "A"]`
7. `another_point = my_point[x:11, y:my_point.y + 200}`
8. `another_point = my_point`, `another_point.x = 11`, `another_point.y += 200`
9. `new_point = {a=100, b=200} //WRONG!`
we want dot operator support for tuples. `tpl1.field1`.
we can say tuple is a special case of map. but for a map all values must of the same type.
we can say, tuple is an array of pairs. but each pair has a different type. so it is not an array too.
`type Point := {x: int, y:int}`
read/write for tuple is done using dot operator. 
proposal 1: use `[.field1: value1, .field2: value2, .field3: value3]` for tuples.
but this makes them like map. can we use same notation? no. it will make things confusing.
Actuallt, this is not tuple. It is a struct.
1. `type Point := {x:int, y:int}`
2. `point = ${100, 200}`
3. `point = Point{.x=100, .y=200}`
4. `my_point = Point{100, 200}`
5. `x,y = point`
6. `x,y = ${100,200}`
7. `another_point = my_point{.x=11, .y=my_point.y + 200}`
8. `another_point = my_point`, `another_point.x = 11`, `another_point.y += 200`
9. `new_point = {a=100, b=200} //WRONG!`
What about this: struct is a map with values of different types.
keys are string but values have different types. We specify type of value for each key.
we need to support variadic templates and string as template arguments.
`type Point := struct["x", int, "y", int]`
you cannot read from a struct with a variable. You must refer to it's inside data using a literal string.
Adding this orthogonality will make code much less readable. Let's agree to add a new concept: struct.
How shall we define struct literal?


? - Maybe we can use a set of rules or regex to convert code to LLVM IR.
or a set of macros. 
these can indicate micro-commands to be executed by the compiler so we will be coding our compiler into that notation.
Compiler just needs to scan the source code, apply macros and run microcommands.
This will be a very special macro language which is designed for this compiler and this language.
Won't it be same as writing C code? If it can be more maintainable maybe we can use it as an intermediate IR between dotlang code and LLVM IR.

? - We should have a modular design for compiler.
Lexer, Parser and some extensions which process parser output.
What we need to specify?
Steps in the compilation process and what is input/output of each step.
The type of rules that we need to have.
e.g.
```
ante
![on_fn_decl]
fun name_check: FuncDecl fd
    //NOTE: fd.name is the mangled name
    if fd.basename != fd.name then
        compErr "Function ${fd.basename} must be declared with ![no_mangle]" fd.loc

    if not fd.name.startsWith "vk" then
        compErr "Function ${fd.basename}'s name must be prefixed with 'vk'" fd.loc
```
or:
```
![macro]
fun goto: VarNode vn
    let label = ctLookup vn ?
        None -> compErr "Cannot goto undefined label ${vn.name}"

    LLVM.setInsertPoint getCallSiteBlock{}
    LLVM.createBr label

![macro]
fun label: VarNode vn
    let ctxt = Ante.llvm_ctxt
    let callingFn = getCallSiteBlock().getParentFn()
    let lbl = LLVM.BasicBlock ctxt callingFn
    ctStore vn lbl
```
e.g. For each function we need to keep it's escape list.
For each line we need to keep bindings used in that line.
We need a list of all functions.
We need a multi-pass scan: 
- Pass1: Scan all types and functions (even generics) and built a map of them.
- Pass2: Process each function (generate if it is generic) and create intermediate representation. Do all required checks.
- Pass3: Optimize intermediate-representation for de-referencing, copy, dispose call, mutable data.
- Pass4: Generate LLVM IR and feed it to llvm.
We can do each of these passes for each function separately. Because each function is considered it's own world.
Step 1: Collect a list of all type names and function names (even generics).
Step 2: Compile each function into LLVM IR using below steps:
- Phase A: Make all type name and function calls to normal function or type reference.
- Make sure appropriate generic function is generated.
- Do all checks and issue error messages if needed.
- Create rule list based on function statements.
- Do optimizations.
- Generate LLVM IR.
Step 2 is done for each function in the list created in Step 1 + functions requested in step 2.
We have two lists: Functions, Types. Each element can be marked as concrete or generic.
Generics are not compiled. They are just used to create concrete elements.
We need to compile each non-generic function in the list.
==========
Step 0: Prepare 4 maps: CFunc, GFunc, CType, GType (Concret/Generic function/type)
Each element in the map contains the location in the source code file too. Or maybe we can keep the body of type or function in-memory so this will be the first and last time we need to read disk.
Step 1: Lex all input files for type name and function name and populate 4 maps.
Step 2: Prepate CQ which is compilation queue. It initially contains only `main` function.
Step 3: Fetch from CQ and lex/parse contents of that element. Do error checks.
If it is a function call, add it to CQ and render an invoke statement.
Step 4: After step 3 is finished, we don't need text of type and functions. Just IR.
Step 5: Optimize IR.
Step 6: Convert IR to LLVM IR and generate native code.
================
For now, let's just ignore generics and assume everything is concrete.
We will have two maps: Func and Type.
Step 0: Prepare two maps Func and Type where key is string and value is a structure of type FunctionDescriptor or TypeDescriptor
Step 1: Lex the input file and just read names of types and functions and update Func/Type maps.
Step 2: Prepare CQ (compilation queue) and add `main` to it.
Step 3: Repeat until CQ is empty: 
  A. Fetch function name F from CQ
  B. Find it in Func map and fetch FunctionDescriptor
  C. Lex it's contents and check for lex errors.
  D. For each function call, first make sure we have such a function. If so, add it to CQ
  E. render intermediate code (between dotlang and LLVM IR) containing simple expressions and method calls.
  F. Check for optimizations.
  G. FunctionDescriptor will contain function body, intermediate codes, metadata, ...
  H. Render intermediate codes to LLVM IR.
  I. Send output LLVM IR to a IR repository.
Step 4: Send IR repository contents to LLVM compiler.
Transforms:
- chaining operator is transformed to normal function call.
- dot operator is transformed to an internal offset fetch.
- get operators are transformed to internal offset fetch
- set operators are tx to internal operation which has potential to be optimized.
- math: divided into separate expressions and temp bindings.
- if/else. simplified to a binding for condition and if with only one boolean variable.
- switch.
- No type inference
- No closure
- explicit dispose and malloc
- No generics
what would the intermediate code look like? It will be called semi-ir.
Maybe we can merge two maps into "Symbols" map with a kind which can be type or function.
We should process types first because they dont rely on functions.
============
Step 0: Prepare SymbolMap which maps string to Symbol struct. This includes kind field (type or function) + the source code definition + metadata + intermediate code
Step 1: Lex the input file and just read names of types and functions and update SymbolMap.
Step 2: Prepare CQ (compilation queue) and add `main` symbol to it.
Step 3: Repeat until CQ is empty: 
  A. Fetch function name F from CQ
  B. Find it in Func map and fetch FunctionDescriptor
  C. Lex it's contents and check for lex errors.
  D. For each function call, first make sure we have such a function. If so, add it to CQ
  D1. Metadata for function: Functions it calls, local variables and if they are part of return, stack size.
  E. render intermediate code (between dotlang and LLVM IR) containing simple expressions and method calls.
  F. Check for optimizations.
  G. FunctionDescriptor will contain function body, intermediate codes, metadata, ...
  H. Render intermediate codes to LLVM IR.
  I. Send output LLVM IR to a IR repository.
Step 4: Send IR repository contents to LLVM compiler.

? - example
```
let a : Point = Point{100, 200}
...
let u = a.x - make u point to address of a + offset but if it is an int, just make a copy
```
for `let` make a copy for int, char, float and create a pointer for all other cases.
union will be rendered as `tag + buffer`. if all cases are primitives or label types, it will be marked as value type (copy on assignment), else, it will be a pointer.

? - implementation
- we should keep an integer for each type to be for `@` operator
- q: can we have overloaded functions in llvm ir?
- q: can I really inline llvm ir functions?
- determine in which case can I make a binding mutable?


? - Allow overloading based on return type and give error if assignments like `x=func1()` are ambiguous.
We already have this by `autoBind` function.
So either you have to write: `x: Type1 = func1(1,2,3)` or if it is generic with generic output argument: `x = func1[Type1](1, 2, 3)`
