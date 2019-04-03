# Type system

Types are blueprints which are used to create values for bindings. Types can be simple or compound (sequence, map, struct, ...).

Simple type is a type which can be described using an identifier without any characters (e.g `MyCustomer` is a simgple type but `[int]` is not).

## Basic types

**Syntax**: `int`, `float`, `char`, `byte`, `bool`, `string`, `nothing`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `char` is a single character, represented as an unsigned byte.
4. Character literals should be enclosed in single-quote.
5. String literals should be enclosed in double quotes. 
6. String literals enclosed in backtick can be multiline and escape character `\` will not be processed in them.
7. `bool` type is same as int and `true` is 1, `false` is 0.
8. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.
9. `byte` is an unsigned 8-bit number.

**Examples**

1. `x = 12`
2. `x = 1.918`
3. `x = 'c'`
4. `g = true`
5. `str = "Hello world!"`
6. `str2 = "Hello" + "World!"`

## Sequence

Sequence is similar to array in other languages. It represents a fixed-size block of memory with elements of the same type, `T` and is shows with `[T]` notation. You can initialize a sequence with a sequence literal (Example 1).

You refer to elements inside sequence using `x[i]` notation where `i` is index number. Referring to an index outside sequence will return `nothing`. Putting an extra comma at the end of a sequence literal is allowed. `[]` represents an empty sequence.

Core defines built-in functions for sequence for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...` plus functions for safe get where they return `T|nothing`.

**Examples**

1. `x = [1, 2, 3, 4]`
2. `x = [ [1, 2], [3, 4], [5, 6] ] #a 2-D sequence of integer numbers`
3. `x = [1, 2]+[3, 4]+[5, 6]] #merging multiple sequences`
4. `int_or_nothing = x[10]`

## Map

You can use `[KeyType:ValueType]` to define a map type. When reading from a map, you will get `nothing` if value does not exist in the map.

An empty map can be denoted using `[:]` notation. Putting an extra comma at the end of a map literal is allowed.

Core defines built-in functions for maps for common operations: `map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

1. `pop = ["A":1, "B":2, "C":3]`
2. `data = pop["A"]`

## Enum

You can prefix any compile time sequence and `enum` keyword and it will be an enum type: `NewTypeName = enum [sequence of literals]`
Note that sequence can have types too and it can be used with generics (Example 1). This is output of the core function that returns type of a union binding.
variables of enum type must accept values of exactly what is specified inside sequence, nothing else, even if they have same value.

You can use a map to decide something based on enum value. Compiler will make sure you have covered all possible types.

**Examples**

1. `NumericType = enum [int, float]` 
2.
```
saturday=1
sunday=2
...
DayOfWeek enum [saturday, sunday, ...]
```
3. `x = [saturday: "A", sunday: "B", ...][my_day_of_week]`

## Union

Bindings of a union type, have ability to hold multiple different types and are shown as `T1|T2|T3|...`.  You can destruct a binding of union type. This will give you a list of values each of type `T|nothing` for each type of the union based on type of the binding (except nothing itself). You can use `_` to ignore one or more possible outputs.

**Examples**

1. `int_or_float: int|float = 11`
2. `int_or_nothing, float_or_nothing = int_or_float_or_nothing_value`
3. 
```
x: int|string|float = getData()
result = check(x, fn(i:int -> boolean) { ... }) //
         check(x, fn(s: string -> boolean) {...}) //
         check(x, fn(f:float->boolean){...})
```
4.
```
#although T type can be at any position in x's original type, but inside hasType T is the first type so a will be corresponding to type T
hasType = fn(x: T|U, T: type, U: type -> bool) {
	a,_ = x
	a!=nothing
}
```

## Struct

A struct (Similar to struct in C), represents a set of related binding definitions without values. To provide a value for a struct, you can use either a typed struct literal (e.g. `Type(field1:value1, field2:value2, ...)`, note that field names are mandatory. 

You can use destruction to access unnamed fields inside a struct(Example 7).

Struct literals must be prefixed by their type or parent value. When defining a struct type (either using named type or inline type) field types is mandatory but field names is optional (Example 11).

**Examples**

1. `Point = struct (x:int, y:int) #defining a struct type`
2. `point2 = Point(x:100, y:200) #create a binding of type Point`
3. `point1 = struct(int,int)(100, 200) #untyped struct`
4. `point4 = Point(x:point3.x, y : 101} #update a struct based on existing struct binding`
5. `x,y = point1 #destruction to access struct data`
6. `another_point = Point(x:11, y:my_point.y + 200)`
7. `_, x = point1 #another way to access untyped struct data`
11.
```
process = fn(x: struct (id:int, age:int) -> int) { x.age }
process = fn(x: struct (int, int) -> int) { 
	_,a = x
    a
}
```

## Named types

You can name a type so you will be able to refer to that type later in the code. Type names must start with a capital letter to be distinguished from bindings. You define a named type similar to a binding: `NewType = UnderlyingType`.The new type has same binary representation as the underlying type but it will be treated as a different type.

You can use casting operator to convert between a named type and its underlying type (Example 4). You can define named type inside a function.

**Examples**

1. `MyInt = int`
2. `IntArray = [int]`
3. `Point = struct {x: int, y: int}`
4. `x = 10`, `y = MyInt(10)`

## Type alias

You can use `T : X` notation to define `T` as another spelling for type `X`. In this case, `T` and `X` will be the same thing, so you cannot define two functions with same name for `T` and `X`.

You can use a type alias to prevent name conflict when importing modules or inside a function.

**Examples**

1. `MyInt : int`
2. `process = fn(x:int -> int) { 10}`
3. `process = fn(x:MyInt -> int)` Error! `process:(int->int)` is already defined.

## Type argument

These are binding of type `type`. You can use these bindings anywhere you need (inside function arguments, part of a struct, ...) but their value must be specified at compile time.
More in "Generics" section.

## Type name resolution

To resolve a type name, first closure level types and then module-level types will be searched for a type name or alias with the same name. At any scope, if there are multiple candidates there will be a compiler error.

Two named types are never equal. Otherwise, two types T1 and T2 are identical/assignable/exchangeable if they have the same structure (e.g. `int|string` vs `int|string`).

## Casting

In order to cast across named types, you will need to write an identity function (a function that only returns its input), but with correct types.

**Examples**

1. 
```
MyInt = int
toInt = fn(x: MyInt -> int) { x }
h: MyInt = ...
g:int = toInt(h)
```

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

