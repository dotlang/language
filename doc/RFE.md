`!!` indicates the item is not related to the language (related to compiler, runtime, ...)

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

Y - Shall we standadise `[]` or `{}` in the notation?
`.[]` chain. maye this one can also change to `.{}`
`@[]` import. maybe this can change to `{}`? We really cannot replace `[]` with a sequence and write `@seq1`. 
`${}` channel ops. `[]` won't be good because we may need to have a sequence of channels inside. 
both for chain and import we don't want to let user replace `[]` part with a sequence binding. even if it is fixed. because it won't be readable.
so:
`x.{lambda1, lambda2}`
`_ := @{"mod1", "mod2"}`
`x.{seq1}`
`_ := @{seq2}`
what about this?
3. `_ := @{"/core/std/{Queue, Stack, Heap}}" #import multiple modules from same path`
`_ := @{"/core/std/(Queue, Stack, Heap)}" #import multiple modules from same path`

N - What about prefixing a function call with name of the module?
It will make the code extremely more readable and easy to follow.
Problem: If we have a function `process` defined in two places, we won't be able to have dynamic resolution.
```
#mod1
process := (x:int)->5
#mod2
process := (x:float)->10
#main
_ := @["mod1"]
_ := @["mod2"]
work := (x:int|float) -> process(x)
```
Then maybe we won't need to "rename" single binding/types within the module. we may then only need to rename the whole prefix.
```
sc := @{"/core/st/socket"}
x := sc.Socket{...}
g := sc.process()
gg := sc.b.g #sc is module name, b is a struct and g is a field inside that struct
```
Won't this make the language less flexible? We already have removed runtime polymorphism.
How will this affect autoBind?
Can we think of a module as an interface or a class implementing an interface?
Suppose that we have a HistoryViewer interface which is created when we call "GetHistoryViewer(node)"
And that function creates different types based on the given node. Then we can call `viewHistory` function which is defined for that interface to process history for different nodes.
How can we have this in dotLang?
one way would be returning a function pointer.
```
HistoryData := ArrayHD | MapHD | PrimitiveHD
getHistoryViewer := (name: string) -> HistoryData { ... }
viewHistory := (x: ArrayHD) -> ...
viewHistory := (x: MapHD) -> ...
viewHistory := (x: PrimitiveHD) -> ...
#outside:
g := getHistoryViewer("map")
viewHistory(g)
```
This is related to the expression problem.
How can we add a new operation? simply add the new function in that module or another module.
How can we add a new data type? We can use generics.
```
#processor[t].dot
T := { x: name }
viewHistory := (x: T)->nothing {...}
getHistoryViewer := (name: string) -> T { ... }

#impl.dot
viewHistory := (x: ArrayHD) -> ...
viewHistory := (x: MapHD) -> ...
viewHistory := (x: PrimitiveHD) -> ...

#outside:
_ := @{"processor[MapHD]"}
g := getHistoryViewer("map")
viewHistory(g)
```
Prefixing function with module name will break a lot of things.
In above example, processor expects a function `viewHistory` for type T. It does not specify module name because it does not care what module it is coming from.

N - We can use the same operator for loading modules at runtime `@`. but it won't be able to use `_`.
So if load function's input is not compile-time value, it's output must be assigned to some identifiers.
Loading at runtime: We are not supposed to load source code modules at runtime. they must be compiled.
Any use of `@` at module-level will load at compile time.
`@` inside function will load compiled lib at runtime. and you cannot assign it's output to `_`.

!! - Provide a command like `dot doc /core/process/net/socket processFunction`
which gives information about a specific type/binding in a file.
or `dot doc @/my/package/file/main.dot processData` will lookup for that type or function inside modules imported by main.dot or defined inside main.dot, and return it's definition .
It can start from given file and if not found, continue to referenced modules.
`dot doc /my/package/file/main processFunction`

Y - Make notation for abstract functions more explicit
`viewHistory := (x: T)->nothing {...}`

N - How do we solve expression problem for adding a new shape?
suppose we have Shape which can be triangle and square with area function.
How can we add circle?
```
Shape := Triangle | Square
area := (x: Triangle) ...
area := (x: Square) ...
...
x: Shape := ...
area(x)
```
solution:
```
#mod1[T].dot
T := {Shape}
Shape := {id: int}
area := (x: Shape) -> int { ... }
...
#square.dot
_ := @{"mod1[Square]"}
Square := {Shape, size: int}
area := (x: Square) -> area(x.Shape)

#circle.dot
Shape := @{"mod1[Circle]"}
Circle := {Shape, radius: int}
_ := @{"mod1[Circle]"}
area := (x: Circle) -> area(x.Shape)

#main.dot
_ := @{"circle", "square"}


```
To add a new function like perimeter, without changing existing modules, just implemenet perimeter for all types:
`perimeter := (x: Circle) -> ...`
`perimeter := (z: Square) -> ...`
To add a new shape type, add corresponding module which has it's own type and area function.
Then, how can we define a function which can return any shape?
`process := (s: Shape) -> ...`
can we call process with a struct that includes/embeds Shape?
We need to write forwarding functions.
`process := (c: Circle) -> process(c.Shape)`
`process := (s: Square) -> process(s.Shape)`
This is flexible because we have the option to write or dont write these fwd functions.

!! - For projects like kubernetes or minikube we need to run `make` with all different arguments.
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

!! - Using `@` for both compile time and runtime loading is confusing and not appropriate.
For runtime we have a different path spec than compile time.
Let's do a core function instead.

!! - When loading a module at runtime, you can only import and invke it's functions.
If you need to send or receive data types, you should either have them ready or destruct them.

N - Add dependent types.
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
Like `reinterpret_cast` in C++.
We need to prevent this: `x:SetInt := SetInt([1, 2, 3, 3, 3])`
Why not use a softer enforcement method?
Add a function which creates a set. It will return set and a flag.
So user has more control over how to respond if data is not valid.
With dependent type, either we need to exit app upon error or make things even more complicated.
But how are we going to enforce users must use that function to create a set?
Maybe we shouldn't. Just add a comment.
`#use createSet to create`
`SetInt := ...`
We may also have a convention: `createXXX` will generate that data with validations in-place.

!! - Use visitor design pattern to build code.
Create AST which is a tree.
Then traverse it using Visitor.
Visit root which will send visitor to others too.

!! - We should not need some tool like Bazel which makes development too complicated.
Everything should be handled in the most minimalist way using the compiler.
Study bazel and how it works + Make + CMake + go dep

N - Is there a way to make it more explicit if a binding is function?
`item_one` is value binding
`processData` is a function binding.
`MyData` is a type
but we can have a value binding of type lambda.
`processData := (x:int) -> x+1`
This can be written inside a function.

N - Use `::` for defer too.
`closeFile(f) ::`
Adding `::` at the end of a line will cause it to be executed before exiting function (like defer)
It cannot produce any output, if it has they will be ignored.
```
f := fopen("a.txt")
close(f) ::
:: 100
```
Those lines will be parsed and executed after return is ready to leave the function. So any reference to bindings which are defined after it, is ok.
`close(f) ::` means `()->close(f)`
So why not make this more clear?
Instead of a normal function call, you must write a lambda which has no input and no output.
`() -> { ... } ::`
this lambda will be invoked upon leaving the function.
The `()->` part is really mandatory/extra but better to be there to make things more readable and consistent.
And you cannot write `()->10 ::` because it is supposed to not return anything. Unless instead of 10 you call a function.
But why make it complicated? Any return value will be ignored.
`()->10 ::` is noop.
`()->close(file)` might return something but will be thrown away.
But we can simply define TempFile type which has an appropriate dispose. So if you do not return that file, it's dispose will be executed and done.
Usage of defer in Go: close channel, close temp file, flush logs, test teardown, remove a dir, close socket, restore something in environment we have changed (e.g. PATH), unlock mutex, log something
Now we do not claim to be covering all those cases, but most of them can be done in a dispose.
Call of dispose is one of those implicit things in the language. So shall we force user to do that?
If any binding has a function in the form of `dispose := (x: Type) -> ...` it must be called before function exit.
But it will make it difficult to write functions with multiple exit points.

N - How/when should we call dispose for a binding/channel?
This is similar to how Rust manages resources.
http://blog.skylight.io/rust-means-never-having-to-close-a-socket/
How/when is a resource like file or socket freed/closed?
Suppose `process` createsa file resource, write some, passes it to another function `process2` and writes more.
When will that file be closed? At the end of `process`? Or at the end of `process2`?
Can compiler decide that?
What if `process2` creates some threads to write to that file?
Note that we won't have a file. We will have a write-only channel.
Solution 1: You cannot "pass" a channel to another function. You must close it. So each function will have it's own channel pointing to the same thing. When all of them are closed (which happens when the function is done), resource is deleted/disposed.
Solution 2: You can pass and compiler cannot decide about dispose. At runtime, we will keep a reference count for that channel and when it is zero, dispose will be called.
Maybe this should not be part of language syntax. Maybe compiler/runtime should handle it transparently.
What happens if I send a socket to a channel and read it later?
Will it be a new socket? Same socket? Cloned socket?
When/how will dispose be called for that socket?
It might be difficult for compiler to keep track of this case because it is not static in the code. Reading from channel can be in different functions under different conditions. So a compile time tracking of dispose call would be difficult.
It would be good if we can follow swift model: "In Swift, compiler analyzes the code during the static compilation pass and inserts release/retain code during the compile time." (https://news.ycombinator.com/item?id=12033026)
ARC: Automatic Reference Counting
Disadvantage of ARC is problem with cycle in dependency. But I think in immutable world, you cannot have it (At least without laziness).
Main advantage of ARC: It is simple and efficient (no pause).

N - Q: What can we remove from the language without loosing much of it's power?
`//`
`x := y // z` ~ `x := [z, y][y=nothing]`
`f(x)` `x.{f}`

N - Another way to make differences more explicit.
For types use a keyword so they are clear in place of definition and also in place of usage they are clear by context.
Now we have function, local bindings and function args.
other `some_name` (value bindings, module name, package name)
function `someName`
type `SomeName`

Y - How do we know if a literal is map or sequence when type should be inferred?
`x := ["A", 1, "B", 2]`!!!!
`x := ["A"=>1, "B"=>2]`
`x := ["A":1, "B":2]`

Y - In seq and map literals user should put comma after last item like Go.
Why?
Can't we just eliminate use of comma?
Purpose is make it less error prone to add a single element to the list/map.


Y - We still need a mechanism for general union type.
Example: Writing a test for HistoryViewerFor. The data set will be a map of input types and expected output.
e.g.
```
input := [Kind1, Expected1, Kind2, Expected2, Kind3, Expected3]
#call process for each key in above map and check if output type is Expectedi
x := process(Kind1)
_, done := Expected1(x)
#if done is false, then result's type is not as we expect
```
I need to have a type curator to be used in a sequence or map or ... to indicate that an element can be any of different types. This should be easily done and not require writing a separate module.
What if we accept implicit embed?
`{int}` means a struct that has an int field AND any other struct that has an int field.
But this is the implicity we are trying to avoid.
The only exception is defining a generic module. So it T is `{int}` you can only replace T with something which has an int.
So how can we explicitly state that there is a type which represents a union of all types which embed type T?
`X := { F | F embeds T }`
This should be a new notation.
`!@#$%^`
`^Shape`
Application: define a sequence which can hold any of those types.
`x : [Circle|Square|Triangle]`
Or for our current historyViewer.
In file system we write `draw*` to specify prefix.
`*draw*` means any file that contains `draw` in it's name.
But there, we can have `*draw` or `draw*` too. while here it does not make sense.
This will be our way of handling polymorphism.
`x: {int}` - x is a struct which has an integer field.
`a: {Shape} := ...` can we assign a Circle to a? 
It should be explicit that type of `a` is a sum type.
This will be similar to interface in golang, but the interface can be any struct. AND in a function call, the actual type will be used.
`a: ^{Shape}`
`a: {Shape..}|int`

N - If a type has fields of Shape inside it, can it be part of `{Shape..}` type?
Let's answer this question later when we want to implement polymorphism and subtyping.

N - How can we write a function that given `[T]` and `func(T)->S` returns `[S]`?
```
T := int
S := int
transform := (x: [T], f: (T)->S ) -> [S] ...
```

N - Can we make generic modules more general?
Mechanisms like `stack[T]` and `stack[int]`.
This gives us a mechanism to pre-process a module.
So the broader topic is pre-processing.
So it won't be called "generic". It will be called "import with pre-processing".
So: It can also be used to replace something with a number or ...
So a module is like a function with specific input and it's output is a piece of code.
So we call that function with those arguments (whih can be an identifier or a literal or ...).
```
#stack[S,T,U,V]
...
#main
_ := @{"stack[int, 5, "A", [1, 2, 3]]"}
```
The arguments can be number, string or type names.
But it makes things more complicated (passing string and ...).
So lets assume arguments can only be type names.

Y - Can we treat `@` like a function which accepts types?
I want to make inport of generics more concrete and strong.
`@{"stack[int]"}` is good but enclosing a type name inside string is not very nice.
`@{"stack[T]"} { T := int }`
Maybe we should use `=>` notation. It is more explicit.
Now generics are just renames.
`_ := @{"stack[T]"} { T => int, GenericType => StackGenericType }`
Above, we import a generic module. Rename T to int and GenericType to Stack...
So we no longer forced to include `[T]` in the name of the module.
But it needs to be explicit somehow.
AND There is a big difference between `T => int` and `GenericType => StackGenericType`
in the first case, we specialize a generic type. left side is module type, right side is local type.
second case is rename. left side is modle type, right side is a new type name.
`_ := @{"stack[T]"} { T => int, GenericType => StackGenericType }`
They both do the same thing: Transfer when doing the import. So in the text of the module, T will be transformed to `int` and `GenericType` will be transformed to `StackGenericType`.
Left side of `=>` is a type define in the module.
Right side can be either an existing or a new type.
`_ := @{"stack[T]"} { T => MyCustomer, GenericType => StackGenericType }`
`_ := @{"stack[T]"} { T => MyCustomer, GenericType => StackGenericType, Data => [int], Source => {int,int} }`
OR
`_ := @{"stack[T]"}(int) { DataType => StackDataType }`
`_ := @{"storage[T,S]"}(int, string) { DataType => StackDataType }`
`_ := @{"storage[T,S]"}([int], string) { DataType => StackDataType }`

Y - Maybe we dont need `func` keyword.
`x : func(int)->int := (x:int)-> x+1`
so `(int)->int` is the type and `(x:int)->5` is the literal.

N - What if function arg is a lambda? should it be named like `processData`?
`sortData := (x: [int], compareData: (int,int)->bool ) ...`
so we have types, lambda bindings and simple bindings.

Y - Type `x: {Shape...}` means types that have a Shape inside. if shape is: `Shape := {id: int}`
Then any struct with Shape is included but structs with `id:int` are not.
`x: {int...}` will include structs that include Shape or any field of int.
But how can we refer to that int field? We have to have a nemd which is used to both filter type and access that field.
`x: {id:int...}` union of all struct types that have an id field of type int
`x: {Shape...}` union of all struct types that embed Shape.

Y - Can we have this in a module?
```
adder := (x:int)->x+1
mm := adder(10)
```
No. Bindings at module level must be compile time calculatable.

N - Can we have this in module level?
```
processData, storeData := { (x:int)->x+1, (y:int)->y+2 }
```
No. This cannot be calculated at compile time.

N - Again: Using prefix for union labels.
What are they? `dow := SAT | SUN | ...`.
They are values. Named values.
`int_or_float := int | float`
`xyz := SAT | SUN`
You can define a union type based on the set of possible values. This can be done with `int|float` OR 
`SAT | SUN`.
So SAT and SUN are two value bindings which are implicitly defined.

N - Comma between decl is everywhere:
struct definition: `{x:int, y:float}`
function args: `process := (x:int, y:float) ...`
sequence: `[1,2,3]`
map: `["A":1, "B":2]`
unnamed struct: `{int, float}`

N - We have naming rule but they dont always discriminate function and value.
`dasdas` can be name of a function or value.
`DataPdsadsa` is name of a type.
We have 3 choices: named type, function binding and value binding.
If it starts with capital, it is a type.
but otherwise, there is no definite way to determine whether it is a function binding name or a value binding name.
I think it's fine because after all, functions are bindings too.

N - Replace EBNF with a combination of EBNF and regex format.
`X+` means one or more
`X*` means zero or more
`X?` means zero or one
`[a-z]` denotes char group
`(A|B)` denotes options.
but EBNF is more readable.

N - Can we have this? `x := [1,2, 10..20]`? Yes.

Y - Union: state that it can have a number of choices. Each choice can be a type or a tag.
Types should not interfer with each other.
`MyUnion := int | MyInt` is not good because both types are int based.
For tags, they are just normal bindings.
```
MyCustomer := does_not_exist | string`
does_not_exist := 100
```
If you do not define that value binding somewhere else, compiler will assign some unique value to it.
And make sure syntax matches with it.
But what about conversion or comparison?
`missed := 1`, `not_applicable := 2`, `DataState := int | missed | not_applicable`
So `missed` is 1. What if `DataState` is storing an int of value 1. What happens if I write `ds1 = missed`?
These cannot be values. They should be types. They should be their own types. So they do not interfere with normal types.
And because they are types, you cannot set values for them. But you can write helper functions to convert a union to int value. Union options are all types. So you cannot use `=` for union.
`Missed := int`, `NotApplicable := int`, `DataState := int | Missed | NotApplicable`
so union bindings will have a flag indicating their type (int or missed or na) and a storage for their value.
But for `Missed` type in above example, we just need it's type. No value.

N - Reading the code might be difficult with the model that we have for return and conditions and loops.
About loops: we can simplify them with core/std functions (map, filter, ...)
For condition: `[1,2][x>0]`
`[x>0].{[1,2][_]}`
or functions: `result = ifElse(x>0, 1, 2)`
For return: `:: data` means return if data is no nothing.
```
if ( x>0 ) return
process()
```
can be written as:
`_ := ifElse(x>0, process(), nothing)`

N - Checking regex match can be done in parallel.

N - We can think of Tree as a normal extension to seq (array).
`x: [[int]] := {9, {3}, {12} }`
X is:
```
          9
        /   \
       3     12
```
`x[0]` is the root. we can have multiple roots: `x[1]` can be the second root, OR it can be interpreted as the second element of the array.
`set(x,0,0,4)` means change 3 to 4 (and return a new reference).
`x[0]` is 9
`x[0,0]` is 3
`x[0,1]` is 12 (second child of the first root.
So we may even not need to define any new notation.
any array can be used as a tree.
Operations with tree:
- add node: fn call
- edit node: fn call
- find node: iterate
- delete node: fn call
So what is `x[0]`? Is it value `3` or a sub-tree?
`x[0]` is 3
`x[0,]` is the tree
`x[0,0,]` is the tree with root = 3
so if a function needs a tree, we can send `x` or `x[0,]` or `x[0,0,]`.
So we can say, each element inside an array other than having it's own data like a normal array cell, can have a number of children. Isn't this just like multi-D array?
`[[int]]` is 2-D int array. `x[0][0]`
But it is definitely confusing.
Let's do it in std or core.

N - Is it possible to somehow merge this language with docker as a built-in feature.
So each app will be run inside a container?
Like JVM.

N - Just like the way we need to mark struct literals with a prefix, it will be helpful to prefix function literals too.
Pro: Makes syntax simpler and also reading, parsing the code
`x := process(x,y, (h:int)->h+1)`
Because, when we see `(h` it can also be an expression. we don't know. So parsing becomes ambiguous.
Maybe we can use the same notation, because struct starts with `{` and function decl with `(`.
What about `[`? Shall we use the same to mark sequence/map literals?
`x := [1` here, we don't know if it is a map or sequence literal.
`x := [1:2]` this is a map literal
`x := [1]` this is a sequence literal.
`struct_literal := !{1,2,3}`
`seq_literal := ![1,2,3]`
`map_literal := !["A":1, "B":2]`
`func_literal := !(x:int)->x+1`
But we really dont need a prefix for seq/map literals. 
For struct, we need it because `{` is also used for code block.
For function, we need it because `(` is also used for expressions.
But if we have `(`, for function decl, it is either `()` or definitely has `:` in it. So it is doable to check it.
What about `{`? 
```
x := 
{
  1,2,3
}
```
We also really don't need a prefix for struct. Because if it is a code-block, it will definitely be prefixed with `(...)->`.

Y - Conver comparison part to a table.

N - We can say if right side of `:==` is a call on a function literal, it will be implemented as a thread. otherwise it will be a lightweight thread.
when we start a thread, we need a thread_id to later access, pause and communicate with the thread. 
I think all of stop, pause, cancel, ... can be handled by channels.
Golang does not let developer decide whether it will be a thread or a goroutine.
We can say, if you call dispose on output of `:==` the corresponding thread will be terminated.
The scheduler will start with one thread and increase/decrease number of threads based on the load, cpu usage and number of lightweight threads.

N - Shall we make untyped structs more explicit?
`point1 := {100, 200} #untyped struct`
`point1 := {100, 200} #untyped struct`
Because they can be used for function output. And will be confusing with code block.
`process := (x:int) -> ~{x, 100, 200}`
`process := (x:int) -> !{x, 100, 200}`

N - Confusion between union and list:
What about a function which accepts a list of int?
`x: ((int))->int := (tt: (int) ) -> tt[0]`
`x: (int)->(int)|float` what's the output of x's type? is it a list of int? or int? (and parens are there just to prevent confusoin.
`x: (int)->(int)|float`
What is this? `x: (int|float)` a list of int or float.
Maybe we should enforce a rule that a union type must use either primitive or named types.
Because combining `|` with `()` makes reading it difficult and confusing: `t := (x:int)->(int)|float`
Is `float` part of function output? or is it part of possible types for t?

N - Make sure `..` can accept vars too.
If it is literal, compiler will generate code. Else runtime.

N - What should be name of a binding which is union of value and function?
`U1 := int | (int)->int`
`handlerData: U1 := getData()`
U1 cannot be invoked. So it should be named like value binding.

N - If we have a union of two function types with same signature, can we cann the union?
No. Because parts of the union must be different.
`TT := (int)->int|(int)->int`???
It's not a valid type for union.
Also, arg name does not affect type of a function.

Y - Maybe we should add prefixes to make reading code and writing compiler easier.
`x := (y:(int)` at this point, we don't know if y is a func that accpets ints or it is a list of int.
`t := (x:int) -> {` at this point, we don't know if function returns a struct literal or `{` is beginning of a type definition.
`t := (x:int) -> [` at this point, we don't know if function returns seq of something, or a seq literal.
`t := (x:int) -> {x}`
`t := (x:int) -> {int,int}...`
struct literal ~ code block
list ~ function input
seq type ~ seq literal
1. struct literal ~ code block
one solution: Literals should be prefixed with `.` or `_`. For function and struct and sequence and list.
This would solve most of problems except between function and list (To solve this, we should change list notation).
If we change notation for list, we won't need prefix for function literal.
```
f := _{10,20,30} #this makes sense because _ is a placeholder instead of which we can use any type
f := Point{10,20,30}
IntS := [int]
h := _[1,2,3] #can we use a type here? maybe. to explicitly state it's type
h := IntS[1,2,3]
h := [int][1,2,3]
t := _<1,2,3> #also here, same as seq
IntL := <int>
t := IntL<1,2,3>
t := <int><1,2,3>
```
So each literal (struct, sequence and list), should be prefixed by it's type or `_` to denote it should be inferred from context.
So if we have a function which expects `{int...}` and I have an int x, I can simply write: `_{x}` to convert it to an untyped struct literal.
suggestion: 
Extend `_` notation to be place holder for literal type for compound literals
use `_` prefix for list, seq and struct literals. It can be replaced with a real type to indicate their type.
But still it is not context-free to decide whether something is a literal!
advantage of this: if we want to send a typed compound literal to a function, we can do it inline.
`process(CustData[1,2,3])`
rather than: `x: CustData := [1,2,3]` and then `process(x)`
If you see identifier then `(` its a function call.
identifier, then `[` seq literal
identifier, then `<` list literal.
What about these?
`{int,int}{1,2}` Does it make sense?
We have this notation for structs. `p := Point{10,20}` because we sometimes need to specify type of a struct literal.
The reason we are using this notation is to be consistent with structs. but what if we remove that one too?
Then maybe we can use `_` everywhere.
`p:Point := _{10,20}` infer the type of the struct literal
`p := _{10,20}` infer type. which means its untyped struct
`p: [int] := _[1,2,3]`
`p: <int> := _<1,2,3>`
Then what happens when we want to update a struct? (e.g. point with x and y)
`new_point: Point := oldPoint{y:=100}`
`new_point: Point := _{old_point, y := 100}` this acts like embedding but in values. So we embed values of old_point, and later we update `y` to some other value. we can embed multiple elements here as long as they do not interfer.
So the rule will be `name: type := _{ binding1, binding2, x := 100, y:=200, z := binding1.z+1}`
suggestion: 
- Every non-primitive data litearl (seq, list, map, struct) must be prefixed with `_`.
- If you need to, explicitly specify type of a struct binding.
- To update a struct use :`new := _{old, field := value}` notation.

Y - For abstract functions, it should be possible to set `{}` on the same line
`process := (x: T)->bool { ... }`

N - Can we replace generics with `...` notation?
for primitives we can use seq/map/list
problem 1: function expectations.
problem 2: `...` notation works with named fields. we cannot just embed some int inside `{}` and send it to method.
problem 3: we cannot enforce relation between data
test criteria: stack, search, sort, binary tree, set, reverse map, filter hashmap.
```
T := {...} #this means every struct
Stack := [T]
push := (s: Stack, t: T) -> Stack
pop := (s: Stack)->T
search := (s: [T], x: T)->bool
sort := (s: [T], cmp: (T,T)->bool)->[T]
reverse := (m: [T,S])->[S,T]
filter := (m: [T,S], filter: (T)->bool)->[T,S]
TreeNode := {data: T, children: [TreeNode] }
Tree := {root: TreeNode}
```
p1: function expectations:
```
T := {...}
process := (x: T)->bool { ... } #this is an abstract function
#here find method will need to call process in it's input.
find := (g:T)->...
```
We can say that if we have `process: (x:int|float)->bool` function and `process: (x:int)->bool` function, calling `process` with `int|float` function, which is actually `int` should call the second one, not the first one. Actually, in this case, one of these two must be abstract, or else there will be a conflict. So if `int|float` function is abstract, then `int` will be called.
p2: can we use `...` with unnamed fields?
`T := {int...}`
`process := (x:T)->x.0`
But then, if we call process with `{a:int, b:int, c:int}` what should happen? We can throw compiler error. Because we expect one int field but we have three. If you want to be exact then: `T := {a:int...}` then it would be fine.
So when using `{int...}` this means the target type must have only one `int` field, else compiler will complain.
problem 3: constraints. Maybe we should do it in code.
`T := {int...}`
`process := (x:T, y:T)->T` 
The above does not imply that x and y must be of the same type. As long as they have an `int` it should be fine.
suggestion: remove phantom types and generics and extend `...` notation to include anonymous fields, state the processing rule for abstract functions if there are multiple candidates (e.g. abstract for `int|float` and normal function for `int`).
We can use notation: `T := ...` to have a union of all possible types (like `void*` or `interface{}`). 
So the only remaining problem: We cannot enforce type relationships. Type safety.
For example, someone can push int to a stack of string.
How can we say that types should match?
`push := (x: T, s: Stack)` No. It cannot be done here. should be handled in the code.
advantage: We no longer need that notation for importing modules. The module file naming becomes easier.
disadvantage: We cannot have type safe generic code.
advantage: This can also handle primitives, untyped structs and state function expectations.
Does this make sense? Write some real-world code to see if it makes sense to write code.
The sample should incorporate all features (different types, function expectations, typed and untyped structs) and different use cases (stack, mergeSort, tree, filterMap, ...)
pro: With modules, we will need a lot of renames.
```
SetElement := {...}
Set := [SetElement]
compare: (SetElement,SetElement)->int := ...  #this notation is better for abs func. we don't need arg names for abs func
create := (s: [SetElement])-> Set ...
add := (s: Set, d: SetElement) -> s 
{
  duplicate := compare(d, s[0])
}
...
g: Set := []
h := add(s, 12)
```
con: Without generic modules, its not obvious what functions are expected.
The other way around: Can we replace `...` notation with generics?
`T := {int, ...}` union of all types that have only one int field.
can be replaced with absfunc.
`getData: (T)->int`
All types that embed Shape:
`T := {Shape,...}`
`getShape: (T)->Shape`
And this notation is more flexible (although may need more code and boilerplate).
all types that have `name:string`:
`T := {name:string,...}`
replace with absfunc:
`getName: (T)->string`
So you can explain the interface both in terms of operations and data using absfunc.
And due to the definitions that we have, you can only use absfunc if it involves a generic type. Or else, any call to it will result in runtime error. 
counter proposal: use generic modules, remove `...`, use absfunc notation.
problem: How can we have a sequence of different shapes?
If I use `T := {int...}` How can I access that int field inside a binding of type T?
There is currently no way to do that because I don't know the actual type. Except if I use a function to do that.
```
T := {int...}
getData:(T)->int := ...
```
So whenever using `...` notation, there should be an absfunc to provide access to that fixed part.
So, `...` notation is just for documentation and compiler enforcement. We cannot use that fields unless a function is provided for us. The only advantage of `...` is to have a sequence/list/map of multiple types.
Can we replace `...` with: `all types that provide this absfunc?`
```
#abstract type (union of every type)
T := ...
#this is a filter for T, so not every type can be inside T but only those types that have this function defined.
getData:(T)->int := ...
```
Example: Implementing a Set of shapes (circle, square, triangle, ...)
```
#set[t].dot
T := ...
getShape: (T)->Shape := ...
equals: (T,T)->bool := ...
Set := [T]
add := (s: Set, item: T) -> Set 
{
	...
}
# main.dot
_ := @{"set[t]"}(Circle)
_ := @{"set[t]"}(Square)
_ := @{"set[t]"}(Triangle)
#now we have T which can be anything, we must have defined getShape and equals for last three types
#so, can we say when we import multiple instances of the same module, abstract elements are not regenerated? No.
#importing set for Circle, will re-write T everywhere with Circle.
```
We have three tools: Generic modules, abstract types and functions and polymorphic union notation.
The best case is we can replace/reduce them with/to a single tool which is good enough to provide major functionalities of all three.
major functionalities: generics, constraints, polymorphic types.
tools: generic modules, absfunc, abstype, `{...}`.
Can we achieve polymorphic types without generics?
```
T := ...
getShape: (T)->Shape := ...
Shapes := [T]
```
Replacing `{Shape...}` with abs func, makes compiler checks difficult.
Shall we remove abs func? 
suggestion: Abs funcs can be only used inside generic modules and must involve the generic type, so compiler can check them when the module is imported.
Now, can we replace generics with abs-type and abs-func?
We can have polymorphic data types. we cannot have type-safe at compile time.
```
#set.dot
T := ... #T can be anything (primitive, struct, ...) 
T := {...} #T can be any struct
T := [...] #T can be any seq
T := [..., ...] #T can be any map.
T := [int, ...] #T can be any map with int as key
#below two functions reduce the set of possible types in union of T.
getShape: (T)->Shape := ...
equals: (T,T)->bool := ...
Set := [T]
add := (s: Set, item: T) -> Set 
{
    ...
}
# main.dot
_ := @{"set[t]"}(Circle)
_ := @{"set[t]"}(Square)
_ := @{"set[t]"}(Triangle)
```
The concept of abs-func and abs-type are both confusing and difficult to reason about. Nothing prevents the programmer to define some of them in another separate module. Then how will they be applied? What will be scope of their effect in filtering possible types for an abs-type?
The `{int...}` method is better because it has a single point of declaration.
What we eliminate abs-func?
Generics will have no way to indicate their expected functions. No problem. We accept that.
So we have: Generic modules, and `{int...}` notation to define a polymorphic sum type.
Shall we have `...` for seq and map too?
Maybe we can use `_` instead.
`T := {_}` any struct
`T := {x:int, _}` any struct with `x:int`
`T := [_]` any sequence
`T := [_,_]` any map
`T := [int, _]` any map where key is int and value can be any type.
`T := _` union of all types.
`T := {_} | [_]` union of all structs and all sequences
Then, how can we enforce types in generic modules?
```
#stack[t].dot 
T := _ #you can have stack of any type
Stack := [T]
push := (s: Stack, t: T) -> ...
#main.dot
_ := @{"stack[t]"}(int)
```
The fact that we "re-write" types in generic modules has a conflict with the polymorphic union notation.
If we replace, then what's use of having `T := _`?
Another solution: Get rid of generics, provide tools to check type safety at runtime. Only have generic types.
proposal: Remove generic modules and abs-funcs. Introduce polymorphic-union-type and core functions to check type safety.
```
#stack.dot 
T := _ #you can have stack of any type
Stack := [T] #you can store anything inside a stack
push := (s: Stack, t: T) -> ...
#main.dot
_ := @{"stack"}
```
or:
`paint := (item: {Shape, _})->... #this can accept any struct that embeds a shape.`
Does this make sense? Write some real-world code to see if it makes sense to write code.
The sample should incorporate all features (different types, function expectations, typed and untyped structs) and different use cases (stack, mergeSort, tree, filterMap, ...).
Relying on a set of functions as some kind of criteria is fragile because it can be exetended very easily and will not be obvious to the reader. We should rely on data, because type definition and declaration is a centralised piece of code.
So the idea of abs-func is not good. But abs-type is doable. 
problem1: How can I have generic container? or map function? or generic search/sort/filter?
problem2: How can I specify my expectation for a type? e.g. when I have a type like `{Shape, _}`?
problem3: Will this affect performance?
What do we do in Java's generics? We specify `T` generic arg, and in this case, we cannot asume anything about it.
But if we say `T extends Shape` it means T has data and operations of Shape.
Similarly, if we say `T := {Shape, ...}` it means type T will embed a Shape. But this only is about data. It doesn't translate to functions. Because the rule of dynamic dispatch is a call to `process(Circle)` will not be forwarded to `procesS(Shape)` if it's not explicitly forwarded.
So if I have `T := {Shape, ...}` in my code and I have `paint(Shape)` function. I cannot call `paint` on type T's bindings, because it may not be forwarded.
So if we have:
`Shape := {...}`
`Circle := {Shape, ...}`
`process := (s: Shape)->int ...`
calling `process(c)` where c is a Circle, if we don't have `process(Circle)` will call process(Shape).
This is basically multiple inheritance and can be difficult to dispatch unambiguously. but can be decided at compile time.
But having polymorphic types we can write:
`process := (s: {Shape,...})->int...`
Inside above function, we can have access to `s.Shape`.
So if a module has `T := {Shape, ...}` the functions can make calls for functions defined for Shape. By calling `process(tvar.Shape)`. Now, if circle has it's own process, what should happen?
If we call `process(tvar.Shape)` then `process(Shape)` will be called.
If we call `process(tvar)` then `process(Circle)` will be called (if tvar is a Circle).
Now, every type that embeds Shape, must have `process` defined. If they don't? Compiler error (?)
Let's have this rule: If you call `process(tvar)` and type of `tvar` is `{Shape, ...}` then you must have at least `process(Shape)` defined. and every type that embeds `Shape` must have this function defined.
We can use concept of abs-func not as an interface definition, but just as a normal and simple place-holder. like `...` in perl. So it means, I know I have to have this function, but in runtime, I am almost sure it won't be called. If it got called throw a runtime error.
So, if we have `process(Shape)` only, and someone calls `process(tvar)` where type of tvar is `{Shape,...}` but it contains a Circle, what should happen? Runtime will call `process(Circle)` because tsvar's type is Circle.
If we have `process(int|float)` and someone calls `process(int_var)` then what should happen?
WE can say, `process(int|float)` will be compiled to two functions. `process(int)` and `process(float)`. As a result, we cannot have `process(int)` custom defined.
Similarly, if we have `process({Shape,...})` we cannot define process for Circle.
But if we have `process(Shape)` we can have `process(Circle)`.
What about non-structs?
How can we define a sequence of multiple possible types?
Extending this notation to seq/map and list?
How can I define a map of int to anything? `T := [int, ...]`
And how can I extract something from this map? 
`x:... := tvar[1]` ? 
If we return back to template modules, we will loose the benefit of a polymorphic data structure where we can have a seq of all Shapes.
What about structs?
`T := [{Shape,...}]`
A real world example: Compiler with an AST. We can have different types of AST. Base type is AST, but we have AddNode which embeds AST and some additional data. `ShiftRightNode := {AST, value: int}` ...
Now, we want to have a list of ASTs in the code. and call `generate` on each one of them. This should be redirected to different versions of generate function based on AST type.
```
AST := {...}
AddAST := {AST, left: string, right: string}
SubAST := {AST, left: string, right: string}
compile := (x: AddAST) ...
compile := (x: SubAST) ...
items: [{AST, ...}] := parseModule(...)
forEach(items, (x: {AST, ...})->compile(x))
#another way to implement, which is not as clean as above
Compiler := (x: {AST, ...})->string
compiler: [ASTType, Compiler] = buildCompilers()
items: [{AST, ...}] := parseModule(...)
forEach(items, (x: {AST, ...})->compile(compilers[x.type]))
```
Let's limit this notation to structs only. If you need something more, write a typed function for that purpose (e.g filtering a map).
How can we write a map/filter function?
`T := ...`
`filter := (x: [T], f: (T)->bool)->[T]`
`map := (x: [T], f:(T)->T)->[T]`
We either should accept the notation of `interface{}` or `void*` or `anything`. OR We have to have a template module system.
The `anything` notation is stronger, because we can do more things with it, but it's also more complicated.
Template modules, is simpler but less powerful/expressive.
What if we allow polymorphic union notation only when importing a template module?
So inside tempalted module, everything looks normal.
When using it, we just use types and functions. But when importing, we pass a type builder (`{Shape, ...}`).
Why not have both? A template module which you can import with any type and a notation to define a dynamic union of a set of types based on criteria.
The template module, defines the generic type and some abs-func for it, which determine expected interface from outside world. When you import it, the abs-funcs should be replaced with existing functions with the same name and signature.
Generics is when we want to have a single implementation for different types.
But if we need multiple impl for multiple types, we use sum types.
Can't we replace abs-func with inputs of the function? That makes writing code a bit more difficult, but we don't need to define abs-func then. But for data, it's good.
`process := (x:[int, {Shape,...}])->int`
input to process is a map of int, to anything that embeds a Shape.
These two concepts are really inter-related. Generic modules can define the fields that their type should include.
`{Shape, ...}` also indicates that.
The point is, generic module will be imported with a single type.
Now how can we have a stack for all shapes?
```
#stack[t].dot
T := ...
push := ...
pop := ...
#main.dot
_ := @{"stack[t]"}({Shape, ...})
```
q: Can/shall we extend `...` notation to non-struct types?
q: How can we implement the compiler example now?
```
AST := {...}
AddAST := {AST, left: string, right: string}
SubAST := {AST, left: string, right: string}
compile := (x: AddAST) ...
compile := (x: SubAST) ...
items: [{AST, ...}] := parseModule(...)
forEach(items, (x: {AST, ...})->compile(x))
```
So: `...` when we want a single type represent multiple types.
generics: when we want single imp work with different types.
If a generic Set module expects a `equals` function pointer, and we have multiple functions with same name but different types, when importing `${"set[t]"}(int)` it will translate to expecting: `equals: (int,int)->bool`. So only passing `equals` as an argument when working with the data is enough.
We can combine `...` and generics, for example when we want to have a Stack of Shapes.
q: Can we extend `...` to other types? e.g. seq/map/list/primitive?
`...` means union. For primitives, we can write `T := ...` in a generic module, which means `T` can be specified anything.
But outside generics, just write `int|char|string|bool|float`.
For map/seq?
`{Shape, ...}` means union of all types that embed Shape.
`[Shape, ...]` means what? sequence of all types that embed Shape?
No. Because `...` is tied to "embed" concept, it works only with struct.
But it can be combined into map/seq.
Do we need such a thing for map/seq which does not use embeds concept?
I don't think so. 
`{X,Y,Z,...}` means union of all struct types that embeds all three of X, Y and Z.
Is this a valid type? `{...}`. No. It shouldn't be. Because it does not have any useful information.
If we have `T := {Shape}` inside generic module, we can import it with `Circle` or `Triangle` or `{Shape, ...}`.
The only meaningful criteria to define a dynamic type is based on embedding. So it should be applied for structs.

Y - Shall we prohibit calling a function literal at the point of declaration?
```
result := (x:int)->x+1(100) #store 101 into result
```
or
```
fn := (x:int)->x+1
result := fn(100) #store 101 into result
```
Y - Shall we add shift right and left?

Y - q: can we have `process(int|float)` and `process(int)`? no.
This can be useful for specialization.
In this case, calling `process` with `int` will call the second item.
What should happen if we call `process` with `int|float` binding which holds an int?
The real question is: Will we dispatch a function call based on the static type of a binding (e.g. `int|float`) or based on it's dynamic type (e.g. `int`).
Note that the dynamic type can never be `A|B`. 
What about this?
`process := (x: {...})->...`
`process := (x: Shape)->...`
If we have `process(int|float)` in fact we have two functions: `process(int)` and `process(float)`. So manually adding `process(int)` will cause trouble and ambiguity in calling the function.

N - How shall we implement dynamic dispatch in case of unions?
int(x) if x is bool, call int|1 because id of bool is 1
sometimes, we do not know id of x. x has a static id but it can also have dynamic id

N - Can we have `{Shape, int, ...}`? No. It should either be unnamed or named for all items.

Y - Can we have `{int, ...}` as sum type of all types that have only one int field?
And access it via `.0`?

N - so assume we have int(g:float) and int(p:bool)
when we call int(float_or_bool) shall we replace it with int|1 o int|2?
(assume id of float is 1 and id if bool is 2)

solution 1: replace int(float_or_bool) with int|99 where 99 is id of float|bool type.
If that function already exists, then fine. If it does not exist but we have int(bool) and int(float) write a small llvm ir code
like this:
```
int|99 := (x: bool|float)
{
	if ( realType(x) == int ) return int|1
	else return int|2	
}
```
And we can make it inline, so it will have minimum overhead.
The details of implementation will depend on memory layout for non-primitive variables.
One proposal: every reference (non-primitive) will have a prefix which contains these data:1
1. dynamic type
2. size in bytes
3. reference count
```
int|99 := (x: bool|float)
{
  load %0, *x
  cmp %0, INT_CODE
  je int_call
  call int|FLOAT
  ret
int+call:
  call int|BOOL
  ret
}
```
so in more complicated cases this would be something like this:
```
int|99|22|88 := (x:int|float, y:string|char|bool) -> int
{
  if type(x) = int and type(y) = char: int|22|99(x,y)
  else if type(x) = float and type(y) = bool: int|11|33(x,y)
  else ... 
}
```
What if we have `save(int|float)` and call `save` with a float var?
compile looks up and finds we only have `save(int|float)`. So?
One way is to break down all functions that have sum type inputs. So `int(int|float)` will be broken down to two functions. 
`int(int)` and `int(float)`. Then we call the one based on static type or dynamic type if it is a sum type.
Another way is to cast float var to `int|float` and call `save(int|float)`.
```
//case 1
process := (int)->int ...
process := (float)->int ...
process(int_or_float) #call with dynamic type
//case 2
process := (int|float)->int... #break this into two functions, call with static type for non-unions, dynamic type for unions
	process := (int)->int ...
	process := (float)->int ...
process(4)
```
So when there is a call like `process(x)` if x is union, get it's dynamic type. Else get it's static type, result is T.
Then call `process|T`.

Y - If chain operator has multuple candidates and none of them match then what?
`int_or_float_or_string.{(int)->int, (float)->int}`?
Compiler error. At least one of the candidates must match. 

Y - 
If we have a variable of type `{Shape, ...}` Can we access `x.Shape`? Yes.
If we have a variable of type `()->int|()->float` can we call it and store result in `int|float`? Yes. But this makes things a bit confusing. Because then we don't know how we should name a union which all cases are function.
If we have `(int)->int|(float)->float` can we call it with `int|float` and store result in `int|float`? No. But you can write a helper function to do that.
This is similar to the way chain behaves.
if you have `(int)->int|(float)->float` stored in x you can write: `int_float.{x}`???
But we cannot put a union inside chain operator. Can we? Shall we extend that? No.

Y - If we have `T := {int, ...}` then in the code we have `tvar.0` how should we access that?
Maybe we have `Type1 := {x:string, y:int}` and `Type2 := {tt:int, pp:string, z:float}`.
Then `.0` cannot be translated into a single fixed offset. But the compiler will re-write code for each type.
So if we have: `process := (x: {int,...})->int`
It will generate these two functions:
`process := (x: Type1) -> ` where `x.0` will be offset 10.
`process := (x: Type2) -> ` where `x.0` will be offset 0.

Y - Memory layout for a struct which embeds other structs.
We need to have `x.Shape` refer to a real Shape object.
`Circle := {Shape, r: float}
```
At 0: 	type_id := 34
	embed_type1 := 83
	embed_offset := 12
At 12: (Shape data)
	type_id := 83
	name: ...
	id: ...
At 18:
	r: float
```
If Circle embeds Shape, 


N - The absolute minimum that I need to write a compiler in dot:
- LLVM bindings
- File I/O
- Struct, Seq and map
- `...` notation for generic union
- multi module compilation
Parts that we don't need:
- Import from other sources, filtering and rename
- Chain operator, union type

N - Another helper to help decide whether it's function body or struct.
struct/expression is defined on the same line if it's return expression.
function body must be started from the next line.
So if after `->` we see type and newline, then it's a code block. Else it's expression.

N - Use cases for dotLang: Hadoop, Spark, Cassandra, Hive, HDFS, Arrow, Oozie, YARN, HBase, Redis, ...
Distributed systems
Big data systems
Backend as service
Search (ES, ...)
web service, API server
Log management
Monitoring (grafana)
Most of Apache projects
Couch DB
Kafka


N - Add support for LLVM-IR based code in function to make bootstrapping easier.

Y - For generic modules with general type, we can re-use `...`:
`T := ...`

N - Suppose we want to write dotLang compiler. What do we need at minimum?
1. Ability to call core functions
2. Read/Write file
3. LLVM integration
4. Write a function in LLVM IR
5. Call another function
6. Struct and union
- Operators: `@{}`, `|`, casting, `[]`, `::`, 
What we don't need?
- Generics
- Lambdas
- GC?
- Import renames and filters
- Named types
- Concurrency
- Struct composition
- Chain operator
- Operators: `//`, `..`, `...`, `=>`

N - Even if at some point we need a dedicated build system, we can use dotLang to describe the build process and steps.

N - The compiler will use `.build` directory for cached compilations, output, intermediate code, temp files, ...
Instead of something like `mvn clean` you can just do `rm -rf .build`
Maybe we need to have some resource files beside the output. We can order compiler to also save output final executable in a specific folder which is set up with all required files.
We can have `pre-compile.sh` script and `post-compile.sh` script which will be executed before and after compilation.
If we have dependency to v1 and v2 of a library which is on github, when we clone it, they will be on the same dir.
`_ := @{"github/lib1/v1"}`
`_ := @{"github/lib1/v2"}`
We can clone the same repo into different dirs and for each dir checkout corresponding branch.
We can clone with `-b v1 --shallow 1 --single-branch` into a specific directory.

N - Green threads needs a runtime (scheduler, threads, assignment, queues, ...).
Is it possible to achieve this without a runtime?
We are not forced to follow go or CSP approach.

N - Using channel for all types of comm makes it easier to mock something.
For example if a function works with a socket, we can instead pass a sequence-backed channel for test purposes.
We can follow this approch for every side effect (e.g. get time, get random number, ...).

N - Tip for including predefined functions in compilation:
`LLVMCreateMemoryBufferWithMemoryRange` create a memory buffer pointing to compiled bitcode for predefineds
`LLVMParseBitcode` read memory buffer and create a new module.

N - Again: Can we replace generics with `...` notation?
Example: Writnig a stack/set, writing map/filter function, writing AST compiler
```
#stack.dot
T := any
Stack := {data: [T], sp: int}
push := (s: Stack, x: any) -> ...
pop := (s: Stack)->any ...
#set.dot
T := any
Set := {data: [T], size: int}
add := (s: Set, equals: func(any, any)->bool) ...
remove := (s: Set, el: any, equals: func(any,any)->bool) ...
```
We can, only if we allow `any` notation and become a dynamic type language.
Template modules allows the language to remain static typed.

Y - Replace `...` for type with `nothing`. So any type which is `nothing` can be replaced with any other type.
Maybe we should replace `...` with `nothing` for abs-func too.
Because right now `...` is used in polymorphic sum types and means "anything can sit here".

N - Can we use `(x)` instead of `[x]` to access elements of seq or list or map?
Ocaml uses `x.(1)`

N - Can we use the same notation for struct literals with some different separator?
`x: Point := ["A" 1 2.9]`?

N - Can we think of generics as a map? where key is type and value is a module?
so `stack[int]` will give me implementation of a stack (define in stack module), specialized for int type.
q1: What if the generic module has multiple types? e.g. map function or a hashmap module?
q2: What would be the type of this map? what's the key? what's the value?
We can say that all types can be represented as integers. So key is int.
Also we can extend a map to have multiple keys. so `[int]` is a seq, `[int, string]` is a map where key is int and value is string. `[int, float, string]` is a map where key is int and float and value is string. or maybe we can simply use an untyped struct. so `[{int, float}, string]` is a map where key is int and float.
`stack: [int, ?]`
right now we have:
`_ := @{"stack[t]"}(int)`
which imports types and bindings into current module.

N - A notation to define singly linked list.
It is not about simplicity, but we want to provide an easy mechanism to handle data structures with regards to immutability.
This can be used for stack, queue, tree and graph, as long as one way processing is enough.
This cannot be a FIFO queu because FO means change the whole data structure.
```
d:{int} = [1,2,3] #1 -> 2 -> 3
x := 0;d
```
what will `d` mean? 1 or the whole list?
How would it be done now?
```
type Node := {data:int, next: Node} | nothing
g: Node := Node{data:=10, next := nothing}
h: Node := Node{data:=20, next := g}
t: Node := Node{data:=30, next := h}
d := t.data
d := t.next.data
```
rewrite:
```
type Node := (int)
g:Node := (10)
h: Node := (20,g)
t: Node := (30,h)
d := t.(0)
d := t.[1..]
```
How can we define a tree?
```
type Tree := ({int, (Tree)})
```
We can treat linked list like seq becaus conceptually they are the same:
```
x: (int) := ~[1,2,3]
x[0] is the first element
x[1..] is a linked list.
So is x[1..5] but this notation will need a copy of whole list
Same notation can be used for seq.
y := [5, 3]&x is for merging lists. You can merge any two lists but best peformance is when the first item is smallest.
x[5..] is also a linked list. It can be a sequence if x is a sequence.
x[0] is the first element of a linked-list or a sequence.
So how can we differentiate this with a seq?
[int] is a sequence of int
(int) is a linked list of int
So tree can be defined as:
Node := ({data: int, children: (Node)})
tree: Node := [{5, [{6, ...]]
tree.children[0].children[2].data
```
How can we convert a list to seq or seq to list?
`x: [int] := [1,2,3,4]`
`y:(int) := ~[x]`
`z: [int] := [y]`
`x[start..]` slice of seq or linked list. O(1) for both assuming start is small.
`x[start..end]` slice. O(n) for list, O(1) for seq (assuming seq includes length too)
`x[..end]` slice. O(n) for list, O(1) for seq (Assuming seq includes length)
`x[index]` read element from seq/list. O(1) for seq, O(n) for list
`x&y` merge two seq/lists. for seq O(m+n), for list O(m) where m is size of `x`.
Algorithm to insert something at specific index in linked list:
```
insert := (lst: <int>, idx: int, data: int) -> <int>
{
  :: lst[..idx]&_<data>&lst[idx+1..]
}
```
Idea: Use `~[int]` to specify list of int type. How does this combine with seq, map, channel types?
Idea: Use negative numbers to refer to elements before end.
`lst[-3..-1]` `-1` index points to the last element.
`lst[-3..]` returns last three elements of the sequence or list.
`~[int]!` a write-only channel which can write list of int.
`[~[int]]` a sequence of a list of ints.
`~~[int]` a list of a list of ints.
`[~int, string]` a map of list of int to string.
`{int}` an unnamed struct
`[int]` sequence of int
`(int)` list of int
`(int)!` a write-only channel which can write list of int.
`(int!)` a list of write-only channels which can write int.
`[(int)]` a sequence of a list of ints.
`((int))` a list of a list of ints.
`[(int), string]` a map of list of int to string.
How should we discriminate between seq literal and list literal?
`x := [1,2,3]` this is a sequence
`x := [1;2;3]` this is a list
`x := [[1,2], [3,4], [5,6]]` a seq of seq
`x := [[1;2], [3;4], [5;6]]` a sequence of list
`x := [[1,2]; [3,4]; [5,6]]` a list of sequence
What if it has only one element?
`x := [1]`?
We can say, by default it is sequence. unless it has `;` at the end:
`x := [1;]`
What about this notation?
What about using `[T;]` notation for a list?
`[int]` is a sequence of int
`[int;]` is a list of int
`t := (x:int) -> [` at this point, we know `[` is for a type.
`x := (y:[int;]` we know y is of type `[int;]`
`<int>` list of int
`<int>!` a write-only channel which can write list of int.
`<int!>` a list of write-only channels which can write int.
`[<int>]` a sequence of a list of ints.
`<<int>>` a list of a list of ints.
`[<int>, string]` a map of list of int to string.
`<int!>?` a read channel which gives you a list of write-only channels.
suggestion: 
- use `<int>` to indicate a single linked list and `<1,2,3>` for it's literals. `[]` for access.
- extend `&` to merge lists too.
- Add slice notations for list and seq: `s[start..end]` with optional start and end.
- explain `O()` complexity of index access and slices for seq and list
```
x: <int> := _<1,2,3>
x[0]
x[1..]`
```
Don't forget , list literals should be prefixed with `_` too.
struct, seq, map and list literals should be prefixed with `_`.
Maybe it's better to use `[]` for lists too and minimise using `<X>` notation.
We can force `,` or `;` at the end of the last item to make a distinction for 1 elements.
Let's not add them to the language. All of these can be easily implemented with a struct and some helper functions.
And not having them as built-in types, is not a big deal 99% of the time.

Y - Add to spec: If all types of union are funtction pointer with same input, you can treat it like a function.
And the binding should be following function naming convention.

Y - The general rule in replacements is: you can replace something with something consistent.
If it's a function, alternative must have the same signature.
If it's a struct, alternative must include same fields.
If it's a union, alternative must have same or less choices. `int|float` can replace `int|float|string`.


Y - State that type replacement must be with a compliant type in generics.
So if original type is `T := nothing` you can replace T with any type.
But if it's `T := {int}` then you must replace it with a struct that has only one int field.

Y - Should we have an operator for power?
In perl and python they use `**`.

N - Can we replace `&` operator with a function?
What should we do for import with a variable path?
`_ := @{prefix&"stack"}`
We can use the notation introduced above to remove ambiguity.
`_ := @(string{prefix, "stack"})`
`_ := @(prefix & "stack")`

Y - Can we remove naming rule for generic module files? and make generic module import something general?
So how can we specify which type is for which argument?
`_ := @{"a[s,t,u]")(int, int, float)`
`_ := @{"a"}(T := int, S := int, U := float) { Type1 => Type2 }`
It is a bit messy!
`_ := @{"a"}(T => int, S => int, U => float, Type1 => Type2 )`
It's better to surround these inside `()` because `[]{}` can be used in the right side of `=>` if we want to map to array or struct types.

Y - Think more about use cases for `=>`. In what cases do we need to use it?
Is it for types? value bindings? fn bindings?
```
#stack.dot
StackElement := nothing
Stack := [StackElement]
push := (s: Stack, e: StackElement) -> ...
pop := (s: Stack) -> StackElement
test := (x:int) -> x+1
#main.dot
StackElement := int
Stack := [StackElement]
push := (s: Stack, e: StackElement) -> ...
pop := (s: Stack) -> StackElement
test := (x:int) -> x+1

StackElement := float
Stack := [StackElement]
push := (s: Stack, e: StackElement) -> ...
pop := (s: Stack) -> StackElement
test := (x:int) -> x+1

_ := @{"stack"}(int)
_ := @{"stack"}(float)
```
Do we need to rename functions? I don't think so. Because there can't be conflict in functions as their signature will be different, unless we have functions which are independent of the type argument. which is not banned.
Solution:
1. If a function is repeated with same signature and body, compiler will handle it.
2. If a function is repeated but with different signature, it should be fine.
3. If a type is repeated with same definition, it's fine.
4. If a type is repeated with different definition (`StackElement := int` and `StackElement := float`), then there is no way of distinguishing them. That's when we need to rename them.
```
_ := @{"stack"}(int){StackElement => StackElementInt }
_ := @{"stack"}(float) {StackElement => StackElementFlt }
#or
#compiler imports these but there will be no way to access StackElement directly as it has conflicts
_ := @{"stack"}(int)
_ := @{"stack"}(float)
#you can alias them. So @ notation can be used to reference a type inside a module.
StackElementInt := @{"stack"}(int).StackElement
StackElementFlt := @{"stack"}(float).StackElement
```
But it's confusing to have access to elements inside a module via `@`. Why not have access to functions?
a value binding has a precise type information. but a function is not explicit. it may refer to different locations. The exact place can be specified if we know the types of inputs.
Another way: Name can also be a parameter. So a generic module can expect a type and a name (or sets of).
```
#stack.dot
StackElement := nothing
Stack := [StackElement]
push := (s: Stack, e: StackElement) -> ...
pop := (s: Stack) -> StackElement
test := (x:int) -> x+1
#main.dot
_ := @{"stack"}(StackElement => int, Stack => IntStack)
_ := @{"stack"}(StackElement => float, Stack => FloatStack)
```
So you can import any module, and during the import, you can provide some transformations. They will be in the form of `A => B` where A is a symbol (type name or binding name) and B will be a new symbol. Any instance of `A` will be replaced by `B`.
This can be used both for generic types and also for renaming symbols to prevent name clash.
But there are two types of `=>`: Type settings and identifiers.
If we have `StackElement := nothing` then `StackElement => int` it will generate: `StackElement := int`.
If we have `Stack := [StackElement]` then `Stack => IntStack` will generate: `IntStack := [StackElement]`.
So rename can be applied to the left side of `:=` (for non-generic types) or right side (for the generic type).
We cannot treat them the same with same notation.
When we import a module, we will need to renamed some symbols and change rvalue for some others.
For example change rvalue for `StackElement` and rename `Stack` type.
```
#stack.dot
StackElement := nothing
Stack := [StackElement]
push := (s: Stack, e: StackElement) -> ...
pop := (s: Stack) -> StackElement
test := (x:int) -> x+1
#main.dot
_ := @{"stack"}(StackElement := int, Stack => IntStack)
_ := @{"stack"}(StackElement := float, Stack => FloatStack)
```
`_ := @{"a"}(T := int, S := int, U := float) { Type1 => Type2 }`
And let's not limit the `:=` assignment to types. It can be used for any binding.
Another way: The module can specify things that can be renamed on the right side. But it will need a new notation.
So it is possible to use a function in place of import type settings.
We can say `^` means re-write or re-define a binding.
What if we keep everything inside import operator boundaries?
```
_ := @{"a", T := int, S := [int], U := {float, string}, Cmp := (x:int) -> x>0), Type1 => Type2, Type3 => Type4 }
```
The `{}` notation makes it a bit ambiguous with a struct. Can't we think of it like a pseudo-struct?
What if we treat it like a function which must only contain static bindings like module levels?
Because import must be calculated at compile time.
But it will become very verbose. We want it to have a small footprint.
```
_ := @{"a"}
(
    T := int, S := [int], U := {float, string}, Cmp := (x:int) -> x>0), 
    Type1 => Type2, Type3 => Type4 
)
_ := @{"stack"}(T := int)
```
Some definitions should be applied inside the module and some should be applied from outside.
We prefix names that refer to something inside the module with `^`.
So instead of `=>` notation we have `^` notation.
Why use `()` for import operator? `[] () {}`? It is better to think of `@` as a compile-time evaluated function.
```
_ := @("a/"&module_name)
{
    ^T := int
    ^S := [int]
    ^U := {float, string}
    ^Cmp := (x:int) -> bool
    {
    	:: x>0
    }
    ^Pred := myPredicate #replace internal function with local function
    MyType1 := ^Type1  #prevent name clash, we may have two Type1 identifiers. So rename one of them
    MyType2 := ^Type2
    ^X := ^P #X definition inside module should be pointing to P inside the module
    ^G := CustomerData #e.g. for generic types (stack of customer)
}
#if it's one item, you can write it inline, for more you must write it in a block
_ := @("stack"){^T := int}
```

Y - Remove embedding?
Can't we just write `Circle := {s: Shape, ...}`. In forwarding we need to write `c.s`.
And in sum type we write:`{s: Shape...}`.
But it means that the field must be named `s` which is difficult to maintain.
What if we write: `{_:Shape,...}`? Then how can we access the embedded Shape?
What if we have two constraints? `{_: Shape, _: Color,  ...}`?
Or similar to the way we write `{int, ...}`, we write `{Shape, ...}`.
Then we can refer to it using `.0`.
`x: {Shape, ...}`
`x.0.shape_name`
So we can add a field name criteria too.
And there will be no special behavior for embedded structs. Just include that.
Can we write this?
`process := (x: {Shape, ...}, y:int) -> process(x.0, y)` 
to forward process function for all types that embed a shape!!!
So you don't really need to write that for every single type.
So this is the proposal:
1. Remove the concept of embedding. 
2. In poly. union explain that `{Shape, ...}` means all types that have one field of type Shape which can be accessed using `x.0` notation.
3. Explain in forward function notation, you can use pol. sum type to do a "group forwarding".
pro: More minimal language as we no longer have a special notation: `Circle := { Shape, id: name}`
Every field inside a struct must have it's own name.
Just like conditionals and loops, for subtyping you have to do it yourself. Which makes it a bit more verbose but more flexible too.

Y - q: What is `{1}`? Is it a sequence or an untyped struct? That's why we need a prefix. `[int]{1}` is a seq of int. `{int}{1}` is an unnamed struct.
q: `process := (x:int) -> {` at this point, we don't know if `{` is start of a struct type or a literal?
Why not make it this: `[]` for types and `{}` for literals?
`[int]`, `[int, int]`, `[x:int, y:int, z:float]`
`{1,2}`, `{1:2, 3:4}`, `{x:1, y:2, z:1.1}`
So if we see `process := (x:int) -> {` we will know that `{` is for a literal, not a type decl.
What happens to polymorphic union? `{Shape, ...}`? Maybe replaced with `[Shape, ...]`.
But in this case we don't know if `[int, int]` is a map or untyped struct.
What if we use `[int:int]` for map type?
Then what about `{1}`? or `{1,2}`? is it sequence or struct?
`{_:1, _:2}` is a struct literal.
`{1,2}` is a sequence literal.
`{x:1, y:2}` is a struct literal.
`x := {1,2,3}`
`x := {1:2, 3:4}`
`x := {a:1, b:2}`
`x := {1,2,3}`
`x := {1:2, 3:4}`
`x := {a:1, b:2}`
`h := { {1, 2}, {3, 4}, {5, 6} }` how can we merge then?
Or we can use `[...]` for literals and `{...}` for types.
`{int}`, `{int:int}`, `{x:int, y:float}` types
`[1,2,3]`, `[1:1, 2:3]`, `[x:1, y:2]` literals.
No. This does not seem very beautiful.
`h := { {1, 2}, {3, 4}, {5, 6} }` How can I say whether this should be parsed as a 2-D int array or 1-D int array?
Maybe we can re-introduce `&`? Now that we are eliminating type prefix.
`h := { {1, 2}, {3, 4}, {5, 6} }` 2d int array.
`h := { {1, 2} & {3, 4} & {5, 6} }` 1d int array.
It might even be better because we are explicitly stating a merge, rather than specifying a type for the literal.
`[string:int]` and `[age:int]`! The second one seems fine but the first one looks weird.
`{"A":1}`, `{age:12}`
`[string, int]` -> It will be confused with a struct with two fields.
`[int*]`, `[string:int*]` because it can have repeated items.
How can we denot empty seq/map/struct?
`{}` what is this? empty seq or empty map or empty struct? It should be stated on the left side or in the context.
`x := process({})`. If we have two process functions which accept seq and map, then which one should be called?
`{,}` is empty sequence.
`{:}` is empty map.
`{_}` is empty struct.
We have this problem in the current manual too! `[]` can be an empty sequence or empty map.
What about types? What is `[]`? It is definitely not seq or map. It is a struct type which does not hold anything.
Shall we use `[string]int` for map type? No. It's better it type is fully contained and surrounded.
`x,y := {_:10, _:20}`
`[string:int]` and `[age:int]`! The second one seems fine but the first one looks weird.
`{"A":1, "B":2}`, `{age:10}`.
**`[]` implies repeatition**. That's why using it for struct seems weird.
But why not use `[]` for seq/map and `{}` for struct type and also for all literals?
Proposal:
- Use `[]` notation for seq `[int]`, map `[string:int]`
- Use `[]` for seq and map literals: `[1,2,3]`, `["A":1, "B":2]`
- Use `{}` for struct `{string, int}`, `{name:string, age:int}`
- Use `{}` notation for struct literals: `{1,2}`, `{age:1, rr: 1.1}`
- Keep `&` to merge two sequences.
- Use `{}` for polymorphic sum types notation: `T := {Shape, ...}`
- Literals don't need a prefix.
- Struct update: `new_pt:Point := {old_pt, x:100}`
- If you want to enforce type, mention it on the binding.
- `{}` is empty struct, `[:]` empty map, `[]` empty sequence. Exact type of map or seq should be inferred from context.
New things:
- Literals don't need a prefix.

N - How does an untyped struct which has a Shape look like?
`MyType := {int, float}`
`MyType2 := {Shape}`
`x: MyType := _{10,2.3}`
`y: MyType2 := _{ _{id:=10} }`
Using `_` as prefix is not really elegant. Can we make it better?
- Every non-primitive data literal (seq, map, struct) must be prefixed with `_` or a type name.
- To update a struct use :`new := _{old, field := value}` or `new := Type{old, field := value}`.
`x := IntArr[1,2,3]`
`x := MyMap[1:2, 3:4]`
`x := Client{a:=1, b:=2}`
`x := _[1,2,3]`
`x := _[1:2, 3:4]`
`x := _{a:=1, b:=2}`
`h := _[1, 2]&_[3, 4]&_[5, 6]`
`r := process(_[1,2,3])`
Can we make `_` part of surrounder notation?
In Go, you must prefix array literal with it's type: `primes = [6]int{2, 3, 5, 7, 11, 13}`
Why not follow the same for array and map?
`x := [int]{1,2,3}`
`x := Arr1{1,2,3}`
`y := [int, string]{1:"A", 2:"B", 3:"C"}`
`y := Map1{1:"A", 2:"B", 3:"C"}`
`z := {int,int}{1,2}`
`z := {x:int,y:int}{1,2}`
`z := {x:int,y:int}{x:1,y:2}`
`z := Point{x:1,y:2}`
`z := [{int,int}]{ {1,2}, {3,4} }`
`h := [int] {1, 2}&arr2&arr2`
`h := [int] {1, 2, arr1, arr2}` merge arrays
If we have `[int]` where an `int` is expected, it means merge into parent struct.
`h := [[int]] { {1,2}, {3,4}, arr1, arr4}` this makes arr1 and arr4 third and fourth elements in `h`.
`h := [[int]] { {1,2}, {3,4}, { arr1, arr4} }` this concats arr1 and arr4 and makes the result the third element in h
`h := [int] { arr1, arr2 }` this will merge arr1 and arr2 into h.
Again: Why do we need a prefix for literals?

N - If we have `process := (x: {Shape, ...})->int`
can we call it with an untyped struct which contains a Shape?
Can we say, even untyped structs have an internal hidden type which can be used when calling functions?

Y - Can we remove auto-bind too?

Y - Remove abs-func and use function ptr as function arguments.
In OOP when I say: `where T: MyClass` it ensures both data and operations on type T.
Because `MyClass` has both data and methods.
But here, I can say `T := MyStruct` and T will have a specific fields.
```
#test.dot
T := {data:int}
process := (x:T) -> x.data+1
save := (x:T) -> process(x)+1
#main.dot
myProcess := (x: MyData)->x.data+2
_ := @("test") 
{ 
    ^T := MyData
    ^process := myProcess
}
```
So even if a module has some functions on generic type T, the importer can replace them with appropriate functions, if the implementation is different.
```
#test.dot
T := nothing
equals := (x:T, y:T) -> false
store := (x:T) -> ...
#main.dot
equals := (x: MyData, y: MyData)-> x.h = y.h
_ := @("test") 
{ 
    ^T := MyData
    ^equals := equals
}
```

N - Can we simulate `...` with generics?
When I write `T := {x:int}` it means any import of this module can replace T with something that has `x:int`.
So basically it is `{x:int, ...}`, but not as powerful.
```
#forwarder.dot
T := {Shape}
process := (x:T)->process(x.0)
```
q - How can I define an array which can contain different shapes?
e.g. a stack of shapes
```
#stack.dot
T := {Shape}
Stack := [T]
push := ...
pop := ...
#main.dot
_ := @("stack")
g: Stack := [my_circle, my_square, ...]
```

N - Do we really need prefix for literals?
`t := (x:int) -> {` at this point, we don't know if function returns a struct literal or `{` is beginning of a struct type definition.
`t := (x:int) -> [` at this point, we don't know if function returns seq of something, or a seq literal.
`t := (x:int) -> {x}`if x is a type, this is struct type, if x is value, it is a struct literal
And if we do, should it be their type? or a specific character?
`x := () -> [1,2,3,4]`
`x := () -> ["A":1, "B":2, "C":3]`
`x := () -> {name:"A", age:12}`
`x := () -> () -> 100` `x()` will give us a function which when called will give us `100`.
`x := () -> () -> int ...`
`x := [1,2]&[3,4]&[5,6]`
If I can write a `parseType` function in the code, then it would be easier.
`x: ... := ` call `parseType` if you see `:` after binding.
`x := (...) ->` call parseType if you see `(` after binding.
`x := (...) -> ....` call parseType after `->`. If it fails, it's an expression.

N - nothing operator
`x := a // b`
`x := [b,a][a=nothing]`
`//` and chain operator are "helper" operators. They don't make something imopssible, possible.
They just make possible things easier to do.
`(6).{addTo(1, _)}.{save}.{update}.{print}`
`(6).{addTo(1, _)}.{save}.{update(x,_)}.{print(y,_)}`
`(y, (x, (6).{addTo(1, _)}.{save}).{update}).{print}`
Why not use seq notation? Because arg type can be different and using `[]` will be confusing.
Why not use a struct literal? Because one of the arguments can really be a struct literal and again cause confusion.

N - can I write: `x,y,z := array1[0,1,2]`?
It looks good but has few benfits.
`x,y,z := map1[3,2,1]` - what if one of keys is missing?

N - Add more links to README. e.g. in `::` explanation we use `//`, link to corresponding section.

Y - Deciding whether union cases are functions with same input can be confusing sometimes.
`x : (int)->float|(MyInt)->float`
Are all options with the same input? `int` and `MyInt` may be defined similarly but they are not the same.
So let's enable safe access to a union only for data members.
`T := {int}|{int, float}` then `x.0` will refer to the int field.

Y - Is the decision about fallback from named type to underlying type good?
`MyInt := int`
`process := (x:int)->x+1`
`g: MyInt := 12`
`process(g)` this will call `process:(int)->int` because we don't have a `process:(MyInt)`.
What abuot this?
```
MyHash := [MyInt:MyInt]
process := (g: [int:MyInt])->nothing
process := (g: [MyInt:int])->nothing #having both these is ok because we claim they are different types
g: MyHash := ...
process(g)
```
can we call `([int:MyInt])`?
What if we also have `process: ([MyInt:int])->nothing`?
This can also happen with structs.
In such cases where there are multiple candidates, compiler will issue a warning.
This spreads like a tree. root of the tree is the original type e.g. `MyHash`. If we expend any of it's sub-types it will be a new child.
```
         ---------[MyInt:int]-------[int:int]
         |
MyType----
         |
	 ---------[int:MyInt]-------[int:int]
```
`MyType := [MyInt:MyInt]`
So if we don't have a process defined for `MyType`, we should look for `[MyInt:MyInt]`.
If not, we process everything there one step.
So for example if it was initially: 
`MyType := [MyInt2:MyInt]`
`MyInt2 := MyInt`
`MyInt := int`
Then the order would be:
`process: (MyType) ->`
if not found: `process: ([MyInt2:MyInt])->`
if not found: `process: ([MyInt:int])->`
if not found: `process: ([int:int])->`
if not found: error.
we can say normal types have a type-code which is a number which does not end with `0`.
named types' type-code is type-code of their underlying type shifted left one bit.
so if int is `1`, `MyInt := int`'s code is `10` but this will assign same type-code to different types.
Each type must have a different type-code. So it cannot be inferred from a type-code, the underlying's type-code.
Another way to handle function call resolution: `MyType`, if not found `[int:int]` the final underlying type.
So for example if it was initially: 
`MyType := [MyInt2:MyInt]`
`MyInt2 := MyInt`
`MyInt := int`
Then the order would be:
`process: (MyType) ->` or `process: (MyType|XYZ)->`
if not found: `process: ([int:int])->`
if not found: error.
Does this work well with union types? it should.
method 2 advantage: it is easier to understand and less confusing.
`MyCustomer := {MyInt, MyInt2, MyType}`
final underlying type of this is: `{int, int, [int:int]}`.
But still is causes problem: ?
- What about when I move type X from module M1 to M2 but don't want everyone to update their code.
```
#M1
MXX := @("M2") { MXX := ^X }
X := MXX
#other places
_ := @("M1")
x: X := ...
```
This works.
But what if there are methods on the old `X` type which I want to update? I can define them in M1. I do not rely on type fallback in function call resolution.
But if the user module, calls functions which operate on `X`, then what?
```
#M1
TempX := @("M2") { TempX := ^X }
X := TempX
process := (x: X)->x.data+1
#other places
_ := @("M1")
r: X := ...
process(r)
```
The real process function is defined for type `X` defined in `M2`. Not `X` defined inside `M1`.
But in the user module we are calling `process:(X)->`where X is defined in M1.
Another way: We try names as long as there is only one option. From the point that we have multiple options, we will jump to the end.
so:
`MyType := [MyInt2:MyInt]`
`MyType2 := MyType`
`x: MyType2 := ...`
`process(x)` will first try for `process:(MyType2)` if not found
`process:(MyType)->` 
if not found: `process:([MyInt2:MyInt])`
if not found: `process:([int:int])`
Also if we have `MyType := [int:MyInt]` it still can continue normally without a jump.
So we can define these terms:
simple type: A type which is one identifier (primitives and named types and sequence)
complex type: A type which involves multiple simple or complex types (hash, struct, union)
named type which is defined using `:=` notation.
underlying type of a named type is what comes after `:=`.
final underlying type of a type: continue in underlying type until there is no named type involved.
How can we make it simple and minimal? Even if it means developer needs to write some more lines?
Answer: No redirection, just lik go.
If you have a MyType and call `process` on it, there MUST be a `process:(MyType)->` function defined.
If `MyType := int` and you have `process: (int)->` it is not used.
If you want to use it, forward.
`process := (x:MyType) -> process(int(x))`

Y - How does named types work with import?
If I write `X := @(...)` is X a named type?
It should be. Or else we will have a separate meaning for import types.
But if I import stack and capture Stack type, any function defined for it won't be available for me.
```
StackType, push, pop, create := @("stack") { ^T := int }
f: StackType := create(100) #this function's output is StackType which is defined inside the module stack. But I am storing it's output in another StackType!
g := push(f, 100) #I cannot call push because push expects a StackType defined in that module but I am passing f which is StackType defined in the current local.
```
Solution 1: When importing, you cannot filter. You have to import everything because a module is a coherent set of functions and types. You can however rename thigs.
Because if you write `A := @...` then A will be a new type and it will conflict with type and function call dispatch.
So, we should have:
`@("stack") { ^T := int }`
Can't we make it an expression? It is just like a function which returns `nothing`.
Also, aliasing the type during import, creates a new type! which causes problem.
`@("mymodue") { MyType := ^ModuleType }`
solution 1: Accept that. but then how can I pass a `ModuleType` to functions inside the module?
What if we only allow rename?
`@("mymodue") { ^ModuleType2 := ^ModuleType }`
If we had the concept of type alias we could handle this easily.
We have the same thing in functions.
Function A can forward to B: 
`A := (x:int) -> B(x)`
Or we can alias it:
`A:(int)->int := B` this is a normal binding of type function, we simply assign a binding to another binding.
But for type we only have definition/spec: `A := B`.
`@("stack") { ^StackType1 := ^StackType }`
`@("stack") { ^StackType2 := ^StackType }`
Either we have to have type alias or type rename notation in import.
type rename is simpler and has less side effect.
type alias has more impact on the language.
```
@("stack") 
{ 
	T := int
	U := [float]
	StackType => IntStack
}
```


N - What can go wrong if we dont fallback for named types?

N - 
`T := int|float!`
`T := (int|float)!`

Y - We are using `:=` much more than `=`.
So why not use `=` instead of `:=`
we can use `:=:`?
`:=` -> `=`
`:==` -> `==`
`=` -> `=?` Other options: `eq`, `?=`, `:=:`,
`!=` -> `<>`
`>`, `>=`, `<`, `<=`
we already have `and, or, xor, not`
This will affect import, struct, type and binding decl, 
`a,b,c = process(1,2)`
result:
- remove `!`
- replace `!=` with `<>`
- equality using `=?` 
- use `=` for bindings `x:int = 12`
- use `:=` for named types: `T := int`
- replace `:==` with `==` for parallel execution

Y - Add type alias
what about type alias?
option 1: no type alias. we only have `:=` for named types and in import, you have to use `=>` for rename
option 2: `:=` to define named type, `=` to define type alias. so 
```
T = int
process = (x:int)->x+1
process = (x:T)->x+2 #ERROR! we already have process(int)
```

Y - Better import and generics
then we can get rid of `=>` and use `=` to alias from within a module
```
IntStack = @("stack"){T := int}.StackType
```
But separating import and rename is a bit confusing. What if I rename and do not import?
Treating import result as a huge struct which has functions and types is a dead-end path I have discussed before. It makes everything much more messy.
What if we can type alias inside import block?
```
@("stack")
{
	T := int
	MyIntStack = StackType #this is confusing! 	
}
```
if we use type alias with `=` can we enable `:=` for bindings too? the what would it mean?
If I import module X and rename type A to B, and someone imports my module, will it B be available to them? no because they are not exported.
but maybe I can replace `=>` with `:=` to indicate alias.
For the same reason we want to replace `:=` with `=` for bindings, for the same reason we should replace it for types.
So let's just eliminate `:=` everywhere. It was result of trying to be similar to Go but there is really no reason for that.
`T = int`
`x = 5`
what about alias?
`x = 5` is like an alias
`x = ()->5` is like a definition.
`T = int` is a new named type definition which is different from `int` but has same binary repr.
`T <- int` to define a new alias.
We need type alias and `=>` is not enough. So let's replace `=>` with something more flexible.
But how can we alias something inside imported module? in Go you just put a name behind import and everything is under that new name But we cannot have module contents "under" some name. Because it will interfere with function call dispatch.
adding a new notation like `%` to refer to symbols inside module is not good too, because we may have imported them with generic type replacements.
```
IntStack = @("stack"){T := int}!StackType
#or
TT := @("stack") {T:= int}
IntStack = TT=>StackType
```
none of these are simple and minimal.
`T = int` defines a new named type
`T: int` defines a new type alias- this is better.
What about import?
`IntStack : @("stack"){T:=int}.StackType` what comes after `:`, can be it mixed with `=` to add a new named type?
it should be possible.
so if we have `:` to define type alias, we should think of a notation to refer to a symbol (type or binding) inside a module.
we wanted `@` to be an expression. It can give us an expression if we extend the notation to refer to symbols inside module.
`_ = @("stack"){T=int}::*` this gives you all symbols inside the module and they are defined in this module (but they are not exported). it is confusing whether these are exported or no. maybe we should remo `_ =` from the beginning.
`@("stack"){T=int}`
`IntStack = @("stack"){T=int}::StackType` this refers to `StackType` inside that module.
`IntStack : @("stack"){T=int}::StackType` this refers to `StackType` inside that module.
we should be able to refer to a binding or a type inside a module.
can we encapsulate all information needed to import a module into something (e.g. a struct) and re-use it?
`data := {"stack", ["T":int]}`
`@(data)` to import
`IntStack = @(data)::StackType`
when importing we want to replace specific symbols (T, Cmp, ...) with something else (int, or a function literal, ...).
but treating them as string will not be strong typed.
If we use `T = int` notation, maybe the user asks, can i use `T:int`? Why not? Why?
We should be using something else, not `=` or `:` to indicate "replace". 
Maybe we can use a hash. key can be a string (symbol), but value? it can be anything and it can be a type name!
Also, we don't want to REPLACE the symbol. we want to relplace it's right side.
So if we have `T = int` we want to replace it `int` with something.
Why not make it this: in the module definition, user marks place-holders.
`T = !Q` then user can replace `!Q` with something else. But what about conditions?
What if I want to say, `T` should be a struct that has `Shape` field?
we should not require module write to write any specific code to indicate it's a generic module.
So they write:
`T = int` or `T: nothing`
when importing module, we cannot change `=` to `:` or vice versa.
So we need another notation to indicate what T should be.
`@("stack"){T => int}`
what if we add a notation so we can have a map of string to type id/... ?
can we eliminate type alias? If we can, generics will be simplified and we can simply use `=` notation in generics import.
`@("stack"){T=int}`.
Let's limit import generics to types. You cannot replace functions like `Cmp` with a function literal. 
Or let's treat import as a mini module. So we put some definitions before import to affect what import does and at the end we can return symbols we need:
```
IntStack : @("stack"){T = int}
```
`IntStack, _ = @("stack", T=int, StackType, _)`this answers all questions but is messy and not simple.
Idea: Let's limit functionality of generics and make the whole problem simpler, scope smaller, and solutions simpler.
e.g. type must always be nothing. but how does this simplify things? no notation needs to be changed if we remove this rule.
proposal: mini-module surrounded by `{}` which anything without `_` is exported.
So we can include and rename and export renamed identifiers.
So:
```
{
	T = int
	StackType = [T]
	T = float
	IntStack = StackType
}
```
is a mini-module which exports `T=float` and `IntStack` to the outside module.
but how can I imply overwriting an existing def? Why `T=float` overwrites `T=int`?
Proposal: I can "pin" a type/binding before import. So the import cannot overwrite them.
```
{
	#definitions here will be visible to outsitde but are not exported.
	T = float
	@["stack"]
	IntStack = StackType
}
```
So in other words, if inside a module/mini-module there are multiple defs for a type/binding, the first one is in effect.
```
T = string
{
	T = int
	@["stack"]
	IntStack = StackType
}
{
	T = float   #isn't this overriden by the previous one T=int?
	@["stack"]
	FloatStack = StackType
}
```
the rule of mini-module and overriding are not simple.
```
d = ["stack"]
@d
{
	#definitions inside this block have higher priority than ones inside the module
	T = int, #this will repace current definition for T
	IntStack: StackType #this will be added/updated and exported
}
or:
@["stack"]
what if we want to compress the defs?
@["stack"] { T = int, IntStack: StckType }
```

N - follow up
with this maybe i can use `:=` for type alias.then I can remove need for `=>` for rename. as I can alias a type using this notation.
or `=` for value binding and `:=` for types.

N - If a generic type is `nothing`, you can replace if with anything.
if it is `int|nothing`, you can replace with `int`, `nothing` or `int|nothing`.

N - we should also simplify chain operator
chain with only one func.
support `#int` notation or similar to be able to use a map to dispatch funtion call.
`typeId(x)` will return internal type of a variable. it is compile-time for non-unions and runtime for unions.
return is an integer. `^int` returns type id of int.
`x := [^int:10, ^float:20][typeId(v)]`
note than union choices must be either primitive or named. 
why not use type name instead?
`x := [int:10, float:20][type(v)]`
or ?
maybe its better to have chain with multiple candidates.
option1: chain operator with multiple functions
option2: simple chain operator, function to get type of a union, notation to get type id of a type, ...
q: can we do the same thing when defining a normal function binding?
```
process = (x:int)->12, (y:float)->19
process(int_var)
process(float_var)
proces(int_or_float)
```
vs
```
process = (x:int)->12
process = (y:float)->19
process(int_var)
process(float_var)
proces(int_or_float)
```
```
int_or_float.{process}
```

N - instead of a scomplex op with 3 funcionalities add 3 simple oeprators.

N - Chain operator `.{}` braces can be confused with lambda/function literal.
So can `[]` be confused with seq/map literal.
`x.{add(8,_)}`
`x.[add(8,_)}`
The purpose of chain operator is to make complex function calls more readable.
`f(x,y,z)`
`(x,y,z).{f}`
`(x,y,z).{f}.{g}`
`(x,y,z).{f}`
`x.y.z.{f}`
`(x,y).z.{f}.t.u.{g}` => `g(f(x,y,z), t, u)`
`x.{f}`
`x.(y).(z).{f}`
So you can end a chain with `.{}` to make call.
or `.()` to add an argument.
we have two things: 1. call function, 2. add argument
lets make it simple and minimal.
take this Haskell example: `sort -n . uniq -n . sort . awk '{ print $5}' . grep tcp . netstat -n`
another way: a prefix which indicates in this expression, fn arg comes before fn.
`!{x(f)}`
`x.{f}`
`(x,y,z).{f}`
`(x,y,z).{f}.{g}` if f's output is a struct can it be destructed into g args?
why not make use of struct?
`x.{f}` x can be a struct
`{1,2,3}.{f}` -> `f(1,2,3)`
`{{1}, {2}, {3}}.{f}` -> `f({1}, {2}, {3})`
now if f's output is a struct with two elements, and g needs two inputs:
`{1,2,3}.{f}.{g}`
`my_struct.{f}.{g}`
`{my_struct.{f},4,5}.{g}` should f output be used as a struct or should it be decomposed?
this is what makes things confusing.


N - how can we refer to a fn inside a module?
```
@["stack"]
{
	myStackFn = internalFn
}
```

Y - use `=` for type alias.
`:=` for named type.
`MyInt = int` is alias, just like for bindings.
`MyInt := int` named type

Y - Use `:=` in bindings for lazy calculate some expression in a parallel lightweight thread.

Y - If I write this:
```
@["x"]
{
	MyType = int #there is only one type with this name, so this is fine
	process2 = process #there may be multiple process bindings 
}
#contents of x.dot
MyType = nothing
process = 10
process = (x:int)->x+1
process = (x:float)->x*2
```
then which `process` is renamed during import?
solution1: user must specify type. we cannot have multiple binding with the same name and type.
```
@["x"]
{
	MyType = int #there is only one type with this name, so this is fine
	process2:int = process #there may be multiple process bindings 
}
```
The problem is, we can have multiple bindings with the same name and different types.
This can happen inside a single module too:
```
process = 10
process = (x:int)->x+1
process = (x:float)->x*2
handler = process #which one?
a = 10
a = 1.1
x = a #which one?
func:(int)->int = ...
func:(int)->float = ...
g = func(10) #which one? but this is invalid. you cannot have functions which only differ in their output type.
```
When there is ambiguity, you must specify type. This is only needed when you have something like: `a=b`
So the correct way would be:
```
@["x"]
{
	MyType = int #there is only one type with this name, so this is fine
	process2:(int)->int = process #there may be multiple process bindings 
}
a = 10
a = 1.1
x:float = a
process = 10
process = (x:int)->x+1
process = (x:float)->x*2
handler:int = process 
OR
handler:(int)->int = process 
```
Type of a binding must be either explicitly stated or could be inferred from right side value.

Y - "Resolution mechanism"
Can we have a local lambda named `process`, a local function `process` and an imported function `process` and a function argument called `process`?
If so, what happens if I call `process()`? which one is called?
what happens if I write `x = process`? which function will be used?
```
@["a"] #this has a binding called process
process := (x:int)->x+1
func = (process: float) -> int
{
    process = 12
    g = process #which process?
}
```
When there is a reference to a binding, how is it resolved? What is scope order which is searched?
1. You cannot define a binding with same name as function argument.
2. Can we define a binding with same name as current function's parent function? 
3. When there is a reference to a binding, first local scope is searched (local bindings and funtion args), then parent function and goes until module level. The next scope will be imported modules.
4. If at imported modules level there are multiple options, there will be a compiler error.
5. If there are multiple candidates at each scope, and type is explicitly stated, it will be used to choose one candidate.
This should be part of function call dispatch: "Identifier resolution policy"
Scope 1: Current function (local bindings and inputs)
Scope 2: Current function's parent function and up to module-level functions
Scope 3: Module level 
Scope 4: Imported modules
First scope 1 is searched based on name of the binding and it's type (if specified). Then scope 2 and ... .
At each scope: If there are multiple candidates: Compiler error, if no candidates: Go to next scope.
If no candidates are found: Compiler error.
The identifier which is referenced can be a function name or a value binding or a type or function call.
For type, scope 1 is current module, scope 2 imported modules. Just name will be used to resolve the reference.
Types of resolution: Type name, binding (value, function name, function call)
If we have `process:(int)->int` can we import a module that has the same function? 
Go does not permit that. If you import 'Adder' you cannot define a function with same signature.
But why? What are modules supposed to be? Are they just containers for some code or they are organization mechanism?
I think we should allow local file to be it's own scope.
This is similar to Perl.

N - How can I hide a binding?
suppose I have `process:(Customer)->int` defined in two places: module a and b.
If I import both of them, I cannot call `process` because it will be ambiguous.
You can overwrite it:
```
@["a"]
{
  process = nothing
}
@["b"]
process(x) #this will call process in a or b?
```
You can change the value of a binding but you cannot change it's type.
You can change underlying type for a type name/alias but it should be consistent.
So you cannot "hide" something. The solution is to rename the function you want to call:
```
@["b"]
{
    bProcess = process
}
```
then call `bProcess` function and it will call `process` defined inside `b`. 
But what if there are multiple functions from multiple modules (a, b and c) all named `process` and you need process functions defined in a and b but not c?
Even if you can hide `process` in module C, any function inside `C` which calls `process` will try local process first.
You can do this:
```
@["a"] { process2 = process }
@["b"] { process2 = process }
@["c"]
#then call process2 function
process2(x)
```
proposal: assigning a binding to `_` will hide it in import.
```
@["a"]
{
	_ = process
}
```
No! this will be confusing. And will add a completely new meaning to `_`.
We already have rename/alias feature. So rename other candidates with the same name.

N - what does it mean to have `{}` block when we import multiple modules?
contents are expanded in a single unit and defs inside `{}` are applied to the whole.

N - `:=` for parallel calculate is a bit confusing.
Maybe becase of my background with it.

N - So basically you can hide a function or binding or a type by re-declaring 

Y - If we use a function name as a lambda ptr, it's type must be explicit.
Either via left hand side or with `_:int` notation.
so: `func = process` is wrong if we have multiple functions named process.
it should be `func:(int)->int = process` or `func = process(_:int)`.

Y - can we name/alias a private type as public?
what if we have a public type which includes private types?
`MyType = [_MyCustomer:int]`?
Of course, private type/alias does not have any limitation.
But what about public?
a public function which has a private input -> invaid
a public binding which has a private type -> this is like a class with private fields.
`Customer = {age:int, data: _PrivateDate}`
this should be allowed but they cannot access `data` directly.
you can define public identifiers however you like but external code cannot access their types that have private type directly.
Proposal:
Type alias should have the same or more restricted scope as it's alias. If underlying is public, it can be either public or private. If underlying is private, it must be private.

N - What if we have `T=nothing` inside a module and we replace it with: `T := int` during import?
Or vice versa.
We have `T := nothing` and replace it with `T=int`? It may cause problems in compilation because with this change, T is int.

Y - Why not use `==` for equality check?


N - As a move to simplify the language: remove named types `T := int`.
Only have type alias: `T = int`.
What advantages do named types bring to the table?
C has only type alias. Also it seems that Rust also has type alias.
ADvantage of named type: Type safety.
So if I have `MyType = int`, and `process:(MyType)` I am sure it will receive a `MyType` and not `int`.
Or: 
```
Customer = {name:string, age:int}
process = (x:Customer)->...
```
I am sure that `process`'s input will be a Customer and not an unnamed struct with those fields.
Another thing that can be lost: Phantom types
```
MyInt = int
YourInt = int
process = (x:MyInt)->...
process = (y:YourInt)->...
```
Above code is invalid with type alias.
solution?
```
MyInt = {data:int}
YourInt = {data:int}
process = (x:MyInt)->...
process = (y:YourInt)->...
```
Are MyInt and YourInt different? If it was C, they would be the same.
Maybe we can say, type alias definition adds a hierarchy.
So if we have:
```
MyInt = int
YourInt = int
```
Then `int` is int. MyInt will be replaced by int and YourInt will be replaced by int.
But if a function expects MyInt, it can only receive MyInt or int.
If a function expects YourInt, it can only receive YourInt or int.
If a function expects int, it can receive any of above: int, myint, yourint.
So, we can say type alias provides a two-way path from each alias path to the most basic type. but the path ends at that place. You cannot move to other paths.
So it will be type alias with a twist.
q: So, can we define a new type?
q: What happens to union?
`MyType = [MyInt, MyFloat]`
`MyInt = int`
`MyFloat = float`
Is MyType equal to `[int:float]`? What about `[MyInt, float]`?
`MyInt = int`
`MyType = MyInt`
`MyType2 = MyInt`
Are MyType and MyType2 equal?
`Handler = (x:int)->bool`
Maybe the path strategy in resolving types makes things complicated.
Other than that, if `MyInt = int` and some function needs `MyInt`, I can simply send an `int` to it without needing to import the module that defines `MyInt`.
`Maybeint = int | nothing`. Is this a new type?
The reasoning that `MyInt = int` may cause user sending int mistakenly does not make sense.
What if we have a `process` function which should have different return for `MyInt` than `int`?
Functions should work based on the data, not their labels (types).
In C: `typedef struct {x:int;} A` and `typedef struct {x:int;} B` define two different types.
So:
```
MyInt = int
YourInt = int
```
They are all the same because underlying type is a primitive type.
But for composed types (sequence, map, struct and union), they won't be equal. In C arrays are equal too but for struct, they are not.
```
MyType1 = [int]
YourType1 = [int]
MyType2 = {x:int}
YourType2 = {x:int}
MyType3 = [int:int]
YourType3 = [int:int]
MyType4 = int
YourType4 = int
```
How do we determine if two types are equal?
In above case, MyType4 and YourType4 and int are equal.
Using `=` cretes equal types.
Using `{}` or `[]` or `|` when defining types, creates a new type.
So `[int]` and `[int]` (again written in the source code), are not the same thing.
MyType1 and YourType1 and `[int]` are different. Of course you can cast them.
So can we have `process([int])` and `process:(MyType1)`? Yes.
Rules of type equality:
R1. Using `=` cretes equal types. So `A=B` means A is same thing as B.
R2. Using `{}` or `[]` or `|` creates a new type. So:
`A = [int]`
`x:[int] = [1,2,3]`
type of X is different from A.
`x:A = [1,2,3]` type of x is same as A.
So if a function expects input type A you cannot send `[int]` to it. In this way, it's similar to named type.
But if we have `B=A` any binding of type B can be sent to functions that expect input of type A.
Does this definition solve the problem of refactoring for which they added type alias?
Is it simple enough? I think so.
If I have `MyType = int` and later I want to change it to `MyType = OtherModuleType`, then?
`MyType = ModuleType1`
`YourType = ModuleType1` in a different source code file.
Then MyType and YourType are the same.
So `A=[int]`, `A` is not equal to `[int]`.
Even `[int]` is not equal to `[int]`.
But if we have: `process([int])->int` we should be able to send it `[int]`.
Are these types equal?
```
MyType2 = {x:int}
YourType2 = {x:int}
```
Two types are identical if they have the same structure (`[int]` vs `[int]`) or they alias to identical types.
```
A = [int]
B = A
C = [int]
D = {x:int}
E = {x:int}
D1 = D
E1 = E
F = int
G = {x:int}
H = {x:F}
```
A and `[int]` and B and C are identical.
D and E and D1 and E1 are identical.
G and H are identical.
You can compare bindings of identical types and they are exchangable. So if a function expects one of them, you can send binings of the other type. If function's output is one of them, you can store it in a binding of the other type.
But why should D and E be equal? Because if they are not, it will bring up path based equality which makes things complicated.
In F# it is advised to use "single case union types" to create a truely new type.
So you cannot use customerId instead of orderId:
```
CustomerId = int
OrderId = int
```
https://fsharpforfunandprofit.com/posts/designing-with-types-single-case-dus/
we can use single case union: `type EmailAddress = EmailAddress of string`
or record type: `type EmailAddress = { EmailAddress: string }`
Single case union would be confusing in our case. 
So why not use a struct?
```
CustomerId = {customer_id: int}
OrderId = {order_id: int}
```
Maybe we should keep named types. The logic would be simpler in that case.
Type identity: Two types are the same if:
Plain type: If they have same structure
Type alias: If they have same underlying
Named type: If they have exactly same name.
Rule: A named type is always different from any other type. Other types are equal if they have the same structure.

Y - A public type/binding (union or struct or map or seq) can contain private types but you cannot access them directly.
Can I have `T := [_private]`? Yes. And pass it's bindings to functions that expect `T`.
But you cannot write `x[0]` because it's type is private.
So the rule is: You can define, receive and send any binding which has a public type. It can however contain private types.
What if we have a public function whose inputs are private type? It does not make sense.

N - Can I write: `T = [_private]`? 
The purpose of private type is that you should be able to change their name or internals without having to change outside.
So using `T` should be Ok as later the author of the container module can change it to: `T = [_privateV2]`.
You can use any public type (named or alias) ...

N - If we use `adder = (x:int -> y:int)` notation can we remove `::`?
`::` is a bit confusing. return X if it is not nothing. it does two things.
what about this? `y=data//` meaning if data is not nothing assign to y and return.
if it is nothing continue. but what if we use this for other assignments?
we can say assigning nothing to y does not cause a return.
or: changing in value of y will cause return.
so in header we set default return value, any change on it will cause immediate return
```
process = (x:int -> y:int=nothing)
{
	y = x+1
}
```
 `adder = (x:int -> y:int)` does not make sense. because `y` is not there.
 It is not a binding. it is a pseudo name. so why let user set its name?
 and it does not imply that we must have a name before it.
  `adder = (x:int -> int)`

Y - Setting type for a binding is not really needed. For function args, it's needed.
But for bindings, it can be mostly act as a documentation.
Exception for union type: `t:int|string=12`.
But what will be use of this? Anyway, we know rvalue is int.
And if it's a function call, the function output determines type of `t`. 
`t:int|string=12`
vs
`t = 12`
first one does not add any new thing. If we want to call a function with `t` the function must accept `int`.
it can be `int|string` or `int` + `string` (two versions).
When do we use `:`?
1. binding type
2. function arg type
3. struct field type
But why not keep it just as informative?
It can be used to set type explicitly to help reading the code.
the bigger question: Should we keep optional useless notations to help reading the code?
This change will make writing code and parsing/compiling more difficult.
And it does not help read the code all the time, because it's not mandatory.
Proposal: Whatever comes before `=` cannot have a type. Only an identifier.
For function input and struct, identifier comes before `:`
What about a complex binding? e.g. a map where key/value are union?
`x = [1:"A", "G":"B", 1.2:9]`?
But in these exceptional cases, let developer do it via comments.
Anyway compiler cannot rely on this for parsing because its not mandatory.
Its desired if something is either forbidden or mandatory. optional will be confusing.
It can be said that sometimes it will cause confusion:
```
handler = process #we have two process functions
```
But we can use `_:int` notation to remove ambiguity.
For named types, we can use casting.
```
MyInt := int
x = MyInt(12)
```
Y - function decl similar to binding decl
`adder = (x:int):int x+1`
`adder = (x:int):int x+1`?
```
adder = (x:int):int
{
   :: x+10
}
```
`map = (x:[int], mapper: (int):int):[int]`
`(int):float` means when given an int input, it's type will be float. so `f(8)` has float type.
`sort = (x:[int], comparer: (int,int):bool):[int]`
`process = (x:[int], factory: (int,int):(int):float):[int]`
What does `(int):(int):float` mean? Means it's binding is a function which when called with an int, will give a function which when called with an int, will give you a float result.
`(IN):OUT`
Can there be any ambiguity?
`t:((int):float):string` t accepts a function which given int gives float, and when you call t with this, it will give you a string.
`MyType = (int):float`
`[T]` sequence
`[K:V]` map
`(I):O` function
What about function that does not return anything? `(int):nothing`
`():nothing`
Proposal: Remove `->` from notation and replace with `:`.
What happens to the shortcut notation: `adder = (x:int) -> x+1`?
Maybe we should make return type mandatory.
`adder = (x:int):int x+1`
or use auto like D or C++: `adder = (x:int):auto x+1` No.
But what if return type is complex? 
Can this be confused with map?
`[(int):int:string]`? key is `(int):int` and value is string.
`[int:(int):string]`. It does not cause ambiguity but might be confusing. 
Maybe we should use a different notation for map. Bot type and literals.
`[int,float]`? `x = [1,"A",2,"B",3,"C"]`? This can be confused with a sequence.
Maybe we can use `->` 
`[int->float]`, `x = [1->1.2, 2->2.2, 3->3.3]`?
`[(int):int->string]`? key is `(int):int` and value is string.
`[int->(int):string]`
Proposal: Remove `->` from notation and replace with `:` and use `->` for map type and literals.
q: what about `(int)->int|float`? in order to prevent confusion we need to use ()
`(int):(int)|float`
`(int):(int):(float)` gets an int returns a function which given int returns a float
`((int):(int)):(float)` given a function which for int returns int, returns a float
what abt this?
`(int):int?` a function given int returns int channel
`(int):(int)?` a channel that gives you int to int functions.
`(int):(float):(string)?` 
this will become more and more confusing when combined with channel and union.
what about this: `(int, int)` and the last one is output type.
`adder = (x:int, int) x+1`
and if we assign a name to it, setting it's value means return
```
adder = (x:int, y:int)
{
	y = x+1
}
```
`adder : (int, int)`
`processs: (int, (int, int))` gets int, returns a int->int function.
`sort: ([int], (int, bool))` gets int array and a int->bool function.
`func: ()` no input, no output
`func: (int)` is this input or output?
it should be:
`func: (nothing)`
`func: (int, nothing)`
then what happens to lambda maker?
`process(_)` it is not intuitive!!!
it is better for notations to have a boundary. eg. `[int]` has a boundary. a token that determines start and end.
`(int):int`
`(int->int)`
```
adder = (x:int -> y:int)
{
	y = x+1
}
```
`adder : (int -> int)`
`processs: (int -> (int->int))` gets int, returns a int->int function.
`sort: ([int], (int->bool) -> [int])` gets int array and a int->bool function.
still confusing.
`process: (int->int->int)` which one is which?
`process (int) -> (int)` both input and output inside parens
`process: (int):(int)`
the logic with `:` is the it follows a name and comes before type: `NAME:TYPE`
but in a function its not like that. so let's keep `->` notation.
`(IN)->(OUT)`
`(int)->(float->string)?` 
if there is ambiguity, enclose in parens.
`((int)->(float->string))?` 
it would be good if we could eliminate this rule. 
if means ambiguity and we are introducing another optional thing to the language.
`(IN -> OUT)`
```
adder:(int->int) = (x:int -> y:int)
{
	y = x+1
}
```
what about shortcut mode?
`adder = (x:int -> int) x+1`
Anyway `(int->(int->int))` is more readable than `(int)->(int)->int`
and also it indicates/enforces mentioning return type.
return cannot have a binding because it is not a binding. we cannot read it.
```
adder:(int->int) = (x:int -> int)
{
	:: x+1
}
```
what about this? `T = (int -> float) | string`
previously: `T = (int)->float | string` was ambiguous.
Can we write:
```
adder:(int->int) = (x)
{
	:: x+1
}
```
?
If we ban type for bindings, this wont make sense.

N - It would be good if we could generalise what we have in chain op: function selection.
we can write `f(x)` so f will be determined using compiler.
Or we can write: `[f,g,h](x)` so based on dynamic type of x, one of three candidates will be selected.
then for chain: `x.(f)` or `(x,y).(f)`
and `x.([f,g,h])` or `(x,y).([f,g,h])`

Y - Remove chain operator. 
It doesn't bring any advantage and makes things more confusing.
It's only advantage is function resolution, which should be replaced with other mechanisms.
We can use casting and check one by one. 
Can we mix them?
`int(i_s).1+string(i_s).1`
no. all we need is array, cast and `//` operator.

Y - How can i write a simple lambda that does not have any input and returns an int?
`()10`? 
`(nothing->int) 10`
`(->int) 10` 

N - is `(nothing->int)` same as `(->int)`?
Are they the same type? no. not the same.

Y - What if we have a function but want to defined it as a specific named type?
`MyP = (int->int)`
`process = (x:int->int) x+1`
For non-function:
`data = MyInt(12)`
`process = MyP(x:int->int) x+1`
If we want to change the notation, we have to change the notation everywhere.
What about this?
`tempProcess = (x:int->int) x+1`
`process = MyP(tempProcess)`
We still use a known casting notation. We have two simple expressions each of which does a straight forward job.
This is simple and intuitive. 
Let's say: Casting operator can only act on a binding or literal value. Not expressions.

N - Replace select in concurrency with `:=` and `//`?

Y - What if we want to do early return with nothing?
Basically we want to have `[body, early_retval][guard_cond]`. 
or maybe we can reference to a future binding.
```
:: [nothing, res][is_everything_ok]
res = [1,res2][dat_found]
res2 = 19
```
So basically we can (should?) have only one return in a function.
Maybe we can replace `::` notation with the similar `=` plus a special variable (maybe a binding with same name as owner function, or `_` if its anonymous function). But there is no function name. we only have binding name.
```
process = (x:int,y:int->int)
{
  __ = 12
}
```
Or maybe we can let developer choose the name:
```
process = (x:int,y:int->out:int)
{
   out = [p1, p2][data_found]
   p1 = 199
   p2 = 210
}
will be translated to:
   p1 = 199
   if ( !data_found) return p1
   p2 = 210
   return p2

```
this is readable, does not add any new notation. can be used to express any type of return, even return nothing.
and is simple. all the complexity will go in the compiler.
Can we do this everywhere? it should be possible to have orth and gen.
```
data = process(x,y,z)
x = ... of course you cannot refer to data or y or z
y = ... you cannot refer to data or z
z = ... you cannot refer to data
```
So if LHS is not return binding, compiler will just change place of the line. Else it will handle early return.
Refering to future references is a bit unintuitive.
What if we say a closure can refer to bindings in future, when called?
`y = [()->10, ()->z][is_fine]`
`z=99`
advantage over normal refer: the structure of the array?
what if we try to solve it other way around? instead of stopping processing the rest of the code, jump over it?
Any reference to a binding before decl is a continuation. continue processing until you get value of that binding.
But if I write: `out = [10,x][cnd]` then how is compiler supposed to initialize this array?
I should write an array of lambdas: `out = [(->int) 10, (->int) z][cond]`
Then compiler can put any code inside body of the second lambda. It will put rest of the function body there.
```
process = (x:int, y:int -> out: int)
{
   out = [(->int) 10, (->int) z+p-1][x>0]
   t= 12
   z=t+1
   p=t-z+process(t)
}
#this will be translated to:
out = [(->int) 10, (->aaa:int)
{
   t= 12
   z=t+1
   p=t-z+process(t)
   aaa = z+p-1
}][x>0]
```
Now, what if I use it in a normal situation?
```
process = (x:int, y:int -> out: int)
{
   data = [(->int) 10, (->int) z+p-1][x>0]
   t= 12
   z=t+1
   p=t-z+process(t)
   out = data
}
```
Each line has a binding on the left and an expression on the right. The expression can refer to other bindings.
This will translate to a graph of dependency which is directed: DAG.
If it is hard to explain and implement, its hard to understand.
What if we say, first line of evvery function must be output assignment which definitely will most of the time have a future reference.
But then the code may be not very readable. And it's not how you write the code.
But think of it like this: You have to think top bottom: First think about output and it's elements, then write those elements.
`out = part1 + part2 + part3`
What if we eliminate early return from the language, but compiler handles it behind the scene? But doing these things behind the scene, may result in unwanted consequences.
Compiler cannot manipulate code. Maybe developer has some lines of code which expects to run but compiler does not because output is ready.
```
out = [a,b][cond]
a= ...
b=...
```
If cond does not hold, we only need to calculate a so we can ignore b. But what if during b calculation some side effects are expected to happen which are needed?
Why not make it easy and let developer surround the costly part of the code in a lambda and invoke it on demand?
```
out = [a,b][cond]()
a = 10
b = (->int) { lots ot code }
```
Proposal: No special return, assigning to output var means return but you can refer to future bindings to make code more readable:
```
out = [(->int) 10, process]()
process = (->int) lots of code
```

Y - Can we use this as a lambda? `x -> x+1`? If type can be inferred?
`h = (x:int->int) x+1`
The definition should be auto-surround. Like cast: `int(x)` which is a self-explicit notation.
`(x:int->int) x+1()` what does `()` apply to? This makes the definition ambiguous.
`(x:int -> x+1)`?
`(x:int -> x+1)()` definition + invoke
`(x:int,y:float -> x*y)`
`(x:int, y:float -> z:float ) { ... z = 12 }`
or:
`(x:int, y:int -> { .... % = 19 })`
Should we force developer to denote output type? Or should we ban it?
It may be like binding, where we ban type specification.
Or we can say, let's force output type when developer is not using shortcut notation:
`(x:int, y:float -> z:float ) { ... z = 12 }`
This makes more sense, I think.
Proposal;
- If type can be inferred, it is optional.
- If result of function is an expression, just put it after `->`. Else write binding name and type and write statements in the code block.

Y - If type is specified in context, can we write:
`(x,y->x+y)`? or `(x,y->z){ z = x+y}`?
For example when expression is an argument sent to another function.

N - For function output, just write output name and possibly expression which refers to future bindings. Then a block of code without return. 
In this case, we dont really need a name or even type. As it cacn be inferred from right hand side.
```
process = (x:int,y:int -> t:int)
{
	t = 4*y - x
}
```
But we need type. For cases when we need a lambda.
```
process = (x:int,y:int->int) x+y+t
{
	t = 4*y - x
}
```
This is not very intuitive and easy to read.
And will prevent us from having multiple early returns.
`process = (x:int, y:int -> int) x+y`
```
process = (x:int, y:int -> out:int) 
{
	out = x+y
}
```
```
sort(my_sequence, (x,y -> x-y))
process(my_sequence, (x,y -> (t -> t+x+y)))
process(my_sequence, (x:int,y:int -> (t:int -> t+x+y)))
sort(my_sequence, (x:int,y:int -> result:bool)
{
	result = x==y
})
```

Y - In module, we are defining multiple bindings with same name which is not allowed inside a function!
```
process = (x:int) -> x+1
process = (x:float) -> 12
```
These bindings have the same name but different types.
what about this?
```
x = 12
x = 19.21
```
and what if we call `process(x)` which x will be used if we also have two process functions?
Proposal: Include type in function name
```
process(int->int) = (x -> y) { y = x+1 }
process(float->int) = (x->y) { y = x/2 }
```
It makes code messy.
Let's consider this special case: You can have multiple bindings of the same name but different type if they are function.
But isn't this an exception? Why can't we have non function bindings with the same name, if they have different types?
```
process(int,string) = (x,s -> y:int) { y = x+1 }
process(float,int) = (x,k->y:int) { y = x/2 }
```
This is because the notatio to define a module-level function is the same as the notation to define function-level lambda.
Proposal: We use different names for those functions, but introduce a compile-time dynamic sequence where you can add functions (or any other thing) to a sequence at compile time. Then you can treat that sequence as a function (if it contains functions).
Example:
```
drw_circle = ...
draw_square = ...
draw_triangle = ...
draw = [draw_circle, ...]
draw = [draw_square, ...]
draw = [draw_triangle, ...]
...
draw(my_circle)
draw(my_square)
#another example:
[(int->int) 10, (error->int) 20](error_or_int)
```
Another approach is using map. So we don't need to treat a sequence like a function (which is weird).
```
drw_circle = ...
draw_square = ...
draw_triangle = ...
draw = [%Circle: draw_circle, ...]
draw = [%Square: draw_square, ...]
draw = [%Triangle: draw_triangle, ...]
...
draw[type((my_circle)](my_circle)
draw[type(my_squalre)](my_square)
#another example:
[%int: (int->int) 10, %Error: (error->int) 20](error_or_int)
```
So we will need a new notation for getting type identifier (integer) for any given type.
Also we will need a built-in function or a notation to get type id of internal type of a union.
But if we use sequence, we won't need those notations.

Y - How can we handle conflict without generics?
Use intermediate module. If `draw` and `T` are defined both in Lib1 and Lib2, add intermediate X like this:
```
#x
@["Lib1"]
myDraw = draw
MyT = T

#main module
@["X"]
@["Lib2"]
#now draw refers to function in Lib2 and myDraw referes to the one in Lib1
```

Y - Declare that `[...]` ntation is only valid at module level.

Y - Review notation to init struct or update/modify struct into a new binding
I think we need to restore type name when defining a struct literal.

N - We can use concept of dynamic compile-time sequence in core.
define function `sort` which works on any data type. Just assume it's defined like: `sort = [...]` and functions are geneated by compiler.

Y - Make generics simpler. It does not need to support all different options like replacing functions. 
We just want type replacement.
Generics implementation is like this because we want it to be orth and general. If we disable non functions, it will not be orth.
I think the previous notation was simpler and still provided enough advanages: `@["Stack(int)"]`
When a module is named `Stack(T).dot` it acts like a function. T is the input and whatever you pass will be replacced inside the module.
Difference with normal functions:
- There is no type involved here, T does not have a type
- As this is a text replace, you cannot pass an expression.
`@["Stack(int)"]` -> import Stack module and replace it's T argument with `int`.
And this does not have to be type, as long as it is a simple identifier (number, token, type name, ...) it is fine. Compiler will only replace.
But, if you pass a local type to the module, how is it supposed to know the definition of that type?
It does not need to (and cannot) know the details inside the type. The identifier of that type however, is not defined inside that module!
```
#stack(T).dot module
Stack = [T]
...
```
If we import above module with `Product` type, how is the code supposed to cmpile? It does now know, product type.
I think this is fine. These arguments are an exception and we assume that they are defined outside. 
So when compiler is compiling the code for these modules, when replacing T with `Product` it inserts other metadata to indicate the layout/size/details of that type.
This will be handled by the compiler. You only imprt a module with an identifier.
But can this be generalized? If I have a type inside a module, what will be it's scope?
Can I access types outside my module in the importer module? No. Because you don't know them.
when you import `Stack(Product)` the code of that module will be compiled with a reference to local Product type. 
it will be as if the code is inserted into current module but symbols are not public to the outside world.
Only those who are explicitly defined public in a module will be exported to the outside world. Not identifiers which are available as a result of import.
Another approach: Let IDE or the developer write code/data types specialized.
Then use dynamic compile-time sequence to integrate them.
```
baseSort = ...
intSort = ...
floatSort = ...
stringSort = ...
sort = [intSort, floatSort, stringSort, ...]
...
#at the compile time, we know type of int_array and we know elements of sort sequence, so we know which function will be called.
#so we know type of sorted. unless a union is involed (e.g. int_array is a union).
sorted = sort(int_array)
```
another example:
```
BaseStack = [nothing]
basePush = (b: BaseStack, y:nothing -> out:BaseStack) ...
basePop = (b:BaseStack -> out: nothing) ...
IntStack = [int]
intPush = ...
intPop = ...
FloatStack = ...
StringStack = ...
push = [intPush, floatPush, stringPush, ...]
pop = pintPop, floatPop, stringPop, ...]
```
Another example:
```
output = map(int_seq, (x:int->x/2))
#above needs us to have:
mapIntFloat = (x:[int], f:(int->float)->[float]) ...
map = [mapIntFloat, ...]
```
Advantage:
- Easy and simple. 
- Almost no new notation. Everything is already in the language
- Specialization is already provided.
- Most of the use case for generics (map, reduce, filter, sort, search, ...) the code is rather simple and small.
We really don't need dynamic compile time union types!

Y - Remove polymorphic union types with `...`

N - We can follow same notation for types:
`Shape = Circle | ...`
`Shape = Square | ...`
compile tim e dynamic union.
pro: This will be more flexible. We don't need a common element to define this union.
con: We won't have access to a common part -> you can define a sequence of functions to do that for each type and call that sequence.
pro: the definition becomes decentralized.
con: You can use `{Shape, ...}` everywhere (e.g. type of function arg), but you cannot use `Circle|...` fr function input type.

Y - The current destruction syntax can be confusing.
`x,y = point`
It's better to make it explicit:
`x,y = *point`
is same as: `x,y = point.x, point.y`
So `*point` is translated to `point.x, point.y` which can be used anywhre we need: assignment, sequence, ...

Y - Review calling functions with argument name
If we want to have it, it must be mandatory! which can make writing code difficult.
Another way: destruct a struct in-place
```
drawPoint = (x:int, y:int -> ...)
#now you want to call draw with 100,200
drawPoint(100, 200)
#or
point = Point{x:100, y:200}
drawPoint(*point)
```
You can combine this notation with more items:
`x,y,z = *point, 120`
or: `drawEx(*point, 190)` is same as `drawEx(100,200,190)`

Y - `process = (x:int -> nothing)` is it a shortcut? can I write a code block after this? No. it is a shortcut syntax!
you have to write: `process = (x:int -> _:nothing)` ...
Extende usage of `_` for when name of input/output is not relevant in a function.

Y - I think maybe a compile time dynamic union can be useful.
Normally we write different functions for different related data types and combine them using ctd-sequence.
`draw = [drawCircle, drawSquare, ...]`
But what if the implementation is the same? it either does not depend on the exact type or it is just some common thing.
For example size of a stack. we don't want to have `intStackSize, floatStackSize, stringStackSize, ...`
we want to have something like this:
```
BaseStack = [nothing]
Stack = IntStack | FloatStack | ...
size = (s: Stack -> len(s))
```

Y - Can we remove the notation for casting? Why do we need to cast? 
We can provide needed casts in core as normal functions and for the rest cast is not really needed.
usages:
1. primitives (float to int) provided using coore
2. union to elements: Use sequence of functions
3. struct: We already have it: `x = Point{...}`
4. functions:
```
Adder := (int,int->int)
process = (x:int, y:int -> x+y) #is process's type Adder? No because Adder is a new type
```
solution1
`p2 = Adder(process)`

Y - Use `&` notation instead of `...`
Also `|` for union

N - Can we have linked list?
It can also be used for iterators
We can use it for a lightweight process on a list. e.g. iterate through a list of int, and for nothing return 0, without need to allocate a very big array.
Use case:
- Consider a very large buffer, calculate sum of ints and use 0 for nothing.
If we already have a sequence, we just need a function ptr to do the processing.
If we don't have a sequence, we can use a channel.
- Use case: Implement observable. We have to keep track of a list of observers. This can be stored in a ll.
I don't think its necessary. We can do it via functions.

Y - Can we also treat a sequence of channels as a channel? This may simplify select.
If we assume we only need either read or write:
```
read_data = [rch1, rch2]()
data_written, channel = [wch1, wch2](data1, data2)
data_written, channel = [wch1, wch2](data1, data2)
data, ch = [rch1, rch2, wch1, wch2](data1, data2)
```
Maybe we can even remove `!?` notation to read/write data.
`data, channel = [rch1]()` blocking read - wait until channel has data to read.
`data, channel = [rch1, nothing]()` non-blocking read, if rch1 does not have data, nothing channel will return immediately
You can always make a select non-blocking by adding a nothing (or any default) channel.
What about their type?
`int!` and `int?`. 
`[int]!` is a channel which gives you int array
`[int!]` is an array of channels that give you an int.
I think it's fine.
We will get rid of `${}` notation.

N - What is the real type of a sequence of functions?
Is it a seq or a fn?
It is a seq but if you invoke it, compiler will generate appropriate code.
CanI use `_` to create a lambda out of it?
`f = draw(_:Circle)` ?
`f = draw(_)`? This is a sequence of functions with only one input.
`f = draw`? This is a simple assignment. Later you can call f just like draw.
How can I fix type of functions in draw? you cannot. They are free to be any type.
What about output? Also free? If draw functions some of them return int and some return string, output of `draw(...)` will be `int|string`?
You can describe type of a sequence of function by using appropriate unions.
`draw` has this type: `(Shape -> int)` where Shape is union of shapes.
So isnide draw, we have one function per shape and all of them return int.

? - How can I create a channel of Customer?
`sender = createChannel(sizeof(Customer))`
option 1: cast
`CChannel = Customer!`
`cc = CChannel(createChannel(sizeof(Customer)))`
option 2: There is no specific channel type. only two generic types.
`reader = createReaderChannel(sizeof(int))`
then, how can we check/verify that when reading from `reader` we only read int?
How can I specify I need a  channel that can write int only? Maybe we can use a lambda. but then select will be impossible as we no longer have the original channel.

? - Can we formalise the protocol to for code generation for generics?
```
baseSort = (x:[nothing])->[nothing] ...
intSort = ...bsaeSort( int)...  #read baseSort and replace nothing with int
```
Above can be used for code that has only one type variable.
Anything else: Write it by hand
q: the baseSort will definitely use comparison on nothing, is it accepted? Wht does it mean?
We can say: All operations on nothing type are valid and will result a nil (comparisons will always fail, addition will give you nothing, ...)
All basic operators (math, compare, ...) are valid and do nothing.
funtion calls on nothing must be defined before.

? - Maybe we can use above for channel creation:
`createCustmerChannel = ...baseChannelCreate(Customer)...`
`baseChannelCreate = (->nothing) ...`
Can we have a shortcut for that? So instead of declaring `createCustmerChannel` function, we simply call base with some notation.
Can we do the same for types?
We sill have this notation: `sort = sort & [intSort, floatSort, stringSort]`
and: `pop = pop & [pintPop, floatPop, stringPop]`
But to use a specialized type or function, we use a shortcut.
`intSort = ...baseSort(int)...`
`intStack = ...Stack(int)...`
Maybe: `baseSort((int))` and `Stack((int))`
or: `baseSort[[int]]` and `Stack[[int]]`
`[` is better than `(` and `{` because it is a single keypress.
And I think it is different enough to prevent any confusion.
q: What about transitive definitions for types? (Alias or named)
```
baseSort = ...
sort = sort & [ baseSort[[int]], baseSort[[float]], baseSort[[string]] ]
#####################
BaseStack = [nothing]
basePush = (b: BaseStack, y:nothing -> out:BaseStack) ...
basePop = (b:BaseStack -> out: nothing) ...
push = push & [ basePush[[int]], basePush[[flot]], basePush[[string]]]
pop = pop & [ basePop[[int]], basePop[[float]], basePop[[string]] ]
```
Or maybe we can use D language notation: `basePop!int`
Maybe we can eliminate `&` notation by using `!` with variable types:
Suppose that we have a sequence of something and want to sort it: currently we have to call: `sort(seq)` and correct function will be chosen.
what if I write: `baseSort!seq(seq)`? or even simpler: `baseSort(seq)`
this means: call `baseSort(nothing)` function but change nothing types to type of seq binding.
So, how do we define a stack of int? `Stack!int`
So we say: 
proposal:
- Remove `&` notation to define dynamic compile time function and union types
- Any type which uses nothing (directly or indirectly) can be customized using `!` notation: `Stack!int` for a stack of int
- When calling a function which has `nothing` based input type with a type which is not nothing, it will be customized at compile time. e.g. `push(myStack)` 
if we have `push = (x: Stack, y: nothing -> z:Stack) ...`
and if myStack is stack of int, compiler will generate this function:
`push = (x:IntStack, y: int -> z:IntStack) ...`
q: What happens to function pointer? We always try to make things explicit but a function call like `push(myStack)` will implicitly generate another function.
Why not make it explicit via `!` notation and keep `&`?
No. auto type detection is not good because it is not flexible and is opaque.
We need `&` notation and `!` is useful because it can act as a shortcut.
```
baseSort = ...
sort = sort & [ baseSort!int, baseSort!float, baseSort!string ]
#####################
BaseStack = [nothing]
basePush = (b: BaseStack, y:nothing -> out:BaseStack) ...
basePop = (b:BaseStack -> out: nothing) ...
push = push & [ basePush!int, basePush!flot, basePush!string ]
pop = pop & [ basePop!int, basePop!float, basePop!string ]
##################
BaseStack = [nothing]
IntStack = BaseStack!int
```

? - Examples of generics usage:
1: clone
2: ser/deser
3 sort an array
4: factory
5: join sequences
6: Run a method periodiclly or at scheduled time

? - What does this mean? `[int:string:float]`?
