# Type system

Types are blueprints which are used to create values for bindings. Types can be basic (integer number, character, ...) or compound (sequence, map, struct, ...).

## Basic types

**Syntax**: `int`, `float`, `byte`, `char`, `string`, `bool`, `nothing`

**Notes**:`

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
4. `int_var = x[10]`

## HashMap

1. HashMap is a hash table of key values.
2. You can use `[KeyType:ValueType]` to define a map type. 
3. When reading from a map, you will get runtime error if value does not exist in the map.
4. An empty map can be denoted using `[:]` notation.
5. Core defines built-in functions for maps for common operations: `slice, map, reduce, filter, anyMatch, allMatch, ...`

**Examples**

1. `pop = ["A":1, "B":2, "C":3]`
2. `data = pop["A"]`

## Enum

1. You can prefix any sequence literal and `enum` keyword and it will be an enum type
2. Example: `MyEnumType = enum [sequence of literals]`
3. Variables of enum type must accept values of exactly what is specified inside the sequence, nothing else, even if they have equivalent value.
4. You can use a map to decide something based on enum value (Example 2). 
5. In case of 4, Compiler will make sure you have covered all possible types, and if not, will issue a warning.

**Examples**

1.
```rust
saturday=1
sunday=2
...
DayOfWeek = enum [saturday, sunday, ...]
```
2. `x = [saturday: "A", sunday: "B", ...][my_day_of_week]`

## Union

1. Bindings of union type, can store any of multiple pre-defined types.
2. Union type are shown as `T1|T2|T3|...`. 
3. You can destruct a binding of union type. 
4. Union destruction will give you a list of `T|nothing` values for each inner type of the union. 
5. During destruction, you can use `_` to ignore one or more of outputs.

**Examples**

1. `int_or_float: int|float = 11`
2. `int_or_float: int|float = "ABCD"`
3. `int_or_nothing, float_or_nothing = int_or_float_or_nothing_value`
4. 
```rust
#assuming check function is already defined
x: int|string|float = getData()
result = check(x, fn(i:int -> boolean) { ... }) //
         check(x, fn(s: string -> boolean) {...}) //
         check(x, fn(f:float->boolean){...})
```
5.
```rust
#although T type can be at any position in x's original type, but inside hasType T is the first type so "a" will be corresponding to type T
hasType = fn(x: T|U, T: type, U: type -> bool) {
	a,_ = x
	a!=nothing
}
```

## Struct

1. A struct, similar to C, represents a set of related named binding definitions without values. 
2. To create a binding based on a struct, you should use a struct literal (e.g. `Type(field1:value1, field2:value2, ...)`.
3. You can define a struct type without named.
4. You can use destruction to access unnamed fields inside a struct(Example 7).

**Examples**

1. `Point = struct (x:int, y:int) #defining a struct type`
2. `point2 = Point(x:100, y:200) #create a binding of type Point`
3. `point1 = struct(int,int)(100, 200) #untyped struct`
4. `point4 = Point(x:point3.x, y : 101} #update a struct based on existing struct binding`
5. `x,y = point1 #destruction to access struct data`
6. `another_point = Point(x:11, y:my_point.y + 200)`
7. `_, x = point1 #You can use _ during destruction to ignore one or more of results
8.
```rust
process = fn(x: struct (id:int, age:int) -> int) { x.age }
process2 = fn(x: struct (int, int) -> int) { 
	_,a = x
    a
}
```

## Named types

1. You can name a type so you will be able to refer to that type later in the code.
2. Type names must start with a capital letter to be distinguished from bindings.
3. You define a named type similar to a binding: `NewType = UnderlyingType`.
4. The new type has same binary representation as the underlying type but it will be treated as a different type.
5. You have seen examples of named types in previous sections (Union, enum, ...).

**Examples**

1. `MyInt = int`
2. `IntArray = [int]`
3. `Point = struct {x: int, y: int}`

## Type alias

1. You can use `T : X` notation to define `T` as another spelling for type `X` type.
2. In this case, `T` and `X` will be exactly the same thing.
3. You can use a type alias to prevent name conflict when importing modules.

**Examples**

1. `MyInt : int`
2. `process = fn(x:MyInt -> int) { x }`

## Type name resolution

1. Order of search to resolve a type name:
  A. Current function
  B. Closure
  C. Module level
2. At any level, if there are multiple candidates there will be a compiler error.
3. Two named types are never equal. 
4. Two types T1 and T2 are identical/assignable/exchangeable if they have the same structure (e.g. `int|string` vs `int|string`).

## Casting

1. For casting between primitive types (e.g. float to int), core functions are provided.
2. In order to cast across named types, you will need to write an identity function (a function that only returns its input), but with correct types (Example 1).
3. Note that, there is no automatic casting provided. All type changes must be explicitly specified in the code.
4. Literals (e.g. `1` or `"Hello world"`) will get value of the most primitive associated type inferred (`int`, `string`, ...). 
5. Based on 4, you cannot assign a literal to a named type without casting. Because for example `1` literal is an `int` literal not a named type that maps to `int`.

**Examples**

1. 
```rust
MyInt = int
toInt = fn(x: MyInt -> int) { x }
toMyInt = fn(x: int -> MyInt) { x }
h: MyInt = getMyInt()
g = toInt(h)
j = toMyInt(g)
```
