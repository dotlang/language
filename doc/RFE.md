# Dotlang - Requests for Enhancement

? - name: simple, pure, simpla (simple + language), func, 
Lisp - list processing
electron is good but a bit long
photon? This is good. 

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
How can we model INSERT - hash
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

N - Assign values from an array of `any` to a tuple.
`var customer = data_array`
But there is no order in a tuple, while array has order.

N - easier notation to loop in a map
`loop(k: map) { ... }`
`loop( k,v: map) {...}` seems reasonable.
Maybe we can let user use the `:` notation too.
any function can be called with `:` as separator.
`add(x:y)` No its not useful.
We can have a lambda with two inputs.

Y - Kotlin has this:
`val positives = list.filter { x -> x > 0 }`
maybe we can have this rule that `a.b c` means `b(a,c)`
But its against all other idioms.
Maybe we can have other notations different from dot:
`func add(X:int, y:int)`
`add(x1,y1)`
`x1 >> add y1` its not working as add's first argument is supposed to be x
`x1 >> add $_, y` it's working but not as simple as `x.add y`
`x..add y` is a syntax sugar for `add(x,y)`?
`x,y..add z` -> `add(x,y,z)`
general idea: bringing function parameters before function name.
`x,y >> add ,z` ?
maybe we can just allow `x >> f y` if there would be no ambiguity. no its not general.
`x.>add(y)` => `add(x,y)`
this notation can help make reading code easir.
what about `(x)add(y)` ?
`(x)add y`
We can add a new operator like `~`:
`x ~ y` means `y(x)` and it would be a syntax sugar
A better example is `contains`: `contains(str, ":")` vs `str ~ contains(":")`
`a ~ b(c)` => `b(a,c)`
`~` will be chain operator but for the beginning.
`var index = str ~ contains(":")`
if we have `func contains(string, strin)` then `contains(":")` will create a function pointer: 
`contains(":")` => `func (x: string) -> contains(":", x)`
what about named args?
`str >> contains(pattern=":")`
or maybe we can just use space:
`str contains(":")`
`str->contains(":")`
`str.length` will call `length(str)`
When we see `A.B` we don't know if it is referring to tuple member or `B` is a function.
But if `B` is a noun, it's a member. If it's a verb then its a function.
Casing is not enough.
`str!contains(":")` - `!` already has it's own meaning.
unless we change comparison operators: `<>` for not equal, `==` for equal, and `not` for not.
Swift, Julia, Rust, Scala uses `!=` - Maybe we should use that one too.
`str ~ contains(":")`
`str contains(":")`
If we also allow paren-less function call this can become ambiguous:
`contains str, ":"`
`str.contains(":")`
we can force, if first arg comes before function name, call should have `()`.
but the we cannot write: `list.filter {...}`
space is better than dot.
`str ~ contains(":")`
`str contains(":")`
The problem with space is ambiguity. There can be cases where there is confusion over meaning of it.
`x fetchData contains ":"` what does this mean? It fetches a string data using input x, then checks if it contains `:`.
completely unreadable.
`x ~ fetchData ~ contains ":"` better.
`~` is like chaining but before. `>>` and `<<` are chain after (at the end) of arguments.
`func save(x: int, y: int, z: customer)`
`save(1,2) << loadCustomer(5)`
`loadCustomer(5) >> save(1,2)`
`func save(z: customer, x:int, y:int)`
`5 >> loadCustomer ~ save(1,2)`
`save(1,2) ~ 5 >> loadCustomer`
This will become too confusing. Either we should ignore this or unify all chainings.
`input ~ f($_, a,b,c)`
`string >> contains($_, ":")`
`input >> f(x,y,z)` => `f(x,y,z,input)`
`input >. f(x,y,z)` => `f(input, x, y, z)`
`string >. contains(":")`
not bad but still not very readable.
Can we use single letter operator?
`input | f`
`input |> f(x,y)` => `f(x,y, input)`
`input >| f(x,y)` = `f(x,y, input)`
`f(x,y) |< input` = `f(input, x, y)`
`f(x,y) <| input` = `f(x,y, input)`
OR
`input .> f(x,y)` => `f(x,y, input)`
`input >. f(x,y)` = `f(x,y, input)`
`f(x,y) .< input` = `f(input, x, y)`
`f(x,y) <. input` = `f(x,y, input)`
`str .> contains(":")`

N - also make a syntax sugar for `loop`:
`loop(x:y) {...}` means `loop(y) (x) -> { ... }`

N - function cannot change inputs even if assigns them to a local var. the only way is to clone.

Y - Think about method call dispatch with respect to multiple inheritance and polymorphism.
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

N - Implement a simple logic inference
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

N - Implement a binary search tree and use it to read data from file and find a specific number
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

N - convert a binary string to a number
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

N - reverse a string
```
func reverse(s: string) -> {
    var len = s :> len
    var result: string
    loop(seq(len, 0)) result += s[$0]
    return result
}
```

N - lambda input in loop must have `any` type. Because it can be anything.
`func loop(con: iterator<T>, body: func(x:T)->loopOutput)`
but in fact, if we are looping as `loop(10)` it will be an int.
if we are checking a condition, `loop(x>10)` then there will be no `x`.
if we are iterating: like map but without an output.
`func loop(data: any[], body: func(x:any)->loopOutput)->loopOutput`
we can use assert to make sure everything has correct type. 
Also note that we can pass any function which is subtype of `func(x:any)`!
so if we have `x: Customer[]`
we can call: `loop(x, func(x: Customer) -> ...)`
`loop(x, func(x: Customer) -> ... )`
`loop(x) (x: Customer) -> { ... }`

N - count vowels in a string
```
func count(s: string) -> int 
{
    return count(s) (x:char) -> x in 'aeoiy'
}
```

Y - can we remove need to put `()` in function call/loop/if?

N - Do we need `in` operator to check if something exists in an array?
It can be applied to anything. It invokes this:
`a in arr` -> `return or(loop(arr, (x) -> x == 'a'))`
but we can simply write a function for that!
`func in(x: any, y: any[])`
`if ( data :> in(arr1) ) ...`

N - with the rule of no need to embed in paren if last input if lambda, we can introduce keywords if the function has only a lambda input. 
```
if ( x > 0 ) { ... }
try { ... }
```

N - can we do import using `@` operator? Let's not make the language cryptic.

N - operator to add to beginning of array
`arr + x` add to the end
`x + arr` add to the beginning

N - how can we have `==` built-in while `bool` data type is not built-in?

Y - adding compile time assertions - this can replace templates somehow
`func push(s: Stack, x: any) { assert x[] :: s.data }`
C has `static_assert` same as D.
Maybe we can add `static` keyword and it can invoke compiler to execute any kind of statement, not only assert.
`static assert date>10`
what can we do in a static block?
1. type checking
2. check environment variables
`assert a::b` 
we can say assertions that are `::` will be evaluated at compile time. 

Y - The array and hash data structures are pretty handy but problem is we cannot alias them in any way.
`type Vector := int[]`
Then what about a vector of string?
We are not looking for a full generics. But like validation `where` which is only applicable when you are defining a custom type we can have similar case for type re-write.
`type Vector := V[]`
`type IntVector := Vector with { V := int }`
And this `V` parameter cannot be used anywhere else.
`func shift(v: Vector) -> V ...`
This will accept any vector and return V which is any. User has to cast it.

Y - Closure should not have write access to free variables. Because if closure becomes a thread, this will become a shared mutable state.

N - can we have a hash of type to function pointer?
Like a set of factories. We can but we won't have a Type type.

N - We have a problem with map/loop I thought we don't:
`loop(x, func(x: Customer) -> ... )`
This should not compile because loop signature is:
`loop(x: any[], func(x: any)->...`
No. It's ok. `Customer` is a subtype of `any`.
So `func (x: Customer)` is a subtype of `func (x: any)`


Y - Now that closure can only have read-only access, maybe we should make `loop` a keyword.
`loop(5) { ... }`
`loop(x>5) { ... }`
`loop(x: array) { ... }`
`loop(k: hash) { ... }`
`loop(k,v: hash) { ...}`
`loop(x: IterableType) { ... }`

Y - for `if` we can force user not to use paren.

Y - better operator for chaining - maybe `.`
beause 4 different operators can become really confusing.
`str :> contains(":")`
first of all, chaining is just a syntax sugar. 
So we don't need to cover every possible scenario (from left to right, from left to left, ...)
So we will have `A.B` having two meanings: access field B of tuple A or call method B with input A.
If paren becomes mandatory, this will not be a problem.
`A.B` is field access, `A.B()` is method call.
`str.contains(":")`
We can allow paren removal but cannot be used in conjunction with this syntax sugar. But it will be another exception which is not like the gen/orth we want.
If something is allowed, it should be allowed everywhere.
But for example for `filter` we want to have: `list.filter { ... }`
No this is not good. It is hard to read amd can become confusing in a large code-base.
`str.length()` -> `length(str)`
If we mandate paren, filter becomes like this: `list.filter() { ... }` which does not make any sense.
But there should be a way to reduce number of all those `{}` and `()`s.
`my_string.contains(":").send(file)`
`@(x,y).process()` -> `process(x,y)`
What about eliminating paren everywhere?
`f x y z` to call `f(x,y,z)`
`str.contains ":"` -> `contains(str, ":")`
This is not good because function name and it's input are not separable.
`map(data, { ... })`
So:
- In function call, paren is mandatory even if there is no input (`str.length()`)

Y - unify data types : int and uint for all precisions.
Go has the proposal:https://github.com/golang/go/issues/19623
Lisp and Smalltalk support it.

Y - Is it a good idea to have `str.contains(":")`?
Golang allows this. Same for D (Uniform Function Call Syntax (UFCS))
Same for C++
and somehow Rust.

Y - Should we make loop/if an expression?
`var t:int[] = loop(var x:10) x`

Y - Because we can have `and/or/...` lets enforce paren for if.

N - What about inside paren? Can we eliminate commas?
`list.procees(1 2 3)`

Y - There is not much use for having `if/else` a syntax sugar. Maybe we should make them keywords too.
`if`, `else`

N - One idea to better org:
two file types: types and functions.
And in type file we specify the modules that can have them.

Y - Suppose we have `First` and `Second` type and `type S := First | Second`
can S accept a variable which both supports First and Second type?
```
type First := (x:int)
type Second := (y: string)
type S := First | Second ;this is valid because F and S do not overlap
var t : (x:int, y: string) = (1, "G")
;t is satisfying both First and Second
if ( t :: First ) ... true
if ( t :: Second ) ... true
```
```
type S
type First := (x: int)
type Second := (y: string)
var t: (x: int, y: string) = (1, "G") ;type of t is S and First and Second
```
Seems that sum type does not mix well with implicit inheritance.
We should have only one of them.
Even if we remove implicit inheritance, we cannot remove multiple inheritance. So we can have a type inherit from A and B and a sum type as `A | B`.
But sum types give us expressiveness. Maybe we should replace it with another thing.
Interface does not give us any type checking. You can assign a string to a variable of type `DoW`.
Why not keep it? And accept this problem. And issue a compiler/runtime error when it is misused.
`type Tree := A | B | C` a variable of type Tree must be either A or B or C.
So if you want to use a variable as a Tree which is none of them or multiple of them, there will be an error either by compiler or by runtime.

N - get rid of `any`. If you want this, you have to implement generics!

N - can we simulate sum types with type inheritance?
```
type Operator;
type Plus := @Opertor
type Minus := @Operator
type Multiply := @Operator
type Divide := @Operator
var g: Operator = Add
if ( g :: Add ) ...
```
We can simplify by allowing define multiple type in one line. `type A,B,C := D`
`type SAT, SUN, ... := DoW`
`type DoW := none`
We have a `none` type which has only one possible value.
But how to have and send variables?
`var op: Operator`
`op = Minus()` - cast nothing to minus. It's possible because minus does not have any value.
`if ( op :: Minus ) ...`
How can we define a tree?
```
type Tree
type Empty := @Tree
type Leaf := int
type TreeNode := (node: int, left: Tree, right: Tree)
func dfs(t: Tree) {
    if ( t :: Empty ) return 0;
    if ( t :: Leaf ) return 1;
    ...
}
```
`type Tree := Empty | int | (node: int, left: Tree, right: Tree)`
The only problem is that now we can send a string as a tree, because of subtyping rule!
Solution1: Let it be. Less exceptions and restrictions, means better.
Solution2: Disallow automatic subtyping for `Tree` by adding some config. -> No new notation.
We can add a random field to make sure no other type will be subtype of Tree but that is not necessary.
Solution 3: Define base type inherit from `none` instead of `any`.
Or maybe we can add a better name, like `unit`, but then again, any type that has a `unit` in it, will become a Tree.
What about maybe/optional?
`type Maybe`
We are already using this for exceptions.
`type Maybe`
But `|` is more expressive.

N - Maybe in a type we should indicate is it an implicit parent or an explicit parent.
implicit parent - every other type can be it's child as long as fields match
explicit parent - every type must match fields and indicate it's parent
Why not make parent explicit?
Even if some type is in a lib and later someone else wants to inherit from it, they can just mention parent name and they can use that type everywhere.
In this way, no one can send an int instead of a tree in accident.
This will still be done with explode operator but not inside () because there are other types too.
`type Point := (@Shape, x: int, y: int) @Drawable @DT @GE`
Then what about sum types?
`type ST := int | string` the sum type itself cannot be child of anything. It's inner types can be.
`type ST := int @A @B | string @C @D @E`
So `(x:int, y: string)` cannot be child of `(x:int)` because it must be stated explicitly.
Problem is: What if the type is defined in a library and we cannot change it? This should be completely implicit.
But in that library, they don't need any extra information about that type.
Anywhere else, we just tag that type with new type.
So: to indicate inheritance, one should tag a type with it's parent and contain parent fields. This can be done in one step using explode operator.
`type X := int @A @B` means variables of type X can be used as int or A or B type.

N - Can we define abstract types? Which are empty and you cannot return values of them. Only for their children.
`type A := any where false` incorrect.
`type A := any`
`func A(any) -> assert false` ?

N - allow tagging a type so we state it's parent. It's optional but can help make code readable.
```
type Tree
type EmptyTree
type Leaf := int @Tree ;tag Leaf so we indicate it's parent type is Tree
```

N - can we allow mutable function inputs with some kind of container?
If we allow closure to modify free variables, this can be done with ease. No need to change syntax or add a new notation.
or maybe we can specify a special type of lambda only to change a value.
Like `set` lambda.
Like converting a local variable to a closure which is bound to it.
`var g:int = 12`
`var cl: func(int) = %g`
`cl(11)` will set value of g
No.
What about this?
```
type Wrapper := (set: func(x: any), get: func()->any)
var intWrapper := (a: int, set: func(x: int) -> { a=x }, get: func()->a) ;this is incorrect
```
Or let's have a core/built-in keyword which gives you two functions for an input: getter and setter.
or maybe only setter.
`processData(x,y,z, setter(x))`
or add `&` notation. This definitely should not be attached to type name because it will make type system mode complicated.
`func process(x: int, y:int, &z: int)`
- This definitely applies to function argument. Not to type or variable or any other thing.
- Caller does not need to do anything special.
Can this be simulated by compiler?
```
func check(&x: int[]) -> x[5] = 11
...
var t: int[]
check(t)
;above is changed to this:
t = check(t)
;and the function becomes:
func check(x: int[])->int[] y=[@x] & y[5] = 11 & return y
```
In other words, result is copied back to the caller. 
function receives a read-only reference to the variable. makes changes to a clone and returns it.
But the developer can do this himself! why complicate compiler and notation by this hack?

Y - what should be default value for a sum type? or any?
for any you must initialize. 
for sum type, same.

N - Is it possible to make sure functions that accept a Tree (or Stack or ...) will not accept `any`?
I want to make sure `func DFS(x: Tree)` won't receive a Stack for example, just because both are empty.
`any <- Tree, Stack ...`
The easiest solution is to introduce a special field that is unique to a Tree.
Any Tree or subtype will definitely have it while a Stack won't have it. So dev cannot send a Stack by mistake.
Now, what that "unique field" should be? 
We cannot waste memory by adding a field which is not supposed to contain any data. This will be just a compile time thing.
We can add a small field with a random name. 
`type Tree := (dsddasdsadasd: int)`
`type Leaf := (@Tree, x: value)`
But still any other type that has an int field will be considered a subtype of Tree.
We should add some kind of a Tag to types.
If a type wants to be subtype of other, it should contain subset of it's fields and same tags.
Will this preserve good things that duck typing gives us? If base type is defined in a library, we can make it subtype of our own type by adding our own type without a tag!
An easy way is to add a dummy field of type `none` or a type which inherits from none. It is according to all rules, no new exception or notation. We may just add a sugar for this.
`type Tree := (dummy: none)`
Maybe we need a shotcut to define a new type in-place based on any or none, if it's going to be used in only one place.
`type Stack := %StackElement[]` -> StackElement is child of any.
```
type TreeBase := none   ;this type does not have any value. It is just a market/tag
type Tree := (id:TreeBase)`
type HeapBase := none
type Heap := (id:HeapBase)`
```
Let's don't change it. It will only complicate the language, adding new notation or syntax.

? - More thinking about type syste, subtyping, type equality and type aliasing and matching rules.
`type A := B` means A is a new type that internally is exactly same as B.
`type T` is an empty type or it is for `any`? If empty type, it does not have any value or representation.
If it is any then it can represent anything. It should represent nothing (none).
if we differentiate any from none, then an empty type which inherits from none...?
I think none should be parent of any (if they are not separate). Because of subtyping rules.
So if a lambda is supposed to have none output, it can return anything (and it will be ignored).
if it's output is any, it cannot return none.
Whenever a specific type is expected, you can provide a more specialized type with more fields and details but not vice versa.
So if (x,y) is expected, you can provide `(x,y,z)` (as function input or output or ...).
So when type T is expected, you can provide either T itself or any of it's subtypes.
------------
We have 7 kinds of type: tuple, union, array, hash, primitive, function and named.
We write C <: S which means C (child) is subtype of S (supertype). 
- Primitive: C and S are the same
- Array: if their elements <:
- Hash: same key, Vs <: Vc
- function: C:func(I1)->O1, S: func(I2)->O2 I1<:I2 and O2 <: O1
- Sum types: C: C1|C2|...|Cn and S: S1|S2|...|Sm if Ci<:Si and n<=m
- Tuple: C=(C1,...,Cn) and S=(S1,...,Sm) if Ci<:S1 and n>=m and if both have named fields, they must match
- Named: A named type is subtype of it's definition (type SE := int, then SE is subtype of int).
`nothing` is supertype of `any` and all other types.
Variable of named type can be assigned to unnamed type and vice versa. `type SE := int` then SE and int are assignable.
Two named types with different names are not assignable implicitly, but a named type and it's underlying type are.
`type SE := int & var s: SE = 12`


? - Go does not permit adding a new function to an existing type if the type is outside file of new function. Can we do the same thing here? It will help organizing the code.

? - The implicit subtyping for empty types can be confusing sometimes. Is it possible to make it more explicit and readable.
Think about different situations like multiple functions, type hierarchy, function overriding. 
Note that we want a simple and readable language with minimum rules and exceptions.
If `type` defines a new type, then user cannot use another type instead of that (if that another type does not have a direct matching function)
```
type SE := int
type DE := int
func f(x:SE) ->...
var g: DE = 12
;you cannot call f with g because their type do not match
;you can of course cast
f(SE(g))
```
Type alias is a different type but it is subtype of its target type.

? - Golang has similar syntax for type assert and extract.
`x = y.(int)`
`switch ( y.(type)` 
Can we make them similar too?
Similarly, `x.[]` is a good notation to use. 
