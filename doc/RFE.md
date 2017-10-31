 
N - Can we simplify conditional return.
```
a := ...
:: 100 #this means return 100
::: 100 #this means return 100 only if the previously assigned binding is true
:cond: 100 #return if cond holds, but then we will have two notations for return :: and :???:
```
And maybe return return keyword?
return = eject
`x := 100 ::`
option 1: Use special variable for return value. but this does not solve early return problem.
`if ( condition ) return 100`
`(condition) return 100`
`(cond):: 100`
`:: 100`
But `()` can be confusing if there is a function call. So we use `{}`.

Y - For chain use `.[]`.
Even if we have single option.
1. `add := (x:int, y:int) -> x+y`, `(10, 20).[add(_,_)]` => `add(10,20)`
2. `({1,2}).[processStruct(_)]` => `processStruct({1,2})`
3. `(6).[addTo(1, _)]` => `addTo(1, 6)`
4. `result := (input, check1(5, _)).[pipe(_,_)].[pipe(_, check3(1,2,_))].[pipe(_,check5(8,_,1))]`
5. `result := error_or_int.[(x:error)->10, (y:int)->20]`
`data.[sequence]`
If the lambda has n inputs and left side has n items:
`(x1).[process(_)]`
`lambda := process(_)`
`(x1,x2,...,xn).[lambda]`

Y - `!` is also used for write only channels. Can we use a better notation for import?
`! "/core/socket"`
`@`
`types and bindings`
`_,_ := "/core/socket"`
What if we only want to import types/bindings? Not very useful.
`_ := @"/core/socket"`
`_ := @["/core/socket", "/core/server"]`
So `_ := @"...."` is a shortcut for a number of definitions (type and binding).
Why not force `[]` just like chain operator?
`_ := @["/core/socket"]`
`_ := @["/core/socket"] { MyType, processData }`
`_ := @["/core/socket"] { MyType, processData := pData }`
`_ := @["/core/socket", "/core/data/{tree, graph}"] { _, MyType, processData := pData }`
What if I write something else on the left side?
Only the items that are mentioned there will be imported
`MyType, processData := @["/core/socket"] { MyType := DDType }`
`ResultItemsOrUnderscore := @[sequence of strings] { rename }`
With this notation we can import one module multiple times:
`SocketStat := @["/core/socket"]`
`openSocket := @["/core/socket"]`

Y - Can we make return notation more intuitive?
`:: 100`
Whats the most intuitive notation to finish execution of current function?
`:: 100`
`{x<0} :: 100`
What if we assume having a magic function?
`ret(100)`
`ret(100,x<10)`
No. its not intuitive.
Maybe we can combine it with chain operator.
So chain operator can accept a special lambda called return.
`x.[return]` means return x from current function.
Its not intuitive.
Anyway this is an exception because it is the only control structure that we have in the language.
option 1: define a magic variable which stores result of the function call.
What if I have access to the variable which is supposed to contain output of current function's call?
`x := process()`
and inside process, I have access to a storage which is supposed to contain result of the function call.
Because of imm rules, I should only assign it once. So as soon as it is assigned, function execution should be finished.
Even if you assign nothing.
Let's call it `*` for now.
`* := 100` means return 100 and exit current function.
But this does not solve conditional part.
I want to assign to `*` if and only if ...
Can we make use of nothing here?
`* := [nothing, 100][condition]`
If we assign nothing to `*` it won't cause return from current function.
So the only way to return nothing will be normal return.
What if I have a function that will return `nothing|int` and there is some situation where I have to return `nothing`?
Just handle it like fp paradigm: rest of the function goes into a lambda which will be only called if we want to return int.
so `* := nothing` wont make sense and is same as `NOP`.
If you want to return nothing, you must do it the hard way:
```
process := (x:int) -> int|nothing 
{
  #if x is negative return nothing
  ...some processing code...
  #if x>100 assign result of lambda1 to output and exit immediately
  temp := [() -> nothing, lambda1][x>100]()
  * := temp
}
```
`* := x`
means assign `x // rest of the function` to the expected output memory location. So we are looking for a shortcut for this:
`* := xyz // rest`
`return xyz // rest`
`:: xyz`

proposal:
`:: := ????`
`{} := 1000` this can also mean empty struct, a bit confusing
`[] := 1000`
`|| := 1000` 
`<> := 1000` ugly
`^ := 1000` 
It's better to be similar/compatible with shortcut notation:
`process := (x:int) -> :: x+1`

N - Can `10` be a function which accepts 10 for every input? Then maybe we can chain to it.
But then it won't have any use.
`int_or_float.[(x:float)->100, 200]` this will always return 200.
`int_or_float.[(x:float)->100, (_:int) -> 200]` this is correct.

N - What if we chain to a function which does not accept that input?
`error_or_int.[(x:error)->10]`?
No. It will be ambiguous what happens if input is error.

Y - Shall we make it mandatory to mention return type if there is a body? `{}`
`process := (x:int)->int { return x+1}`
`process := (x:int)-> x+1` if it is a single expression, you dont need to mention type
Makes code more readable.
Makes compiler's job easier.

N - We can reserve `/lang` for language constructs.
`/core` for core functions.
`/std` for additional functions.

Y - Some basic things need to be covered in core:
1. Hash calculation on any data structure
2. Serialization/Deserialization
3. assert: `assert(x=1, "x must be 1")` - if failed, exit app
`=` by default performs deep comparison of data structures.

? - We can use the same operator for loading modules at runtime `@`. but it won't be able to use `_`.
So if load function's input is not compile-time value, it's output must be assigned to some identifiers.
Loading at runtime: We are not supposed to load source code modules at runtime. they must be compiled.
Any use of `@` at module-level will load at compile time.
`@` inside function will load compiled lib at runtime. and you cannot assign it's output to `_`.

? - Provide a command like `dot doc /core/process/net/socket processFunction`
which gives information about a specific type/binding in a file.
or `dot doc @/my/package/file/main.dot processData` will lookup for that type or function inside modules imported by main.dot or defined inside main.dot, and return it's definition .
It can start from given file and if not found, continue to referenced modules.
`dot doc /my/package/file/main processFunction`

? - For projects like kubernetes or minikube we need to run `make` with all different arguments.
to run tests, e2e tests, make, clean, ...
I think these are mostly job of bash/powershell/... OS scripting.
`make clean` -> `rm -rf .build`
`make tests` -> `dot test ...`
`make` -> `dot build`
`make amd64` ->
`make test-ingeration` ->
Maybe filter `dot test` to execute in a specific dir in source structure.
`make bazel-generate-files` -> external cli tools
`dot build|run|test`

? - Add dependent types.
Applications: binary tree or max-heap or RB tree or abs function as a dependent type, a list of max size N
A dependent function's result depends on it's input.
When that function is invoked or that data type is created, those rules are checked and if they don't match, there will be a runtime error. 
`MyInt := int with (x:int)->x>0`
`check := (x:int)->x>0`
`MyInt := int with check`
What can that piece of code do? Is it only supposed to do some checks without any side-effect?
Can it be (mis)used to work as logging? or security? or caching?
Not caching. Because this is not supposed to add a hidden execution path.
Maybe we can even say that these rules will be executed in parallel in another thread (note that everything is immutable).
So they should not interfere with main execution path in any way (change return value or input or ...).
What about generic types. Can we use this to make sure T type in a generic module, has some functions? This is already provided in generics section.
`PFunc := (x:int)->int with (x:int, y:int)->bool { ... }`
`process: PFunc := (x:int)->int ...`
So for functions, the check lambda's input is function input + function output. and output will be bool. 
`PosInt := int with (x:int)->x>0`
We can thinkg of `(int)->int` as a generator of int. So we should be able to define constraints on that output which obviously needs to rely on input.
`MyFunc := (int)->int with (x:int, y:int)-> ...` this code will be called after each call to a function of type MyFunc.
It should be explicit and obvious what kind of constraint we have for each type.
What if I have:
`MyInt := int with ...`
`MyInt2 := MyInt with ...`
When I create a binding of type MyInt2, both checks will be done.
What if `MyInt` is a part of a struct? Same.
So when a binding is created, these rules will be checked:
1. Rules on the type of struct and it's underlying types and so on
2. Rules on each of it's members.
`p: Point := Point{x:=100, y:= MyFloat(100.2)}`
So checks for MyFloat and Point will be done.
The checks will be executed when a binding of that type is created or casted from another type.
How can we simplify this? Maybe by using a ctor-like function?
So everytime you want to create a BST struct, you must do it through calling function X.
So it won't be applicable to functions.
But what should that function do? How is it suppose to actually "create" that type without calling itself again? We might need to introduce a new notation.
1. Define types normally and have a notation to define constraint for a type/function.
2. Define type with a specific function as ctor which will verify and create it.
```
MyInt := int
MyInt := (x:int) -> MyInt { ... }
..
y := MyInt(100) #this will call MyInt function
```
So we are combining ctor and casting operator.
But having a function named `MyInt` is against the rule.
Maybe we can have this exception. 
Because it also has generality. Because this is a normal function.
What about then I write `x := MyPoint{x:=100, y:=200}`
Will it call MyPoint function?
Of course if there is no such function, compiler will handle it.
But if we have:
```
MyPoint := {x:int, y:int}`
MyPoint := (x:int, y:int) -> MyPoint 
{
  #make sure checks on x and y are satisfied
  #return anonymous struct
  :: {x,y}
}
...
y := MyPoint{x:=100, y:=200} #this will call MyPoint function
z := MyPoint(pt1) 
```
advantage of this method: No need to add a new notation.
Also it is more flexible because we can define other casting options too. For example casting from string to MyPoint.
What about non-struct?
```
MyPositiveInt := int
MyPositiveInt := (x:int) -> MyPositiveInt
{
  #check if x>0
  #return output
  :: x
}
```
The only point of confusion: We are returning an int in a place we should be returning `MyPositiveInt` or anonym struct where we should return `MyPoint`. Who does that part?
We can add another notation to allocate a memory block (low level operations) and set it's value. Of course the developer can also do this to bypass constraint but it will be up to him.
What will be name of that function? What should be it's output type?
So `allocate` is a special function which it's output type must be inferred from context.
Either binding must have a type or it should be in return. So it won't need size.
It will probably be part of `lang` package, not even core.
```
MyPoint := {x:int, y:int}`
MyPoint := (x:int, y:int) -> MyPoint 
{
  #make sure checks on x and y are satisfied
  #return anonymous struct
  :: allocate({x,y})
  #or
  :: allocate({x,y})
}
...
y := MyPoint{x:=100, y:=200} #this will call MyPoint function
z := MyPoint(pt1) 
==========
MyPositiveInt := int
MyPositiveInt := (x:int) -> MyPositiveInt
{
  #check if x>0
  #return output
  :: allocate(x)
}
```
What about a sequence?
`Set := [int]`
```
Set := (data: [int]) -> 
{
  ...
  :: allocate(data)
}
```
basically allocate does not even need to "allocate" memory. Because we already have that data.
We need to re-type an existing binding. Like casting but more low level.
