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

? - We can extend usage of channels for IO too.
Reading from a file is same as reading from a channel which is connected to the file by runtime.
Writing to console is sending data to a channel.
Even for cursor location, we can have a channel. write to it to set location, read from it to get current location.
What about closing channels? Do we need `defer close(channel)`?
print is sending something to console channel.

? - `<int>` for a channel of int. `.<1>`?
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
