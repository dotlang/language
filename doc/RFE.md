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


? - Type classes or some other similar method to have some kind of flexibility in function call dispatch
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





