! - If this is going to be 90% similar to another programming language, then why bother?
I need to test new ideas and approaches without fearing to fail.

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

Y - Rename tuple to struct.

N - one negative thing about literals is that they are not orthogonal.
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
3. `point = Point{x=100, y=200}`
4. `my_point = Point{100, 200}`
5. `x,y = point`
6. `x,y = ${100,200}`
7. `another_point = Point{x=11, y=my_point.y + 200}`
8. `another_point = my_point`, `another_point.x = 11`, `another_point.y += 200`
9. `new_point = ${a=100, b=200} //WRONG!`
What about this: struct is a map with values of different types.
keys are string but values have different types. We specify type of value for each key.
we need to support variadic templates and string as template arguments.
`type Point := struct["x", int, "y", int]`
you cannot read from a struct with a variable. You must refer to it's inside data using a literal string.
Adding this orthogonality will make code much less readable. Let's agree to add a new concept: struct.
How shall we define struct literal?
The only purpose of addin `$` prefix is to make code readable and prevent confusion.
`func myFunc9(x:int) -> {int} {12}`
`x={12}` is this a code block which evaluates to 12 or a tuple literal?
`x=[12]` array with one element
`x=["A":12]` map
`x=(12)`?
`x=(a=1, b=2)` it will be confusing with function call. let's stick to `${}`

N - `type array[T] := map[int, T]`?

Y - remove `++` and `--`. If they are not expressions, why have them and make people confused?
Let's keep them. It is intuitive.
But we want everything to be expression to be composable.

Y - Expressions are composable so add to orth.
What non-exp do we have? var decl., 
whatever you cannot pass as an argument?
you cannot combine statements. 
function calls are statement because they return something (even if nothing).
loops should also be expressions. This means that the function handler should return two things: next iterator and iteration result.
`[10 .. (x:int)-> {print(x), x--} .. 0]`
`g = [10 .. (x:int)-> {print(x), ${x, x-1} } .. 0]`
then g will be `[10,9,...,0]`
`g = [10 .. (x:int)-> x-1 .. 0]`
`g = [0 .. (x:int)-> arr1[x]+1 .. length(arr1)]`
we have two things: iteration result and next iteration input.
either we can specify both in the lambda or use convention for one of them.
solution1: lambda returns the value of iteration, next iteration input is determined using a function call. (on what?)
solution2: lambda returns next iteration input. the value is determined using `getValue` function call. what if we want to have different `getValue` for different types? e.g. a loop on customer list, first time we extract their names, then their ids.
let's say, if lambda returns one thing: it will be both value of this round and input to next round. if it returns two things, first is value and second is input for the next round.
loop stops as soon as input to the next round is same as end marker.
`g = [10 .. (x:int)-> x-1 .. 0]` 
`g = [0 .. (x:int)-> arr1[x]+1 .. length(arr1)]`
```
myOutput = [
iter .. 
  (x: Iterator)->
  {
      [true: ${nothing, nothing}, false: ${x, getNext(x)}](eof(x))
  }   
.. nothing
]
```
proposal: lambda always returns next round input. value can be extracted by calling another function outside `[]`.
`g = [0 .. (index:int)-> index+1 .. length(arr1)] . arr1(_)`
another way to have loop: chain operator + array.
if we chain an array to a lambda which has only one input, it will be called in order and generate a new array.
so, the array can be anything. literal or use a lambda to create iterators.
`g = [0 .. (index:int)-> index+1 .. length(arr1)] . arr1(_)`
```
myOutput = [
iter .. 
  (x: Iterator)->
  {
      [true: nothing, false: getNext(x)](eof(x))
  }   
.. nothing
] . getValue(_)
```
so with a lambda: `[start..lambda..end] . func`
output of the first part `[start..lambda..end]` is: `[x0=start, x1=lambda(start), x2=lambda(x0), ... ]`
we continue until output of lambda is same as end. then we stop. we don't end in the output. so it can be used as a marker without any useful information (e.g. nothing).
then we feed the array to the lambda.
the array can contain structs which will be fed to the lambda2. 
lambda can output anything as long as it can accept the same thing and func accepts it.
`[${start,0}..lambda..${end,0}] . func(_,_)`
start, end, lambda input and output and func input must be same type. int or string or struct or ...
`out = [start..(input: start)->output..end] . lambda(lin)`
type of start, output, end and lin must be the same. out will be an array of type of output of lambda.
if no lambda, out will be of type of output.
But if left side is an array, what if lambda accepts an array?
`[1,2,3] . (x:int)->x+1` it can be deduced from the context. lambda must specify input type. even if we use `process(_)` the process function has input type.
If chain target accepts an array, the whole array will be sent to it.
1. extend chain operator: if left side is `array[T]` and chain target accepts `T`, it will process each element of the array.
2. array range operator: clarify definition and algorithm.
start is inclusive but end is not.
lambda is used to fetch the next element of the array.
NO to extending chain operator. It will make language more difficult.
```
myOutput = [
iter .. 
  (x: Iterator)->
  {
      [true: ${0, nothing}, false: ${getData(x), getNext(x)}](eof(x))
  },
  (x: Iterator) -> getData(x)
.. nothing
]
```
two lambda is confusing. Let's say lambda returns two things: value and next.
problem: 1. when returning end marker we have to also send a dummy value for round output.
2. if we want to return a tuple as round value, it will not be very readable.
`[0..10]` ~ `[0..(x:int)->${x, x+1} .. 10]`
what if we say, next is determined using convention and round output is the output of the lambda?
still generating custom int ranges (`1,3,5,7,...` ...) anything which is not +1 or -1 will be more difficult.
what if we don't want to have an array? Just run a code with some side-effect?
WAIT! it we use lambda, we cannot modify any non-local variable:
```
[
iter .. 
  (x: Iterator)->
  {
      append(myOutput, getData(x))
      [true: nothing, false: getNext(x)](eof(x))
  }   
.. nothing
]
```
This is not correct. `append` will modify `myOutput`? It is not local.
we must specify iteration value in the lambda.
`[start..end]` next is `+1` or `-1` and value if the actual number.
`[start..(current:int)->${current+2, current+2}..end]`
output of the lambda is `${value, next}`. 
so:
`[start..(input)->${current, next}..end]`
`[iter0..(iter:Iteartor)->${read(iter), iter+1}..nothing]`
means:
1. create an empty array O.
2. set val = start
3. run lambda with val. name result current and next.
4. add current to O.
5. if next is same as end: finish
6. if not, val = next and goto 3.
what if we want to read a file and it is empty? The result array should be empty but here it will be at least an iterator.
loop is a repeated execution of if.
`while(x<10) { print(x), x++ }`
`x=10`, `x=[true: (x:int)->print(x), false: nothing](x>10)`
reading from file into an array:
```
file = fileOpen(...)
file_contents = [
  true: nothing,
  false: ()->{ getChar(file), 
](eof(file))
```
Nature of a loop is repeated execution of a block of a code. until when? until some condition is met.
But that code block is a lambda. So it cannot modify any of local variables. So either we need it for side effect (write to file) or it should return the value of the iteration. what about end condition?
The end condition is something which should rely on a changing variable. So that lambda should return the new value for that variable too.
Can't we implement this using recursion? It will be hard to read and we cannot capture a good output.
So, the iteration processing needs to return two things: result of this iteration and next iteration value.
Can't we just assume iterator to be auto-next by compiler after each round? Depending on the type of loop: Issue is we cannot have custom iterator but the iteration logic rarely changes.
Even if it does, we can use named types. `MyInt` and define `getNext(x: MyInt)`.
So the loop lambda only needs to return value of the current iteration. if it is same as end marker, loop is finished.
`[1..(x:int)->x..10]` ~ `[1,2,3,...,9]`
`[1..(x:int)->x..1]` ~ `[]`
read the whole file: `arr = [file_iter..(x: FileIterator)->[false: getChar(x), true: nothing](eof(x))]`
can't we have two lambdas: one to check end and other to get value?
`arr = [file_iter..(x: FileIterator)->[false: getChar(x), true: nothing](eof(x))..nothing]`
gnerally we need 3 lambdas: `getValue`, `moveForward`, `isFinished`.
`getValue` will get current iteartor and return the value for the current iteration round.
`moveForward` sill receive current iterator and return the next iterator
`isFinished` will receive current iterator and return true if we are finished with iteration.
Can't we model it as a struct?
`type Loop[T,U] := {start: T, getValue: func(T)->U, moveForward: func(T)->T, isFinished: func(T)->bool}`
How can we use this to create an array?
Can't we use the same thing for if? a tuple with two lambdas or values?
Ok. Let's do something else.
Use convention:
`isFinished` -> Loop is finished when getValue returns `nothing`. But what if we have a loop for it's side effect? (e.g. print the current value only). No problem. Just return a dummy 0. and return `nothing` when you are finished.
`start` is marker in `[start...`
`for(int x=0;x<100;x++)` `x++` is moveForward and the body of the loop is getValue.
So we have `[start..(current)->next]`
Read a file: `arr = [file_iter..(x: FileIterator)->[false: getChar(x), true: nothing](eof(x))]`
print 0 to 10: `[0..(x:int)->{print(x), [true: 0, false:nothing](x<=10)]`
map array to array+1: `new_array = [0..(x:int)->{[false: arr(x)+1, true: nothing](x<length(arr))}]`
this is a bit unreadable. for reading from file, we don't need end-checker as we have to check in getValue.
But for array+1 checking for length each time is a bit daunting.
read whole file: `arr = [file_iter..(x: FileIterator)->getChar(x)..(x: FileIterator)->eof(x)]`
Let's say the processing lambda has to return two things: iteration value and next iterator.
general format: `[initial_value..(current_value)->${output, next}..(current_value)->continue_check]`
print 0 to 10: `[0..(x:int)->{print(x), ${0, x+1}..(x:int)->{x<=10}]`
read whole file: `arr = [file_iter..(x: FileIterator)->${getChar(x), next(c)}..(x: FileIterator)->!eof(x)]`
map array to array+1: `new_array = [0..(idx:int)->${arr(idx),x+1}..(idx:int)->idx<=length(arr)]`
Why do we define loop based on an array? I think we should base it on `if` concept.
So it can be orthogonal and used either with an array or map.
We can implement if/conditional using map or array.
Let's just model it as if pseudo code: `if(X) then A else B`
`result = if(X) then A else B` we can model this using current methods.
we can say, repeat this until result of the expression is nothing. Then stop.
As the result of evaluation you can return one thing or more. So if you return two things they can be next iteration and current value.
print 0 to 10: `x=0`, repeat this: `x = if(x<=10) print(x) && evaluate to x+1 else nothing`
read whole file: `arr = REPEAT if ( eof(file_position) ) nothing else getChar(file_position) && evaluateo to next(file_position)`
map array to array+1: `new_array = REPEAT if (idx<=length(arr) ) ${arr(idx)+1, idx+1} else ${nothing, nothing}`
`result_array = REPEAT if ( condition ) value1 else value2`
continue until result of evaluation is `nothing`.
Let's use `:=` for repeat. But how can we repeat something without assignment? use `_`
`_ := ...`
`:=` means repeat right side and store result on the left side. so left side will be an array.
`result_array := expression` evaluate expression and store the result it in result_array until evaluation result is `nothing`.
But in order for expression to change, it must change one or more of existing variables in the current function.
So expression, may result in more than one output. First output is the one which is accumulated.
Iterate from 0 to 10 : `x=0`, `_,x := [true: ${x, x+1} , false: ${nothing, nothing}](x<=10)`
Here we print from 0 to 10. map that is used for if has key=true/false and value is a lambda which we call with x.
Result of that call is two values: first value is output and second is next value for x. 
`x=0`, `n,x := [true: (a:int)->{print(a), a+1}, false: (a:int)->${nothing, nothing}](x<=10)(x)`
**q: **What will be type of `n`? We don't know it's size in the general case.
What if we don't want to have an array in the output? What if we want a linked-list? 
print 0 to 10: `x=0`, `_,x := [true: (a:int)->{print(a), a+1}, false: (a:int)->${nothing, nothing}](x<=10)(x)`.
read whole file: `arr, fpos := [true: ${getChar(fpos), getNext(fpos)}, false: ${nothing, nothing}](!eof(fpos))`
map array to array+1: `new_array,idx = [true:${arr(idx)+1,idx+1}, false: ${nothing, nothing}](idx<=length(arr))`
or we can say, the variable which is of type array will be accumulated.
about linked-list, I think it is possible if we do it like print. Inside the lambda and not using output.
What if I want to read the whole file and store it's chars in a linked-list?
`list, fpos := [true: ${getChar(fpos), getNext(fpos)}, false: ${nothing, nothing}](!eof(fpos))`
we can use convention here: use `accumulate` function. we have a default implementation for arrays.
```
var list: LinkedList[char]
var file_pos = openFile(...)
while ( !eof(file_pos) ) {
  list.data = getChar(file_pos)
  list = list.next
  file_pos = next(file_pos)
}
```
how can we have a function which adds something to list?
```
func accumulate(storage: LinkedList[T], data: T)->LinkedList[T]
{
  var resut: LinkedList[T]
  result.head = data
  result.tail = storage
  return result
}
type Accumulator[S,T] := func(storage: S[T], data: T)->S[T]
```
obviously you cannot accumulate for int or float or char. Only for collections.
**so** the general syntax will be: `v1, v2, v3, ... := expression` where expression is supposed to return a tuple with appropriate number of elements assignable to left values. assignment will be done from v1 to vn.
it will continue evaluating expression until it outputs `nothing` for all of it's arguments.
Before then, output of the expression will be updated into `vi` lvalues. If they support accumulation, they will be applied else they will be overwritten.
So if `v1` is int and `v2` is array and `v3` is set, this will overwrite value of v1 but add the value for v2 and v3.
even `nothing` can be applied to lvalues unless everything is `nothing`.
**print 0 to 10**: `var _,x=0 := [true: (a:int)->{print(a), a+1}, false: (a:int)->${nothing, nothing}](x<=10)(x)`.
**read whole file**: `arr, fpos := [true: ${getChar(fpos), getNext(fpos)}, false: ${nothing, nothing}](!eof(fpos))`
**map array to array+1**: `new_array,idx = [true:${arr(idx)+1,idx+1}, false: ${nothing, nothing}](idx<=length(arr))`
What if we can run some code after each assignment?
read whole file into a linked-list.
So there is no need for convention and accumulate function.
Can we have an array on the left-side? Let's also return index:
**print 0 to 10**: 
`var x=0 := [true: (a:int)->{print(a), a+1}, false: (a:int)->nothing](x<=10)(x)`.
**read whole file into a linked-list**: 
`list.data, list, fpos := [true: ${getChar(fpos), list.next, getNext(fpos)}, false: ${nothing, nothing, nothing}](!eof(fpos))`
**read file into array of chars**:
`arr[index], index, fpos := [true: ${getChar(fpos), index+1, getNext(fpos)}, false: ${nothing, nothing, nothing}](!eof(fpos))`
**map array to array+1**: 
`new_array[idx],idx := [true:${arr(idx)+1,idx+1}, false: ${nothing, nothing}](idx<=length(arr))`

Y - We are using a map with true and false a lot. Can we simplify it?
Or maybe use array? true=1, false=0

Y - reading from array `arr(0)` is fine even if we send it to another function.
but writing `arr(0,1)` is not. can we make it more explicit?
maybe by using a function? or `=`?
`var t = arr(0)`
`arr([0:10, 1:20])`
`var y = mymap("A")`
`myMap(["A":1, "B": 2])`
we use map to update an array or map. key is index or map key.
value is array or map value.
what if key of the map is a map itself?
`myMap(["A":1])` does this read from map or write to it?
can't we write: `arr(0) = 10`
`myMap("A") = 100`
what is result of this expression? rvalue.
it is more readable.

N - How can I force `set` data structure uniqueness requirement?
`type Set[T] := LinkedList[T]`
Just add appropriate functions as gateways:
`func add(s: Set[T], x: T)` which will check for correctness of the set.

? - cant user write this?
```
struct1
.
field1
```?
won't it be confusing with chain operator?
No. user is not support to do that and that will be a syntax error.
but relying on whitespace around dot is like Python relying on indentation.
Can we replace it with another symbol which is also easy to type?
It should be single keypress, single char and easy to read and type.
`~`
`,`
`str ~ contains(_, ":")`


! - Maybe we can use a set of rules or regex to convert code to LLVM IR.
or a set of macros. 
these can indicate micro-commands to be executed by the compiler so we will be coding our compiler into that notation.
Compiler just needs to scan the source code, apply macros and run microcommands.
This will be a very special macro language which is designed for this compiler and this language.
Won't it be same as writing C code? If it can be more maintainable maybe we can use it as an intermediate IR between dotlang code and LLVM IR.

! - We should have a modular design for compiler.
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

! - example
```
let a : Point = Point{100, 200}
...
let u = a.x - make u point to address of a + offset but if it is an int, just make a copy
```
for `let` make a copy for int, char, float and create a pointer for all other cases.
union will be rendered as `tag + buffer`. if all cases are primitives or label types, it will be marked as value type (copy on assignment), else, it will be a pointer.

! - implementation
- we should keep an integer for each type to be for `@` operator
- q: can we have overloaded functions in llvm ir?
- q: can I really inline llvm ir functions?
- determine in which case can I make a binding mutable?


! - Allow overloading based on return type and give error if assignments like `x=func1()` are ambiguous.
We already have this by `autoBind` function.
So either you have to write: `x: Type1 = func1(1,2,3)` or if it is generic with generic output argument: `x = func1[Type1](1, 2, 3)`
