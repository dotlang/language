# Dotlang - Requests for Enhancement

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

Y - Loading code on the fly.
`func loadCode(file: string)`
How can we define type of a general function? `func(any)->any`
just mention in the core functionality

N - How can we define a function that can accept anything and return anything?
How can we define a function that accepts only one input and returns anything?
`type Function := func(any)->any`
`type SingleFunc := func(i:any)->any`
what does this mean?
`type SingleFunc := func(any,any)->any`
Why do we need to define a function that can accept "Anything in any number" and return anything?
even when we load a plugin at runtime, the input/output must be specified.
Or in map function.

Y - Remove extra operators overridable.
- OpIterate
- opMath
- opCompare we really dont need to compare. we just call some sort methdo with a lambda.
We also need to be able to overload `~` operator so we can have regex for strings.
we need `~` and something to concat. 
users should be able to customize this. 

N - unify function syntax
`type fadder := int -> int -> int`
`type fadder := func(int,int)->int`

Y - Why not provide regex as a function? Then we don't need the silly operator `~` for all types.

Y - To prevent confusion with numbers, shall we change add/remove operators?
`++` `--` as binary opertors
main use: for string.
we can provide `+` as a built-in operator that works on numbers and arrays.
It join arrays together.
Then we can eliminate `opAdd` and `opRemove` operator functions.

Y - Find a good name.
Notron
light
hotspot
Electron
spot
go/d+lang
something+lang
idlang
dotlang - it is simplest shape and also very powerful in english language and our language.

Y - can `f(1,2,3)` be redirected to `func f(x:int, y:int)`? 
According to subtyping, it can. `(1,2,3)` is like a Circle and `(x:int, y:int)` is like definition of a shape.
But this will be too confusing. 
Putting any rule against subtyping, will be agains gen but I think we have to.
First: function input is not a tuple, it is a series of arguments. So subtype and inheritance is not applied to the input list itself. Of course caller can use explode to prepare this list.
Second: So a call to `f(1,2,3)` have to call a function with name `f` and three input arguments. No less and no more.

N - If `A` has `x:int` and `B` has `x:int` then type `C` can inherit from both of them!
And it can be used as any of these two types.

N - Type hierarchy is created based on data and type names.
So `StackElement` is a different type from `any`. Although data-wise they are the same.

N - Can we provide a mechanism to organize code better?
How can a developer find a function?
Maybe we can force the single space: `func add` so if user want to find a function, he only needs to search for a specific pattern.
Maybe we can force a specific filename based on the types involved in functions.
Module is enough.

N - Can we make defining empty types easier?
`type Stack := %StackElement[]`
Empty types are defined using `%` prefix.

Y - Can we have `Circle | Shape` type?
No. Because they overlap. This is essentially `Shape`.
Overlap is not a problem, one type being subset of the other, is the problem.

N - When we define `type MaybeInt := Nothing | int` we are defining a new type! Aren't we?
Can we use this notation to provide some kind of generics?
`type MaybeType`
`type Maybe := None | MaybeType`
`func process() -> Maybe with { MaybeType := int }`?
`type VectorElement`
`type Vector := VectorElement[]`
`type IntVector := Vector with { VectorElement := int }`
`func append(x: Vector, y: VectorElement)->Vector` type of y is VectorElement.
No. No generics. It is tempting to say there should be a relation between function inputs but this should not be dealt with at syntax level.
You can put assertions inside function body to make sure appropriate arguments are passed to the function.

Y - Clarify about sum types. Is everything around `|` a type?
Even `None`? We can consider them as a simple type which has a single possible value which is the same.
Shouldn't we isolate them from other symbols? No. After all, they are just types. 
Special types which have single value.

N - Clarify more about types used in collections which mimic generics.

N - focus on performance issues.

N- Like in julia we can have dispatch checked with type:
`func work(x: T, y: T)-> ...` this will be invoked if type fo x and y are the same.
In Julia we can have: `myappend{T}(v::Vector{T}, x::T) = [v..., x]`
```
type VectorElement
type Vector := VectorElement[]
func append(x: Vector, y: VectorElement)->Vector
```
append definition should know that type of `y` is related to type of `x`. So if it is receiving a:
`type IntVector := int[]` - It should be aware that `VectorElement` is now `int`.

? - Think about method call dispatch with respect to multiple inheritance and polymorphism.
We can do this step by step:
- When function `f` is called with n inputs, we find all functions with same name and number of inputs, called candidate list.
- If call is made with names, drop functions whose inputs does not match with given argument names.
- Sort candidate list: Bottom-most one should be the one whose input types match with static type of arguments. This is the last option.  Top-most should be the one with types matching dynamic types (if exists).
- For each candidate, for each input, remove candidate it if it's type is not super-type of argument (according to subtype rules). 
- Define score for each candidate: distance between dynamic type of input and function parameter type.
- The one with minimum score is chosen. If we have multiple candidates, there will be runtime error.
- Starting with the first argument `a` with static type `Sa` and dynamic type `Da`.
  - For each function `f0` in the candidate list:
    - Let's call first input type `S0`.
    - if `S0` does not match with `(S1, Da)` type range, then discard `f0` from candidate list.
- After processing is done, choose the topmost function from candidate list.
- The possibilities on the caller-side are endless, so we should index and classify functions.
At compile time we know function name and number of arguments. Also we know the set of all candidates.
This will give us a list of `n` candidates from which we will need to select one at runtime.
q1. Is it possible to set this at compile time? Like developer says call this specific function.
q2. Can we use hash or some other method to make this faster?
`func f(x:int, y:int)` can be coded as `f/x/int/y/int` or `f_x_y_2/int/int`.
How can we quickly decide distance between two types? infinite means they are not related at all. zero means they are exactly the same.
`type Shape := (name: string)`
`type Shape2 := (name: string, r:float)`
`type Circle := (@shape, r:float, d: float)`
Distance between Shape and Circle is 2. Between Circle and Shape2 is 1.
each argument's type in function signature is either: primitive, array, hash, sum, tuple, named, any.
- primitive: type must match with corresponding variable being sent. If not, ignore candidate.
- array: arg must be array. calculate distance for array element's type.
- This should not be a ranking algorithm. Because ranking equals ambiguity for the developer.
Algorithm must be clear and simple and it's result will be either a single function or a runtime error.
We also may call a function where there is no definition for static types. We may use `any` version.
So we create a list of candidates. process them and drop those who don't pass tests. if result is a single function, call it, else runtime error.
But there can be multiple candidates:
```
func draw(Shape, Shape)
func draw(Circle, Circle)
...
draw(cir1, cir2)
```
Process each candidate. If it's better than current candidate, replace current. 
If it is the same, mark a flag and continue.
When search is finished, if flag it set, runtime error. Else call the current function.
This is basically a sort and rank algorithm. Just if there are two best options -> we throw error.
To measure "better than current candidate" we have to have a method to quantify this.
So problem of method dispatch boils than to comparing two functions against a call.
```
call: f(a,b,c,d)
f1: func f(ta,tb,tc,td)
f2: func f(Ta, Tb, Tc, Td)
```
- If call is being made with named arguments, this will help us drop more candidates before this step. But at this step, names don't really matter.
- With a scoring algorithm, we just need to compare a function implementation against the call.
```
call: f(Sa:Da,Sb:Db,Sc:Dc,Sd:Dd) - Sx:Dx are static (e.g. Shape) and dynamic (e.g. Circle) type of arguments
f1: func f(ta,tb,tc,td) - tx is type of function input
```
- if ( ta==Sa, tb==Sb, tc==Sc, td==Sd) score=0 (will be chosen only if no other candidates a better score)
- if ( ta==Da, tb==Db, tc==Dc, td==Dd) score=infinite (will definitely be chosen)
Type hierarchy is more like a graph. On the root is `any` and all empty types.
Below are single field types and so on.
We need to call an implementation which makes most use of provided fields. If we are passing 20 fields in total, the one that uses all of them (works with dynamic types) is the best choice. Obviously we cannot call a method which needs more parameters than what we have sent to it. Worst case: a function that does not use any of fields (all inputs are any or empty).
- Solution 1: Rank candidates, based on a score: number of fields they are using.
- Solution 2: Arg by arg, select functions that have highest fields covered for current argument.
Solution 2 makes sense because developer can control the dispatch by introducing appropriate functions which cover first arguments rather than all of them.
For sum type arguments, the typethat matches most fields is selected for comparison.

? - also make a syntax sugar for `loop`:
`loop(x:y) {...}` means `loop(y) (x) -> { ... }`

? - can we remove need to put `()` in function call/loop/if?

? - Implement a simple logic inference
```
;format: A is B, B is C -> A is C
type Sentence = (source: string, target: string)
func processSentence(s: string) -> Sentence[]
{
    return split(s, " is ")
}
func checkQuery(data: Sentence[], source: string) -> string | none 
{
    loop(s: data)
    {
        if ( s.source == source ) 
        {
            if ( s.target == surce ) return true
            return checkQuery(data, s.target)
        }
    }
    
    return false
}
```

? - Implement a binary search tree and use it to read data from file and find a specific number
```
type BST := Empty | (data: int, left: BST, right: BST)
func processFile(s: string) -> BST
{
}
func find(bst: BST, x: int) -> bool
{
    return false if ( bst == Empty )
    
    return true if bst.data == x
    return find(bst.left, x) if (x<bst.data)
    return find(bst.right, x)
}
```

? - convert a binary string to a number
```
func convert(s: string) -> ulong
{
    var result: ulong = 0;
    loop(x: s) {
        result += 2**counter if ( x == '1') 
        counter++
    }
    return result
}
```

? - reverse a string

? - count vowels in a string

? - A small db engine
