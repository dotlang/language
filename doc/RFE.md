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

? - Add more links to README. e.g. in `::` explanation we use `//`, link to corresponding section.

? - Add support for LLVM-IR based code in function to make bootstrapping easier.

? - Is it possible to somehow merge this language with docker as a built-in feature.
So each app will be run inside a container?
Like JVM.

? - For generic modules with general type, we can re-use `...`:
`T := ...`

? - Suppose we want to write dotLang compiler. What do we need at minimum?
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

? - Make sure `..` can accept vars too.
If it is literal, compiler will generate code. Else runtime.

? - What should be name of a binding which is union of value and function?
`U1 := int | (int)->int`
`handlerData: U1 := getData()`

? - Even if at some point we need a dedicated build system, we can use dotLang to describe the build process and steps.

? - The compiler will use `.build` directory for cached compilations, output, intermediate code, temp files, ...
Instead of something like `mvn clean` you can just do `rm -rf .build`
Maybe we need to have some resource files beside the output. We can order compiler to also save output final executable in a specific folder which is set up with all required files.
We can have `pre-compile.sh` script and `post-compile.sh` script which will be executed before and after compilation.
If we have dependency to v1 and v2 of a library which is on github, when we clone it, they will be on the same dir.
`_ := @{"github/lib1/v1"}`
`_ := @{"github/lib1/v2"}`
We can clone the same repo into different dirs and for each dir checkout corresponding branch.
We can clone with `-b v1 --shallow 1 --single-branch` into a specific directory.

? - Use cases for dotLang: Hadoop, Spark, Cassandra, Hive, HDFS, Arrow, Oozie, YARN, HBase, Redis, ...
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

? - We can say if right side of `:==` is a call on a function literal, it will be implemented as a thread. otherwise it will be a lightweight thread.
when we start a thread, we need a thread_id to later access, pause and communicate with the thread. 
I think all of stop, pause, cancel, ... can be handled by channels.
Golang does not let developer decide whether it will be a thread or a goroutine.
We can say, if you call dispose on output of `:==` the corresponding thread will be terminated.
The scheduler will start with one thread and increase/decrease number of threads based on the load, cpu usage and number of lightweight threads.

? - Green threads needs a runtime (scheduler, threads, assignment, queues, ...).
Is it possible to achieve this without a runtime?
We are not forced to follow go or CSP approach.

? - Checking regex match can be done in parallel.
