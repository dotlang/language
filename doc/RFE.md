N - `x=literal` will copy-value because litearl is not reference type.

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
which case is more common? using large data or using non-primitives? I think non-primitives are used much more. so we should focus on those cases: we should prevent confusion behavior in ref-assign semantics. So we should use copy semantics. And in rare cases where a very large data variable is being used, the developer is responsible to ref-assign.
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

Y - Make it easier to check for errors?
`var x = process()`
`if ( x @ error ) ...`
`if ( var x = process(), x @ error ) ... else ...`
`var x = if ( var temp = process(), temp @ error ) -1 else t`
Is it possible to use monad to call a series of functions and return error as soon as any of them returns error?
Better if we provide a general mechanism so it can be used with other cases too.
```
func bind(input: Maybe[double], f: func(Maybe[double])->Maybe[double])->Maybe[double] 
{
  if ( input == None ) return None
  return f(input)
}
func try[T](input: T|Exception, f: func(T)->T|Exception)->T|Exception
{
  return input @ {
      e: Exception -> e,
      t: T -> f(t)
  }
}
var result = do(do(do(x, process1), process2), process3)
;or
var result = (x, process1) |> do |> (_, process2) |> do |> (_, process3)
;which is completely unreadable
var result = do do do x, process1, process2, process3
;or: input |> func
var result = (x, process1) >> do >> 
             (_, process2) >> do >> 
             (_, process3) >> do
;maybe we can use loop:
var input: Maybe[int] = 5
input = loop(var x <- [process1, process2, process3]) { input = do(input, x) }
;but this is not very readable. user cannot read the flow of execution.
var result = try(x, process1) >> 
             try(_, process2) >> 
             try(_, process3)
;better than other choices but still we need >>             
var result = try { (x, process1) >> (_, process2) >> (_, process3) }
;above is not readable
;can we use opCall? for example on a Maybe?
var input: Maybe[int] = 5
input(process1)(process2)(process3)
;opCall on maybe will receive a function, apply it on the maybe and return another maybe
var finalResult: Maybe[int] = input(check1)(check2)(check3)
;advantage1: no more nested paren
;advantage2: We have used existing mechanisms
;advantage3: no need to add a new chaining operator
;advantage4: it is readable
func opCall[T](m: Maybe[T], f: func(T)->Maybe[T])
;what if function has more than one input?
var finalResult: Maybe[int] = input(check1(5, _))(check2(_, "A"))(check3(1,2,_))
;original method:
var finalResult: Maybe[int] = do(do(do(input, check1(5, _)), check2(_, "A")), check3(1,2,_))
;which is way longer than opCall approach. We just need _ to create a lambda on the fly.
```
- Add notation of `_` to create a lambda from an existing function. This is readable and short and can be used in other places.
- You can use opCall to chain a set of method calls and handle an error in-between.
If we have an existing function f with n arguments: `f(a1, a2, _, a4, a5, _)` will create a lambda expression with two inputs which will call `f` with given argument values. q: when are `ai` values evaluate? what if we have `n=f(x, _)` and value of x changes later before we call n? they will be evaluated at call time.
`var t = f(a1, a2, _)` is same as `var t: func(int)->int = (x:int) -> f(a1, a2, x)`

N - What are the problems with immutability?

N - remove var/val keywords and replace with with prefix to variable names.
`val` -> no prefix.
`var` -> `$` prefix.
What about function inputs without qualifier?
`x:int = 12`
`x=12`
no! variable declaration should be explicit.

Y - We can say that compiler will translate each tuple to a named type on top of `binary[N:int]`. So every possible type is a binary.
`type Point := {x:int, y:int}`
is translated to:
`type Point := binary[16], x_offset=0, y_offset=8`
Also union types are translated to a binary with size=largest choice.
How does named types work with subtyping?
what is order of resolution?
`type MyCircle := Circle`
`type X := {MyCircle, ... }`
first the type hierarchy is tried (from T1 to it's parent ... up to empty tuple).
If no choice is found, will switch to the underlying type.
But is that possible that no choice is found in the type hierarchy of the T1? If so, how come compiler permits this?
Maybe we can say `process(T1)` is ok with compiler if there is at least one `process` function which accepts an input which is super-type of T1. This can be it's static type, parent type, empty tuple, it's underlying type, or at the end, binary type.
I think compiler should choose a static-candidate at compile time and at runtime, the runtime system should either find a full dynamic type match or call this candidate.
Suppose that we have `binary -> Shape -> Polygon -> Square` types.
and: `type MyType := Square`
then: `MyType -> MyChild -> MyGrandChild`
then if a variabe of type MyGrandChild is passed to a function.
For static candaidate this is the ordered list: MGC, MC, MT, Square, Polygon, Shape, binary
for dynamic candidate same path will be available. if for example dynamic type of the variable is `MyGrandChild` and there is `func process(MyGrandChild)` it will be called (note that this can be a fwd function).
It not found, the static candidate will be called.

N - if we want to eliminate templates, what would happen to array?
`type array := `?

N - Is it possible to treat template types just like normal arguments but with special notation?
`func max[T](x: T, y:T) -> return x if x>y else y`
`func max(~T, x: T, y: T)-> return x if x>y else y`
`var t = max(int, x, y)`
what about types? `var array[T]`

Y - To prevent substitution failure: indicate template arguments can either be a type, identifier or a literal.

N - using `:=` with a var output of a function does not make sense.
`var x := getPtr()` is same as `var x = getPtr()`?
consider a `var int` 
`var x:int = 19` we have this: `119:[100]-----------------> 100:[19]`. where 100 is the memory address which contains the value. the actual value inside x is 119, because it is a pointer.
`x=11` means write `11` into the memory x is pointing to (100). so we will have:
`x:119:[100]-----------------> 100:[11]`
support we also have: `var y:int = 13`
`x:119:[100]-----------------> 100:[11]`
`y:120:[101]-----------------> 101:[13]`
then `x := y` means writing 101 into address part of x.
`x:119:[101]---------------|`
`y:120:[101]---------------|-> 101:[13]`
so when I have `func getPtr()->var int` calling it will give me this:
`temp:130[102]------------------->102: [311]`
then `var g := getPtr()` means:
`temp:130[102]-----------------|->102: [311]`
`g: 131[102]-------------------|`
and `var g = getPtr()` means:
`temp:130[102]------------------->102: [311]`
`g: 131[103]--------------------->103: [311]`
don't focus on `var/val`. everything is a reference. the point is: do you want to have access to the original data? if so, use `:=` else use `=` which will duplicate the original data for you.
so there are two points: 1)to what is this variable pointing to 2)is it possible to change it?
this may be a bit confusing. can it be made simpler?
assigning a var function to another var using `=` is like:
`int* p; *p = *getdata()` in C. it does not make much sense but making it forbidden is not good for consistency.

Y - Note that you can use `getOffset` to map a whole tuple on top of a binary. Although this is a hack but can be sometimes useful for performance.

Y - We can use `allocate[int](100)` for fixed size allocation. So let's remove literals for template args.
`type int := binary[8]` -> `type int := binary` and compiler will write appropriate `allocate` call.

N - What if we have multiple implementations for a protocol?
`protocol Ord[T] := { func compare(T,T)->int }`
`func sort[T: Ord](arr: array[T])-> array[T]`
sort expects existing function `compare` for any given type T. Suppose that I have a Customer class.
Sometimes I want to sort them by name and sometimes by their id.
`sort(customerList) ;sort by id`
`sort(customerList) ;sort by name`
How can I do this?
solution1:
`protocol Ord2[T] := { func compare(T,T)->compareById(T,T) }`
`sort[Customer: Ord2](customerList)`
So when I call the function, I explicitly specify the type for the template + a similar protocol name.
`process[int, string, Customer where Customer: Ord2, int,string: Ord3](...)`
similar protocol: protocol Q is similar to P if: Q has all the methods of P with possibly redirection to another method.
But this does not make much sense.
Solution 2: Implement with a function pointer to compare
Another solution: write everything normally. But inside the sort function decide how to sort.
Another solution: Use subtyping. define the protocol function for subtype.
```
protocol Ord[T] := { func compare(T,T)->int }
func compare(Customer, Customer) ...
type CustomerSortId := Customer
func compare(CustomerSortId, CustomerSortId)...
```

Y - Applications of casting `@`:
cast between named type and underlying
cast between elements of union and union type
cast between subtype and suprtype
cast anonymous tuple to typed
cast int to float

N - For every non-tuple type, compiler should be able to detect their type at compile time.
for tuples: each pointer contains an extra block before actual data which indicates the dynamic type.
It is updated when a value is assigned to the variable.
So maybe variable is Shape but it's memory block indicates it is a Circle.
method call resolution will happen using this information + default candidate specified at compile time.

Y - Can we solve var/val issue with something else (non-generic). So generics will only have type arguments (int, float, ...)
e.g. get element from var/val array or add two numbers.
`func add(a: BigInt, b: BigInt)->BigInt` this will accept var or val and return result as a val. 
Add does not count. The only case is where, function returns "part" of it's input as output. in this case, if input is var output will be var, same for val.
If input is taken from parts of two inputs, then this does not count.
just like how strchr works.
`func strchr(x: string)->string` return is val.
Let it be like that. user will need to write two functions, he can write once and call it in the other case + duplicate.

Y - can functions be overloaded based on return type or val/var?
1. `func process()->int`
2. `func process()->var int`
3. `func process()->val int`
1 and 3 are the same. so they are not allowed with each other.
but 2 is ok. `var g = process()` will call 2.
what if user does not collect function output? it should be banned.
but if we use `var/val` without type, it will cause problem.
`func process()->var int`
`func process()->var float`
`var x = process()` which one to call?
So var/val of return type is part of signature but not the return type. Because it will be possible to infer type from method call. 
`process/int/var.int/val.float/val` is a condensed view of the signature of the funtion.


Y - Can we simplify where?
`func process[S, X, N, M, Q, P, T where S,T,X: prot1, N,M: prot2, T,N: prot3, P, Q]`
shortcut: list expected func = operator to check existence
- move it inside function to make it more readable (still compile time)
as this is only valid for compile time, not being part of function definition should not matter much.
a protocol is like a function which returns a bool.
q: can we specialize protocol for a specific type? no it does not make sense. But we can have different funnctions with same name and signature but different protocols.
q: what about lambda and closure?
putting it inside the function body does not also make sense. It should only be for runtime.
```
protocol Ord[T] := {
    func compare(x:T, y:T)->int
}
func sort[T] Ord[T] (x:T[])
func process[S, X, N, M, Q, P, T]  prot1[S,T,X] prot2[N,M] prot3[T,N]
```
This makes more sense. After `[]` in function declaration we can list of protocols that we expect. It is a bit similar to generic function definition but should be fine as it clearly follows the actual function declaration.
```
;we can overload protocols
func sort[T] Ord[T](...)
func sort[T] StrictOrd[T](...)
```
If we call sort function, compiler will decide which protocl best matches.

N - Now that there is no assert, how can we check for types? 
We said `@` expressions are evaluated at compile time. just use if

Y - How to define alias for generic types?
`type A = int`
`type S[T] = Stack[T]`
`type ST = Stack[int]`

Y - Just like the way function can determine protocol of generic, can a type determine data of a generic argument?
can those generic arguments form a relation with each other? like the way we have with functions?
```
;this does not make any sense. Type does not have anything to do with behavior defined for a specific type
type Stack[T] proto1[T] := {...}
;Set can be defined only on types that can be compared.
type Set[T] comparable[T] := { ... }
```
- Maybe a type can also depend on protocol definitions for it's arguments.
- What about data? sort, graph, tree, queue, list, hash, pair, 
Type does not have any behavior so it cannot read/write or check the data aspect of it's generic type.
but the same way we use concepts in C++ for class, we should be able to use protocols for both function and types. 
```
;do we need to repeat protocol for type and functions?
type Set[T] comprbl[T] := array[T]
func add[T] comprbl[T] (s: Set[T])->...
func get[T] comprbl[T] (
```
Maybe we should not worry about behavior of the data when defining generic types over them.
Let set accept any type it wants. related functions will have protocols in place (we definitely need protocols for functions).
but if a protocol is defined for a type, functions working with that type can omit that protocol.
If set has comparable protocol, read/write functions dont need to define it twice.
But in some cases like Stringer, there is no specific type that should define a protocol. In these cases functions define the protocol constraint.
`type Complex[T,U,V] prot1[U,V] prot2[T, V] prot3[T, U, V] = { ... }`
So you cannot even create a Set with something which is not comparable -> more strict and explicit type system.
`type Set[T] comprbl[T] := array[T]`
`type Set[T] := comprbl[T] array[T]`
`type Customer[T] := serializable[T] { name: string, ...}`
This can affect subtyping. If parent type has a protocol constraint, child does not need to define it again?
`type Shape[T] := prot1[T] { ... }`
`type Circle[T] := { Shape[T], ...}`
No child does not need to, but the protocol will be enforced by the compiler.
Some examples on why we need protocol for type definition:
- Set[T] can only be used with types which are comparable. We cannot define `Set[adder_function]`
- BinaryTree[T] can only be used with comparable types so we can do search on the tree.
- Bloomfilter can be only used with types which have hash defined.

Y - Can we enforce data fields using a protocol?
`protocol HasId[T] := { func getId[T](x: T)->x.id }`?

Y - Can we replace protocol with a compile-time function?
```
protocol Ord[T] := { func compare(T,T)->int }
;protocol is a function which returns a bool
;
func Ord[T]() -> bool {
    ::Compare(T,T)
}
```
pro: it's using existing features
pro: it's more expressive, maybe we can later add other things too
pro: embedding will be translated to function call which is more intuitive
pro: expressive in terms of function input and it's contents
q: how can we ensure relationships? `!=` should be inverse of `==`? this needs calling a function which is not possible at compile time. 
in protocol definition for comparable we can say: `!=` is inverse of `==` and provide a default implementation.
this is called axiom in C++ concepts or default methods. But axiom is more flexible.
The things is, axiom is mostly used to document type and it cannot be enforced by compiler.
https://akrzemi1.wordpress.com/2012/01/11/concept-axioms-what-for/:
Axioms are meant to express semantic requirements or assumptions about template arguments. 
Unlike syntactic requirements (e.g., requiring operator==), semantic requirements expressed with axioms cannot be validated by the compiler when matching a model against the concept. So axioms only express how we would like the models to behave, but the there is no way to force the models to implement the required semantics.
C++ Axiom uses `and, or, =>, <=>` to express relationships.
can we check axioms at runtime? it is dangerous, can have side effects and make code slower.
But the notation for compile-time function should be different. So for example they cannot define variables.
```
protocol Ord[T] := { func compare(T,T)->int }
;protocol is a function which returns a bool
;:= means it is compile time
;we can use `=` for inline maybe
;if a compile time function has inputs, they must be literals, in this case it will be more like constexpt
func Ord[T]() -> bool := {
    ::Compare(T,T)
}
```
We need a syntax to check a function exists.
And to define an axiom.
```
;to make it simpler, it cannot have any input
func SerDe[T] -> bool := {
    ::serialize(T)->val string
    ::deserialize(string)->var T
    ::deserialize(serialize(T)) => T   
}
```
- If we can make this more intuitive
- This type of task that is assigned here does not match with definition of a function. We seem to be trying to make a cat look like a dog. We need to define notation for checking function exists, axiom, remove function input, add `:=` notation, ...
all to eliminate `protocol` keyword.
```
protocol SerDe[T] := {
    func ser(T)->string
    func des(string)->T
    func reflectivity(x: T) -> des(ser(x)) <=> x
}
protocol Eq[T] := {
    func equals(T,T)->bool
    func notEquals(T,T)->bool
    func default(x: T, y: T) -> equals(x,y) => not notEquals(x,y)
    func identity(x: T) -> equals(x,x)
    func reflectivity(x: T, y:T) -> equals(x,y) => equals(y,x)
    func transitivity(x,y,z: T) -> (equals(x,y) and equals(y,z)) => equals(x,z)
}
```
we can say, functions without body are to be checked by compiler to be defined.
Functions with a body, are merely for formal documentation of properties of that protocol.
protocol inheritance: `protocol SerDe[T] := Eq[T] { ... }` 
- We can add `=>` notation as an operator which means logical `if`.
`var t = x=>y` implies operator, means `t=if x then y else true`
- `<=>` equivalence of behavior/computation. `t=x<=>y` means `t=x iff y`.
if we have `if` only defined for boolean type, then `<=>` is same as `==`.
- `<=>` is extra?
`x + 5 == y + 2  <=>  x + 3 == y`. might be useful and make axiom more readable.

N - can we use `=` to force inline?
`func process() = { ... }`
it is like a variable. so everytime process is called, it will be replaced with right side of `=`.
No. The syntax for inline should be inside function body. Nothing should be changed from outside.

Y - We can have protocol inheritance just like the way we define protocol for a type.

Y - Can we make this more readable? same for protocol inheritance and protocols in type definition.
`protocol Eq[T] := Ord[T] { ... }`
`func process[S, X, N, M, Q, P, T]  prot1[S,T,X] prot2[N,M] prot3[T,N]`
`type Set[T] := comprbl[T] array[T]`
the syntax for define protocol is exactly like function or type definition. 
Why not use embedding for protocols too?
`protocol Eq[T] := { Ord[T] ... }`
for function, use `:prot` to "enforce" it.
`func process[T,U]  :prot1[T,U] :prot2[T] :prot3[U] (x:T, y:U) {...}`
but `:` is not clear for type declaration. 
`type Set[T] := :comprbl[T] array[T]`
Another solution to make it clear: protocol names should start with a specific character.
`protocol $Eq[T] := { $Ord[T] ... }`
`func process[T,U]  $prot1[T,U] (x:T, y:U) {...}`
`type Set[T] := $comprbl[T] array[T]`
but this is not very beautiful.
`protocol Eq[T] := { Ord[T] ... }`
`func process[T,U] (x:T, y:U) prot1[T,U] {...}`
`type Set[T] := $comprbl[T] array[T]`
- maybe it's better to place protocol name after function inputs, so function signature order is not changed.
- we have to declaration: protocol definition and protocol enforcement. 
for definition we don't need to do anything.
for enforcement of a protocol on a function input or type, maybe using a different notation is better to make it more explicit. `=:`? or maybe use protocol name as a pseudo function? no.
or use a keyword like `requires`, `assert`, `assume`, `promise`, `where`, `with`.
q: How do we handle inheritance for protocols? what about conflicts? let's not make this too complicated.
a protocol can ask for enforcement of another protocol. If there is any conflict, it is developer's responsibility to solve it. We won't add any extra notion to handle these exceptional cases.
`protocol Eq[T] := +Ord[T] { ... }`
`func isInArray[T](x:T, y:array[T]) +Eq[T] -> bool { loop(var n: T <- y) {if ( equals(x,n) ) return true} return false }`
`type Set[T] := +comprbl[T] +prot2[T] array[T]`

Y - What about protocols with lambda?
`var f1 = func(x: T, y:int) +prot1[T] -> int { return x+y }`
`type adder[T] := +prot1[T] func(x: T, y:int) -> int`
`var rr: adder[T] = (x,y) -> x + y`

Y - Shall we explicitly indicate if a type is disposable (has dispose function)? What about other such requirements?
I think this is another application of protocols. If we want to indicate (for the developer or documentation) that a type confirms to a specific behavior, we use a protocol without argument which implies the argument is the type itself. This is not applicable for functions. Similarly we can explicitly indicate that a type has `equals` function.
```
protocol Disposable[T] := { func dispose(T) }
type FileHandle := +Disposable int
```

N - Why not add var/val to the type?
`let x: var int = 1`
this makes things messy. maybe we should use notation?
using `def` makes things confusing with Python but we don't care about Python here.
`def x: var int = 1`
we are doing this (attach mutability qualifier to the type name) in function output! so let's make it consistent.
`func process() -> var int`
So we can have 3 types: var, val and no qualified (used in function I/O, indicating it can be either val or var but should be treated val).
`var int` -> `int&`
`val int` -> `int!`
`int` -> `int`
But note that when calling a function or creating a type with template which need a type, you must not pass `int&`. because it will make everything super messy. a mutable array of immutable int, an immutable stack of mutable floats..
What about this?
`func process[T](var x:T)`
how can we translate this to the new model?
`func process[T](x: var T)`
so types used as generic arguments cannot include mutability qualifier. Maybe we should not use notation and use keywords.
`var int`
`val int`
problem is: it makes code messy and hard to read:
`var x:int` -> `def x: var int`
pro: explicit is better
pro: only 5 characters more.
pro: will not cause confusion with templates.
`def x: var int = y`
another option: notations like `$`
`$ x: var int`
what about type inference?
old: `var x = process()`
now: `def x: var = process()`?
for type inference: right side of `=` or `:=` has its type and var/val. If we just want to use it we can simply write:
`def x = process()`. If we want to state a qualifier:
`def x: var = process()`
or most explicit one:
`def x: var int = process()`.
can we say, if no qualifier it is immutable. if var it is mutable? this may be more consistent with function definition.
`def x: int = 12` x is immutable
`def x: var int = 11` x is mutable
`def x: var = process()` x is mutable of type output of process
`def x = process()` type and imm same as output of process
`func process(x: int, y: var int)` x is immutable. y is mutable. but how can sender send mutable variables for x?
maybe we should simply state `x:int` in function input means you must send immutble variable. if you have a mutable you should make a copy.
pro: variable definition becomes cleaner.
con: functions become less flexible. previously we have 3 options (var, val, no qualifier) but now we only have two (var, no qualifier).
how can we have both? flexibility in function where we can state we accept immutable or mutable or anything. and clean syntax to define variables without needing to type var/val/def all over the place?
There are two orthogonal concepts regarding variables: storage class and type.
template is about type.

Y - storage class can be val or var.
`storage_class var_name: type = rvalue`
only for function output, there is no var_name so we omit it.
`func process() -> val:int { ... }`
`func process() -> int {...}`
`func process() -> var:int {...}`

Y - `native` is a trivial keyword. Can we replace it with something else?
`func assemblyAdd(x: int, y:int) -> int {...}`
`type binaty := binary`

Y - If we use LLVM, then assembly code and os/cpu filter won't be needed.
But we may need to write bitcode inside the code and indicate it needs to be inlines (macro).
But not a general macro system for the language.
```
func process() -> var int native {
;bitcode
}
```

Y - If we have `val x = 12` another assignment to x is forbidden.
But what about ref-assign? `val x = 12` and `x := y` where y is val.
This should be ok I think.
To check: behavior when it is used elsewhere in a thread.
Technically it is possible to ref-assign a val. but if we allow this for local variables and ban it for function inputs it will be source of confusion.
Let's say we are pass-by-value. so value of a variable is the address of the memory cell which contains actual data.
So it won't make sense for function to ref-assign it's input.
ref-assignment for val is only possible upon declaration.

N - can a function ref-assign a val input? No.
if no, for sake of consistency we should ban it for local variables too.

N - Maybe we can use the rightmost bit of references as an indicator.
if 0, it is a reference.
if 1, it is a value.
developer won't notice anything. but runtime will handle this.
but it will complicate processing. we need to check for that bit all the time.
But if we use a convention (val int is sent by value not reference), which is agreed upon both on caller and callee side, it would be simpler and faster. But if someone write another compiler, they will need to follow this convention.

N - Can we assign nothing to all types? What is it exactly and where is it used?
You cannot. Nothing is it's own type you cannot assign Nothing to an integer.

N - If a lambda has no input and output can I just write: `{ code }`?
This is basically like a code block (but cannot return).
Maybe explicit is better here. 
`loop(10, { printf("Hello world" })`

N - What are the problems with generics?

N - What are the problems with subtyping and polymorphism?

N - What can be removed to make language simpler?
`..` notation?
- `@` casting/type check
- `+` protocol enforcement
- `|` sum types
- `_` placeholder for lambda
- `:` tuple declaration, variable type declaration, hash literal
- `:=` custom type definition, reference assignment
- `=` type alias, copy value
- `..` range generator
- `<-` loop
- `->` function declaration
- `[]` generics, array and map literals
- `{}` code block, tuple definition and tuple literal
- `()` function call
- `.` access tuple fields

N - How can I define a custom type which needs 20 bytes of memory?
`type MyType := binary`
`func createMyType() -> MyType { return llocate(20) }`

Y - Can we implement loop with recursion and provide it as a function in core?
- problem: we won't be able to return from within loop.
- access to local variables will be provided.
- Something which is simple may take a little longer, be a little more verbose, but it will be more comprehensible
easiest type: repeat some code for 10 times
```
loop(10, () -> { printf("Hello world" })
loop([2..10], () -> { printf("Hello world" })
loop([2..10], (x:int) -> { printf("Hello world" })
loop(my_array, (s: string) -> ...)
loop(my_hash, (key: int) -> ...)
loop(x>0, () -> { ... }) ;if x is var, the loop body can change it
loop(my_iteratable, (iterator: int) -> ...)
loop(true () -> { ... })` infinite loop
;to return something:
;we can return explicitly to simulate break: return false means break outside the loop
;return true means continue to the next iteartion
loop([1..100], ()-> { if ( ... ) return false })
;to force return from inside loop: set a var outside
var result = 0
loop(... , () -> { if ( ... ) { result = 88; return false; })
```
- We need to behave hash and array just like any normal iterable. They should provide functions for iteration and support iterable protocol.
- This can remove a keyword `loop` and a notation `<-` and corresponding section.
- a new section in core will be added (besides array and map) to exaplain loop.
How do we treat break and continue and break/continue in multiple levels?

Y - Now that everything is a reference, returning a tuple just to return more than one thing might be inefficient.
let developer return multiple items: `return x,y` (2 refs) instead of `return {x,y}` (3 refs)
the only reason would be efficiency. 
this makes sense. what would be affected?
method dispatch
would it be possible to return a var and a val? yes. what should the caller do then?
`func process()-> var:int, val:int`
`? = process()`
it define result separately:
```
var x:int
val y:int
x,y = process
```
but this is a bit strange because we define val and then assign to it.
`var x, val y = process()` this is better. we declare and assign in a single statement.
`var x, val y := process()`
you can even write: `var x,y = 1,2`
`var x, val y = 1,2`

Y - introduce label types
How can we define a tag type? (one bit)
`type true := ?`
`type true`?
if we have a good definition for label types, it should be fine.
label type: types that only have one value which has same notation as the type.
`type ABC`
`var g: ABC = 1` wrong
`var g: ABC = ABC`
`if(g==ABC)` true
`if ( typeof(g) == typeof(ABC) )...`
`if ( g @ ABC )` true
you can define multiple label types at once: `type A,B,C`

Y - define sum types using variant template
`type bool := true|false`
`type boolx := true|false|error`
then can I write: `myBoolx = bool`?
Isn't it better to previously define labels explicitly?
This is like `Nothing` type. It is a label (type which has only one value which is the type itself).
But how is variant defined?
we can say it is handled like a tuple: compiler will assign.
`type variant := variant`. It will act just as the documentation. compiler will handle allocations.
`type variant := binary`. And compiler will handle the reset.
But if we have a bool, can this make sense?
`type bool := variant[true, false]`
`var myBool: bool = true`?
`if ( myBool == true)`?
`type IntOrFloat := variant[int, float]`?
`type IntOrFloat := variant[int, float]`
`type Maybe[T] := Variant[Nothing, T]`
`type OptionalInt := Variant[Nothing, int]`
- better and shorter name than `variant`.
pro: type system will be more consistent
con: we will add yet another built-in type
other possible names:
`sum`
`or`
`union`, `tagged`, `joint` -> **`union` is chosen.**
**`type bool := union[true, false]`**

Y - How can we define DayOfWeek type now?
`type SAT, SUN, ... `
`type DayOfWeek := union[SAT, SUN, ...]`
`var x: DayOfWeek = SAT`
`if ( @x == @SAT )...` we can use SAT both as a type and as a value, because SAT is a label type

Y - Review block notation for `@`
this can affect matching `@` operator: `if ( x @ var t:int)`
`if ( var t = my_map("key1"), t @ var x:int )`
map's get will return `maybe[t]` which will be `variant[nothing, t]`.
- How does this affect binary `@` operator?
`if ( g @ ABC )` true
`if ( var t = my_map("key1"), t @ var x:int )`
we can say `@` can be used either to cast or check something can be casted.
`a @ int` will return true if it can be casted to int.
`var g = @int(x)`
`if (x @ int ) y=@int(x)`
`if (int @ x ) y=@int(x)`
`if ( var t = my_map("key1"), t @ var x:int )`
how can we combine these two?
`if (@int(x) ) y=@int(x)`
`if (x @ int ) y=@int(x)`
combining them into one operator is a bit inconsistent.
For example: `if (x @ var y:int ) ;y has int of x`
In the above, there is no assignment or `:=` so how does y get it's value?
`if (var y:int = @int(x) ) ;y has int of x`
the only way to assign something to a variable is `=` or `:=`. We are adding a new notation.
OTOH maybe assignment is not possible. so we have assignment and also check for assignability.
`if (x @ int and var y:int = @int(x) ) ;y has int of x`
`if ( var t = my_map("key1"), t @ int and var x:int = @int(t) )`
this is longer but consistent with previous notations.
So we have `@` act as cast and check if it can be casted.
What happens to the block type?
- In this case we may need to make `if/else` keywords.
- or maybe just make `if` keyword and `else` a semi-keyword handled by the compiler.
`if(c) {A} else {B}`
`x=c; if (x) {A} if ( !x) {B}`
can we make two cases of `@` more similar to each other?
this is not very readable and intuitive: `if ( var t = my_map("key1"), t @ int and var x:int = @int(t) )`
this is more intuitive:                  `if ( var t = my_map("key1"), @t == @int and var x:int = @int(t) )`
least surprise?
`@` is supposed to be with types. 
also and is supposed to work with booleans: `x:int = @int(t)` is not boolean.
defining a new variable inside if condition part!
```
var intCast = 0
if ( var t = my_map("key1"), @int(t, intCast) )
```
`@int(x)` will cast x to int.
`@int(x, y)` will try to cast x to y and return true if it succeeded, false if it failed.
- add notation to define variable inside function call: `process(var result: int)` NO!
`if ( var t = my_map("key1"), t @ int and var x:int = @int(t) )`
`if ( var t = my_map("key1"), @t == @int and var x:int = @int(t) )`
`if ( var t = my_map("key1"), var x:int, @int(t, x) )`
what if I want to store result in a val?
now that everything is a reference, we have a `nil` reference. maybe we can use it here. but it is dangerous to let developer care about this. this is supposed to be transparent.
`if ( var t = my_map("key1"), var x:int, @int(t, x) )`
Go way:
`if ( var t, found = my_map("key1"), found )`
`var t, _ = my_map("key1")` ?
we can do the same for casting:
`var i, success = @int(x)`
**so: `@int(x)` will return result + success**
**`@T` will return type-id.**
this might cause problem when assigning to hash: `if ( var t, found = my_map("key1"), found )`
`if ( var t = my_map("key1"), var i, success = @int(t), success )`
Let's make hash get data, return single item: `optiona[keytype]`
but make `@` return two items in the result.
**`var value = my_map("key1") if ( var i, success = @int(value), success )`**
** `_` as variable name means compiler define a temp var as we don't care about this var **
** `_` as function input means value will be provided later **

N - can't we replace optional with multiple return values?
no! sum type is not only optional. what about intorFloat type?

Y - If we remove block mode from `@` then we may need a switch.
https://github.com/golang/go/wiki/Switch
`@` working for both type and values is a bit confusing.
```
if ( x == ) {
0 -> 
1 -> 
}
```
maybe we can implement this with a function. using a map literal?
q: how popular is switch?
not very popular.
```
;when result of x is not boolean
y = if ( x ) {
    1 -> "G",
    2 -> "H",
    3 -> "N",
    else -> "X"
}
y = if ( @x ) {
    @int -> "G",
    @string -> "H",
    @float -> "N",
    else -> "X"
}
```
what about type checks? for example check if maybe[int] is nothing or no?
`@` with one identifier, returns type-id of given variable of type.

Y - update naming with protocol naming convention

Y - if we support return multiple types, maybe we should change this notation:
`var x,y = func1()` where func1 returns a tuple of two items.

Y - can compiler simplify `union[int, floatOrString]` to `union[int, float, string]`?

Y - `@T` it T is a union. Does it return type id of `union[int,float]` or type id of `int` (if union has an int)?
With having templates, we should not care much about dynamic type of something.
We have two use cases where we need to know actual type: dynamic type (is this Shape a Circle)? and union.
In all other cases, the type is evident.
```
y = if ( @x ) {
    @int -> "G",
    @string -> "H",
    @float -> "N",
    else -> "X"
}
```
So it does not make sense to use `@r` for any other type, although it is allowed.
`@T` will return static type for everything except tuples (will return their dynamic type).
what about unions then? Let's say union has a static type (which is defined in the source code) and dynamic type (it's actual type).
Let's say `@T` returns the type of actual data inside the variable T. For tuple and union this can be different.

Y - How to assign and ref-assign in one statement?
`var x=, y:= process()`?
First ref-assign then do `=` in another statement.

Y - How can we model a function which doesn't return anything? 
Nothing?
`type NoReturnFunc[T] := func(T)`
`func process() -> { ... no return ...}`

N - So now, we should define tree like this?
`type tree := {data:int, next: ref[tree] }`
if we define a recursive data structure which refers to itself in non-ref type, what should be the value of that field?
`type tree := {data:int, next: tree}`
when I create a tree, storage needs to be allocated infinitely.

N - What will be the difference between these two:
```
var x: func(int)->int = myProcess
var x: ptr[func(int)->int] = &myProcess
```
because we have first-class functions, this is not very useful.

Y - Can we remove `:=`?
Sure we need to keep the concept of ref-assignment but `=` and `:=` make things a bit confusing.
Example: `var x,y = process()` if we want to assign x and ref-assign y it would be impossible or too complicated.
```
C only uses `=` for both assignments.
int intVar = 12
int* q = intPtr
int* q; *q = intVar
===============================
1. update q itself, 2. update *q
int intVar = 12
int q = intVar
int q = intPtr
```
In C, assuming everything is a pointer, ref-assign is done with `=`, val-assign is with `*x=*y`.
We want to reverse. `=` for value assignment (because it is easier and more intutive)
but for ref-assignment we need a separate notation. AND we prefer to still use `=`.
So we will need to prefix-suffix something.
`x=y`
`*x=*y`
`x:=y` means copy y.ptr to x.ptr
each variable can be considered to have two internal parts: ptr and val.
`var x:int` `x.ptr` is the pointer and `x.val` is the value
`x=9` means `x.val = 9`
`x:=y` means `x.ptr = y.ptr`
we won't be using ptr and val in the language because it will be confusing. Just for clarity here.
`x=y` -> `x.val = y.val`
`x:=y` -> `x.ptr = y.ptr`
now we say `T.val` is same as we write `T`.
`T.ptr` will be indicated with `&`?
`x:=y` -> `&x = &y`. `&T` will return T.ptr which means the address that T is pointing to.
`x` variable has a value (stored in RAM) and also address of that RAM cell.
if you want to assign vaue: `x=y` means copy value of y into value of x
`&x=&y` means copy address of y into address of x.
`$x = $y`
`$x` is an integer representing the address of the location which stores the value of x.
`x=9` means writing 9 into the memory cell at `$x`.
`$x` is similar to `addressOf(x)` but it can be either as lvalue or rvalue.
also it implies that we cannot write `$(x+1)` but with `:=` we could write: `x := y+1`
this will affect: function call, var/val definition and assignment, parameter pass and receive, generics?
Note that `$` is not part of a type. It is a built-in operator to get address of a memory cell which stores value of a variable.
If compiler makes optimizations, and make a `val:int` non-reference, still `$x` will point to the address of x itself.
function call: `func process(x:int, y:int)`
`process(x,y)` no change here unless
- This will give developer ability to "fetch" address of any variable as an integer number. But to make things safe we can do two things:
- it won't be int. it will be some type defined in core. But this is not good as we are mixing built-in operators with core types. Let's say `$x` will return something which is not int!
- developer cannot do anything with that except assigning it to another address. 
What happens if user writes: `var g:string=$t`?
`$t` must have a type. let's call it `ptr`. And we can either define `type ptr := int` or make it a completely new type (so it cannot be misused).
`var x:ptr = $y`
`$y = x`
in every other language, there are two types: regular and pointer. But here we want to make everything pointer.
defining a ptr type also makes things confusing.
proposal: define `ptr[T]` data type and make everything else value type.
then what happens if a fuction returns `var:int`?
we can say function should either return val or var of ptr type.
There is a relation between var and ref. for local vars, they are independant but for function return, var implies ref.
pro: having a ptr type is confusing a little but, but having `=` and `:=` is also confusing.
we have var and val, also ptr and nont-ptr
there are 4 combinations:
`var:int`- an integer which you can change, one memory cell allocated for the data
`val:int`- a fixed integer which you cannot change, one memory cell
`var:ptr` - a pointer to an integer, you can change both value and the pointer (2 memory cells) 
`val:ptr` - a pointer to an integer, you cannot change vale or the pointer (2 memory cells)
- if a function returns `var:int` the caller will receive a mutable copy of the variable. It will not be a pointer.
- if a function returns a var pointer, it can be used in the caller to change values which might be used elsewhere.
- the only case where we can have race/conflict is function returning a `var:ptr` which is also sent to a thread. It can be used to modify data.
```
var x:int = 12
var x: ^int= &x
val v:int = 19
val x: ^int = &v 
```
we can remove `:=` but: we need ptr buit-in type and `&` operator and `*` operator.
we can use `=` to assign between ptrs.
The only things that we can do with a ptr type variable: 
1. assignment: set it's value to another ptr of the same type: `ptr1 = ptr2`
2. referencing: set it's value to pointer to another variable of it's internal type: `ptr1 = &otherInt`
3. assignment: read it's ptr value for assignment to another ptr of the same type: `ptr1 = ptr2`
4. derefrencing: read it's indirect value (like `*x` in C): `intVar = *ptr1`
5. invoke ptr if it is pointing to a function: `ptr(1,2)`
con: we can have `ptr[ptr[int]]`. For gen yes we can have it.
q: what about pointer to function? `type pf := ptr[func(int)->int]` `var gg: pf = &myProcessFunction` `gg()`
q: multiple variable of ptr and non-ptr decl in same stmt. `var x,y = process()` - in process: `return 10, ptr2`
q: how to solve initial issue? solution: there is no longer ref-assignment. we only have `=`.
q: what is new semantics for `=`? Same as before. copy value. for ptr, it will be the pointer itself.
q: what about ptr arithm? how will array work now? ptr arith is not allowed. we will provide core functions.
q: ref instead of ptr. `ref1 = &myInt`, `myInt = *ref1`. I think `ref` is more intuitive for non-C developers.
q: how does it combine with templates? `var g: Stack[ptr[int]]`
q: how to we initialize pointer and non-pointers? for example for a tuple?
`var x: Point = {x=10, y=20}`
`var x: ^Point = &x`
`var x: ^Point = &{x=10, y=20}`
q: do we have null pointer now? what about un-initialized ref? No we shouldn't have
if we change name to `ref` it will mean it is referencing to something.

q: can `*ptr1` be lvalue? yes if the ptr is var.
q: if `ptr1` is a pointer to Point, how can I access tuple fields? can I still use dot notation? can we extend dot notation to act the same for ptr[T] as for T? (Like Go) yes. the ref itself is not a struct so `.` is not used for it. Of course if it is a ref to non-tuple, you cannot use `.`.
q: what if someone writes `opCall` for function pointer? shall we disallow this? it's better not to.
q: why not disallow call on ptr type. So user has to de-reference and then call. we should keep places where `()` is used on non-function to minimum.
q: can we have nothing for ref type? no. it will open the door for a lot of abuse. Like C# we can prevent in compilation, if a ref (or any other variable) is not assigned to.

Y - where is `opCall` used? can we change/remove it?
- array and slice
- map
- maybe type to handle errors and chain calls
- function pointer invoke
problem: it will be confusing as developer can easily define custom `()`.
Let's say developer cannot override `()` for above cases.
To make everything consistent, let's say `()` will invoke opCall for all types except function names and function types and function pointers?

Y - Shall we make ptr part of the notation?
Like: `var x: ref[int]`
`var x: $int`. Because ptr is really part of the type.
How do we represent pointer to a pointer? `var t: $$int`
```
var g : $int = &x
var t: $$int = &g
```
or: `^int`
`var g: ^int`
`var g: \int`
`var g: ~int`.
this is better: `func process(x: ^int, val y: ^int) -> ^Point[int]`
`func process(x: $int, val y: $int) -> $Point[int]`

Y - disallow prefix `++` and `--` and add these to operators.
and make it statement, not expression. so they cannot be used inside another expression:
`arr1(x++)`?

Y - We should ban recursive data types which use non-ref to refer to themselves. 

Y - Shall we maky syntax for tuple initialization more explicit?
`var x: Point = {x=10, y=20}`
`var x: Point = Point{x=10, y=20}`
can we use `@` here? to cast a literal?

Y - Shall we initialize vars automatically or give compiler warning if developer has not init them.
In go everything is zeroed but as a result pointers will be `nil` which we don't want to have.
proposal: instead of thinking instead of the developer, let him assign values and issue compiler error if using un-init value.

N - What should be default value for a union? Nothing! Let the developer decide.

Y - Make sure `@` is only used to cast and type-id. nothgin else. 
What about literals?

Y - You can have tuple literals without name:
`var x: Point = {1,10}`

N - Applications of casting:
cast between named type and underlying
cast between elements of union and union type
cast between subtype and super-type
cast int to float.
Do all of them need success flag?
Maybe we should have different notation for casting that can fail and other casts.
casting that can fail: union to it's elements
Every other cast is fine and cannot fail (if there a chance of fail, it will be caught by the compiler)

Y - Clarifications about `@` opertor and its uses.
Can we say in `@T` T must always be a type?
And for type-id use another symbol? Does it make things simpler?
There are some similar but different concepts here:
1. General casting of data (literal to typed tuple, int to float, to supertype, to underlying type) which I call them static casting because they can be verified by the compiler.
2. Union check and extract type: Check if a union has type T and get it's T value. This is dynamic type check and extract.
For 1, we can continue to use `@` notation as a function: `var x = @type(y)`
For 2: maybe we should use a function. adding a new notation can be a bit confusing.
we already have `@^&*`. candidates for notation: `$%`.
We can use same operator: as binary it will check if union X has type Y: `x $ y`.
- does union X has type Y? 
- cast value of union to type X.
maybe for 2 we can use `@`: `var x:int = @int(intOrFloat)`. but in this case there is chance of failure. what should we do?
either define `@` to return two outputs all the time which will be useless for named type, primitives, ...
or add a new notation: `%`? `var x,y = %int(intOrFloat)` will return result and success flag.
Also to check inner type of a union, still we cannot use same notation as others. Because type-id operator can either mean type of the union or type of it's internal data.
`::`?
proposal: to make things simpler and dont force people to learn 100 notations, re-use `@` with this definition that it works differently for union types.
`@T` returns type-id of data inside the union, dynamic type of tuple, and static type for everything else.
another solution: use dot operator for them. but this is not good as it will be confusing with tuples. User should know it is a tuple as soon as he sees dot.
`var result, success = extract[int](intOrFloat)`
If `@` returns two inputs, we always have to ignore success flag when doing cast to other types. And this is not a cast. This is reading a binary data and parsing as a specific type which must be a member of valid types of the union.
`var result, success = extract[int](intOrFloat)`
`var result, success = @int(intOrFloat)`
`var result, success = $int(intOrFloat)`
let's choose this: `var result, success = %int(intOrFloat)`
`if ( intOrFloat % int )` check if union has a specific type.
So we don't need to use `@` for check type-id of data inside union.
shall we simplify `@` as type-id? The only use case is to find actual type of a tuple variable. which is not very much needed. So let's replace it with a core function.
So **`x = @T(y)` will be used to static cast: underlying type, supertype and some primitives.**
Go has type assertion because it has `interface{}` but we don't have such a thing.
We can define type assertion for unions. So type assertion operator will check and return result + success.
**union type check**: using `%` operator (type assertion). `union_var % type` returns true if union_var has data of given type.
`var result, success = %int(intOrFloat)`.
how can we use this in `if` with multiple results? `%union_var` will return type-id of data inside union.
`type(x)` function returns actual type of the data inside x. this is different than static type for tuple and unions.
```
y = if ( type(x) ) {
    int -> "G",
    string -> "H",
    float -> "N",
    else -> "X"
}
if ( type(u) == int) ...
```
we need two things: type assertion (dynamic, for union) and type cast (static, for other cases).
type assertion: get me int inside x or error.
assertion: `var myInt, success = @int(intOrFloat)`
cast:      `var myInt = @int(myFloat)`
can't we use the same notation? for union, it will return two outputs. for other types one output (function overloading based on input type is accepted).
it is simpler. we can also do the same with binary operator `@`!
`x@T` returns true if x is of type T (Applicable only for union and tuple, for other types it is naive).
`@x` and `@T` will return type-id.

N - How to cast to a pointer? Is that even possible?
`var t = @^int(g)`
It can be valid if a union as pointers or when underlying type is pointer.
`type MyPtr := ^int`
`var x: ^int = @^int(myPtr)`
`var x: int = *@^int(&myPtr)`

Y - Can we simplify array and map assignment notations?
now to assign to array:
`*arr(0)=88`
opCall for array type will return `val:^T` or `var:^T`.
and for map:
`map1("1") = 4`
can we simplify it?
```
var x: map[int, string] = [1:"A", 2:"B"]
*x(3) = "C" ;x(3) will return ^string
```
the syntax for assigning to array or map does not seem intuitive.
solution 1: add reference type like C
solution 2: new notation for shortcut: `*ptr = val`. To replace `*` maybe.
maybe we can use `:=`? :-D
```
var x: ^int;
x = &y
x <= z ;copy z value to the address x is pointing to
```
Previously we could just write: `arr(0) = 10`
Let's say `=` does both. if rvalue is `&` it assigns to x else assigns to `*x`.
```
var x: ^int
x = &y  ;x will point to y
x = 10  ;*x will be set to 10
```
Because `&` is clearly different from other notations.
Similarly in Golans, `x->field` is replaced with `x.field` because it can be clearly inferred that left of dot is a pointer or a normal structure. So they did not add a new notation.
what if rvalue is a pointer?
```
var x: ^int
x = &y  ;x will point to y
x = 10  ;*x will be set to 10
var z: ^int
z=x   ;= will ref-assign if rvalue is &expression or a pointer of the same type
z=10  ;= will value-assign if rvalue is internal type.
```
in `x=y` if x is pointer, if y is it's internal value, it will assign value else it will assign ref.
But this is not readable. it should be explicit from the source.
Maybe we should change the notation of Opcall to be like this:
`func opCall[T](x:array[T], i: index, value:T)`
`arr(0, 10)`
solution: make `^` like reference type and we cannot have `^^`. `^` is a reference to another var so you cannot write:
`var x: ^int = 12` maybe compiler can help about this.
if they need ref to ref, they can define a tuple to contain a ref and define a ref to that tuple.
```
var z:int = 12
var r1: ^int := z ;ref
var r2: ^int := r1 ;ref
r1 = 19 ;set value
arr(0) = 100
arr(0) := 10 ;not working unless array contains int references
```
pro: we no longer need `*` and `&`
con `:=` still confusion!
pro: array and map value assignment is easier to read now.
maybe we can use `&` for ref-type like C++:
```
var z:int = 12
var r1: &int := z ;ref
var r2: &int := r1 ;ref
r1 = 19 ;set value
arr(0) = 100
```
so what has changed since when we had `=` for data copy and `:=` for ref-copy?
Now you can only `:=` for ref-types. Everything is not ref!
q: how can we stress a litearl is `&int` or `val:&int`?
by lvalue type or function output type. If cannot be inferred, define a temp variable with type.
`var x: &int = 11`
in C++ you cannot re-assign a reference, but here with using `:=` notation we can do it (of course if it is var).
`val x: &int = z` z must be val. 
But what is use of a reference to a val? for gen. and sometimes we have to return a reference.
e.g. array read.
if array is val, return the element itself.
if array is var, return a mutable reference.
we have reference to val for generality. Although it might not be very useful but just like `@` for integer.
```
val x: int = 12
val y: &int := x
;both x and y point to the same immutable thing
val x: LargeBuffer = {...} ;10MB data
val y: &LargeBuffer := x
```
if everything is value type, then ref to val may become useful. We would like to return a reference to a big buffer rather than the buffer itself. so reference to val is also useful.

Y - What this should do?
`var x: &int = ...`
`var y: &int = x`?
`var y: &int := x` 
Operator `X := Y` lvalue must be a reference type to type T and rvalue must be of type T.
`var y: &int = x` this is valid. rvalue and lvalue are of the same type. y will point to the same location as x.
`var y: &int := x` this is not valid. if lvalue if `&int` then rvalue must be int.
`X=Y` if X is reference type to int, and Y is int?
`X=Y` if X is reference type to int, and Y is `&int`?
===================
`refint = refint` - copy rvalue's target into lvalue's target
`int = int` - normal code, copy value
`int = refint` - copy rvalue's target into lvalue
`refint = int` - copy rvalue into target of lvalue
`refint := refint` - make lvalue and rvalue point to the same thing (we cannot have ref to ref)
`refint := int` - lvalue will point to rvalue
`=` makes a copy. if it is given a normal type, copies it's value. if it has a reference type, copies it's target value.
the copies data will be pasted on the location of lvalue. if it is a reference, will be copied to it's target.
`:=` only accepts ref as lvalue. will get a reference to rvalue (if it is already a ref, it will take itself) and assign it to lvalue. So lvalue will point to rvalue (or it's target).
When dealing with `=` think of reference as `*pointer` in C.
when dealing with `:=` think of it as `=` with C pointers and non-reference on rvalue as `&x` in C.

N - can a pointer to Shape, point to a Circle?

N - If we want to have pointer, how do we specify end of a linked list?
`type List[T] = {data: T, next: union[Nothing, List[T]]}`

Y - Can we specify `&` in a template?
`func process[T](x:int)->&T`
this is what happens when a type is split into two parts.
Maybe we should use language built-in features like template:
instead of `&int` use `ref[int]`. but how to prevent `ref[ref[int]]`?
`func process[T](x:int)->ref[T]`
`process[ref[int]](10)`???
solution1: make `&` non separable. so `&T` does not have a meaning if T is template arg.
But this is not feasible. Sometimes we have T, but want to return a reference to T.
`func opCall[T](x: array[T], index: int) -> &T`
how can we return a reference without temp var (like in shortcut function)?
references are not as flexible as pointers.
`func getRef(x:int) -> ???`
`func getPtr(x:int) -> &x`
But with pointers we have the problem of assigning to array and hash.
I think pointer is more general and orthoronal. With reference we have to add more and more exceptions. This is permitted that is not...
we need a notatin which is flexible (little or no exception) and can help us write array and maps indexers.
===
Let's have reference type based on generics: `var g: ref[int]`
by default it has a temp allocated data.
It can be set to reference to some data using `:=`: `g := t` in C we write: `g = &t`
We can change it's internal value using `=`: `g=5` in C we write: `*g = 5`
What if a ref type appears as rvalue?
rvalue of `=` means it's internal data: `var r: int = g`. but this does not make sense. `=` is supposed to work with direct type.
Let's say `=` assigns reference and `:=` assigns internal value.
`var i = 12`
`var p1: ref[int] := i`
`var p2: ref[int] = p1` p2 will point to i too
the `&` and `*` notations are more expressive.
for example if I want to `++` the internal value of a reference, with `:=` notation it is really difficult.
`var i = 12`
`var p1: ref[int] = &i`
`var p2: ref[int] = p1`
`(*p2)++`
`p3=p4`
`&T` will return address of variable T as a `ref[t]` which can be rvalue.
`*T` will return a variable of type t which can be lvalue or rvalue.
now, the problem: we need a better syntax to set array or hash members.
`*arr(0) = 12`
`*map("A") = 19`
`var p1: int = *arr(0)`
`var p2: int = *map("A")`
`var p3: ref[int] = arr(0)`
`var p4: ref[int] = map("A")`
solution 1: have two opCalls. one for rvalue and one for lvalue.
solution 2: `type ref[T] := {ptr: ptr[T], val: T}` and runtime handles access to val and ptr.
con for 2: syntax can become really annoying.
`func opCall[T](subject: array[T], index: int)`
`func opCall[T](subject: array[T], index: int, rvalue: T)` - should this be T or `ref[T]`? **source of ambiguity**
- Note: Maybe we should change `*` notation as it would be confusing with multiplication.
`var i = 12`
`var p1: ref[int] = &i` - `&` operator creates a ref tuple.
`var j = p1.value`
This is because of the fact that we want to have both reference and immutability as orthogonals.
C++ has both of them but with exceptions.
Go has only reference.
Scala has only immutability.
Rust has both but with a more complicated model.
Now we have to pick which one do we want. Each has it's own flexibilities and problems.
If the goals is Simplicity, we should compare them based on how simple/complex they are.
```
          |  value-type | ref-type |
------------------------------------
  mutable |  var:int    | var:int* |
------------------------------------
immutable |  val:int    | val:int* | 
```
- I think this can never be fully orth because:
1. for a function I/O, it does not make sense to return or accept `var:mutable`. If it is a small data, being var is useless and if it is a large buffer, being var is waste of memory and performance. Because `var` has some kind of `ref-type` in it's concept. We expect to have a reference to something, if we want to be able to change it (var).
2. For local variables, being `val:reference` does not make sense. Why waste space by adding redirection if we don't want to modify the data? 
So if we want to have all 4 cases orthogonal, we will need to deal with these inefficiencies. And the developer needs to always think about whether he should define a case as ref or as immutable or not.
Two general options to reduce this problem: 1. remove/reduce one or both of these factors, 2. let compiler decide
**compiler decide**: developer only specifies immutability of the data. Compiler will handle and decide whether somethings needs to be sent/received as reference or value. 
problem 1: We need to tell whether in an assignment, we want to dupliate rvalue into lvalue or make lvalue point to rvalue.
problem 2: `var x:BigBuffer = y` this is expensive! we should prevent it -> notation of `:=`
if we assume `=` will be handled by the compiler but it's semantic will be rvalue same as lvalue.
problem 3: `var x: BigBuffer = process()` if output of process is immutable, this must make a copy. if output of process is mutable, this can be a reference assignment to save space.
`var x: int = process2()` if output is val, this makes a duplicate. if it is var, it will ref-assign.
`var x: BigBuffer = process()` if output is val, it will duplicate. if it is var, it will ref-assign.
we need to formalize compiler rules to make sure they make sense and are consistent (when it will duplicate and when ref-assign, 
can we say `var` means reference and `val` means value or reference?
`val x = otherVal` ref-assign if it is big, copy if it is small
`var x = otherVar` ref-assign if it is big, copy if it is small
`val x = otherVar` make a copy
`var x = otherVal` make a copy
`process(var1)` send a reference. so inside the function, var means reference for arguments. but for local variables it may have other meanings.
`var1 = process()` inside process, it must define it's output as reference (compiler should do that). So var means reference behind the scene, unless data is not outbound (sent to another function, received from outside or returned to caller).
`process(val1)` send a copy if small, reference if big.
`val1 = process()` if func output is val: make a copy if small, get reference if big, else make a copy.
So we might have `var x:int` and `var y:int` inside a function. but runtime handled x as a value type while y is a reference type (pointer), because y is returned to the caller. developer does not need to worry about this. compiler/runtime will take care of this and make sure that the most efficient implementation is used.
what if I want to make sure a reference is sent to a function and not a copy? if it is val, the question does not make sense so it must be var. if it is var:int, function will receive a reference. 
Function will receive or send a reference when communicating with outside world using mutable types. Otherwise, it may be working on reference or on a duplicated value.
1. `func process(var x:int)->int { var y:int = x; return y }` does y contain a copy of x or a reference? 
2. `func process(var x: Buffer)->Buffer { var y: Buffer = x; return y}` what about this case?
So function should hold reference when communicating with outside world using refs. But if two communications collide: get var from outside, return var inside. It should make a copy.
So we can say in all communications `=`, send arg, return arg copies will be made except when the data is var (both source and destination).
- we must obey function signature when sending data. But when receiving result, we may other var/val and copy will be made if it does not match with function output.
If we can get this right (consistent and efficient), we can remove `:=` and reference type (`*&^`) and a lot of headache and the language will be much simpler.
The common cases:
1.  **send var:int to function**: reference
2.  **send var:Buf to function**: reference
3.  **send val:int to function**: data-copy
4.  **send val:Buf to function**: reference
5.  **recv var:int fr function**: reference
6.  **recv var:Buf fr function**: reference
7.  **recv val:int fr function**: data-copy
8.  **recv val:Buf fr function**: reference
9.  **define local var:int**: reference if it is going to escape, else data
10. **define local var:Buf**: reference
11. **define local val:int**: data
12. **define local val:Buf**: reference
13. **var:int=var:int**: data-copy
14. **var:Buf=var:Buf**: data-copy (`=` is supposed to make a copy of the data, unless ref-assignment can be done trnsprntly)
15. **val:int=val:int**: data-copy
16. **val:Buf=val:Buf**: reference
17. **return function var:int input**: return the received reference
18. **return function var:Buf input**: return the received reference
19. **return function val:int input**: return a copy of the received copy
20. **return function val:Buf input**: return the recived reference
21. **var:int = arr(0)**: reference
22. **var:Buf = arr(0)**: reference
23. **val:int = arr(0)**: copy
24. **val:Buf = arr(0)**: reference
25. **arr(0)=var:int** data-copy
26. **arr(0)=val:int** data-copy
27. **arr(0)=var:buf** data-copy
28. **arr(0)=val:buf** reference
29. **var:int=getPointer\[int\](binry, 0)**: reference
30. **var:Buf=getPointer\[Buf\](binry, 0)**: reference
31. **val:int=getPointer\[int\](binry, 0)**: data-copy
32. **val:Buf=getPointer\[Buf\](binry, 0)**: reference
`=` is supposed to make a copy of the data, unless ref-assignment can be done trnsprntly (in cases where rvalue is a temp like result of a function call which is mutable or big-immutable).
**Rule 1**: When communicating with a function, everything is sent as a reference except for small immutable data.
**Rule 2**: when defining local variables, everything is a reference except small immutable data or small mutable data which is not going to escape.
**Rule 3**: when doing assignment to another item, everything is data-copy except for large immutable data.
**Rule 4**: when a function returns one of it's inputs, it will return the same thing except for immutable small data.
**Rule 5**: array and map getter is treated like receiving data from a normal function call.
**Rule 6**: array and map setter is treated like function call + assignment using `=`
**Rule 7**: The special function `getPointer` which is used to point to binary buffer, is trated just like a normal function.
And the compiler should keep track of a variable to know if it is a ref or not.
So let's make these changes: Remove the concept of pointer or reference + all it's related notations.

Y - to solve fragile base class:
1. mark type cannot be inherited?
2. child class can only override base class methods that dont have body.
we can switch to a pure "contain and delegate" method to replace inheritance (then we can support multiple inheritance too).
but what about polymorphism?
In Go, polymorphism only applies to interfaces. So if Class A contains B which contains C, A cannot be used instead of B. but if it supports interface I, it can be used for that.
Like Go: When you embed Shape in Circle, you can access Shape inside the Circle by `.Shape` but you cannot use Circle in place of Shape.
But we have protocol which is similar to interface in Go. Maybe we can use it.
interface is supposed to have no code but we have put axioms inside protocol.
this will affect: method dispatch, polymorphism and subtyping, single or multiple inheritance, fwd methods, axioms, generics, dynamic and static type, union with shape and circle

```
protocol General[T] := {
    func draw[T]()
}
type Shape := {}
func draw(s: Shape)...

type Circle := {Shape, ...}
func draw(c: Circle)...

func process(c: Circle)... ;this can only receive a circle and not a shape
func process(c: Circle->Shape) ;manually fwd but compiler can also help
func process[T](x: T) +Prot1[T]... ;this means i expect a set of specific methods to be defined for type T. In practice this can be called for a Shape or Circle or any other type which conforms to this protocol.
Why we cannot have: `process(x: Prot1)`? Because functions and protocols are inherently multi-parameter. So it is possible to define a protocol based on multiple types.

...
process(myCircle) ;this will call process for Circle and not Shape. If for any reason no function for Circle, we will have compiler error.
```
1. There is no dynamic dispatch except for protocols. So f(Circle) cannot be dispatched to f(Shape) automatically.
But if we have a variable of type `prot1` calling `process(prot1)` may be redirected to any type that implementes that protocol.
2. protocols have no data (like interfaces) but can have default implementations (e.g. axioms).
3. So when a function has `Shape` input, it will always have a Shape. But for protocol type, it is not known at compile time.
4. If data is important for your function, define input with correct type, if behavior is important, define generic with that protocol.
5. To prevent fragile base class issue, we also should implement closed recursiob. Design patterns which rely on abstract methods like Template method, should use function pointer instead.
6. Protocol can have impl. They have no field, so they can only call themselves and possible other functions.

4. How does this affect virtual method overriding? When process(myCircle) is called and Circle does not have perform, then process(Shape) will be called -> not automatically but by using fwd methods.
If now, perform(Shape) calls another function like `final` which has candidates for both Shape and Circle, if we call the one for Shape, it is closed recursion. If we call the one for Circle, it is open recursion and can cause fragile base class problem.
How do we define fwd method?
`func process(Circle->Shape)`
Go has closed recursion. 
Go uses automatic promotion because it is not multiple dispatch. We have to use manual promotion except for special cases.
`=` can only assign same type so you cannot assign circle to shape.
whenever we use template, we should be able to specify protocol even in function output or local variable decl.
So we can not define `array[Shape]` and store Circle in it. 
The array should be define general with protocol which is implemented by both Shape and Circle.
There is no point in specifying both type and protocol because with a fixed type, protocol is irrelevant.
1. So everything will be a static pointer and nothing else without dynamic type. Except for protocols?
But protocols are supposed to be resolved at compile time.
So inside a function, I want to have an array to store different shapes.
`var arr: array[T] +Shaper = [getCircle(), getSquare()]`
`var arr: array[T+Shaper] = [getCircle(), getSquare()]`
What if function is not generic? 
```
func process() {
    var arr: array[T+Shaper] = {getCircle(), getSquare()}
    ;for each element in arr, do this and that
}
```
What if we let protocol be a type itself? So we will have data-types and behavior-types.
Each function can specify one of these and not both. 
But what about multi-parameter protocols?
This should be simple and straight forward.
And if we allow protocol as types then:
`func process(x:+Shaper, y:+OtherProt, z: dsdsad)` 
Then we will have the problem of multiple dispatch again! There can be multiple candidates for a function call.
**problem** We cannot have array `array[T+Shaper]` because we are treatng protocol like a type (what if I get first element of this array?) and also `T` may not be present in the function signature.
What about allowing for polymorphism from base type to child type?
`var s: Shape = myCircle`
Then **problem**: Meaning of `=` will be confusing (what if for any reason `=` is implemented with data-copy?). It is supposed to copy data so if I change properties of `s` it should not affect `myCircle`!
what about polymorphism in function call and not assignment?
`var arr: array[Shape]`
`arr(0) = myCircle` what should this do?
Seems the only solution is to define protocol as a type:
`type Stringer[T] := +{ func toString(T) }`
And we can use this type whenever a type is needed:
`var arr: array[+Stringer]` We can use any type of data which has appropriate methods.
Maybe then we can remove `+` and treat protocols just like normal type (but without data, only behavior).
we can explicitly indicate a type conforms to a protocol: `type FileHandle := +Disposable int`
`type Set[T: comprbl, prot2] := +comprbl[T] +prot2[T] array[T]`
we can specify multiple protocols for a variable or generic type
`func process(x: Stringer+Dieposable)` 
What about multi-argument protocols?
`func process[S,T,X]+Adder[S,T,X] (x: S, y:T)->X { return add(x,y) }`
`func process[T]+Stringer+Disposable(x: T)` 
`var arr: array[Stringer]` this array can store any data type as long as it conforms to this protocol
This of protocol as a generic interface which is a pointer to another type supporting provided functions.
We use normal types for variables and function arguments and interface type for generic arguments.
HOW can we have an array which contains circle and square?
I think we should not be treating interface like a normal type.
can I write this? `var x: Stringer = getCircle()`?
The whole point of polymorphism is to solve expression problem. What if we solve it in another way?
Define a union of valid types: `type ShapeTypes := union[Circle, Square]`
Then: `var x: array[ShapeTypes]`. Problem solved. You can store any shape inside this array.
BUT here comes the expression problem: What if someone adds a new Shape like Triangle.
Maybe we can re-define this union as: `type ShapeTypes2 := union[ShapeTypes, Triangle]`
But what about all those functions?
`func process(x: ShapeType)...`
Now I have added a Triangle, I can write fwd function: `func process(x: Triangle)...`
So if we accept the expression problem and try to solve it in another way:
0. open methods (what we already have) is used to solve exp problem.
1. We treat protocol different than type.
2. You cannot declare an array of a protocoo.
3. `=` will copy data, so `var s: Shape = myCircle` will loose data.
4. dispatch will be based on static type or union internal type.
5. we use open functions to handle expression problem.
5. polymorphism? almost none?
we have open functions (functions that can be extended with new pattern-matches). So we can add a new function for each type of shape. 
q: write example for exp prob for extension of type and functions and make sure we are handling cases.
q: clarify method dispatch again.
for polymorphism.
6. What about recursion? Open or closd? maybe closed!
```
type Circle :=
type Triangle :=
func area(Circle)->double...
func area(Square)->double...
func permi(Circle)->
...
```
Add-hoc poly -> function overloading
parametric poly -> template
subtyping -> embed and fwd
7. developer can do subtyping and simulate is-a relationship with embedding and writing fwd methods. As a result, types can embed as many other types as they want.
8. to have a polym array: `var x: array[union[...]]`
9. to get output of a polym function: `var result: union[Circle, Square] = createShape(config)`.
10. pure "contain and delegate" for inheritance and subtyping
11. If there is common behavior, use protocol. If there is common data, use composition.

Y - Move axiom and `=>` notation to ToDo of the document. For now, protocol can only have bodyless functions.
```
;Also we can initialize tuple members, we have embedding
;Note that if T is a sum type, each function here can be multiple implemented functions
protocol Eq[T] := {
    func equals(T,T)->bool
    func notEquals(T,T)->bool
    func default(x: T, y: T) -> equals(x,y) => not notEquals(x,y)
    func identity(x: T) -> equals(x,x)
    func reflectivity(x: T, y:T) -> equals(x,y) => equals(y,x)
    func transitivity(x,y,z: T) -> (equals(x,y) and equals(y,z)) => equals(x,z)
}
```

Y - can we use `@` to cast from literal tuple to typed?
or an untyped tuple to typed? No. If literal wants a type, specify it at the time of declaration.
What if we have an untyped variable? No. This is not needed really. but prohibitinh it is not natural.

N - can child type re-defined parent type fields?

N - do we have fragile base class problem?
```
func inc1(s:Shape) -> inc2(s)
func inc2(s:Shape) -> s.counter++

func inc2(c: Circle) -> inc1(c)
```
No. Parent can enforce dispatch using static type.

Y - In Go I can write `var x: Interface1 = method1()` to have dynamic type. How is that possible here?
`var result: union[Circle, Square] = createShape(config)`?
maybe a special union is the key.
How can I have minimum change but a dynamic union which covers any conforming type?
suppose we have 100s of shapes! How can I define a union then?
`var result: union[Circle, Square, Triangle, Rectangle, Oval, Polygon, ...] = createShape(config)`
What about this notation?
`type Shapes := union[+ShpProtocol]`
`var x: Shapes = createCircle()`
`if ( x @ Circle ) ...`
The type definition is a normal union but instead of writing all possible types, we ask compiler to fill in that place. There is nothing involved in the runtime. Just a syntax sugar to help us not write all the implementation types.

N - Suppose that I hve written a method for complex processing on Circle and Square.
Now I have a triangle. How can I re-use it?
Solution is to write method based on a protocol or Shape. And fwd it for circle, square and triangle.

Y - Something being optional is not a good thing:
```
protocol Disposable[T] := { func dispose(T) }
type FileHandle := +Disposable int
```
User can later write his own protocol and functions and make my type implement another protocol. so this definition would be incomplete!

Y - what is the difference between single and double quote string literals?
we can say: single quote -> char, double quote -> string,  backtick for multi-line, raw string.

Y - Note that when using type for alias to a function, you have to specify input names too.
`type comparer := func (int, int) -> bool;`
`var x: comparer = func(x: int, y:int) -> ...`
How can we define a function literal and call it?
`(x:int)->int { return x+1 }(10)`
A function type should not include parameter name because they are irrelevant.
A lambda variable can omit types because they can be inferred: `var x: comparer = (x,y) -> ...`
A function literal which does not have a type in the code, must include argument name and type. `(x:int)->int { return x+1 }(10)` or `var fp = (x:int)->int { return x+1}`

Y - Can we simplify union with virtual `.x` fields?
currently we use `@` to see what is inside a union: `if (intOrFloat @ int)...`
But now that there is no dynamic type, `@` can not be used for tuple's actual type because it is the static type.
`var myInt, success = @int(intOrFloat)`
`var value = my_map("key1") if ( var i, success = @int(value), success )`
`@` is used for 4 purposes:
1. get type inside union
2. check if union is of type `X`
3. cast A to B
4. item 1 + check for success
only 3 is general. 1 and 2 and 4 are only for tuple.
`var x: intOrFloat = 1`
`if ( @x == @int ) ...` -> `if ( x.type == typeof(int) )`
`if ( x @ int ) ...` -> `if ( x.(int) )`
above two are almost the same. except for block-if.
`if ( var i, success = x.(int), success )...`
block-if: 
```
y = if ( @x ) {
    @int -> "G",
    @string -> "H",
    @float -> "N",
    else -> "X"
}
```
```
y = if ( x ) {
    (int) -> "G",
    (string) -> "H",
    (float) -> "N",
    else -> "X"
}
```
if `x.(int)` is used in a boolean or single-var context, it evaluates to a bool indicating true if union has int.
Else it will return two output: result and success.

N - Can a union contain unnamed types?
`type A := union[int, {x:int, y:int}]`?
Then how can we fetch the second case? No!

Y - Make notation for protocol usage cleaner.
`protocol Eq[T] := +Ord[T] { func compare(T,T)->bool }`
`func isInArray[T](x:T, y:array[T]) +Eq[T] -> bool { loop(var n: T <- y) {if ( equals(x,n) ) return true} return false }`
`type Set[T] := +comprbl[T] +prot2[T] array[T]`
`type T1[T,U,V] := +prot1[T] +prot2[T] +prot3[T,U] +prot4[T,V] ...`
`T:protocol` is the shortcut for cases where there is only one generic type.
`protocol Eq[T:Ord] := { func compare(T,T)->bool }`
`protocol Eq[T: T+Ord] := { func compare(T,T)->bool }`
`func isInArray[T,V: T+Eq, (T,V)+prot2](x:T, y:array[T]) -> bool { ... }`
`type Set[T,V+T.comprbl+T.prot2+(T,V).prot3] := array[T,V]`
`type T1[T,U,V+T.prot1+T.prot2+(T,U).prot3+(T,V).prot4] := ...`
What if we declare protocol as real parameters? Will it be more readable? What about types?
we can say no need to define protocol for types. Instead define them on functions that work with that type.
So set is: `type Set[T] := array[T]`. and in related functions, we make sure
`func addToSet[T: Ord](s: Set[T], x: T)...`
But adding it like implicit arg will make things complicated. It is optional and we need to add some more rules regarding order of arguments.
`protocol Eq[T:Ord1, Ord2] := { func compare(T,T)->bool }`
`protocol Eq[T: Ord(T), Ord2(T)] := { func compare(T,T)->bool }`
`func isInArray[T,V: Eq(T), prot2(T,V)](x:T, y:array[T]) -> bool { ... }`
`type Set[T,V : comprbl(T), prot2(T), prot3(T,V)] := array[T,V]`
`type T1[T,U, V, : prot1(T), prot2(T), prot3(T,U), prot4(T,V)] := ...`
`func isInArray[T,V: Eq(T), prot2(T,V), T.Field1](x:T, y:array[T]) -> bool { ... }`

Y - Is this the best syntax for union with all types conforming to X?
`union[+ShpProtocol]`
What about a union with all types that have a specific field or property?
union of all types that embed Shape?
Can we define a more general form for unions? because now it is the main tool for polymorphism.
We can define a union with a pattern. This pattern will be evaluated at compile time to specify set of types inside the union definition.
`type u1 := union[int, float, string, char]`
`type u2 := int, float, string, char`? no.
`type u3 := union[ShpProtocol($, int), OtherProt(float, $)]`
`type u4 := union[ShpProtocol2($)]`
`type u5 := union[Protocol2]` or `union[Protocol2($)]`
`type u6 := union[$.ParentTuple]`
this is super confusing! `and, or` , multiple protocol, combining protocol and data constraints, multi-arg protocols, ....
`type u1 := union[T: ShpProtocol(T)]` all types that conform to this protocol
`type u2 := union[T: ShpProtocol]`
`type u3 := union[T: ShpProtocol(T, int), OtherProt(float, T)]`
`type u4 := union[T: T.ParentTuple1, T.ParentTuple2]` all types that embed these two parents
`type u5 := union[T: Prot1(T), T.Tuple1]` combine both.
We define a union like a protocol.
Why not use the same syntax for protocol? type must have this field?
Then the restrction will be unified for protocol, type, function and union.

Y - General structure for generic parameters constraint. Applicable when defining a protocol, type, function or union.
`[T1,T2,T3,... : Cons1, Cons2, Cons3, ...]`
`Consi = ProtocolCons | FieldCons`
`ProtocolCont = ProtocolName(T1, T2, T3, ...)`
`FieldCons = T1.Field1`
For protocol, constraint specifies the which types can implement this protocol (pre-requirements).
For function, it specifies which types can be used to call this function.
For types, it specifies which types can be used to instantiate this type.
For union, it specifies which types are possible options for this union.
Constraint: General selection syntax to filter specific types.
Simplest constraint: `T` which means all possible types. `union[T]` means every possible type?
Type filter is a better name.

N - Type filter for protocol can be mistaken with function call.
But I don't want to re-use `[]` because it will be confusing.

Y - Add a section for phantom types and explain it can be implemented using named types or unused generic vars.

Y - with the new notation for contain and delegate, what happens to automatically fwd methods by compiler?
Shall we do that? or let developer write them?
`func process(s: Shape)...`
`func process(c: Circle->Shape)`? automatic? No. must be manual.

Y - Note that when I call `process(myIntOrFloat)` with union, it implies that there must be functions for both int and union (or a func with union type).

Y - Change syntax for map literal from `:` to `=>`. because `:` is used in many other different places.
Can we use a less strange and more consistent notation?
`var y: map[string, int] = ["a" => 1, "b" => 2]`?

Y - Implement STM. Everything immutable except inside a function. remove `var` and `val`.
can this simplify the language?
This will affect: keywords, all definitions for protocol and func, 
pro: it will simplify notations and language. no need to specify var/val everywhere.
con: STM may not be a good choice. how to prevent race conditions? if caller changes a parameter sent to a thread?
How can I modify array element now?
`arr(0) = 10`? No it no longer will work.
`set(arr, 0, 10)` no.
Clojure has a function which makes a copy of array with modifications.
In we cannot use `opCall` for array and map the only remaining use case will be for `Maybe` to support transparent error handling. Maybe we can eliminate that too and get rid of `opCall` completely.
In Cljure all types are references.
3 major problems in concurr and parall:
1. shared mutable state r/w with multiple threads
2. having exclusive access to a resource (write a file by multiple threads)
3. deadlock
Clojure uses promise, delay and future to tackle the first two issues.
Maybe we can even have optional stm (like a generic STM type which supports this).
Clojure has atoms which are data with changes done atomically (synchronized under the hood).
To modify atom you `swap` it with output of a function (so it can retry behind the scene). `swap(x, process(1,2))`.
Clojure: For mutable state you have these options: atom (atomic ref in java), ref (use STM) and agent.
Clojure has support for transient data which are mutable but must be kept inside a thread.
How can we have mutable local variables? tuple, union, array, map, primitives, ...
`tuple.field = x`
`var = x`
`union1 = y`
`array = [1,2,3]`
`map = [1,2,3]`
`array`
This will affect: array and map impl, ...
solution 1: a special keyword or function like `set`. But how can we make sure data is not shared with another thread?
Maybe we should define the data in a specific way like: `mutable[T]`. Then work with it. When done, we can unbox it and return it.
`var x: Mutable[array[int]]`
Another solution: Everything immutable, provide good and efficient immutable data structures.
In which cases do we need mutation? Big array, big hashtable. what else?
compiler can optimize behind the scene and use normal mutable int if data is not escaped from the function.
We can define a transient generic with some core functions to mutate it. 
```
var x: transient[array[int]]
transient_set(x, 0, 100)
...
var y: array[int] = transient_unbox(x)
```
Let's make transient more transparent. It is set by default for all local arguments.
Those functions can be achieved using dot notation and `=`.
The only problem will be array and map. I think they should become native types instead of built types.
So we won't have binary data type.
`var x: array[int]`
syntax to get/set? we don't want to use `[]`. and we don't want to call a function because it will break rule of local only is mutable.
`x![0] = 2`?
`map1!["A"] = 10`
- so we will loose binary type, getptrOffset, and all related things.
- Function input is immutable. you cannot change or re-assign it. But you can change local variables:
```
var i:int = 12
i=13
var s: string = "AAA"
s = "BBB"
var p: Point
p.x = 100
p.x = 200
var arr: array[int]
arr(0) = 100
var mp: map[string, int]
mp("A") = 100
```
- Changes: remove `binary` and related methods, `array` and `map` are native types, new notation to set map and array. remove `val` keyword. function inputs are immutable. local variables are mutable. 
- closure has read-only access to parent block.
- What about loop? make it a keyword?
- What happens to `opCall`? later
- What about `=` semantics? for local it mutatets and copies value.
- For function arguments, we cannot have them as lvalue.
- lvalue can only be local variable. local=local or local=arg or local=literal.
- it should copy data.
- function input may or may not be pointers, compiler can optimize, if a function returns a very large buffer, compiler will return a reference to it.
- if a closure can see function's local variables, it can be source of race condition but let's have the developer worry about this. We provide tools to prevent that such as atoms.
- We have immutability for function args. So if developer starts a thread by calling a function, it will have no access to mutable data. but this may not be true.
```
var x = 12
startThread(() -> myFunc(x))
x++
```
Another way: everything which is sent to a thread function must be a copy or an instance of `atomic`.
General rule: Only local variables can come on the left side of `=`.
To solve the problem with closure and race: What if closure does not have any type of access to local variables of the function? only to it's inputs. Doesn't matter because there is a single thread (parent function) which can write and another which reads. There can be conflicts. Another solution: STM.
What if function does not have local variables? Only functions that have no local variable can start a thread -> Still the provider of function arguments has write access.
solution: atomic and lock and ....


N - Do we need to make `loop` a keyword? I don't think so.

Y - What needs to change to handle monadic errors.
`func opCall[T](m: Maybe[T], f: func(T)->Maybe[T]) -> { return if (@m == @Nothing) None else f(m) }`
`var input = 10`
`var finalResult: Maybe[int] = input(check1(5, _))(check2(_, "A"))(check3(1,2,_))`
so we can remove `opCall`?
`func chain(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] ...`
`var finalResult: Maybe[int] = chain( chain( chain(input, check1(5, _)) , check2(_, "A")) , check3(1,2,_))`
`var finalResult: Maybe[int] = input >> check1(5, _) >> check2(_, "A") >> check3(1,2,_)`
`func opChain(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] ...`
This means infix function call. Shall we allow this exception?
`func >>(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] ...`
`var finalResult: Maybe[int] = input >> check1(5, _) >> check2(_, "A") >> check3(1,2,_)`
Let's have a normal function like chain: 
`func opChain(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] ...`
Then define an alternate syntax to calling it when it is infix.
Like: `func opChain $>>$(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] { ... }`
Function must have only two inputs.
`func opChain(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] { ... }`
define function alias
`func >> := opChain`
`func opChain(m: Maybe[T], f: func(T)->Maybe[T]) -> Maybe[T] { ... }=|>>|`
Let's just have this chain as a special case. If a type wants to define special behavior for chaining just write `opChain` function. And `>>` will be used for chaining.
`A >> f` means `f(A)` by default.
purpose: make code more readable: `f(x)` becomes `x >> f`
`f(f(f(x)))` becomes `x >> f >> f >> f`
`f(g(h(x)))` becomes `x >> h >> g >> f`
`f(g(x))` becomes `x >> g >> f`
`input >> check1(5, _) >> check2 >> check3`
Maybe we can use `|` which is similar to bash.
`var finalResult: Maybe[int] = input | check1(5, _) | check2(_, "A") | check3(1,2,_)`
We use `or` for conditions so this is not used elsewhere.
Another solution: return a tuple with a single function pointer.
`var finalResult = chain(input)(check1(5, _))(check2(_, "A"))(check3(1,2,_))`
`var finalResult = input | check1(5, _) | check2(_, "A") | check3(1,2,_)`

N - for union definition do not use `:` but use `|` which `T|F` implies all T if F.
No. this concept applies to type and function and protocol too. let's just use `:`

Y - Unified immutability everywhere. Makes things simpler to read and write. And the optimizations will be done by compiler.
Then we can get rid of `var` keyword as everything is immutable. re-assignment can be disallowed.
Then how can we define type? Do we need to?
Everything immutable except special types which cannot be sent to other functions.
maybe a binary data type?
```
var x:binary = swap(largeBuffer)
;now largebuffer is empty and does not point to anything
x[100]=200
```
- hashtable uses a linked list or array + linked-list internalls. 
- edit = edit a node in linked-list
- add = add to linked-list
for linked-list we can implement it using a number of list-chunks. each chunk is a small linked-list (~10 nodes) and chunks are connected to each other. So an edit in one of them needs only updating the other chunk. 
- implement array as chunks too. a root table includes list of chunks.
- let's implement everything as immutable. if compiler is sure some data is not shared with other threads, it can optimize changes.
- if the function does not start a new thread, it's local variables can be mutated.
- maybe we should change array and map write notation. for reading it is fine to use `()` but for writing we should use functions.
```
func readFile() -> buffer
{
    var b: buffer = allocate(1024)
    b = fread("a.txt")
    set(b, 10, "A")
    set(b, 20, "B")
    ...
    return b
}
```
in this case, a call to `set` will modify in-place and return same reference.
this is done with escape analysis and check if function is starting a new thread.
so summary:
1. everything is immutable even local variables.
2. we provide functions in core to create new instance on mutations of array and ...
3. compiler will check and if function is not creating a new thread and a variable is not escaped, calls to core functions to create a new instance can be optimized to in-place mutations.
For example `arr = set(arr, 0, 10)` will be compiled into a normal mov statement.
or `tuple1 = {tuple1.a, tuple1.b, tuple1.c+1}` will be compiled into add statement.
Haskell compiler also does that:
https://stackoverflow.com/questions/27754801/when-does-ghc-internally-mutate-immutable-values
4. change `var` keyword to something else.
5. we need a syntax to change a tuple. we cannot use `tup.x = 10`
for int, float, char, string as a whole and union we simply use `=`.
we can use `=` for tuple too but it would be difficult to rewrite all fields
`myPt = {myPt.x+1, myPt.y}`
`myPt = myPt{x=myPt.x+1}`

another solution is to provide synchronized functions. These functions can modify any data without worrying about immutability because they cannot be called from two threads. but this does not solve the problem as the problem is not with the function but with the data strcutre. in OOP they compose data structure inside a class with appropriate methods but here we don't have that feature.
Maybe we can define a set of functions who have exclusive access to the data inside a tuple. 
But the whole point of immutability is making sure data structures are all thread-safe.
solution: channels like Go, atomic types, mutex and lock, future, promise.
6. There are tools in the core for handling concurrency: channels, mutex, atomics, ... . but they are only for concurrency purposes and not for general data structures. 
```
var x: mutex
acquire(x)
x=x+1
release(x)
```
we can define `atomic` as a native type and only core functions would be able to work with it. normal code does not have access to the integer inside `atomic[int]`.
But it seems that when everything is immutable we no longer need mutex, lock and semaphore. except for things like db connection. I think we can use channels for that.
`var db = channel_receive()`
in the pool:
`pool, dbc = getConnection(pool) -- channel_send(dbc)`
advantage of message passing: we can easily migrate the other thread to another machine.
actor, mutex, CAS, lock, semaphore.
The most primitive one is CAS which also has hardware support.
`var result: bool = cas myInt, oldInt, newInt`
this will check if myInt=oldInt, it will copy newInt into myInt and return true. else false.
`var done = myInt = (oldInt => newInt)`
if we aloow for re-assignment, then it will be like mutable shared state!
In Sclala, you cannot re-assign to a `val`.
We can define a special type which is like int but you can only work with it using specific functions.
```
var x: cas = casSet(100)
var done = compareSwap(x, 100, 200)
;now x is 200
;so you must know that x is a mutable variable. BUT it can only be mutated using `compareSwap` function.
;you cannot write x=101
```
this can be used to implement mutex or semaphore or lock.
Semaphore can be simulated with channels: http://www.golangpatterns.info/concurrency/semaphores
Mutex also: https://stackoverflow.com/questions/3952061/how-can-we-use-channels-in-google-go-in-place-of-mutex
Go channels use lock, mutex, semaphore and as a result cmpxchg.
So it seems that channels can be the unified mechanism to handle concurrency in an efficient manner. 
Compiler will definitely try to optimize code by converting immutable data to mutable if it is safe.
Can we re-assign? in Haskell and Clojure are declarative so they don't have `=`.
In scala and rust you cannot re-assign to a mutable.
The only problem is closures! because they have access to outside variables. Even if we disallow re-assignment, it will not be simple and clear.
But why? If I write `print x` inside a closure and x is defined outside, I am quite sure that x value won't change (if we disallow re-assignment). Clojure allows re-assignment for atomics.
cpu has also atomic fetch-and-add in addition to cmpxchg.

1. everything is immutable even local variables. And you cannot re-assign.
2. compiler will check to see if a variable can be mutable in instruction level (if it's not escaped).
For example `arr = set(arr, 0, 10)` will be compiled into a normal mov statement.
or `tuple1 = {tuple1.a, tuple1.b, tuple1.c+1}` will be compiled into add statement.
3. change `var` keyword to something else. maybe a notation.
4. we need a syntax to change a tuple. we cannot use `myPt2 = myPt{x=myPt.x+1}`
5. The only mechanism to handle concurrency and corrdination is channels which under the hood use fetch-and-add, cmpxchg, semaphore, mutex and ... .
variable types: int, string, char, union, tuple, array, map.
```
x = 12
y = x+1
str1 = "DSADAS"
str2 = [str1, "DS"]
un1:union[int, float] = 1
pt1 = {100,200}
pt2 = pt1{x=101}
arr1 = [1,2,3]
set(arr1, 0, 22)
map1 = [1=>"A", 2=> "B"]
set(map1, 1, "G")
```
maybe we should bring type before the variable name!!!!?!?!?!??!?!?!?!?????
then what about type inference?
Golang does it like this:
```
var i int
var c = true
int k := 3
```
maybe we should not use `=` anymore!
`<-`. But `=` is more intuitive for imperative code.
`x = 3`
we should disallow variable declaration without assignment.
so variable declaration and assignment are the same thing. we call declsign.
now we have two types of declsign: with explicit type or without.
do we need to specify type?
int - no
float - no
string - no
array and map - no
bool - no 
union - ?
the only case is union because it can have multiple possible types which are not specified at declsign.
`f = 1` maybe f is a int, float union. but does it matter? we are assigning value to f and we cannot change it later.
so basically it does not make sense to "define" a variable of type union. except for function input!
for label type unions like bool, it can be inferred.
it does not make sense to define variable of type union while disallow re-assignment.
what about function input? 
1.`func process(x:int, y: float)->union[int, float]`?
2.`func process(x: union[int, float])->int`
what if I want to use output of the first process function? I have to define it's type as union.
why? I can omit type and it will be whatever output of the function is.
So basically for local variable we don't need type decl but for function input and output we do.
`func process(x:int, y:string, z: union[string, float])->union[a,b,c,d]`
so `=` is used for declaration and assignment and type inference.
```
var i int -> invalid
var c = true -> var does not make sense.
int k := 3 -> no need for type
```
```
x = 10
y = 1.12
z = "Hello"
a = [1,2,3]
m = [1=>2, 3=>4]
bb = true
cf = 1.23
gh = process(1, cf, 12)
```
It is better to be more explicit. Although it is not required but better to make finding new variables easier.
`let`, `:=`, `<-`
what about function pointer type?
`type pred := func(int)->bool`
`g := (x:int)->bool { x>0 }`

Let's continue with `:=` notation which is consistent with named types concept.
I think I will need to review the whole spec as this change (no type decl, everything imm, ...) has a huge effect. lambda, protocol, type filter, union, operators, chaining, array and map, ...
`x,y,z := process()`
`type u5 := union[T: Prot1 + T.Tuple1]` 
`protocol Eq[T:Ord1, Ord2] := { func compare(T,T)->bool }`
`type Set[T,V : comprbl(T), prot2(T), prot3(T,V)] := array[T,V]`
`func isInArray[T,V: Eq(T), prot2(T,V), T.Field1](x:T, y:array[T]) -> bool { ... }`
how do we initialize a variable? 1. by using literals, 2. another variable 3. function call
about union: the litearl cannot have multiple types. `f:=5` f will be int, we cannot have it `union[int, float]`
for another variable: it will get type of the other variable
for function: it will get output type of the function
so we can have union typed variables but we don't need to specify that.
problem is when we assign tuple with literal, there not much that IDE can do to help. But we specify type in the tuple literal.
`third_point := Point{200, 400}`
`aaa := third_point{y=102}`
`opChain` ok.
what if we want to share a big data structure? because everything is immutable, we can simply send a reference to the data. compiler and runtime will handle this case.
1. everything is immutable even local variables. And you cannot re-assign.
2. compiler will check to see if a variable can be mutable in instruction level (if it's not escaped).
For example `arr = set(arr, 0, 10)` will be compiled into a normal mov statement.
3. no `var` keyword. `:=` is used to declare and initialize a value and don't need to specify type for local variables. but we need to specify type in type decl and functions and protocols.
4. syntax to change a tuple: `myPt2 = myPt{x=myPt.x+1}`
5. The only mechanism to handle concurrency and corrdination is channels which under the hood use fetch-and-add, cmpxchg, semaphore, mutex and ... .
q: stack push -> will return a new stack.
syntax to define tuple literal?
`pt := Point{x=100, y=200}`
`pt := Point{100, 200}`
using `=` is not good now that we use `:=` for declsign. but here x is field name.
`pt := Point{x:100, y:200}`
`:` is used for type filter, tuple type declaration, and previously in var type decl `var x:int`
6. tuple litearl uses `:` like `pt := Point{x:10, y:20}`
what about slices?
1. `arr := [0..9]`
2. `slice1 := arr(1, 2)`
3. `slice2 := arr(0, -1)`
we should allow for more expressive syntax to init an array.
Haskell: `sq = array (1,100) [(i, i*i) | i <- [1..100]]`
`x:array[int]`
`x:=[1,2,3]`
`x:=loop((x:int)->x*2, [1..10])` here loop body returns a single int -> 1d array
`x := (x:int)->x*2 | loop(_, [1..10])`
`g:=x(0)`
`y:=x[0=>10]`
2d array:
`x2: array[array[int]]`
`x2 := [[1,2], [1,3], [2,2]]`
`x2:=loop((x:int)->[1, x+1, x*2], [1..10])` here loop body returns a list -> 2d array
`g:=x2(0)(0)`
`y2 :=x2[0,0=>102]`
what about loop with condition?
`loop(x>0, () -> { ... })`
`loop((x:int)-> {x>0} , () -> int { code to return new value for loop condition })`
`var result := (x:int)-> {x>0} | loop( _ , currentVar, () -> int { code to return new value for loop condition })`
`func loop[T,X](pred: func(T)->bool, initial: T, body: func(T)->X)->array[X]`
what should we call them now? what we used to call variables. value? 

Y - remove `--` and `++` they are mutating.

Y - Are these still valid?
- Applications of casting:
yes. cast between named type and underlying. `type MyInt := int`
no. cast between elements of union and union type
no. cast between subtype and super-type
no. use core functions. cast int to float
no. there is no untyped tuple. cast from an untyped tuple variable to a specific type.
So we only need to cast from named to underlying. 
`type MyInt := int`
`x := getMyInt()`
`y := @int(x)`
can we simplify this and get rid of `@`?
like the way we handle tuples.
`y := int{x}` if type before `{}` is not tuple, it is a cast from named to underlying type.
Is named type still relevant/needed? yes it should be.
But we still need `@` as indicator of type-id of types.

N - can we use type alias in union?
`type MyInt = int`
`type x := union[MyInt, int]` -- error definitely
`type x := union[MyInt, float]`
`if ( x.(int) )` or `if ( x.(MyInt) )` are the same.

Y - `==` compares field by field, datawise. If you want custom comparison, write your own function. So there is no `opCompare`. 

Y - Remove "You can have multiple assignments at once: `x,y=1,2`"
What is use of this? for function call result, it will return tuple and we will use `{x,y}` syntax.

Y - make calling dispose function explicit. let types declare they implement a protocol.
add `=` to alias functions. If a type marks to implement `Disposable` any value of it's type must call it's dispose method or any of it's aliases. `=` is used for type and function alias.
`dispose`. Why not call it explicitly?
when writing defer you must explicitly state the code. The only advantage is that when there are multiple returns you can write one defer.
problem is `dispose` is called implicitly which is against our philosophy.
Shall we return `defer` keyword?
`s := createSocket(....)`
`s := expression & release_expression` how to initialize this expression and how to finalise it when exiting the function.
`f := openFile("A.txt") & closeFile`
`g := openSocket(...) & closeSocket(1, _)`
`identifier := exp & closure` closure will be executed upon exiting the function.
How can we mark types as "resource" so user must use `&` notation to release them?
we need to indicate if a type implements a protocol. 
`type FileHandle := {handle: int} +prot2`
So if a type is marked with protocol `Disposable` it must have a `dispose` method and whenever we have a value of it's type we must use `&` after declsign.
If function name is known, maybe we don't need `&` notation. but it is a shortcut to write it only once.
`f := openFile(...) & closeFile`
developer even does not need to write function name. it is specified in the protocol.
we just need a mechanism to make calling it explicit but don't mention it's name. Why don't mention? 
Let's make calling it explicit. So it will be more readable, and also user can use it for other purposes mayne.
can we make `Disposable` protocol empty? So if a value is defined of type X which is marked with Disposable, developer must add `& function_call` to dispose. but it won't be clean.
`f := openFile(...) & closeFile` vs `f := openFile(...) & dispose` 
We want to have different names. 
We need to specify "HOW" a protocol is implemented for a type.
so when defining a type we can specify that:
`type FileHandle := {handle: int} +prot2{dipose => closeFile}`
Means FileHandle implements prot2 protocol but with this name: `closeFile`.
`func closeFile(x:int)->bool { ... } = dispose` dispose is another name for this function. so we are implementing Disposable protocol for this type. so we have `dispose(x)` and `closeFile(x)` which are the same thing.
`func closeFile(x:int)->bool { ... } = dispose`
`func dispose(x:int) = closeFile` dispose is another name for closeFile. So our type has implemented disposable protocol but with it's own function name.
`func A(t1,t2,...) = B` is used to define alias for functions.
maybe we want to run dispose on another line?
for exampe: `acquire_lock(x) & release_lock(x)` this is not pure! acqlock should return something as a handle the resource.
`x := acquire_lock() & release_lock`
`func dispose(lock) = release_lock`

N - can we make chain operator paren-free? no need to use paren when it is combined with other expressions.
`x := gg | process(_,1))`
`x := {gg, xx} | process(_,_,1)`
`x := 1 | process(_,2) + 5`????
`x := 1.process(_,2) + 5`
`x := 1.process(_,2).f2(_,5)`
but dot can be confused with tuple accessor.

Y - can we say that all functions must return something even if Nothing. so all functions can be modelled as `func(I)->O`.

Y - Do we still need to return multiple outputs?
`return x,y`
`return {x,y}`
`x,y := process()`
`{x,y} := process()`
if all functions return a single thing, modelling generics which work functions can be easier.
`{t, found} := my_map("key1")`
`{t, _} := my_map("key1")`
we can create temporary tuple and assign it's components to actual values.


Y - 
maybe we can use `:=` for map and array too.
`arr := [1,2,3]`
`arr2 := arr[1]` append
`arr3 := arr[0 => 1]`?
`arr3 := arr[0 => 1, 1=> 9, 3 => 10]`?
`map2 := map1[2 => "A"] ;add or update`
`map2 := map1[2 => "A", 3 => "B"] ;add or update`
how to set 2d array?
`arr3 := arr[0,4 => 1]`
`twod = array[array[int]] = array(10,10)`
we can define matrix for 2d array.
`x: matrix[int]`
then for higher order combine them.
`x: matrix[array[int]]` - 3d array, .... not unified.

N - if we use `:=` for var assignment, can we use `=` for comparison?

Y - declare `nothing` a primitive type. Because we refer to it in the definition of `|`

Y - Say that we can use `(x)array` to read from map or array.
and array literal can be define like a hash literal with sequential keys as index.

Y - Make block-if syntax similar to hash and re-define chain operator without relying on `opChain`.
```
y = (x)[
    1 => "G",
    2 => "H",
    3 => "N",
]
```
if map does not have that key, y will be `Nothing`.
`if ( y.(Nothing) ) y=default`
1. we should be able to reverse order in `map(key)` to `(key)map`
2. so basically, if is a syntax sugar over a map literal.

```
y = (x)[
    1 => "G",
    2 => "H",
    3 => "N",
] | "default"
```
we write `opChain` for `maybe[T]` and `T` to return second arg if first is Nothing.
q: in if order is important but in a hash it is not.
q: what about normal if?
the above syntax is for block-if for values and types.
```
y = ( x )
[
    (int) => "G",
    (string) => "H",
] | "X"
```
- we still have normal conditioned if.
- we call declare `(T)` an operator which returns type-id of a type. so `x == (T)` will check if type of x is T. but how can we cast x? below is no longer valid if we cannot reutrn multiple items:
`var int_value, success = int_or_float.(int)`
Let's say `type(x)` will return type-id of x which can be compared to `int`. but it's not good to treat `int` like a value.
`{_, has_int} := int_or_float(int)`
`int_or_zero := int_or_float(int)`
`{int_or_zero,isInt} := int_or_float(int)`
reading from maps:
`{intVal, found} := my_map("key1")` `if(found) ...`
```
y = ( x )
[
    (int) => "G",
    (string) => "H",
] | "X"
```
Y **Summary**: chain operator has two functions: `A|B` is B is a closure, it will evaluate to `B(A)`.
If B is a value, if A is Nothing, it will evaluate to B else to A.
q: How can we check for type of data inside a union? we say:

**summary**: type function returns type-id of a value and `@T` returns type-id of a type.
```
y = ( type(x) )
[
    @int => "G" + int{x},
    @string => "H",
] | "X"
```
or:
```
y = ( type(x) )
[
    @int => "G" + int{x},
    @string => "H",
] | "X"
```
`value := my_map("key1")` normally map query will return a maybe[T]
`value := my_map("key1") | 0` --if does not exist, set value to 0

Y - chain operator has two functions: `A|B` is B is a closure, it will evaluate to `B(A)`.
If B is a value, if A is Nothing, it will evaluate to B else to A.
Disallow writing `opChain` for developer. Just define it's behavior based on expectation.
for example 
`maybe[T] | default(5,)` will return 5 if first is nothing.
`A | f(T)` will return `f(A)` if T is of type of A
`maybe[T] | f(T)` will return first if it cannot be sent to f, `f(first)`.
`func default(y:T, x:maybe[T]) -> T {return y if  x.(Nothing) else x.(T)}`
Still I think it is not clear and consistent.
OTOH writing `opChain` and calling it with `|` is not very readaable. what if I write `bind` function and call it like this:
`func bind[T](x:T, f:func(T)->T)...`
`x | bind(,f)`
`x | default("A",)`
`(x)[1=>2, 3=>4] | default(0,)`

N - No need to use `_` in pipe if pipe is sent to last argument.
`x | f(a,_)` can be written: `x | f(a,)`
use empty comma to indicate place of pipe.
`f(x,_,y)` -> `f(x,,y)`
maybe we can get rid of `_` totally.
I think `_` is needed when we don't need part of output of a function.
why not re-use it here?

N - Now that everything is named, aren't we moving toward lazy evaluation?
`x := f(1)`
`y := g(x)`
first line is just a call to a pure function which has no side-effct. so compiler can run it when evaluating `y` or even later.
BUT functions can have side-effects here. They can write to file or network or ... .

N - Shall we omit return type from function declaration?
For function type, the return type should be mentioned but for declr do we need it?

N - How can runtime memoize a function? Maybe function has a side-effect.
maybe developer should handle it by adding a struct and a general function which calls target function and has a cache.?

Y - Now that we can re-assign, shall we use `=` instead of `:=`?
And `==` for comparison as expected.
`=` makes a copy as expected.

N - We are not looking to have pure functions. Our functions can have (and will have) side effects like IO and network.
We want to have functions that work on immutable data. 

Y - Allow variable re-assignment and prevent data racing in closure capture by compiler detecting re-assigned captured vars.
Can't we re-assign variables? and do something else for threads and race and ...?
For example a thread, has read-only access to outside vars but communicates through a channel.
what is the problem with re-assignment?
What if we disallow access to outside values? 
we use closure in block-if and loop. they should have access.
```
x = 1
start_thread({loop(true, process(x)}))
```
if later we change value of `x` there might be a race condition. 
which one is more important? avoiding potential race condition or letting user re-assign values?
This does not happen only for closures?
```
x = 1
process_in_thread(x)
x=x+1
```
if we say, calling a function, sends a copy of the data or a reference which `x=x+1` will renew, then it will be fine.
so `x=x+1` we must make sure that x is assigned to a new location on memory. as a result the thread's x variable won't be changed.
```
func process_in_thread(x: Point) { ... }; I am sure that x won't ever be changed. even if caller re-assigns it, it will be a new thing.
```
so the only problem is race condition for closure. Maybe we can accept that and let developer handle those cases by using channels. 
Java only allows access to final variables in a closure. Final variables are not re-assignable.
what if closure gets a copy or immutable copy of the variable?
```
z = 1
closure1 := (x:int) -> x+z
```
C++ syntax:
```
z = 1
;z is captured by value
closure1 := [z](x:int) -> x+z
```
can't we just send z like a normal argument without changing signature of the function?
`closure1 := ((x:int, z:int) -> x+z)(_, z)` but this is too long
`closure1 := (x:int, z:int) -> x+z`
or we can say closure can only access primitives. but its not good.
another solution: closure can access but it cannot be re-assigned: compiler can detect this.
and we allow re-assigning for all other variables (of course it will bind a new identity to a value).
Java compiler can detect that: "A variable or parameter whose value is never changed after it is initialized is effectively final.".
If we re-assign, it should be to the same type.
`x := 1`
`x := 5`
it is consistent with unions?
What if I want x to have `union[int, float]` type?
`x := union[int,float]{1}` for explicit typing.
then I can write `x := 1.5`
`x := 1`

N - Can we extende/insert into array using new notation?
`arr = arr[100=>102]` updates.
no insert unless using a function.

Y - Can't we just remove function alias? it is redundant and only added to support implement protocol with functions with different name.
```
type FileHandle := {handle: int} +Disposable
func closeFile(x:FileHandle)->bool { ... }
func dispose(x: FileHandle) -> closeFile(x)
f = openFile(...) & closeFile
```
compiler will detect `closeFile` is same as dispose for this type.

N - Shall array access return maybe to handle index-out-of-bounds?
it may cause confusion:
`g=[f(x)->5->5]`
key of a map (and array index) cannot be function type or lambda expression.
`g=g[f(x)->5]`
`g=g["A"->(x: int, y:int) -> int { return x+y }]`
It can be confusing!

N - What happens if I modify a slice?
It will modify underlying array. No. There is no mutation.
```
var arr: array[int] = [0..9]
var slice1: array[int] = arr(1, 2)
```
Y - if cannot declare variable.
What changes in var assignments in if and loop?
`if (var x=1, x>y)...`
Maybe it's not very useful.
`if (x := 1, x>y)...`
But we are going to convert if to a map lookup. So how will var be translated?

N - Can we simplify type filter? instead of `prot1+prot2` combine them in a new protocol and just include that one?
`func isInArray[T,V: Eq(T) + prot2(T,V) + T.Field1](x:T, y:array[T]) -> bool { ... }`
becomes:
`protocol pp[T,V] := Eq[T] + prot2[T,V] + T.Field1`
`func isInArray[T,V: pp](x:T, y:array[T]) -> bool { ... }`
`type u5 := union[T: Prot1 + T.Tuple1]`
We do not specify multiple types for a variable. So why multiple conditions for a template argument?
`func process(x:int, y:float, z:string)`
similarly:
`func process[T:prot1, U:prot2, V: prot3](...)`
but protocols can be multi-parameter.
`func process[T,U,V :prot1(T,V) + prot2(T,U) + prot3(U)](...)`
what about using paren when refering to protocols?
`protocol comprbl[T] := ...`
`type Set[T,V : comprbl(T) + prot2(T) + prot3(T,V)] := array[T,V]`

Y - We are not using `var` keyword because we won't be assigning type and so it is redundant.
but `x=f(dasadsa)` seems a bit weird.
specially now that we can re-assign, `=` does not necessarily indicate declaration.
maybe `def` or `let`
or use `:=` for the first time which means assign and declare.
`:=` use to do declaration and initilization at the same time
What happens if I write `:=` twice? error.

Y - use `//` for comments and get rid of `;` completely.

Y - check loop syntax now that we have full mutability and closure syntax and it is a function.
```
loop(10, () -> { printf("Hello world" })
loop([2..10], () -> { printf("Hello world" })
loop([2..10], (x:int) -> { printf("Hello world" })
loop(my_array, (s: string) -> ...)
loop(my_hash, (key: int) -> ...)
loop(my_iteratable, (iterator: int) -> ...)
loop(true () -> { ... })` infinite loop
;to return something:
;we can return explicitly to simulate break: return false means break outside the loop
;return true means continue to the next iteartion
loop([1..100], ()-> { if ( ... ) return false })
;to force return from inside loop: set a var outside
var result = 0
loop(... , () -> { if ( ... ) { result = 88; return false; })
```
`loop(x, (x:int) -> x>0, (x:int) -> { print(x), x++, return x }) ;if x is var, the loop body can change it`

N - What should be initial state for a socket or db connection? all zero.

Y - `return 1 if (x)` how is it translated to map lookup?

N - if `=` duplicates data, what if i `=` a file-handle or db connection or thread?
it will duplicate the variable but the resource will be the same.

N - How can I keep data imm and close a file? What should the file descriptor be?
`f := openFile()`
`g := closeFile(f)`
f won't be usable anymore.
g will point to a closed file.

N - An easy solution to put multiple commands in the same line specially for closures.
it is against simplicity.

Y - Better syntax
`f = openFile(...) & closeFile`
Can we make this more general?
can we do this for other variables? yes.
`x:=12 & print(x)`
```
func process() {
  x:=12 & print(_)
  print(100)
}
```
will print 100 then 12.
What if I pass the file to a thread?
- Change the notation of declaring variables which are disposable.
so if T is disposable type: 
`x := createT()`
right-side cannot be another variable or literal.
the resource release should be handled by the runtime behind the scene.
It needs to be done by runtime but I want it to be explicit that "THIS" variable is disposable.
Maybe we can force a naming notation for these? But its not general. What about custom notations? what about user-defined notations? If we ban it is against orth, if we allow it will be messy.
maybe use a keyword like `resource`:
`resource g := fdsfdsf`
is it that important?
or maybe we can make it explicit and force user call that method somewhere in the code. but it cannot be tracked. because handle may be sent to a channel or another thread.
Disposable is used to define a destructor. Java instead has `finally` keyword and makes it explicit.
what if I write `g := fileHandle1` and pass g to a thread?
Dispose happens based on the actual resource. so if method containing fileHandle1 is finished but the thread that has g is not, the resource won't be released.
We can use something like `using` C# or `scope` in D but I don't want to enforce an indentation level. It makes reading the code difficult. The `defer` method in Go is beautiful but I also don't want to add another keyword.
Maybe I should just ignore the case where something is passed to another function. 
Even if we make close file transparent, user can call it explicitly and pass the file handle to another method. 
So let's just delegate this to the developer to be careful not to use a closed resource.
But I would like to make it explicit and mandatory to close or release resources. 
What if I want to open a resource, pass it to a thread and let it be open even if current function is finished?
But what if someone passes a resource to multiple threads and cause a conflict?
It will cause data racing and conflicts. Resources can only be owned by a single thread (or function) at the same time.
`x := openFile()`
`processInNewThread(x)`
`write(x, "A")`
we can say if a type is marked with `Resource` protocol, you cannot send it to another function. If you do, you will loose control over it. Because it must have exclusive owner. compiler can enforce this.
If a type is marked with `Disposable` you must either call `dispose` on it in the function explicitly (compiler can enforce this because there is no exceptions) or pass it to another function.
But it is difficuly for compiler to check if dispose is called. because it can be nested inside an `if`. But similar to the way we check if unused variable is being used, we can check if `dispose` is called.
Can we merge resource and disposable? if something is a resource, it must be disposed. if something is disposable we can also mark it as resource. So we can define `ExclusiveResource` which means a type is exclusive to the function which created it and it should call `dispose` on it or pass it to another function.
A function that accepts an exclusive-resource must either dispose it or pass it to another function.
And if it passed it to another function, it cannot use it afterwards.
And dispose is like this: `func dispose(T)->T` it will return an empties instance so you must call it like:
`x = dispose(x)`.
Example: file handles, socket, database connection, anything that relates to the outside world.
sending something through channel delegates the responsibility to the receiver side.
Other solution: let the developer do it and handle such cases. but it's not good.
What if a closure thread accesses that resource? it shoudn't.

Y - `5 | nothing` returns 5
`nothing | 4` is like `nothing | func(x:nothing)->4` so `f(nothing)` will just return 4.
does that help to make `|` semantics more clear?

Y - Can we simplify this syntax more?
`var finalResult: Maybe[int] = input | bind(_, check1(5, _)) | bind(_, check2(_, "A")) | bind(_, check3(1,2,_))`
`func bind[T](x:T, f:func(T)->T)...`
Used to transparently handle exceptions?
`var finalResult: Maybe[int] = input | check1(5, _)) | check2(_, "A") | check3(1,2,_)`
solution 1: add a new operator
solution 2: custom opChain or custom operators
`a|b` if a is exception do not call `b(a)` but return a. if a is not exception, return `b(a)`.
`var finalResult: Maybe[int] = input | bind(_, check1(5, _)) | bind(_, check2(_, "A")) | bind(_, check3(1,2,_))`.
`var a: union[T1,T2,T3,...] = x | y | z`
`|` can act as an unwrapper too. if x is `maybe[int]` and y closure expects int and internal type of x is similar, then unwraps it.
so if you write `a = Nothing | 5` 5 will be returned as this is value.
`a = x | f(_)` if x applicable to f, then return f(x), else return x.
`finalResult := input | check1(5, _) | check2(_, "A") | check3(1,2,_)`
for values: it will return the first item which is not nothing.
for closures: it will return the first result which cannot advance to the next step.
`x | f` if f is a closure, will evaluate to `f(x)` if f can accept data of type `x`, else it will evaluate to `x`. 
`a | b` if b is not a closure, will evaluate to `a` if it is not `nothing`, else it will evaluate to `b`.
`a|b` ~ `a|default(_,b)`
`func default[T](x:T, def: T) { return if ( type(x) == @nothing ) y else x`
deciding based on whether `b` is a closure or not is a bit confusing. We can have variables of type function pointer. What about them?
`data | function` will return `function(data)` if it is applicable else data.

Y - What if resource is in maybe? compiler cannot detect that.
`x := maybeOpenFile()`
`x:=getFileOrIntOrString(...)`
can we say, exclusive resources cannot be part of a union?
We are adding more and more rules and exceptions!
We should simplify.
Let developer worry about sharing them with other threads and functions.
He can either call dispose function explicitly or just let runtime do it.
Problem is for all other data, we just duplicate them so there is no mutation.
But these are "exclusive" resource. There is only one of them behind the scene. So even if I write:
`g := myFile` it does not create two files.
So duplicating or passing to another function is like a shared mutable state.
It is inherently mutable (you write to file or socket).
So let's prevent sharing it.
That's why it is marked with `exclusive` protocol. It is not supposed to be shared.
`x:=getFileOrIntOrString(...)`
compiler cannot detect whether it is an exclusive resource or no.
solution 1: they cannot be part of a union. function can return a tuple in case they need union with them.
the main problem is `dispose`. How can I call dispose for a union type which has a resource as one of it's valid types?
solution: if you want a `union[nothing, File]` you must have two dispose functions: `dispose(file)` and `dispose(nothing)`.
And so you must call `dispose(x)` which will at runtime redirect to one of these.
So add required dispose functions and use the resource inside a union.

Y - Simplify this.
`type u5 := union[T: Prot1 + T.Tuple1]` 
`protocol Eq[T:Ord1 + Ord2] := { func compare(T,T)->bool }`
`type Set[T,V : comprbl(T) + prot2(T) + prot3(T,V)] := array[T,V]`
`func isInArray[T,V: Eq(T) + prot2(T,V) + T.Field1](x:T, y:array[T]) -> bool { ... }`
specially for union the syntax is confusing.
`type u5 := union[A, B, C, ...]`
result of a type-filter is a set of types which conform to a specific protocol or has a specific field.
we call this: `typeset` which is a compile-time thing.
Now we can define a union with that typeset which means that union can store a value of any of those types.
we can define a protocol and limit it's type with a typeset: only those types are allowed to implement this protocol.
we can define a generic type with that typeset: it can be instantiated only with those types.
we can define a generic function with a typeset. the function can only be called with those types.
`typeset`?
`typeset TS2(T) := Eq[T] Ord[T]`
`typeset TS3(T,U) := prot2[T,V] T.Shape V.Data`
`typeset TS3(T, U, V) := prot2[T,V] + T.{Shape} + V.{Data}` ?

`func isInArray[T,V: TS3](x:T, y:array[T]) -> bool { ... }`
or maybe we should combine all of these into protocols. so protocols will be typesets.
protocol specify a set of types based on their requirements. These requirements can be either on functions or fields of types.
`protocol P1[T] := Ord1 + Ord2`
`protocol P2[T,V] := Eq[T] + prot2[T,V] + T.Field1`
```
protocol P2[T,V] := {
    Eq[T],
    prot2[T,V],
    prot3[V],
    func process(T,V)->int,
    T.Field1
}
```
`func isInArray[T,V :: P2](x:T, y:array[T]) -> bool { ... }`
Why do we need filter based on fields? to write a function which can act on all children of Shape.
Suppose that we have `Shape` and it's children: `Square, Circle, Triangle, Rectangle, Oval, ...`.
I want to write a function to accept all of those, in one decl:
`func process[T: T.Shape](x: T) ...`
But why not write a normal function for Shape and redirect when I need to? it is more difficult but more flexible.
using protocol, defines 20 functions for all those types and I will be stuck with them. I cannot override them because compiler will complain about confusing decl.
So let's just remove fields.
```
protocol P2[T,V] := {
    Eq[T],
    prot2[T,V],
    prot3[V],
    func process(T,V)->int,
}
```
`func isInArray[N,R :: P2](x:T, y:array[T]) -> bool { ... }`
`N,R :: P2` means `P2(N,R)` must hold.
`func isInArray[N,R :: P2](x:T, y:array[T]) -> bool { ... }`
what about single-arg protocols?
`func isInArray[N: P2, R](x:T, y:array[T]) -> bool { ... }`
current: 
`func isInArray[T,V :: Eq(T), prot2(T,V)](x:T, y:array[T]) -> bool { ... }`
`type u5 := union[T :: Prot1]`
`type Set[T,V :: comprbl(T), prot2(T), prot3(T,V)] := array[T,V]`
`protocl_name(A,B,C)` invokes protocol to get the matching typeset.

Y - Shall array access return maybe to handle index-out-of-bounds?

N - In block-if we have a lambda syntax. So it cannot re-assign function variables.
It's ok. They are not supposed to be very long codes.

N - Force functions that have side-effect return a special return type.
`func writeFile`
`func sendOnNetwork`
There are specific functions in core that have side-effects. Compiler knos them and the functions that call them. So it can deduce those functions + every function that calls something outside (C code)

N - `func isType[T](x: T, type: int) -> typeof(x) == type`
`if ( isType(x, @int) )`
`if ( typeof(x) == @int )`
`func isNothing[T](x: T) -> typeof(x) == @nothing`

N - In block-if, what if key is an expression?
```
(f(x,y,z,t)) [
@int => ...
@float => ...
]
```
solution: store it in a variable. No need to make syntax more complex.

Y - Scala: 
`userList.sortBy(_.active)`
here:
`sort(users, (x:User)->x.active)`
It's ok. We are not aiming to have shortest possible syntax.
The only shortcut we accept in this regard is `_` for closure
Scala: `ps.filter(_.score < 50).filter(_.active).map(_.copy(active = false))`
When passing lambda as argument, we have nested paren. Can we eliminate that?
`result := ps | filter(_, (x:User) -> x.score < 50) | filter(_, (x:User)->x.active) | map(_, (x:User)-> not x.active)`
Maybe we can use different notation for function decl (used also for lambda) than function call?
`func process(x:int)->...`
`process(12)`
say we use `/args/`?
`func process(x:int)->...`
`process/12/`
`result := ps | filter/_, (x:User) -> x.score < 50/ | filter/_, (x:User)->x.active/ | map/_, (x:User)-> not x.active/`
We definitely need some notation to make code readable and explicit and specify argument bounds.
`{}` is used for code-block and tuple definition and tuple litearl.
`[]` for generic and array/map literals.
`()` for function declaration.
`<>`?
`result := ps | filter<_, (x:User) -> x.score < 50> | filter<_, (x:User)->x.active> | map<_, (x:User)-> not x.active>`
It's better to keep lambda decl same as function decl because they are same things.
So: `x := (g:int) -> g+1`
But for function call, maybe another notation is better
`f:x,y,z:`
`f(x,y,z)` current notation
`f!x,y,z!`
`f x y z`
`f x,y,z` cannot compose
`f/x,y,z/` pro: no need to press shift
`f\x,y,z\`
`f/x,y,z\`
`f<<x,y,z>>` too long
`f<:x,y,z:>`
`f/x,y,z;`
`f;x,y,z;`
`f,x,y,z`
it should be easy to nest because we may nest function calls:
`f/x,y,g/1,2,3//`
Maybe we should act other way around: change function declaration syntax:
`func process/x:int, y:int/` because inside function declaration we won't be nesting.
`func process/x:int, y:int/ -> int`
`func process/x:int, y:int/ -> int { x+y }`
`x := /x:int/ -> x+y`
`result := ps | filter(_, /x:User/ -> x.score < 50/ | filter(_, /x:User/->x.active) | map(_, /x:User/-> not x.active)`
or `|`?
`func process|x:int, y:int| -> int { x+y }`
`x := |x:int| -> x+y`
`result := ps >> filter(_, |x:User| -> x.score < 50/ >> filter(_, |x:User|->x.active) >> map(_, |x:User|-> not x.active)`
proposal: use `>>` for chain and `|x,y,z|` for function/lambda declaration (Like Rust).
`func process[T,V :: prot1(T,V)] |x:T, y: U| -> { ... }`
Scala: `primes.filter(_ > 100).take(5).toList`
`t := primes >> filter(_, |x:int| -> x>100)) >> take(_, 5) >> toList(_)`

N - Current notation to fallback for map nothing:
`value := my_map("key1") >> def(_, 0)`

N - functions record assumptions. How?

Y - Can't compiler just deduce the required functions from body of the template functions?
The original purpos for C++ concept was to make compiler error messages more meaningful.
From https://isocpp.org/blog/2016/02/a-bit-of-background-for-concepts-and-cpp17-bjarne-stroustrup:
The lack of well-specified interfaces led to the spectacularly bad error messages we saw over the years. 
How does this affect the failable example?
what about unions? how can we make it abstract with regards to child types like circle and square?
worst case: compiler can generate it at compile time for us.
q: what about disposable protocol? we can use a convention or some empty tuple to be included.
q: how to provide substitutability for types? keep a variable which can accept any of children of Shape?
easiest solution: define the type in the code manually. problem: if we extend to a new subtype, we must update that part too.
??? `type u5 := union[T :: Prot1]` This union can accept all types that match `Prot1`.
not needed: `protocol Eq[T :: Ord1, Ord2] := { func compare(T,T)->bool }`
not needed - functions enforce this: `type Set[T,V :: comprbl(T), prot2(T), prot3(T,V)] := array[T,V]`
not needed: `func isInArray[T,V :: Eq(T), prot2(T,V)](x:T, y:array[T]) -> bool { ... }`
`x := createShape()` type of x can be anything?
`draw(x)`
1. `type shapes := union[Shape]` union includes all tuples that embed Shape type.
2. every tuple that embeds `ExclusiveResource` is treated like an exclusive resource.

Y - In closure, another solution is to assign captured vars before using them.
http://docs.scala-lang.org/sips/pending/spores.html
```
x = 12
|| -> { y := x, process(x) }
```

N - (included in another one) How can we define a loop for multiple array or maps?
```
loop([users, servers, permissions], 
|input: {u: User, s: Server, p: Permission} | -> { if (hasPermission(u,s,p)) Stat{u} })
```

N - How can I run map function on an array or map or any other non-list type?

Y - to reduce paren, use `then` keyword. and make loop a keyword?
`return if a then 5 else 7`
`g = if a then {
...
...
} else {
...
...
}
```
loop 10 do printf("Hello world")
loop [2..10] do printf("Hello world")
loop x>0 do printf(x)
loop true do ...
loop x <- [2..10] do printf("Hello world")
loop item <- my_array do printf(item)
loop g <- my_iterable do ...
loop {x,y} <- [ [2..10], [1..9] ] do printf("Hello world")
```
continue: just include that condition inside loop body
break: include that condition inside loop header

Y - General loop: for example on a bitset which is not an array or a map.
```
type Iterator[T] := {...}
iterator := getIterator(myBitSet)
loop g <- iterator do ...
```

Y - Syntax to define tuple literals:
`var another_point = Point{x=100, y=200}`
`=` is not intuitive. let's use `:=`
`another_point := Point{x:=100, y:=200}`
can we use this to define an untyped tuple with names?
`g := {h:=11, g:=12}`
But we cannot use this as another type which has exactly same name and types.
`h := MyTuple{g}` then we can use `h` as `MyTuple` type.
But this notation will be useful when a function returns a tuple.
`func process || -> {x:int, y:int} ... { ...return {x:=12, y:=91} }`

N - matching in if-block with tuple types can be difficult.
```
n = (type(a))
[
  @Point => Point{a}.x + Point{a}.y
]
```
proposal: underscore inside a hash literal when key is a type-id is translated to casted data.
```
n = (type(a))
[
  @Point => _.x + _.y
]
```
```
m := (n) [ @Point => 2 ]
```
- we must be using a map literal and not a stored map.
no its not general and not simple.
maybe we can shortcut repeated castings.
```
n = (a)
[
  @Point => Point{a} { .x + .y }
]
```
instead of `A.g...A.h...A.y` write `A.{g...h....y}`?
solution1: `A { ... }` then inside the block any `.G` will be translated to `A.G`.
```
n = (a)
[
  @Point => |q:=Point{a}| -> q.x + q.y
]
```
solution2: a lambda with parameters which have values it will be evaluated on the spot
2 is more flexible, you can combine multiple arguments and use this in other similar places.
it can be called expression-lambda.
But note that this is only applicable/useful for union types and only inside map literals.
```
n = (type(a))
[
  @Point => Point{a}.x + Point{a}.y
]
```
Let's don't touch it. If it is needed user can open a code block and assign it to a variable.

N - can we make `>>` simpler? "does not match" is not simple and clear.
specifically when we don't specify type on lvalue.
`x := a >> process(_) >> save(_)`
`if ( type(x) == @exception ) ...`
No this makes sense. 

Y - Adding a shortcut for type checking.
`if ( type(x) == @T )`
`if ( x @ T )`

N - Can we use something else instead of `{}` for tuples? it becomes confusing with code block.
for tuple declaration it is ok. But tuple literal no.
```
point := /x:=100, y:=200/
type Point := /x: int, y: int/

point := ++x:=100, y:=200++
type Point := ++x: int, y: int++

point := ::x:=100, y:=200::
type Point := ::x: int, y: int::

point := #x:=100, y:=200#
type Point := #x: int, y: int#

$ is similar to S, might be mistaked
point := $x:=100, y:=200$
type Point := $x: int, y: int$

point := //x:=100, y:=200//
type Point := //x: int, y: int//
= = = =
point := #x:=100, y:=200#
point := #100, 200#
type Point := #x: int, y: int#

/ is also used for integer divide!
point := /x:=100, y:=200/
point := /100, 200/
type Point := /x: int, y: int/
```
```
point := #x:=100, y:=200#
point := #100, 200#
type Point := #x: int, y: int#
g := Point#x:=100,y:=200#
g := Point#100,200# to define literal
g := Point[int]#100,200#
type Circle := #Shape, radius: float#
g := Point{myUnion} to do cast
g := int{x}
Point[int]#100,200#.x / 5
Point[int]#100,200#.x / Point[int]#100,200#.y
```
```
point := /x:=100, y:=200/
point := /100, 200/
type Point := /x: int, y: int/
g := Point/x:=100,y:=200/
g := Point/100,200/ to define literal
g := Point[int]/100,200/
type Circle := /Shape, radius: float/
g := Point{myUnion} to do cast
g := int{x}
Point[int]/100,200/.x / 5
Point[int]/100,200/.x / Point[int]/100,200/.y
func process()->/x:int, y:int/ ... return /x:=1, y:=30/

Point[int]!100,200!.x / Point[int]!100,200!.y
Point[int]&100,200}.x / Point[int]!100,200!.y
```
Let's keep `{}` other candidates are mostly confusing.

Y - what other features are not really needed or can be easily simulated with other features?
or can be done by the compiler?

Y - Make loop syntax explicitly indicative of variable is new or not.
loop variable must be declared. makes reading code simpler.
```
loop x>0 do printf(x)
loop true do ...
loop x := [2..10] do printf("Hello world")
loop item := my_array do printf(item)
loop g := my_iterable do ...
loop {x,y} := [2..10], [1..9] do printf("Hello world " +x +y)
```
re-sue `:=`. pro: it is existing notation and is familiar. 
con: we are using it for another purpose: rvaue is not a simple value.
We want something which indicates variable is being declared AND is not `:=` and indicates iteration.
`<:=` no.
`x := @array` no new notation. only one notation should be used.
Can't we just say, if x is not declared before, it will be?

N - `process(1,2,_)` what does this mean?
what if we have two process functions with 3 arguments and third one are different?
I think third argument should be a union

N - Is there a feature which can only be used in some situations and not always?

N - If I use typed literal, I can omit name:
`x := Point{12, 13}`
`x := Point{x:=12, y:=13}`

N - We have two ways to declare a variable. `:=` and `<-`.
```
loop x     := [2..10] do printf("Hello world")
loop item  := my_array do printf(item)
loop g     := my_iterable do ...
```
java: 
```
for (String item : someList) {
    System.out.println(item);
}
```
No problem. Let's have two notations. Because `:=` makes no sense for this case.

Y - How to remove a key from map?
`map1 := ["A"=>1, "B"=>2]`
`map1 = map1["C" => 5]`
`map1 = map1["A" => nothing]`?
or maybe use `+` and `-`?
`map1 = map1 + ["N"=>8]`
`map1 = map1 - ["B"]`
but what about array?
`array := [1,2,3]`
`array += [1]`? we cannot add to an array
`set(array, 1, 7)`
`set(array, [1,2,3], [5,5,5])`
`y2 :=arr[0,0=>102]`
Scala uses functions.
For reading you can use `()` but for update you must use `set` function.

Y - We can use `if ( x == SAT )` notation for type checking with label types.
So can we just eliminate binary `@`?

Y - `loop x :=: [1..10]`
no 3 letter notations.
`loop x := [1..10]`

Y - simplify `>>`?
How is Monad defined in Java or Kotlin or Python?
How can we more natively simulate it?
`var finalResult: Maybe[int] = input >> check1(5, _) >> check2(_, "A") >> check3(1,2,_) >> (|x:int| -> x >> process(_))`
`func pipe[T, U](x: Maybe[T], f: func(T)->U)->Maybe[U]`
`finalResult := pipe(input, check1(5, _)) >> pipe(_, check3(1,2,_)) >> pipe(_, check5(8,_,1))`
`data := array1(10) >> default(_, 0)`
this is simpler because there is no "if does not match".
can we use a simpler notation? `|>` `|>` makes sense.
can we get rid of nested paren here?
`finalResult := pipe(input, check1(5, _)) |> pipe(_, check3(1,2,_)) |> pipe(_, check5(8,_,1))`
what about `.` dot?
`finalResult := pipe(input, check1(5, _)).pipe(_, check3(1,2,_)).pipe(_, check5(8,_,1))`
`a.f(_)` means `f(a)`
`{a,b}.f(_,_)` means `f(a,b)`
`finalResult := {input, check1(5,_)}.pipe.{_, check3(1,2,_)}.pipe.{_, check5(8,_,1)}.pipe`
`5.f.(_, 5).g` ~ `g(f(5),5)`
why use braces here?
`finalResult := (input, check1(5,_)).pipe.(_, check3(1,2,_)).pipe.(_, check5(8,_,1)).pipe`
`finalResult := pipe(input, check1(5,_)).pipe(_, check3(1,2,_)).pipe(_, check5(8,_,1))`
How to differentiate from tuple access?
when accessing tuple, `tuple.member` but for chain: `a.f(...)`
Then what if tuple has a function pointer?
`tuple.fp(10)` it will be really confusing with chain. NO! this is calling fp function pointer which is member of tuple.
but chaining is really useful here.
`data := array1(10).default(_, 0)`
Shall we put rules on invoking a function pointer?
if `fp` is a function pointer, `fp()` is wrong.
`myCircle.draw()` call draw function pointer which is a member of myCircle tuple
`myCircle.draw()` call `draw` function with input `myCircle` - this is not correct. it must be a closure.
`tuple.f()` is invocation of a function pointer.
`tuple.f(_)` is chaining tuple to normal function f.
`finalResult := pipe(input, check1(5,_)).pipe(_, check3(1,2,_)).pipe(_, check5(8,_,1))`
`g := 5.add(_, 9)` g will be 14
`g := (5,9).add(_, _)` g will be 14
but this syntax is not consistent. What is meaning of `(5,9)`?
left side of a dot can be a normal variable or a tuple. for chaining, tuple will chain multiple values into the function.
But what if function needs a tuple?
`{1,2}.processTuple(_)` if closure has one input, then left of dot is a tuple as a single argument.
`{1,2}.processTwoData(_, _)` in this case tuple will be dispatched to two arguments.
And of course if on the right side of dot, there is no closure (just an identifier or name without underscore) it is variable reference.
`finalResult := pipe(input, check1(5,_)).pipe(_, check3(1,2,_)).pipe(_, check5(8,_,1))`
`g := (5,9).add(_, _)`
`g := 5.add(_, 9)`
`{1,2}.processTwoData(_, _)`
`{1,2}.processTuple(_)` 
`data := array1(10).default(_, 0)`
`data := circle.process(_)`
`data := circle.process()`
`data := circle.process`

Y - Better and more distinct notation for tuples?
`/1,2/./_, _, 5/.process(_,_,_)` will become `process(1,2,5)`.
`#1,2#.#_, _, 5#.process(_,_,_)` will become `process(1,2,5)`.
They are not nested beautifully.
`#1,2#4,5##` !!!
`/1,2/4,5//`
start and end market must be different and complementing.
`|>1,2|>4,5<|<|` too long. 4 keys needed.
what about a prefix?
`$(1,2,3)` makes a tuple literal.
`$(1,2, $(4,5))`
`${1,2, ${5,6}}`
`${1,2}.processTuple(_)`.
Tuple literal which does not have a type must be prefixed with `$`.
`point := ${x:=100, y:=200}`
`point := Point{x:=100, y:=200}`
`fourth_point: {x:int, y:int=123} = ${300}`

Y - Now that we use these keywords, why not use for switch?
`switch`, `else`?
you must use braces. if it is just one or two cases, maybe its easier to use `if`.
```
y = switch x 
{
    1: "G",
    2: "H",
    3: "N",
    else: "A"
}
```
To type match for a union:
```
y = switch type(x)
{
    @int: "G" + int{x},
    @string: "H",
    else: "X"
}
```

N - `type x := func(x:int)->int`
`g := |x:int|->x+1`

Y - function chaining `.` with spaces around. So we don't need to introduce rules and exceptions about tuples.

N - `!` for check for nothing and different syntax for switch
`g := arr(0) ! 5`
`g := arr(0) || 12`
`g := arr(0) . def(_, 5)`
`g := if arr(0) != nothing then arr(0) else 12`

Y - switch for union
```
switch(union1) {
x:int -> 
y: float ->
nothing ->
else ->
}
```
places that we use nothing: array, map, maybe.

N - what does this do?
`x := map1(1) . ${_, 1}`
`x := 5 . ${_, 1}`
`x := ${5, 1}`
how can we access inside x?
`${a,b} := x`
or we can simply send x.

Y - Like what we did for tuple literal, shall we use symbols for array and map literals?
1. `arr := $[1, 2, 3]`
8. `arr := array[int]$[1, 2, 3]`
1. `my_map := $["A"=>1, "B"=>2, "C"=>3]`
5. `my_map := map[string,int]$["A"=>1, "B"=>2, "C"=>3]`

Y - Provide ability to update used libraries without need to re-compile main application.
https://github.com/apple/swift-evolution/blob/30889943910a4a4e46a800f03d17a91e11ca475f/README.md#development-major-version--swift-30

Y - Can't we make switch statement consistent? all cases `:` or `->`?

N - Disable loop/for for array or hash and use core functions.
con: we loose ability to return and re-assign local vars.
con: more nesting and paren/braces because we don't have `do`.
but loop will be simpler or maybe we can eliminate it.
q: what about nested loops?
we can delete `for` keyword and have only `while` for condition based loops.

Y - Decide on the name: Generics or template: Generics

N - It can be a bit confusing between function literal and tuple. But `$` is useful here.

Y - Explicitly define where we should use `||` for func definition.

N - How can I state type of a lambda? Do I need to?
`fp := int{|x:int|-> { return x+1}}`?
No. A lambda has it's own input and output types. 

N - If we disallow re-assignment, then closure's limitation can be lifted. but what about loops?

Y - ban using `=` for exc resources.

Y - Having two ways to assign `=` and `:=` is confusing.
maybe add `val` or `def`?
Then we can also add optional type with `val` and no need to cast integer to `union[int, float]`
 `:=` custom type definition, variable declaration, tuple literal, `for`
 `type MyInt := int`
 `x := process()`
 `x := {a:=1, b:=2}`
 `for x := [1..10] do ...`
 will become:
 `set x = process()`
 `set x = {a=1, b=2}`
 `for set x <- [1..10] do ...`
 or:
 `def x = process()`
 `def x = ${a=1, b=2+g}`
 `def x = Point{a=1, b=f(x)+f(y)}`
 `for def x <- [1..10] do ...`
 let is used in js, rust, F#
 `let x = process()`
 `let x = ${a=1, b=2+g}`
 `let x = Point{a=1, b=f(x)+f(y)}` confusion here because `a` may be name of a local variable.
 `for let x <- [1..10] do ...`
 `let another_point = my_point{x:=11, y:=my_point.y + 200}`
 `let x = Point{.a=1, .b=f(x)+f(y)}` 
 `let x,y = my_point`
 `let x,y = ${100,200}`
 or:
 `var x = process()`
 `var x = ${.a=1, .b=2+g}`  `var another_point = my_point{.x=11, .y=my_point.y + 200}`
 `var x = Point{.a=1, .b=f(x)+f(y)}` confusion here because `a` may be name of a local variable.
 `for var x <- [1..10] do ...`
 `var x = Point{.a=1, .b=f(x)+f(y)}` 
 `var x,y = my_point`
 `var x,y = ${100,200}`
 `var x,y: int = ${100,200}`
 `var x: int,y: float = ${100,200}`
 using `var` has a con: you can write `var x: int` and not assign to it.
 but with `:=` assignment is bound to declaration.
 objective: make things simple to write and read -> using `var` is better. It is more explicit and can easily discriminate var decl and assignments.
We can force init upon decl.
`var x = process()`
`var x = ${1, 2+g}`  `var another_point = my_point{.x=11, .y=my_point.y + 200}`
`var x = Point{.a=1, .b=f(x)+f(y)}` confusion here because `a` may be name of a local variable.
`for var x <- [1..10] do ...`
`var x = Point{.a=1, .b=f(x)+f(y)}` 
`var x,y = my_point`
`var x,y = ${100,200}`
`var x,y: int = ${100,200}`
`var x: int,y: float = ${100,200}`
You cannot define a tuple literal without type and with field names. 
Untype tuple literal can only contain values.

N - protocols but for types? No need. Just use convention.
I want to define a set but it's generic function must be comparable.
`type Set[T] := array[T]???`
one solution: enforce this type can only be created using X function. And in that function declare this.
`type Set[T] := array[T] with func create[T]`
So you cannot simply define a Set literal or an array literal and cast it to Set.
`type Set[T] := array[T] with create`
this is like a constructor. `create` means a function with this name, a single generic input and output type of `Set[T]`.
`func create[T](...)->Set[T]`.
Let's not create a new keyword for this.
`type Set[T] := array[T] -> create`
`type Set[T] := array[T] <- create`
This can be useful for exclusive resources too. User is not supposed to create a FileHandle tuple himself.
`type Set[T] := array[T] <- create`
Name cannot be fixed. it can be something else, not always `create`.
We can redirect function and like `dispose` use fixed name.
Just like `dispose` we can have `create` function.
AND like exclusive-resource, we can have same tuple which if embedded, means type cannot be manually created.
`type Set[T] := {data: array[T], CustomCreate}`
So if the tuple embeds this, it must be instantiated using `create` function.
`dispose` is mostly for built-in types.
Can we simplify it?
Same for create. but create is more used because developer should not be involved in manual dispose but for create they can be.
Can a developer define one of it's own types as an ex-res with custom dispose? Yes. Like a virtual memory buffer.
If a developer defines a custom type as CustomCreate type, how can he write the code for create function?
Anyway he needs to write some kind of a tuple.
`type Point := {x:int, y:int, CustomCreate}`
```
func create(x:int)->Point {
  return ${.x=x, .y=10}
}
```
can users modify an exclusive-resource? They shouldn't be.
But why not have `create` as just a convention? If user calls type with inappropriate types and arguments and creates a variable he cannot use it because functions will complain. Less limits!
So we only need this for `ExclusiveResource`.

N - Document alias methods used for dispose and create to redirect standard name to another names.

N - Set a tag-line as "(almost) Go + Generics"

Y - Why do we need ex-res concept? Can we simplify them?
- What if user writes: `var otherSocket = mySocket`?
will it be a copy of the original or a new socket? suppose `mySocket` is an open and active socket.
Problem is we do not have notation of reference assignment. This causes problems for large data (handled by the compiler) and also for special resources like a network socket.
Because of making assignment by copy, you cannot simply deal with these resources.
underlying, there is only one socket or file descriptor or ... .
Also there is not much use to give developer this ability. Because it is only limited to core.
Maybe we can make it easiler.
Can we think of an exclusive resource like a static function which always returns the same thing?
- You cannot assign to a funtion.
ex-res cannot be an lvalue. what about defining `val` which cannot be re-assigned? Too much change just for a simple concept which also won't be enough.
Limitations:
1. cannot be assigned.
2. must either pass it to other func or call dispose.
3. after passed to other func, you cannot use them.
4. cannot be captured by closures.
Our philosophy is that compiler/runtime should not be doning something behind the scenes. It must be indicates explicitly by the developer.
`var f = openFile("a.txt")`
`var g = f`
- They cannot be re-assigned to copied to another variable.
- User must explicitly call `dispose` function.
what about imposing a block for them? like using?
```
using ( var file = fileOpen() ) {
...
}
```
`dispose` is automatically called when we exit this block.
outside block, there is no `file` so it cannot be used. Not very beneficial.
If ex-res is only for core level data why give developer ability to deinfine custom ex-res?
- we can force user cannot create/generate his own ex-res values. He must call core functions. So we can prevent assign.
- we cannot prevent re-assignment. unless as a magical rule.
- Instead of checking for these rules let developer handle the case. `vet` utility can issue warnings for these cases but that is completely a separate topic.
The only thing is that we have `dispose` functions for resources that are valuable. 
Let's ban sending them to other functions or lambda or returning them. but this does not make sense. How can we implement a thread pool or db connection pool this way?
- What about this?
1. everything is allowed. assign, re-assign send ...
2. If at any step, two threads make a call against an exclusive resource, runtime will exit. so developer is responsible.
You can assign to a resource or re-assign to it.
You can send it to another function and work with it after sending.
Functions with input of tyep ex-res can use it or return or send or do nothing.
What if I dispose exres and send it to another function? It's an error.
1. Exclusive resources are just like other data tyes but internally they use access controls to make sure they are only used by the thread which has created them. 
2. If you send an exclusive resource to another thread, and try to use it there, there will be a runtime error.
3. You are expected to create exclusive resource by calling appropriate functions instead of initializing a literal.
4. You are expected to call `dispose` function on exclusive resources if you don't want to rely on GC to call that.
There are two approches:
optimistic: Let them do whatever they like, if something goes wrong I will throw error.
pessimistic: Don't let them cause any trouble. 
in opt view, I need to monitor and manage each operation to make sure it is not an error. 
in pess view, I don't need to monitor anything because the rules in-place by compiler make sure nothing goes wrong.
opt view is easier for the developer but expensive for compiler and runtime system.
pess view is more difficult for the developer (he has to deal with a lot of rules) but easy for compiler runtime system.
Because of performance reasons we can choose pessimistic view and let compiler check rules.


Y - Document that we can specialize generics:
`func process[int](x: int)...`

N - These rules (For exres) will guarantee prevention of data-race and destruction, but they are really hard to follow.
If we can enforce them for all the types that we have we can get rid of GC and make everything mutable!!!!!!!!
- For any var, you can modify it inside the function.
1 - No re-assign or assign to other vars.
2 - pass them or return them or dispose them.
3 - if you pass, you cannot use them after that.
4 - cannot be capture by closure.
rule 3 is the most strange rule.
how can I implement a loop then?
The problem with this approach is that it makes writing and reading the code difficult.
Advantage: no GC and no racing (Like what Rust does)
Cost: unreadable code which is also hard to write.
Let's just ignore it.

N - Can we simplify exres?
Why I cannot re-use a exres after passing it to another function?
we adopt notation of copy-value in all cases with `=` but here it won't be copy-value.
`var f = file2` invalid
`process(file2)` then `write(file2, 1)` invalid.
we can get rid of `dispose` and say, it can be automatically called but better to have it explicit there.
can we hide all of these details inside some functions?
they return a simple integer so if I assign it to another var, it will clearly be the same thing.
```
var fileHandler: Filedesc = openFile(...)
var f2 = fileHandler
fileHandler = dispose(fileHandler)

```
- To force not using after dispose, you can force `x=dispose(x)` format in the code.
- No exres can appear on the right side of `=`.

Y - protocols?
To have minimum impact on the language and concepts but have protocols, we can define expected functions as a tuple with function pointers. an input of type this, can use core function to get appropriate functions from current environment.
`func process(a:int, x: RequiredFunctions)`
`process(10, &)`
`process(10, ${&})`
problem with protocol:
- they are confusing we can (should) have multiple protocols for multiple arguments
`func process[T,U,V : prot1(T), prot2(V), ...]` and reading the code becomes confusing.
- The developer should decrypt protocol syntax to find out what functions are needed to be defined.
- It is more readable and more powerful but causes confusion.
- It is a new piece of different syntax in function and data type declaration.
what about data types? How can I say a set must have these protocols? Maybe I cannot do it with tuples.
- Protocol is more powerful because I can define multiple protocols each for a specific type and task and combine them easily and they are more readable. 
- How to write a generic iteration function?with expects an interable?
- another solution: make it easier to bind functions in the context to function pointer varialbles.
problem with protocol is that it can be used to make code very complicated. Anything that let's others make code bad should be eliminated unless it has very clear benefits without a good and simple alternative.
```
protocol Adder[S,T,X] := {
    func add(x: S, y:T)->X
}
func process[S,T,X: Adder] (x: S, y:T)->X { return add(x,y) }
s = process(x,y)
```

```
type Adder[S,T,X] := {
    add: func(x: S, y:T)->X,
    sub: func(x: S, y:T)->X
}
func process[S,T,X] (x: S, y:T, z: Adder[S,T,X])->X { return z.add(x,y) }
s = process(x,y, Adder{.add=add1, .sub=sub1}) //this is completely consistent with current syntax
```
```
type Adder[S,T,X] := {
    add: func(x: S, y:T)->X,
    sub: func(x: S, y:T)->X
}
func process[S,T,X] (x: S, y:T, z: Adder[S,T,X])->X { return z.add(x,y) }
s = process(x,y, autoBind[Adder[int, int, int]())
```
- `autoBind[T]` function in core will generate a tuple with given type. 
Haskel's type classes have some problems: What if implementation does not have the same name as in the typeClass?
Here we have full control over input and we can pass our own tuple with any function name we want.
2. They don't have laws. We can implement this as a set of other tuples/functions and bind these two maybe using a convention.
can we abstract over these tuples? Like a function which can accept different protocol tuples based on the request of the caller. with tuples we can because protocol is no longer a magical thing. 
Also there is no need to special notation to inherit from another protocol. We already have it.
`s = process(x, y, autoBind[Adder]())`.
vs
`s = process(x,y, autoBind[Adder[int, int, int]())`
We can say `[~]` indicates compiler should infer types from the context.
`s = process(x, y, autoBind[~]())`. In this place, process needs a tuple of type `Adder` which should be `Adder[int, int, int]`. Or maybe even `[]`.
So:
`func add[T](x: T, y:T]`
can be called as: `add[](5,9)`.
`s = process(x, y, autoBind())`
`func autoBind[T]()->T`
so: 
proposal: 
1. Define a function in core called `autoBind`. 
2. Each function can define an input of type tuple which includes only function pointers. 
3. Usage: In generic functions, to document requirements regarding generic types. 
4. Caller can use `autoBind` to provide default values for that tuple fields based on it's field names and current context's functions.

N - what about forcing to use `[]` so when reading the code we know which function is generic and which is not?
`func add[T](x: T, y:T]`
can be called as: `add[](5,9)`
So we can have two functions with same name generic and non-generic:
```
func process[T](x: T)...
func process(x:int)...
process[](myInt) //this will call the first function
process[int](myInt) //same as above just with explicit types
process(myInt) //this will call the second function
```
It will pullote syntax without a clear benefit.

N - Can we implement exres using native features of the language?
Just like autoBind?
so developer is not forced to do or avoid doing something?
1 - No re-assign or assign to other vars.
2 - pass them or return them or dispose them.
3 - if you pass, you cannot use them after that.
4 - cannot be capture by closure.
How can we implement these rules using functions?
Can we add a layer on top of internal resource? So user can only work with them using those functions.
but these items are mostly built-in features. capture or assignment.
optimistic: Let them do whatever they like, if something goes wrong I will throw error.
pessimistic: Don't let them cause any trouble. 
in opt view, I need to monitor and manage each operation to make sure it is not an error. 
in pess view, I don't need to monitor anything because the rules in-place by compiler make sure nothing goes wrong.
opt view is easier for the developer but expensive for compiler and runtime system.
pess view is more difficult for the developer (he has to deal with a lot of rules) but easy for compiler runtime system.
pess view is good for runtime performance.
opt view is good for developer work.
performance is last goal, top goal is simplicity. 
All these rules indicate complexity!
So let's do it like this. 
Minimum rules and restrictions. Let developer do whatever he likes.
At runtime (or better at compile time), throw error if something wrong is being done.
1 - No re-assign or assign to other vars -> can assign or even modify
2 - pass them or return them or dispose them -> can just let them be there without pass or return or dispose.
3 - if you pass, you cannot use them after that -> can use after passing.
4 - cannot be capture by closure -> can captures
Everything is like a normal integer variable.
But at runtime we will throw error if it is shared between multiple threads.
We can do this for all other types but it will be very expensive, which is not worth it.
So how are we going to define this? by using something like phantom types.
`type FileDescriptor := Resource[int]`
`Resource` type specified exres-es.
Anything which is based on Resource is a resource and will be checked for single-thread use at runtime.
And let's do it like this: Each function which creates or accepts a resource, must call dispose for it.
Runtime will count references and do the actual dispose when it has no more references. unless they are returning the resource as an output.
1 - No re-assign or assign to other vars -> compiler checks for this and ban resource on the right side of `=`.
2 - pass them or return them or dispose them -> just call dispose unless you return the resource.
3 - if you pass, you cannot use them after that -> can use after passing.
4 - cannot be capture by closure -> can capture.

N - Can we prevent re-assignment in the code? maybe use `val`? NO! This solves only some of the problems but not all of them.
What will be the use of this?
1. Closure can only capture `val`s. No need to enforce rule: cannot re-assign it captured in closure.
2. for exclusive resources, they must be defined as `val`.
But isn't this like a loop? what happens when I send a `var` to a function?
There are two complexities here: 
1. adding `val` to the language.
2. stating you cannot re-assign exclusive resource.
I think 2 has less complexity for the language.
maybe we can eliminate the rules by adding special code blocks:
```
var f = openFile() {
  work with f variable without ability to re-assign it.
} this will call dispose.
```
But what about returning a resource?

N - Options for writing a compiler:
1. Full hand-written compiler and parser and assembly generator and optimizer
2. Use LLVM tools
3. Fork an existing compiler (Go, Swift, C)
4. Use GCC tools
5. libjit
6. GNU Lightning
7. asmjit
dot: `func process(x:int)->int { return x+1 }`
Go: `func add(x int) int { return x + 1 }`
C: `func add(int x) { return x+1 }`
Swift: `func addTwoInts(a: Int)->Int { return a+1 }`
Problem with Go: receiver type, interfaces, const,
Another problem with fork: They are not written in C so it will add either another level of redirection or complexity.
I can use their parsing and code generation parts to interact with LLVM.
The only downside for LLVM is compilation speed. But still Go's compilation speed has been decreasing recently.
Let's go with LLVM.
What about the language? C or C++?
- asmjit: last commit May 2017, `a.mov(x86::eax, 1);`, 
- GNU lightning: provides only a low-level interface for assembling from a standardized RISC assembly language, It does not provide register allocation, data-flow or control-flow analysis, or optimization. `jit_addi(JIT_R0, JIT_R0, 1);`, last mail in list: 2016-09
 Libjit: `jit_value_t temp2 = jit_insn_add(function, temp1, z);`, last email in list: 2017-05, 
 myjit: `jit_addi(p, R(1), R(0), 1);` port of Lightning, last commit Mar 2015, has register allocator
 transpose to C and compile in-memory
JIT:
pro: more control, can do optimizations, more native
con: can be difficult to generate executable
TC:
pro: easier to write compiler, almost everything is already available
con: implementing some advanced features like green thread can be difficult because we have less control
-------------
myjit: C, Github, seems simpler (~10 files), 20K SLOC, last update 2015-03-15, `jit_addi(p, R(1), R(0), 1);`, has reg-allocator
libjit: last commit 2017-05-26, has dpas example, has more files (~50), has `/jit-elf-write.c`, 46K SLOC, said its not designed for AOT.
libgccjit: based on GCC, can output executable which is native without need any .so file

Y - if we adopt Rust's model (simplified) we won't need GC and exclusive resources won't be an exception.
Rust: There can only ever be one binding to a given resource
Resource = allocated memory space
Binding = variable or value name
Rust: If you pass a binding to a function, the function takes ownership of the resource
If we mix this with everything immutable maybe we can simplify it.
When we call a function, ownership is NOT moved to that function in dotLang. The caller is the owner of the data.
The only problem that we have is with ex-res because they are special. 
Exceptions regarding ex-res:
1. you cannot `file1 = file2`
2. you cannot share with another thread.
3. dispose automatically if not returned
3 can be stated as a general rule of the language. everything is disposed when function ends.
1 can be removed. you can do `=` and its fine as long as everything is within a thread.
2 can be enforced. if everything can be sent to other threads via channels, we can disable creating a channel of that type.
what about lambda capture?
if a lambda captures a file descriptor inside a same thread it's fine.
if another thread -> core functions will notice that.

N - Shall we ban `x=y` format assignments? why?
It is not very useful but banning it would add to the complexity.

N - Seems we should put more effort on defining scope and ban rebinding.
`let`
This will affect: `if, else, while, then, do, for, var, =`
`var` is very meaningless now. shall we replace it with def or let?
what about multi-assignment?
`var x,y = ${10,20}`?
`let x,y = ...`
`def` is a bit misleading and let is used in Fsharp, Ocaml, swift
other options: `const`, `final`, `readonly`
`let` `def` - def is easier to type.
Let's go with `def`.
`def x,y = ${1,20}`
`def p = ${1,20}`
`def p := ???`
but let makes more sense and more intuitive.
1. bindings are defined using `let`.
2. no assignment. no re-binding the same name inside a block.
3. loops are implemented using core functions.
4. if, then, else, switch? make them more functional?
5. closure can capture a binding.
6. exclusive resources are like a normal binding. you can pass them to other functions. if used from multiple threads, will throw error.

N - can we unify return in a function or lambda and evaluation of a block?
now that we cannot re-assign, a block is more like a lambda or anonymous function.
`||->{...}` a lambda without input
`{...}` a block
`||->{...}()` calling an anon-func, actually same as a block.

N - multiple stmt/exp in same line?
`let x = ${1,2}`
`let y = 1,2` ?
it makes things complicated.

Y - Clarify how a block can return and evaluate to something.
How to define a normal block:
`let x = { 5 } `
`let x = { process(1,2,3), 6 }`
```
x = if cond1 then {
  process(1,2,3)
  5
} else {
  radasd(Dsadsada)
  11
}
```

Y - will banning re-assignment help readability and simplicity?
pro ban: it will force dev to choose good names for new results of computations.
pro ban: rule for ban re-assign on closure use will be removed and simplified.
con ban: while loop becomes messy function call.
con ban: this forces user to write complex if/switch/... to get value of a variable. -> can we have a block-like notation where result of block evaluation will be assigned to variable? then it may make things easier to read and write.
complete immutability without rebinding, makes code safer in multi-threading cases and easier to refactor and more documented ans easy to read. on the other hand it bans using loops or while as a keyword.
this if happens will remove: `for, while, do, <-`
In Closure we have: "If a lambda captures a value in the parent function, that value cannot be re-assigned"
Erlang and elixir: "They simply don’t allow values in a certain memory location to change.
Variables aren't the immutable thing. The data they point to is the immutable thing. That's why changing a variable is referred to as rebinding.
"
variables are labels for values. 

Y - Shall we implement loop using functions? what about loop variables?
types of loop:
1. conditions: `while x > 0 do...`
2. counted `for x=0..10 do...`
3. iteration `for x <- arr1 ...`
we can implement 2 using 3.
so we just have two types:
conditional and iteration.
1. conditions: `while x > 0 do...`
2. iteration `for x <- arr1 ...`
2 can simply be done with lambdas. we will loose `do` and some other keywords and syntax will become a but cluttered. 
Which maybe we can add notations to make it more readable.
so we need to deal with while (loops with conditions):
`while x > 0 do ...`
we can say the loop has two lambdas: first predicate second body.
body returns an output which will be used for predicate.
`for, do, while` can be replace.
`switch` maybe.
`if, then, else` maybe.
side effect: assign and declaration will be combined together.
`func while[T](pred:func(T)->bool, body: func()->T, T)`
`while( ||->{ !eof(file) }, ||->{ print(readLine(file)) }, nothing)`
what about this?
```
var list: seq[func(x:int)]`
for i <- [1..100] do {
  list = append(list, ||->{print(i)})
}
for f <- list do f()
```
what will this code write? 
Elixir: "closures in functional languages capture values, not references"
maybe we can implement while loop with recursion on lambda:
```
|x:int|->{ print(x), if x>0 then call_self(x+1) }
```
the type of while where we check for number boundary can be implemented with a `map` on an array with that size but for large numbers this can be more efficient. but anyway, compiler can optimize map on a large array.
`map(|x:int|->print(x), [1..100000])`
`x = [1..1000000]`
compiler does not need to allocate 1m memory cells for this. because it will only be read.
maybe we can define a tail-recursion return statement. this will help implement while efficiently.
But why add a new keyword? just let developer know we have tail recursion. and he can write:
`return callme(1,2,3)`.
Because we allow for functions to have side-effect it makes sense to have `if ( x > 0 ) process()` without else. basically using if as an statement, not an expression.

N - how you write this without assignment?
```
result = (JSONObject) super.deserialize(writable);

Object optDlValue = result.opt("dl");

//Do not touch anything if for any reason we dont have a dl field
if (!(optDlValue instanceof JSONObject)) return result;

JSONObject dlValue = (JSONObject) optDlValue;
Object urlList = JSONObject.getNames(dlValue);

if (!(urlList instanceof String[])) return result;

for (String url : (String[]) urlList) {
    handleUrl(dlValue, dlValue, url);
}
```
```
result = deserialize(writeable)
dlPart = get(result, "dl")
if ( typeOf(dlPart) != @JSONObject ) return nothing
names = getNames(dlPart)
if ( typeOf(names) != @array[string] ) return nothing
result = process(names, |s: string|->handleUrl(s))
return result
```
```
return writeable . deserialize(_) . get(_, "dl") . getNames(_) . process(_, |s:string|->handleUrl(s))
```

N - can we have if without else? then if will not be expression.

N - Erlang:
A sequence of expressions is separated by commas:
Var = fun_call(),
Var2 = fun_call2(), Var3 = fun_call3(Param1, Param2)

Y - maybe we should remove `[]` syntax for array and map access and use just functions.

Y - how can we write a lambda inside itself?
If it has a name, it should be possible:
`ff = |x:int| -> { print(x), ff(x+1) }`

N - if `if` cannot come without else, maybe we should merge them.
likewise, switch must have `else`. to be checked.
```
y = switch ${x,y}
{
    ${1,2} -> 
}
```
what if switch does not have else?
```
y = switch x 
{
  1 -> 2,
  2 -> 3,
  3 -> 4,
}
```
if x is 10, what will be the value of y?
if y can accept nothing, then switch can be non-exhaustive.
`let y: maybe[int] = switch ...`
can we remove if, then, else?
`callSystem(100) if x>100`
let's keep them. 

Y - replace word `variable` with `binding`.

Y - Can we make switch more powerful? like for multiple items?
```
y = switch operation_result 
{
    1 or 5 or 9 -> "G",
    2 -> "H",
    3 -> "N",
    _ -> "A"
}
```
```
y = switch operation_result, int_or_float 
{
    1 or 5 or 9, x:int -> "G",
    2, y:float -> "H",
    3 -> "N",
    else -> "A"
}
```
```
y = switch operation_result, int_or_float 
{
    11, _ -> "R",
    1 or 5 or 9, x:int -> "G",
    _, y:float -> "H",
    3 -> "N",
    _ -> "A"
}
```
```
y = switch operation_result, int_or_float 
{
    11, _ -> "R",
    1 or 5 or 9, x:int -> "G",
    _, y:float -> "H",
    3 -> "N",
    _ -> "A"
}
```

N - sometimes it is really useful to bind behavior and data. like what we do for an array (suggsted above)
if it is a large array, just store the size and when asked for a specific element, calculate and return.
this is: type of `array[int]` when you call `[]` should not just do a memory lookup but should have some logic there.
maybe we can add a new type for it: `dynarray[int]`
No Makes things complex. User can define a `dynarray` type and use it in the code.

N - Define `IO` type and when a function returns something from io return it inside IO type.
`var x: IO[string] = readLine()`
`writeLine(x)`
`writeLine(IO{"Hello world"})`
`let x: IO[string] = readLine()`
`x()`
`let h:string = x.value`
No. We are not interested in writing pure functions.

N - Having `file_open` without close in the code is not good. 
Compiler is not supposed to do that.

N - Providing security like Kerberos
So user with credentials X can only call function f and g with arguments "A" and "B".
As an additional and separate component like Kerberos and Ranger
Which user can insert data in a table?
On the server side we can have a kerberos server accessible via rest api.
on the client side, a kerberos enabled app can ask server for each action.
This does not need to need any change on the language.

Y - https://medium.com/@greglo/descopes-a-missing-compiler-feature-b4a5fa0751c8
How to remove a binding out of scope?
`unlet`?
`dispose`? yes. we should be able to call dispose on everything and compiler checks and prevents access something after calling dispose.
So we won't have to have close_file and close-socket and...
only dispose

N - `A.b` can also be considered as a function (which definitely must be inlined).

N - First I need to check the language and make decisions.
1. compilation passes
2. memory model, heap, stack, pointer
3. function call system: by value, by reference, ...
4. how to represent different data types? union, map, array, ...
5. Is there a way to implement as much as possible inside the language?
6. What is the minimum required features that has to be implemented in the core compiler?
7. How am I going to parse the code and what is the data structure for that?
8. How to tokenize the source code?
9. How can I measure size of every variable? e.g. tuple, union, map, ...
- union is a pointer to structure which is tag+data where tag represents the data type.
- almost everything is allocated on stack except return data and things that are passed to a thread code. These data are either defined by their value or allocated on heap and use a pointer. Or maybe we can duplicate them inside caller code's stack.
- Each type will have it's unique number (result of `@Type`) assigned by the compiler.
- Each function's signature is transformed into a unique string containing name, input type and output type. And each function call is converted to a call to a unique function name based on type of the arguments.

N - `union` can also be implemented using a tuple with maybe[t] for each type + compiler and runtime helps.
`union[int, float, char]` ~ `{a: union[int, nothing], b: union[float, char], c: union[char, nothing]}`
but still we will need union. 
solution 1: define maybe as an extended primitive. then union can be implemented using maybe.
solution 2: just define union with normal types + tag field. compiler will handle to make sure only one of them is allocated.

Y - Remove `$` prefix for literals. What can be confusing?
array, map, tuple literals
`$[1,2,3]` `$[a,b,c]`
`$[1:"A", 2:"B", 3: "C"]` `$[x:y, z:t, u:v]`
tuple: `${100, 200}`
tuple type: `type pt := {x: int, y:int}`

Y - Can we replace `union` type with a `|` notation?
what about `union[Shape]`? We can use `|Shape|`?
`|` is easier to read and write.
`union[Shape]`
`Circle|Square|Rectangle|...`
`|.Shape|`
then what about this: `|.Shape|.Polygon|`
or: `Circle|.Shape|`?
This notation will be confusing when combined with polymorphism union.
`int|float|string`
`Shape` no
`let x: |Shape|`
`let x: array[|Shape|]`
`let x: Shape*`
`let x: $Shape`
`let x: ^Shape`
`let x: *.Shape`
`let x: array[*Shape]`
`let x: T | T.Shape`
`type AllShapes := *Shape`
`type AllShapes := |*Shape|`
`type AllShapes := union[Shape]`
`type AllShapes := |{Shape}|`
`|{Shape}|`
`|{T}|` where T is a named type can be used to indicate all tuples that embed that type.

N - core is supposed to have absolutely low level things that cannot be simply/easily defined in std.
std is supposed to have absolutely minimum needed tools to provide expressiveness needed to write software.
Everything else should be in external libraries (graph data structure, json parser, ...)

Y - Map can be implemented using a linked-list. and linked list is just a tuple.
shall we make map an extended primitive?
compiler only treats specially for map literals.
why map is a primitive but linked-list is not?
If everything is immutable, what is the difference between list and array?
we can say array has O(1) access and O(n) update.
list has O(n) access and O(lgn) update.
list is a mutable version of array.
We can have immutable linked-list if we just keep track of head and add to the head and with a singly-linked list.
We can have single-linked list, double-linked list, queue and other data structures.
`type List[T] := { head: T, tail: List[T] }`
map may be implemented using a linked-list behind the scene but because of the special behavior it expects, we consider it as an extended primitive data type.
list and dlist and queue and other data types can be easily implemented using existing features.
We could also define list as an extended primitive and build map on top of it.
I think we should consider map, list, queue ... just data structures that we have. The only difference is that in map, we can have literals: `["A":1, "B":2, "C":3, ...]` which we can simply make this available to any other data type which has set method. and `[1,2,3]` same.
So map is just an important data structure.
- bool, string and nothing are just plain data types which are also important. just explain them inside notes sections.

Y - Now that we use `|` for union, lambda expression becomes a bit confusing: 
`let adder = |x:int, y:int| -> x+y`
`let adder = (x:int, y:int) -> x+y`


Y - In order to simplify things, we should do as least-astonishment rule. Let local variables be mutable.
The fact that I cannot modify/edit a local variable is a bit of atonishment.
The fact that I cannot edit input argument is expected and normal because it belongs to elsewhere.
But we have the restriction about data race and closure capture and mutable shared state. also meaning of `let`.
Maybe we should revert to `var`???????????
Let's check them one by one. All of these issues become problem in the context of multiple threads.
Closure captures a local variable. It becomes a thread. Local variable is modified outside either by other closures or parent function. 
```
let x = 12
start_parallel () -> { process(x) }
```
A closure definitely cannot mutate captures variable.
This is a cast of simplicity vs. security. We can let closure capture variables which are mutable and accept the fact that we might end up with a mutable state which is shared with a thread (we have simplicity but loose security).
Solution 1: Closure can capture any variable, but they cannot be changed (Java says they must be effectively final, we say they cannot be modified and compiler can verify that). So compiler will give error is closure is capturing a local variable which is being modified after declaration.
This will also affect loop. Now that we can modify, why not have loops back?
If I call `process(myPoint)` and the function starts a new thread with myPoint and later I modify myPoint, it will also result in data race.
Java forcing effective final values to be captures, is not for race but for the way it handles those captures.
I am convinced that a shared mutable state can be problematic.
But not all of closures and function calls are going to be threads.
Let's permit everything but compiler will check for code that can cause problem.
But it will be hard to check. You may have a chain of function calls which end to a thread, reading variable X.
The mere fact that function/closure cannot change their input/captured variable will reduce likeliness of data race.
Because there is only one place which is owner of the data and can change the data.
I think we can accept this (and make developer responsible to handle this case), and in return make language easier to work with.
Proposal:
1. Use `var` instead of `let` and call it variable instead of binding.
2. Functions can modify local variables.
3. Notation to modify array, map and tuple changes.
4. We will have `for, while, do` keywords back. `<-`
Modify array and map: `x[0] = 10, a["A"] = 10`

N - Can't a closure modify variables of parent function?
No. It is againt transparency. We may return the closure and it can have all sorts of side effects.

N - functions like copy which order is important can be called by mistake.
Can we make it more clear? without using named argument?
Maybe using named types?
`Copy(From{x}, To{y})`
`check(Str{x}, Pattern{y})`
`move(Source{x}, Target{x})`
`contains(Str{x}, Char{y})`
`checkGreaterThan(Source{x}, Boundary{y})`
In this case we are not relying on argument names but on their types.
These functions are not overloaded much. Why not use a tuple?
`func copy(x:{from: string, to: string}) { ... }`
`copy({.from=A, .to=B})`
`copy({.to=B, .from=A})`

Y - Add `++` and `--` as statements.

N - Are map and array still not primitive types?

N - Just like we define type alias, shall we have function alias?
`type MyInt = int`
`func myProcess(x: int, y:int) = p2`
`func myProcess(x: int, y:int) = p2(y,x)`
But there is no advanrage to this.

N - map and almost everything else can be implemented using normal types and array.
can array also be implemented using normal features?
we have special behavior for array and map: indexing and literals.
What about other types?
Can I use `[1,2,3]` literal for another type? How?
Remember that functions cannot modify their input.
`var x = [1, 2, 3]` what should be type of x? array of int. so this type of literal can only be used for array not any other type. because type inference will have problems.
so we can and will have a queue data type but it will be initialized using an array or map + a function.
`var x: queu[int] = newQueue([1, 2, 3])`
it doesn't matter it we can implement array using language features because it is so basic.


N - Support check  loop condition at the end
`while x>0 loop print(x)`
`loop print(x) while x>0`
`while x>0 loop { ... }`
`loop { ... } while condition`

Y - The control structure in the language is a bit too complicated now:
`for, do, while, if, then, else, break, continue?, switch, ...`
Can we simplify it?
we can write these using `switch` but as we don't have macros, we either need to define them as new keywords or functions.
Can we have inline functions in place of a macro? 
`#define if(c,t,f) switch(c) true -> t, false -> f`
`func if(cond: func()->bool, tr, fa) ...`
`... if ( x>0, print(x), return false)`
I should decide how revolutionary this should be. If I want something revolutionary, this can result in a new notation. but if I don't I might stick with normal and more intuitive keywords.
func with inline marker can accept an input which does not have a type and will simply be replaced.
`func! if(con, tr, fa) ...`
```
if ( x>0, {
  print(x)
  process(x,y)
}, {
x++
return x
})
```
maybe we can add only switch and goto and implement other control structure.
or `goto` and `if`. but we cannot implement switch with if, because switch has an unknonwn number of inputs.
`switch` is more general than others.
how can we handle untyped arguments? like the condition in if.
`func! if(cond: bool, tr: func()->T, fa: func()->T)->T`
`if(()->x>0, ..., ...)`
we can keep this syntax and avoid untyped input argument (which is against language rules and typing system), but we need to simplift `()->x>0`.
We can say that `{...}` can be considered as a lambda with no input. but then a lambda is not supposed to change parent variables. but a code-block inside a function can do that.
q: How can we simplify definition of a lambda without input? Like `()->x>0 and y==1`
how can we implement while loop?
maybe we can implement everything using switch and recursive functions. But if we use inline code, then being recursive can be confusing and expensive in runtime and output size.
proposal: Why should we deal with macro? Compiler should deal with it. we just write functions and the smart compiler detects what needs to be inlined. Of course recursive function cannot be inlines especially if rec. condition is dynamic. We just write a normal function. `if`, `while`, ...
Suppose that we have switch and goto and labels.
`func while(cond: func(T)->bool, body: func()->T) ...`
`while((x:int)->{x>0}, ()->{.... x })`
`/x>0/`
`/_>0/`
we can define shortcut for lambda expression: `/.../`
`<...>`
`\...\`
`$...$`
`$x>0$`
`{{x>0}}`
`{{_>0}}`
we can implement everything using if, goto or switch, goto.
using if, goto has the advantage that I can also use if in normal code. 
`print(t) if t<0`
`if(r==0) { ... }`
`while({{_>0}}, {{.... x }})`.
```
func while(cond: func(T)->bool, body: func()->T, x: T)
{
  var indicator = cond(x)
  start:
  if ( indicator == false ) return
  indicator = body()
  goto start
}
```
the more revolutionaty, the more difficult (or at least unintuitive) code writing will be. You will need to do according to some rules. We can define basic commands based on a mapping from assembly language. Because of that, if and goto are normal choices.
- we can implement `continue` using return inside body block. 
- we can also have `break` with a different output type for body `T | BreakIndicator`.
- we can make switch single argument and make it's choices, lambdas.
so all we will need is `if`, `goto` and lambdas + `{{}}` notation.
con: we cannot return somethnig from within while. This is possible with a specific notation.
`func while(cond: func(T)->bool, body: func()->T|Return[X]|BreakIndicator, x: T)`
still we cannot return from inside `while` function something which forces parent function to return.
so:
1. Add `{{}}` shortcut notation for lambda.
2. Add `goto` keyword.
3. Make `if` general (it can be used as prefix or suffix).
4. Make every other thing, a function: `for, while, switch, ...`
`func switch(x:T|S, (i:T)->int, (i:S)->int)`
or we can use a map literal with key = type and value = lambda. but value type cannot be changing.
I have been switching between "everything is a function" and "these should be keyword" notation multiple times.
Each one has it's pro and con.
everything func: 
 pro: simpler, easier to write compiler, 
 con: notation will be a bit more restricted (e.g. return is not possible)
keywords:
 pro: easier to read
 con: language spec will be longer.
we want a language which is both high-level and low-level at the same time.

Y - If we want to make `if` an expression maybe we should also add else. 
Or use this notation:
`x=t>0 and print(t)`
`y=t<0 or print("not found")`
`var x = if(correct) 10` if not correct, x will be nothing? this is a bit confusing because x does not have a type.
Simple: no else, no nothing.
We already have `and` and `or`. Maybe we can replace `if` with them.
so we will only have `jump` + operators `and, or, not, ...`
Also, and and or make expressions.
`print(x) if x>0`
`(x>0) and print(x)`
but then we have to support non-booleans for and/or.
`(x>0) and print(x) or print("failed")`
if condition is true, short circuit rule, will cause print to be executed.
if it is false, after `and` won't be executed.
if condition is false, short circuit rule, will cause print-failed to be executed.
`true and A or B` will invoke A
`false and A or B` will invoke B
what about this?
let's define `and` and `or` like this:
on their first (left) argument they must have a boolean but the right side argument can be non-boolean.
`true and X` will evaluate to X.
`false and X` will evaluate to false.
`true or X` will evaluate to true.
`false or X` will evaluate to X.
`condition and true_action or false_action`
how can this be non-boolean expression? if it has and/or 
`x = condition and true_expression or false_expression`
left of or operator is not bool. NO. if left side evaluates to non-bool, means, condition is true. 
`x = condition and nothing or 1`
This should be clarified more and formalized with a clear definition. 
Then we can replace if and only use `and` and `or`.
Perl uses or in this way.
What if they are not expressions this way?
So and/or as expression, only accept booleans.
But as statements, they accept anything.
`X and Y`
What does `X and Y and Z or Y` mean? also `X and Y or Z or T or V`?
It is confusing. developer must use paren. otherwise they will be evaluated left-to-right.
`b1 and b2 and act1 or act2`
`(b1 and b2 and act1) or act2`
`A or act2` is A is false, act2 is executed. if A is true, no act2.
`(b1 and b2 and act1) or act2`
`if(b1 and b2) act1 else act2`
This is confusing (precedense) and complex (paren everywhere).
`... if (C)`
`if (C) ...`
if can be prefix or suffix of simple statement.
why not suffix for code block?
`{....} if x>0` 
it make code un-readable if condition comes at the end of the block.

N - How can we handle the requirement for having unique names for function and types?
In a large project this may cause problems.

Y - Shall we use a notation for union type labels? Instead of using strange "Label types"?
Then what will happen to the type of the union?
`var x: bool = $true`
`type(x) == @bool`
`if ( x == $true )`
The `typeOf` function exaplained in union section is confusing. It seems to return type of it's input but type of it is a union of int and float. So returning current data inside it is confusing.
We should only rely on pattern matching and switch.
```
func switch(x: T|U, t_handler: func(T)->S, u_handler:func(U)->S)->S {
  var t, has_t = T{x}
  var u, has_u = U{x}
  if ( has_t ) return t_handler(x)
  if ( has_u ) return u_handler(x)
}
```
Can we have a general switch function? For any number of cases in a union?
Maybe we can handle it via recursion.

Y - 
`var result = [true: {...}, false: {...}][condition]()`
`var result = if ( condition ) {...} else {...}`
we can remove if and else and just use map literals.
but how can we have loops then?
`jump [true: label1, false: label2][condition]`
problem is labels are treated like something very different.
If we can assume they are integer numbers representing places in the code, we can treat them like integers.
prefix with `@`?
we have `$` for union labels, `@` for type-id and `?` for labels.
`@` which is read `at` makes more sense for labels.
`@PPP` defines a integer label with the same name with value an integer. So you can store `@PPP` in a variable.
What if I pass `@PPP` to another function and jump to it? it should not be possible.
we can have a core function to return current execution position as an integer.
`var x: int = label()`
later we can jump to this label: `jump LL`
The `label` function returns a named type: `type Label := int`. Compiler will issue error if you send or receive this type from/to a function.
So you can simply store this in a hash or anywhere else.
Proposal:
1. Remove `if/else` an replace it with a map.
2. new type `type Label := int`
3. core function `func getLabel() -> Label`
4. statement `jump lbl` (we can only allow it in core functions)
5. we can store labels in a variable or map or ...
6. `jump [true: lbl1, false: lbl2][condition]`

Y - we have two prefixes: `@` for getting type. `$` for union labels.
Can we remove or simplify them?
`@` is very limited. I think we can remove it.
`$` is needed for clarity only. Maybe we can remove it and make some easy and basic assunptions.\
or we can say, all capital names are union labels.
Why do we need `@`? to investigate type inside union. but we can use functions:
`if ( internalType(int_or_float) == typeOf[int]() )`
`func typeOf[T]()->int`
proposal:
1. remove `$`
2. union can have type or capital letter identifiers as flag labels
3. we can call a function or lambda which accepts an int with `int|string` if we are sure that the variable contains int.
so, we need `@` operator for simplifying creation of maps for pattern matching. 
but maybe we can get rid of `var t, found = int{int_or_float}` notation?
but this is useful for maps. and arrays. let's keep it.

Y - How can we implement pattern matching with map and jump and ...?
use core functions.
`var real_type: int = internalType(x)`
```
y = switch int_or_float_or_string
{
    g:int -> 1+g,
    s:string -> 10,
    _ -> "X"
}
```
```
y = switch(int_or_float_or_string, [@int: {{1+_}}, @string: {{10}}], {{ "X" }})
func switch(v: S|T|U, mp: map[int, func()->X], else: func()->X)->X {
  var ff, found = mp[xType(v)]
  return [false: else(), true: ff(v)]
  //instead of
  return 1 if A
  return 2
  //we write
  return [true: 1, false: 2][A]
}
```
can we somehow make this more general? a union of any type?
maybe define a general function with 5 union cases, and just invoke it if input has less than 5 cases.

Y - How to define a pattern matching with typed input?
`func switch(v: S|T|U, mp: map[int, func()->X], else: func()->X)->X { ... }`
the `mp` input contains lambdas which don't have any input. I want them to accept an input of type specified by map key.
But compiler has no way of checking types. Because map key is a variable.
`var y:int = switch(int_or_float_or_string, [@int: (x:int)->1+x, @string: (s:string)->10], ()->100)`
`func switch(v: S|T|U, mp: map[int, func(T)->X|func(S)->X|func(U)->X], else: func()->X)->X { ... }`
```
func switch(v: S|T|U, mp: map[int, func(T)->X|func(S)->X|func(U)->X], else: func()->X)->X {
  var ff, found = mp[xType(v)]
  return [false: else(), true: ff(v)][found]
}
```

Y - `func process(x:int|float|string)`
`process(int_or_float)`
is this valid?

N - How can I write this?
`return if failed`
`...`
`return [true: nothing, false: ??? ][failed]`
what about this?
`return [failed: nothing][true]`
if failed, it is `return nothing`.
if failed is false, it will also return nothing.
```
jump([true: x][failed])
return
x = getLabel()
```
`jump` function does nothing if it's input is nothing.

Y - How can we do forward jump?
```
jump(x)
...
x = getLabel()
```
This contradicts with all rules. And we are doing this only to treat labels as numbers.
can't we just use `:` notation to define a label and `jump` function to jump to a label and store labels inside a map.
```
var x: Label
jump(x)
...
x = getLabel()
asdsdasda
```
This storing labels inside map is only for a jump.
mayeb we can have this:
`func jump(cond: bool, true_label: int, false_label: int)`
`func jump(cond: bool, true_label: int)`
`func jump(label: int|nothing)`
It's a bit confusing.
We should be looking for readability and minimalism.
what if I re-assign a label variable?
It is not correct to treat them like variables.
Maybe we should not be storing them in a map in the first place.
But then it does not make sense for `jump` to be a function.
`jump label_1`
but if we don't treat them like normal variables, we cannot use things like label or nothing for jump.
`jump label1`
`return if failed`
the current mechanism with label and map is good for expressions but what about statements?
`[true: return, false: nothing][failed]` NONONO
we can say if expression results in nothing, statement won't be executed.
`return [true: nothing][failed]` if failed, return nothing.
**if map access is used with statement and key is not found, statement won't be executed.**
But how can we differentiate between a nothing value and a missing value? return 1.
Then, how to return `nothing`?

Y - Maybe we can replace jump and label with some kind of notaion to repeat a map check.
`while ( x > 0 ) print(x), x--`
`x := [true: (x:int)-> {print(x), return x-1}][x>0]`
`A := ...` repeat assignment until A becomes nothing.
We can remove jump and label and forward jump and label type and map with labels ...

Y - how can we use this in the case for statements?
e.g. `return if failed`
`return [true: nothing][failed]`
we can detect whether map contains a key or not.
so: `statement [...][...]` will run statement if map contains the given key. in this case, the value of the map does not matter because statement does not have any input.
`return [true:true][failed]`
`return [true:][failed]`

N - This is a minimal solution, but not very much readable. Maybe we can add a shortcut or a notation or operator.
e.g. `[[A, B]]` shortcut for `[[true:A, false: B]]`

N - map always returns `T|nothing`. Doesn't it affect our routing and conditionals and loops?

N - A way to define multiple statement in the same line, for lambdas.

Y - simplify `{{...}}`?
remove it.

Y - Let's say we can write: 
`var x:int, found: bool = maybe_int`.
we can do this for every union type:
`var x:string, found: bool = int_or_string_or_float`

Y - `return [true:][failed]`
This is confusing. Everything is according to a map fetch. 
Only `:=` adds a little complexity (which also removed label and goto).
`return [true:nothing][failed]` 
Maybe we should follow the advice that a function must only have one return statement.
No. Just add more explanations and make it only for return.

Y - I think we can also eliminate `return` keyword.
The last expression inside the function will determine it's result.
```
func process(x: in) {
  print(x)
  x+1
}
```
pro: no need for exception for return with map with missing key.
con: code may become complex.
we can write `x=nothing` and update it if needed.
then at the end: `x`.
we already had this with `func process(x:int)->x+1`
`func myFunc9(x:int) -> {int} {12}`
does this function return 12 in a code block or returns a tuple literal?
Maybe we should use `$` prefix for tuple literals.
`func myFunc9(x:int) -> {12}` this one is really confusing. We don't know type of return.
`func myFunc9(x:int) -> 12`
`func myFunc9(x:int) -> { print(10), 12 }`
`func myFunc9(x:int) -> {12}`
At least it is confusing.
`${...}`
Let's use `$`

Y - `:=` notation is not very intuitive and does not imply repeatition.
`x := [true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing][x>0](x)`
`x = [true: (g:int)-> {print(g), g-1}, false: (g:int)-> nothing][x>0](x)`
- we can have multiple variables on the left side and loop will finish when all of them are nothing.
we need something which means: continue evaluation until result is nothing.
`lbl: x = [true: (g:int)-> {print(g), g-1}, false: (g:int)-> nothing][x>0](x)`
`jump [nothing:lbl](x)`
adding jump and labels makes things more complicated (although more flexible and dangerous too).
`&{x = [true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing][x>0](x)}`
`&{...}` means evaluate block until it is nothing. then continue to the next statement.
`x=1` evaluates to 1.
`loop {x = [true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing][x>0](x)}`

N - Can we add a keyword which is simple like `loop`? but for if. NO
`loop { ... }`

Y - How can we implement map?
`var x:array[int] = loop { y }`
```
var myOutput
var iter
loop 
{
    data, iter = [
        true: (x:iterator) -> ${nothing, nothing}, 
        false: (x: iteartor)->${getData(x), next(x)}
    ][eof(iter)](iter) 
    append(myOutput, data)}
```

N - assign if it is not nothing.
`x = if y` if y is not nothing, assign it to x.
it is not straight forward to implement this behavior using functions.
but the notation is confusing.
`if y then x=y`
conditional assignment:
`x := y` y will be assigned to x if it is not nothing.
if y is nothing, x won't be changed.
Is this useful?
```
var y:int = switch(int_or_float_or_string, [@int: (x:int)->1+x, @string: (s:string)->10], ()->100)
...
func switch(v: S|T|U, mp: map[int, func(T)->X|func(S)->X|func(U)->X], else: func()->X)->X {
  var ff, found = mp[xType(v)]
  retVal := ff(v) //run if ff is not nothing?
  [false: else(), true: ff(v)][found]
}
```
alternative:
`data, something = y`
`x = [true: data, false: x][something]`

N - How do you write this now?
```
stringed = switch ( int_or_float ) 
{
    x:int -> ["int" , toString(1+x)],
    y:float -> "is_float",
    else: "Not_int"
}
```
```
stringed = switch(int_or_float, [@int, (x:int)->["int", toString(1+x)], (y:float)-> "is_float"...
```

Y - Reading this notation is a bit difficult. Can we make it more readable?
`x = [true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing][x>0](x)`
`x = [x>0][true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing](x)`
This is more readable but we are using `[]` for many different purposes.
Define map literal, array literal, query map and query array.
Btw we can also use array for conditionals.
`[T]` generics
`[1,2,3]` array literal
`[true:1, false: 2]` map literal
`map[4]` map query
`arr[1]` array query
we can use functions. `get` + `$` for map and array literals.
`x = get(x>0, $[true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing])(x)`
`x = [x>0]$[true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing](x)`
`map$"A"`
`map[1]`
`[1]map`

Y - Stil this does not seem correct.
```
var y:int = switch(int_or_float_or_string, $[@int: (x:int)->1+x, @string: (s:string)->10], ()->100)
...
type FF[T,X] := func(T)->X
func switch[S,T,U,X](v: S|T|U, mp: map[int, FF[S,X]|FF[T,X]||FF[U,X]], else: func()->X)->X {
  var func_to_call: maybe[FF[S,X]|FF[T,X]||FF[U,X]] = [@v]$[@S: mp[@S], @T: mp[@T], @U: mp[@U]]
  var found = func_to_call != nothing
  //reading from map, returns a maybe
  var result = [found]$[true: func_to_call(v), false: else()]
  
  result
}
```
problem is nesting this structure is extremely hard to read.
jump can solve it but it adds problm with forward labels and using labels as data.

Y - Extend `@` for unions too. acts like `xType`.

Y - There is a surprise here.
when you cast union to a type, you get two output! an additional flag.
when you read from map or array you get a maybe[T]
Let's make them uniform. When you cast union to some type you get maybe[T] too.
You can check for nothing with `==` and `!=`

Y - if casting union to int returns maybe, how can I extract the integer data inside a union?
`${int_value, done} = int{my_union}`
`${value, found} = my_map[1]`
`${value, found} = my_array[100]`

? - can we remove loop?
`loop {x = [x>0]$[true: (x:int)-> {print(x), x-1}, false: (x:int)-> nothing](x)}`
It is a bit hard to read. and `nothing` is a special case.
`var x = 100`
`//x!=0// x = [x>0]$[true: (x:int)-> {print(x), x-1}](x)` run this statement or block as long as this condition holds.
`/x!=0/ x++` run this block or statement if this condition holds.
NO. any kind of prefix will be confusing when mixed with statement or expression or assignment.
It will reduce orthogonality. If with map, is completely orthogonal with other concepts. Actually it is nothing new.
Now, we want to have a loop. internally, loop can be also modelled as reading from a map and processing the result.
1. x = read from map
2. y = process x
3. if predicate(y) goto step 1
problem is with goto.
`x=[k]$[1: ..., 2: ...]`
`y = x>0`
`x=[x>0]$[true: (g:int)->g-1, false: (g:int)->nothing](x)`
This is wrong! invoking result of map will return maybe[int] while left side is expected to be int.
We want to implement this:
`while ( x > 0 ) print(x), x--`
`x, found = [x>0]$[true: (g:int)-> { print(g), x-- }]`
we want to repeat while a condition is held.
`x, found = [x>0]$[true: (g:int)-> { print(g), x-- }](x)`
prefix makes code more readable but less orthogonal.
This definitely involes an assignment. a restricted and minimal way to model loop criteria is a boolean variable. Other things can be simulated with a boolean variable.
`label1: x, found = [x>0]$[true: (g:int)-> { print(g), x-- }](x)`
`jump label1, found`
jump is very general and powerful.
`x, found = [x>0]$[true: (g:int)-> { print(g), x-- }](x)`
`loop found` repeat previous command if found is true.
How can we do loop condition check before the actual command?




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
