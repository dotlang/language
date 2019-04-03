# Functions

Functions are a type of binding which can accept a set of inputs and give an output. For example `(int,int -> int)` is a function type, but `(x:int, y:int -> int) { x+y}` is function literal. What comes after `->` must be a type.

A function will return the result of its last expression.

You can alias a function by defining another binding pointing to it (Example 8). 

If a function has no input, you can can eliminate input/output type declaration part (Example 13).

When calling a function, you can ommit arguments that are at the end and accept `nothing` (Example 14). This can be used to have optional arguments.

If a function is being called with literals (compile time known values), compiler will try to evaluate it during compilation. This is used in generic types (Example 15).

**Syntax**: 

- Defining a function:

`functionName = fn(name1: type1, name2: type2... -> OutputType) { code block ... out = expression }`

- Defining a function type (Examples 14, 15 and 16):
`FunctionType = fn(type1, type2, ... -> OutputType)`

**Examples**

01. `myFunc = fn(x:int, y:int -> int) { 6+y+x }`
02. `log = fn(s: string -> nothing) { print(s) } #this function returns nothing`
03. `process2 = fn(pt: Point -> struct {int,int}) { return {pt.x, pt.y} } #this function returns a struct`
04. `myFunc9 = fn(x:int -> {int}) { struct {int}{x+12} } #this function returns a struct literal`
05. `process = fn(x: int|Point -> int) ... #this function can accept either int or Point type as input or int|Point type`
06. `{_,b} = process2(myPoint) #ignore second output of the function`
07. 
```
process = fn(x:int -> int) 
{ 
  #if x<10 return 100, otherwise return 200
  [x<10: 100, x>=10: 200][true]
}
``` 
08. `process = fn(x:int -> int) { x+1 }`, `process2 = process`
09. `sorted = sort(my_sequence, fn(x,y -> int) { x-y} )`
10. `Adder = fn(int,int->int) #defining a named type based on a function type`
11. `sort = fn(x: [int], comparer: fn(int,int -> bool) -> [int]) {...} #this function accepts a function pointers`
12. `map = fn(input: [int], mapper: fn(int -> string) -> [string])`
13. `process = fn{ 100 }`
14.
```
seq = fn(start_or_length:int, end:int|nothing -> ...)
...
x = seq(10)
y = seq(1,10)
```
15. 
```
add = fn(a:int, b:int ->int) { a+b }
g = add(1,2)
```

## Function call resolution

We use a static dispatch for function calls. Also because you cannot have two functions with the same name, it is easier to find what happens with a function call.

If `MyInt = int` is defined in the code, you cannot call a function which needs an `int` with a `MyInt` binding, unless it is forwarded explicitly in the code (e.g. `process = fn(x:MyInt -> process(int(x)))`).

To resolve a function call, first bindings with that name in current function will be searched. If not found, search will continue to parent functions, then module-level. At any scope, if there are multiple candidates (matching with name) there will be a compiler error. Parameter types must be "compatible" with function arguments, or else there will be a compiler error. For example if function argument type is `int | nothing` and parameter is an `int` it is a valid function call.

## Lambda (Function literal)

Lambda or a function literal is used to specify value for a binding of function type. It is very similar to the way you define body of a function binding. Lambdas are closures and can capture bindings in the parent function which come before their definition (Example 1). They can also capture members of the parent struct, if the code is part of a binding inside a struct.

You can use `_` to define a lambda based on an existing function. Just make a normal call and replace the lambda inputs with `_` (Example 5).

If lambda is assigned to a variable, it can invoke itself from inside (Example 6). This can be used to implement recursive calls.

**Examples**

1. `rr = fn(nothing -> int) { x + y } #here x and y are captures from parent function/struct`
2. `test = fn(x:int -> PlusFunc) { fn(y:int -> int) { y + x} } #this function returns a lambda`
3. `fn(x:int -> int) { x+1} (10) #you can invoke a lambda at the point of declaration`
4. `process = (x:int, y:float, z: (string -> float)) { ... } #a function that accepts a lambda`
5. `lambda1 = process(10, _, _) #defining a lambda based on existing function`
6. `ff = fn(x:int -> int) { ff(x+1)}`

## Generics

Generic types are defined using functions that return a `type` (a type argument) and use `[]` instead of `()` . These functions are compile time (because anything related to `type` must be) (Example 1). 

Note that arguments or functions of type `type` must be named like a type, not like a binding, and must receive value at compile time. This means that you cannot use a runtime dynamic binding value as a type. You also cannot assign a function that receives or return a type to a lambda. Because lambdas are a runtime concept. Note that a generic function's input of form `T|U` means caller can provide a union binding which has at least two options for the type, it may have 2 or more allowed types.

If a generic type is not passed in a function call (and it is at the end of argument list), compiler will infer it (Example 6). 

**Examples**

1. 
```
LinkedList = fn[T: type -> type]
{
	Node = struct (
		data: T,
		next: Node|nothing
	)
	Node|nothing
}
```
2. `process = fn(x: LinkedList[int] -> int)`
3. `process = fn(T: type, ll: LinkedList[T] -> ...`
4. 
```
process = (T: type, data: List[T] ...
pointer = process(int, _) #right, type of pointer is fn(int, List[int])
```
5. `process = fn(T: type, x: [T], index: int -> T) { x[index] }`
6. 
`push = fn(data: T, stack: Stack(T), T: type -> Stack[T]){...}`
`resutl = push(int_var, int_stack)`


