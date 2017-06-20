 
Y - Note that `val` can only appear on the left side of `=` when it is being declared. What comes on the right side of `=` must be either another val or made val using `@val` or a literal. This notation will duplicate it's input if needed.
There is no need to force clone a val with `@val(@t))` notation. because cloning is used when we want to detach left side of assignment from right side. but for val, there is no attachment.

Y - Slice should keep a pointer to parent array + index number.
Because to make things safe, we should let pointer operations only on binary.
So it cannot have a pointer variable.

N - can result of an expression be val?
`x=y+z` can y+z be val?

Y - `=>` should be same as `>=` and also `<=` ~ `=<`

N - Can developer write his own "byte" data type?

N - `x=literal` will copy-value because litearl is not reference type.

Y - force single space between func and function name.

Y - Shall we have pointer data type?
`var t: ptr[int]`
`t=10`?
`*t=10`
`t=&y`
`t=addr(y)` `t=&y`
`set(t, 10)` `*t=10`
`t() = 10` will cal opCall which returns a `var int`.
it will be very confusing. because we already have references. working on non-binary data with pointer makes things confusing.

Y - What does `==` compare now that everything is a ref?
`x==y` The easy way is to say it will do data comparison.
if you want to see if they are same references,
`x =? y`
`ref(x) == ref(y)`

N - Can we make use of binary to increase performance? 
Like having unboxed (non-ref) data?
suppose we want to do fast math operations. but compiler will optimize for this.
Do not make language more complex for the sake of something which compiler can do.

Y - What should be initial value of variables?
`var x: Point` `process(x)` what should happen?
variables are initialized upon declaration. for val you must assign value, for var, compiler will set default value (everything zero, empty, ...)
`var x: array[int]` will create an empty array

Y - Can we define label for union types better?
more formal.
`type MaybeInt := int | Nothing`
Labels define a new type which has only one value with the same notation (or use them).
`type UnionType := Type1 | Type2 | Type3 | ...`
`type Nothing` - defines a type which has only one valid value: Nothing

Y - write methods with inline assembly.
And methods that can force compiler to be inlined, so they don't have pushall/popall statements.
Like by using `=`
`func process(x: int) -> int = x+1` for force inline. But problem is inline must be done by compiler.
Method resolution which happens at runtime may call this. so it cannot be inlines upon each call.
This can help me write parts of the language in itself. Only need to provide basic compiler. then others can be written in assembly.
compiler may not be able to enforce val/var for these methods.
```
func process(x:int) -> int 
{|
  mov ax, 10
  mov bx, 20
  add ax, bx
|}
```
`{| ... |}` for assembly
`{|| ... ||}` for inline assembly

Y - inlining will be done by compiler. What about methods with assembly code?
Maybe some methods must be inlined. Can compiler deduce this?
Convention: Methods that start with double underscore must be inlined. But we want methods that can be easily called.

Y - We should provide some syntax in assembly to write cross-OS and cross-hw code.
```
func process(x:int) -> int 
{|
   (OS == WIN)
   {
     mov ax, 10
     mov bx, 20
     add ax, bx
   }
   (CPU != Intel)
   {
      mov ax, 12
   }
|}
```

N - Why not have everything value and compiler converts them to references when it needs to? Won't it make things simpler for the developer?
Because we will loose flexibility of pointer operations.

Y - Let `=` and `==` act as if data is data and not a reference.
Currently `==` acts this way. Compares real data, not references. But there are functions to compare ref.
`x=y` should copy data of y into x. So if rvalue is a temp variable (e.g. `x=1+y`), it will be a ref-assign handled by the compiler. if you want x to reference to place where y is pointing to, you must use another notation.
`x << y`
`var x: point = y` will copy all the data inside y to x
`var x: point => y` x will point to the same location as y.
`var x: point = ref(y)` but this is not intuitive.
`var x: point = @ptr[point](y)`
when we write `x=y` we expect x and y be the same thing. if x points to y we have achieved this, but then x and y will be bound together.
for a newbie this might be confusing:
```
var x: Point = {a=10, b=20}
var y: Point = x
y.a++
print x.a ;will print 11!
```
OTOH, if we say `=` will copy data, above code will print 10 which is what we put into x initially.
in copy semantics: there might be cases where a `=` will be expensive (large data)
in ref-assign semantics: there might be cases where a `=` will be confusing (non-primitive data).
which case is more common? using large data or using non-primitives? I think non-primitives are used much more. so we should focus on those cases: we should prevent confusing behavior in ref-assign semantics. So we should use copy semantics. And in rare cases where a very large data variable is being used, the developer is responsible to ref-assign.
But we do our best not to involve developer into reference vs. data confusion. In eyes of the developer everything should be what it seems to be. `int` is an integer number not a reference number, although compiler/runtime will handle it as a reference to make other language features (e.g. var) work.
So when he writes `x=y` it expects y be copied into x.
to do ref-assign we should use either a special notation or a core function. using `=` will cause confusion.
`var x:BigBuffer = y` this is expensive! we should prevent it.
`var x: BigBuffer = &y` like C but it is confusing. left side is BigBuffer and then what is type of right side? How do you define `&y`?
`var x: BigBuffer := y` this is intuitive and makes sense but might be confused with type declaration.
Anyway, it is more consistent with type declaration concept. If we write `type MyInt := int` it will be some kind of assignment as a reference. MyInt is a reference to int type.
`x := y` will make x point to the same thing as y. 
`val x = otherVal` copy (or ref-assign due to optimization)
`var x = otherVar` copy
`val x = otherVar` copy (or ref-assign due to optimization)
`var x = otherVal` copy 
`= = = = = = = = = = =`
`val x := otherVal` ref-assign
`var x := otherVar` ref-assign
`val x := otherVar` ref-assign
`var x := otherVal` invalid. You cannot have a var pointer to a val memory area.
`= = = = = = = = = = =`
`val x = @val(otherVal)`  copy 
`var x = @var(otherVar)`  copy
`val x = @val(otherVar)`  copy
`var x = @var(otherVal)`  copy
`= = = = = = = = = = =`
`val x := @val(otherVal)` ref-assign
`var x := @var(otherVar)` ref-assign
`val x := @val(otherVar)` ref-assign
`var x := @var(otherVal)` ref-assign to copy of otherVal
I think this model makes more sense and is more intuitive. `=` copies right side into left side.
`:=` makes left side reference to the place right side is referncing. Of course both left and right must be consistent (var-var or val-val).
Now, do we still need cloning notation? `x=@y` -> `x=y`. no.
this will affect: `@val/var`, parameter passing and return, cloning, slice, array, binary.
I think we still need `@var/@val` notation. Especially in shortcut functions.
1. missing input qualifier = val.
2. missing output qualifier: val.
`func process(x: int) -> x+1` - return is var
`func process(val x:int) -> x` return is val
`func process(var x:int) -> x` return is a val
parameter passing: if val is expected, you can pass either var or val.
3. no more clone operator.
slice means a pointer and a length.
```
func get[V,T where vax: var|val](vax arr: array[T], index: int) -> vax T {
    vax T result := arr.data + index*sizeof[T]
    return result ;we cannot shortcut this by writing something like "return *(arr.data + index*a)"
}
```
`a:=b` means a should point to the memory cell which stored result of the right side.
`a:=b+1` means calculate b+1, store result somewhere and make a point to that location.
`a:=b+c+d+8` add right side values, store result somewhere and make a point to that location.
if you want a point to location of next cell after b, you must use core functions:
`a:=getOffset(b, 1)`
`var p1: int := getOffset(buffer, 8)` 
-what comes on the right side of `:=` is an address, but `a:=b+c+7` this doesn't make sense.
- We no longer need ptr type, everything is a pointer.
- `type slice[T] = (length: int, start: T)`
- `type array[N: int, T] = (size:int, data: binary[N])`
`var x : int := otherVar`
`a=b` means copy value of b into value of a
`a:=b` means copy b into a
`a:=b` is same as `a = &b` in C++.
`a:=a+1`
- We also don't need `@var/val`?
what if function wants to return a val? don't specify anything and result is val.
what if function shortcut wants to reurn a var? 
`func process(val x:int) -> var int x+1`

Y - Clarify:
can we have a read-only view of a read-write memory cell?
C++ can do this: The only thing special about a pointer-to-const is that you cannot change the pointed-to object through this particular pointer. It's entirely possible to change the object in some other way (https://stackoverflow.com/questions/27139496/pointer-to-a-constant-pointing-to-normal-variable).
So basically, `val x = var1` is ok and possible.

Y - Clarify single space in type definition and protocol too.

Y - The `:=` is a very powerful operator. But in what cases do we need it?
`x := y`. 
- When I want to have a val view on a var. But if function has val, I can simply send var to it.
- For internals of array and slice. (we can use native and implement in compiler or use core functions to get address and get/set operations, we can even use ptr type).
- When output of a function is a large data structure: `var x = getLargeBuffer()` will duplicate the buffer which is expensive.

N - Better encapsulation.
So if I change something, I may need to update 100s of places.
It is nature of fp.

N - function chaining: `=>` and `<=`.
Advantage: less paren.
`finalize_operation(1,9,4, $_) <= get_customers <= (1,9)`
`calculate(data) => print => save`
`data => calculate => print => save`
`data => calculate(_) => print(_) => save(_)`
`string => contains(':')`
simplicity: makes reading some code easier but more things to learn
power: no specific 
performance: no effect
Later

N - Provide features to implement more of the language inside the language.
Maybe extend assembly support.
What can be implemented using assembly notation?
`if x then y else z`
`loop`
This will need something more than usual function inputs.
Maybe it's too much to do in the language considering the fact that we want to keep gen and orth.
This can be done with macro but it's not good.

Y - can we remove continue and break? yes!

N - Can we simplify while considering the case that at the end of hash or array, the get operation will return nothing?
loop will continue until it gets false or nothing as the variable or result of iteration.
`loop(x <- [0..10])` or `loop([0..10])`
`loop(x <- [a..b])`
`loop(x <- my_array)`
`loop(k <- my_hash)`
`loop(n <- x>0)` or `loop(x>0)`
`loop(x <- IterableType) { ... }`
no it becomes very unreadable an confusing.

Y - infinite loop can be written as `loop(true)`.

N - force return to be last statement of the function and maybe simplify based on it.
the fact that we can define named output is a bit confusing with return.
why do we need function output? for reading/for writing.
for writing -> use return
for reading -> ?why?
if we use a notation for function output, we can have implicit single return and also defer can use it.
user is expected not to have complex and big functions. So one return statement makes sense.
```
func process() -> x:int {
    defer {
        var maybeException = catch() ;returns Exception|Nothing
        ;in case of an exception, return value should be 19
        if ( maybeException @ Exception ) x = 19
    }
```
let's allow multiple returns.
what about defer?
can we add a condition to defer? like if?
naming function output is werid.
if we don't name function output, how can I change it? use another return.

N - Create a compiler which does basic things (expression parsing, generics, ...) then implement the rest on dot, possibly with even re-write of original parts.

N - Doesn't it make more sense if I write `x:=y+1` to address byte after y?
No it is super confusing, even though we are using a different notation `:=`.
`x := getAddress(y)+1` makes more sense
`x := getOffset(y, 1)` is good too.
to be more formal in `x:=y`, right side must be of type `ptr`. And you cannot create ptr. you must ask core.
So `x:=y` should not make sense! because y might be int, not ptr. Also adding ptr makes things more confusing.
So what comes to the right side of the `:=`? It is a single variable or expression.
`x:=y` makes x point to y.
So when I am working in slice or array, and want to get to a specific index in the array:
`result := getBufferOffset(myBuffer, offset)`. This is a bit confusing.
right side of `:=` is an expression. it is result of a function call. this function returns an int (or any other type) which is sitting inside a binary. So can I just call it normally to have a copy?
`var t:int = getInsideBuffer(myBuffer, 10)`? should be ok. but I should choose a better name.
This can be seen as a cast with an offset.
`var x:int = @int(y)` cast y to int.
`var x:int = @int(myBuffer, 10)` you can cast a buffer to another type (whole or from a specific index).
`var x:int := @int(myBuffer, 10)` now x++ will update inside the buffer.
But cast is suppose to make a copy! `var x = @int(maybeInt)`. isn't it?
We can say that cast can make a copy or not. if type is matching, it won't create a copy.
`var x:int = @int(otherInt)` this won't create a copy!
this is more intuitive than calling another function. 
Does this give people access to inside a tuple?
`var x:int := @int(myPointTuple, 4)`? at least in syntax this should be possible, while if we use functions, we can simply enforce only binary input.
`func readBinary[T](x: binary, offset: int) -> T`
To be decided later.
But the syntax for `:=` is similar to C: `int* x = &y`. You cannot write `int* x = &(y+1)` it does not make sense.
C uses `&` so it is more intuitive that we cannot write `&(y+1)`. But here `:=` implies a more extended notation.
`x := y`, `x := variable`, `x := process(...)`

Y - Why do we need a separate `nothing` type? It should just be part of a Maybe type.

N - unify types: Mark all types based on `MyDataType`.
`binary, int, char, float, array, map, bool, string`

N - Note that generics are resolved using static type not dynamic type.

N - When iterating through a custom type, what if it returns `maybe<int>`?

Y - Put map, array and other non-language things in a separate section. First explain the core language. Then constructs which are built based on them.
Just say array and map are part of core and explain about syntax sugars that compiler provides.

Y - Remove phantom types. They can be easily implemented with named types.
`type Sha1Hash := string`
`type Md5Hash := string`

N - Replace sum type with a tuple which we can only set one field's value.
Does this help with inheritance in sum types? type matching? enum? error handling?
What about adding a tuple where all fields have the same name:
`type IntFloat := {x:int, x:float}`
Or better yet: An unnamed tuple!
`type IntFloat := {int, float}`
`type Maybe[T] := {T, Nothing}`
How are we then going to represent the fact that it can only have one value?
`;`? This is a union so these fields are all stacked on top of each other.
What do we want to simplify?
maybe a normal tuple with flag:
`type IntFloat := {i: int, f: float, status: int}`. if status is 1 then i has value, if it is 0 then f is valid.
Sum type can be simulated with tuple but needs more code: set status when you write something.  check status when you read something back to know which field is valid. 
Advantage: We won't need `@` for that, the rules about not-overlap in sum type won't be needed anymore (`type s := Circle | Shape`).
Maybe we can solve the overlap problem with tagging, like Haskell:
`data EitherIntInt = Left Int | Right Int`
Then how can we read/write values? It is not intuitive.
`type intOrFloat := int | float`
`var x: IntOrFloat = 1 ;or =2.233`
The overlap problem can be detected at runtime. But anyway, maybe we can accept that, based on the dynamic type of the variable. So if we assign circle to `shape|circle` it will be there as a circle not a shape.
Can we think of dynamic/static type like a sum type?

N - Dave Cheney: Most programming languages start out aiming to be simple, but end up just settling for being powerful.
Something which is simple may take a little longer, it may be a little more verbose, but it will be more comprehensible.
limit the number of semantic conveniences
The 90% solution, a language that remains orthogonal while recognizing some things are not possible.
About the simplicity, I think the core of dot is about "guarantees". When I declare a typed int variable, I have a guarantee that it won't have a string. Same for optional/Maybe (I have a guarantee that variables will be one of these two).
Also about generics, I have a guarantee the it will act acording to the protocol I have specified.
For val, I have a guarantee that it will be immutable.

N - Problem with templates in C++:
- makes code unreadable, difficult to maintain
can we replace them with something like `constexpr` in c++?

N - Now that everything is ref and `=` is to copy value, whenever I am working with tuples, I have to keep in mind to use `:=`. which is a bit hard because people forget things.

N - Can we drop generics and keep protocol?
`type array := anything`
`protocol getIndex := ...`
`func sort(x: anything + getIndex + Ord) ...`
`func getIndex(x: array)...`

Y - remove `defer`
RAII like C++ can help us remove `defer`.
applications of defer: close db/net connection, close file, unlock mutex
con of defer: make code unreadable, what if defer inside defer?, what if I want to change output in defer, what if I run a new thread in defer, what if there is an exception inside defer?, what if I defer x.close and return x? what is order of defers? how/when are defer argument evaluated?

Y - remove exceptions
What can be a good use case for exceptions? Now that we have maybe?
Thsi can remove catch, throw and maybe defer.
e.g. in SerDe when format is incorrect, something is missing, cannot cast.
use case: prevent a plugin or thread crashes the whole app.
option: when you load a plugin, you can get control of it's lifecycle. same when you create a thread or green thread. You can define a result/output to be updated when thread or goroutine calls "system_exit" to end the process.
For these special cases we can have something like: `invoke` which will return `T|Error` where T is output of the function.

Y - What happens to assert then?
option 1: if it is failed, exit the process. As this is a real exception, dedicating a keyword for it does not make sense.
option 2: a shortcut for returning error.
`assert str.length>0, xyz` if condition is not satisfied, return xyz
`assert str.length>0, xyz` -> `return xyz if !(str.length>0)`. We can use postfix if instead!
remove assert and replace with if/return.

N - What is the main source of complexity now?
template?
polymorphism and subtyping?
sum types? no.
protocol?
immutability?

Y - Can we make the special behavior of compiler toward array and hash literals, not special?
Maybe by calling `opCall` on a temporary mutable instance?
`var x: array[int] = [1, 2, 3]`
`var y: map[int, string] = [1:"A", 2:"B", ...]`
anywhere compile sees `[a,b,c,d,...]` or `[a:b, c:d, ...]` it will call `opCall` for the expected type with index and value or key and value. So this is a general behavior. `[a..b]` means `[a, a+1, ..., b]` and other syntax sugars.

Y - Is there a way to model a general function? 
For example to define `invoke` function to run another function in parallel or with an exit/exception handler.
`type function[A,B,C,O] := func(A)->O | func(A,B)->O | func(A,B,C)->O`
maybe we can call every function with an unnamed tuple matching it's inputs.
`func process(x:int, y:string)`
`var g = {1, "A"}`
`process(g)`
`func process(g: {int, string})`
solution 1: variadic templates
solution 2: sum types
`func invoke[A,B,C,O](f: function[A,B,C,O], input: {A,B,C})->O|Exception`
What is the difference between these two?
`func process(x:int, y:string)`
`func process(g: {int, string})`
can we do a recursive definition?
`type function[I,O] := func(I)->function[I, O]`. no it's too confusing.
the question is: how can we model the input of any function as a specific type? the only viable solution is a tuple. 
we can say for each function `func process(x:int, y:string)` compiler defined another function with a tuple input.
`func process($: {x: int, y:string})->process($.x, $.y)`. So every function can be called with a tuple with appropriate types.
or put it another way: the invoke works with functions with single input. if your function has multiple inputs, simply write a wrapper function or a closure. Anything that compiler does behind the scene can be source of confusion.

N - Remove/simplify generics:
If everything is supposed to be a reference, maybe generics can be simplified into a normal generic type with `void*` or similar. then `anything` type is actually just a pointer.
on option: only use generic to specify output type of a function (which means automatic casting only). In this case, maybe we can use a simpler notation rather than `[]`: `int x = pop!int(stack1)`
So `f!T(x,y,z)` is just a shortcut for: `@T(f(x,y,z))`.
We define `anything` as something like `interface{}` or `void*` or `Object`.
issue: Then array will be just a set of pointers. So array of 3 integers will be 3 pointers to 3 integer -> waste memory space.
how can we implement array without generics and with anything/binary?
`func array(size:int)`
 
N - binary can be parent type of all non-tuples and `{}` parent of all tuples.

N - can we remove `where`?
`func get[vax, T where vax: var|val](vax arr: array[T], index: int) -> vax T`

N - Can we remove protocol?
protocol is used to abstract over a behavior. I say I can accept any type as long as it has this specific behavior. I don't care what that type is. Because I only need that specific behavior.
q: can we document the laws of protocol in the code? e.g. in Ord, it should be transitive
q: What if a type implements a protocol in more than one way? e.g. type int, implements Ord in different ways using different functions.
other option: make method names anonymous and let type explicitly state which protocols it implements and what is the name of corresponding methods.

N - Can we replace subtyping with functions?
and maybe use protocols?
```
type Shape := { name: string }
type Circle := { shape: Shape, rad: float }

protocol ShapeChild[T] := {
 func toShape(T)->Shape
 func fromShape(Shape)->T
}

;this function can act on any type that "claims" to be a shape (claim = implement appropriate function)
func processShape[T: ShapeChild](s: T) { 
  var x: Shape := toShape(s)
  x.name += "A"
}
func toShape(x: Circle)->Shape { return x.shape }

var ss: array[Shape] = [toShape(createCircle()), toShape(createSquare()), toShape(createTriangle())]
loop(s: Shape <- ss) processShape(s)

;when you define a function with protocol, you are stating that you can call this function with any type that 
;satisfies this protocol.
;for variable declaration, you say you can put anything inside this array if it is providing this protocol.
var s: array[T: ShapeChild] = [createCircle(), createSquare(), createTriangle()]
func getItem[T](arr: array[T], index: int) -> T { ... }
when you call getItem(s), the result will be `T:ShapeChild`. But this is not how an array should behave.
```
If caller uses `:=` it can mutate inside the parent type by having a pointer of child type.
`var x: Shape := createShape()` x will have static type as Shape but dynamic type may be different.
What parts of subtyping causes a change in the language/syntax/semantics: 
1. automatic conversion from child to parent when needed: `process(myCircle)` fwd to shape
2. ability to store data of type child in variables of type parent: `var s: Shape := createCircle()`
for 1, we already have forwarding methods: `func process(x: Circle->Shape, y:float)` to make it explicit.
`var s: Shape := createCircle().Shape`. But for performance reasons, the parent should be unnamed.
subtyping and generics are two important tools to support for polymorphism.
why do we want to remove subtyping?
problem 1: sometimes we want B based on A but it should not behave like A.
- Just like the way we do not automatically cast MyInt to int, we also don't cast Circle to Shape.
- What if you cannot put a Circle inside a Shape variable unless you cast by calling function?
- Real example: A logger utility where there are different loggers: FileLogger, NetLogger, ConsoleLogger, ...
`type FileLogger := ...`
`type ConsoleLogger := ...`
`protocol Logger[T] := { func doLog(params: T, data: string) }`
`func process[T: Logger](logger: T) { doLog(logger, "Starting...") ... }`
What do we mean when we say "remove subtyping"? 
`var s: Shape = createShape(parameters)`.
Is the notation that a variable can be of type Shape but hold a Circle, a good/accepted thing?
can we simulate/support this notation using current tools? 
How can we model an expression parser (add, minus, ...) or a JSON file model (string, int, map, ...)?
FP languages use sum types for this.

N - Can we remove polymorphism or simplify it? or method dispatch?
The underlying principle is Liskov substitution rule. I should be able to substitute Circle with Shape.
Either in a function call or assignment:
`var s: Shape = myCircle`
`process(myCircle)` where process expects a Shape.
what if the developer can explicitly indicate he wants a variable which can hold both static and dynamic type?
in OOP when we see `x.f()` we don't know which method will be called because x can be anything.
in FP, we use type-classes so we know. `f[X](x)` indicates function of the typeclass for type X will be called.
e.g. `area[Circle](myCircle)`.

N - Can we make generic types and protocols, more built-in and consistent?
`func sort[T: Ord](arr: array[T])-> array[T] { ... }`

N - Sometimes it is good to force caller of a function to use `:=`. For example when it is casting circle into Shape.
can we make this transparent? so even if they use `=` they won't loose dynamic type.
`var s: Shape = myCircle.Shape` - copy as a shape
`var s: Shape := myCircle.Shape` - reference to a shape
`var s: Shape = myCircle` - copy the whole circle
`var s: Shape := myCircle` - point to circle as a shape
Having `s := myCircle.Shape` is dangerous because if s is returned but myCircle is not, how are we supposed to free memory?
But this is a normal pattern. Just like having an int point to inside an array and returning that integer.
At least this is possible in C++ and Golang, but in golang the whole structure will not be GCed until the part is valid.
Anyway, this is more like an implementation strategy which should be handled by compiler, runtime, GC.
You cannot force caller to use `:=` but you can use `=` before return to return a small structure.

N - Like C++ move semantic
If I write `buffer = buffer1+buffer2` result of right side is a temp var so instead of deep copy, I can run `buffer := 1+2` instead. This is implementation.

N - remove `:=`?
Can we say if function returns `var X` we must use `:=`?
If so maybe we can fully eliminate `:=` notation.
`var x = getVarInt()`.
Here it does not really make sense to use `=`. It should be `:=` because rvalue is a temp var.
Can we eliminate `:=` completely? and infer `=` or ref-assign?
`var x:int = y` should this be `=` or `:=`?
in many cases compiler can deduce `=` or `:=` (if it is a primitive, `=`, if it is tuple, `:=`) but in some cases it is not flexible enough. for example if a function wants to return a reference to a primitive.
or we want to send a copy of a tuple -> solution is to clone.
main issue is with lack of gen and orth when we have: `func process()->var int`.
If convention is copy-value for primitives, then we cannot get the reference.
`var p: Buffer = processData()` should this copy the whole structure?
If processData output is val, it definitely will duplicate.
But if processData output is var, then rvalue is a temp, then `p := processData` is better. compiler can do this optimization but what should we do with added confusion over `=` vs `:=`?
can we remove `:=`?
we say `=` will duplicate right-side into left-side but will ref-assign if?
`var x = y`
`var buffer = processData()`
How can we elegantly and with simplicity say `=` will duplicate for primitives but ref-assign for tuples (for var-var case).
advantage of `:=`: getting rid of cloning operator and cast to val/var (because `=` makes a copy).
Now `=` has a consistent behavior and so does `:=`. But without `:=` we need to set rules for `=`.


N - If caller can send a var to a function as val, it can change its value and it can be cause of race.
A race condition occurs when two or more threads can access shared data and they try to change it at the same time.
if a method wants an input but does not care whether it is var or val it can use generics.
But if it wants to use that variable in concurrency situation and wants to make sure it will be `val` it must declare parameter as `val`.
Why not default to var/val if input argument has no qualifier?
So if function input does not have a qualifier, it can be var or val but function should treat it as read-only/immutable.
what about output type?
if output qualifier is missing, function can return var or val, but caller should treat it like a val.
Is this correct? `val x = var1`. No. `val` is not a "read-only view" of a memory cell. It should be a real read-only memory cell to which only vals are pointing.

Y - this should be forbidden: `val x := otherVar`

? - What are the problems with generics?

? - What are the problems with subtyping and polymorphism?

? - Make it easier to check for errors?
`var x = process()`
`if ( x @ error ) ...`
`if ( var x = process(), x @ error ) ... else ...`
`var x = if ( var temp = process(), temp @ error ) -1 else t`
Is it possible to use monad to call a series of functions and return error as soon as any of them returns error?

