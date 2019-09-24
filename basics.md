# Basics

## Main features

01. **Import a module**: `queue = import("/core/std/queue")` (you can also import from external sources like GitHub).
02. **Primitive types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `type`, `nothing`. 
03. **Bindings**: `my_var:int = 19` (type is optional, everything is immutable).
04. **Sequence**: `my_array = [1, 2, 3]` (type of `my_array` is `[int]`, sequence of integers).
05. **HashMap**: `my_map = ["A":1, "B":2, "C":3]` (type of `my_map` is `[string:int]`, hash map of string to integer)
06. **Named type**: `MyInt = int` (Defines a new type `MyInt` with same binary representation as `int`).
07. **Type alias**: `IntType : int` (A different name for the same type).
08. **Struct type**: `Point = struct(x: int, y:int, data: float)` (Like C `struct`).
09. **Struct literal**: `location = Point(x:10, y:20, data:1.19)`.
10. **Union type**: `MaybeInt = int | nothing` (Can store either of two types, note that this is a named type).
11. **Function**: `calculate = fn(x:int, y:int -> float) { x/y }` (Functions are all lambdas, the last expression in the body is return value).
12. **Concurrency**: `my_task := processData(x,y,z)` (Start a new micro-thread and evaluate an expression in parallel).
13. **Generics**: `ValueKeeper = fn(T: type -> type) { struct(data: T) }` (A function that returns a type)
14. **Generics**: `push = fn(x: T, stack: Stack(T), T: type -> Stack(T)) { ... }`
15. **Enum**: `DayOfWeek = enum [saturday, sunday, monday, tuesday, wednesday, thursday, friday]`

## Symbols

01. `#`   Comment
02. `.`   Access struct members
03. `()`  Function declaration and call, struct declaration and literals
04. `{}`  Code block, selective import
05. `[]`  Sequence and hashMap
06. `|`   Union data type 
07. `->`  Function declaration
08. `//`  Nothing-check operator
09. `:`   Type declaration (binding, struct field and function inputs), type alias, struct literal
10. `=`   Binding declaration, named type
11. `_`   Place-holder (lambda creator and assignment)
12. `:=`  Parallel execution
13. `..`  Access inside module
14. `///` Select (oncurrency)

## Reserved keywords

**Primitive data types**: `int`, `float`, `char`, `byte`, `bool`, `string`, `nothing`, `type`

**Operators**: `and`, `or`, `not`

**Data type identifiers**: `fn`, `struct`, `enum`

**Reserved identifiers**: `true`, `false`, `import`

## Coding style

1. Use 4 spaces indentation.
2. You must put each statement on a separate line. Newline is the statement separator.
3. Naming: `SomeDataType`, `someFunction`, `some_data_binding`, `some_module_alias`.
4. If a function returns a type (generic types) it should be named like a type.
5. If a binding is a reference to a function, it should be named like that function.
6. You can use `0x` prefix for hexadecimal numbers and `0b` for binary.
7. You can use `_` as digit separator in number literals.

## Operators

Operators are mostly similar to C language:

* Conditional operators: `and, or, not, ==, !=, >=, <=`
* Arithmetic: `+, -, *, /, %, %%, >>, <<, **`
* Note that `==` will do a comparison based on contents of its operands.
* `A // B` will evaluate to A if it is not `nothing`, else it will be evaluated to B (e.g. `y = x // y // z // 0`).
* Conditional operators return `true` or `false` which are equal to `1` and `0` respectively when used as index of a sequence.
* Comments can appear anywhere in the code and start with `#`. Anything after `#` till end of the line is comment.

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

```swift
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

```swift
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

```swift
pop = ["A":1, "B":2, "C":3]
data = pop["A"]
```

## Enum

1. You can prefix any sequence literal with `enum` keyword and it will be an enum type.
2. Example: `MyEnumType = enum [sequence of literals]`
3. Variables of enum type must accept values of exactly what is specified inside the sequence, nothing else, even if they have equivalent value.
4. You can combine enum with a map to implement execution control. 
5. In case of 4, Compiler will make sure you have covered all possible types, and if not, will issue a warning.

**Examples**

```swift
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
3. You can destruct a binding of union type. 
4. Union destruction will give you a list of `T|nothing` values for each inner type of the union. 
5. During destruction, you can use `_` to ignore one or more of outputs.

**Examples**

```swift
int_or_float: int|float = 11
int_or_float: int|float = "ABCD"
int_or_nothing, float_or_nothing = int_or_float_or_nothing_value

#assuming check function is already defined
x: int|string|float = getData()
result = check(x, fn(i:int -> boolean) { ... }) //
         check(x, fn(s: string -> boolean) {...}) //
         check(x, fn(f:float->boolean){...})
	 
#although T type can be at any position in x's original type, 
#but inside hasType T is the first type so "a" will be corresponding to type T
hasType = fn(x: T|U, T: type, U: type -> bool) {
	a,_ = x
	a != nothing
}
```

## Struct

1. A struct, similar to C, represents a set of related named types. 
2. To create a binding based on a struct, you should use a struct literal (e.g. `Type(field1:value1, field2:value2, ...)`.
3. You can define a struct type without a name (unnamed type).
4. You can use destruction to access unnamed fields inside a struct.
5. You can add a function after definition of a struct type by `fn{...}` notation. This will be executed on each instantiation of that type and can be used for logging or validation purposes.

**Examples**

```swift
#defining a struct type
Point = struct (x:int, y:int) 

#create a binding of type Point, defined above
point2 = Point(x:100, y:200) 

#untyped struct
point1 = struct(int,int)(100, 200) 

#struct type with no field names
Point = (int, int)

#update an existing struct binding and save as a new binding
point4 = Point(x:point3.x, y : 101)

#destruction to access struct data
x,y = point1

another_point = Point(x:11, y:my_point.y + 200)

#You can use _ during destruction to ignore one or more of results
_, x = point1 

process = fn(x: struct (id:int, age:int) -> int) { x.age }

process2 = fn(x: struct (int, int) -> int) { 
	_,a = x
    a
}

PointTemplate = struct(x:int, y:int) 
	fn{
		assert(x>0)
		assert(y<0)
		assert(x+y<100)
		log("a new instance of point-template is created")
		validateCheck(x, y)
	}
```

## Named types

1. You can name a type so you will be able to refer to that type later in the code.
2. Type names must start with a capital letter to be distinguished from bindings.
3. You define a named type similar to a binding: `NewType = UnderlyingType`.
4. The new type has same binary representation as the underlying type but it will be treated as a completely different type.
5. You have seen examples of named types in previous sections (Union, enum, ...).

**Examples**

```swift
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

```swift
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

1. For casting between primitive types (e.g. float to int), core functions are provided.
2. In order to cast across named types, you will need to write an identity function (a function that only returns its input), but with correct types (Example 1).
3. Note that, there is no automatic casting provided. All type changes must be explicitly specified in the code.
4. Literals (e.g. `1` or `"Hello world"`) will get value of the most primitive type inferred by the compiler (`int`, `string`, ...). 
5. Based on 4, you cannot assign an untyped literal to a named type without casting. Because for example `1` literal is an `int` literal not a named type that maps to `int`.

**Examples**

```swift
MyInt = int
toInt = fn(x: MyInt -> int) { x }
toMyInt = fn(x: int -> MyInt) { x }
h: MyInt = getMyInt()
g = toInt(h)
j = toMyInt(g)
```

# Functions

Functions (or lambdas) are a type of binding which can accept a set of inputs and gives an output. 

For example `fn(int,int -> int)` is a function type (which accepts two integer numbers and gives an integer number) and `fn(x:int, y:int -> int) { x+y }` is a function literal. 

For generics (types and functions) see Advanced section.

## Declaration

1. `functionName = fn(name1: type1, name2: type2... -> OutputType) { code block }`
2. Note that functions are namaed camelCased.
3. Functions contain a set of bindings and the last expression in the code block determines function output.
4. There is no function overloading. Functions should have unique names in their defining module.
5. You can alias a function by defining another binding pointing to it (example A). 
6. If a function has no input, you can can eliminate input/output type declaration part (Example B). In this case, compiler will infer output type.
7. Optional arguments: When calling a function, you can ommit arguments that are at the end and accept `nothing` (Example C).
8. If a function is being called with literals (compile time known values), compiler will try to evaluate it during compilation (e.g. generics). 
9. Module level functions that start with `_test` and have no input are considered unit test functions. You can later instruct compiler to run them (Example D).
10. There is `assert` core function that can be used for checking assertions. You can disable assertions as a compiler flag.

**Examples**

```swift
myFunc = fn(x:int, y:int -> int) { 6+y+x }

log = fn(s: string -> nothing) { print(s) } #this function returns nothing, pun not intended

process2 = fn(pt: Point -> struct (int,int)) { return struct(int,int)(pt.x, pt.y) } #this function returns a struct

process = fn(x: int|Point -> int) { ... } #this function can accept either int or Point type as input or int|Point type

_,b = process2(myPoint) #ignore second output of the function

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

```swift
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

```swift
#A
x : int = 12

#type is inferred
g = 19.8 

#B
a,b = struct(int,int){1, 100}

#C
a,_ = point

a,_ = single_element_struct
```

