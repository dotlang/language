# Functions

Functions (or lambdas) are a type of binding which can accept a set of inputs and give an output. 

For example `fn(int,int -> int)` is a function type (which accepts two integer numbers and gives an integer number) and `fn(x:int, y:int -> int) { x+y }` is function literal. 

For generics (types and functions) see Advanced section.

## Declaration

1. `functionName = fn(name1: type1, name2: type2... -> OutputType) { code block }`
2. Note that functions are namaed camelCased.
3. Functions contain a set of bindings and the last expression in the code block determines function output.
4. There is no function overloading.
5. You can alias a function by defining another binding pointing to it (Example 8). 
6. If a function has no input, you can can eliminate input/output type declaration part (Example 13). In this case, compiler will infer output type.
7. Optional arguments: When calling a function, you can ommit arguments that are at the end and accept `nothing` (Example 14).
8. If a function is being called with literals (compile time known values), compiler will try to evaluate it during compilation. 
9. Above point is used in generic types (Example 15).
10. Module level functions that start with `_test` and have no input are considered unit test functions. You can later instruct compiler to run them (Example 16).

**Examples**

```rust
01. myFunc = fn(x:int, y:int -> int) { 6+y+x }
02. log = fn(s: string -> nothing) { print(s) } #this function returns nothing, pun not intended
03. process2 = fn(pt: Point -> struct (int,int)) { return struct(int,int)(pt.x, pt.y) } #this function returns a struct
05. process = fn(x: int|Point -> int) { ... } #this function can accept either int or Point type as input or int|Point type
06. _,b = process2(myPoint) #ignore second output of the function
07. 
process = fn(x:int -> int) 
{ 
  #if x<10 return 100, otherwise return 200
  [x<10: 100, x>=10: 200][true]
}
08. process = fn(x:int -> int) { x+1 }, process2 = process
09. sorted = sort(my_sequence, fn(x,y -> int) { x-y })
10. Adder = fn(int,int->int) #defining a named type based on a function type
11. sort = fn(x: [int], comparer: fn(int,int -> bool) -> [int]) {...} #this function accepts a function
12. map = fn(input: [int], mapper: fn(int -> string) -> [string])
13. process = fn{ 100 }
14.
seq = fn(start_or_length:int, end:int|nothing -> ...)
...
x = seq(10)
y = seq(1,10)
15. 
add = fn(a:int, b:int ->int) { a+b }
g = add(1,2)
16. 
_testProcessWithInvalidInput = fn{...}
```

## Function call resolution

1. We use a static dispatch for function calls. 
2. Also because you cannot have two functions with the same name, it is easier to find what happens with a function call.
3. If `MyInt = int`, you cannot call a function which needs an `int` with a `MyInt` binding.
4. Fucntion resolution is done similar to type name resolution. 
5. Parameter types must be "compatible" with function arguments, or else there will be a compiler error. 
6. For example if function argument type is `int | nothing` and parameter is an `int` it is a valid function call (But not the other way around).

## Lambda (Function literal)

1. All functions are lambdas.
2. Functions are closure. So they have access to bindings in parent contexts (Module or parent function).
3. You can use `_` to define a lambda based on an existing function. Just make a normal call and replace the lambda inputs with `_` (Example 4).
4. If lambda is assigned to a variable, it can invoke itself from the inside (Example 5). This can be used to implement recursive calls.

**Examples**

```js
1. 
rr = fn(nothing -> int) { x + y } #here x and y are captures from parent function/struct
2. 
test = fn(x:int -> PlusFunc) { fn(y:int -> int) { y + x } } #this function returns a lambda
3. 
fn(x:int -> int) { x+1} (10) #you can invoke a lambda at the point of declaration
4. 
lambda1 = process(10, _, _) #defining a lambda based on existing function
5. 
ff = fn(x:int -> int) { ff(x+1) }
```
