# Requests for Enhancements

X - modules and versioning
we can ask user to pin a specific version in their imports if they want deterministic builds
we need reproducible builds. meaning if I need `v1.5.*` of a dependency, it should compile exactly the same on my machine than any other machine (CI or team mate or ...)
now, this can translate to `1.5.1` or `1.5.2` depending on some factors. so we need to lock that.
one way compatible with current method is to act like this:
```
# autogen(/https/github.com/uber/web/@v1.9+.*/request/parser)
path=""
T = import(path)
```
when compiler compiles above for the first time it writes proper value for path and later will re-use it, until you run `dot update deps`
```
#autogen(/https/github.com/uber/web/@v1.9+.*/request/parser)
path="/https/github.com/uber/web/@v1.9.16/request/parser" 
T = import(path)
```
so this `@1+.*` syntax is only valid in autogen in comments. You cannot actually use it in import path.
If you want to import a module you must either:
1. specify an exact version
2. use autogen as above and let compiler calculate a fixed version.
3. the result will be inserted by the compiler as the value for binding after autogen.
4. the value will remain there until developer does a dep-refresh command to update them.
how can we have multiple modules/packages in one github repo?
These questions are not really needed for initial lang design and compiler impl.

X - Our goal is to minimize number of stuff the developer needs to keep in their head

X - Not only dot is easy for users, it should also be easy for developers.
so they should not need a lot to set up a dev env.

X - Use protothreads for lightweight threads implementation

X - Everything is a file
Use this for stdio, sockets, ... 
inspire from linux Kernel

X - We may need a function in core like `createStream` to create a stream with custom logic.
or to read from file or network

X - For future: support shortcut to define lambda
when function result is an expression and input/output types can be inferred from context:
instead of `fn(x:int, y:int -> int) { x+y }`
write: `x,y -> x+y`
or: `fn(x,y -> x+y)`

X - Core needs to have support for these
- serialisation deserialisation

N - Can I define a generic function that accepts type T and returns integer number x?
```
CodeFunc = fn(T: type, x: T,ret: int -> int) {
  ret
}
code = [ CodeFunc!(Circle, my_shape, 1), CodeFunc!(Squre, my_shape, 2) ]
```

Y - Update how to section about polymorphism
original ask: Type classes or some other similar method to have some kind of flexibility in function call dispatch
what are the alternatives?
- interface in Go
- trait
- mixin
- type class
- generics with `?` wildcard?
we want the simplest and least surprising solution which is minimal, does not need developer to memorize stuff and is not complicated.
objectives:
- Provide Liskov substitution principle but without subtyping because it makes things complicated
- no function overloading
- it should be flexible: no attachment between data and behavior
what are some real world examples of this?
- support we have a drawing application. we have lots of shapes each with it's own draw.
now I want to load a drawing file. which basically is a list of shapes.
how can I draw the whole scene?
```
drawCircle = fn...
drawSquare = fn...
drawTriangle = fn...

Shape = Circle | Square | Triangle
shape_sequence = loadFile()
```
Now, there is no easy way to call specific functions based on type inside shape.
I can write my own dispatcher:
```
superDraw = fn(s: Shape->nothing) {
  draw = [Circle: drawCircle, Square: drawSquare, Triangle: drawTriangle]
  drawFunction = draw[type(s)] #get compile time type of "s"
  drawFunction(s)
}
```
problems:
1. type of `draw` map on above function is really confusing and difficult to get.
2. how can I invoke drawFunction? I don't know its input.
```
DrawFunction = fn(T: type -> type) { 
  fn(shape:T->nothing)
}
```
we can define a generic type as above. and define all draw functions based on that:
```
drawCircle: DrawFunction(Circle) = fn...
drawSquare: DrawFunction(Square) = fn...
drawTriangle: DrawFunction(Triangle) = fn...
```
then type of:
`draw = [Circle: drawCircle, Square: drawSquare, Triangle: drawTriangle]`
draw will be map of type, to `DrawFunction(Square)|DrawFunction(Triangle)|...`.
still confusing.
we can say, type of draw, is `[type:fn(?->nothing)]`?
this is clearly a dependent type. a map where value is of type which depends on key.
but it is a lot. we want to simplify it.
we also want to put developer in control. so not a lot of hidden automatical behind the scene stuff.
maybe this can be solved via a case function for unions.
```
superDraw = fn(s: Shape->nothing) {
  selectCase(type(s), 
    [Circle: drawCircle, Square: drawSquare, Triangle: drawTriangle])
}
```
but again, we don't know type of the seq we are passing.
also, what if function needs extra inputs? this will just make things more complicated.
we really need a function to call. rather that a function to call our function.
can we use closure? excluding circle, triangle, ... all these functions look the same.
so we can say, we have a map where key is type, value is of type `fn(Canvas, float->nothing)`. 
so all keys have the same type. we just find and invoke.
now, this solves second problem and also first one (because this map has now a proper type).
but how can we build values?
```
superDraw = fn(s: Shape, c: Canvas, f: float->nothing) {
  draw = [Circle: drawCircle(c,_,_), Square: drawSquare(c,_,_), Triangle: drawTriangle(c,_,_)]
  drawFunction = draw[type(s)] #get compile time type of "s"
  drawFunction(c, f)
}
```
above works fine except that we now have a new way to create a lambda:
`myFunction(shape, _,_)` where shape is a unin.
I think this is the least conflicting and disruptive way we can do that.
- creating lambda based on a function which accepts type T, passing a union value of type T|S|U|..., will give you nothing if types don't match. or the function.
```
x = getShape()
drawCircle(x, _, _) is nothing if x is not a circle
drawCircle(x, _, _) gives you an actual function if runtime type of x is what drawCircle expects.
```
maybe we should make it more explicit.
```
x = getShape()
^drawCircle(x, _, _) is nothing if x is not a circle
^drawCircle(x, _, _) gives you an actual function if runtime type of x is what drawCircle expects.
```
so, if function accepts `T|Y` and internal type of the binding matches, it's fine.
if not , nothing.
so, this should be allowed to be used on any function, even those that don't support unions.
```
x = getShape()
drawCircle?(x, _, _) is nothing if x is not a circle
drawCircle?(x, _, _) gives you an actual function if runtime type of x is what drawCircle expects.
```
so, `lambda?(.....)` will give you nothing if what you are passing, is not as expected. it is like "try to call" or "try to create a lambda".
so, `addIntegers?("A","B")` will give you nothing.
which is confusing.
maybe we should only allow this with lambda creation. but this means a new restriction.
definitions should be as general as possible.
so `myFunction?(...)` means try to call this function. or try to create a lambda with these inputs.
so, if you pass a type which is "completely" wrong, there will be a compiler error.
but if you pass a type that "may" be compatible at runtime, then at runtime you get nothing or actual function.
```
adder = fn(x:int, y:int -> int) {...}
adder?("A","B") #compiler error
x = getMaybeInt()
z = adder?(x, y) #if x is nothing, this will evaluate to nothing, otherwise will call adder and give you the result
#above is same as:
if type(x) == int: z = adder(int(x),y)
else: z = nothing
```
also:
```
Shape = Circle | Square
Canvas = SolidCanvas | EmptyCanvas
drawCircle = fn(x: Circle, c: SolidCanvas -> ...
r = drawCircle?(my_shape, my_canvas) #if my_shape is a circle AND my_canvas is a SolidCanvas, call will be made
if type(my_shape) == Circle && type(my_canvas) == SolidCanvas: r = drawCircle(Circle(my_shape), SolidCanvas(my_canvas))
else: r = nothing
```
we can even write:
`result = drawCircle?(my_shape) // drawSquare?(my_shape) // drawTriangle?(my_shape)`
or:
`draw = drawMap[type(my_shape)]`
**Proposal**
1. We inroduce a new way to call a function: `?` which is called "checked-call".
2. If you checked-call a function by passing some arguments, it those arguments' type match with function input types, call will be made. otherwise `nothing` will be returned.
3. Checked calling a function with wrong input type will result in a compile time error.
4. Checked calling a function which accepts type T with a union binding as input, will be evaluated at runtime. If correct type is inside the binding, call will be made. Otherwise, `nothing` will be result of the expression.
Example:
`Shape = Circle | Square | Triangle`
`my_shape = createShape(...)`
`result = drawCircle?(my_shape) // drawSquare?(my_shape) // drawTriangle?(my_shape)`
this will help solve the problem of polymorphism in a less disruptive way.
still does not replace interface, trait or type classes.
it can be used for a switch/case/match based on union type:
```
code = switch([ fn(x: Circle->int){1}?(my_shape), fn(x: Square->int){2}?(my_shape) ]);
```
in above code, code will be 1 if we have a circle, 2 if we have a Square.
input to switch is a sequence of `int|nothing`s.
`?` is for IF. 
`result = drawCircle!(my_shape) // drawSquare!(my_shape) // drawTriangle!(my_shape)`
`result = drawCircle^(my_shape) // drawSquare^(my_shape) // drawTriangle^(my_shape)`
`result = drawCircle~(my_shape) // drawSquare~(my_shape) // drawTriangle~(my_shape)`
`result = drawCircle$(my_shape) // drawSquare$(my_shape) // drawTriangle$(my_shape)`
`code = [ fn(x: Circle->int){1}!(my_shape), fn(x: Square->int){2}!(my_shape) ]`
So, what does this mean: `drawCircle!`? does it have a meaning?
it has no specific meaning. `!` is used when you call a function or create a lambda.
but `drawCircle` IS a lambda. So, `drawCircle!` gives you a new lambda which when called will return nothing or make the call? no. this is too confusing
we want a new notation to "call" a function or create a lambda.
but when I write `drawCircle!(my_shape, _, _)` I do create a lambda. 
but `!` without passing any parameter just makes no sense.
q2: can I do this: `drawCircle!(my_shape,_,_)!(my_canvas,_)(1.1)`?
this should be fine. `drawCircle!(my_shape,_,_)` will give you a lambda which needs two other arguments.
q3: what is type of `drawCircle!(my_shape, _, _)`? if output of drawCircle function is int, type of this is a function with output of `int|nothing`.
so, `drawCircle!` is a function which can accept a circle and two other inputs, and if didn't match, will return nothing. 
confusing!
maybe we should just embed it in the concept of a function call. so it applies everywhere.
`Shape = Circle | Square | Triangle`
`my_shape = createShape(...)`
`drawCircle = fn(x: Circle->int) {...}`
`result = drawCircle(my_shape) // drawSquare(my_shape) // drawTriangle(my_shape)`
how about this?
`drawCircle = fn(x: Shape->int|nothing) { if typeof(x) != Circle return nothing else ...}`
it is possible but not very clean and also if we have more than one union input, becomes messy. also we loose advantages of static typing.
`result = drawCircle(my_shape) // drawSquare(my_shape) // drawTriangle(my_shape)`
what about this?
`drawCircle = fn(x: Circle|nothing->int|nothing) {...}`
`result = drawCircle(Circle|nothing(my_shape)) // drawSquare(Square|nothing(my_shape)) // drawTriangle(Triangle|nothing(my_shape))`
it needs a bit more code, but is more flexible. and no special magic by compiler/runtime.
also we can help to reduce boilerplate:
`drawCircle = fn(x: Circle|nothing->int|nothing) { checkNothing(x)@{nothing} #if nothing is passed, return nothing...}`
`drawSquare = fn(x: Square|nothing->int|nothing) {...}`
`drawTriangle = fn(x: Triangle|nothing->int|nothing) {...}`
`maybeCast = fn(x: T, S: type, T: type -> S|nothing) { (S|nothing)(x) }`
`result = drawCircle(maybeCast(my_shape, Circle)) // drawSquare(maybeCast(my_shape, Square)) // drawTriangle(maybeCast(my_shape, Triangle))`
so:
1. no need to change anything or add any new notation. just use existing tools: casting, error checking
2. in function side, we allow for `nothing` instead of actual type and handle that
3. in casller side, we try to cast union binding to the actual type. if not match, then `nothing`
4. we can now, modify this to return something else, if we need to.
**Proposal**
1. No change to language, notations or rules.
2. An example of polymorphism by using type casting and error handling:
`drawCircle = fn(x: Circle|nothing->int|nothing) { checkNothing(x)@{nothing} #if nothing is passed, return nothing...}`
`drawSquare = fn(x: Square|nothing->int|nothing) {...}`
`drawTriangle = fn(x: Triangle|nothing->int|nothing) {...}`
`maybeCast = fn(x: T, S: type, T: type -> S|nothing) { (S|nothing)(x) }`
`result = drawCircle(maybeCast(my_shape, Circle)) // drawSquare(maybeCast(my_shape, Square)) // drawTriangle(maybeCast(my_shape, Triangle))`
```
superDraw = fn(s: Shape, c: Canvas, f: float->nothing) {
  #here key is type, and value is a lambda which takes a canvas and a float
  draw = [Circle: drawCircle(maybeCast(s, Circle),_,_), Square: drawSquare(maybeCast(s, Square),_,_), Triangle: drawTriangle(maybeCast(s, Triangle),_,_)]
  drawFunction = draw[type(s)] #get compile time type of "s"
  drawFunction(c, f)
}
#or if we want to make it more efficient:
superDraw = fn(s: Shape, c: Canvas, f: float->nothing) {
  #here key is type, and value is a lambda which takes a canvas and a float
  draw = [Circle: fn{drawCircle(maybeCast(s, Circle),_,_)}, Square: fn{drawSquare(maybeCast(s, Square),_,_)}, Triangle: fn{drawTriangle(maybeCast(s, Triangle),_,_)}]
  drawFunction = draw[type(s)]() #get compile time type of "s"
  drawFunction(c, f)
}
```

N - Can I now create a VTable?
`draw = [Circle: drawCircle(maybeCast(s, Circle),_,_), Square: drawSquare(maybeCast(s, Square),_,_), Triangle: drawTriangle(maybeCast(s, Triangle),_,_)]`
above is not a VTable. it is a map. it needs `s` as a shape.
we can have a function which returns vTable, but accepting a shape:
```
getShapeVTable = fn(s: Shape -> fn(Canvas, float->nothing), fn(File, float->nothing), fn(Paper, float->nothing)){
  vtable_draw = [Circle: drawCircle(maybeCast(s, Circle),_,_), Square: drawSquare(maybeCast(s, Square),_,_), Triangle: drawTriangle(maybeCast(s, Triangle),_,_)]
  vtable_save = [Circle: saveCircle(maybeCast(s, Circle),_,_), Square: saveSquare(maybeCast(s, Square),_,_), Triangle: saveTriangle(maybeCast(s, Triangle),_,_)]
  vtable_print = [Circle: printCircle(maybeCast(s, Circle),_,_), Square: printSquare(maybeCast(s, Square),_,_), Triangle: printTriangle(maybeCast(s, Triangle),_,_)]
  
  return vtable_draw[type(s)], vtable_save[type(s)], vtable_print[type(s)
}
```

N - Do we need abstraction?
we can do that via functions.

N - Do we need functor?
```
Take concept of function application: f.apply(x)
Inverse: x.map(f)
Call x a functor

interface Functor<T> {
    Functor<R> map(Function<T, R> f);
}
```
so we can write:
```
Functor = fn(T: type, R: type-> type) {
    struct { data: T, map: fn(mapper: fn(T->R) -> Functor(R)) }
}
Functor = fn(T: type, R: type-> type) {
    fn(mapper: fn(T->R) -> Functor(R))
}
```
can I write `T(R)` as type of an argument?
```
process = fn(data: T(R), T: type, R: type -> int) ...
```
we can write this:
`[1, 2, 3].map(x => x.toString()).map(x -> x+"A").map(...)`
functor is a mapping function which takes another function and applies it on something and result will be another functor.
We have this in Java
```
Identity idString = new Identity<>("something interesting!");
Identity idInteger = idString.map(String::length);

@FunctionalInterface
public interface Functor<T, F extends Functor> {

    private final T value;

    public Identity(T value) {
        this.value = value;
    }

    @Override
    public  Identity<?> map(Function<T, R> f) {
        final R result = f.apply(value);
        return new Identity<>(result);
    }
}
```
A functor is a piece of data (like an integer) + a mapping function which accepts a lambda from int to string for example. output of this mapping function is another functor 
which has another piece of data (of string type, in this example).
So it is like an applicator of a function to its internal piece of data. but not directly. It applies the function and returns another functor.
so, it is abstract. and composable (you can pass any mapping function you want).
this internal piece of data, I think can be provided through closure or using a struct.
what we know for sure, is that outside world does not have direct access to this piece of data.
```
Data = struct {x: T, map: fn(mapper: fn(T->R) -> Data(R)}
initial = createIdentity(100) #generates an instance of Data above with initial x as value 100
initial.map(toString).map(getLength).map(adder)...
```
or we can use closure:
```
Functor = fn(T: type -> type) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial.map(toString).map(getLength).map(adder)...

createIdentity = fn(data: T -> Functor(T)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result)
    }
}
```
problem is: when I write map function for my functor, it accepts a function `T->R` but I don't know anything about type R.
not until map function is called.
In java we have `?`: `class Identity<T> implements Functor<T,Identity<?>>`
when I call `createIdentity` I know T (e.g. int), but I don't know R. It will be determined throughout lifecycle of the data.
it can be string, or float, or int, or Customer or anything.
is `Functor(int)` a correct type?
it gives me, `fn(mapper: fn(int->R), R: type -> Functor(R))`. 
so, calling `createIdentity(100)` gives me above. it is good but I have to decide what is R at compile time.
Maybe I should write it like this:
```
Functor = fn(T: type -> type) {
    fn(R: type -> type) {
        fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
    }
}
```
So, if you call `Functor(int)` it will give you another function, which when called with a correct type, gives you a real mapper.
but this means I need to know R before calling mapper. 
`createIdentity(100).map(toString)`
so this should be: `createIdentity(100)(String).map(toString)`. 
```
Functor = fn(T: type -> type) {
    struct { data: T, mapper: fn(m: fn(T->R), T: type, R: type -> Functor(R))
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial.map(toString).map(getLength).map(adder)...

createIdentity = fn(data: T -> Functor(T)) {
    &{data: data,
        mapper: fn(m: fn(T->R), T: type, R: type -> Functor(R) ) {
            result = m(data)
            return createIdentity(result)
        }
    }
}
```
no. struct is not ok. because map function inside struct will not have closure access to struct fields. because closure is only for functions. 
if we want access, we should pass an instance of the functor to the mapping function which is weird: `x=createIdentity(100); x.map(x, toString)`
so we have to work with closure:
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
Functor = fn(T: type, R: type -> type) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...

createIdentity = fn(data: T, T: type -> Functor(T, R)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result)
    }
}
```
in Java, we only need `T` to create an instance of the functor.
but when we call it, `R` will be automatically inferred.
in java, creation of functor and calling it are two separate steps.
when we create, we pass an int number, and get a class with a function.
when we call the function, R becomes known. 
we merge both in one step: `createIdentity`. Maybe we should provide a dummy R (noop function) too.
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
Functor = fn(T: type -> type) {
    fn(R: type -> type) {
        fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
    }
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...

createIdentity = fn(data: T, T: type -> Functor(T)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result, R)
    }
}
```
q: can we have a generic type, which when instantiated gives you a generic type? yes. above Functor
q: when does above loop finish? ???
when I call createIdentity, I will have a function. but input to that function is not determined, until I call that function.
let's assume I call `createIdentity(100)` what do I have? a `Functor(int)` which means a function
a generic function which needs `R` type to be called. 
If I call it -> R is clear from source code
if I don't call it -> no need to worry about it.
I think this can be declared and clarified in the language manual.
with proper examples and clarification.
1. we can have a generic function which generates a generic function/type
2. we can implement functor via double generic functions + closure + recursive calls
3. add examples of Maybe functor and Identity functor for clarification
can't we separate instantiation from map? this way, we don't need that confusing generics notation.
point is, when we define a functor, we don't know anything about the mapping function which will be applied at some point in future.
so, putting type of it inside those definitions is confusing.
but, we have a promise not to bind behavior (mapping) and data (internal x).
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
Functor = fn(T: type -> type) {
    fn(R: type -> type) {
        fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
    }
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...

createIdentity = fn(data: T, T: type -> Functor(T)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result, R)
    }
}
```
if I write `x = createIdentity(100)` what is type of x? x is a function.
x is a generic function that needs R argument. with R, it is a function accepting `fn(int->R)` and giving another generic function on R.
but we said, you cannot play with generics, only instantiate them. 
now, what happens if I pass `initial` to a function?
initial is of type `Functor(int)` meaning it has an integer inside it. and accepts a mapper function which maps int to some other type R.
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
Functor = fn(T: type -> type) {
  struct { 
      data: T,
      map: fn( fn(T->R), T: type, R: type -> Functor(R)) #this is a generic function, not a generic data structure
  }
}

createIdentity = fn(input: T, T: type -> Functor(T)) {
    myMapper = fn( mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(input) #type of result is R
        return createIdentity(result)
    }
    Functor(T) {
        data: input,
        map: myMapper
    }
}


initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial.map(toString).map(getLength).map(adder)...
```
This is fine, if we allow for generic lambdas. so you can pass them and call them anywhere.
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
Functor = fn(mapper: fn(T->R), T: type, R: type -> Functor(R))

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...

createIdentity = fn(data: T, T: type -> Functor(T)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result, R)
    }
}
```
Nope. Functor is a container. It is not a function.
but container is provided using closure.
above we are mixing normal inputs (mapper) and generic inputs.
so, what does `Functor(T)` mean? functor has 3 inputs: mapper, T and R.
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
# We use Functor(T) to say: this is a function that accepts a T->R mapper. What is R? we don't know yet.
# we will know R when someone calls the function. Actually this indirection, helps us simulate ? in Java
Functor = fn(T: type -> type) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R))
}

createIdentity = fn(data: T, T: type -> Functor(T)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R) ) {
        result = mapper(data)
        return createIdentity(result, R)
    }
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...
```
Functions that generate a type are named like a type.
Bindings that are a function, are named like a function.
another way:
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
# We use Functor(T) to say: this is a function that accepts a T->R mapper. What is R? we don't know yet.
# we will know R when someone calls the function. Actually this indirection, helps us simulate ? in Java
Functor = fn(mapper: fn(T->R), T: type, R: type -> Functor(R))

createIdentity = fn(data: T, T: type -> Functor(T, ?)) {
    fn(mapper: fn(T->R), T: type, R: type -> Functor(R, ?) ) {
        result = mapper(data)
        return createIdentity(result, R)
    }
}

initial = createIdentity(100) #generates an instance of Functor above with initial x as value 100 through closure
initial(toString)(getLength)(adder)...
```
ّIn Java, when you call map function, input is a `T->R` function and output is `Functor(R)`. So you don't need to specify the second type.
So, in Java, functor class has only one type argument: what it has inside.
but here, we want to merge class and function. so we want to provide two types. but we don't know the second type yet.
what is output of createIdentity? is it a function? if so, that function has 3 inputs: T, R and mapper.
suppose that I have:
`push = fn(T: type, data: T, stack: Stack(T) -> Stack(T)) { ... }`
now what does `push(int)` mean?
correct way is: `push(int, _, _)` which means: this is a lambda that accepts an integer and a stack of int and gives you a stack of int.
now, `Functor(T)` is wrong. it should be: `Functor(T, _, _)` so we use `_` for type too, which is not surprising.
```
# we have to specify both T and R when declaring type
# but during call, we won't always have a value for R, until we call mapper function
# We use Functor(T) to say: this is a function that accepts a T->R mapper. What is R? we don't know yet.
# we will know R when someone calls the function. Actually this indirection, helps us simulate ? in Java
Functor = fn(T: type, R: type, mapper: fn(T->R) -> Functor(R, _, _))

createIdentity = fn(data: T, T: type -> Functor(T, _, _)) {
    fn(R: type, mapper: fn(T->R) -> Functor(R, _, _) ) {
        result:R = mapper(data)
        return createIdentity(result, R)
    }
}

initialHolder = createIdentity(100) #type of initial is: fn(R: type, mapper: fn(int->R) -> Functor(R))
second = initialHolder(string, intToString) #type of second is: fn(R: type, mapper: fn(string->R) -> Functor(R))
initialHolder(string, intToString)(int, getStringLength)(int, timesTwo)...
```
we call functors like functions. 
q: We can do above with a simple function call chain.
`100 :: intToString :: getStringLength :: ...`
why do we need this? what advantages does it bring?
The key is in the map function (the one defined inside createIdentity). It can have all sorts of logic.
for example it can process for optional values `T|nothing` and if it is nothing, it won't call the mapper function.
so, mapper function has no idea about nothing. It only works with `T->R` but map function handles that.
This is like a function call with pre-processing.
We can also implement logging, interception, ... for it. Any processing we want to do before/after a function call.
generally: this gives us ability to invoke a function (any function) in a controlled environment. so we can control some stuff.
for example calling `doubleMe` function on `int|nothing`. control: if it is nothing, don't call function, otherwise call it with an int.
what about this?
```
map = fn(data: T, mapper: fn(T->R), T: type, R: type -> R ) {
        result:R = mapper(data)
        result
    }
}

initialHolder = 100
second = map(100, intToString)
map(initialHolder, intToString) :: map(_, getStringLength) :: map(_, timesTwo)...
```
we have a place to apply our logic (inside map function). and also, it is not exotic.
and we have an environment to control function execution.
for example we can write:
```
map = fn(data: T|nothing, mapper: fn(T->R), T: type, R: type -> R|nothing ) {
    if T is nothing then return nothing
    else return mapper(T(data))
}
```
or for list:
```
map = fn(data: [T], mapper: fn(T->R), T: type, R: type -> [R] ) {
    run mapper on all elements in data and create [R] and return
}
```
Maybe this itself is a functor!
Laws of functor in Haskell:
```
fmap id = id
fmap (f . g)  ==  fmap f . fmap g
```
so, we should write map, in a way that `mapper` returns same thing, we return the same thing.
also, if we call `map(data, function1) :: map(_, function2)` it should be same as `map(data, fn(x -> y} { function1(function2(x))}`
so, we already have functor! no need to complicate stuff.
using previously discussed functions makes syntax more "interesting" because it allows for direct chaining. but imposes a lot on compiler and runtime.

N - Should I be able to pass a generic function to another function?
```
push = fn(T: type, data: T, stack: Stack(T) -> Stack(T)) { ... }

process(push)
#inside process function
push(int_var, int_stack)
push(float_var, float_stack)
```
so, what should be pushed into stack when I call process?
we can only push one pointer. 
but when I call push for int and push for float, they are two separate functions.
option1: push is a map and push of int is an entry inside that map.
so at runtime, there is one more redirection. 
when I call `push(int...)` first runtime needs to check push to find out actual address of push function for integers. and then call it.
option 2: I can encode type names inside assembly level function names. `push_int`, `push_float`, ...
but we don't have access to push in process. We just have a `fn(T: type, data: T, stack: Stack(T) -> Stack(T))` binding.
caller cannot know what will process do with push.
that is why we don't allow for passing of generic functions.
but with functors, this is needed. 
so when I call `createIdentity(100)` I have a functor of int. which basically means it is a generic function, put into a binding.
q: how should a functor be named? it is a binding but has a function inside. so it should be named like a function.
`initialHolder = createIdentity(100)`
type of initial is: `fn(R: type, mapper: fn(int->R) -> Functor(R))`
option 2: we do one more round of compiler to scan all invocations of a generic lambda.
so, after this round we know `push(int)` and `push(float)` are called. but we don't really know what function do they call (in compile time). 
there are two problems here:
1. how is callee want to know which code to run exactly? e.g. when running `push(int)`?
2. how does compiler know what code to generate?
so, how can we have this in a library where we don't know how WILL call us?

N - How do we provide SOLID?
Open/Closed Principle: use higher order function to modify, 
Liskov Substitution Principle: function pointers, maybe abstraction
Interface Segregation Principle: specify smallest set of data in function input
Dependency Inversion Principle: function composition, first class functions

N - Do we need abstraction?
why do we need that?
example: we have a function that takes a graph node and does something on it.
now we want to be able to pass any graph node to it.
if behavior of the function is the same for all graph node types, then it is a generic function.
for example, avg function works in numbers. what if someone calls it with `Customer`?
they should be immediately notified.
or max or any statistical function.
in some cases, type really doesn't matter: e.g. stack or linked list.
because we act just as a holder, we don't read their value.
but for max, or for sort, or ... we need that.
is it really an important feature that we need?
we separate data and behavior. so if you need to call a function on a piece of data, just define the function as as input.
rather than expecting some kind of constraint or interface or contract to provide it to you.
problem is: if a developer calls my generic function, how do they know what should be provided?
well, it is in function inputs.
but, when we separate these, expecting a function to define data and their behavior does not make sense.
if there is such requirement, they must be separate: data input, behavior input.

N - Current solution for polymorphism is ugly.
all implementation methods must support nothing.
`drawCircle = fn(x: Circle|nothing->int|nothing) { checkNothing(x)@{nothing}`
which is not possible all the time.
`draw = [Circle: fn{drawCircle(maybeCast(s, Circle),_,_)}, Square: fn{drawSquare(maybeCast(s, Square),_,_)}, Triangle: fn{drawTriangle(maybeCast(s, Triangle),_,_)}]`
`drawFunction = draw[type(s)]()`
how can we simplify it with minimum change in the language?
```
drawCircle = fn(x: Circle->int|nothing) { ... }
draw = [Circle: fn{ drawCircle(getType(x, Circle)@,_,_) }, Square: fn{ drawSquare(getType(x, Square)@,_,_) }, Triangle: fn{ drawTriangle(getType(x, Triangle)@,_,_) }]
drawFunction = draw[type(s)]()
```
getType returns error if it cannot do the casting.

N - should we make it explicit that we expect runtime to provide value for a function argument?
For:
- Type arguments: infer from caller site
- `T|nothing` arguments: pass `nothing`
- Contract arguments: Resolution
- Numbers: Pass 0
- Manual: `x:10> int` no this is too much
`process = fn(x: int, data: T, T: type, stringer: ToString!(T), len: int|nothing -> string) { ... }`
`process = fn(x: int, data: T, T :> type, stringer:> ToString!(T), len:> int|nothing -> string) { ... }`
this looks better. and is explicit.
so function argument of the pattern `name :> type` means if it is not provided, compiler/runtime should try to find a value for it.

N - Indicate that:
`string = [char]`
`bool = true|false`

N - Is it correct to say, struct fields must have name?
yes

N - Is this notation ok?
`MyFund = fn(T: type -> type) { fn(data: T->int) }`
we can define it in one go.
but this sometimes helps us define the function type easier without needing to use `_`s.
yes it is fine.

N - Module level constants should be all caps with more than one letter.
Generic type names must be single letter caps.

N - Can you import multiple items and pass them to a function in one go?
`processIntegers(import('a')..{num1, num2, num3})`
or you should define them separately
I think this should be allowed because they are the same.
it is confusing, but we cannot prevent it.
why not? it makes reading code harder because at firt sight someone may think processIntegers has only one input.
Let's say, the only allowed notation is `A,B,C,... = import("...")..{a, b, c, ...}`
or: `x,y,z = t..{a,b,c}`

Y - what about function call?
`process3Integers(get3Integers())`
is this ok?

Y - If I have `MyType = fn(a: T, T: type ->int)` is `MyType(_, int)` a type? can I use it in other places?
yes we can. another way to simplify this is:
```
MyType = fn(T: type -> type) { fn(x: T -> int) }
process = fn(x: MyType(int) -> ...)
```

Y - Expression problem
adding new operation: this is easy in FP. but what about us?
we have a `superDraw` function which does draw. So adding a new operation is just adding new functions for them.
those types can be anywhere.
But what about new type?
if we add "Oval", then what happens to superDraw?
```
drawCircle = fn(x: Circle, c: Canvas, f: Color->int) {...}
drawSquare = ...
drawTriangle = ...

superDraw = fn(s: Shape->nothing) {
      #here key is type, and value is a lambda which takes a canvas and a color and returns error or int
      draw = [
        Circle: fn{ drawCircle(getType(x, Circle)@,_,_) }, 
        Square: fn{ drawSquare(getType(x, Square)@,_,_) }, 
        Triangle: fn{ drawTriangle(getType(x, Triangle)@,_,_) }
    ]
      drawFunction = draw[type(s)]() #get compile time type of "s"
      drawFunction()
}
```
we can solve this via multimethods.
Clojure has protocols to solve expression problem but they dispatch only on type of the first argument. which is not efficient.
```clojure
(defmulti evaluate class)

(defmethod evaluate Constant
  [c] (:value c))

(defmethod evaluate BinaryPlus
  [bp] (+ (evaluate (:lhs bp)) (evaluate (:rhs bp))))

//Adding a new operation
(defmulti stringify class)

(defmethod stringify Constant
  [c] (str (:value c)))

(defmethod stringify BinaryPlus
  [bp]
  (clojure.string/join " + " [(stringify (:lhs bp))
                              (stringify (:rhs bp))]))
                              
//Adding a new data type like FunctionCall
(defmethod evaluate FunctionCall
  [fc] ((:func fc) (evaluate (:argument fc))))

(defmethod stringify FunctionCall
  [fc] (str (clojure.repl/demunge (str (:func fc)))
            "("
            (stringify (:argument fc))
            ")"))
```
This solution introduces a new concept: multi-method. Which is actually "open-method". A method which is open. You can add to it. 
What would this look like in dotLang?
```
evaluate = fn!()
evaluateConstant = fn!evaluate(x: constant -> constant) { x }
evaluateBinaryPlus = fn!evaluate(left: ?, right: ? -> int) { left + right}
#new operation
stringify = fn!()
stringgifyConstant = fn!stringify(x: constant -> string ) ...
#adding new type
FunctionCall = struct ...
evaluateFnCall = fn!evaluate(x: FunctionCall -> ...
stringifyFnCall = fn!stringify(x: FunctionCall -> ...
```
This clearly solves expression problem.
Also, we don't need to write multiple functions with the same name. They continue to exist with their own name.
what is new?
1. we mark a function as an open-method `evaluate = fn!()`
2. we mark other functions as an extension for an open method `x = fn!parent...`
===
we need to specify structure of the files in the open method.
what about calling?
`x = evaluate(item)` item can be anything for which we have implemented evaluate open method.
so, evaluate is a real function, but its pieces are gathered and assembled during compile time and dispatched during runtime.
in evaluate we need to specif function signatures.
Let's rewrite above for shapes:
```
draw = fn!()
drawCircle = fn!draw(...)
drawSquare = fn!draw(...)
#new operation
stringify = fn!()
intToString = fn!stringify...
floatToString = fn!stringify...
#new shape
drawOval = fn!draw(...)
```
now, all draw functions must have the same signature. otherwise people cannot call them via their parent.
this common signature is defined in parent function `draw`
`draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)`
then we can implement this open method for any type we want:
`drawCircle = fn!draw(shape: Circle, c: Canvas, color: float -> nothing) {...}`
and how can I actually draw something?
```
Shape = Circle | Square
my_shape = readShape()
draw(my_shape, canvas1, red_color)
```
above `draw` call will be dispatched to the correct function based on type of `my_shape`.
we can also simply call draw with a concrete type: `draw(my_circle, canvas1, red)`
q: how can we say in a generic function, I accept type T, but the type T must have implemented that open method?
q: what should this be called? contract is not good because takes away the fact that it is just a function.
interface? no.
open method? method is for OOP
open function. sounds good.
Defining an open function: `draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)`
Specializing an open function for a specific type: `drawCircle = fn!draw(shape: Circle, c: Canvas, color: float -> nothing) {...}`
Calling an open function: `result = draw(my_shape)` or `result = draw(my_circle)`
`draw(my_circle)` will do this:
1. find draw -> it is an open function
2. find a single function which says `fn!draw` and has a circle input type
3. invoke that function.
q: what if open function has multiple generic types?
q: how can I specialize draw for `Stack` generic type? and also for `Stack(int)` type?
**Proposal: Open functions**
1. You can define a generic function as open by adding `!` after fn. 
2. As they are generic, you cannot pass them around.
3. An open function, is a function which can be specialized for different types, with different behavior for each type.
4. To specialize an open function you should use `fn!A` in specialized function where A is name of the open function.
5. When a call is made to the open function, it is automatically redirected to the correct specialization based on type of arguments.
===
q: what if I have specialized draw for `Circle|Square`? Then calling with a binding of that type will call that specialization.
so, if you call an open function with a union, the best specialization will be picked at runtime.
if it is `T|S` and we have a specialization fot that specific type, it will be invoked.
Otherwise, runtime type of the binding will be used.
Function call resolution: When an open function is called, compiler/runtime will search in all functions with `fn!A` in definition.
The fact that this function is specializing open method X, should it be reflected on the function name or function decl?
```
draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)
draw[Circle] = fn(shape: Circle, c: Canvas, color: float -> nothing) {...}
```
there is no point in forcing developer to provide a default function body for open function.
but also there is no point in banning that.
so to make it general, we can say, __any function can have an optional body.__
of course if you call a function that has no body, runtime error will happen.
```
draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)
draw[Circle] = fn(shape: Circle, c: Canvas, color: float -> nothing) {...}
drawMyCircle = fn!draw(...)
drawCircle!draw = fn(...)
```
if I put it with `fn!draw` then what if I define a local lambda with that notation?
then function dispatch will not be compile time.
but we cannot differentiate between module level and fn level lambdas.
in other words, is this a feature of the function type? specializing an open function?
I think it is.
__specialization of an open function is property of a type__
q: what if open function has multiple generic types? 
you can still specialize it by providing concrete types for one of more of its generic types.
It will result in a hierarchy of specializations.
at runtime, the best function, will be called.
BUT suppose that open function has `Shape, Canvas` type arguments.
we specialize it for `Circle, Canvas` and also `Shape, SolidCanvas`.
and then we call the function with `Circle, SolidCanvas`. 
What happens? there must be a specialization matching "exactly" with concrete types.
so there will be a compiler/runtime error unless you have a specialization for `Circle, SolidCanvas`.
q: what if I have stringify, and specialize it for `Stack(T)` and also `Stack(int)`? how can that be done?
```
stringer = fn(x: T -> string) 
stackToString = fn!stringer(x: Stack(T), T: type -> string) ...
intStackToString = fn!stringer(x: Stack(int) -> string) ...
```
now, calling stringer with `Stack(int)` will invoke `intStackToString` but calling it with any other stack will invoke `stackToString`.
**Proposal: Open functions**
1. Body is optional for functions. If a bodyless function is called, there will be compiler/runtime errors.
2. An open function is a generic function marked with `!`: `draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)`
3. An implementation function, implementes an open function for a concrete type: `drawMyCircle = fn!draw(shape: Circle, c: Canvas, color: float -> nothing) {...}`
4. When an open function is being called, compiler/runtime will check all functions in scope who have `!A` in their type. And the one that exactly matches with input types will be called. If nothing is found, the open function itself is invoked. If a union is passed and has no match, runtime type of the union will be used.
Example: `toString` open function.
```
toString = fn!(x: T, T: type -> string)
intToString = fn!toString(x: int -> string) ...
floatToString = fn!toString(x: float -> string) ...
stackToString = fn!toString(x: Stack(T), T: type -> string) ...
intStackToString = fn!toString(x: Stack(int) -> string) ...
```
If you call `toString` with a `Stack(float)` then `stackToString` will be called.
If you call `toString` with `int|float`, runtime type of the union will be used to do the dispatch.
===
q: can I call an open function with T generic type? yes but based on rule of generics, T must have a value at compile time.
so, what does this add?
1. `fn!` notation for both open function and implementation.
q: when writing a function, how can I say, I expect `toString` open function to have an implementation for this generic type T?
```
process = fn(data: T, T: type -> int) { ... result = toString(data) ... }
```
problem is, the open function can have multiple types:
`draw = fn!(shape: T, canvas: S, color: float, T: type, S: type -> nothing)`
`drawCircleOnSolidCanvas = fn!draw(shape: Circle, canvas: SolidCanvas, color: float -> nothing) { ... }`
now, I have a process function, which needs to call draw
`process = fn(item: T, canvas: S,S: type, T: type, draw(S,T): fn -> int) { ... result = toString(data) ... }`
`draw(S,T): fn` means draw open function must be implemented for types S and T.
so I should be able to write: `draw(item, canvas, ...)`
q: why not make open functions, types?
and implementations are just of that type?
```
ToString = fn(T: type -> type) { fn(x: T, T: type -> string) } #nothing new
toStringInt: ToString(int) = fn(x:int -> string) { ... } #nothing new
genericToString = fn!ToString(T)(data: T -> string) { (optional) default impl } #!ToString - define an open method
str_val = genericToString(int_var) #nothing new
process = fn!ToString(T)(data: T -> float) { here we know T has an implementation for ToString
```
vs
```
toString = fn!(x: T, T: type -> string) #body is optional
intToString = fn!toString(x: int -> string) ...

process = fn(data: T -> float) + toString(T) { ... here I want to be able to call toString(data) ... }
```
better not to mix this open function concept with type declaration for functions.
`+ toString(T)` means this function expects `toString` function to be defined for type T.
**Proposal: Open functions**
1. Body is optional for all functions. If a bodyless function is called, there will be compiler/runtime errors.
2. An open function is a generic function marked with `!`: `draw = fn!(shape: T, c: Canvas, color: float, T: type -> nothing)`
3. An implementation function, implementes an open function for a concrete type: `drawMyCircle = fn!draw(shape: Circle, c: Canvas, color: float -> nothing) {...}`
4. When an open function is being called, compiler/runtime will check all functions in scope who have `!A` in their type. And the one that exactly matches with input types will be called. If nothing is found, the open function itself is invoked. If a union is passed and has no match, runtime type of the union will be used.
Example: `toString` open function.
```
toString = fn!(x: T, T: type -> string)
intToString = fn!toString(x: int -> string) ...
floatToString = fn!toString(x: float -> string) ...
stackToString = fn!toString(x: Stack(T), T: type -> string) ...
intStackToString = fn!toString(x: Stack(int) -> string) ...
process = fn(data: T -> float) + toString(T) { ... } #the process generic function expects type T to have an impl for toString function
```
If you call `toString` with a `Stack(float)` then `stackToString` will be called.
If you call `toString` with `int|float`, runtime type of the union will be used to do the dispatch.
---
this should be super easy and super explicit.
explicit: need `!` when defining open function. need `!NAME` when defining implementations.
maybe we should separate generic type and rest of the arguments. so `toString(T)` makes sense.
```
ToString = fn!(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
floatToString: ToString(float) = fn(x: float -> string) ...
stackToString: ToString(Stack) = fn(x: Stack(T), T: type -> string) ...
intStackToString: ToString(Stack(int)) = fn(x: Stack(int) -> string) ...
process = fn(data: T -> float) + ToString(T) { ... } #the process generic function expects type T to have an impl for toString function
```
using a type here needs less new notations. but we no longer have default impl.
also, how am I supposed to call the function that implements ToString for my type T inside process?
`process = fn(data: T, toString: ToString(T), T: type -> float) { ... }`
this works well with multiple types:
`process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw(S,T) -> int) { ... result = toString(data) ... }`
then when calling process:
`x = process(my_int, intToString, int)`
so this is fine except for:
1. it is difficult to remember all impl functions for all types
2. what about union?
`drawShape = (s: T, drawFunc: Draw(T) -> ...`
```
my_shape = loadShape(...)
drawFunction = runtimeFindImpl(my_shape, Draw) #find a function of type Draw(T) where T is runtime type of my_shape
drawShape(my_shape, drawFunction)
```
a bit more verbose but more flexible and developer has more control.
what about multi-types?
`Draw = fn(S: type, T: type -> type) { ... }`
`drawFunction = runtimeFindImpl(my_shape, my_canvas, Draw)`
**Proposal: Open functions**
1. Body is optional for all functions. If a bodyless function is called, there will be compiler/runtime errors.
2. A contract is a generic function type marked with `!`: `ToString = fn!(T: type -> type) { fn(data: T -> string) }`
3. An implementation function, implementes a contract for a concrete type: `intToString: ToString(int) = fn(x: int -> string) ...`
Example: `ToString` contract.
```
ToString = fn!(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer: ToString(T), T: type -> int) { ... result = stringer(data) ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
...
myFunction(int_var, intToString)
myFunction(int_or_float)
```
so, you can omit passing functions which are of a contract type. Runtime/compiler will automatically find them for you.
if compiler cannot find an impl for static type of the binding, and we have impl for all possible cases of dynamic type (for unions), the it will be done at runtime.
q: How can I implement type `Draw(S,T)` for Circle and all types of Canvas?
we can define `Draw(S)` which returns a generic function: `fn(shape: S, canvas: C, C: type -> ...`
and then implement it: `myCustomDraw: Draw(Circle) = fn(shape: Circle, canvas: C, C: type -> ...`
then how can I declare function process needs this?
`process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw(S,T) -> int)`
type decl is a bit weird. Why not use it after fn? It is a new notation. type decl is necessary because we have said, named type are not same as underlying type.
so when process function needs `stringer: ToString(T)` only a function of that type is allowed.
```
ToString = fn!(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer: ToString(T), T: type -> int) { ... result = stringer(data) ... }

Draw = fn!(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
...
myFunction(int_var, intToString)
myFunction(int_or_float)
```
and you cannot mix contracts, because you cannot type a named type:
`MyInt: float = int` does not make sense.
so you cannot write `Draw: GenericDraw = fn!(...)`
and no, you cannot define a function with only specifying one generic type value. All generic types must have concrete types.
```
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
```
so, here we assume Canvas is a union type and not generic. which is fine.
__in all cases, caller of a function has the option to specifically provide an appropriately typed function as implementation of a contract__
```
ToString = fn!(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer: ToString(T), T: type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw = fn!(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
...
```
so, if you omit value for a contract when calling a function, runtime will find something for it.
so for example if contract is `Contract(S,T,U,V)` compiler/runtime will first find values for S,T,U,V types based on rest of the parameters used to call the function.
then we will have something like `Contract(int, string, float, Customer)` and then all functions of type `Contract` will be searched.
not that, if call is made with a union e.g. `int|string` and above search fails during compile time, runtime will use dynamic type of the union binding to dispatch the call.
but compiler will make sure all of the union cases have a candidate.
I think it is still a bit implicit. Not explicit enough. When a function implements a contract, we definitely need to set its type, otherwise it will be plain wrong.
but maybe we should made contract types more explicit. rather than `fn!` maybe we should add `!` to the name.
so everyone everywhere knows this is a contract.
```
ToString! = fn(T: type -> type) { fn(data: T -> string) }
intToString: ToString!(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer: ToString!(T), T: type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw! = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw!(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw!(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw!(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
...
```
what does it mean to define a contract which is not generic? it makes no sense. it is a simple type.
the only way we can have multiple functions with the same signature is with generic types.
q: Can I have a generic contract of type struct?
then a function can say, I expect `Shape(T)` and then we return a binding of that type based on T?
**Proposal: Open functions**
2. A contract is a generic type type suffixed with `!`: `ToString! = fn(T: type -> type) { fn(data: T -> string) }`
3. An implementation function, implementes a contract for a concrete type: `intToString: ToString!(int) = fn(x: int -> string) ...`
Example:
```
ToString! = fn(T: type -> type) { fn(data: T -> string) }
intToString: ToString!(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer: ToString!(T), T: type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw! = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw!(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw!(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction: Draw!(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
```
Caller has an option to pass a function for those contract arguments but if omitted, Runtime/compiler will automatically find them for you.
if compiler cannot find an impl for static type of the binding, and we have impl for all possible cases of dynamic type (for unions), the it will be done at runtime.
you can define contracts based on structs or other types too, but runtime/compiler won't be able to automatically resolve them for you. you have to do it yourself.
--
q: Can I have a generic contract of type struct?
but suppose that we allow for that. runtime won't be able to automatically find it for you! because runtime can find types, it cannot look for bindings of that type.
but even without runtime help, this might be useful. I have a generic function that accepts data of type T, and I want that data to have a field named `.age`.
```
Aged! = fn(T: type -> type) { struct { age: T } }
process = (data: T, aged: Aged!(int) -> ... ) {
  result = aged.age
  ...
  
}
process(my_int, Aged!(int)(my_struct)
```
well, we cannot forbid that. Contract is any generic type marked with `!`. But user will have to manually do the casting.
suffixing is better because they still start with a capital letter.
on one hand this `!` notation makes things explicit which is good. on the other hand, it adds a new mental burden for the developer so he has to keep in mind that.
can't we just drop all new notations and rely on `:>` below to say: compiler/runtime please find something for here?
minimum disruption
```
ToString = fn(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer:> ToString(T), T: type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction:> Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
```
so, we don't have anything unusual, new or made up notation.
everything, EVERYTHING, is just like before. you define types, you write functions, you call those functions.
BUT the new part is `:>` notation where we ask compiler/runtime to provide value for an argument if it is not sent from caller site.
so, if you use `:>` on a something which is a generic function, based on how function is called, it will be mapped to a correct function.
of course there must only be one matching function. otherwise there will be compiler errors.
so, e.g. if I have `draw:> Draw(T)` and T is a Shape, you must either have a function of type `Draw(Shape)` or functions of type `Draw(S)` for each S as an option for Shape union.
I think this makes more sense.
rather than defining new concepts and names, just stick to the normal way but add support for automation.
**Proposal: Automatic Resolution**
1. When using generic arguments, you can ask compiler/runtime to automatically resolve them for you.
2. For example if you expect a function of type `ToString(T)` and function is called with `T=int`, you can ask compiler to automatically find a function of type `ToString(int)` for you so caller does not need to pass them explicitly.
Example:
```
ToString = fn(T: type -> type) { fn(data: T -> string) }
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer:> ToString(T), T: type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction:> Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
```
Of course, caller can still explicitly pass values for those arguments.
if compiler cannot find an impl for static type of the binding, and we have impl for all possible cases of dynamic type (for unions), the it will be done at runtime.
Note that there are rules (explained in the next section), on how/what can be resolved automatically.
So, suppose that we want to write a graph traversal algorithm. Graph can have two types of nodes: basic (leaf) and complex (non-left).
Each one has its own processing.
```
NodeType = BasicNode | CompleNode
MyGraph = Graph(NodeType)
ProcessNode = fn(T: type -> type) { fn(node: T, T: type -> string) }
processBasicNode: ProcessNode(BasicNode) = fn(node: BasicNode ...
processComplexNode: ProcessNode(CompleNode) = fn(node: CompleNode, ...

processGraphNode = fn(x: T, T:> type, processor:> ProcessNode(T) -> string) { processor(x) }
processGraph = fn(g: NodeType -> string) {
  data = processGraphNode(g)
  foreach node in g.rootNode.children:
    processGraph(node)
}
```
whenever you call `processGraphNode` you should also have a processor function for the type you are sending.
q: Is it still possible to provide default impl? no.
q: how can we use this for getHashCode?
```
Hasher = fn(T: type -> type) { fn(data: T, T: type -> int) }
intHasher: Hasher(int) = fn...
stringHasher: Hasher(string) = fn...
...
process = fn(data: T, hasher:> Hasher(T), ... 
makeMap = fn(K: type, V: type, hasher :> Hasher(K) -> [K:V]) { ... }
```
so, in above graph example, you cannot simply call any of two process functions (basic or complext), by just having a union binding of them.
you need to write a function to do that:
`processGraphNode = fn(x: T, T:> type, processor:> ProcessNode(T) -> string) { processor(x) }`
**Proposal: Automatic Resolution**
1. You can use `:>` when declaring a function to indicate that argument should be optional and if missing, inferred via compiler/runtime.
2. For example if you expect an argument which is a function of type `:> ToString(T)` and function is called with `T=int`, if this argument is missing, compiler/runtime will automatically find a function of type `ToString(int)` for you so caller does not need to pass them explicitly.
3. For `x :> T|nothing` nothing will be used. For `x :> int` zero will be used if missing.
4: for `T :> type` compiler will infer type.
5. For `x :> ToString(T)` and T is a union, if no impl exists for static type of x, compiler will make sure impl for each option of union type T is there and delegate the rest to runtime
Example:
```
ToString = fn(T: type -> type) { fn(data: T -> string) }
genericToString: ToString = fn(T: type, data: T -> string) ... #top level catch all impl
intToString: ToString(int) = fn(x: int -> string) ...
myFunction = fn(item: T, stringer:> ToString(T), T:> type -> int) { ... result = stringer(data) ... }

myFunction(int_var, intToString)
myFunction(int_or_float)

Draw = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction:> Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }

Hasher = fn(T: type -> type) { fn(data: T, T: type -> int) }
genericHash: Hasher = fn(T: type, data: T -> int) { ... }
intHasher: Hasher(int) = fn...
stringHasher: Hasher(string) = fn...
...
process = fn(data: T, hasher:> Hasher(T), ... 
makeMap = fn(K: type, V: type, hasher :> Hasher(K) -> [K:V]) { ... }
```
q: why do I need a level of redirection when defining ToString?
`ToString = fn(T: type, data: T -> string)`
If I have above, is `ToString(int, _)` a function type? should be. but keeping them separate makes decl easier to read.
A generic function is just like an interface. You can implement it for any type by defining functions of that type but with concrete internal types.
yes! we can have generic default impl for them.
how does this allow us to solve expression problem?
so, for each generic funtion type like Hasher, we have N implementations for different types. (or one for T which is the default implementation).
so, we define a generic type function for each operation and one impl for each type.
new type -> add a new impl for all available operations (`drawOval: Draw(Oval) ...`)
new operation -> define a new type function and impl it for existing types: `Printer = ..., printCircle = ...`
so, each generic type function is an interface.
you can have a default implementation for it too.
Shall we use a special name for these generic type functions? Let's call them contract.
and each function of that type is an implementation of a contract.
and when I write `process = fn(...hasher:> Hasher(T)...)` it means I need an implementation for that contract based on the type my function is called.
and if used with `:>` it gives me runtime dynamic dispatch for union types.
But note that, still in a generic function, I cannot say this function only accepts `T|S`. It could be called with any type.
The onyl way I can filter, is to add a contract impl so that if a type doesn't have that impl, caller cannot call my function.
q: can I have contract impl for getting a field value from a struct?
like: getRankFromT. So it can be used in sorting.
```
Ranker = fn(T: type -> type) { fn(data: T -> int) }
customerRanker: Ranker(Customer) = fn(data: Customer -> int) {data.age}
Sort = fn(data: [T], ranking:> Ranker(T) -> [T])...
```
We can even use this to filter out specific types.
```
IsNumber = fn(T: type -> type) { fn(nothing -> boolean) }
intIsNumber: IsNumber(int) = fn(nothing->boolean) { true }

process = fn(data: T, T:> type, isNumber :> IsNumber(T) -> string) { ...}
```
Here in process, we want to make sure type T is a number.


Y - Should we allow optional args `:>` in the middle of arg list?
caller can call function with: `process(1,2,,3)` notation.
not very useful but one less rule.
caller can ignore them if they are all at the end. otherwise, an empty comma should be used.

N - To solve expression problem, when a new type is added, we need to modify original union type.
you don't have to. you can use generic functions.
but if you have a specific function that for example reads shapes from file, then yes you have to modify that function and if it returns a `Shape` then you have to modify it.

Y - The fact that I cannot edit a union type later, is a bit counter intuitive.
if contracts are like interfaces, I can implement them for any type I want. So no need for union type.
but, what about the code that reads shapes from a file or database or network?
I can make that code polymorphic too:
```
ShapeReader = fn(T: type -> type) { fn(file: File -> T) }
circleReader: ShapeReader(Circle) = fn(file: File -> Circle) { ... }
squareReader: ShapeReader(Square) = fn(file: File -> Square) { ... }
...
readShapeInner = fn(T: type, reader :> ShapeReader(T) -> ? ) { ... }
readShape = fn(f: File -> ?) {
  type = f.getType()
  readShapeInner(type)
}
```
What is the output type of the generic function that reads all types of shapes?
We need a dynamic union.
union of all types T where we have implemented `ShapeReader` for them.
`Shape = ShapeReader(_)`
what if contract has multiple types?
`Shape = Drawer(_, SolidCanvas)`
`Shape = Drawer(_, _)`?
`Shape = T where Drawer(T)`
or we may have a function that generates those type?
`Shape = fn(->type) { Drawer(T) }`
`Shape = forall T: type -> Drawer(T)`
rather than binding based on function signature we should bind based on type.
because we may have multiple contracts and maybe some of those types don't have an impl.
https://wiki.haskell.org/Existential_type:
has a good example
```Haskell
class Shape_ a where
   perimeter :: a -> Double
   area      :: a -> Double
 
 data Shape = forall a. Shape_ a => Shape a
 
 type Radius = Double
 type Side   = Double
  
 data Circle    = Circle    Radius
 data Rectangle = Rectangle Side Side
 data Square    = Square    Side
 ```
 ```
 Shape = struct{}
 Circle: Shape = {r: float}
 Square: Shape = {n: int}
```
no.
we need a notation to find list of all types that implement a contract.
`Shape = fn(->type) { Drawer(T) }`
`Shape = forall T: type -> Drawer(T)`
`Shape = Drawer(?)` - union of all types that implement this Drawer contract
Nope. This is confusing. 
is there a way that we don't need to do this?
we can put these in functions + closure.
`ShapeReader = fn(T: type -> type) { fn(file: File -> T) }`
Now, `ShapeReader(Circle)` will give you a circle.
```
readShapeInner = fn(T: type, reader :> ShapeReader(T) -> T ) { ... }
readShape = fn(f: File -> ?) {
  type = f.getType()
  readShapeInner(type)
}
```
Can't we follow the same for types?
we define a general contract (function-contract) and implement it for different types.
we define a generic type-contract and implement it for different types.
A contract on behavior: `Drawer = fn(T: type -> type) { fn(x: T -> string) }`
A contract on type: `Shape = fn(T: type -> type) { Shape | T }`
`Circle: Shape(Circle)`?
we implement a behavior contract by defining a function of the given type.
we implement a type contract by defining an unnamed type with that contract.
`Circle = struct{...}`
`_ = Shape(Circle)` a named type without a name. 
`Shape = fn(T: type -> type) { Shape | T }`
above implies, any call to type `Shape` with type `T` will enrich union type Shape with T.
why not use the direct way?
```
Shape = 
Shape |= Circle
Shape |= Square
```
In haskell we define existential types as all types that satisfy a type class.
```
Draw = fn(S: type, C: type -> type) { fn(shape: S, canvas: C, color: float -> string) }
drawCircleOnSolidCanvas: Draw(Circle, SolidCanvas) = fn(shape: Circle, canvas: SolidCanvas, color: float -> string) { ... }
drawSquareOnAnyCanvas: Draw(Circle, Canvas) = fn(shape: Circle, canvas: Canvas, color: float -> string) { ... }
process = fn(item: T, canvas: S,S: type, T: type, drawFunction:> Draw(S,T) -> int) { ... result = drawFunction(item, canvas) ... }
```
in `process` function above, `T` is limited by `:>` because T must be something that implements that function `Draw(S)`.
can't we do the same for a type?
`Shape = fn(S:> type, drawFunction:> Draw(S)->type)` This can imply `Shape` is a type where you don't have to pass a type to it.
`Shape = fn(S:> type, _ :> Draw(S)->type) { S }`
then when I write `x: Shape()` or `loadShape = fn(name: string -> Shape())` it means union of all types.
`Shape = |fn(S:> type, _ :> Draw(S)->type)|`
`Shape = |S| : Draw(S)` union of all S types where we have Draw implemented for them
can we have multiple conditions? all types that satisfy contract A and B
for OR we can simply | them: `NewType = A | B`
`Shape = |S| :> Draw(S), Hasher(S), ...`
q: what about multi-type contracts?
for example we may have a contract of shape+canvas to draw shape on a canvas.
`Drawer = fn(S,T -> type) { ... }`
then, what if I need all shape types that have Drawer defined. for any canvas type?
`Shape = |S| :> fn(S: type, _ :> Draw(S), _ :> Hasher(S), ...)`
`Shape = |S| :> fn(S: type, T: type, _ :> Draw(S, T), _ :> Hasher(S, T), ...)` All S types where they have implemented Draw and Hasher contracts for any T
`Shape = |S| :> fn(S: type, _ :> Draw(S, SolidCanvas), _ :> Hasher(S, NullCanvas), ...)` All S types where they have implemented Draw + SolidCanvas or Hasher for S and NullCanvas.
**Proposal**:
1. You can define a dynamic union based on implementations of one or more contracts.
2. `XType = |T| :> fn(T: type, _ :> Contract1(T), :> Contract2(T), ...)`
3. Above means XType will be union of all types like T where we have an implementation for Contract1 and Contract2 for T.
4. This also supports multi-type contracts:
`Shape = |S| :> fn(S: type, T: type, _ :> Draw(S, T), _ :> Hasher(S, T), ...)` All S types where they have implemented Draw and Hasher contracts for any T
`Shape = |S| :> fn(S: type, _ :> Draw(S, SolidCanvas), _ :> Hasher(S, NullCanvas), ...)` All S types where they have implemented Draw + SolidCanvas or Hasher for S and NullCanvas.
This becomes a bit fuzzy if someone decides to use this inside function decl.
let's ban that.
can't we simplify that?
`XType = |T| :> Contract1(T), Contract2(T)`
`Shape = |S| :> T: type, Draw(S, T), Hasher(S, T)`
`Shape = |S| :> Draw(S, _), Hasher(S, _)`
`Shape = |S| :> Draw(S, SolidCanvas), Hasher(S, NullCanvas)`
With the help of this, can I extend a `readShape` function to read new types?
```
readShapeInner = fn(T: type, reader :> ShapeReader(T) -> Shape) { ... }
```
if above function is in a library which supports square and circle, can I extend above to support triangle?
assuming I add a function for triangle?
`readTriangle: ShapeReader(Triangle) = ...`
Can we simplify multi-types?
A `XType = |T| :> Contract1(T) + Contract2(T)`
B `Shape = |S| :> Draw(S, _) + Hasher(S, _)`
C `Shape = |S| :> Draw(S, SolidCanvas) + Hasher(S, NullCanvas)`
D `Shape = |S| :> Draw(S) + Hasher(S) + ShapeSaver(S)`
S above implies that if I have something of type `Shape` I have implementation of draw and has function and save function for it.
so: if I write this:
`process = fn(item: Shape -> string) { ... }`
can I call `draw(item)` in it? you can but who is going to cast `draw` to `drawAAAA` actual function?
That is why we added `:>` notation:
`process = fn(item: T, T: type, drawFunction :> Draw(T) ) { ... drawFunction(item) ... }`
in above, we need caller/compiler/runtime to give us a pointer to the actual draw function.
so, process says I am a generic function which can work with any type T you can imagine, but it must have a drawFunction.
D definition above says, `Shape` is a union of all types like S which implement Draw.
these two are clearly related.
can we make the relation more explicit?
`process = fn(item: T, T: type[Shape], drawFunction :> Draw(T) ) { ... drawFunction(item) ... }`
what does oop do? in oop, `Shape` is an interface with all functions needed. and you say `process` needs an argument of type `Shape`.
ther you have access to impl of all of those functions.
maybe we should not make the relation explicit. let it be more flexible.
maybe some function needs a draw function but not for only a shape. anything that has that function is accepted.
if I have a seq of Shapes how can I draw all of them?
```
drawOneShape = fn(item: T, T: type, drawFunction :> Draw(T) ) { drawFunction() }
drawShapes = fn(items: [Shape] -> nothing) {
  foreach x: Shape inside items: drawOneShape(x)
}
```
but, if declaring supported functions for `Shape` is not going to be used anywhere, why declare them?
just manually add types to it. other places are enforcing required functions which works and developer knows that to send/provide.
so, rather than: `Shape = |S| :> Draw(S) + Hasher(S)`
we write: `process = fn(data: T, T: type, drawFunc :> Draw(T), hashFunc :> Hasher(T) -> ...`
then what is the point of Shape?
we don't really need to put those specific requirements on type T.
Because it is not going to be needed by functions. It might be useful for the developer as a documentation source but why 
add so many new things to the language just for docs?
so, what can we do?
we need a union type which is extensible, but we don't want to have a strange inclusion criteria.
simple types.
to declare shape type `Shape = enum [Circle, Square]`
to extend shape type `Shape = enum [Shape, Triangle]` 
`ShapeEnum = enum [ShapeEnum, Circle, Square]`
`ShapeEnum = enum [ShapeEnum, Triangle]`
and how to define a union type?
`Shape = |ShapeEnum|`
why not merge above?
`Shape = Shape | Circle | Square` this definition enables extension of the union type
`Shape = Shape | Triangle`
**Proposal**
1. You can define a dynamic union by using union type on the right side: `T = T | S | U`
2. For a dynamic union, it can be extended at any place in the code: `T = T | P` This adds P as a new case type for union type T
---
But this means that when I write a code to work with Shape, I cannot simply assume it will be only cases that I have specified.
But that should be fine.

N - How does dynamic union work with contracts?
```Elixir
Shape = Shape | Circle | Square
Draw = fn(T: type -> type) { fn(item: T -> nothing) }
drawCircle: Draw(Circle) = fn(item: Circle -> nothing) { ... }
drawSquare: Draw(Square) = fn(item: Square -> nothing) { ... }
draw = fn(item: T, T:>type, drawFunc:>Draw(T) -> nothing) { drawFunc(item) }
drawAll = fn(shapes: [Shape] -> nothing) {
  for each shape in shapes:
      draw(shape)
}
```
but in above code, what will be value of `T`? will it be actual type of the shape? or Shape?
maybe we should call it like this: `draw(shape, internalType(shape))`
anyway, how is dynamic union used?
```
Shape = Shape | Triangle
drawTriangle: Draw(Triangle) = fn...
#no change needed in draw function or drawAll
```
we can say, if you want `:>` to use static data then ... to use dynamic data use ... but it is confusing.
how can developer know in advance?
so, if `T` is a normal type then everything is ok.
but if we call function with a union T, then there is the question of: should T be `A|B|C` or actual A or B or C type of what is passed?
this only applies to generic functions.
`draw = fn(item: T, T:>type, drawFunc:>Draw(T) -> nothing) { drawFunc(item) }`
option 1: instead of `type` we can write `type+Shape` to indicate runtime type of T should be used.
option 2: we can write `T:>>type` to say, T should be runtime type of the arguments, not static type.
`draw = fn(item: T, T:>>type, drawFunc:>Draw(T) -> nothing) { drawFunc(item) }`
because if we call draw with `Circle|Square` should T be `Circle|Square` or the actual type inside T?
who should decide about this? caller? or function?
consider this function:
```
myFunction = fn(item: T, stringer:> ToString(T), T:> type -> int) {
  ... result = stringer(data) ... 
}
```
when you call myFunction with `Circle|Square` what will be value of T?
if call is for a non-union, everything is clear at compile time.
if call is for a union type, and there is only type inference, compiler will infer to union type.
if call is for a union and there is also function inference, compiler will check. If we have a function for union type, then it will be used to T will be union type.
if we don't have a function for union type but we have a fn for union options, then T will be runtime type.
