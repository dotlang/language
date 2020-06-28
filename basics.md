# Type system

Types are blueprints which are used to create values for bindings. 

Types can be basic (integer number, character, ...) or compound (sequence, map, struct, union).

## Basic types

**Syntax**: `int, float, byte, char, string, bool, nothing`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `byte` is an unsigned 8-bit number.
4. `char` is a single unicode character.
  - Character literals should be enclosed in single-quote (e.g. `'a'`).
5. `string` is a sequence of characters.
  - String literals should be enclosed in double quotes.
  - To represent double quote itself inside a string, you can use `\"`.
6. `bool` type is same as int but with only two valid values. `true` is 1 and `false` is 0.
7. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.

**Examples**

```perl    
int_val = 12
float_val = 1.918
char_val = 'c'
bool_val = true
str1 = "Hello world!"
str2 = "Hello" + "World!"
n: nothing = nothing
byte_val: byte = 119 #note that it is optional to mention type of a binding after its name
```

## Sequence

1. Sequence is similar to array in other languages. It represents a fixed-size block of memory with elements of the same type, `T`, and is shows with `[T]` notation. 
2. You can initialize a sequence with a sequence literal (First example).
3. You refer to elements inside sequence using `x[i]` notation where `i` is index number. 
4. `[]` represents an empty sequence.
5. Referring to an index outside sequence will throw a runtime error.
6. Core defines built-in functions for sequence for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

```perl    
x = [1, 2, 3, 4]

#a 2D matrix of integer numbers
x: [[int]] = [ [1, 2], [3, 4], [5, 6] ] 

#merging multiple sequences
x = [1, 2]+[3, 4]+[5, 6] 

int_var = x[10]

#this is definition of string type
string = [char] 
```

## HashMap

1. HashMap is a hash table of key values.
2. You can use `[KeyType:ValueType]` to define a map type. 
3. When reading from a map, you will get runtime error if value does not exist in the map.
4. An empty map can be denoted using `[:]` notation.
5. Core defines built-in functions for maps for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

```perl    
pop = ["A":1, "B":2, "C":3]
data = pop["A"]
```

## Enum

1. You can prefix any sequence literal with `enum` keyword and it will be an enum type.
2. Example: `MyEnumType = enum [sequence of literals]`
3. Variables of enum type must accept values of exactly what is specified inside the sequence, nothing else, even if they have equivalent value.
4. You can combine enum with a map to implement execution control. 
5. In case of 4, Compiler will make sure you have covered all possible types, and if not, will issue a warning.
6. Also core will have functions to implement `switch` on enums which make sure all cases are covered.

**Examples**

```perl    
saturday=1
sunday=2
...
DayOfWeek = enum [saturday, sunday, ...]

x = [saturday: "A", sunday: "B", ...][my_day_of_week]
 
#definition of type bool
true=1
false=0
bool = enum [true, false] 
```

## Union

1. Bindings of union type, can store any of multiple pre-defined types.
2. Union type are shown as `T1|T2|T3|...`. 
3. You can use casting to check what's inside a union binding or cast it to a type.

**Examples**

```perl    
int_or_float: int|float = 11
int_or_float: int|float = "ABCD"

my_int = int(int_or_float) #this will fail if input binding does not have an int
maybe_int = int|nothing(int_or_float) #if binding has a float, you will get a nothing as a result of this cast
```

## Struct

1. A struct, similar to C, represents a set of related named types. 
2. To create a binding based on a struct, you should use a struct literal (e.g. `Type{field1:value1, field2:value2, ...}`.
3. Type name in struct litearl and field names in struct type are mandatory.
4. Optional fields: When creating a value of struct type and don't specify value for fields which can be `nothing`, they will be set to `nothing`.
5. Edit: You can create a new struct value based an existing value. This will merge them all. (Example A).
6. If struct literal type can be inferred from context, you can omit type and use `&{...}` notation (Example B).

**Examples**

```perl    
#defining a struct type
Point = struct {x:int, y:int}

#create a binding of type Point, defined above
point2 = Point{x:100, y:200}
point2new = Point{100, 200}

#update an existing struct binding and save as a new binding
point4 = Point{x:point3.x, y : 101}

process = fn(x: struct {id:int, age:int} -> int) { x.age }
    
#A
another_point = Point{my_point, x:10}
third_point = Point{point1, z: 10, delta: 9}

#B
switchOnValue(my_number, &{value: 10, handler: AAA}, &{12, BBB}, &{13, CCC})
```

## Named types

1. You can name a type so you will be able to refer to that type later in the code.
2. Type names must start with a capital letter to be distinguished from bindings.
3. You define a named type similar to a binding: `NewType = UnderlyingType`.
4. The new type has same binary representation as the underlying type but it will be treated as a completely different type.
5. You have seen examples of named types in previous sections (Union, enum, ...).

**Examples**

```perl    
MyInt = int
IntArray = [int]
Point = struct (x: int, y: int)
```

## Type alias

1. You can use `T : X` notation to define `T` as another spelling for type `X`.
2. In this case, `T` and `X` will be exactly the same thing.
3. You can use a type alias to prevent name conflict when importing modules.
4. `X` on the right must be a type name. It cannot be definition of a type.

**Examples**

```perl    
MyInt : int
process = fn(x:MyInt -> int) { x }
```

## Type name resolution

1. Order of search to resolve a type name:
- Current function
- Closure
- Module level
2. At any level, if there are multiple candidates there will be a compiler error.
3. Two named types are never equal. 
4. Two types T1 and T2 are identical/assignable/exchangeable if they have the same structure (e.g. `int|string` vs `int|string`).

## Casting

1. We use `T(value)` notation to cast value to a specific type.
2. Casting can be done for primitive types, named types or unions.
3. For union, you can use casting to get underlying type. If you cast a union binding to a wrong type, there will be a runtime error.
4. You can cast a union to `T|nothing` to do a safe cast. You will get `nothing` it type T is not inside the union binding.
5. Literals (e.g. `1` or `"Hello world"`) will get value of the most primitive type inferred by the compiler (`int`, `string`, ...). 
5. Based on 4, you cannot assign an untyped literal to a named type without casting. Because for example `1` literal is an `int` literal not a named type that maps to `int`.

**Examples**

```perl    
MyInt = int
myint_var = MyInt(12)
```

# Functions

Functions (or lambdas) are a type of binding which can accept a set of inputs and gives an output. 

For example `fn(int,int -> int)` is a function type (which accepts two integer numbers and gives an integer number) and `fn(x:int, y:int -> int) { x+y }` is a function literal. 

For generics (types and functions) see Advanced section.

## Declaration

1. `functionName = fn(name1: type1, name2: type2... -> OutputType1, OutputTyp2, ...) { code block }`
2. Function names are camelCased.
3. Functions contain a set of bindings and the last expression in the code block determines function output.
4. If calling a function that returns multiple bindings, you can use `_` to ignore one of them.
5. There is no function overloading. Functions should have unique names in their context.
6. You can alias a function by defining another binding pointing to it (example A). 
7. If a function has no input, you can can eliminate input/output type declaration part (Example B). In this case, compiler will infer output type.
8. Optional arguments: When calling a function, you can ommit arguments that are at the end and accept `nothing` (Example C).
9. If a function is being called with literals (compile time known values), compiler will try to evaluate it during compilation (e.g. generics). 
10. Module level functions that start with `_test` and have no input/output are considered unit test functions. You can later instruct compiler to run them (Example D).
11. There is `assert` core function that can be used for checking assertions. You can disable assertions with a compiler flag.
12. You can chain multiple nested function calls in reverse order via `::` operator (Example E).

**Examples**

```perl    
myFunc = fn(x:int, y:int -> int) { 6+y+x }

tester = fn(x:int -> int, string) {x+1, "a"}
int1, str1 = tester(100)
int1, _ = tester(100)
_, str1 = tester(100)

log = fn(s: string -> nothing) { print(s) } #this function returns nothing, pun not intended

process2 = fn(pt: Point -> int,int) { pt.x, pt.y } #this function returns a struct

process = fn(x: int|Point -> int) { ... } #this function can accept either int or Point or int|Point as input

process = fn(x:int -> int) 
{ 
  #if x<10 return 100, otherwise return 200
  [x<10: 100, x>=10: 200][true]
}

#A
process = fn(x:int -> int) { x+1 }
process2 = process

sorted = sort(my_sequence, fn(x,y -> int) { x-y })

Adder = fn(int,int->int) #defining a named type based on a function type

sort = fn(x: [int], comparer: fn(int,int -> bool) -> [int]) {...} #this function accepts a function

map = fn(input: [int], mapper: fn(int -> string) -> [string]) ...

#B
process = fn{ 100 }

#C
seq = fn(start_or_length:int, end:int|nothing -> ...)
...
x = seq(10)
y = seq(1,10)

add = fn(a:int, b:int ->int) { a+b }
g = add(1,2)

#D
_testProcessWithInvalidInput = fn{...}

#E
resut = f(g(x)) 
result = x :: g :: f
# calculate average score for new good students
student :: filter(isGoodStudent, _) :: map(createNewStudent, _) :: calculateAverage
```

## Function call resolution

1. We use a static dispatch for function calls. 
2. Also because you cannot have two functions with the same name, it is easier to find what happens with a function call.
3. If `MyInt = int`, you cannot call a function which needs an `int` with a `MyInt` binding.
4. Fucntion resolution is done similar to type name resolution. 
5. Parameter types must be "identical/compatible" to function argument types, or else there will be a compiler error. 
6. For example if function argument type is `int | nothing` and parameter is an `int` it is a valid function call (But not the other way around).
7. When you need a function of type `fn(T->U)` any function that can accept T (or more) and returns U (or less) works fine.

## Lambda (Function literal)

1. All functions are lambdas.
2. Functions are closure. So they have access to bindings in parent contexts (Module or parent function).
3. You can use `_` to define a lambda based on an existing function. Just make a normal call and replace the lambda inputs with `_` (Example A).
4. If lambda is assigned to a variable, it can invoke itself from the inside (Example B). This can be used to implement recursive calls.

**Examples**

```perl    
rr = fn(nothing -> int) { x + y } #here x and y are captures from parent function/struct

test = fn(x:int -> PlusFunc) { fn(y:int -> int) { y + x } } #this function returns a lambda

fn(x:int -> int) { x+1} (10) #you can invoke a lambda at the point of declaration
#A
lambda1 = process(10, _, _) #defining a lambda based on existing function
#B
ff = fn(x:int -> int) { ff(x+1) }
```

# Bindings

1. A binding assigns an identifier to a typed immutable memory location. 
2. A binding's value can be a literal value, an expression or another binding.
3. The literal value can be of any valid type (integer number, function literal, struct literal, ...). 
4. Binding names must start with a lowercase letter (except bindings that define a generic type, more in Advanced section).
5. You can define bindings at module-level or inside a function. 
6. Module-level bindings can only have literals as their value. 
7. Type of a binding can be inferred without ambiguity from right side value, but you also have the option to specify the type (Example A).
8. If the right side of an assignment is a struct, you can destruct it into its elements by using comma separated values on the left side of `=` (Example B). 
9. In destruction, you can also use underscore to indicate you are not interested in one or more of those elements (Example C).
10. Binding name resolution is similar to type/function name resolution.

**Syntax**: 

1. `identifier = expression`
2. `identifier : type = expression`

**Examples**

```perl    
#A
x : int = 12

#type is inferred
g = 19.8 

#B
a,b = Tuple{1, 100}

#C
a,_ = point

a,_ = single_element_struct
```

# Resources

There are different types of resources which needs handling but we can categorize them into two main groups: Memory and others (sockets, network connections, DB connections, files, threads, ...).

The first type is handled via GC and the second type is automatically freed by runtime when the corresponding binding goes out of scope. These are similar to C++ destructors, but implemented only for scarce system resources and handle deallocation of those resources when they are no longer needed.

Any other mechanism to free/cleanup a resource, exposes mutation to the language which causes a lot of confusion.
