# Electron - Requests for Enhancement

N - A notation to join two arrays.
In Haskell we have:
```
qsort (p:xs) = qsort lesser ++ [p] ++ qsort greater
    where lesser  = filter (< p) xs
          greater = filter (>= p) xs
```
It uses `++` notation to merge two arrays. 
Why can't we use a `join` function? 
`func join(x: any[], y:any[]) -> any[]`
We can. 
This is approch of Go.

N - How to dump an object? core.

N - Example for DB and fake DB:
```
type DBInfo := ...
func select(db: DBInfo, s: table) ->
type FakeDBInfo := @DBInfo...
func select(db: FakeDBInfo, s: table) -> ...
```
Can we use this to fake a function?
```
func secondary() {
}
func primary(x: int) {
  secondary()
}
...
;test code - I want to primary call my secondary instead of default
;if secondary has some input which depends on primary's input, this can be achieved with subtyping.
primary(10)
```

N - Study Monad. Can we really live without them? yes I think we can.

N - Real-world use case: Connect to database.
How can we fetch result of a SELECT? 2D array
How can we create a dynamic query? string interpolation
How can we model INSERT? - hash
e.g. building a tuple at runtime based on result of select? no.
```
func queryDatabase(db: DBInfo, sql: string) -> cursor
func queryDatabase(db: DBInfo, sql: string) -> (fieldNames: string[], data: any[,])
...
var (fields, data) = queryDatabase(db, "SELECT * from Employees")
;type of data is a 2D array
var firstField: any = any[0][0]
```

N - RWUC (real-world use case) - How can I read a json file?
```
func parseJson(x: string) -> any
type Json := (name: string, value: Json | int | ...)
```

N - `LIKE` operator -> regex

N - To redirect:
```
func process(x:int, y:int, z:int) -> ...
func process(x:int, y:int) -> process(@$, 10)
```
We can apply `@` on `$` too!

Y - Regex operator.
This should be done in core functions, but as a shortcut:
```
x = ( data ~ '^hello' )
```
x will be an array containing all matches. You can use groups for matching.

N - Shall we add `in` operator? Check if data x is inside array.
we can define `find` function.
`func find(x: any[], data: any) -> bool`

N - review naming conventions
- We want distinct names for function, type and data.
- Options: `some_name`, `SomeName`, `someName`
current: `someFunctionName`, `my_var_name`, `SomeType`, `my_package_or_module`

N - Should `any` cover `none`?
I don't think so. So if `map` expects a fn whose output is `any` we cannot pass a lambda which returns nothing. 

Y - if hash does not have a key, `ht[key]` will return `none`.
But this does not make sense: `doWork(ht['non-exist'])` what will happen at runtime if `doWork` expects an int?
`if ( ht['noway'] :: none )` if key is not in hashtable.

Y - shall we use functions behind syntax for array and hash?
So developer can customize `arr[0]` or `ht["data"]` for his own types?
```
func queryValue(x: any[], y:int)->any
func queryValue(x: any=>any, k: any) -> any
func queryKeys(x: any=>any) -> AnyIterator
```
We won't let developer customize everything (`+`, `-`, ... or other custom operators).
But what can be application of this?
We can define `+` for tuples.
problem: `x+y` maybe at runtime type of x or y is not int and we won't know what function to call at compile time.
But primitives cannot be subtypes. So if type of x/y is `int` then definitely native add should be done.
`i = j * 5` is same as `i = mult(j, 5)` 
If you see them and don't know the meaning, you have to take a look at the code.
Either the library developer should provide doc about operator meaning or you should check the code.
So if PL does not support operator overloading, this does not solve "code readabiity" problem.
The only issue with operator overloading is "context". We have a previous understanding of `*` and expect a certain behavior.
If the library developer, has mis-used it, then we will get confused. But with method naming, at least there is a name which can be more descriptive than `*`. But shall we make decisions instead of developers? Why not let them make their own decisions?
The problem with operators can be exactly repeated for functions.
List of operators: `[]`, `+-*/`, `==`,`!=`, `++`, `--`, comparison, slice.
It should be minimum: 
- `opIndex` for `[]` reading and writing and slice for array and hash
- `opMath` for `+-*/** %`
- `opCompare` for `==, !=, <=, ...`
- `opIterate` for `++, --`
So if a type implements `+` it has to implement all math operators.
And this is only possible for non-primitive types (but you can implement for an alias).
And note that operators cannot mutate their input so all of them will return the result.
Advantage: We can define `type string := char[]` and overload operators for it. 
So string is not a primitive anymore.
result: string assignment is a reference assignment. to clone use `@`: `var str2 = [@str1]`
user can define his own data types which behave like an array.
what about slice? same as opIndex but with two int arguments.
hash-table syntax is just a function in core.
Because of immutability, you cannot override `=` operator. 
`func opAssign(x: Customer) -> Customer { return x }`
`func opAssign(x: Customer) -> Customer { return @x }`
Does not make sense.

Y - Maybe by using type alias we can stress that some types must be equal in a function.
```
type T
func add(x: T[], data: T)-> T    ;input must be an array and single var of the same type and same as output
add(int_array, "A") will fail
```

N - Cant we unify array and hash?

Y - what if we define string as `char[]` and override `+` operator for that? and len?

? - Find a good name.

? - Loading code on the fly.
`func loadCode(file: string)
