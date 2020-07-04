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

? - Expression problem
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

