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

? - Do we need abstraction?
we can do that via functions.

? - Do we need functor?
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
