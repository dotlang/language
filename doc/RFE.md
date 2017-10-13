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

Y - cant user write this?
```
struct1
.
field1
```
?
won't it be confusing with chain operator?
No. user is not support to do that and that will be a syntax error.
but relying on whitespace around dot is like Python relying on indentation.
Can we replace it with another symbol which is also easy to type?
It should be single keypress, single char and easy to read and type.
`~`
`,`
`str ~ contains(_, ":")`
`0 ~ arr = 10`
but `~` does not imply chaining. `>>` is better but it's two characters.
`>>` and we use `>` in function and comparison so it will be unreadable.
`x>0>>arr`
`""`
`|`
`f(x)`, `f(g(x,1))`
`(x)f`, `((x)f(_), 1)g(_,_)`
`x . f(_)`, `x . f(_) . g(_,1)`
`x ~ f(_)`, `x ~ f(_) ~ g(_,1)`

1. `{x,y,z} ~ {_,_,_}` => `{x,y,z}`
2. `g = (5,9)add(_, _)` => `g = add(5,9)`
3. `(1,2)processTwoData(_, _)` => `processTwoData(1,2)`
4. `({1,2})processStruct(_)` => `processStruct({1,2})`
5. `(6)addTo(1, _)` => `addTo(1, 6)`
6. `result = {input, check1(5, _)} . pipe(_,_) . {_, check3(1,2,_)} . pipe(_, _) . {_, check5(8,_,1) } . pipe(_,_)`
7. `func pipe[T, O](input: Maybe[T], handler: func(T)->Maybe[O])->Maybe[O] ...`
8. `{1,2} . {_, _, 5} . process(_,_,_)` => `process(1,2,5)`.
9. `func inc(x:int) -> x+1`, `var eleven = 10 . inc`
10. `func add(x:int, y:int) -> x+y`, `${10, 20} . add`

Y - Can we have some kind of assertions for function and data?
minimal and simple?
for data, it will have a performance cost. and it won't be flexible. what if I just want to return exception insted of exit?
The best choice for functions is `assert` as a mechanism to return exception.
To exit, we don't need any special code. just `if`: `[()->{exit(1), ()->{}](isSafe)`
but assert can cause the block to evaluate to a specific expression if a condition is satisfied:
`if(!success) return expression`
this can be done for early return cases.
`assert success, expression` means `[expression, nothing](success)` but forces block to be evaluated to the expression. 
This can apply to any code block.
`x={assert success, 10 .... 20}`
you can use assert to early-terminate a code block.
Can we choose a better name?
`check`
`ret` and `return` will be misleading
`ensure`
`assert` is better. but it is not meaningful here. 

Y - Make assignment a statement so people cannot mis-use side-effects and combine them.

N - Repeated assignment might be difficult to read especially when we have multiple variables.
`v1, v2, v3, v4 = ...`
```
var x=0 := [
  (a:int)->nothing, 
  (a:int)->{print(a), a+1}
](x<=10)(x)
```
```
var x=0 := x ~ x<=10 ~ [
  (a:int)->nothing, 
  (a:int)->{print(a), a+1}
]
```

N - How can we apply assert to data?
Examples: datetime.month<13, ...
simply define a validation function. and write: `assert isValid(x), exception`

Y - Doesn't reading from map and array return two values? data and found? Doesn't this affect conditionals and loops?
How can I chain result of reading from array or map?
Maybe you are not supposed to do that.
For array we can say return data or runtime error if index out of bounds.
But for map, user really needs to capture both outputs.
If map's value is a function and I want to call function immediately affter reading from map:
`myMap(100)("A", "B", "C")`?
`var f,_ = myMap(100)`, `f("A", "B", "C")`?
what about this?
`var x=0 := [true: (a:int)->{print(a), a+1}, false: (a:int)->nothing](x<=10)(x)`.
`var x=0 := { var f, _ = [true: (a:int)->{print(a), a+1}, false: (a:int)->nothing](x<=10), f(x) }`.
For array, we can say runtime error will be thrown.
Can't we keep this for array too? because this is consistent with the philosophy of the language.
`var x=0 := [true: (a:int)->{print(a), a+1}, false: (a:int)->nothing](x<=10).0(x)`.

Y - `assert` is not very descriptive.
The purpose is: Make sure this condition holds, or else the whole block should be terminated and be evaluated as this value: ...
`retif` ? remember that we are not bound by other languages.
`evalif`
`throw`
`ensure` - this implies the first part (make sure condition holds), but not the second part (return).
I don't want to make it two keywords. Because it will add to the complexity. 
The purpose of adding this is to make defensive programming and requirement enforcement more straight forward.
`expression if condition`? this is not very readable. I need something at the beginning.
`if condition, expression`
`[false_ret, nothing](condition)`
Generally it is better to document expected condition rather that unexpected. So the command should be something like 'ensure this condition holds or else return this value'
so `retif` does not make sense.
`guard`?
`guard month<12, 100`
`retifnot month<12, 100`
`100 unless month<12`
`unless month<12`
it is better to check for unwanted cases rather than wanted cases. because we are going to return some value and it may depend on the wrong data. so if input is <0 return `err("must be positive")` and if it is `>100` return `err("too big")`.
so the correct semantic should be: `if this is true, evaluate immediately and exit the block`
`exitif condition, expression`
`retif condition, expression`
`guard condition, expression`
guard does not make it explicit that we will return.
this is overlapping with conditionals if. can we merge them?
`return 0 if x<0`
`retif x<0, 0`
`return [true: 0, false: nothing](x<0).1`? this will mean that we return `int|nothing`. which can change semantic of function.
`return [true: 0](x<0)` -> `return an_int, found_bool`
if found_bool is true, return will be executed. if false, it won't. but we can just write the conditions manually:
`return 0, x<0` without using map or array.
`assert 0, x<0`
we can check both ways: wanted or unwanted cases. checking for wanted cases makes code more readable?
`return err("must be positive") if x<=0`
`return err("too big") if x>100`
vs:
`return err("must be positive") if !(x>0)`
`return err(too big") if !(x<100)`
semantically both are the same but the first type of checks are more readable because you don't need to add `!` for conditions.
So let's check for unwanted case. 
`retif bad_condition, return_value`
`value ::cond` evaluate this block to value if cond holds.
if cond holds, make this line the last line of the block.
`1 ::missing_data`
`err("must be positive") ::{x<0}`
`err(too big data") ::{x>100}`
because using a keyword make it difficult. it should contain multiple concepts:
1. exit the current block immediately
2. if this condition holds
3. return/evaluate to this value
what if we are inside a block and want to exit the function?
this should be the main purpose of the operator. because inside a block, simply check for condition??
i think "exit block" semantic is more powerful than "exit function". You can put the statements outside the blocks and make function return.
If it is inside the block, you can check for block exit and return from function immediately if it is error.
but if this is valid in block-level, doesn't it replace if?
`x=[100,200](success).0`
`x={100::success, 200::!success}`
There should not be more than one way to do something.
otoh if we make it exit from current function, it might make reading code more difficult.
maybe we should change the semantics: stop further processing if this condition holds.
```
result = nothing
result = [err("must be positive), nothing](x>0).0
result = [err("too big"), nothing](x>100).0
result ::{result != nothing}
```
what if we make the condition checking a code-block?
```
result = { [err("ERROR"), nothing](x<100 and x>0).0 }
::result
```
we can say `::x` means evaluate current block to x if it is not nothing. 
you can explicitly evaluate to nothing by writing `nothing` as the last statement.
but what if I want to return nothing?
what about putting these conditions outside function block?
```
func process(x:int) -> int|error ::{x>0}, error("too big)
{
  ...
}
```
NO. it makes code complicated. you have to read different parts.
I think in any case, this feature can be misused to simulate if instead of checking for errors.
so either: 1. let misuse happen, or 2. make it so explicit that misuse is almost impossible.
for example checking for conditions outside function is an example of 2.
```
func process(x:int, y:int) -> int|error 
::{x<0}, error("must be positive")::
::{x>100}, error("too big")::
::{x>y}, error("wrong order")::
{
  ...
}
```
problem: more advanced cases like if result of pre-processing failed, return this, is not possible.
a compromise: return if x is not nothing. returning nothing is still possible but must be done explicitly.
```
func process(x:int, y:int) -> int|error 
{
  var result = [nothing, err("must be positive")](x<0).0
  ::result
  result,_ = [nothing, err("too big")](x>100)
  ::result
  ...
  x+y
}
```
This definitely makes code a bit more complex and language more complicated. But it will be more expressive. 
Because otherwise, we will need to check for error for the rest of the function or put the rest of the function in a very big lambda.
How can we write above code without `::`?
```
func process(x:int, y:int) -> int|error 
{
  var valid1 = x<0
  var valid2 = valid1 and x<100
  var result = [err("general error"), x+y](valid2)
  result
}
```
Above code needs to calculate `x+y` even if we have an invalid input. 
```
func process(x:int, y:int) -> int|error 
{
  var valid1 = x<0
  var valid2 = valid1 and x<100
  var result = [()->err("general error"), ()->x+y](valid2)()
  result
}
```
Above code does not calculate `x+y` in case of an error, but for a medium to large function, this will be difficult and the error message is not specific.
```
func process(x:int, y:int) -> int|error 
{
  var result = [err("must be positive), nothing](x<0)
  result = [err("too big"), nothing](x<100)
  result = [code_block, result](result != nothing)
  
  result
}
```
Another solution is to add a `=` that only works if left side is nothing.
If left side is nothing, it won't execute and won't evaluate right value.
`x <= 5` means put 5 into x if it is `nothing`. 
This can be called "soft assignment" which means only assigng if lvalue is not nothing.
but this will affect the whole type system. what if function output does not accept nothing?
suppose that function output is `T|error`. I declare result as `T|error|nothing`.
check pre-conditions. If they are failed, set result to an error. else set result to nothing.
Put the reset of the function in a block of code and assign it to result. If result is already an error, the block won't be evaluated.
```
func process(x:int, y:int) -> int|error 
{
  var result = [err("must be positive), nothing](x<0)
  result = [err("too big"), nothing](x<100)
  //if result is nothing, evaluate right value and assign to result
  //if result is not nothing, skip this block.
  result << { x+y }
  //same as above but with lambda which is more limited in terms of access
  result = [true: ()->{ x+y }, false: result](result == nothing)
  //other way:
  result = { x+y } if ( result != nothing )
  //and does short-circuit. if result is nothing, it will evaluate the block.
  //if result is not nothing, it will short curcuit and skip the block.\
  //but we are re-inventing if/else with a more confusing notation.
  //array and map access notation is intuitive and familiar. But this type of usage for
  //and/or is not and it also gives developer two ways to do the same things.
  result = ( result == nothing ) and { x+y } or result
  
  result
}
```
con: a new indentation level
pro: we still have only one exit point
pro: we still can return nothing here. but in `::` we cannot use it to return nothing.
con: make code complicated because result is `err|int|nothing` but function output is `int|erro`.
Compiler can handle this because using `<=` makes sure result won't remain `nothing` (unless the block evaluates to nothing).
solution 1: add `::`
solution 2: add `<=` (or `=?`, or `<<`).
so we have two bad things: more indentation, more exit point. 
Which bad things do you want to choose?
If we go with `::` we can force the developer to explicitly state the block evaluation result with `::` as the last statement in the block. But `::` has a conditional nature. return if this is no nothing.
What if we really want to return `nothing`?
I think its a good idea to make return explicit but adding two separate notations for early return and final return is too much.
Maybe we can merge these two.
solution 1: convention, if `::` is the last statement in the block, it will return unconditioanlly. if it is in the middle, it will only return if the argument is not nothing. compiler can check to make sure each block of code ends with `::`.
`{x+y}` vs `{ :: x+y }`.
`func add(x:int, y:int) -> :: x+y` 
`:: expression` put a space between these two, so complex expressions are more readable.
```
var result,_ = [nothing, err("must be positive")](x<0)
:: result
```
vs
`:: [nothing, err("must be positive")](x<0)`
con: two different meanings for the same symbol.
con: what if I want to return nothing in the middle of the function?
`:: err("must be positive"), x<0`
`:: final_result`
`x = { :: 1, x>0, :: 2}` this is overlapping with if.
Let's say, if user wants to return nothing, he has to write code accordingly.
The features that the language provides are for non-nothing (something), return value:
`:: 10` what does this do if it is in the middle of the code?
`10}` no. confusing.
to remove the overlap, make `::` independent of if. use nothing criteria.
`:: [nothing, err("must be positive")](x<0)` evaluate to the expression if it is not nothing.
But in many cases, we return `myabe[t]` so for error cases, we may want to return `nothing`.
con: two different meanings for the same symbol.
con: what if I want to return nothing in the middle of the function?
what about making use of missing values in if?
`:: [err("too big")](x<100)`
if `x<100` expression will evaluate to true which returns `${invalid, false}`. no exit.
if `x>100` expression will evaluate to false, which returns `${err("too big"), true}`. exit.
so we can say, `::` accepts a tuple of A,B where if B is true, it will return else will continue.
we can write: `:: ${err("too big"), true}` to force exit.
`:: ${exp, bool}` conditional exit. if bool is false, exit with exp value.
`:: exp` immediate exit
`t = { :: ${1, x>0}, :: 0}`. still we can simulate if/else with `::` in a block.
But what if `::` wants to return a real tuple? containing a value and a boolean?
we get back to step 0:
`:: exp, condition`
`:: exp`
and force block end with `:: exp`.
Can we embed it inside if? but explicit return is a good thing.
we agree to have multiple exit points.
**there must be at most one unconditional exit point at the end of the block (if none, compiler assumes nothing output) and multiple conditional exit points.**
`:: value` exit unconditionally and must be last statement.
`[false: :: nothing](isFine(x))`
using `return` is not good because we want to concept to be applicable to code blocks too.
what if we agree to use a prefix before `::`?
`x>0 :: nothing`
can I use this notation for other cases? `x>0 g=10`? 
Adding complexity.
what if I declare a special variable for block result (e.g. `%`). assign whatever value I want to it.
So problem of nothing will be solved. then I can say `::` exits immediately if condition is satisfied.
`:: x>0`
`::`
We have two new notations: `::` and `%`. Too many notations. Can't we just re-use existing notations?
`:: 100`
`:: `
can't we do this with chaining?
if function output is `int|err`:
`:: validate_data(x,y,z) ~ process1`
if `validate_data` returns err and process only accepts int, chain will not proceed and return value is the output of validate_data. but if validate returns something which is expected by process1 chain will proceed.
pro:

Y - add `::` as explicit return specified.
**there must be at most one unconditional exit point at the end of the block (if none, compiler assumes nothing output) and multiple conditional exit points.**

Y - Add `return` statement, remove `$` for tuple literals.
change chain operator behavior: return x if f cannot accept x type

Y - How can we make it easier to check for invalid data?
We don't want to make a big complex expression for return.
```
func add(x:int, y:int)->int
{
  return x+y
}
```
```
func add(x:int, y:int)->int|error
:: x>100 -> err("too big")
:: x<0 -> err("most be positive")
{
  return x+y
}
```
can we use a normal if statement and indicate in the else clause that the rest should be processed?
```
func add(x:int, y:int)->int|error
:: [true: err("too big"), false: continue](x>100)
:: x<0 -> err("most be positive")
{
  return x+y
}
```
or have a symbol which indicates result of evaluating "rest" of the function.
```
func add(x:int, y:int)->int|error
:: [true: err("too big"), false: continue](x>100)
:: x<0 -> err("most be positive")
{
  return [true: erro("too big"), false: %%^](x>100)
  return [true: erro("must be positive"), false: %%^](x<0)
  
  return x+y
}
```
limitation:this should only be used in return where we are sure we won't be continuing.
pro: removes problem of lots of indentation or nested lambdas
pro: readable
pro: useful for pre-req
pro: can return nothing.
con: not very orth.
```
func add(x:int, y:int)->int|error
{
  var t = 12
  return [true: erro("too big"), false: $](x>100)
  return [true: erro("must be positive"), false: $](x<0)
  
  return x+y+t
}
```
can we think of `$` as evaluation result of main body of the function and move these outside block?
```
func add(x:int, y:int)->int|error
{
  var t = 12
  return [true: erro("too big"), false: $](x>100).0()
  return [true: erro("must be positive"), false: $](x<0).0()
  
  return x+y+t
}
```
q: can I combine `$` with other things? e.g. `$+10`?
`$` symbol can only be used outside main block. It refers to evaluation result of the main block as a lambda which does not have any input. `()->T`. `$` represents the main function.
basicall `$` means ignore and continue but in the language we cannot have such a concept. So we interpret it as a lambda with no input and output of the function.
1. You can use `$` symbol in the expression used for return statement.
2. `$` represents a lambda with no input and output is equal to evaluation of the rest of the function.
but problem is about treating rest of the function as a lambda. By definition, lambda has read only access to outer variables. But we can have variables defined before return and should be able to update then in the function body.
what about a convention:
`return $` means do not do anything. `$` can be considered as a special symbol which is not returnable. So `return $` does not return anything and goes to the next statmement.
We can replace `$` with nothing, but then it will be a bit confusing. Because nothing is perfectly valid as output of a function.
```
func add(x:int, y:int)->int|error
{
  var t = 12
  return [$, erro("too big")](x>100).0
  return [$, erro("must be positive")](x<0).0
  
  return x+y+t
}
```
Still not very normal. Using a very special notation that returning it does not do anything! not very normal.
```
func add(x:int, y:int)->int|error
{
  var t = 12

  result1 = [nothing, erro("too big")](x>100).0
  result2 = [nothing, erro("must be positive")](x<0).0
  
  return [()->result1, ()->result2, ()->x+y+t]()
  
  return x+y+t
}
```
what about return nothing to be ignored but return a lambda which returns nothing to work?
```
func add(x:int, y:int)->int|error
{
  var t = 12
  return [nothing, erro("too big")](x>100).0
  return [nothing, erro("must be positive")](x<0).0
  
  return x+y+t
}
```
another solution: return is ignored if it's argument does not match with function output. No. We encourage writing incorrect code!
another solution: chain!!!
`return x<0 ~ [true: ()->err("A"), false: ()->nothing](_).0() ~ (_: nothing) -> { rest of the function}`
**proposal:** enable using `_` for function argument name if we dont use it.
we don't need to introduce a shortcut like `{...}` for a lambda without input. because it will make language more complex without much usefullness.
**applicatios of `_`**: ignore function input or output, create lambda in-place. `f(x,_,_,1)` creates a lambda with two inputs.

Y - What if I want to call function output after chain?
`x ~ f.p` f output is a struct which has `p` field. this is not readable!
either ban it altogether or state `f` must be in single form without attached symbols (more exceptions).
what was the purpose of this rule? Just to make code shorter?
shouldn't we state that ANY type of function call must have `()`? `1 ~ f` does not have this.

Y - Can't we get rid of all `.0` in array and map readings?
Just throw runtime error if index is wrong for array.
Referencing an array with invalid index is really exceptional error.
Can't we have both of them? no.

N - Even the notes in the lang spec can be some kind of complexity and harm orth and gen. 
We need some of them anyway but those who have higher cost (complexity, not orth, not gen) and little benefit should be eliminated. 
?e.g. 16. You can combine multiple expressions on the same line using comma as separator.

Y - The syntax to update array or map is not very intuitive.
`arr(0, 10)`
`my_map("A", 2)`
solution 1: use a function. But functions are not supposed to change their input: `set(arr, 0, 10)`. And the syntax is not very intuitive.
solution 2: normal `=`: Like assigning a variable, `my_map("A") = 2`.
How does this work with chaining an 2d array?
`myArray(0,0)= 100`
`{0,0} ~ myArray = 100`
Can we replace `myArray(0)` with a function?
`process(myArray) = 100`
`func process(x: array[int]) return x(0)`
I think this will make things more complicated in runtime and compiler implementation.
`myMap += {key, value}`?
`myArray += {index, value}`?
`myArray2d += {index1, index2, value}`?
and `-=` to remove from map? Because still we cannot use a function to modify the map.
What about write to array using reading + set?
`myArray = [myArray(0..5), 100, myArray(6, 100)]`
`myArray = [myArray(0..5), 100, myArray(6, 100)]`
How should we be updating arrays?
Without having any special behavior for array.
`myArray(0) = 0`
What about using `[]` and `=` notation for array and map.
For conditionals we can just allow `~` for `[]` too.
`0 ~ arr[_] = 100`

N - `x ~ y ~ f(_)` is it `f(y)(x)` or `f(y(x))`?
Each variable must correspond to one `_`.


Y - What happens if a function gets an array and returns the same array and we send X to func and change it's output.
```
func process(x: array[int]) -> x
var t = [1,2,3]
y = process(t)
y(0) = 100
//does this change t?
```
Remember that `=` is copy operator.
or: `process(t)[0] = 100`?
If behavior of `process(t)[0] = 100` is not the same as `x=process(t), x[0] = 100` then it will be really hard to read.
what if process returns an int? 
It is not enough to say that function cannot modify it's arguments. What if the function returns one of it's argument (directly on indirectly)? e.g. returns an array of structs, which contains it's input. Or a map which has key or value of it's input.
```
var t: array[Point] = [p1, p2, p3]
var t2: array[Point]
t2[0] = p1
```
does t contain original points? 
Does t2 contain a copy of `p1`?
the rule of least surprise states that `t=[p1,p2,p3]` will mean `t[0]`should return p1.
solution 1: adding `ptr[T]` type. NO! it will affect every single thing.
solution 2: everything reference.
solution 3: everything data.
solution 4: primitive are by value, others by reference.
Should this affect `p1.x`? `var t: array[Point] = [p1, p2, p3], t[0].x = 100`
similar to putting something inside a map.
`func process(x:int) -> x`, `t=process(p)`, `t=100` should this affect p?
The general rule is calling a function should not have a hidden effect that is not visible in the call site.
`x=f(y,z,t)` x should be independent of other 3 arguments. So any change to x should not affect y,z or t. If it does, it will make code not readable.
but what about `t=[p1, p2, p3]`? We cannot say this generally.
pointer data type: More complicated but no exception and general.
rule-based: Less complicated but we will have exceptions.
What is the best solution? Remmeber our top goal: Simplicity.
Let's write some cases and examples:
1. `t=returnSame(p)`, `t++`. Does this affect `p`?
2. `t=[pt1, pt2, pt3]`, `t[0].x = 100`, does this affect `pt1`?
3. `t=returnArray(pt1, pt2, pt3)`, `t[0].x=100` does this affect `pt1`?
We can have array of point vs. array of point pointer. `array[Point]`, `array[Point*]`?
This will definitely make code less readable. I don't know whether `WindowHabdle` is a pointer or not. User can make it pointer with a named type. It won't be understandable by reading the code.
If we say, caller will receive a deep-copy of result of a function, it can be expensive.
What about this: Caller cannot modify result of a function call in any way. If it wants, it can make a copy.
This will solve problem 1 and 3.
Doesn't this rule conflict with `:=` and loop imeplementation?
If we make everything immutable this problem will be solved but then we cannot have loops.
`x := [true:x+1, false: nothing](x<10)`
Here we only need the final results (The round just before returning `nothing`).
Also if we make everything immutable, then we will be back to the old problem: How to modify array, map, tuple, .... 
So: Variables are mutable except function input and outputs.
We can change the responsibility to a function: Result of a function should be created using mutable variables. So a map with one of inputs is not valid. But this is really hard to enforce.
`t=[pt1, pt2, pt3]`, `t[0].x = 100`
`map1=["A": pt1, "B":pt2]`, `map1["A"].x = 400`
`var t = map1["A"]`, `t.x = 900` does this change the map?
It should. But then again, `=` is not copying now!
`var t = map1["A"]` makes a reference copy of the data inside the map. So `=` is not making a duplicate.
`map1["A"].x=200`.
If map had int, then `=` would create copies. 
This is a different behavior for different data which is against simplicity.
What we are looking for is "Simplicity" which means less rules and less exceptions.
We say `=` makes a copy EXCEPT when it is a tuple or a union or array or map. 
What if we say `=` does reference assignment ALWAYS.
Then `arr1 = [pt1, pt2, pt3]`, `arr2 = arr1`, `arr2[0].x=101` will update `pt1`.
Then what about int?
`x=100`, `y=x`, `y=19` this will update x too.
Let's say, `=` makes a ref assignment. `y=x` will make y point to the same data as x.
`y=x+0` will make y point to a copy of x. but this is weird.
**1-** `=` makes a copy of rvalue to lvalue if type of rvalue is `int`, `float` or `char`. For other types (struct, union, array, map, string, bool, nothing) it will assign lvalue as a reference to rvalue.
**2-**: You can use `clone` core function to duplicate something.
Can we easily enforce the rule of not modifying function output?
What if I put it inside a map and query the map using a runtime value?
`var pt = process()`, `myMap["A"] = pt`, `myMap[readInput()].x = 101`.
`pt=returnSame(original)`, `pt.x=10`, doesthis affect original?
We can have the same problem inside the function. What if function stores a lot of data inside map and query using a runtime value and modify it?!!!!!!!!!!!!!!
That's why they say everything immutable.
What's the barrier to make everything immutable?
Loops.
What will be affected? syntax to update array, map, tuple. closure capture.
There are two solutions to this: 1. make everything immutable. 2. make things selectively mutable (pointer data type).
I prefer 1 because it is safer.
WHY DO WE NEED FULL IMMUTABILITY? We cannot check function does not mutate it's inputs. Also if function returns a result which includes an input inside it, updating that result will have hidden effects and we also cannot enforce function output to be read-only.
How can we implement loops with single-assignment?
`var v1, v2, v3 := {f1(v1,v2,v3), f2(v1,v2,v3), f3(v1,v2,v3)}`
Internally, this is a recusrive function call which ends if input is nothing.
`x := [true: ()->{print(x), return x+1}, false: ()->nothing][x<100]()`
`var f = (x:int) -> { print(x), return [nothing, x+1](x<100) }`
`f` will return int or nothing.
`0 ~ f` means `f(0)` which will return 1. 
`f(f(0))` will return 2.
`f(f(f(0)))` will return 3.
`var x = 0`
`var final = (x  ~~ f)` means feed `0` into `f` and after getting the result, feed it again into `f`. And repeat until it cannot be fed into `f` (it is `nothing`).
But if we make everything immutable, we cannot have things like what we do for repeated assignment.
**What are problems we want to solve:**
1. We cannot enforce a function does not modify it's inputs and can modify it's local variables. If it can modify, it can modify everything.
2. If a function returns a data which includes all or part of it's input, we can modify the output and result will be an indirect change and side effect which is hidden when reading the code. Also similar to 1, we cannot enforce function output to remain read-only.
The solution to these problems is to make everything immutable.
Now problem is: How to handle loops?
`while(predicate, body)`
q: read whole file into a linked list of characters.
`while((f: iterator)->!eof(f), (list: LinkedList, f: Iteartor) -> { return LinkedList{head=readChar(f), tail: list} }`
whole file into a char array?
`arr = while((f:Iteartor)->!eof(f), ...`
`func while(...f: func()->T)->T[]`
We can implement loops as functions in core.
Everything becomes immutable and single assigned.
Closure can capture vars outside but as read-only.
Shall we change `var`?
How to modify array? You cannot. You cannot modify a map also.
Tuple: Clone.
Then maybe we can use `()` notation to read from map and array.
1. Change `var` to `let`
2. Everything is immutable (local vars, function input, output, captured vars, ...)
3. Loops are done as core functions.
4. No `:=`
5. `=` is only usable with `let`.
6. You cannot update array or map or tuple in-place.
7. You can run a loop and it's output will be a map or array.
What made us to have re-assignability in the first place?
Line 4141 of RFE.4: "The fact that I cannot modify/edit a local variable is a bit of a[s]tonishment.".

N - So:
`let arr = [pt1, pt2, pt3]`
this contains references? yes.

Y - Now that we no longer have loop with `:=` shall we return `if/else` keywords?
Early returns is really needed and without if, it will make things less readable.
`return A if B`
then?
`if x>0 then return 100`
`let h = if x>0 then 1 else 2`
Especially with immutability, we need to have more powerful mechanism to write assignment expressions.
`x>0 ~ [()..`
Then what about switch? We will need a switch statement for type matching and ... . 
It will become super confusing.
OTOH missing early return will also make things confusing.
can't we add `retif` keyword?
`retif 100, x>0`
or assert:
`assert x>0, error("x must be positive")`

N - and as if
`x = (x<0) and exit(1)` ~ `if(x<0) exit(1)`
`x = (x<0) or exit(1)` ~ `ifnot(x<0) exit(1)`
or:
`x = (x<0) and bool{exit(1)}`
`x = (x<0) or bool{exit(1)}`
or:
`x = (x<0) and bool{let tmp=process(1)}`
`x = (x<0) or bool{let tmp=process(1)}`

Y - map should return zero-value for missing key
`x=[()->0, ()->process(1)](x<0)`
don't read output, just execute. if not missing.
`[false:()->exit(1)](x<0).0()`
if `x<0` we don't want to execute anything. just the case that `x>0` is important for us.
Can we say, if map element is missing, it will return a default value + false flag?
Then we can safely run the default value which is expected to be harmless.
so if we have `map[string, int]` reading a missing key, will give us `{0, false}` where 0 is default value for value.
Similarly if value is a function, a lambda with return of default value will be given to us + a false flag.
zero value: The default value for a type.
`x=[()->process(1)](x<0).0()`
`x=[false:()->process(1)](x<0).0()`
Why array should not have this?
One application of not having this: throw runtime errors. But this is not the correct way to throw runtime error (using missing array index). because the error message will be confusing.

Y - array should return zero-value for missing index (value+flat).
Why array should not have this?
One application of not having this: throw runtime errors. But this is not the correct way to throw runtime error (using missing array index). because the error message will be confusing.

Y - Now that everything is immutable, we can think of functions as immutable lambda bindings!
`let process: func(x:int)->int = { ... }`
yes it is possible but just makes syntax more confusing and less readable.
What can be application of this?
If we allow this, we should also allow other types here. `let PI:float = 3.1415`
`let process: func(x:int)->int = { ... }`
`func process(x:int)->int { ... }`
pro: it will make things simpler. we don't have function and lambda. we only have lambda.
con: Reading code may become more difficult.
`let process = (x:int) -> x ~ print(_)`
What happens to closure then?
pro: we will allow nested functions without changing anything in the language.
there will be no declaration. only assignment/binding.
q: what happens to method resolution? 
`let f: func(int|string)->int = process`. There must be a func named process with exact same definition.
If we have two functions for int and string, it cannot be used.
Maybe we can use `:=` for let too. Similar to type. because it is not supposed to be changed.
Then we use `=` for conditional.
`let x := 100`
`:=` also implies that the binding is immutable. 
`let` defines data, `type` defines type or blueprint to create data.
This may enable us to import a module with prefix.
`let mod1 := import("...")`
`mod1.process` will be a lambda pointing to the function inside module.
so `import` function will return a struct with appropriate field names pointing to functions.
`let _ := import("core/st")` will import functions without being inside a struct.
then we can remove `import` keyword!
modules will be `let` + `type` to define data and types. 
pro: `func` will not be a magical keyword. It will be just like `int`. A normal type of a variable.
maybe we can use `import` instead of `autoBind` too!
1. define functions using `let`.
2. `=` will be used for comparison, `:=` for let.
3. modules will contains let and types.
`let process: func(int)->int := (x:int)->int { ... }`
`let process := (x:int)->int { ... }`

Y - import as a function, `module` primitive type.
q: what if import is used with a variable?
solution1: disallow using `import` inside functions. Only at module-level.
`let module = import(...)` type of module is a struct with fields determined by the compiler based on contents of the module imported.
`let module: MyStruct = import[MyStruct]()` type of module is specified here. `import` function will return `MyStruct` with appropriate function pointers to available functions.
`import` will import both functions and types. Types cannot be part of a struct. 
`let mod1 := import("...")`
what happens to the types defined inside the module?
Can we have types inside a struct? If so, we can think of a module as a big struct.
`type s := { x:int, y:int, z:int, f: func(...), tt: ???}`
Let's not think about module as a struct.
So how can I import a module with prefix? To avoid name clash?
`let prefix := import("..")`
Maybe we can use a notation different from dot. A new type: Module.
`let prefix: Module1 := import...`
`let _ := import...`
let the user call import with a variable. we will handle this in implementation.
autoBind?
`let myFuncs : AdderFunctions := import[AdderFunctions]()` import without input will look in currently available functions at compile time and return a struct with appropriate function pointers.
Or why not use autoBind itself? pro: Simplify and unify.
so:
1. import function in core accepts a string and loads the symbols inside that module as a module binding.
2. import without input, will be called like autoBind.
3. `func` becomes a primitive data type.
What prevents us from treating `module` like a `struct`? The fact that we cannot have a type defined inside a struct.
`type MyStruct := { x:int, y: int, `.
`struct` is a blueprint for data. Not definitions.
we can have a `Module` primitive type which is defined by creating a new file and importing it.
You can use `_` to capture output of import as normal available symbols.
Or name it's output. If you name, you can use `moduleName#name` to access functions and types inside the module. 
`let x: myModule#myType = ...`
`let p = myModule#myFunc(10, 20, 30)`
`/`?
`let x: myModule/myType = ...`
`let p = myModule/myFunc(10, 20, 30)`
we can use `/` as a separator.
we can use the same notation to import a single function or type:
`let y := import("/core/st/Socket/createSocket")`
`let y := import("/core/st/Socket/SocketType")`
Maybe we can even replace import with a symbol. So `/` will be really part of identifier not inside a string.
```
let y := /core/st/Socket/createSocket
type y := /core/st/Socket/SocketType
let mod1 := /core/st/Socket
type socketType := mod1/SocketType
let process := mod1/createSocket
```
Maybe `/` is good for path separate which has a physical corresponding element in the file-system.
But we should use a different notation for things that are "inside" the module.
```
let _ := /code/st/Socket` //all types and functions inside core-st-socket are available normally without prefix
let mod1 := /core/st/Socket  //type of mod1 is a module. it contains all functions and types defined inside mod1
let createSocket := /core/st/Socket::createSocket
let createSocket := mod1::createSocket
type socketType := /core/st/Socket::SocketType
type socketType := mod1::SocketType
```
We can use `::` to access types and functions inside an already loaded module.
1. `func` becomes a primitive data type.
2. `import` is not keyword and it removed.
3. You can use `::` to access types and bindings defined inside a module.
4. You can load a module in current namespace or as a binding with `let`. Then use `::` to access it's internals.
5. A new primitive type: `module` which you can only use by writing a module file and importing it. 
`func calculate(x: int, y: string) -> float { ??? if x > 0 then 1.5 else 2.5  }`
`let calculate = func(x:int, y:string)->...`

Y - use `def` to define a module binding.
The module type is too hidden. When I see `let x :=` on the right side it can be an int, a function, a module or any other possible value.
This is right and if there is need for more documentation, I can determine type.
`let x:int := 12`
maybe I should not use `let`?
`def`?
`def mod1 := /core/st/Socket`
2. `def _ := /core/std/{Queue, Stack, Heap}`
2. `def A,B,C := /core/std/{Queue, Stack, Heap}`
8. `def _ := git:/github.com/adsad/dsada`
9. `def _ := svn:/bitcucket.com/adsad/dsada`
Then maybe it can help to define inline module easier.
But it will make autoBind very different.
How can I convert a module to a tuple? You cannot because module can have custom types.
suggestion: Enable user to generate a tuple of function pointers with available functions in current context (default namespace) or any given module.
`def mod1 := /core/st/Socket`
`let au: AdderUtils := autoBind[mod1, AdderUtils]()`
Exception: You cannot send a module as an argument to a function. Why not? Because function argument needs a type. And a module contains types and bindings.
Just like the way we can have struct inside struct, we should be able to have module inside module.
But passing a module to another function is not possible. Because how are we going to describe it's type? Unless we capture part of the module. e.g. like auto-bind.
It will be a bit confusing if we use `def` here.
Because we should be able to address a function inside a module.
`let createSocket := /core/st/Socket::createSocket`
Unless we say, this is only possible if we have loaded the module before.
`def A := /code/st/Socket`
`let createSocket := A::createSocket`

N - maybe we can use `import` function instead of `autoBind` too!

Y - We cannot use `=` for type alias anymore. Because it is confusing.
`=` is equality check.
`:=` is binding.
maybe we should add a new keyword: `alias`.
`alias MyInt := int`
`type MyInt = int`
`type MyInt <- int`
alias con: it is similar to define in C. why not use it for other bindings?
`typedef`?
`typedef MyInt := int`
`type MyInt : int`? like `x:int` we define a type which is of another type.

Y - Explain the difference between namespace and module.
We have a default namespace which is current symbols + imported modules with `_`
Each module has it's own namespace which is accessible using `ns::symbol` notation.
Each module has it's own namespace. You can define new namespaces using `def`.
Maybe it is better if we replace `def` with `namespace` keyword.
`namespace _ := /code/st/Socket`
`namespace mod1 := /core/st/Socket`

N - Why can't we write a new module inline?
`let myModule := { let y = 12, let process = (x:int)->x+1, ...}`?
it will be confused with struct.
module can contain bindings and types and alias.
```
def myModule := {
  let y := 12
  let process := (x:int)->x+1
  type MyInt := int
  type MyInt2 : int //myModule::MyInt2 will be exactly the same as int
  let M2 := {
    let f:func(x:int)->x+1
  }
}
let g := myModule::y
let h := myModule::M2::f(10) //h will be 11
```
can I define a module inside module then? It make things much more complicated.
You can define struct inside struct. But for module, you cannot. Same as why you cannot define a file inside a file.
This is not a very useful notation (inline module), but banning it is harmful.
Is module a type or binding?
type is used when we can have multiple instances of it: `type MyInt := int`
But `let` is when we define an instance. `let x:MyType`. 
So module is a binding not a type.
I don't think banning this is a bad decision. This is not banning. We just dont provide notation and dont support this feature. If you want a module, create a new file and store the contents there. And load it here.
If that's not possible, just put the contents inside the current file. 
It is possible to allow such definition and semantic, but what problem will it solve?
It will definitely complicate definitions and encourage people to put multiple things in the same file.
But what advantages will it have?
It's advantage is like a function literal which is defined in-line.
Define module inline, means namespace lies below modules. Each module can have one or more namespaces.
What if what we need is above module? This is called package. You cannot import a package directly for readability reasons.
Also each module should work on a specific problem, so we don't really need further classification inside module.

Y - In import use `//` for local filesystem which is shortcut for `/file/`
Then `/git/`, `/svn/`... can be used to other protocols.

N - Maybe we should use a keyword for struct.

N - Simple:
1. Similar things behave similarly.
2. No exceptions. Only general rules.
3. Similar notations for similar things.

Y - replace `autoBind` with casting default namespace `::` or a module namespace to a struct.
How can we simplify autoBind?
autoBind is responsible to create a struct with function pointers (let) which now can be either function or any bindings, from a namespace.
`def A := /code/st/Socket`
`let myAdderUtils: AdderUtils := AdderUtils{A}`
Basically we are casting a module to a tuple. So it will assign everything inside the module with the same name as the struct fields and return a new instance of struct.
`let myAdderUtils: AdderUtils := AdderUtils{::}` This will do the above but for current namespace.

Y - Naming for namespace?

N - Can we use `[1,2,3]` notation for other types too?
If they suppose `set` then yes. Compiler generates calls to `set` for them.
But this will be confusing. When I call a function with `[1,2,3]` what will be it's type?

N - Can we reduce primitive data types?
e.g. remove array and map from primitives and treat them like a non-primitive? possible defined in std and not core.
bear in mind that everything is immutable.
`let x: array[int] = [1,2,3]`
then we need to remove `arr[0]` notation and possibly use `get` function.
make code less readable.
what about map?
replace `map["A"]` notation with `get` function call.
we no longer have `a[b]` notation. we use `a(...)` notation.
replace `map("A")` notation with `get` function call.
handle map literals in a general way.
conditionals?
we need to implement map in core. because inherently it uses conditionals.
question is: How can people define their own custom maps?
With cusom hash or bucketing. sha-1 or murmur or md5 or ... ?
User can write his own data type like `CustomMap` and write appropriate functions.
Will it support `myCustomMap("A")`?
will it support map literals? `["A":1, "B": 2]`. Not needed very much. We can write custom casting functions.
But we need to decide about `map("A")` and `array("A")` notation.
They make code more readable.
But their shortcut should not be special case.
`var(a1,a2,...)` maps to `get(var, a1, a2, ...)`
`var(a1, a2, ...)` maps to `var ~ get(_, a1, a2, ...)`.

Y - DRY - When type of the function indicates input types, in the literal part just mention input names.
`let add:func(int,int)->int := (x,y) -> { return x+y }`

N - If we move map to std, can we also move array?
we already use functions to read/write.
The only problem would be processing literals.
compiler needs to compiler a literal to a set of function calls. It cannot do it in a single function call. Because then, what would be input type of that function?
`let a := [1,2,3]`
will be translated to:
`let a := create_from_literal(3, create_from_literal(2, create_from_literal(1, empty_array)))`
we may have two types of array: normal linear array with sequential allocated memory, immutable array with tree-based allocation system.
we can think of `[a,b]` notation as a concatenation. So it will create a block of memory which is a concatenated to b in binary representation. this is similar to a struct. an untyped literal: `{field1, field2, ...}`.
we also have string type with it's special behavior by compiler. So let's just make array a built-in type defined in core and compiler will automatically convert `[1,2,3,...]` type literals to appropriate arrays.

Y - proposal: remove map from language and move it to std. 
We only need array. Also make the literal general. So any other type can use those literals.
we can do conditionals with array. If we have map, we can also use std.
q: What about `a(0)` notation?
q: but when we have a map-like literal, how can we know the type?
hashtable can be implemented using linked-list which we can have with struct and generics.
`myArray(0)` or `get(myArray, 0)`? Simple: second solution. uses already available features of the language. no exceptions.
how can we implement conditionals with this get notation?
`return get([0,1], x==0)` means `return 1 if x==0 else return 0`
If array is going to be built-in type, let's keep `a(0)` notation for them.
the only concern is about literals. We want the language to be expressibe. so user should be able to easily write array and map literals.
`[1,2,3]` is an array literal.
`let y:=[1:2, 3:4, 5:6]` is another literal form which compiler will compile to this:
`let y := set([1,3,5], [2,4,6])`?
How are we going to specify type of the data. Compiler is not supposed to infer the type for us, because it can be anything. Note that `map` is no longer part of the lang manual or compiler or even core.
It is going to be part of std.
`let y := ["A":1, "B":2, "C":3]`
`let set:func(array[string], array[int])->map[string, int] := (a,b)->{...}`
What if someone wants to use above literal for another type?
If binding has a type specified, then compiler knows the output:
`let y:map[string,int] := ["A":1, "B":2, "C":3]` So compiler must call the set function which gives `map[string,int]`.
But what if there is no type?
`let y := ["A":1, "B":2, "C":3]`
This will be translated to this function call: `create_from_literal(["A", "B", "C"], [1,2,3])` and if there is only one such function it will be called without a problem. If there are multiple such functions with same input type, the output type will be important. So it must be specified in the literal definition either by casting or by assigning a type to lvalue or type should be inferred from the context.

N - If we add support for varargs functions, we can easily support array and map out of core.
`[1,2,3]` will be converted to: `create` function call with varargs.
`let create[T] : func(items:VarArg[T])`
You can call core functions to get ith element from var arg.
core also has a memory allocation function to allocate and initialize memory of size X with given vararg.
A `[1,2,3,...]` will be converted to function call: `create[T]` where T is type of elements inside brackets.
A `["A":1, "B":2, "C":3, ...]` will be converted to function call `create[K,V]` where K,V are key and value types.
`let create[K,V] : func(array[K], array[V])->map[K,V]`.
read: `get`
write: `set`
But then shall we name them Array and Map like the naming convention? I think we should.
What will happen to string type then?
And bool?
`type String := array[char]`
`let str: String = "ABCD"` 
"ABCD" will be converted to `['a', 'b', 'c', 'd']` by compiler.
1. State that compiler handles `[1,2,3,...]` and `["A":1, "B":2, ...]` and `[1..10]` literals with function calls to `create`.
2. `"ABCD"` will be converted to `['A', 'B', ...]` by the compiler.
3. Functions can define to have variable arguments by using special struct defined in core: `VarArg[T]`.
4. core provides functions to allocate and initialize a piece of memory and get size of a type.
5. State that `true` and `false` are 1 and 0 in int context.
6. `var(1,2,3)` will be converted to `get(var, 1, 2, 3)` function call.
7. Array and Map will be defined in std and are not part of the language.
But then, how is compiler going to optimize if conditionals? if everything is implemented in std.
`let cases := [100,0]`
`let result := cases(x>0)`
Below should be the same:
`let result := [100,0](x>0)`
First compiler needs to call `create` to create something which we don't know.
q: When we create an array using core, what is type of the output of the function call? buffer?
We can have a binary type which represents a sequentially allocated memory region. 
But again, we need to have `binary` primitive type. Why not have `array` primitive type?
q: How can compiler optimize for conditionals when it cannot provide special behavior for array and map? Maybe we should use another way. Maybe compiler should create `binary` by seeing `[1,2,3,...]`. Then it can assign it to an array maybe.
`let result := get([100,0],x>0)`. We need to make `get` function call. But if we make it inline, it will be:
`let result := int{binBufferPtr + int{x>0}`.
I think this is optimized enough.
q: When we create an array using core, what is type of the output of the function call? buffer?
We can have a primitive data type called: `binary` which represent a memory buffer. An array is simply a binary with an additional info: cell size. Binary is more flexible than array.
So `[1,2,3]` will create a binary or an array?
compiler will see `[1,2,3]` and call `create[int](1,2,3)`:
```
type Array[T] := binary[T]`
let create := func[T](items: VarArg[T])-> Array[T]
{
  return Array[T]{malloc(len(items)*sizeof[T](), items)}
}
//in core:
let malloc[T] := (size: int, data: VarArg[T])->binary[T]
```
There can be other memory allocation functins for other purposes.
why not replace binary with array? array is more intuitive, let's compiler more optimizations and also you can use array for other purposes. `binary` can be used to allocate custom sized buffers. We can use array for this purpose too.

Y - Remove maps from lang syntax.
1. State that compiler handles `[1,2,3,...]` and `["A":1, "B":2, ...]` and `[1..10]` literals with function calls to `create`.
2. `"ABCD"` will be converted to `['A', 'B', ...]` by the compiler.
3. State that `true` and `false` are 1 and 0 in int context.
4. `var(1,2,3)` will be converted to `get(var, 1, 2, 3)` function call.
5. Map will be defined in std and is not part of the language.

Y - I think we should add another shortcut: `variable(a,b,c)` will become `get(variable, a, b, c)`. 
So reading from array and map and conditionals will become easier.

Y - Can we move loop functions to std? Because of immutability, we cannot have loops with counters. 
`while(x<10) print(x), x++`.
what is the fundamental things that we need in loops? Can we add it to the core or to the language syntax?
`while : func(predicate: func(int)->bool, body: func(int)->int`
we may want to create an array based on output of a loop body's lambda.
if we define array and map in std, we need to either define loops independent from array and map and put it into core/lang or define it based on map and put it in std.
Putting them in std is better because it makes language simpler. But note that std should be written in pure dotlang.
So suppose that I want to write `loop` function to execute a lambda over an array.
```
let loop := func(arr: array[T], body: func(T)->U)->array[U]
{
  let len := length(arr)
  return create[T](len*sizeof(T), arr >> body(_))
  //what does >> do? A >> closure(_)
}
```
Another solution: create an iterator for type X. but we then need `while`.
we can implement this using recursive function. which accepts an iterator and if it is eof, then return. else call itself again.
```
let loop := func(iterator: Iter[T], body: func(T)->U, outputIterator: VarArgIterator[U])->nothing
{
  assert !finished(iterator), nothing
  
  outputIterator = save(outputIterator, body(getValue(iterator)))
  iterator = forward(iteartor)
  outputIterator = forward(outputIterator)
  return loop(iterator, body, outputIteartor)
}
```
solution: You can't assign output of a loop to an array. You have to use a list. Then you can convert the list to array.
```
let innerLoop := func(iterator: Iter[T], body: func(T)->U, head: ListElement[U])->{ListElement[U], Iter[T]}
{
  assert !finished(iterator), head
  let current_loop_value := getValue(iterator)
  let current_loop_output := body(current_loop_value)
  
  return innerLoop(forward(iteartor), body, {data: current_loop_output, next: head})
}
let loop := func(arr: Array[T], body: func(T)->U)->LinkedList[U]
{
  return innerLoop(getIterator(arr), body, emptyList[U])
}
```

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

N - Remove `array` and `map` from core. They will be in std. We can implement them using a linked list.
Why do we need array? With immutability, we can only use array with hard coded values. Anything else needs a linked-list, including a map. So for example, reading lines of a file into an array is not possible because we cannot mutate the array as we are reading file lines. Haskell uses lists everywhere.
Maybe we should move array to std and treat it like `map[int,T]` and make `map` a primitive data type.
And `[1,2,3]` will become `[0:1, 1:2, 2:3]` map literal.
but can't we make map non-primitive?
What are operations on a map?
map is a linked list. Each cell has a data (key) and another linked-list.
read: hash, get to the data, find key in the list.
we can create hashtable with fixed bucket count for some cases. 
e.g. `x = new HashTbl(150)`.
The thing that we need is `O(1)` access time to elements in a linked list. If we can achieve that, we have an array.
q: How can we have `O(1)` read for a linked list without using a map? We can have a different data type like `treemap` which uses tree to provide `O(lgn)` access to list elements.
q: How can I initialize an array or map data structure? Done.
q: How can I read all lines of a file into a hash table with key=line number and value=line contents? Done.
q: What happens to array and map literals? Done.
q: What happens to conditionals and loops? Done.
q: How can I create a map with a lambda which returns map entries? Done.
q: How can I read lines of a file into a normal linked list? Done.
a: initialize array and map
we can use convention: `x := [1,2,3]` or `[1..3]` will call:
`a=iterate[int](1, nothing)` 
`b=iterate[int](2, a)`
`c=iterate[int](3, b)`
`x=iterate[int](nothing, c)`
`iterate[T] : func(input:T, state: Iterator[T])`
`iterate[T] : func(input:nothing, state: Iterator[T])`
similarly: `x := ["A":1, "B":2, "C":3]` will become:
`a=iterate[string, int]("A", 1, nothing)`
`b=iterate[string, int]("B", 2, a)`
`c=iterate[string, int]("C", 3, b)`
`x=iterate[string,int](nothing, nothing, c)`
a: read file lines into a map
`lines := [readLine(iterator)]`
every iteration has two outputs: the data for the final output (key, value) and next iterator. But these are the same things. Iterator points to key and values.
`lines := [filePosition:readLines(_)]` means while iterator?
Let's use loop function: `loop := func(arr: Array[T], body: func(T)->U)->LinkedList[U]`
we can have `loop : func(fp: FilePosition, body: func(FilePosition)->{K,V}, forward: func (FilePosition)->FilePosition)->Map[K,V]`. The key is using iterator to create a map.
suggestion: we can provide `map` function in core. to process a list or any iteratable.
suggestion: In a hashtable which needs 1024 buckets, create a list of that size.
a: conditionals and loops. Loops can be implemented using map and loop functions.
For conditionals we can use assert + lambda: `x=(y:int)->{assert y>0, 100 ; return 200}(current_y)`
`ifelse: func(predicate: bool, if_true: T, if_false: T)...`
`ifelseLambda: func(predicate: bool, if_true: func()->T, if_false: func()->T)`
compiler can inline these calls to make them efficient.
we can have `treelist` type and `get[T](treelist, index)` will return data at position index after address of treemap.
But how can we model this? we need a linked list which it's next is calculated automatically. It cannot be extended.
`type treelist[T] := {data: T, next: treeList[T]|nothing}`
actually, we can treat an array like a linked-list. so if data points to memory 100 and next points to memory 108 then it is an array. 
we can have a function in core which receives a size and returns a linkedlist of that size which you cannot extend. The list will be allocated in a consecutive memory block. 
`type ArrayList[T] := { data:T, next: ArrayList[T]|nothing }`
`mylist := coreMallocArrayList[ArrayList](100 * sizeof[T])`.
`let get := func(arr:ArrayList[T], index:int) -> coreGetMemory[T](arr, index*sizeof[T]())`
We want to have a data structure which is treated differently. Normally a struct field, is a pointer to a memory location. But we want to have it as a value, instead of a pointer.
Actually we want to `x.field1` return a pointer which is `addr(x)+offset`. where `field1` is a struct (so is `x`).
`type T := { field1: Point }`
`let x:T := { field1={x=100, y=200} }`
`x.field1.x` should be converted to a memory address by compiler. this address will be:
`temp=addr(x)+offset_field1`
`result=temp?`
In arraylist we have a `next` field, we don't want to allocate memory for it. We will be calculating it at runtime.
but this is against all other language rules.
Let's just remove `next` field and provide the calculation using iterators and functions.
`type ArrayList[T] := { data:T }`
`type Array[T] := {size:int, raw: ArrayList[T]}`
`mylist := coreMallocArray[ArrayList, Iter](100 * sizeof[T], iter0: Iter, valueGen: func(Iter)->{T, Iter})`.
`let get := func(arr:ArrayList[T], index:int) -> coreGetMemory[T](arr, index*sizeof[T]())`
still it's not very readable. We have `ArrayList` which is size of `T` but in practice, we allocate `100*sizeof T` memory to it. This is not readable.
maybe we should add binary data type. With array we cannot create dynamic sized array. 
I said "With immutability, we can only use array with hard coded values" But maybe that's not true. We can create an array and at the same time, provide a generation function to allocate it's cells.
`let x: array[int] := createArray[int](count, iter0: Iter, gen: func(iter: Iter, index:int)->{int, Iter})`

Y - Make `binary` the primitive data type. And make `array` in std. But what will be the difference between these two?
`binary` can be more general. It is a flat memory block. But array uses binary to store a number of data items of the same type. 
`let x: binary = [1,2, "A", '4']` is valid and compiler will allocate appropriate memory block and set the values there.
`let x: binary = allocBinary(byte_count, body: func(index:int)->binary)`.
`get` for binary? it needs offset and output type.
But for array, it can work with only index.
generally binary is more general and maybe people can use it to implement O(1) linked-list.
we can also simulate other things using a binary.
`let x: binary = [1,2, "A", '4']`
`let x = [1,2, "A", '4']`
`let ax: array[int] = [1, 2, 3, 4]`
`x(1)` means second byte of the binary data.
`ax(1)` means second element.
`get[T](a: binary,i: index)`
`get[T](b: array[T], i: int)`
`type array[T] := binary`
array is a phantom type.
`["A":1, "B":2, ...]`?
We can generalize it to `[a:b:c:d:... e:f:g:h:... ]` all elements must have same count.
which will be formed into a set of function calls. There is no other way than calling functions step by step to create the hashtable. We should design the map with iteration in mind. Something like a linked-list.
So: `[a:b c:d e:f]` will become:
`x=set(nothing, a, b)`
`y=set(x, c, d)`
`z=set(y, e, f)`
`[a,b,c,d]` automatically allocates memory buffer.
You can also use core functions to allocate and initialize the buffer.
So what is type of `[1,2,3]`? binary or array?
If we move array to std, it should be called `Array`. same as `Map`.
Then it will be just like `int` and `MyInt`. You have to specify type.
`let x := [1,2,3]` will create binary.
`let x: Array[int] := [1,2,3]` will create array.
`let x := Array[int][1,2,3]`
As Array is no longer part of core, we cannot have a special behavior for it.
We can just have a notation which determined type.
`let x := Array[1,2,3]` This means the binary block should be of type `Array[T]`. Definitely the type should have a generic type parameter.
What about map?
`let x := Map[1:2, 3:4]` this means what? The type is specified by the available `set` methods. So we don't need to specify type here.
`func set(mp: Map[K,V]|nothing, k: K, v: V) -> Map[K,V]`. But then again, we may have different set functions each with it's own output type. for example, a set for linked-list with two data points per element.
`func set(mp: List[K,V]|nothing, k: K, v: V) -> List[K,V]`
So with `[1:2, 3:4, 5:6]` both of these can be called.
We can write: `let x := Map[1:2, 3:4, 5:6]` to denote output type we expect. The type of arguments for set if determined in the literal.
So:
1. array is removed from primitive types.
2. binary is primitive now with support from core to initialize using a set of function calls.
3. `[1,3,4]` is a binary literal but you can use a type prefix with one generic type argument to specialize the type: `Array[1,2,3]`.
4. Still `array(0)` will be translated to `get(array, 0)` same for binary.
5. `[a:b:c, d:e:f, ...]` with vairable number of arguments and variable but similar number of elements in each part, will be translated to a set of calls to `set` function. You can prefix this with type to specify which set function to call: `let x := Map["A":1, "B":2]` will call `x=set(nothing, "A", 1)` then `y=set(x, "B", 2)` and output of set is `Map[K,V]`.
6. For binary literal, you can prefix with type if elements in the literal have the same type.

Y - Enable writing things like `[1,2, str, ...]` an array of different types and compiler will automatically store them in the memory with level of access same as type. Obviously compiler cannot infer type of `[1,2, "A"]` so it must be specified and it will give developer ability to access inside a data.
`let x:array[char] = [121212112]` this will create an 8 cell array populated with this integer value.
In this way we can access internal bytes of an integer or any other data (struct, union, ...).

Y - Should we remove type prefix from literals?
We can always write:
`let x:Array[int] = [1,2,3]`
or:
`let x:Map[string, int] = ["A":1, "B":2]`
So if type is specified in the context (function output, function argument, binding has a type), compiler will call appropriate functions. If not, it will call default ones.

Y - What happens to string concatentation?
`let a := ["AB", "CD", "EF"]`. Is it a string? or array of strings? or binary?
String is binary. The size of that binary is specified by the compiler.
`a` is `"ABCDEF"` which is 6 characters in a binary data. If you call `get` for the string, it will give you the character.
What if we want to have array of string?
`let a: array[string] := ["AB", "CDEE", "EFGHHHHHH"]`
In this case, size of strings can differ. How can we fetch 2nd item in this array then?
q: What is the difference between `["A", "B"]` an `[v1, v2]`? Nothing. Data inside v1 and v2 will be copied to the result binary buffer.
`let a: array[string] := ["AB", "CDEE", "EFGHHHHHH"]`.
Treating `["A", "B", "C"]` as concatenation of strings is not intuitive and general and will be confusing when people have array too. So let's handle it differently. e.g. `+`.
`"A" + "B"` will give you `"AB"` string.
`["A", "BCD", "EFG"]` will give you a binary which has 7 characters.
`["A", "BCD", "EFG"]` as array of string, will give you an array with 3 pointers.
`[point1, point2, point3]` what will this binary look like? Will it be 3 pointers? or 3 point data?
which approach is more general and intuitive?
we should handle string concat using functions. If we move string to Std, then maybe we can treat it more intuitively.]
I think the idea that we can have different data types in a binary can cause confusion because later we will have no way of reading them back. Unless the owner know what is where. But then it can easily define a struct.
So let's assume binary, is `binary[T]` where T denotes elements inside the memory slot.
`type string := binary[char]`. means string is a memory buffer containing characters.
`[1,2,3]` is of type `binary[int]`.
What about string?
`["A", "B", "CDEF"]` does it have 6 characters or 3 strings?
By default it should contain 3 strings. `get(x,0)` should give you `"A"`.
Can we cast it so that it concats the data? If we do, we should make it general.
`let x := string["A", "B", "CDEF"]` will give you `"ABCDEF"` string.
`binary[T][...]` means elements in place of `...` must be of type T or should be casted.
`[pt1, pt2, pt3]` contains 3 pointers to 3 points.
Everything in a binary literal is a pointer, except for primitives (int, float, char) which are values. But actually it makes no difference for us.
`type list[T] := { data: T, next: list[T] }`?
can we cast a part of a binary, as another binary? `x=[1,2,3,4]`
I want to have a binary which is `[2,3,4]`. This should be possible using core, is similar to array slice.
So as a summary:
1. the primitive type is `binary[T]` where T denoted type of elements inside the memory block.
2. binary literal must have items of the same type.
3. `let x:string := ["A", "B", "CDEF"]` If a binary literal has a specific type with specific T, compiler will convert. So `x` in this example will be `"ABCDEF"` and not 3 strings lied in a binary.
but `let x:binary[string] := ["A", "B", "CDEF"]` will make `x` contain 3 strings (3 references).
4. core will provide functions for string search, regex, replace, trim, concat, ....
5. `[bin1, bin2, bin3]` where type of all bini values is `binary[T]` can be either `binary[T]` or `binary[binary[T]]`. This will depend on the context. `binary[binary[T]]` is the default case unless in the context, it should be `binary[T]`.
`let x:binary[int] = getSlice(array1, 0)` will give you a binary which points to a space inside another binary. this is provided by core.
With current definition, what is the difference between binary and array?
If we are looking for just a different name, binary is not descriptive.
`block`, `buffer`, `seq`. Let's go with `seq[T]` which is array for all practical reasons.
It also embeds the self-similar property of the data structure.
1. the primitive type is `seq[T]` where T denoted type of elements inside the memory block.
2. binary literal must have items of the same type.
3. `let x:string := ["A", "B", "CDEF"]` If a binary literal has a specific type with specific T, compiler will convert. So `x` in this example will be `"ABCDEF"` and not 3 strings lied in a binary.
but `let x:seq[string] := ["A", "B", "CDEF"]` will make `x` contain 3 strings (3 references).
4. core will provide functions for string search, regex, replace, trim, concat, ....
5. `[bin1, bin2, bin3]` where type of all bini values is `seq[T]` can be either `seq[T]` or `seq[seq[T]]`. This will depend on the context. `seq[seq[T]]` is the default case unless in the context, type is `seq[T]`.
`let x:seq[int] = getSlice(array1, 3)` will give you a binary which points to a space inside another sequence. this is provided by core.
Shall we provide a specific notation to destruct a sequence?
`let x,y,z := str` x,y,z will catch first 3 characters? No. it does not make sense. this notation is only for struct.
`let x:seq[seq[int]] := [seq[int], seq[int], seq[int]]` this is 3 pointers. 
`let x:seq[int] := [seq[int], seq[int], seq[int]]` this is 3 concatenated sequences.
`let x:string := ["A", "BC", "DEF"]` this is a string `"ABCDEF"`
`let x: seq[string] := ["A", "CD", "DEF"]` this is a sequence of 3 strings

N - How can we represent 2d array?
`[[1,2], [3,4],[5,6]]` is a valid literal.

Y - What if we have `{1} ~ process(_)` and there are two process functions. one that accepts int and one that accepts `{int}`? 
If you write `1 ~ process(_)` it will definitely call `process(int)`. But with struct literal, and two process functions there will be ambiguity.
Shall compiler give compilation error?

N - There can be ambiguity between function boundaries and struct literal/definition.
shall we change it?
like:
```
let process := (x:int, y:int) -> int 
{
}
```
proposal 1: like Python, spaces.
proposal 2: use two keywords to mark beginning and end of function body.
```
let process:func(int,int)->int := (x:int, y:int) -> int 
  let a := 12
  return x+y+a
```
we can say functions must end with `return` keyword. Then we have an end-marker.
The start-marker is the literal. But this makes code less readable if we define a lambda inside a function.
proposal 3: Use `$` prefix for tuple literals.
proposal 4: use `$` prefix for code literals.
```
let process := (x:int, y:int) -> int 
${
  return x+y 
}$
```
proposal 5: use double braces
```
let process := (x:int, y:int) -> int 
{{
  return x+y 
}}
```
not good. it is still confusing with cases where we define nested struct literals.
`{1,{2,3}}`
proposal 6: begin/end
proposal 7: Use something else for tuples.
proposal 8: Dont change. This is not a major problem.

N - `[0:"A", 1:"B", ...]` can be used as a linkedlist-

N - Can we remove `let` keyword? Because it needs to appear with `:=` so just use `:=` to denote a new binding.
pro: it makes reading easier. DRY. When I use `:=` it means `let`.
con: Maybe text becomes less readable? So why not remove type too?
`type MyInt := int`
`MyInt := int`
`MyVal:int := 10`
Or maybe we should use different notations and remove both keywords?
I think using keywords is better as it makes text more readable.
`type A := B` type
`let  A := B` data
what comes on the left side of `:=` is an identifier and on the right side of `:=` is either a value (5, "A", 1+f(x)...) or a definition `{int,int}`.
The nature of these two is different. That's why we use different keywords.
`let` for data
`type` for types
`let process : func(int,int)->int := (x:int, y:int)->x+y`
`func process(x:int, y:int)->x+y` this is shorter but less consistent with other notations that we have.
But it may be good if we differentiate these two. type and binding definition.
`type MyInt := int`
`::value:int = 12`
But `::` is used elsewhere for namespaces.
If it is a blueprint, we should use a different keyword (and notation?).
If it is a value binding, we should use a different keyword (and notation?).
`let` is used for multiple purposes: define function, data.
It is one purpose: define a binding. But that binding can be int, string or a function.

N - If we have a binding which is union of functions which accept int, float, string and output int can I call it with a binding of type `int|float|string`?
`let fn: func(int)->int|func(string)->int|func(float)->int := ...`
`let data: int|float|string := ...`
`let o := fn(data)`
We should be able to do that because it makes sense. Unless of course, the union has a non-function case which does not match.
But what if union has `func(int)->int` and the data is of type string?
We should call it with possible inputs for all cases.
`let fn: func(int)->int|func(string)->int|func(float)->int := ...`
`let o := invoke(fn, int_var, string_var, float_var)`
this can be even placed in std.
Maybe we can even call it with an untyped struct.
`let o := fn({int_var, string_var, float_var})` But this will be inconsistent with current notation.

N - Can we have variadic templates?
for example 
`let fn: func(int)->int|func(string)->int|func(float)->int := ...`
`let o := invoke(fn, int_var, string_var, float_var)`
To support cases where we want to support flexible unions with any number of types (e.g. implement pattern matching).
`let invoke : func(x: T|S|U, t: T, s: S, u: U) ...`
what about the case with four types?
We can write one function with 9 or 10 types and call it with any union with less cases? What about the rest of arguments?
`let invoke : func(x: T|S|U, t: T, s: S, u: U) ...`
`let invoke : func(x: T|S|U|V, t: T, s: S, u: U, v: V) ...`
`let invoke : func(x: func(T)->int|func(S)->int|func(U)->int|func(V)->int, data: {T, S, U, V}) ...`
It will make things complicated. Let's not add them to the language.

Y - Candidates for adding a keyword which makes language more expressive: loop, switch (pattern matching).
switch: we have a binding A and a list of candidates B1,...,Bn, Each Bi has a lambda.
To whatever binding they are equal, the lambda will be executed which specifies result of expression:
```
let a := match data 1 -> 100, 2->200, 3->300, _->400
```
Note that we no longer have code-block. So any complicated calculation should be in a lambda.
```
let a := data = 1 -> 100, 2->200, 3->300, _->400
```
```
let a := 200 if data=1 //else nothing, no. we need a more comprehensive system.
```
`let a := match data 1 -> 100, 2->200, 3->300, _->400`
This syntax seems ugly.
Let's do this: Function can have literals for their input. Use a sequence of lambdas with this format and match keyword which decides which function to call.
```
let a := match data [(1)->100, (2)->200, (3)->300, _->400]
```
`let a := match X [lambda1, lambda2, lambda3, ...]`
The first lambda that can accept X will be called and the result will be stored in a.
All functions must have same input/output type.
pro: You can extend this. data can be a tuple and lambdas can have multiple inputs.
con: specifying literal for lambda if made general, will make language more complex and less readable.
`let a := match data [(1)->100, (2)->200, (3)->300, _->400]`
Maybe we can add match function to std where we have maps.
`let a := match(data, [1:100, 2:200, 3:300])`.
Ok. What about loop?
```
let innerLoop := func(iterator: Iter[T], body: func(T)->U, head: ListElement[U])->{ListElement[U], Iter[T]}
{
  assert !finished(iterator), head
  let current_loop_value := getValue(iterator)
  let current_loop_output := body(current_loop_value)
  
  return innerLoop(forward(iteartor), body, {data: current_loop_output, next: head})
}
let loop := func(arr: Array[T], body: func(T)->U)->LinkedList[U]
{
  return innerLoop(getIterator(arr), body, emptyList[U])
}
```
A loop in general (conditional, iteration, ...) needs these components:
1. iteration lambda (a lambda which decides whether iteration should be finished).
2. forward lambda: accepts current iterator and moves it to forward.
3. body lambda: does the calculation, accepting current iterator, outputs some value or maybe nothing.
4. Initial value for iterator lambda.
`iter_lambda := (x:int) -> x<10`
`fwd_lambda := (x:int) -> x+1`
`body := (x:int, curr_output)-> print(x), return curr_output`
`initial := 0`
above config will print `0,1,2,...,10`
How can we simplify, compress this and make it more intuitive and general?
`let initial := 0`
`let result := loop initial, iter_lambda, fwd_lambda, body` the most mechanical way.
and also how are we supposed to set value of result?
body should also accept output iterator too.
Maybe we can combine body and fwd lambda.
`let result := body while iter_lambda`
we can send nothing on the first round.
```
let result := (x:int|nothing) -> 
{ 
  assert x!= nothing, 0
  print(x)
  return x+1 
} while (x:int) -> x<10
```
we can say, the output of the last round of execution is what will be placed on result.
loop for iteration is not useful right now because almost all collections are going to be placed inside std.
So let's focus on conditional loop (while). OTOH this type of loop does not have a prefixed number of execution rounds. it may run for no round, 10 rounds or 1000 rounds. So what can we expect from output?
We can create a linked-list and update it with respect to immutability restriction.
q: How can we write a conditional which creates a singly linked list with numbers 0 to n where n is variable?
```
let n := 100
//I want result to be 0->1->2->...->99
//continue execution until the predicate returns nothing.
let result := (x:int, lst: List[int]) -> 
{ 
  asset x<10, nothing
  let newList := append(lst, x)
  return newList
} while (x:int) -> { assert x<10, nothing, return x+1 }
```
So we now have two components:
1. Body lambda: accepts current round value and current intermediate result. does the processing and returns new result.
2. Predicate: Accepts current round value, return nothing if loop must be finished. else returns next round value.
We can say, if predicate input is nothing, it is the initial call and it should return the initial value (which can also be nothing if we want to stop loop without even one execution round).
```
let n := 100
//I want result to be 0->1->2->...->99
//continue execution until the predicate returns nothing.
let result := (x:int, lst: List[int]|nothing) -> 
{ 
  let newList := append(lst, x)
  return newList
} 
while (x:int|nothing) -> 
{ 
  assert x=nothing, 0
  assert x<n, nothing
  return x+1 
}
```
`let A := body(x, o) while pred(x)`
1. O := nothing (current loop result)
2. X := nothing (current iterator value)
3. X := pred(X)
4. if X is nothing, return O as the output and finish the loop
5. O := body(X, O)
6. goto step 3
In other words: `let A := body while pred` means run body as long as pred does not return nothing, at which point result of last execution of body will be stored in A.
better name?

Y - Can we merge assert and return?
`return 10`
`assert condition, 10`
It is not very intuitive to read assert statement.
`return 10 if x=10`
problem is: if we add `if` and ban it's use with let, it will not be orth and gen. if we allow, then we will need else.
`let x := if cond then 10 else 20` this is good but what happens to assert?
if we use `if` as an expression it cannot replace `assert`.
if we use `if` as an statement it will be incompatible with assert.
`retif x>0, "ERROR"`
`return 10 if x>10`?
proposal:
1. remove `assert`
2. add `if` keyword but it can only be used with `return`.
`let x := 10 if cond` no.
`return 10 if x>10` is more readable than assert but it will be confusing because we cannot use it elsewhere.
Let's not look for `if` because it will make things confusing.
proposal: use a notation. `x>0 $ 100`. But then we should use the same notation for return.
`x>0 $ 100` - assert
`$ 1000` - return
or:
`x>0 return 100`
`return 200`
`x<100 and y!=100 return 100`
let's prefix return with the conditional.
it is not the most readable thing but: we will remove assert, no need to add it.
It will be more readable than assert.

Y - We really should have a notation for one line so writing two statements in one line should be possible:
`let fn := (x:int) -> { print(x), return x+1 }`
proposal: Enable semicolon as statement separator when multiple stmt in the same line.
`let fn := (x:int) -> { print(x); return x+1 }`
`let fn := (x:int) -> { print(x)$ return x+1 }`
`let fn := (x:int) -> { let y := x+1; print(x); print(y); return x+1 }`

Y - What is this:
`let process := (x:int) -> {print(x)}`
Does it return a tuple which includes nothing? or just returns nothing.
Let's use `$` for tuple literals.

Y - semicolon can be confusing.
Let's use `&`. 

Y - Add nothing check operator:
`let x := y ^ z ^ 1`
`let x := y or z ^ 1`
`let x := something(y, z, 1)`
variadic function? but what will be type of input?
if we want this, we should have variadic template.
```
let something[T...] := (data: T) -> 
  (x:int, ???) -> { T[x] != nothing return T[x] & return nothing } 
  while 
  (k:int|nothing) -> k == nothing return 0 & k >= length(data) return nothing & return k+1
```
We cannot have the type for round output. it can be nothing OR type of T[x]. Also, this means result of the whole loop can be still nothing (which by the way makes sense).
Maybe we can do this: Input is a normal array of union. possible types of the union are determined at compile time.
```
let something[^T] := (list: seq[|^T|]) -> 
  (x:int, _:|^T|nothing) -> { list(x) != nothing return list(x) & return nothing } 
  while 
  (k:int|nothing) -> k = nothing return 0 & let y := int{k}.0 & y >= length(list) return nothing & return y+1
```
applications of variadic template: string concat with other types, invoke a union function with union input.
`let fn: func(int)->int|func(string)->int|func(float)->int := ...`
`let invoke[^T] := (function: |func(^T)->int|, input: |^T|) -> @func(input)->int = @function return function(input) & return nothing`
or string creation:
```
let concat[^T] := (data: seq[|^T|]) ->
  (x:int, result: string|nothing) -> { data == nothing return nothing & return concat(result, data(x)) }
  while
  (x:int|nothing) -> { x = nothing return 0 & let y := int{x}.0 & y >= length(data) return nothing & return y+1 }
```
Can we generalize this more? There is another case that we need to generate multiple types at compile time: embedding.
`|{Shape}|`

N - When type of x is `nothing|int` and we have `x=nothing return 0 & return x+1` compiler should deduce that `x+1` is adding 1 to an integer, not `int|nothing`.
`x=nothing return 0 & return int{x}.0+1`
this makes compiler code complex and reading code harder because these two may not be near each other and also the first return can have other conditions too.

N - Can we extend `_` in destruction:
`let x,_ := {1, 100}`
`let x,_ := {1, 100, 200}`
`let _,x := {1, 100, 200}`
No.
left side must have appropriate number of elements even for `_`.

Y - Formatting: braces on their own line unless the whole code is in one line.
`x := { ... }`
or
```
x := 
{
...
}
```

N - Can't we generalize condition prefix for return?
Of course this cannot be used with `let`. But with other types of statement like function call it should be usable.
Also can we make it more explicit?
like `=>`
`x<0 => return 100`
`x>0 => let t := 12` NO.
How does this work with `&`?
`let process := (x:int, y:int) -> { x>0 => return 100 & ... }`
Maybe we should enclose boundary for the condition but it will be something like code block.
`&` should break the bounday for the condition.
What type of statements can we write?
`let`, `function call (which also means let`, `return`.
So we either have `let` or `return`.
Why we cannot prefix a let with a condition?
`let x := 10` what if condition is not satisfied? The value for x is not clear here.
Unless we embed the condition into `:=` which is not good.
`x<0 => return 100`

N - A better way to specify initial value.
```
let x, result := 0, ()->... while ()->...
```

Y - We have two types of statements: `let` and `return`.
Can we mrege them? or unify them?
we cannot remove `let` because it is also used at module-level. And removing it will be so implicit.
It should be explicit because it is important.
instead of `let _ := process()` you can simply write `process()` but generally having let is a good thing.
I may need to call dispose before return. But this is only needed for ex-res. So its not a big issue.
I think we cannot merge these two because their nature is different:
let means do some calculation and proceed.
return means do some calculations and exit.
Let's accept the fact that we may have two types of statements: let and return.
Now, having pre-condition only for return seems a bit non-orth.
If we can have a meaningful and good definition for let with pre-condition then it would be fine.
`x<0 >> return 100`
`x<0 && return 100` confusing with `&`.
`retif` not very readable.
`return 100 if x<0`
`return 200`

Y - With larger loops, reading code can be difficult because while can be placed far from initial assignment.
`let A := do body(i, o) while pred(i)`

N - Add a style section.

Y - Can we add if suffix to let?
`let x := 10 if t<10`
this means if t is less than 10, x=10 else x will be nothing.
So if there is an if suffix, compiler will infer `|nothing`.

Y - nothing check operator?
`let y := a | b | c`. This is confusing with union.
`let y := x || y || z || nothing`

Y - `let x := t if r<10 || 11`
implements if/else.

N - `&` can be confusing with and. can we choose another separator?
`let fn := (x:int) -> { let y := x+1 & print(x) & print(y) & return x+1 }`
`let fn := (x:int) -> { let y := x+1 then print(x) then print(y) then return x+1 }`
`let fn := (x:int) -> { let y := x+1 then return 100 if x<0 then print(x) then print(y) then return x+1 }`
then is not good because combined with if is can be misleading.
`let fn := (x:int) -> { let y := x+1 then print(x) then print(y) then return x+1 }`
`let fn := (x:int) -> { let y := x+1 , print(x) , print(y) , return x+1 }`
`let fn := (x:int) -> { let y := x+1 , print(x) , print(y) , return x+1 }`
`let fn := (x:int) -> { let y := x+1 then return 100 if x<0 then print(x) then print(y) then return x+1 }`

Y - remove variadic generics.
It was initially used to support nothing check. But now that we have `||` it is mostly same as using a tuple.


Y - The capital letters rule for union identifier it not convenient.
Shall we add a prefix? like `!`?
`type DoW := %Sat | %Sun | ...`
`let x:DoW := %Sat`
`if x = %Sat`
Let's just have no prefix. Like Haskell and F# and almost all other languages.

Y - Phantom types?
```
type State := Open | Closed
type Socket[T] := { data: int }
```
But I cannot say T must be of type State. If you want to be strict you can write:
```
type State := Open | Closed
type Socket[Open], Socket[Closed] := { data: int }
```

Y - Change comment char to `#` and nothing-check to `//`.
`let x := 10 if x<10 // 200`

Y - Can we change if notation. Because it becomes less readable when combined with `//`.
`let x := 10 if x<10 // 200 & return 100`
`return 100 if x<10`
or:
`let x := if x<10 then 10 // 200 & return 100`
`if x<10 return 100`
Let's remove support for if in let. Only in return.
`return 100 if x<100`
`let x := [200, 10](x<10)`

N - We should allow both single and double-quote. but what is type of this? `'c'`? Is it string or char?
`'c'`
`"DSADSAD"`

Y - remove `&` Using `&` for continue execution is not intuitive. `&` in english means and.
Maybe we should remove it?
con: it may force reader to scroll horizontally
con: typos may get hidden
con: diff view will be more difficult to read

N - Should we throw runtime error if seq index is out of bounds? yes.
if we return struct with result and bool, it can be directly used in return.
`return [100](condition)` acts like an assert.
This is determined by the output type of `get := (arr: seq[T])->` but as it is part of core, we must specify it in lanref.
OTOH if we remove index-out-of-bounds error, a conditional like: `let x := [100, 200](x<100)` won't be possible.
You will need to add `.0` to fetch the actual result from the tuple.
Let's keep runtime error. conditionals will be easier and for return, we have a good alternative.

Y - We don't need booleans as a separate type.
bool can be considered `true|false` and `true=1, false=0`. 
We need it but it will be based on int. 
So `true` is int 1. we don't need to cast true to 1.

N - Can I write union with values?
`type Data := 1 | float`? No.
So how can I define bool type when true is 1?
`let true := 1`
`let false := 0`
No. union is not supposed to cover that. 
Let's just say compiler will do the conversion.

Y - `if` can we get rid of it?
pro/con of having if:
pro: makes code more readable.
pro: early return
con: if removed, we will have unification. everything will be let. NO. but we can do it. either make the last exp, the return value or use a special case of let.
`let := 12` means assign the return value.
Write a piece of code without if and compare.
what if we can say, set this value if it is not `nothing`? use `//`.
But I don't want to make the whole function a big `let`:
`let output := [1,2](11) // [3,4](cond2) // ...`
`output`
1. make output value explicit.
2. we should either have an early return or some mechanism to prevent execution of a let if we already have our output.
```
let output := [-1, nothing](x<0)
let expensive_result := ...
let output2 := 
```
But if we treat function output as a binding, we may need to re-assign to it.
problems with implicit return:
1. invisibility
2. error prone, you may add some let after return.
Ok let's keep explicit return. But what about if?
A two-part keyword if not very good.
But assert is also misleading.
`return 10` definite return
`returnif 10, x<10` what would the order be then?
having a keyword with two parameters makes reading code difficult.
so either we should make it one argument or ?
`return [100, nothing](x<100)`
one argument: a tuple with two elements. return value, and condition result.
`return [${100, true}, ${0, false}](x<100)` redundant code.
`return [100](x<100)` if `x<100` is false, it will return 100. if not, element is missing! so maybe instead of runtime error we can return a tuple. But then it will also affect to legitimate case: let's make return aware of this. return always receives a tuple. returns the first element if the second element is true.
so: `return 10` will be wrong. we should write: `return ${10, true}`
or we can add a new keyword: retif. return is non-conditional return. retif expects a tuple.
`return 10` -> `return [10](false)` boiler plate! not very intuitive.
proposal 1: `return ${retval, do_ret}`, `return [100](0)` (this needs removing runtime error for seq access outo of bounds)
`return (100)` can be shortcut for a function call which will return `${input, 0}`
proposal 2: `return 1`, `retif 1, x<10`
proposal 3: `return 1`, `return 100 if x<0`
why not remove conditional?
```
let lambda1 := ...
let lambda2 := ...
return [lambda1, lambda2](condition).0()
```
in complex logic this will make code less readable.
what is the main goal of the language: simplicity. Now which one of proposals is simpler?
can we have `return (100)`? `var(1)` will be converted to `get(var, 1)`.
what about the case there is no var? what will `(1)` be translated to? it can be translated to `get(1)`.
if so, we can write `return (100)` to have a normal return.
and `return ${100, condition}` for conditional and these two are the same.
so:
proposal: keep `return` keyword but it needs a tuple with exactly two elements: return value and condition.
if condition is met, it will return the given value. else, does nothing.
what if I want to evaluate and return a lambda if a condition is met? write two statements: first evaluate if condition is satisfied. `return [()->100](0)()`? no. let's no make it more complicated.
evaluating a lambda and returning a value are two different things. Let's not mix them.
proposal:
1. `return` needs a tuple with two elements: value and flag.
2. we still can have index out of bounds runtime error. so conditionals with array can be done more easily.
3. to return a value: `return ${100, true}` or `return (100)`
4. `let get[T] := (data: T) -> ${data, true}`
5. to return conditionally: `return ${data, predicate}` or `return ${[100,200](predicate), true}`
q: what happens to the shortcut: `let adder := (x:int, y:int)->x+y`?????
shall we write: `let adder := (x:int, y:int)-> ${x+y, true)` ?
or `let adder := (x:int, y:int)-> (x+y)` ?
what if I write: `let adder := (x:int, y:int)-> ${x+y, x<100)` ? then it will be a compiler error?
should it return nothing in this case?
`let adder := (x:int, y:int)-> ${x+y, x<100)` means if `x<100` return x+y else return nothing.
But it is making things more and more hidden. `(a)` is `get(a)`.
defining `(a)` as `${a, true}` is also irrational. Why not write `${a, true}` instead?
`var(1)` is more readable and is meant for seq access.
Also `let adder := (x:int, y:int)-> ${x+y, x<100)` can be a bit confusing. becase nothing return type is not visible.
current proposal: `return ${value, predicate}`
q1: `let adder := (x:int, y:int)-> ${x+y, x<100)` what does this do?
q2: can I write `let adder := (x:int, y:int)->x+y`?
we can say, without `{}` everything on the right side of `->` will be returned. But it will make things confusing. Two different way of operation for the same thing.
`let adder := (x:int, y:int)->x+y` should be a shortcut for:
`let adder := (x:int, y:int)->{return x+y}`
one solution: write `let adder := (x:int, y:int)-> (x+y)`
Can we just merge `var(1,2,3)` and `(var, 1, 2, 3)` notation?
`[100,200](100)` -> `get([100,200], 100)`.
proposal 3: `return 1`, `return 100 if x<0`
Then we can get rid of `(a,b,c)`->`get(a,b,c)` notation.
it is clearer and more readable.
proposal 1: `return ${retval, cond}`, pro: simple, no new keyword. con: complex, tuple all over the place, shortcut notation will be confusing `()->10` won't work. 
proposal 5: provide an un-returnable value which cancels return.
`return nothing` does not work. so `return [100, nothing](x<100)` will only return if `x>=100`.
important factors:
1. we should preserve the shortcut notation: `()->10`
2. it should not pulloute all over the place with boilder plate.
3. better not to have a two-part keyword `return ... if ...`
we already have `do ... while ...` but they are together all the time. having return with optional if is a bit confusing.
having `return nothing` not returning, is also confusing. 
One meaning of simple is straightforward, without special/edge cases and easy to understand and act as expected.
having forced to always return a struct is not simple.
`retif` is also confusing because it sometimes can be hard to know which one is the condition.
proposal 1: `return 100 if x<0`
proposal 2: `x<0 => return 100`
proposal 3: `return _` means don't return. then `return [100,_](x<100)` won't return if `x<100`.
using `_` will be confusing. because normally it is used as a name, not a value. also:
`return process(_)` what does it do? reading  `return [100,_](x<100)` is harder than `return 100 if x<100`.
Maybe we can choose another symbol? But what will be it's type? Can I send it to another function? ...
proposal 1: `return 100 if x<0`
proposal 2: `x<0 => return 100`
proposal 3: `(x<0) return 100` return 100 if `x<0`
`(x<0) ~ (_:false) -> return 100`
`(x<0) ~ return 100`
We can give a new meaning to `(x)` comapred to `x`. but it won't be very useful.
`return` means jump to the end of the function (position T). if we state it as a delta, it means just D bytes forward.
`return 100` -> `result=100, jump $current+D` where D is determined at compile time.
Now if we have access to D value, we can multiply it by 1 or 0. 1-> do the jump and return. 0-> don't do anything.
If we separate return and jump, this means we should store return value somewhere which needs re-assignment feature.
let's remove all of the return and jump and add a new keyword: `forward`. At any time `%` means distance to the end of the function as an integer number.
`forward` has two arguments: value and size.
`forward 100, % * (x<100)` if `x<100` then jump to the end of the function. If not, don't jump.
if we remove return value from forward:
```
let x := err("invalid input")
forward % * (data<0)
let y := 100
return y // x
```
if data is negative, return error else return y.
this means a binding which is not yet introduced (because of the jump), will be nothing. which might be confusing.
If we remove `%` from forward and just give it 0 or 1?
```
let x := err("invalid input")
forward (data<0)
let y := 100
return y // x
```
It is better in the sense that prevents a lot of mis-uses. But still, we are referring to `y`. The main problem is calaculations. By forward we want to eliminate doing calculations.
`forward` keyword makes sense and can be added but what about return?
```
let x := [nothing,err("invalid input")](data<0)
forward (data<0)
let y := 100
return x // y
```
This is better. we return x if it is not nothing. else y.
with forward, we jump initializing y. 
but still there is room for mis-use and also we repeat the condition twice.
```
let x := nothing
forward (data<0)
let y := 100
return x // y
```
what should this do? x is definitely nothing. Then return y. What is value of y?
Maybe like `while` we should use `nothing` definition.
proposal 1: `return 100 if x<0`
proposal 3: `(x<0) return 100` return 100 if `x<0`
proposal 4: `return` to return nothing. `return XXX` to return XXX if it is not nothing.
`return [nothing, 100](x>100)` means return 100 if `x>100`.
q: what is type of `[nothing, 100]`? it is `seq[int|nothing]`. Then the output type of the function should be `int|nothing`?
what if I have `let x := nothing, return x` should it return or no? It will be confusing.
proposal 5: `return ${data, predicate}`. q: what about this? `adder := () -> ${1,false}` What does this do?
no. it can make the code less readable and confusing.
proposal 1: `return 100 if x<0`
proposal 3: `(x<0) return 100` return 100 if `x<0`
define a re-assignable special variable which should hold result of the function. add forward to jump to the end of function.
e.g. a binding with the same name as the function:
```
let adder := (x:int, y:int) -> 
{
  adder := [0, 100](x<100)
  forward (x<100)
}
```
proposal 4: provide a strong return which returns from caller.
the nature of conditional is mutability. we are changing something. but in runtime, it will only be set once. although in the code there are multiple places where we set it.
we can define a binding which as soon as it is set, fucntion execution is finished.
as soon as it is set to something other than nothing. Like unnamed symbol
`let := 12` means return 12.
proposal 5: `let := 12` to return. How can we say, don't return if ... ?
proposal 6: use a lambda. 
proposal 1: `return 100 if x<0`
proposal 3: `(x<0) return 100` return 100 if `x<0`
can we use `(x<0)` in other places? It is just an expression.
pro `(x<0) return 10` - no new keyword. reads fluently: if ... retur ...

N - Mention compared to go, we dont have pointers.

Y - Struct literal in Go uses `field: value`.

N - Do we need a shortcut for checking something is nothing?
`!x` if x is boolean will work normally as expected.
we can say 0 and `nothing` evaluate to false boolean.
Anything else is true.
so `(x) return 100` means return 100 if x is not 0 or false or nothing.
But it might make some mistakes possible.
Let say this:
Everything is the same about true, false and 0 and 1.
`!x` applied to a variable which could be nothing means not nothing.
alternative:
`(x==nothing) return 100`
Let's don't change this behavior.
`!` works only on booleans. no shortcut for nothing.

Y - remove `let`: Like Go, let's have this syntax: `x := ....` and remove `let`.

N - nested if/else if?
```
if lower == "" 
{
				flag.Value = "true"
} else if lower == "true" || lower == "false" 
{
				flag.Value = lower
} else 
{
				return fmt.Errorf("Expecting boolean value for flag %s, not: %s", arg, value)
}
```
`flag_value := [nothing, "true"](lower = "")`
`flag_value2 := flag_value // [nothing, "lower"](lower = "true" or lower = "false")`
`(flag_value2 = nothing) return error("ERR")`
can we simplify above by removing nothing checks?
`flag_value := [nothing, "true"](lower = "")`
`flag_value2 := flag_value // [nothing, "lower"](lower = "true" or lower = "false")`
`(flag_value2 = nothing) return error("ERR")`
In this case we need nothing marker for return. 
type of `[nothing, "A"]` will be `seq[nothing|string]`.
`( x := ... ) return 1`
what does this mean? `(x) return 100` means if x is true.

Y - 
```
routers := ...
if ( condition ) routers = append(routers, ...)
```
we write:
```
routers := ...
new_routers := [routers, () -> append(routers, x)](condition)
```
now `new_routers` can be either a routers list or a lambda which returns router list.
we don't know.
we can have a function which resolves this:
`new_routers := [routers, () -> append(routers, x)](condition)`
`new_routers2 := simplify(new_routers)`
```
simplify[T] := (data: T|func()->T) -> [data(), data](@data == @T)
```
but this won't work. Because we cannot calculate the sequence. If data is T then `data()` will fail!
```
type F[T] := func()->T
simplify[T] := (data: T|F[T]) -> T
{
	result := [nothing, data](@data = @T)
	return result // F[T]{data}.0()
}
```
What does this mean? `var()`? If variable is a function pointers this has a meaning!
`var(1,2,3)` if var is a function pointer, will call the function.
So this notation is ambiguous because it has 3 meanings: call function, call function pointer or call `get`.
proposal: replace it with `<>`
`x := [1,2]<x=0>`
`var<1,2,3>` will be translated to `get(var, 1, 2, 3)`.
and it won't be ambiguous with calling function ponter.
Can it be ambiguous with int compare operator? `func(var<1>2`.
The only place we have used the `var(...)` notation is for reading from seq.
q: Can it be used with lambda maker and chain operator?
q: What about the original issue? A sequence this has both T and `()->T` lambda, how can we simplify?
proposal: `var()` means var. But this is not good because if there is a mistake, we would silently ignore it.
`var<>` can use get notation to merge these two notations.
`var<1>` will call `get(var, 1)`
`var<>` will call `get(var)` which will return var if it is not function pointer. If it is, it will invoke and return the result.
`get[T] := (x: ()->T ) -> T x()`
`get[T] := (x: T) -> T`
So:
`new_routers := [routers, () -> append(routers, x)](condition)`
`x := new_routers<>`
ambiguity: `let x := var<a>(b)>(d)`
it can be: `var< [a>(b)] > (d)`
or: `[var<a> (b)] > (d)`.
goal: to provide a mechanism to read data from sequence easily (and later for custom data like map).
goal: provide a mechanism to convert `T|()->T` to `T` easily -> this can be done with functions so don't make syntax more ambiguous. Doing it with a function is not difficult but adding a new notation for this, makes a code harder to read and may arise some real parsing ambiguity cases (unless of course if we add a completely new notation which is also not good).
so our purpose is to have a shortcut for a function call like opCall or get: `get(a,b,c)` should be written easier.
`seq1(0)` reads first element of the sequence. It is not a magic notation. It calls `get(seq1, 0)`.
but if variable is a function pointer, this can be confusing.
we can write: `0 ~ get(seq1, _)` but still it is long. this is a very common notation and will be used in many cases. So it's better if we have a notation for it.
`a//b`
`var<a>(b)>(c)`
another way to implement simplify: `data ~ callFunc(_)` it will be evaluated to `T` is data is not a function pointer.
`var[1]` -> `get(var, 1)`, `var[[1]]` -> `get(var, [1])`, `var[var[1]]` -> `get(get(var, 1))`
`var[]` -> `get(var)`
we use `[]` for generics, sequence and custom literals.
`[]` is definitely not ambiguoug because nowhere else it is usable except for empty sequence.
But if it is prefixed with an identifier or literal, `5[]` it means it is not an empty sequence literal.
`var%1` -> `get(var, 1)`
`var%(1,2)` -> `get(var, 1, 2)`
`var.(0)`
`var.[0]`
`.` is only used to fetch data from struct and nothing else. struct fields cannot start with `(` or `[`.
So maybe we can even use both of them.
`var.()` -> `invoke(var)`
`var.[]` -> `get(var)`
`var.(a,b,c)` -> `invoke(var, a, b, c)`
`var.[a,b,c])` -> `get(var, a, b, c)`
just because we can, doesn't mean we should do this.
`new_routers := [routers, () -> append(routers, x)](condition).()`
`a.(b,c,d,...)` is for the case where `a` is either T or a function pointer that returns T. In this case, if it is T this doesn't do anything. If not, it will call that function pointer. result will be of type T.
What if a has other cases? like nothing? then this notation is not useful.
What if type of a is `func()->T|func()->func()->T`. Then `a.()` will be of type `func()->T`.
This notation can be used for lazy calculation. The function can accept `int|func()->int` and by `.()` it can convert it to a real int whener it wants to.
`a.[b,c]` is customizable. it will be translated to `get(a, b, c)`. For sequence, this is done in core to fetch element at index b. `seq1.[0]`
`new_routers := [routers, () -> append(routers, x)].[condition].()`
so: proposal:
1. `a.(b,c,d)` will convert `T|func(b,c,d)->T` to `T` by calling `a` if it is a function pointer or doing nothing if it is not.
2. `a.[b,c,d]` is a syntax sugar for calling: `get(a,b,c,d)`. For sequence it is used to fetch element at a specific index.
what about `.{}`? Maybe we can use it for casting.
`int.{a}`. `func()->int.{a}`. we need to enclose both arguments. `(func()->int).{a}`
`int.{x}`, `float.{x}`, `MyInt.{x}`. So it won't be confused with struct.
`Point.{x}` converts x to Point structure.
`Point{100,200}` creates a new struct with given values.
So inside `.{}` we can only have one element. yes. the binding we want to cast.
`Type.{binding}` 
maybe we can have multiple items which does conversion for all of them in a tuple.
`mx, my, mz := MyInt.{x,y,z}`
`mx, my, mz := (func()->int).{a,b,c}`
3. `T.{b,c,d}` or `(T).{b,c,d}` where T is a type, will cast data to T.

N - Isn't casting notation ambiguous with tuple?
`Type{A}`
`StructType{100}`
I don't think so. They are compatible.
What if target cast type is not simple. We may need it. `(func()->T){a}`
1. if type to cast to, is not simple (one identifier), it should be enclosed in paren.

Y - Should we return maybe[int] when reading from int sequence?
`x := array.[0] // exit(0)`
there are 3 options:
1. throw runtime error
2. return `T|nothing`
3. return `{T, bool}`
if we use 3, and have `_,d := arr.[0]` the compiler may be able to optimize the operation.
we have similar issue when casting a union type to non-union.
in that case, we definitely have to use tuple because it is a union itself, we should not be returning another union.
if we return a struct, conditionals will change:
struct:    `[100,200].[x<100].0`
maybe int: `int.{[100,200].[x<100]}`
The code is easier to read in struct case because we can directly read the data.
The struct case is shorter (4 characters) and has less nested surrounders. The maybe case needs `int.{}` which forces us to mention the type name which is also redundant.
So either return a struct or throw runtime error.

Y - How does chain work with `.{}, .(), .[]`?
with `.()` the chain operator has it's own logic too.
`x ~ a.(_)` may result in a (if a is not function pointer) or x (if a is fp and it's input it not x) or `a(x)`.

Y - The chain operator is a bit confusing. `~` acts magically. apply X to F if it matches with it else return X.
`ivar ~ processFloat(_)` will give you `ivar` which may be unexpected and code is also not readable.
Let's handle this strange logic in a function:
`handle[T,U] := (data:T, f: func(U)->X) -> ...`
We used this initially to handle error return but now with conditional if and `//` it is not very needed.

Y - What does `T.{}` mean?
What does `var.[]` for sequence mean?
`var.()` has its own meaning.
`var.[]` will call `get(var)`.
For custom types, it is up to the developer.
But what about sequence? `get(my_array)`? 
What does it mean? It must be compatible with normal get: It return something of the same type as sequence elements.
`arr.[]` or maybe not? It is not defined in the core. 
Although user can write `get[T] := (arr: seq[T])` function and add support for it.

N - Another reason reading from array MUST give you a tuple not T|nothing:
What if the array already supports nothing?
`x := seq.[0]` if `x` is `nothing` How can I know if it was nothing inside the array and `0` is a valid index or whether `0` is invalid index and `nothing` is because it was missing?

Y - Add `with` keyword to do/while to specify defult loop output:
`with default do body(T,I) while pred(I)`

Y - Why not throw runtime error for index out of bounds?
90% of the time we are traversing the sequence
9% we use an index which should reside inside
only 1% of the time there may be an index which lies outside.
So for that 1% we need to pollute all the code with `.0`

N - Why `arr[index]` notation can be confusing.
`arr[po](1)` it is calling `arr[T]` func with `1` input or fetching an item from arr which is a fp and calling it?

N - Do we have something for pattern matching?
we have `int|float` with two functions that accept int or float. We want to call on of these functions with the input.
`x:int|float = ...`
`f1: func(int)->string`
`f2:func(float)->string`
we want to call `f1` if x is int, or f2 if x is float.
we have a `nothing|int` input. on the first line we return if it is nothing.
Rest? define a new binding and cast.
`x:int|float = ...`
`f1: func(int)->string`
`f2:func(float)->string`
we want to call `f1` if x is int, or f2 if x is float.
```
result:string := ()->
{
	(@x=@int) return f1(int.{x})
	return f2(float.{x})
}
result := (f1|f2)(x)
```
we can add a new notation: `(a|b|c)(x,y,z)` which means call either of a or b or c with input `(x,y,z)`.
whichever matches with the input. so a,b,c must be 3 functions or lambdas with 3 inputs. The one that matches with type of x,y,z will be called. x,y,z can be union types and their actual type will be used.
what if we have a function which accepts `int|float` and another which accepts `int` and input is int?
There should not be confusion about method call.
Maybe we can extend `.()` notation. On the left can be `T|func()->T`
or it can be any union with functions that have same output.
`(f1|f2).(x,y,z)`.
but `|` in this context is not usable.
we have to decide about if we allow multiple items in triple operators:
`array.[index]` only one
`type.{a,b,c}` multiple value but only one type.
`var.(1,2,3)` ? it we allow multiple items on the left `.()` will become even more complicated.
So how shall we handle function call with a union? Use a map when std is available.
```
result := [@int: fInt, @float: fFloat](@data).()
```
suppose that we have this: `x: fInt|fFloat = getData()` x is a function pointer which returns string but input can be either int or string.
if we have a union of two function pointers with same input but different output types, we can call it just like a normal function and output will be union of their output types. This makes sense but still will make reading code difficult.
Why not implement this with a function?
`invoke := (f: func()->T|func()->U)->T|U { ... }`
`x.(1)` is only valid if x is union of two types?
if x is a non-fp, `x.(1)` is `x`. else if it is fp, it will be called with the input.
x can be `int|f()->int|g()->int`? no.
x can either be `T` or `(???)->T`. We can define it using Opt type:
`type Opt[T] := T | func()->T` but the function can have some inputs.
Suppose that we have a sequence of fps. All of them have the same output but their input is different.
One takes nothing, the other takes int the third takes float. 
Now we have a `nothing|float|int` data.
`x:nothing|float|int := processData()`
`result := [(_:nothing)->1, (x: float) -> 2, (y: int) -> 3].(x)`
This means that `a.(...)` if a is function pointer will invoke it, if a is union of function pointers will invoke the appropriate function, else will evaluate to a itself. No. It will be confusing.
`result := [@nothing: (_:nothing)->1, @float: (x: float) -> 2, @int: (y: int) -> 3].[@x]`
result is a union of all possible function pointers! and hence we cannot invoke it!
We should be able to invoke a union of function pointers. then we can write:
`result := [@nothing: (_:nothing)->1, @float: (x: float) -> 2, @int: (y: int) -> 3].[@x].(x)`
so if we have:
`fp: func(nothing)->string|func(int)->string|func(float)->string := getData()`
then we can invoke fp: `fp(?)` but what should be the input? it must have nothing and int and float. because fp can be any of them.
suppose that we don't have a union, we have a struct with all possible cases or a sequence with all possible cases.
not struct. suppose that we have a sequence of functions. if we read from this seqence, it can be any of those functions.
what if we don't read from the sequence first.
we invoke the sequence with a value which is one of expected inputs
`invoke := (sq: seq[func(nothing)->string|func(int)->string|func(float)->string], input: nothing|int|float)`
invoke can call the first appropriate function pointer in the given sequence with `input`.
it will find the first element in the sq which is a fp of input equal to type of `input`.
So this can be easily done with a function.
What about `.()`?
```
tryCall := (x: T|func()->T) -> T
{ 
	(@x == @T) return T.{x}
	return (func()->T).{x}()
}
```
this is fine unless func has some input. then we will need to write tryCall for each input count (because we don't have variadic templates). Also this will be quite popular I think so better to have a notation for it.

Y - specify starting index value in while
`A := with default do body(I, T) while pred(I)`
default is the initial value for T, so type of T does not need to be `T|nothing`.
we need a default for I too. So that initial call to pred is done with that value.
`A := with default_output at default_iterator do body(I, T) while pred(I)`
in C we write:
`for(x=0;x=pred(x) != nothing) body(x, t)`
Or maybe we can say, initial call to pred will be done with the default value of I. 0 or empty.
or we can write:
`A := with default_output do body(I, T) while pred(I) while pred(nothing)`
```
n := 100
//I want result to be 0->1->2->...->99 as a linked list
result := with nothing do (x:int, lst: List[int]) -> 
{ 
  newList := append(lst, x)
  return newList
} 
while (x:int) -> 
{ 
  (x<n) return nothing
  return x+1 
}, (x: nothing) -> 0
```

N - Maybe we can use `while` predicates to simulate local function matching.
No.

Y - Instead of `do, while, with` just add a single keyword or symbol to call current function (just useful when function is anonymous lambda). then instead of:
```
filteredSum := (data: seq[int]) -> int
{
  len := length(data)
  return 
    with 0
    do (i:int, sum: int) -> sum + data.[i] * ( 1 - (data.[i] % 2) )
    while (i: int) -> 
    {
      (i<len) return i+1
      return nothing
    }, (i: nothing) -> 0
}
```
we can write:
```
calc := (index: int, sum: int)->
{
	(index>=length(data)) return sum
	return calc(index+1, sum+data.[index])
}
filteredSum := calc(0, 0)
```
Is this general enough?
`x := do body while pred`
```
x := (i: int, data: string) -> 
{
	new_i := pred(i)
	(new_i = nothing) return data
	return x(new_i, process(data))
}(with_value, default_result)
```
yes it is.
How can I read lines of a file into an array?
We can provide a function in core like this:
`fill[T] := (size: int, filler: func()->T) -> seq[T]`
worst case: read lines into a list then convert. if file is small, it won't be a big overhead.
If file is large, list is still better.
proposal: remove do, while, with and loop altogether. implement loop using recursion.
but provide helper methods like map and filter and reduce in core.
```
maxSum := (a: seq[int], b: seq[int]) -> int 
{
  return
    with 0
    do (index: {int, int}, max: int) ->
    {
      current_max := a.[index.0] + b.[index.1]
      return [max, current_max].[current_max>max]
    }
    while (index: {int, int}) -> {int, int}
    {
      return inc(index, length(a), length(b))
    }, (_: nothing) -> ${0,0}
}
```
becomes:
```
maxSum := (a: seq[int], b: seq[int]) -> int
{
	calc := (idx1: int, idx2: int, current_max: int) -> 
	{
		(idx2 >= length(b)) return current_max
		sum := a.[idx1] + b.[idx2]
		next1 := (idx1+1) % length(a)
		next2 := idx2 + (idx1+1)/length(a)
		return calc(next1, next2, max(current_max, sum))
	}
	
	return calc(0, 0, 0)
}
```
" A properly tail-call-optimized recursive function is mostly equivalent to an iterative loop at the machine code level."

Y - Break type-id into two operators: `@int` returns id of the given type.
`^union` returns type inside the union variable.
It is better to have two notations that do a simple thing rather than having a single notation that does a complex job. 
With multiple notations, there is more room form flexibility by combining them (orth).

N - Do we need named types? Can't we unify them with alias types?

Y - `:` is used in a lot of different places. can we use different notations?
```
Ok x:int
Ok type MyInt: int
${x:10, y:20}
[1:2, 3:4] -> [(1,2) (3,4)]
```
for custom literl we can use sequence literal with `(a,b,c)` format.
or what about `=:`? for struct literals: `${x=:10, y=:20}`. its ugly.
but with this notation for custom literal, we should use `[1 2 3]` for sequence.
sequence of int: `[1 2 3 4]`
custom literal: `[("UK", 65) ("US", 300) ...]`
now we have: `["UK":65, "US": 300, ...]`.
advantage of suggested literal: no re-use of `:`.
`()` notation is only used for function decl and call and conditional return.
we can write `(1,2,3)` to call a function whose name is provided by context: for custom literal, name is `get`.
`[1 2 3]` is also better because it is differentiated from generics where comma is used.
proposal:
1. sequence literal items are separated using space and not comma.
2. custom literals are enclosed in parentheses and separated by space: `[("US", 300) ("UK", 65) ("CA", 200)]`
this notation does not re-use `:` which is good. Also it is more like function call.
in this new notation we can also have custom literals with only one elements: `[(1) (2) (3)]` is different from `[1 2 3]`. The second one is a sequence but the first one will call get function.

N - More general call forwarding
`process := (x:int, y:int) -> x+y`
`process := (x:int) -> process(x,0)`
`process := (x:int) -> process(x,0)`
`draw := (Circle->Shape)`
`draw: func(Circle) := (c: Circle) -> draw(c.Shape)`

N - We use end of line as statement separator. What if a line is too long?
For example an import statement?

N - We can alias a function using normal `:=`:
`process := OtherModule::innerProcess`
For type:
`type MyInt := int` creates a new type
`type MyInt: int` defines an alias

Y - Replace `^` with another better more intuitive notation.
`@int_or_float`
`@[int]` return internal type of a union which has int.

N - 
`process := () -> int|error { ... }`
`x:=process()` 
x can be either int or an error.
`x ~ (s: error) -> { print(s) }` if x is an error, the lambda will be executed.
`(@x = @[error]) return false`
`(@x = @[error]) return error.{x}.0.code`
`r := int.{x}.0`

Y - Fibonacci with dynamic programming
```
fib := (n: int, cache: seq[int|nothing])->int
{
	(seq[n] != nothing) return int.{seq[n]}.0
	seq_final1 := set(seq, n-1, fib(n-1, cache))
	seq_final2 := set(seq_final1, n-2, fib(n-2, seq_final1))

	return seq_final2.[n-1]+seq_final2.[n-2]
}
```

Y - Change `~` behavior to accept multiple candidates as the target.
You can use `~` operator to handle union types.
`r:int := int_or_float ~ (x:int)->x ~ (y:float)->1`
But it is not appropriate.
`int_or_float ~ `?
How can we store multiple lambdas in the same place?
`a ~ (x:int)->1, (y:float)->2, (z:string)->3`
`input ~ f1, f2, f3` input will be applied against any of f1,f2,f3 which can accept type of input.
Can we replace the behavior of `~` with this?
`error_or_int ~ (x:error)->... ~ (y:int)->...` current status to handle error.
`error_or_int ~ (x:error)->..., (y:int)->...` new status. more readable less ambiguous and error-prone.
`error_or_int ~ (x:error)->10 ~ (y:int)->20` this will always returns 20 (whether input is error or int).
`error_or_int ~ (x:error)->10, (y:int)->20` this will work correctly.
How can we handle monadic error handling then?
`${input, f1(_)} ~ pipe(_, _) ~ ${_, f2(_)} ~ pipe(_,_) ~ ${_, f3(_)} ~ pipe(_,_)` 

Y - Explain `.()` better. If x is a lambda, it will be called, else nothing will happen.

Y - method dispathc: `type MyInt := int` if a function is called which has no candidate for `MyInt` the version for `int` will be called.

N - Can we include input validation built-in?
Something like phantom types but with a logic.
But this can be done with functions and phantom types.
We can define functions that accept input string and output a SafeString for example.
And the functions can accept SafeString type. Then user can either cast manually:
`process(SafeString.{data})`. which sometimes can be difficult or impossible, especially if type of `data` is not compatible with `SafeString`. Or he can use an already provided function:
`checkSafe := ...`
`process := (d: SafeString) -> { ... }`

N - How can we make it mandatory to call a function for casting?
suppose that we have `SafeString` type. User can simply write `SafeString.{data}` and bypass the whole logic for safeString, instead of calling an appropriate function which accepts string and outputs a SafeString.
option 1: when defining the type, determine name of the function for casting (from what?).
option 2: convention! For casting from underlying type to named type, call function `cast` if it exists. else normal cast.
option 3: when defining a named-type just indicate it cannot be casted with `.{}` syntax. But how is the creator function going to create it's output?
Option 1 and 2 also have a problem: infinite loop. When you call a function to do the cast, behind the scene, the function itself will need to do the casting at some point.
`data := SafeString.{unsafe_string}`
`data := makeSafe(unsafe_string)`
`makeSafe := (x: string) -> SafeString { (...) exit ...}`
Doing this behind the scene and transparently is not good. Both because of the philosophy that we have and also for infinite loop effect. User casts to SafeString, function is called, function casts input to SafeString (if everything is fine), function is called again, ... . This is not good. Resolving the infinite loop is possible but will add further rules to the language.
So we need to make it explicit to call the casting function. Maybe we can formalize the naming.
`createSafeString` to cast string to SafeString, and do the checks. User can either bypass this and do the cast manually, or call this function to do it correctly.

Y - `_` is the most confusing notation in the language. Let's limit it's scope or break it into multiple items.
1. lambda creator `process(_, _)`
2. unknown variable in assignment: `x, _ := ...`
3. function input `process(_:int)`
We can eliminate item 3 and force user to just write some argument name.
Also for 1 we have some cases:
```
1. input ~ func(_,_,_,...)
2. input ~ ${_,_,_,...}
3. input ~ Type.{_,_,...}
4. input ~ var.(_) => var.(input)
5. input ~ var.[_] => var.[input]
```
Here also we can remove 3 (type cast). Cases 4 and 5 are simply special cases for 1.
So:
proposal: remove `_` used in type casting and also used in no-named function input.
Shall we force user to write name for function output arguments?
`x, _ := process()` vs `x, isClosed := process()`?
second one: user needs to deal and pay attention to the second argument.
all uses for `_`: lambda creator, func output ignore
`var.(_)` is this a lambda creator? NO. 
`var.[_]` is a lambda creator: `process(var, _)`.
Can we say `${_,_}` is same as: `(x:int, y:int) -> ${x, y}`?
What is type of `1 ~ ${_, 10, _}`? structs with `_` must be filled immediately with `~` operator.


N - We can prevent index out of bounds error by defining sequences as cricular.
This can be easily implemented by adding a named type and re-implementing `get` function for that type.
`type CircularSeq[T] := seq[T]`
`get[T] := (c: CircularSeq[T], idx: int) -> get(seq[T].{c}, idx%len(c))`


N - Can we remove/ban function overloading?
Why do we need function overloading?
pro: overloading makes code less readable.
What about argument count? Can we overload based on argument count?
In Go almost all the functions are bound to a class or receiver. So you can easily have two functions named `process` belonging to two different receivers. 
con: we cannot have generic functions. Or maybe we can allow for this type of function overloading? But definitely we cannot have specialized generic functions.
No.

Y - Simplify `_`
`result := ${input, check1(5, _)} ~ pipe(_,_) ~ ${_, check3(1,2,_)} ~ pipe(_, _) ~ ${_, check5(8,_,1) } ~ pipe(_,_)`
`result := ${input, check1(5, _)} ~ pipe(_,_) ~ pipe(_, check3(1,2,_)) ~ pipe(_,check5(8,_,1))`
`result := (input, check1(5, _)) ~ pipe(_,_) ~ pipe(_, check3(1,2,_)) ~ pipe(_,check5(8,_,1))`
Maybe we should simply use `()` in chaining, instead of struct literal.
`output := (input1, input2, input3) ~ lambda(_,_,_)`
The we won't need `_` to create a struct literal.
`1 ~ process(_)` and `(1) ~ process(_)` are the same, but for more inputs, you must use `()`.
Banning `_` to create input in chain will make writing complex expressions harder which is a good thing.

Y - q: if there are multiple candidates for a function ponter assignment, what should happen?
```
process := (x:int)->...
process := (y: string)->...
...
g := process(_)
```
Now g is a function pointer but to which process? Can we make it a meta-function which can be redirected to any of the two candidates? It can accept either int or string, and depending on the type of the input, it will call appropriate candidate.
We can even have a lot of different functions with same name and number of inputs and one function pointer which points to all of them.
`g := (x:int|string) -> process(x)` this one is more readable.
One way to resolve the ambiguity:
`g := process(_:int)`
So: When using `_` as a lambda make, you can add `:type` to it to remove ambiguity.


N - can we assume `return` to be a special lambda which returns from parent function?
`return(10)` 
when called, it will return from current function.
it's not a normal function.

Y - `type` keyword simplification.
`type MyInt := int`
`MyInt := int`
we also have type alias:
`type A : int`
`process := (x:int) -> x+1`
we can use convention: if it starts with capital letter, its a type, else its a binding.
Do we really need type alias?
If we have `MyInt := int` and there is no method for `MyInt` calls will be automatically redirected to `int`. 
So it will have same effect as a type alias.
If it starts with capital letter or `_Capital` it is a type. else its a binding.

Y - Determine rules of assignability. What can be assigned to what?
Same type.
Literals can be assigned to bindings of different types if they match with their underlying type.
value V can be assigned to binding of type T if:
1. V is a binding or literal and type of V is identical to T
What does it mean if two types are identical?
type T1 and T2 are identical if:
1. Both are same named or unnamed type (defined in the same place in the code)
2. T1 is named and T2 is identical to T1's underlying type, or vice versa.
unnamed type: `seq[int], bool, int, {int, int}...`
For now let's just remove type alias.
What about `type` keyword?
What about import?
`import /code/std/q`
`:: := /code/std/q`
No lets keep import.
proposal:
done 1. remove type alias
2. remove `type` kyword
3. add explanation about type assignability and comparability and replacability.
4. In naming, state binding names start with lowercase.
Basically, named types are type alias unless for function dispatch where they are considered different.

Y - Why we cannot define a new type inside a function? (Line 441)
Now that types are similar to bindings, why not let people define types inside function. Why ban?
```
process := (x:int) -> 
{
	dsad()
	G := {int, int}
}
```

Y - To mark some type as to be only created by calling a function we can mark some/all of thier fields as private. So user is normally not supposed to fill it up and has to make an appropriate function call.

N - Can we have multiple bindings with the same name?
`read := (t: int)->t+1`
`read := (s: string)->12`
we should.

N - The same notation for binding and type is a bit confusing.
`data := { ... }` is this a code or struct? It's a struct. Code starts with `(...)->...`
`A := B` means A is a name for B. They can be types or lambdas.
Why not treat type like a lambda? In this case, A is name of the lambda, B is it's body and it's output will be a new type.
But it will only complicate the code. That lambda will need to create a new type (union or struct or sequence or ...). We just write that.

N - The element that comes inside a compound literal, is not orth. It's something new, does not have a type. Can we use exisintg tools like tuple literal?
`[(1,2) (3,4) ...]` What is type of `(1,2)`? Can I accept it as a function argument?
If we replace it with struct literal, will it become a normal seq?
`[${1,2} ${3,4} ...]` If structure of all of them is the same, then yes. This is a `seq[{int,int}]`
`seq[int] => [1 2 3 4]`
`seq[string] => ["A" "B" "C"]`
What if I really want to have a sequence of structs?
What happens to compound literal then?
Purpose of compound literal is to define a map (key and value).
What should be the difference between a map literal and a sequence of structs that has two elements?
`x := [(1,2) (3,4) (5,6)]` 
`x := [${1,2} ${3,4} ${5,6}]`
I think this is fine. There should be enought discrimination between these two. 
Also this is supposed to be for "literals". So everything is written in the source code statically.
To create this dynamically, you need to make appropriate calls.
What about making it simpler:
`x := [1,2 3,4 5,6]`?
`population := ["US",100 "UK",200 ...]` It's not very readable. But `()` is also confusing.
Compound literal is a shortcut for calling some methods. That's all.
`x := [(1,2) (3,4) (5,6)]`?
If you want it to be more flexible and dynamic, just call the function directly.

Y - `|` can be ambiguous:
`T1 := func()->int|nothing` is nothing for the whole type of function's output?
In these cases, the advantage of using `union` becomes more clear.
For all other types either they are simple (int) or their boundary is specified (`{...}` or `seq[...]`).
So as we try to be as simple as possible, it's better to have union boundary specified.
solution1: enclose all cases with `|`.
`T1 := func()->|int|nothing|`
`T1 := |nothing|func()->int|`
But what if they get nested?
`T1 := |nothing|func()->|int|float||`
This is not very readable.
solution2: `union`?
`T1 := func()->union[int,nothing]`
`T1 := union[nothing, func()->int]`
then we will need to modify general type filter rule: `|{Type}|`
We can write: `union[Type]`.
Then we can use `|` notation elsewhere.
Another option: When there is ambiguity, use `()`.
`T1 := func()->(int|nothing)`
`T1 := func()->int|nothing`.
`func(input)->(output)`
So when using sum types, if there is ambiguity, use `()`.
`A | B` or `(A) | (B)`
`T1 := func()->int|nothing`.
`T1 := func(int|string)->int|func(string)->string|int`
`T1 := union[func(int|string)->int,func(string)->union[string,int]]`
Another idea: define union just like struct with special notation.
`T1 := {x:int|y:float}`. Then maybe we can change `@` notation too.
`T1 := {f:func()->int|nothing,g:int}`.
`T1 := {f:func()->int|g:nothing}`.
What about enums?
`T1 := {SAT|SUN|MON}`?
`T1 := {_:SAT|_:SUN|_:MON}`?
With this notation we can have multiple ints in a union. it can be `g:int|h:int`.
It will affect function dispatch and set.
q: what will be the notation to check the current data inside union?
q: what will be notation to read current data?
q: what will be above two notations for enums?
Giving name to union cases, will make things more complex: need for notation to check them, enums, function dispatch, ...
What is we don't give it a name but use `{a|b}` notation?
`T1 := {func()->int|nothing}`.
Or:
`T1 := |func()->int,nothing|`. This is not very readable.
The only case of ambiguity is for function type with union.
`func()->{int|string}` No.
Problem is not with `|` but its with function. `func(int)->string` the output type does not have a finish marker. 
Adding a finish marker will make it difficult to write but maybe easier to read.
Like enclosing in `()` if type is not simple.
`func(int)->string`
`func(int)->(string|int)`
This makes sense and is intuitive.
proposal: For `func` type, if output is not simple one word identifier, it should be enclosed in paren.
So: `T := func(int)->string|nothing` means nothing belongs to T, not function.

Y - The general union is not orth. `|{Shape}|`. 
If this is a type, I should be able to use it whenever a type is expected, including defining a new union.
Also isn't it confusing? `|{Shape}|` if combined with other things, may mean that one option is a anon-struct with a Shape struct in it.
`|{Shape}|` How can it be mixed with other types? It shold be orth.
`A|B`
`union[A,B]` this is not very intuitive and good looking.
`|{Shape}|int`
The notation that indicates union of all types that embed type T, should not need `|`. So it can be combined with other types. So `^Shape` can denote a union type including all types that embed type Shape.
So we can easily write: `^Shape|int`.
Or it can be `<Shape>`?
or `$Shape`.
or `[Shape]`.
No these are not intuitive. 
Proposal: `^Shape` instead of `|{Shape}|`.

N - Shall we use a keyword to specify struct's type? Just like union?
No.

N - Function call: You can always use named type where underlying type is expected but not the other way around.
Assign: You must cast?

N - As an example of ambiguity: we have docker-create and docker-build commands. This is totally confusing.

N - Again: Why can't we have named args?
For function call. Maybe they have different name for their inputs.

N - We can extend usage of channels for IO too.
Reading from a file is same as reading from a channel which is connected to the file by runtime.
Writing to console is sending data to a channel.
Even for cursor location, we can have a channel. write to it to set location, read from it to get current location.
What about closing channels? Do we need `defer close(channel)`?
print is sending something to console channel.
We can explicitly indicate functions that have a side-effect by specifying the channel as their input. 
So if a function writes to console or reads from stdin, it needs a channel input.
What about a function which wants to read from a file? Who is responsible to "create" that channel?
For stdin, stdout we can pass channels to the main fucntion but we then need to pass it explicitly to all functions called, to reach the final consumer.
Other option: Have a special struct which contains IO channels. Then searching for that name will give functions that have I/O side effect. But if they don't have access to the source code and only function signature, then this won't be possible.
We can force these functions to include the channel in their output. So if a function writes to a file, it will need to return `FileChannel` as one of it's outputs.
Goal: Make it explicit that a function has side-effects (network, console, filesystem, ...)

N - `<int>` for a channel of int. `.<1>`? No. It's better to have lambdas, they are more flexible, composable and extendable.
`chn: <int> := createChannel[int]()`
`data.<chn>` send
`t := <chn>` receive.
`chn.<data>` send
`chn.<>` receive
or:
`chn.[]` call get on channel = read from channel
`chn.[data]` send = `get(chn, data)`
r/o or w/o channels?
maybe a function accepts a r/o channel but we can also send a r/w channel to it.
it makes things complicated. let's say you can cast a r/w channel to r/o channel before sending.
its good to have a syntax which includes notation for w and r and r/o channel includes only the notation for reading. w has notation for writing.
shall read/write actions be expressions or no? what should be result of read?
what happens if we read from a closed channel? How can we know if a channel is closed?
How can we mix multiple channels into a single expression, like `select`?
Notations should be nestable. So we can have a channel which can transmit int channels.
Maybe we can simply use a normal data structure like a Queu and then convert is to a channel by binding it to a thread.
There are multiple notations needed: channel, r/o, w/o, read. write, ...
I think it's better to use current notation instead of adding new ones. Just like sequence.
We can have `pipe` class, `rpipe` and `wpipe`.
For receiving data: acts like reading from sequence: `pipe.[]` which means `get(pipe)`
For sending data: It's simpler to re-use existing `.[]` notation. but the meaning of this is tied to `get` operation.
Maybe we should rename `get` to something more general, like `process`.
Then for sending data: `pipe1.[data]` can be used. result of this expression can denote some information about status of send operation.
Also upon `pipe1.[]` we can return two things: received data and a flag indicating whether the channel is still open or closed.
How can we easily and simply differentiate a read-only pipe and a write-only pipe and a bi-dir pipe?
we should be able to cast pipe to r/o or w/o pipe but not reverse.
Maybe we should call `.[]` as `opProcess` or `opBracket`.
option 1: All pipes are r/o. but upon creation, we are given a function pointer which can be used to write to the pipe. So if someones needs to write, they will need the fp too.
`myChannel, writer := createPipe()`
`myChannel, _ := createChannel()`
Maybe we can enable buffering using another function + channel.
Can we use channels with immutables? In Erlang, they use recursion and lambdas to handle data receive.
Seems we should define a lambda to be executed when data is received from a channel.
But how can we share receive part between multiple processes?
Any process which has `writer` fp, can call it to send data through the channel.
proposal: Instead of closing, processes detach from channels. When there is no attachments to channel, it is considered closed.
For `select` statement we can pass a sequence of channels to a core function to perform receive on one of them.
Erlang provides a lambda to be executec when data is received through channel. 
Problems: Notation to declare channel, make it read only, how to send, how to receive, select statement, ...
The most important issues are notations and semantics to send/receive.
We have notations for send/receive: 
Send: call given fp: `sender(100)`
Receive: `data := chnl.[]`
We need to examine some examples.
E.g. a Web server needs to run a function for each new client.
We dont need to sacrifice immutability or add any special notations. If there is a need to receive or send multiple data, the function can use recursion.
Note: A buffered channel is a mux of a sequence of normal channels. We should try to create buffered channels using normal channels + other existing notations in the language.
We should write some examples of common use cases (trivial, normal and advanced), to see if the current tools (channel, fp for send, functions and recursion) suffice for this purposes.
Examples to try:
1. Echo server
2. Web server using TCP sockets
3. A buffered channel for multiple producers and single consumer (aggregate multiple files into a stream to network)
4. Single producer, multiple consumers (even processing)
5. Multiple producer, multiple consumer (search engine, crawlers produce links which is consumed by crawlers)
6. Feed server (Single producer of price feed, multiple consumers which are pricing servers)
7. ping/pong servers
8. Multiplex channels
9. Buffered channel
10. timeout (combine special timed channel and select statement)
read from a sequence of pipes can act like select statement. But select can combine send and receive.
What should happen when we send-to/receive-from a closed channel?
Proposal: `invoke` keyword returns a channel object which can be used to send/receive data to that thread.
Proposal: we can have two pipes for each direction instead of bi-dir pipe. One pipe for send, one for receive.
Proposa: `invoke` will also accept pipe for read and write for the thread.
Proposal: Creating a channel will give us two connected channels: r/o and w/o When you write to w/o channel, data will be available on r/o channel. `rpipe`, `wpipe`
Make channels consistent and orth. Closed channel, multiple calls to close, sharing a channel with mutiple producer threads, mux-ing multiple channels, buffered channels, ....
Proposal: For buffered channel, we can simply define it as a named type and re-implement `process` function for them.

N - Send notation: `chn.[a,b,c,d]` send multiple data
Receive notation: `data := chn.[]`

N - idea: select can accept a sequence of channels. This can let developer select on a variable number of channels.
But generally we need to know whih channel was triggered.
select can accept a sequence of channels and lambdas to be executed if that channel is active.
`select [(rpipe1, (x:int)->...) (ch2, (_:int)->...) ...]`

N - We can have mutex and use them if we add a keyword like `synchronized`.
```
synchronized(value1) lambda1
```

N - Provide unlimited buffered channel (acts like a queue).
Channel can accept a storage for it's data. If `nothing` is provided, it will be a normal channel which blocks on send/receive
If we provide an int variable, it wil be a buffer with 1 cell storage.
If it is a list of ints, linked-list, it will be unlimited storage.
Or we can say all channels are buffered. If buffer size is 0, channel will block upon send/receive until the other party receives or sends.

N - Things that we need for concurrency: keyword to create a new thread, select, channels (send, receive, buffer)
`invoke, pipe, select`
receive: `data, closed := pipe.[]`
send: `result, closed := pipe.[a,b,c,d]`
You can write to `sinkpipe`, `wpipe`
You can read from `sourcepipe`, `rpipe`
`select [(rpipe1, (x:int)->...) (wpipe1, data_to_write, ()->...) ...]`
`data := select [rpipe1, wpipe1] [(x:int)->print("read data x") (wpipe1, data_to_send, ()->...) ...]`
`select ()->rpipe1.[], (data:int)->wpipe1.[data]` no. this is too general. user may write other things inside lambdas.
`data := select rpipe1, wpipe1] [(x:int)->print("read data x") (wpipe1, data_to_send, ()->...) ...]`
`select [(rpipe1, nothing) (wpipe1, data_to_write)], [(x:int)->... ()->...]`
select is a complex operation by it's nature: read or write, multiple channels, multiple data, multiple actions.
Can we simplify it?
`select [(rpipe1, lambda1)], [(wpipe1, data_to_write, lambda)], [...]`
select can accept a variable number of compound literals. we can even combine them into a 2d literal:
`select [ [(rpipe1, lambda1)] [(wpipe1, data_to_write, lambda)] [...]]` a sequence of compound literals
`select [ pipe1_data pipe2_data pipe3_data ...]`
`pipei_data = (wpip1, data_to_write, lambda) or (rpip2, lambda)`
or maybe we can use structs.
`select [ pipe1_struct pipe2_struct ...]`
`select [ ${rpipe1, lambda1} ${wpipe1, data_to_write, lambda} ${...} ]`
Why not define a new syntax to make it simpler and easier to read? (But keep it general).
Adding new syntax like `a: code, b: code` is good but will make it less extendable.
If we want to select on a variable number of channels, the `a:b` syntax won't work.
But using a compound literal will support that case. That's why re-using existing mechanisms is better.
We can re-use `.()` notation for seq to implement select.
`[ [(rpipe1, lambda1)] [(wpipe1, data_to_write, lambda)].()` select one of possible items.
Because sequence is not a func. `seq` and `func` are two distinct types.
pro: no need to add new keyword.
pro: we use existing mechanisms.
con: it might be a bit confusing.
Technically we can have compound literals with variable number of elements:
`[(1,2) (3,4,5)]`. Because, after all, it is a set of function calls.
`[ (rpipe1, lambda1) (wpipe1, data_to_write, lambda)]`

N - We can pass a sequence to the function to create channels but it will imply the sequence will be mutated!
The storage must be fully hidden from the code. 
`rpipe, wpipe := createPipe[int]()`
`rpipe, wpipe := createPipe[int](100)` buffer size
We can easily separate r/o and w/o pipes.
we have `process := (r: rpipe) -> ...` so we can write: `x := rpipe1.[]` and only this way
we have `process := (w: wpipe, d: data) -> ...` so we can write: `x := wpipe.[data]`

N - Other suggested names for channel: port, pipe
We must have channel/pipe ready for IO, because of mutable nature of them.
Can we implement all ex-res as channels?
non-threading candidates for channels: stdout, stdin, file, network, ...
`Stdin := Input<Std>`
`Stdin := ReadOnlyChannel<char>`
When writing to a channel, we should be able to write a single data item or a sequence. But this is impl-related.
All of ex-res have a communication nature, so they fit with channel model. They might be shared across threads, which also fits with usage of channels. They embed a mutable state, also fitting with channels.
You can dispose an channel or let it open. When it's no longer referenced, it will be GCd.
But we have 3 arguments here: Pipe(r/w), type (thread, file, network, io) and data (char, string, int, ...).
Can we merge and unify them?
`stdout := CreatePipe<Write, Std, char>()`
`socket1 := CreatePipe<Write, Socket, char>()`
`Dir := Write | Read`
`CreatePipe[Dir, Kind, Value] := () -> pipe[Dir, Kind, Value] ...`
`CreatePipe[Kind, Value] := () -> {rpipe[Kind, Value], rpipe[Kind, Value]}`
`wpipe[Type, Value] := {...}`
`StdOut[Value] := wpipe[StdIO, Value]`
We can define two other primitive types: `wpipe` and `rpipe`.
What does `wpipe[Type, Value]` mean? `Value` is type of data we want to read from or write to.
r and w pipes are related most of the time. So it's better to have a single API which gives out both of them.
You can just ignore the one you don't need. 
But what does `Type` mean? We need a mechanism to know this read-only pipe which you can read only `int` from, where is it connected to? Is it reading from a file? or network? ...
This can be thought of like a stream reader/writer. `StreamReader`, `StreamWriter`. We don't care what is it. We just read or write. Is that possible? Does it make sense?
We have a `StreamWriter[char]` binding. We can write using `x.[a]` notation. It will write to somewhere. Maybe a file or a socket or standard output. We don't care.
There are different functions to create different types of Stream. So `Type` will be embedded inside different functions.
`OpenFile[T] := (s: String) -> {PipeWriter[T], PipeReader[T]}`
`OpenFileReadOnly[T] := (s: String) -> PipeReader[T]`
`OpenSocket[T] := (host: string) -> {PipeWriter[T], PipeReader[T]}`
What if I have a function which accepts a `PipeReader` but I expect it to be reading from a file? This cannot be decoded into type. And as we don't have polymorphism, we cannot pass `FileReader` when a `PipeReader` is expected. Except using the general union notation:
`process := (pipe: |{PipeReader}|)->...`
input to process can be any struct type that embeds `PipeReader`.
Or we can have all of them of the same type: `PipeReader` but have a tag field which denotes type of underlying 

N - We can combine pipes. e.g. zip/unzip or digest. 
For example we have `StreamWriter`. We can also have another `StreamWriter` that wraps the first one and outputs hash.
How can we model this? Is this a StreamWriter + lambda to call for reading?
We can provide a lambda when creating a new `StreamWriter` which will be called when writing (same for reading).
Or we can separate them. We can have normal StreamWriters crated to write to a file or socket or ... .
And we can have lambda-based StreamWriters. But then they will need to embed another StreamWriter.
We write to container, it will process data and write to the internal sw.
But then it won't be transparent.
It's better if we can create a streamwriter with two additional arguments: Parent writer and lambda.
So when I write to sw, it will invoke lambda, which will decide to write to parent or do something else.
How can this work with buffered channels?
You can create channel other using core calls or based on another channel + lambda.
for ReadOnlyChannel, any read operation will call the lambda.
for WriteOnlyChannel, any write, will call the lambda.
Lambda then will decide to process, store, ignore or redirect the operation to the internal channel.
And the channel parameter can be anything as long as the lambda knows it.
`ReadOnlyChannel[T] := {inner: ReadOnlyChannel[T]|nothing, lambda: nothing|func(T)->bool}`
`read[T] := (channel: ReadOnlyChannel[T])->T|nothing { ... }`
Or maybe we can separate them! A channel that just reads, A lambda that just does some calculations.
This won't be as transparent as the original solution but would be definitely simpler.
So if a function expects a ChannelReader, that function needs to be modified to expect a lambda. And that lambda will have a channel reader and will apply it's own logic.
But this is not extensible. Suppose that there is a function that we cannot change.
This function expects a ChannelReader to read some data from a file.
Now that file is compressed. I cannot send a lambda to the function to include the channel reader and unzip the data on the fly because that function does not accept a lambda.
Can we make ChannelReader a lambda? Then we can easily impersonate a channel reader by writing our own lambda.
ChannelWriter will be a lambda too.
pro: we no longer need `rpipe` and `wpipe`.
pro: It is more flexible and orth because now we are working with lambdas. So for example digest or unzip is possible.
Of course the inner most lambda is created by core and has access to the thread-safe synchronized mutable buffered storage.
So when we create a channel, we just receive two lambdas: writer and reader.
`PipeReader[T] := func()->T`
`PipeWriter[T] := func(T)->T`
`openSocket[T] := (host: string) -> {PipeWriter[T], PipeReader[T]}`
`writer, reader := openSocket(...)`
pro: we already have composability because we use functions. 
pro: No need to create a new concept.
q: How does this work with buffered channels?
q: How does this work with ex-res?
Buffered channel means the channel have it's own storage. When writing it will be written to that storage. When reading it will be read from that storage.
This is not possible in dot. So buffered channels must be provided by core (e.g. thread communication, socket, ...).
You can write your custom lambdas on top of an existing channel.
`DigestPipeWriter[T] := func(T)->T`
`createDigestPipeWriter[T] := (original: PipeWriter[T])->DigestPipeWriter[T] { return (input: T)->write(original, input)...}`
So:
Pipe is something user cannot see. He works with writer and reader which are lambdas.
You can compose pipes by composing their lambdas.
When you create a pipe, you are given two lambdas (or maybe one), to read/write.
select: can be implemented by applying `.()` on a sequence.
So: `A.()` if A is a lambda will invoke it, if it is a sequence, will do select, otherwise will return `A` itself.
This is a bit confusing. We can implement select using a core function but it should be built-in.
Maybe adding a new operator?
`seq1.<>`?
Can't we use existing tools that we have?
select: try to read/write on some channels -> try to invoke some lambdas. 
What happens if I have a lambda which wraps a normal channel. How can I know if it will block? How can core know? How can `select` know? 
If it is just a normal lambda, How is select supposed to know if it will block upon read/write? How can we do a peek/tryRead/tryWrite?
One solution: Each read/write can return `nothing` indicating that it cannot do that action.
We should be able to invoke read/write in two modes: sync, async.
In normal mode it will block if it cannot do the action.
In peek mode, it will return immediately with `nothing` if it cannot perform the action.
Select needs these lambdas prepared to be invoked in peek mode. 
So, we have a list of lambdas. The first one that does not return `nothing` will be invoked. Else we will be blocked.
So we have a sequence of lambdas. Their input can be empty or T, output can be nothing or something else.
`[lambda1 lambda2 lambda3].<>`
Actually, those lambdas have no input. Because their input is already provided.
`select := (x: seq[func()->T|nothing])->...`
We simply call `select` function from core with a sequence of lambdas. BUT, for reading, we also need a lambda to process it.
We will need a sequence of `{lambda1, lambda2}`. l1 is the action. l2 is the processor of the result.
For read, it will process read data.
For write, it will process written data (mostly dummy, but to make it consistent).
`select := (x: seq[{func()->T|nothing, func(T)->nothing}])->...`
Idea: in addition to two lambdas, we can return a Channel ID which can be used in other operations like check if channel is ready. But then can't we use that ID for read/write? IT we can, the we cannot have r/o or w/o channels. If we cannot, it will be a bit unintuitive.
We can simulate default in select, with a special channel which is always ready for read or write.
Can't we simulate select with a special channel?
Like a channel where you send it will send to any of available channels. No. We can combine read and write in a select.
select needs to peek a lambda for read/write, if it is ready, locks it, then does the operation.
peek and lock are internal low-level operations which cannot be ?
Maybe instead of peek we can have a bool flag which indicates whether the operation should block or no.
Select will call it with `block=false` so it will be notified instantly whether action is performed.
But in this case, select can even be called with any other non-related function as long as they support this protocol. But there is not a protocol for block. It is provided by caller of select. It provides a lambda which given an input, will call appropriate function with `block=false`, select will process call result and if it is `nothing` means action is not successfull.
`select := (x: seq[{func()->T|nothing, func(T)->nothing}])->...`
Another solution: calback, the first channel that is ready for send/receive will call a code block to do the operation.
The internal OS call, needs a set of file descriptors. So we will definitely need something other than lambda.
If we only use a channel-id, then how are we going to mix channels? Maybe we shouldn't.
Maybe we can give out two channel-ids. One for read and one for write.
`readable, writeable := createChannel[int]...`
`data := readable.[]`
`writeable.[output_data]`
So `createChannel` will give out, a struct including a `OutChannel` and `InChannel` types. 
How can we combine them? Like a channel that reads from a file and outputs uncompressed data?
Maybe upon creation, we can also attach two lambdas: One to execute before writing, one to execute after reading.
`reader, writer := createFileChannel[int]("/tmp/a.txt", read_lambda, write_lambda)`
But if we are going to have separate reader and writer, why not have read/write lambdas?
But then what can select do? Maybe runtime can keep a mapping between these lambdas and their internal channel.
But having lambdas without ability to mix them with other lambdas is not very useful. Maybe we can mix lambda and channel-id. So we pass channel-id to the lambda. So we have them both now. And we can enclose lambda inside another lambda, as long as it behaves as expected: has an input for channel-id. So when creating a channel, we will have 4 outputs: two lambdas for read and write and two ids for read/write operations. It's a bit too much!
We can make it 3: channel-id (of type Channel), writer lambda, reader lambda.
```
ChannelId[T] := 
ChannelReader[T] := func(ChannelId[T])->T
ChannelWriter[T] := func(ChannelId[T],T)->T
createFileChannel[T] := (path: string) -> {ChannelId[T], ChannelReader[T], ChannelWriter[T]} { ... }
id, r, w := createFileChannel("/tmp/a.log")
[(id, r) (id2, w, x)].<> ???
```
We can introduce a new syntax, but then we won't be able to run it for unlimited number of channels. Maybe we can create a special channel which will acts just as a mux over a variable number of channels. Readin from it, will read from any of available channels. writing to it will? It can only be read from. When writing, you have to specify which channel to write to.
```
result := select
	ch1.[], (x:int) -> process(x),
	ch2.[y] 
```
`index := [(readable, lambda) (writeable, data)].<>`
What if `select` becomes just a normal function in core?
What should be it's input? Using struct here is not really intuitive and elegant.
Maybe we need a new notation. Maybe we need a new data structure and methods to process a literal to create that structure.
`SendDS[T] := {c: ChannelWriter, x: T}`
`ReceiveDS[T] := {c: ChannelReader, f: func(T)->T}`
`SelectDS := { data: seq[SendDS[T]|ReceiveDS[T]] }`
But each send or receive can have it's own type!
solution 1: variadic templates
solution 2: special notation
What about this notation?
`result := [ch1|ch2|ch3].[]` to read from a sequence of channels or block
`result := [ch1|ch2|ch3].[data]` to write to any of channels which is ready to write
`result, index := ch1.[] | ch2.[] | ch3.[data] | ch4.[data]`
`result, index := rch_sequence.[]`
`result, index := wch_sequence.[data]` try to send `data` over the first ready channel
`result, index := [ch1 ch2 ch3].[]`
`result, index := [wch1 wch2 wch3].[data]`
`result, index := ch1.[] ^ ch2.[] ^ ch3.[data] ^ ch4.[data2]`
`result, index := [ch1 ch2].[] ^ [ch3 ch4].[data1 data2]`
or add a new operator to make it more readable and explicit:
`result, index := [ch1 ch2].<> ^ [ch3 ch4].<data1 data2>`
`result, index := [rch1 rch2 wch3 wch4].<nothing nothing data1 data2>`
But if we add a totally new notation, then we won't be able to run select on a sequence.
We want to be able to run select on sequence of channel reader or writer or both.
`result, index := [rch1 rch2 wch3 wch4].<nothing nothing data1 data2>`
Seems that select is not compatible with functional approach.
`result, index := [rch1 rch2 (wch3, data1) (wch4, data2)].<>`
`result := [(channel1, d1) (channel2,d2) (channel3,d3)].<>`
```
result, index := <
data1 := chan1.[]
data2 := chan2.[]
result3 := chan3.[d1]
result4 := chan4.[d2]
>
```
```
result, index := [
chan1.[]
chan2.[]
chan3.[d1]
chan4.[d2]
]
```
There should be a mechanism to invoke channel operations in non-blocking way.
Above sample includes expressions. Unless we change semantics of sequence, it's elements are expected to be evaluated on the spot.
```
result, index := [
() -> chan1.[]
() -> chan2.[]
(data: int) -> chan3.[data]
(data: int) -> chan4.[data]
].(d1, d2)
```
This one is better, but can we put anything inside those lambdas?
`result, index := [ch1 ch2 ch3 ch4].<(idx: int, data: int|nothing) -> {...}>`
```
result, index := [
() -> chan1.[]
() -> chan2.[]
chan3.[_]
chan4.[_]
].(d1, d2)
``` 
What if we can separate read and writes?
```
result, index := [chan1 chan2].[]
result2, index2 := [chan3 chan4].[data]
``` 
the `process` function for a sequence of channels, is implemented in core and implements select statement. It should be either a sequence of r/o or w/o channels.
We can unify read and write by using transducers. We need to have a channel and a lambda. When channel is ready, the lambda will be executed. That's all.
```
result, index := [
	(rchan1, () -> rchan1.[])
	(rchan2, () -> rchan2.[])
	(wchan1, () -> wchan1.[data1])
	(wchan2, () -> wchan2.[data2])
].()
```
When any of channels are ready, the corresponding lambda will be executed.
Result of the lambda + index of the channel in the sequence which is activated, will be returned.
This is simpler, a unified structure: channel + lambda. Can be extended to a variable number of channels, because it is a sequence.
`.()` does not make sense here. Unless we combine it with something else that returns the lambda.
```
result := [
	(rchan1, () -> rchan1.[])
	(rchan2, () -> rchan2.[])
	(wchan1, () -> wchan1.[data1])
	(wchan2, () -> wchan2.[data2])
] ~ findReadyChannel(_).()
```
`findReadyChannel` will return the lambda for the channel which is ready.
```
result := [
	(rchan1, () -> rchan1.[])
	(rchan2, () -> rchan2.[])
	(wchan1, () -> wchan1.[data1])
	(wchan2, () -> wchan2.[data2])
].[].()
```
`.[]` on a sequence of channel and lambdas, will return lambda for the channel which is ready.
Because of using `.()` you can use an expression (non-lambda) instead of lambda. But it won't make sense because you need to do the read/write operation asap.
q: Does this conflict with future plans for map and compound literals?
q: How can we embed code for a channel? Its part of the API that cretes that channel.
q: How can we have a dynamic/variable-sized sequence like above example?
The syntax above is for compound literal. What if we don't want to use a literal?
solution 1: Using two sequences. Problem: channel and it's lambda will be far from each other, visually.
solution 2: Struct
```
result := [
	${rchan1, () -> rchan1.[]}
	${rchan2, () -> rchan2.[]}
	${wchan1, () -> wchan1.[data1]}
	${wchan2, () -> wchan2.[data2]}
].[].()
```
Type of the first expression is: `Select[T] := seq[{rchan|wchan, func()->T}]`.
If there are different functions with different outputs, `T` should become union of those types.
`[ ${1, "A"} ]` and 
`[ (1, "A") ]` 
are different.
You can still use compound literal model with variable sized data. Just call appropriate methods.
So we have:
`x := [ (ch1, lambda1) (ch2, lambda2) ]`
will translate to these calls:
`x0 := set(nothing, ch1, lambda1)`
`x := set(x0, ch2, lambda2)`
And what would be signature of `set` and type of `x` here?
`set[T] := (x: nothing, ch: ChannelReader[T]|ChannelWriter[T], lambda: func()->T) -> { ... }`
`set[T,S] := (x: Chn[S], ch: ChannelReader[T]|ChannelWriter[T], lambda: func()->T) -> { ... }`
X can be a linked-list or any other suitable data structure.
Problems:
1. Type of input is `ChannelReader` so we don't have (And can't) anything to differentiate between network or file or ... channel. So, how should they be organized?
2. What will be type of the data structure that hold above compound literal?
They must be different, at least internally. A file channel and a socket are different. So, either we should make it another template argument, or use `^T` notation.
`set[K, T, S] := (x: DStr[S], ch: ChannelReader[K, T]|ChannelWriter[T], lambda: func()->T) -> { ... }`
In select input, we have a list of channels (of kind K and type T), with lambdas with no input and output of type T.
So we have two template argument per each element. We can have a general type T and another function with output S and assume T will be some kind of channel but it is not correct.
Generally, we need to be able to say the input for this function must be a channel of type reader, and it should be able to accept r/o channels of any type and kinds (socket-int-reader or file-string-reader).
So, if sequence has 4 rows, we have 8 types. What shall be the data structure for it?
```
DStr[K,T, K2, T2] := { ch: ChannelReader[K,T]|ChannelWriter[K,T], lambda: func()->T, next: DStr[K2,T2] }
```
The compound literal is used for similar-typed literals like map. But if type of each item changes, its hard.
Solution: From the beginning, specify type using union.
`DStr[K,T] := { ch: ChannelReader[K,T]|ChannelWriter[K,T], lambda: func()->T }`
`DStr[K,T] := { ch: ChannelReader[_,T], lambda: func()->T }`
`Chr[T] := ChannelReader[T] | ChannelWriter[T]`
`DStr[T1, T2, T3] := { ch: Chr[T1]|Chr[T2]|Chr[T3], lambda: func()->T1|T2|T3 }` But here we cannot enforce that lambda for chr-t1 should output t1 not t2 or t3.
`Chr[T] := { c: ChannelReader[T]|ChannelWriter[T], lambda: func()->T }`
`DStr[T1, T2, T3] := {Chr[T1], Chr[T2], Chr[T3] }`
`DStr[T1, T2, T3] := seq[Chr[T1]|Chr[T2]|Chr[T3]]`
`select := (cases: seq[Chr[_]])->???`
It seems that `select` should be handled in the syntax level without using a normal function.
So user just writes `[(ch1, l1) (ch2, l2)].[].()` and core will handle it to generate data and do the call.
But what about the case when we have a variable size/dynamic input? Just specify it's type explicitly:
```
cases: seq[Chr[T1]|Chr[T2]|Chr[T3]] := processCases()
cases.[].()
```
But then `.[]` becomes confusing. It is supposed to read something.
solution 1: keep this. use notation `.[]` for sequences to act as select. But doesn't `.[]` have other usages?
Normally we write `.[0]` to get an element from the array.
solution 2: Add a new notation.
We can also write: `cases.[]()` If all items are lambdas.
Anyway, calling `.[]` on a sequence whose elements are of type `AltCase[T]` will invoke core select function.
`AltCase[T] := { c: ChannelReader[T]|ChannelWriter[T], lambda: func()->T }`
`cases: seq[AltCase[T1]|AltCase[T2]|AltCase[T3]] := processCases()`
```
result := [
	AltCase[int]{rchan1, () -> rchan1.[]}
	AltCase[string]{rchan2, () -> rchan2.[]}
	AltCase[int]{wchan1, () -> wchan1.[data1]}
	AltCase[float]{wchan2, () -> wchan2.[data2]}
].[].()
```
So:
```
stdout := createStdOut()
```
Why include type in channel type? We have a channel we can read from. You can read anything from it. int or string or ... . Just like stdout where we can print anything to it. By removing T from channel type, the select data structure becomes simpler, And we won't be able to use `.[]` because it doesn't specify output type.
```
stdout := createStdOut(lambda_processor, buffer_size)
stdout.["A"]
stdout.[12]
stdout.[myF_float]
stdin := createStdIn(lambda_processor, buffer_size)
x: int := stdin.[int][]
x: string := stdin.[string][]
```
Then any channel is basically a tag (r/o or w/o), internal file descriptor, a lambda. 
But what should lambda do? If it doesn't know it's input type?
The lambda, should be generic. It should be based on type T, or it should be specialized for some types. If we read/write some type which is not supported by that lambda, there will be compiler error.
But it's always better to be strong typed. Just like a function's input which has a specific input type, channels should have a specific type.
For stdout, output type is normally string where we convert everything else to string before sending to the channel.
```
AltCase[T] := { c: ChannelReader[T]|ChannelWriter[T], lambda: func()->T }

result := [
	AltCase[int]{rchan1, () -> rchan1.[]}
	AltCase[string]{rchan2, () -> rchan2.[]}
	AltCase[int]{wchan1, () -> wchan1.[data1]}
	AltCase[float]{wchan2, () -> wchan2.[data2]}
].[].()
#or
result := [ 
	(rchan1, ()->rchan1.[]) (rchan2, ()->rchan2.[]) (wchan1, ()->wchan1.[data1]) (wchan2, ()->wchan2.[data2]) 
].[].()

std_reader, std_writer := createStd[string]()
stdout_reader.[]
stdout_wrter.["Hello"]
```
But we cannot separate the part that finds the available channel and the part that runs the corresponding lambda.
This should be an atomic thing. Find channel and run corresponding lambda.
Maybe we can map `.[]` to do this.
If the method is run on a sequence of AltCases, it will act as a select.

N - When creating a channel, in Clojure you can also provide a transducer.

N - Instead of closing, processes detach from channels. When there is no attachments to channel, it is considered closed.
Make channels consistent and orth. Closed channel, multiple calls to close, sharing a channel with mutiple producer threads, mux-ing multiple channels, buffered channels, ....
Provide unlimited buffered channel (acts like a queue).
How do we manage different channel types? Note that for select and AltCase, we need the same data type for all R-Channels and W-Channels.

N - Can we mix select with custom conditions?

N - If a channel has multiple senders and multiple receivers, how can we indicate that senders are finished?
How can we indicate that receivers are not reading anymore?
we can simply stop running select on them. 
Then we can have a core function to return number of senders waiting or receivers waiting on that channel. But this number can be zero when a s/r is doing some temp process. 
keeping track of senders/receivers for a channel is not good. It's dynamic tool. Anytime any thread can read/write to/from it. 
If channel is closed, receiver will know that there is no more data.

N - Summary:
```
AltCase[T] := { c: ChannelReader[T]|ChannelWriter[T], lambda: func()->T }

;The corresponding channel will be acquired during execution of appropriate lambda.
cases: seq[AltCase[int]|AltCase[string]|AltCase[float]] := [
	AltCase[int]{rchan1, () -> rchan1.[]}
	AltCase[string]{rchan2, () -> rchan2.[]}
	AltCase[int]{wchan1, () -> wchan1.[data1]}
	AltCase[float]{wchan2, () -> wchan2.[data2]}
]
result, index := cases.[]
#or, compiler will automatically generate appropriate cases here and set type for base sequence
result, index := [ 
	(rchan1) (rchan2) (wchan1, data1) (wchan2, data2) 
].[]
#type of result is int|string|float

std_reader, std_writer := createStd[string]()
data := std_reader.[]
std_write.["Hello"]

net_reader, net_writer := createSocket[int](host, port, settings, (x:int)->x+1)
data := net_reader.[]
net_writer.[10]
```

N - What about adding a new syntax for select?
```
data, index := select rch1, rch2, wch1:data1, wch2:data2
data, index := [rchan1 rchan2 wchan1 wchan2].[(2 data1) (3 data2)]
```
What if we want to also check for another conditions, in addition to channel being ready?
What if we say `.[]` and `.[x]` can be done in a non-blocking way.
```
data := rch.[] #will block if data is not ready
data := NonBlocking.{rch}.[] #if data is not ready, will return nothing
wch.[data] #will block if there is no one to read
NonBlocking.{wch}.[data] #will not block
```
If we combine this with recursive function, we can implement select as a function.
`select := (cases: seq[rch|{wch[T], T}])->{?}`
But what will be the input type of that function? we can define a select with 1, 2, 3 or 4 type of input. 
or maybe simply add `||` operator?
`data, index := rch1.[] || rch2.[] || wch3.[data1] || wch4.[data2]`
`data, index := [rch1 rch2].[] || [wch3 wch4].[data]`
I really prefer not to add a new syntax/notation and just use existing notations: `.[]`, `.()`, functions.
Suppose that you are reading/write files and want to check which file is available for read/write:
`data, index := [rfile1 rfile2 wfile3 wfile4].[(2 data1) (3 data2)]`
We can split it into read and write channels:
`data, index := [rfile1 rfile2].[]`
`data, index := [wfile3 wfile4].[data1 data2]`
How can we combine them?
`data, index := [rfile1 rfile2] /// [wfile3 wfile4].[data1 data2]`
Another solution: Use a try-write optin.
`x := tryWrite(wch1, data1)`
`y := tryWrite(wch2, data2)`
`data, index := [rch1 rch2 x y].[]`
What about this as a shortcut to create appropriate ds?
`data, index := [wch1 wch2].[data1 data2].[rch1 rch2].[]`
or
`data, index := [rch1 rch2].[wch1 wch2].[data1 data2].[]`
`[rch1 rch2].[wch1 wch2]` will create a data structure to hold these call it A
`A.[data1 data2]` will append data1 and data2 to writer channels.
`[wch1 wch2].[data1 data2]` will create a data structure to hold these writer and their data, call it A.
`A.[rch1 rch2]` appends writers to the data structure
So this data structure will be something like:
`DS := {writers: seq[CW[int]|CW[float]|CW[string]], writeData: seq[int|float|string], readers: seq[CR[int]|CR[string]}`
A `.[]` call on DS will invoke select and return data + index.
A `.[rch1 rch2 rch3 ...]` will update list of readers
A `.[wch1 wch2 wch3...]` will update list of writers
A `.[other1 other2 other3]` will update list of data to write.
Of course number and type of data to write must match with writers and their types.
`.[]` will invoke some core function which is unnamed.
A call to `.[]` on any DS of the format above will act as select.
How can we define the general data type for DS? Above example is only for int, float and string.
`DS[T, U, V] := {writers: seq[CW[T]|CW[U]|CW[V]], writeData: seq[T|U|V], readers: seq[CR[T]|CR[U]|CR[V]]}`
Maybe support for variadic templates solves this but it would add complexity.
We just define DS with 1, 2, ..., 6 different data types. It would be enough.
What if we have channels that send channels? Then a `.[wch1 wch2]` can be either sender channels or the data to be sent.
So the order should be: add readers, add writers, add write data. 
Or: add writers, add write data, add readers.
After DS is created and before `.[]` we can ammend it with adding readers or writer+data.
If what is being added to DS is channel-reader then its for reading.
If it's channel-writer it for writing and the data to write will/must come next (it can be int, string, channel-reader or writer or anything).
To prevent issue with index and cases where DS is created in multiple steps (reader, writer+data, reader, reader, writer+data, writer+data), instead of returning index, we return the actual channel which is being triggered.
`data, channel := [rch1 rch2].[wch1 wch2].[data1 data2].[]`

N - Name? channel, pipe, port, InPort, OutPort, 
We can use phantom type to separate read and write.
```
ReadOnly :=
WriteOnly := 
Channel := { id: int, buffer_size: int }
ReadOnlyChannel := { Channel, reader_lambda}
WriteOnlyChannel := Channel, writer_lambda}
FileWriterChannel := WriteOnlyChannel
FileReaderChannel := ReadOnlyChannel
openFileReader := () -> FileReaderChannel ...
```
port is confusing. 
Channel is very clear but a bit ong.
`invoke`?
What about `((...))` to make a function call in parallel?
or `(|...|)`.
or `&` prefix.
`process(10)` normal execution
`&process(10)` run in parallel
How does it mix with chain operator?
`(1) ~ process(_)`
What if we parallel run a function which is chained to another function?
`(1) ~ &process(_) ~ writeOutput(_)`
Here `process(1)` will be executed in parallel and when finished, it's output will be sent to writeOutput function.
`&process(1)`
`writeOutput(?)`
No. It's not good. Because `&process` need to return quickly (this is supposed to be in parallel).
What if that function has an input? It mustn't. Because no one will be there to capture it.
So it cannot have any output. If it does, just wrap it in a lambda: `()->{process(10) , return nothing}`.
So return type must be nothing.
If we use `&` it won't be composable with chain operator.
We an start a line with this keyword which will execute that line in parallel.
`invoke process(10)`
`invoke (x:int)->process(100+x)(12)`
What about `.()`? It can mean call in parallel.
`process.(10)` run this function call in parallel.
`(10) ~ process.(_)`
parallel execution is not supposed to return anything. If it does, we need to wait for it to finish to have access to that data.
`(x:int)->process(100+x).(12)`
`data := process.(10)`
We cannot use data until after process is finished. 
`|| 1 ~ process(_) ~ data(_) ~ write (_)`
Any line starting with `||` means that line will be evaluated in parallel. You cannot use it with bindings.
`|| expression`
Another option: You can capture output of a parallel execution, but as soon as you try to read it, you will be blocked until that execution is finished.
`x := process.(10)`
`write(x)`
No. This will make impl more complex and decrease performance.
`|| process(20)`
`invoke process(20)`
`process.(20)` This is simple and elegant but what happens to optional call?
`process|20|` generally `|` might be confusing with union data type.
If we say that `.()` call cannot be chained to another call? Why? It is possible. We want to define a process where we want to do somethings after task A is finished. This can be done with channels too but forbidding it here, does not make sense.
`process.(10) ~ write(_)`
should be the same as:
`x := process.(10)`
`write(x)` here code will be blocked, until process is finished.
What about this?
any binding assignment is valid but code will be blocked on the first case of refering to that binding, until task is finished.
`data := process.(10) ~ write(_)`
code will start to run in parallel and when finished, output will be sent to write. Result of write will be written to `data`. But if in any following line, `data` is used, code will block.
`data := process.(10) ~ write(_)`
is same as:
`data := () -> { return process.(10) ~ write(_) }()`
So basically, any line that contains `.()` will be converted to a lambda which will return result of it's last expression.
Compiler will check future references to `data` and if there is any, will place a mutex waiting for the task to finish.
`.()` is not very intuitive.
what about using a core function? It would be more readable to have a syntax for this.
`data := process.(10) ~ write.(_)`. This will start process in parallel, wait for it's finish, then feed it's output to write in parallel?
`:()`? `:` can imply parallel. No.
`.()` is not good because parallelism should be explicitly readable in the code.
`_ :=| process(10)`
`data :== process(10)`. This is better and easier to type.
`data ::= process(10)`
`data :=: process(10)`
So `a :== expression` means evaluate expression in another thread.

N - Keyword to create new green thread: `&`?

N - What happens if we close/dispose a channel twice? If we read/write from a closed channel?
multiple close should work without error.
read/write will return data+bool which indicates whether channel is closed.
solution: channe-r and w each have a subscriber count. Upon first send or receive, it will be increased if the thread-id is new. It will be decreased with each call to close or dispose. When number is 0 then channel is considered completely closed.
And any action on it will return `nothing, false`.
What if sender is finished by receiver has not started yet? There should be a way to just signal that I want to subscribe for this channel. Like `subscribe(rch)` or `subscribe(wch)`. And, of course they are idempotent.
A buffered channel is closed when there is no subscribed sender and the buffer is empty.
Sending to a closed channel (which has no receivers or all receivers have closed the channel), means sending data to channel after calling close or dispose on it. This will fail with runtime error.
Reading from closed channel (Where there is no sender and buffer is empty) will return 0 + false (indicating channel is closed). As long as the buffered channel has data, even if all senders have closed the channel, receivers can receive data without a problem.

N - Is it possible to have two references to the same channel?
`data, channel := select operation`.
I think so. When we send a struct to a function, it has a refernce to it + the caller has another reference.
So it should be fine.

N - Can we combine `:==` and select?
`data, channel :== [wch1 wch2].[data1 data2].[rch1 rch2].[]`
should be possible.

N - 
name? types? (file, socket, console, general)
```
chan := { id: int, buffer_size: int }
rchan := { chan, reader_lambda }
wchan := { chan, writer_lambda }
FileWriterChannel := WChannel
```
If we define `chan` as a built-in type, then we cannot have `^???` type specifier.
option 1: define two built-in types: `wchan` and `rchan`. Everything else is phantom typed around these.
option 2: define normal structs for channel, then phantom reader and writer, then phantom typed channels.
```
getStdOut[T] := (lambda: (T)->T) -> wchan[T] ...
getStdIn[T] := (lambda: (T)->T) -> rchan[T] ...
getSocketReader[T] := (s: Socket, lambda: (T)->T) -> rchan[T] ...
getSocketWriter[T] := (s: Socket, lambda: (T)->T) -> wchan[T] ...
getFileReader[T] := (path: string, lambda: (T)->T) -> rchan[T] ...
getFileWriter[T] := (path: string, lambda: (T)->T) -> wchan[T] ...
```
Inside wchan or rchan is not visible to developer. 
Options for all channels: buffer size, transformation function.
channel can have external (file, network, console) or internal (buffer) data source.
file writer channel with buffer? what does that mean?
console writer with buffer?
suppose that I have a file reader with `int` type, if it is buffered, it will first read the whole buffer, then will read from the buffer. So it makes sense for rchan to have buffer. But for wchan? Same. They have a buffer, they write to the buffer. When buffer is full they flush the buffer.
```
rch1,_ := createChannel[int](10, lambda1)
```
What does it mean to have buffer size for channel of string? It will be number of strings that it holds.
If you want correct control, you must define char channel.
So if I have `wchan[int]` it is something I can use to write. The destination, buffering and transformations are not visible to me. Normal channels can be used for synchronization. But others with external source? No.
If a file is finished, reading will return zero + false. When writing to a file, there is always room to write.
So even if you run select on a file writer channel, it will always proceed.

N - We can have different types for different channel types: For example file based or socket based channels.
But in cases that we need a general capture, like in select, we need to use `^` notation.
```
Cases := seq[^InPort|^OutPort]
```
Why not have a single type? `wchan[T]` and `rchan[T]`.


N - Problem is about having multiple users for a channel (read or write).
Sending or receiving is ok. but what about closing?
What if we also add `opening` to a channel? So each thread that opens, must also close the channel.
If everybody closes, then channel is not usable anymore.
If senders all close their channels, receive operations on the corresponding `rchan` will fail.
But what if we have sender 1 open and close and sender 2 has not started yet! in that case, receivers will not be able to read anymore, until sender 2 starts working.
So a close channel might be opened later.
But what if sender closes but receiver opens? 
No. The whole open/close concept is just confusing.
Why not remove them all?
A channel is a transport mechanism for data to somewhere else. If you don't need it, just don't use it or dispose it.
If you want to send other meta-data (no more senders, no more receivers, ...) just use another channel.
Its simpler to use two simple channels than to use one complex channel.
Of course if senders all dispose/close their channel, a receive will be blocked forever, waiting for a send.
Or if all receivers have disposed their rchan, a sender to wchan will be blocked forever. If they are interested to be informed about this, they can use another channel.

N - channe-r and channel-w each have a subscriber count. Upon first send or receive, it will be increased if the thread-id is new. It will be decreased with each call to close or dispose. When number is 0 then channel is considered completely closed. This can be used by receivers to know if there are more senders. We need to keep two coutners: subscribed, unsubscribed. If both are 0 means they are not started yet. If subscribed>ubsub means there are active senders. If subsc=unsub>0 means all senders are done. 
But what if first sender starts and finishes, but rest of senders have not started yet?
What does it mean to close a rchan?
Close can be used as a signal from sender to receiver to say there is no more data (so using subscribe and unsub count).
But what if receivers can close the channel? This cannot be a signal from them to sender. Because nature of the channel is for reading not writing a signal.

N - There should be a way to just signal that I want to subscribe for this channel. Like `subscribe(rch)` or `subscribe(wch)`. And, of course they are idempotent.
Other solution: Sending nothing means I want to subcribe on this channel.
But what about receive side?
Suppose that there is a channel which has a sender S and receiver R. Both are working on something else now.
S starts sending and finishes. After a little while, R starts listening. 
Is channel is not buffered, S will be blocked until R is ready.
Else, data will be buffered. When R starts, it will read from the buffer.
Why not do this?
1. Its advised to dispose/close channel when you are done with it.
2. Working with a disposed channel or sending it to other functions is error.

N - How can we define types that are internal and dont have anything on right side of `:=`
e.g int
`int := ...`

N - What about `default` in select? Just use a core function to get a simulated channel which always has some default value.

Y - Summary
Channels are a data transportation mechanism which are open the moment they are created. They are read-only (`rchan[T]`) or write-only (`wchan[T]`). They can be buffered or have a transformation function (`func(T)->T`) which will be applied before write or after read.

== Parallel execution:
`result :== expression` evaluate expression in parallel and when its finished, store result in `result`. If we refer to `result` later, code will be blocked until task is finished. Type of `result` will be same as type of the expression.
If expression returns a struct, you can destruct it by having multiple bindings on the left side.
You can use `_` to ignore expression result.
== Read and write
```
std_reader, std_writer := createStd[string]()
data := std_reader.[]
std_write.["Hello"]
reader, writer := createChannel[int](100) #specify buffer size

#Options for all channels: buffer size, transformation function.
getStdOut[T] := (lambda: (T)->T) -> wchan[T] ...
getStdIn[T] := (lambda: (T)->T) -> rchan[T] ...
getSocketReader[T] := (s: Socket, lambda: (T)->T) -> rchan[T] ...
getSocketWriter[T] := (s: Socket, lambda: (T)->T) -> wchan[T] ...
getFileReader[T] := (path: string, lambda: (T)->T) -> rchan[T] ...
getFileWriter[T] := (path: string, lambda: (T)->T) -> wchan[T] ...
```
== Select:
`data, channel := [wch1 wch2].[data1 data2].[rch1 rch2].[]`
or
`data, channel := [rch1 rch2].[wch1 wch2].[data1 data2].[]`
Applying `.[]` on a specific data structure (containing rchan and wchan+data) will acts like a select.

== closed channel
Any party can close/dispose their channel. Send or receive on a channel where there is no receiver or sender will cause blocking forever. If you want to prevent this, you need to implement this separately using another channel or any other mechanism.
Of course if channel is buffered, the buffer will be used for read/write.
== core
There are utility functions to create timed or always on channels (to be used as default in a select)
== Ex res
Exclusive resources (sockets, file, ...) are implemented using channels to hide inherent mutability of their underlying resource.

Y - Replace ex-res with channels
What if I have a function which expects a file to write to? This will provide some kind of polymorphism. 
The channel data structure (r or w) will have a channel-id, channel-type, buffer-specs and functor.

N - A binding can be either data, function or a type.
Type
functionName
dataName
Don't we need a keyword to separate them?
No.

Y - Use links for ToC.

Y - What if I write a lambda which returns x which is to be calculated in parallel?
`x :== process()`
`y := ()->x`
this will not cause stop of the code, unless `y` is invoked.

N - Remove import statement:
`:: := /core/net/socket`
No.

Y - Merge multiple modules into same namespace by:
`import a,b,c -> ns` So ns will contain all symbols from a and b and c.
But obviously, its not possible to have multiple ns on the right and one module on the left.

Y - If a lambda is on a single line, it must be a single expression, so it won't need braces.
So can we braces must always be on their own line?

N - Types are bindings too. 
But they are compile time bindings which are used by compiler at the time of compilation.
They are not stored in the final executable.
But functions and values are.
So we only have a collection of bindings.
`MyInt := int`
This binding has a name (MyInt) and a type (int). 
`f := (x:int)->x+1`
This binding has a name (f) and a type (`func(int)->int`). and a body.
`x := 10`
This binding has a name (x) and a type (int) and a value/body (10).
for func type we also need two other types: input and output.
(Later for generics we will need to add other options, but for now we don't need them).
So, fields for a binding:
`name` - what comes on the left side of `:=`
`type` - `int` or `float` or `func(int)->int`
`body` -> only for non-types

Y - Provide ability to import from github a specific tag or branch.
In the code you write `import github/a/b` but code will be checked out only during the first compilation time.
Afterwards, it will only use local cache. Unless you run `clean` command or manually delete the corresponding dir.
`import github/apache/cassandra` this will import master branch and create master dir in `github/apache/cassandra`
`import github/apache/cassandra/tag|branch|commit-id`
But what if I want a specific module inside that project? Shall we repeat the full path each time?
`import github/apache/cassandra[mybranch] -> T` This is not a namespace because namespace must point to a module.
But inside `cassandra/mybranch` there are a lot of packages and modules.
What if we treat import like a string? So we can easily concat them.
`T := "github/apache/cassandra/mybranch"`
`import [T "/path/module"]`
`import [T "/path/module"] -> A` alias
`import [T "/path/{m1, m2}"] -> A,B` import multiple modules
`import [T "/path/{m1,m2}," T "/path/m3"] -> A` merge multiple modules into same namespace
`import "github/apache/cassandra/master/dir`
What if the repository has a dir with the same name as the branch? branch name is mandatory.
`import "github/org/repo/branch/dir1/dir2/module"`
If we allow this, it can be used as a dependency definition. We have a main module which only defines dependencies + their versions. Other modules import this one and append the module they need to import.

N - There should be no "global" or "system-wide" libraries. Except core which is bundled with the compiler and runtime, everything else must be imported (explicitly or implicitly) and installed inside project folder.
e.g. `src` for source and `dep` for dependencies.
Other dirs: `res` for resources
`doc` for documentations
`t` for tests.

N - Can we have this binding in module level?
`person := ${"A", "B"}`
We can.

N - name of file (module) and dir (package) must include lowercase letters, numbers and underscore.

N - Can we make `import` a function in core?
No. Because it won't be executed at run-time. It is a compile time notation.
`import A,B -> X`
`X := import("A")`
`X := import("A", "B", "C")`
what if we say import is a special function which will be executed at compile time?
Then the developer cannot use runtime bindings in import input:
`R := getInput()`
`X := import(R)`

Y - Enable defining types inside a struct.
So what happens to struct embedding? Types are added too. And of course any conflict will result in compiler error.
So we can have `myPerson.MyInt` as a type.
Also `myPerson.createData` as a function (this is not new).
Pro: Less restriction, prepares way for module import and remove `import` keyword
Pro: We can define inline modules. Because module is just a struct.
q: Can we use `$` notation to merge two structs? No.
Struct fields which start with lowercase are binding. Uppercase are type.
```
Point := {x:int, y:int, Customer := int}
```
So we can define a struct in two ways: Condensed and Expanded.
Condensed is defining inside a module.
Exnapded is to define it in it's own module.
What happens to autoBind? You cast a struct literal to a struct type.
`compare_functions := Comparator.{personStruct}`
So all bindings and types that are defined inside `personStruct` and match with `Comparator` type will be copied to a new struct and assigned to `compare_functions` binding.
And similarly, types starting with underscore are considered private and won't be exported to outside modules.
So if you import a module into a struct, you will only have access to items without underscore.
So `myModule.Str1.Str2.Struct3.MyInt` can be a type.
Types start with uppercase letters.
Bindings start with lowercase letters. (functions have `someFunction` nameing and others are separated with underscore).
**Summary**
1. Allow defining types inside struct. Nothing else will change.
`Model := {x:int, y:int, CustomerCode := int}`
When we instantiate, obviously we assign value to bindings only.
So you can define types inside a struct or at module level.
2. Update `autoBind` documentation

Y - Module as a struct
q: Can I add `.` and refer to stuff inside an imported struct right after `$`?
`CustomerModel := $"/core/Customer".Customer`
This should be possible, but then how can you reach any function defined inside that module? If you just pick a type, then what happens when you want to invoke a function inside that module?
```
CustomerModel := $["/core/Customer"].Customer
x: CustomerModel := createCustomer() #error! function is not defined.
#you must import the module or use $ notation again!
x: CustomerModel := $["/core/Customer"].createCustomer()
```
Or maybe we can make it more beautiful. 
`$[...]` import multiple modules into one or more structs
`${"/core/Socket"}` import a single.
Why not merge two syntax! A sequence with only one member.
**Summary**:
1. Remove import keyword.
2. Importing a module means assigning it to a struct binding using `$` notation.
```
Socket := $["/core/Socket"]
Socket, Stack := $"/core/{Socket, Stack}"
IntStack := $"/core/Stack[int]"
A, B := $["/core/Socket" "/core/Stack"]
A := $["/core/Socket" "/core/Stack"]
```
Result of import is just a normal struct binding that we can use in our functions. We can also use `_` to merge the module into current namespace.
Update `autoBind` documentation
**End Summary**
Define a new binding type: module. Name must be prefixed with `&` and you can use `_` if you don't want to alias.
So we can use `:=` notation and right side implies a module path.
For example, if binding name starts with `&`.
Then if the difference is more explicit, we can even re-use dot notation and remove `::`.
Because `A.b` is for struct and `&A.b` is for module.
`&m := "/code/st/Stack[int]"`
We use string on the right side so that we can use string operations (e.g. re-use a prefix).
q: what about merging two or more modules into each other?
q: how to import multiple modules?
`import /core/{Stack, Vector}`
`import /core/A, /core/B]`
We can merge if we import a sequence of strings.
`&multiple := ["/core/Socket" "/core/Data"]`
And if we use `&_` module will be imported into current namespace.
`&_ := "/core/net/HttpServer"`
`&_ := "/core/std/{Queue, Stack, Heap}"` This is a bit un-intuitive.
`pref := "/core/std/";`
`&_ := "/core/std/{Queue, Stack, Heap}` This is a bit un-intuitive.
Sometimes we want to import multiple modules but not merge them.
`&A, &B := "/core/std/{Queue, Stack}"` Import two modules into two namespaces.
`&`
`&x := "/core/Socket"`
What if we change `:=` notation?
`xn :: "core/Socket"`
But xn is supposed to behave similar to a binding (we can address inside using `.`).
`&A, &B := "/core/std/{Queue, Stack}"` Import two modules into two namespaces.
`&multiple := ["/core/Socket" "/core/Data"]` merge 
`&_ := "/core/Socket"`
As the namespace is a super-type, it's name should be similar to a type: `AliasName`
`|~±§`.
Using `*%!` is not advised because they can be used in other places (math and comparison).

Y - Can we remove generics? Not exactly but we can simplify it by using package templates.
Where do we need generics?
containers, array, hash/map, compound literals, stack, queue, graph, tree
algorithms: sort, search, 
We can have type checks in functions which can be enforced at compile time.
`(x @ y)` in a single line will enforce x and y are of the same type.
this means:
1. extend `@` for easier type checking
2. remove generics
3. remove compound literals, we have only seq and map literals.
4. add special notation for map and sequence types.
5. add new? notation for read from sequence and map.
Maybe extend autoBind notation to replace interface in Go.
OTOH we can keep the current status, find out the problem with generics and try to resolve them as much as possible.
e.g. readability: force call on functions and creation of types to include `[int]` part to specify their type.
applications: container, algo, map/reduce/higher-order-funcs
alternative: use type variable in module file-name. `/core/std/Socket[T].dot`
So you must specify type in import and nowhere else.
So you define `Stack` module with a type like `T` which is initially some default value like int.
Then: `import /core/Stack[T := string]` and you will have Stack type and methods specialized with string.
You can define `T` in the module based on a specific struct and then during import, you can only replace it with another tuple which embeds that struct (derived type).
Advantage: We only need to modify import syntax. Nothing else.
Con: What if we want to import a module with different types?
Con: Circular reference. A package defines type A and B which refer to each other using a generic type.
Pro: Function and type names during definition and call won't need to include `[int]` notation.
`import "/path/to/module" [T: int, S:string, D:float] -> AliasName`
We can also add specialization by adding extra modules.
`Stack[T].dot` and `Stack[int].dot`
We can even remove `[T]` part from module name. Then specialization will become difficult, but import will becomemore natural?
`import /core/Stack [T:string]`
`import /code/Stack[string]`
The second format seems more intuitive. But how can we import the default type? By using `[T]` in module name.
`import /code/Stack[T]` import the default stack implementation.
How can we define a Server type which have a Set of clients and a Client type which has a set of servers?
```
Server := ...
Client := ...

import /core/Set[Server] -> srv_set
import /core/Set[Client] -> cli_set

Server := { c: cli_set::Set }
Client := { s: srv_set::Set }

```
This is an example pseudo-code for Go: https://gist.github.com/egonelbre/d6787bfff0684cddbd10
What if there is T in module name but not inside it? Then there is no way for others to customize module code.
If you want to have a generic module, use `[T]` notation in file-name and define/use type named T inside the module.
How can we write an inverse-map function which receives a map of int to string and returns map of string to int? define two types and use them in the code.
You write normal code. Just append `[T,S,Y,...]` to the filename. And upon import, you can either import normally: `import /core/Stack[T]` or you can replace T with a real type.
compiler can give warnings if module name has `[T]` but no type T is defined inside the module.
```
import /core/map[int] -> mm
#if binding name start with uppercase, its a type else its a value binding.
mymap := mm::map
```
We do not have a mechanism/type/container to hold a set of bindings. We just use module alias.
importing a map twice for different types will give you error if you use types inside the module. We cannot have two types with the same name. But for functions it's ok because we can have multiple functions with the same name but for different types.
q: can we extend this to package level? So we have directories with `[T]` in their name. And all of their modules will inherit that T? No. It makes things complicated and less readable.
What if we have `Stack[T].dot` and `Stack[S].dot` files in the same package?
That would be a compiler error, just like defining two functions the same singature.
q: What about nested generics? e.g. Map of string to a list of integers. or a list of list of integers.
e.g. `Stack<List<int>>`
```
import "List[int]" -> Lint
import "Stack[Lint::List]" -> St
#Now St is a Stack which contains List of int
#OR
&Lint := "/core/List[int]"
&St := "Stack[&Lint.List]"
```
Can the module add static compile-time checks on it's type?
```
#file: Stack[T].dot
T := int
```
You must use a named type for generic type replacement: `/core/Stack[MyCustomer]`
**Summary**:
1. No change in defining a module. Remove `[T]` notation for type or bindings.
2. module file name can have `[S,T,U,...]` suffix with types with the same name defined inside the module. If not, compiler will give error.
3. When importing that module you can either import `my_module[T]` or `my_module[int]`. Where `int` can be replaced with any primitive type, named type or any type defined inside an available struct.
`IntStackModule := $"/core/Stack[int]"`
`IntStackType := IntStackModule.Stack`

N - Can we treat a module similar to a class?
`&Car := "/data/std/CarModel"`
`cc: &Car.Car := &Car.createCar(1)`
Can we use a different naming and replace `&A.` with something simpler?
Prefixing symbol with `&` is a bit hard to type.
Option1: Use dot to separate namespace from binding or type name but use a prefix to separate namespace from a struct.
Option2: Use a special notation to separate namespace from binding but no prefix or special naming for namespace.
` := "/data/std/CarModel"`
`cc: &Car.Car := &Car.createCar(1)`
What about `[Name]`?
`[Car] := "/data/std/CarModel"`
`cc: [Car].Car := [Car].createCar(1)`
The only possibility for ambiguity is sequence and compound literals.
`x := [1 2 3]`
`x := [Car]`
`[[Car]] := "/data/std/CarModel"`
`cc: [[Car]].Car := [[Car]].createCar(1)`
Is there a no-surround alternative which is also easy to type?
`Car:: := "/data/std/CarModel"`
`cc: Car::Car := Car::createCar(1)`

`Car& := "/data/std/CarModel"`
`cc: Car&Car := Car&createCar(1)`

`Car! := "/data/std/CarModel"`
`cc: Car!CarModel := Car!createCar(1)`
Below one is better than others. Suffix notation is not intuitive and readable.
`!Car := "/data/std/CarModel"`
`cc: !Car.CarModel := !Car.createCar(1)`
But `!Car` is not intuitive. It can be read 'not car'.
`!Car := "/data/std/CarModel"`
`cc: !Car.CarModel := !Car.createCar(1)`
`??Car := "/data/std/CarModel"`
`cc: !Car.CarModel := !Car.createCar(1)`
What if we use existing mechanisms? 
We have a set of bindings (value, function, ...) and types inside a module. 
For bindings, we have struct.
If we can define a type inside a struct, then we can simply define a new struct instance binding and import a module into it.
`x := Point{x:100, y:200}`
`y := "/core/Socket"{};
Basically, then, a module will be a struct definition.
```
Person := {
	x:int := 10, 
	y:float := 1.19, 
	IntList := seq[int]
}
```
`Person := [["/core/PersonInfo"]]`
cases: import single module, import multiple modules, merge modules
Basically we are defining a struct literal here. So let's use `$` notation.
```
Socket := $"/core/Socket"
Socket, Stack := $"/core/{Socket, Stack}"
IntStack := $"/core/Stack[int]"
A, B := $["/core/Socket" "/core/Stack"]
A := $["/core/Socket" "/core/Stack"]
```
So if we have `{...}` after `$` it is a normal struct literal.
If we have `""` or `[...]` we have a struct literal which will be imported from another module.
Of course we can use existing `_` to say we don't need aliasing.
`A := $"..."` import the given module and store it's bindings and types into A

N - How should this work with Docker?
Suppose that our app is going to be installed inside a Docker vm.
First copy the source, then run `dot update` and it will automatically scan the source and fetch required packages.
`dot ls-req` will give you a list of dependencies.
Anyway, we won't need a big Makefile, requirements.txt or Gemfile.

N - How can we do DFS, BFS in dot?

N - We can create bindings used for import:
```
#module1
mname := "/core/Stack[int]"

#module2
x := "./module1"
_ := x::mname
```

N - How can we write a function which compares two stacks?
```
#comparer[T]
T := ...
S1 := import "/core/Stack[T]"
compare := func(a: S1.Stack, b: S1.Stack)
```

N - We currently have `${...}` and `$[...]`.
We maybe able to use `$(...)` notation too.
Where can this be useful?
It must be related to structs.
`x := $(1,2,3)`

Y - We should have a clear distinction between string concat and a sequence of two strings.
6. `base_cassandra := "github/apache/cassandra/mybranch"`
7. `_ := $[base_cassandra "/path/module"]`
Is above a sequence of one string or two?
option1: Use `+` for string concat
`_ := $[base_cassandra+"/path/module"]`
But then `+` will not be only available for string, it will be allowed for all sequences.
It will give us a notaion to merge two sequences.
option 2: `&`. `a&b` will generate a new sequence as result of merge of two given sequences.
`"A"&"B"`
How can we define a 2d sequence?
`SeqI := [ [1 2] [3 4]]`

N - Note that, importing a module, will give us a type not a binding. So we cannot send it to a function.
It may contain bindings which we can send to a function.
We have two concepts: Type and Binding.
Bindings have Types.
Types are blueprints used to instantiate bindings.

N - What if I want to have a sequence of type T where T can also be changed as a generic argument.
```
T := int
MyType := $["seq[T]"].Type
```
putting module name inside quote implies not being parametric, while `[T]` is the parametric part.
`T` will be replaced at compile time by real type of T.
Maybe we can add one more chain to the mechanism and both remove this and also casing.
```
#my_module[t].dot
T := int
MyType := $["/core/Stack(T)"].Type
x: MyType := [1 2 3]
```
Anything inside `()` in module path, will be processed by the compiler to generate module code, based on the given arguments.

N - Shall we change the notation of `[]` in template packages to prevent confusion with `$[...]`?
`SeqInt := $["seq[int]"]`.
`SeqInt := $["seq(int)"]`. And we will need to change module filename accordingly.

Y - Each module has an active namespace and a passive namespace.
Active: Bindings and types defined directly inside the module
Passive: Bindings and types imported into current namespace using `_`.
When writing code inside module, you have access to both.
When importing the module, you import their "active" namespace. You can import it into current passive namespace or put it inside a struct type.
Namespace is a type. Actually it is a struct.
So each module is defining a new struct.
Importing a module is similar to embeding.
`Circle := {Shape, r: float}`
Why not use the same notation?
`Circle := { $["Socket"], r: float}`
```
#module1.dot
${x:int} #you embed this inside current struct(module) which is same as defining x:int
$["/core/Socket"]
```
We also should allow for both types of defining struct: comma separated or newline separated.
When you write `$["/core/Socket"]` you are embedding Socket module inside current module (struct).
**Summary**: Modules are same as struct.
When you write `x: Shape` you define a new binding of type Shape and name it x, but without a value
When you write `MyInt := int` you define a new named type.
When you write `MyInt := $["/core/Socket"]` you define a new named type.
Problem: `$` is used to define a struct literal, so it is only for values or bindings.
It is not supposed to work for TYPES.
`x := ${1,2,3}` define a new value, not a new type
`MyInt := $["/Core/Socket"]` This is defining a new type! Totally confusing.
option 1: use `!`
`@$%^&*`
So `!` operator will work on a sequence of strings and will define new types based on those modules.
If you want to import a module into current namespace, you shouldn't use `_ :=` notation because it is used to ignore output of right side. You should do it just like embedding, write the type name.
```
#module1.dot
!["/core/Stack"] #this will import Stack (it's types and bindings) and put them (embed them) inside the current module
```
But then again, this should become part of the current module's struct. So when others import `module1` they should also see `Stack` inside module, which makes the module dirty.
Solution? Merge all modules you want into same type. or re-use `_` to add to passive namespace.
```
#module1.dot
!["/core/Stack"] #this embeds Stack type INTO current module's active namespace. So if others import module1, they will have whatever is defined inside Stack, inside the result of their import
_ := !["/Core/Queue"] #this embeds Queue into passive namespace
A := !["/Core/Tree"] #this will define A point to the struct represented by Tree
```
active namespace: direct namespace
passive: indirect
When using a binding or type, first direct namespace then indirect namespace will be searched. 
When importing a module, their direct namespace will be imported into current direct or indirect namespace or a new type.
Each namespace is in a hierarchy: Current struct, parent struct, ..., module.
We can use `()` notation for `!` to see it as a function. Then for generics we can revert to `[]`.
To make it more intuitive, we should not allow multiple bindings on the left side. Because this is not a struct literal. 
`A, B := !("/core/stack" "...")` does not make sense!
So, `!` can accept a string which can also include `{}` to represent multiple modules. If we have multiple modules for `!` it will merge them all into same struct type. And it should not accept multiple inputs. Only one string.
Of course if there is a conflict, it should be handled appropriately.
1. `!("/core/st/Socket")`
2. `SocketType := !("/core/st/Socket")`
3. `_ := !("/core/st/Socket")`
4. `_ := !("/core/std/{Queue, Stack, Heap}")`
5. `MergedType := !("/core/std/{Queue, Stack, Heap}")`
6. `MyModule := !("git/github.com/net/server/branch1/dir1/dir2/module")`
7. `base_cassandra := "github/apache/cassandra/mybranch"`
8. `_ := !(base_cassandra&"/path/module")`

Y - module names must be lowercase, but type names must be CamelCase.
So `Socket[T].dot` is not a valid module name.
It must be `socket[t].dot`.
But the type inside the module must not be lowercase.
Easiest solution: Just keep it this way. Use lower-cased type name in module file name.

N - A function can also import modules into it's own direct or indirect ns.
But it cannot embed them. So `!("socket")` is not valid inside a function. The output must be assigned either to `_` (indirect) or to an identifier (direct).

Y - direct/indirect -> explicit/implicit

Y - There are two ways to declare a struct: inline and module.
intline: `Customer := {name:string, age:int}`
module: in a separate file, no need for comma
```
#customer.dot
name: string
age: int
```
usage:
inline: `x: Customer := Customer{name:"A", age:30}`
module: `my_customer := !("customer"){name:"A", age:30}`
module another way: `CustomerType := !("customer")`
`my_customer := CustomerType{name:"A", age:30}`

Y - A module provides a number of types and bindings. Those bindings can be abstract `name: string` or concrete `name: string := "ali"`. When you import a module, you have a type. You can initialize new bindigns based on that type and during that operation, you can provide values for abstract bindings.

N - There are two types of bindings: Concrete and abstract.
Concrete has a value but abstract does not.
When you create a binding of type struct, you must provide value for abstract bindings and must not provide value for concrete bindings.

Y - mark items that must be specified when importing the module. This is just like a struct definition where you provide values.
`Customer := {name: string, age: int}`
How can we define a module for sorted list so that it has a generic type + requires compare function?
```
#ordered_item[t].dot
t := int
compare := (a:t)->int ...

#ordered_set[t].dot
t := int
_ := !("ordered_item[t]")
OrderedSet := { ... }
add := (x:t, s: OrderedSet)-> { ... }

#main.dot
Customer := { ... }
compare := (a:Customer)->int ...
_ := !("ordered_items[Customer]")
```
solution 1: You should be able to override bindings in a module when importing it. So you can re-write compare function of ordered_item
solution 2: You can override only empty items. So the ordered_item module, provides empty binding, but main should provide an implementation for that.
```
#ordered_item[t].dot
t := ...
compare: func(a:t)->int := ...

#ordered_set[t].dot
t := ...
_ := !("ordered_item[t]")
OrderedSet := { ... }
add := (x:t, s: OrderedSet)-> { ... }

#main.dot
Customer := { ... }

_ := !("ordered_items[Customer]"){compare := (a:Customer)->int ...}
#another way: using another import with exactly the same bindings as we expect here
_ := !("ordered_items[Customer]"){!("default_customer_order")}
```
proposal: `...` for a type or binding means it must be specified during import, else it is not callable.
So either direct importer or indirect importer should provide concrete values.
Also we can use import when providing values in another import.

N - Suppose we have this struct:
`XS := {x:int, y:int := 10}`
Can people change value of y when they create instances of XS?
yes: they should be able to change upon creation.
no: setting value for a field means it is a constant that can never change.

N - Why we cannot provide generics in struct level?
```
Stack := { T, push: func(data:T)->... }
x: Stack[int]
```
It might be possible but to simplify things, it's been decided to have them only at module level.

N - With this new generics design, what happens to `seq`?
Or `func` or `wchan` or `rchan`?
`x : seq[int] := [1 2 3 4]`
`x : $["seq[int]"].Type := [1 2 3 4]`
Can we say `seq[int]` is a shortcut for `$["seq[int]"].Type`?
Anything that I use here, should be applicable to other types too.
```
#seq[T].dot file, assume seq is implemented as a linked-list
type T := int
type Type := {data: T, next: Type}
```
Then usage:
`SeqInt := $["/core/seq[string]"].Type`
option 1: define `X[T]` a shortcut for `$[X[T]].Type`. But it won't be much useful for other cases. Because they will need a path for their module.
option 2: Do not use `seq[int]` notation.
Using `A[B]` notation for a type will be source of confusion which we want to avoid by using module template.
Because then we can use `A[B[C[D]]]]` and ...
`x1: seq[seq[int]]`
`x2: wchan[seq[int]]`
`x3: rchan[seq[seq[int]]]`
`x1t := $["seq"]`
`x1: x1t.Type`
If we want to be consistent, we must use the same approach and don't take an exception for seq and chans.
We define sequence type just like other types that a developer will define.
`SeqInt := $["seq[int]"]`.
For literals, compiler will handle the type generation when it should be implied.
`SeqInt := $["seq[int]"].Type`.
`ss: SeqInt := [1 2 3 4]`
`SeqInt2 := $["seq(SeqInt)"].Type`.
But this is difficult to type and everytime, user must import seq or chans and use their type.
Even in go, you can define these generic types easily.
Another option: Use similar syntax `()` but without extra notation:
`x: seq(int) := [1 2 3]`
`y: wchan(string) ...`
Note that this can be confused with function call.
option 1: define `X[T]` a shortcut for `$[X[T]].Type`. But it won't be much useful for other cases. Because they will need a path for their module. So mentioning `seq[int]` will automatically import corresponding functions into indirect namespace.
And this is only valid for seq, wchan, rchan.
and map?

N - New notation for sequence `[int]` and map `[int,string]`
Maybe we should also stress on ease of use: writing code more easily.
So things like forcing to import a module in core for each type of sequence user wants to use is not a good idea.
Maybe we can use this notation:
`[int]` for a sequence of int
`[int, string]` for a map
Not having to use `seq` or `map` keywords makes it a bit more separate from normal generics syntax.
`x: [int] = [1 2 3 4]`
`y:[string, int] = ["A",1 "B",2 ...]`
So why they cannot have 3 items?
`z: [string, int, int] = ["A",1,2 "B",4,3 ...]`
What does this mean? How can you read it back?
pro: Just like struct and union, seq and map will use notation. Not identifiers.
pro: It won't be confusing with generics notation.
pro: easier to type.
But still for functions which are generic (like let), we need some exceptions. So user does not need to import them for each type they use.
`z: [string, int, int] = ["A",1,2 "B",4,3 ...]`
`z: [string, {int, int}] = ["A",${1,2} "B",{3,4} ...]`
`z.["A"].0`
`z.["A"].1`
what about 2d array?
`x: [[int]]`
`x.[0].[1]`
`[string, {int, int}]` is a better notation because it build on existing notations and also does not raise the quetion of using 3,4,... items. We only have 2 items.
Moved to summary note.

N - What about notation for wchan and rchan? `int+`, `int-`
`w: wchan[int] = ...`? `w.[data]` writing to w-o channel
`x: rchan[int] = ...` `data := x.[]` reading from r-o channel
`x: =int>` r/o channel
`y: =int<` w/o channel
`x: %int` r/o channel
`y: %%int` w/o channel
why not use generic import? it will be hard to read and write. We want to make it easy.
`x: int[]` r/o channel
`y: []int` w/o channel
`x: int[]` r/o channel
`y: []int` w/o channel
`int, float, char, string, [int], [int, string] (int) (int)`
What about `()`?
`(int)` w/o channel
`)int(` r/o channel
`int+` w/o
`int-` r/o
`x: int+ ...`, `x.[10]`
`y: int- ...`, `data := y.[]`
`z := (int+).{ch}`
Moved to summary note.

N - Shall we add `map` as another built-in?
Then we can throw away the syntax for compound literals.
can we implement map with existing mechanisms? yes. but then it will not enjoy the compiler helpers that seq has.
```
m: map[string, int] := ["A",1 "B",2 "C",3]
#vs
MyType := !("map[string, int]").Type
m: MyType := ["A",1 "B",2 "C",3]
```
Another option: Force to import even seq and core but provide syntax sugars
`MapType := !("map[string, int]").Type`
Shortcut: Instead of above you can write: `map[strig, int]`. But this is not good as it is not general.
Moved to summary note.

N - For example `length` function can work on seq. If we want to use it on `seq[Customer]` shall we import `/core/length_utils[Customer"]` module?
It would be difficult to do that and it would be non-general to not do that.

N  - If we allow `seq[T]` what about their functions?
e.g.
`r,w := createChannel[int](...)`
option 1: Make type one of the arguments: `r,w := createChannel(@[int], ...);`
and compiler will handle to have it's output channel of int.
it can make life more difficult for readers because type or r,w may not be very clear.
option 2: replace function with syntax. 
anyway we will have lots of array/map related functions. we need to come up with a consistent solution.
proposal: functions are just like normal functions but compiler will import appropriate functions for us. 
So we cannot write `createChannel[int]`. We should write `createChannel` and make the expected output type explicit.
So let's say: Eveything in core is like normal code but compiler will import appropriate functions for you.
So something like: extract method which extracts part of a sequence, it is generic. So it is defined like:
```
type T := ...
extract := (x: seq[T], start: int, end: int)->seq[T] ...
```
Similarly, sequence, wchan and rchan are defined in core in some semi-dot modules. But compiler will import them for us.
As a result, if a function is already imported which is `extract` for int sequence from some non-core module, compiler will not import from core. 

Y - Default is import into indirect namespace.
But this will result in lots of name duplicates: suppose we import stack and queue. probably they both have a type `t` which is their generic type. How are we supposed to handle this?
The rule is: As long as you don't refer to a type or binding, no check for conflict will be done. So when you import another module, into direct or indirect ns, they will live separate from other modules. When you refer to something, if at any stage in the search there is more than one candidate, there will be compiler error.
So compiler will search direct ns in current func, then current struct, then parent struct, ..., then module.
If not found, it will do the same for indirect (indirect ns in current func, current struct, ..., module).
Only structs have a namespace.

Y - In struct update change `:` to `:=` because it makes more sense. Also in literal.
`Customer := {name: string, age: int}`
```
#customer.dot
name: string
age: int
```

Y - Using space for separator is not good.
`result := [data () -> processBigBuffer(buffer)].[condition].()`
Here `()` and `->` can be separated with space which makes reading the code difficult.
Let's rever back to comma.
`x := [1,2,3,4]` sequence
`y := ["A",1, "B",2, "C",3]` map

Y - To make things more consistent use `$` prefix for sequence and map literals too.
`{}` is also used for function and lambda. That's why `$` is used for discrimination.
`[]`? Is used for sequence and map type. Something like `[A,B]` is a map type definition.
option 1: use `$` for seq and map literlas and `[]` to refer
option 2: No prefix for literals but `.[]` to refer.
Having `$` prefix does not fit well with `&` operator to merge sequences.

Y - Can we use `[]` instead of `.[]`?
`x[0]`
`rch[]`
`wch[10]`
Applications of `[]`: module filename for generics, define sequence and map type, define sequence and map literal.
1. filename
2. `[int]` `[int, string]`
3. `[1 2 3]`
4. `[1,2 3,4 5,6]`
So `A[b,c,d]` will be translated to a call to `process(A,a,b,c,d)` which for seq and map has it's own impl.
Then, can we eliminate `.()` and `.{}`? For the second one, no. We need casting operator.
Can we replace `.()` with `[]`?
So calling process on a function pointer will invoke it. Otherwise, nothing will happen.
`result := [data, () -> processBigBuffer(buffer)].[condition].()`
But `[]` has another meaning for reading from channels too.
`result := [data,() -> processBigBuffer(buffer)].[condition].()`
Let's keep `.()`
Problem: When I see `[1,2]` it is custom process call or it's a sequence literal?
It depends on what comes before this.
`[1][2][3]` 1 is sequence, 2 and 3 are custom process

Y - Remove `$` for struct literals.
What confusion can it bring?
With what can it be confused?
Lambda? They have `->` before them.

Y - Generics type: No need to declare them, add all lowercase to the file name and use all capital in the code. No separator is allowed.
When defining uninitialized fields, we write `name: string` but what about types?
For generics.
`x: int`
`y`
`MyInt := ...`
How can we define a generic type without implying it is embedded into the module's struct type?
Is there a better solution for case change in type definition and module file name?
Maybe we can solve both problems with one move:
If type does not have value and it is generic, do not mention it in the module. Because then it will mean it is embedded.
Instead, add it to the file-name. 
`stack.dot` becomes `stack[t].dot`
Then use `T` type freely in your code. Compiler will know that t type will be provided when importing this module.
If they do not provide value for T, there will be compiler errors.
Anything inside `[]` after module name, can be assumed to be defined in the code as a type.
`stack[t].dot`
proposal: For these types, they must be all capital in the code. Also these must be one word identifiers, there is no separator.
pro: more readable and explicit
pro: problem of case is somehow solved. in filename all lowercase in code capital

Y - New notations for primitives: 
sequence `[int]` 
map `[string, int]`
wchan: `int+`
rchan: `int-`

Y - `T-` can be a bit confusing when combined with other things.
`T?` for reader
`T!` for writer

N - Can we force everything to be addressed from their import? (no ignore for import)?
Then if user wants to use an additional set of functions for a type, they can just merge corresponding modules.
This will become very similar to OOP. module is a type of class.

N - Does this work?
```
process := (x:int)->x+1
process2 := process
```
can process2 be an alias for process? yes. it should work.

N - Casting will just return something with bindings pointed to original value. Types won't be affected.

N - Can we simulate interfaces now? With casting an imported module to a type which has only function pointer bindings.
```
#my_module.dot
process := (x:int)->x+1

#intr.dot
process: func(int)->int

#main.dot
MyModule = $("my_module")
Intr = $("intr")
Refined = Intr.{MyModule}
```
So:
proposal: You can cast from type A to type B...

N - Proposal: Remove concept of type.
Named struct types can include bindings. So why not think of them as normal bindings with abstract values.
Then we can either update them (make a copy and provide values for those missing) or just use them.
`MyInt := int`
`MyPerson := {x:int, y:int, z:=10}`
MyPerson is an abstract binding which has two placeholder bindings (x and y) and one normal binding.
A binding which does not have a value...
The fact that we can define binding inside a struct (which we have to support to support modules as struct) makes things more complicated. How can we simplify them?
solution 1: Define a new type: module. result of import is of that new type.
But module is exactly same as struct? struct can have bindings with or without value. But (initially) it was not supposed to contain named types. Also embeding a module (upon import) that contains named types, will make things more complicated.
Why not import module normally first and then embed it's typs inside a struct?
solution 1: struct cannot contain type definitions. modules can. when importing module you can import into implicit ns 
one problem we need to solve is when import will add duplicate binding/types. In that case we need to cover that or alias that. What if we can rename them? In this case we can just eliminate alias.
We just import a module and it will go to implicit ns. No named type and no embed.
Then it won't be expression! it will be statement.
The biggest advantage of expression is composability, but here we dont want to compose expressions.
```
import "module1"
import "module2" { process2 := proess, f2 := f1, MyType := ModuleType } #this block is evaluated in the context of module2
process2(100) #this will call process inside module2
```

Y - proposal: remove `$` and add back `import` statement. you can alias names when importing.
review autobind. with this new import, we may also need autobind for current implicit ns.
So `A.x` will only be used when A is a struct.
q: What if we import a generic module two times? There will definitely be overlapping types with different implementations.
q: How shall we handle phantom types based on generics?
`import "MapHelper[int,string]"`
`import "MapHelper[int,float]"`
Just use the functions. For types which are common, you can alias them if you need to refer to them explicitly.

Y - If a struct contains a function with impl, can we call it without creating an instance of that struct?
If we can, this will become OOP like. Something like static functions.
But this is not good. struct is supposed to define a pattern to hold data. 
We are not supposed to provide any initial value for them. If there are any, do it in a creator function.
So:
proposal: Struct can only contain un-initialized bindings. Nothing else (no values, no named types, ...)

N - If a module contains a function and we import it as a named type, can we call that function without creating a new instance of that type?
We should.
so `a.f` is refering to f field inside struct binding `a`.
`A.f` is refering to f binding inside named type `A`.
`A := {x:int, f:=(x:int)->x+1}`
`y := A.f(10)`

N - two important questions:
Can we define types inside struct?
Can we define types inside function?
Currently answer to both of these is yes.
Can you define bindings inside a struct?
```
Point := {x:int, y:int, process := (x:int)->x+1}
...
g := Point.process(10)
pp := Point{10,20}
g := pp.process(10)
```
So as a summary:
1. We have types (e.g. struct) and bindings (e.g. functions)
2. Among types only struct/module and among binsings only functions can contain other things.
2. You can define bindings and types inside types (structs)
3. You can define bindings and types inside bindings (functions)
This is too complicated! We can almost define everything everywhere.

N - Evaluate effects of adding `anything` to the language and removing generics.
How does it affect struct, function, types, module system, import, namespaces?
1. Import inside a function
2. Define type inside a struct
3. Define type inside a function
4. Define binding inside a struct
What can we do with an import? ignore (implicit ns), named type, embed
We can have interface polymorphism in the data and types we have.
if we have `process(anything)` and send it an integer and process calls `refine` on it's input, it will first try to call `refine(int)`.
In go they need to write 67 function for different sortings. what about here with anything?
```
sort := (x: [anything], compare: func(anything, anything)->int) ...
```
What if we can mix these two? Above can be considered a generic function with only one type arg. When calling it, compiler will automatically assign type to replace anything. So you cannot declare a variable of type anything. But when calling `sort` function above, the type of argument you use, will specify what type `anything` is in real.
There are lots of limitations to this but maybe they are worth it.
What about maps?
We can consider `anything` to be union of all universal types that we have.
In which case, we can call above sort function with int array and a function which compares float with string.
But we can then do some checks inside sort function:
```
sort := (x: [anything], compare: func(anything, anything)->int) ->
{
    @compare = @[func([x],[x])->int]
}
```
anything acts like `void*` in C++. You can also define a binding of type anything.
Compiler will decide about code generation for these functions. For example if sort calls `process(x)` based on the type of x passed to sort, different functions can be called.
```
List := {x:anything, next: List}
```
How can we write a function to compare two lists?
`cmp := (a: List, b: List) -> { @a.x=@b.x ... `
questions:
1. implement stack
2. implement sorting
3. implement search 
4. implement binary tree
5. implement set
6. reverse map
7. a function which filters a hashmap
`reverse := (x: [anything, anything])->[anything, anything]`
What if compile does nothing at compile time for anything functions and just calls them. And user needs to handle type casting. But a function call inside that function, in go this is handled at runtime with runtime dynamic dispatch.
But we want to do it at compile time. That's why we need to generate appropriate code based on input type at compile time.
module level or any? Which one is better?
Use the original factor: Simplicity in writing and reading and maintaining.
option 1: generics as templated modules
option 2: `any` type
```
Stack := [any]
push := (s: Stack, x: any)...
pop := (s: Stack)->any ...
#example: a function which filters a map by a predicate
#filter[K,V].dot
filter := (m: [K,V], pred: func(K)->bool)->[K,V]
{
	...
}
#main.dot
import "filter[int, string]" {intFilter := filter}
import "filter[int, Customer]" {customerFilter := filter}
a := filter(m,pred)
#how can we run filter on a map of string and list of int?
import "list[int]" { ListInt := List }
import "filter[int, ListInt]"

### using any type
#filter.dot
filter := (m: [any,any], pred:func(any)->bool)->[any,any]
{
	
}
```

N - Add a section "Why dot" and say conditions which rule out competitors.
Like "Why zimbu" in http://www.zimbu.org/

N - How should an import path be resolved and where should the data be looked up or saved?
suppose we have `import /a/b/c` Where should we look for a directory?
option 1: The location we run the compiler (pwd): `pwd/deps/a/b/c`
option 2: Use env-var
option 3: You can use option 1 + an optional argument to the compiler for root path.
by using option 3, we can have a shared deps dir for multiple projects.

N - How can we work on multiple interrelated projects at the same time?
How can we have different versions of the same dependency?
What if we need libA any version and libB but libB needs a specific version of libA?

N - What about versioning?
We can write a custom function which can be used to decide whether a specific branch/tag can be used for import.
`import "github/apache/cassandra/thisOrLater("1.4"`?
Or use star:
`import "github/apache/cassandra/v1.*.*"`
star means in this place there will be one or more numbers. Choose the largest one.

N - What if we have `sort(x:[?], cmp: func(?,?)->int)` and want to make sure cmp is a good function for comparing data of type x? How can we use `@` for that purpose?
q: How to get type of data inside an array?
q: How to get type of key and value inside a map?
one solution: Use named types
```
Anything1 := anything
sort(x:[Anything1], cmp: func(Anything1,Anything1)->int)
```
Not very elegant.
solution: `@` returns int. 
`Type := @[x[0]]`
This wont work for map.
what if the array is empty.

Y - Review autobind and phantom types section for the new import notation.

Y - What about auto-bind?
cast current namespace into a struct. fill struct fields with bindings with same name and type in current ns.

N - If we follow module generics, can we just enable import without providing types?
Maybe not. because the code is supposed to be working with some types.


N - Review manual and Check order of the manual. Now modules refer to structs. Maybe we should mention them after structs.
Changed/new notations: `!, $, ?` generics, modules, sequence and map type and literals, channels, 

N - Review the new modules notation and how it works with struct. 
What is different and what is common? Also about function's ns.
Explain lookup mechanism for type and symbol names.

Y - `.()` only seems to be useful when dealing with reading from array or sequence in conditions.
`[1, ()->12][condition].()`
`x:=[1, ()->12][condition] #type of x is int|func()->int`
We want to "compress" a union to a specific type.
`x:int|float := ...`
`(@x != @[int]) int.{x}`
compress is too general, the union variable is either a function or non-function. If it is a function, invoke it.
`x := [1, 10][condition]`
`x := [1, expensive_call()][condition]`
Can we use `//`?
`x := [nothing, 1][condition] // expensive_call()`
above means: `if condition then 1 else expensive_call`

Y - `.{}` is for casting, create zero-value and autoBind.
`Int.{x}`
`Int.{nothing}`
`Comparer.{}`
Alternative: Just use the type name as a function.
`y := int(x)`
`z := int(nothing)`
`t := Comparer()`
It is more convenient, shorter and more intuitive.
It is easily separable because type name starts with capital.

N - Can we eliminate `^` notation?
It is supposed to generate a union of all types that embed a specific type:
`^Shape` all structs that embed shape.
example of a function to return name of shapes.
`process := (x: ^Shape)->x.name`
Can't we write it like:
`process := (x: Shape)->x.name`
`process := (x:???`
Maybe this can be solved via generics:
`process := (x: T)->x.name`

Y - In generics, how can we explain our expectations?
e.g. we expect generic type to embed Shape?
```
#module[T].dot
#here we assume T is a struct which must embed Shape
process := (x:T)->x.name
#main.dot
import "module[int]" #!!!
```
we want to make sure type T embeds type X.
solution 1: Let compiler throw errors at compile time.
solution 2: Provide a syntax to check type of T at compile time so people will know.
solution 3: If module does not define type T, this means it can be anything. If it does, T should be substitued with something that embeds that type.
proposal: In generic modules, if T is not declared, it can be anything upon import. If it is declared, importer can substitute it with something that embeds that type.
remove `^` notation.

Y - Can we express expected functions in a generic module?
like, we have a set module on type T, but we expect type T to be comparable.
```
#set[t].dot
#this means T can be anything, but this function must be defined
compare := (a:T, b:T)->int ...
#this means T must contain a data field of type string.
T := {data: string}
#and a function with below syntax
process := (a:T)->int
```

Y - Define a syntax to declare abstract functions.
`process := (x:int)->int`
but there is no body, any call to this will result in runtime error

Y - Can a struct embed another struct implicitly by having fields with same name and type?

Y - Can we Get internal type of union with a more intuitive notation and remove `@`?
`@x` will return type of x (only if x is union typed or generic)
`@[int]` will return integer identifier of type int.
Why can't we combine these two? Is there any use case where we need the integer value?
Why not use casting notation?
`int_val, has_int := int(int_or_float)`
`(int(int_or_float).1) return 100` if var has a int, return 100
Usage of int for type: using map for selecting based on type
`[@int, 100, @float, 200][@x]` this will give 100 if it is int or 200 if float.
But we can do it via chain operator:
`resut := x ~ (a:int)->100, (b:float)->200`
But sometimes we need to return based on the type.
`(@exp = @[int]) return int(exp).0`
why not cast?
`(int(exp).1) return int(exp).0`

Y - For return's condition, shall we use something else? So we have less nested paren?
Right now we use `()` for cast, return condition, function call
`[]` for sequence and map literals, their types, select.
Its better if we can reduce number of usages of `()` and `[]` so they will be less confusing.
`(int(exp).1) return int(exp).0`
`int(exp).1.return int(exp).0`
`int(exp).1->return int(exp).0`
y `{int(exp).1} return int(exp).0`

N - Chain operator. Can we make notation simpler?
We should be able to chain, chain operators together. So surrounding notations like `(...)` is not good.
`f(x,y)`
`(x,y)f(_,_)`
`(x)f(_)`
`(x)( f(_), g(_), h(_) )`
1. `g := (5,9)add(_, _)` => `g := add(5,9)`
2. `(1,2)processTwoData(_, _)` => `processTwoData(1,2)`
3. `({1,2})processStruct(_)` => `processStruct({1,2})`
4. `(6)addTo(1, _)` => `addTo(1, 6)`
5. `result := (input, check1(5, _))pipe(_,_)pipe(_, check3(1,2,_)) ~ pipe(_,check5(8,_,1))`
5. `result := (input, check1(5, _)) ~ pipe(_,_) ~ pipe(_, check3(1,2,_)) ~ pipe(_,check5(8,_,1))`

6. `pipe[T, O] := (input: Maybe[T], handler: func(T)->Maybe[O])->Maybe[O] ...`
7. `inc := (x:int) -> x+1`, `eleven := 10 ~ inc(_)`
8. `add := (x:int, y:int) -> x+y`, `(10, 20) ~ add(_,_)`
9. `(1) ~ process(_)`, = `1 ~ process(_)`
10. `result := error_or_int ~ (x:error)->10, (y:int)->20`

Y - Can we eliminate function forwarding?
1. `draw := (Circle->Shape)`
2. `process := (Polygon|Square|Circle->Shape, GradientColor|SolidColor]->Color)`
4. `draw: func(Circle) := (c: Circle) -> draw(c.Shape)`
Why should we make it simpler by providing this shortcut? We are not oop and should not try to be.
1. `draw := (c:Circle) -> draw(Shape(c))`
2. `process := (Polygon|Square|Circle->Shape, GradientColor|SolidColor]->Color)`
4. `draw: func(Circle) := (c: Circle) -> draw(c.Shape)`

N - Idea: use `~` to return statement for conditions.
`{x<0} return 100`
`(x<0) ~ return 100`
This is not intuitive and will be confusing.

Y - Now that we have changed notation for seq and removed compound literal and generics, this notation is a bit weird:
`data, channel := [wch1, wch2][data1, data2][rch1, rch2][]`
`data, channel := [rch1, rch2][wch1, wch2][data1, data2][]`
What about using a map? channel to data.
`data, channel := [rch1, nothing, rch2, nothing, wch1, wch2, data1, data2][]`
Why not have it as a function? So it can be composed with other functions, extended, ... .
`data, channel := select([rch1, rch2], [wch1, data1, wch2, data2])`
Pro: No need for confusing `[]` notation.
Pro: Using existing mechanisms.
But what will be the signature of this function?
`data, channel := select([
	rch1, ()->rch1., rch2], [wch1, data1, wch2, data2])`
Maybe we also should change notation to read/write in channels. As `[]` will be confusing.
3. Read data `data := reader?`
4. Write data `writer!data`
5. Select `data, channel := [wch1, wch2][data1, data2][rch1, rch2][]`
6. Select `data, channel := [rch1, rch2][wch1, wch2][data1, data2][]`
Maybe we can implement select by using `:==`.
`data, channel :== rch1?, rch2?, wch1!data1, wch2!data2`
No it should not be bound to `:==`. It should be generally possible to calculate and open to using `:==`.
This can be a special notation like `$`.
`data, channel := ${rch1?, rch2?, wch1!data1, wch2!data2}`
But we also need to support variable number of operations.
What if we apply `!` or `?` on an array?
`data, channel := ${rch1?, [rch2,rch3]?, wch1!data1, [wch2,wch3]!data2}`

Y - The bahvior of select is not intuitive and orth.
`data, channel := ${rch1?, [rch2,rch3]?, wch1!data1, [wch2,wch3]!data2}`
Can I use `!?` with arrays, outside `$`? what does that mean?
`data, channel := ${rch1?, [rch2,rch3]?, wch1!data1, [wch2,wch3]!data2}`
We can write name of channels only but it won't be very readable and also for write operations, we will need to mention data to send.
`data, channel := ${rch1?, [rch2,rch3]?, wch1!data1, [wch2,wch3]!data2}`
`data, channel := ${[rch2,rch3]?}`
Also, we may want to send different data to different channels in an array: `wcharray!data`
We can say in `wch_array!` we can either mention one item or a sequence. what if they are channels of sequence? Won't it cause confusion?
Anything that comes after `!` is to be sent. If left side of `!` is an array, right side must also be an array one element per channel. For `?` we can have either a channel or seq of channels.
BUT what if I write `[ch1, ch2]?` outside `$`? Will it acts like a select?
I think it should. `[ch1, ch2]?` means read from any of these which is available to read.
`[w1, w2]![d1, d2]` means try to write to any of these which is available.
result of `[c1, c2]?` is `data, channel` indicating which channel used to read and which data was read.
If you want to combine read and write you need to use `$` operator.
What if we make `$` mandatory for all read/write for single/multi channels?
`data,_ := ${r?}`
`data,_ := ${w!data}`
`data,ch := ${r?, w!data}`
`data,ch := ${r1?, r2?, w1!data1, w2!data2}`
`data,ch := ${[r1, r2]?, [w1, w2]![data1, data2]}`

Y - Review manual document organization. What is the best order of titles and document titles?

Y - Should we have a mechanism to import only some specific items? (Type or binding).
`import "module1"`
`import "module1" {item1, item2, item3}"`
`import "/path/to/module" { name1 := name2, MyType := ModuleType, ... }`
Why not underscore and existing rename syntax?
`import "/path/to/module" { _ := *, MyType1 := ModuleType1 }`
Here we only import `ModuleType1` as `MyType1` and discard other bindings and types.
How can we get rid of `*`? What if we say, by default everything is imported, but if you include `{}` only elements mentioned there will be imported. So you have a change to filter and rename imported identifiers.
`import "/path/to/module" { _ := _, MyType1 := ModuleType1 }` import everything but rename `ModuleType1`
`import "/path/to/module" { MyType1 := ModuleType1 }` only import and rename `ModuleType1`
`import "/path/to/module" { _ := ModuleType1 }` only import `ModuleType1` without rename.
