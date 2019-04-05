# Type system

Types are blueprints which are used to create values for bindings. Types can be basic (integer number, character, ...) or compound (sequence, map, struct, ...).

## Basic types

**Syntax**: `int`, `float`, `byte`, `char`, `string`, `bool`, `nothing`

**Notes**:

1. `int` type is a signed 8-byte integer data type.
2. `float` is double-precision 8-byte floating point number.
3. `byte` is an unsigned 8-bit number.
4. `char` is a single character.
  - Character literals should be enclosed in single-quote (e.g. `'a'`).
5. `string` is a sequence of characters.
  - String literals should be enclosed in double quotes.
  - To represent double quote itself inside a string, you can use `\"`.
6. `bool` type is same as int but with only two valid values.`true` is 1 and `false` is 0.
7. `nothing` is a special type which is used to denote empty/invalid/missing data. This type has only one value which is the same identifier.

**Examples**

1. `int_val = 12`
2. `float_val = 1.918`
3. `char_val = 'c'`
4. `bool_val = true`
5. `str1 = "Hello world!"`
6. `str2 = "Hello" + "World!"`
7. `n: nothing = nothing`
8. `byte_val: byte = 119`

## Sequence

1. Sequence is similar to array in other languages. It represents a fixed-size block of memory with elements of the same type, `T`, and is shows with `[T]` notation. 
2. You can initialize a sequence with a sequence literal (Example 1).
3. You refer to elements inside sequence using `x[i]` notation where `i` is index number. 
4. `[]` represents an empty sequence.
5. Referring to an index outside sequence will throw a runtime error.
6. Core defines built-in functions for sequence for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...`.

**Examples**

1. `x = [1, 2, 3, 4]`
2. `x: [[int]] = [ [1, 2], [3, 4], [5, 6] ] #a matrix of integer numbers`
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


