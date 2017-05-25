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

Y - More thinking about type syste, subtyping, type equality and type aliasing and matching rules.
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
.....
We have two categories of types: named and unnamed.
Unnamed: `int, string[], float => int, (int,int)...` - They are created using language keywords and notations like primitive type names, `any`, arry or hash, ....
Named: `type MyType := ?????` These are defined by the developer and on the right side we can have another named or unnamed type. Right side is called underlying type.
We have two special types: `nothing` and `anything`. All types are subtypes of `anything` (except `nothing`). `nothing` is only subtype of itself. So if a function expects nothing (which is weird) you can only pass a nothing to it and nothing else. If a function expects `anything` you can pass anything to it (except `nothing`).
We have 7 kinds of type: tuple, union, array, hash, primitive, function.
We write C <: S which means C (child) is subtype of S (supertype). 
- A type is subtype of itself.
- Primitive: C and S are the same
- Array: if their elements <:
- Hash: Vs <: Vc, Kc <: Ks
- function: C:func(I1)->O1, S: func(I2)->O2 I1<:I2 and O1 <: O2 and if inputs are named, they should match.
- Sum types: C: C1|C2|...|Cn and S: S1|S2|...|Sm if Ci<:Si and n<=m
- Tuple: C=(C1,...,Cn) and S=(S1,...,Sm) if Ci==Si and n>=m and if both have named fields, they must match
Variable of named type can be assigned to underlying unnamed type and vice versa. `type SE := int` then SE and int are assignable.
Suppose that we have a function `func f(x: T1, y: T2, z: T3)`
You can call this function with 3 data, if type of each data is subtype of corresponding function argument. if input is named, it should match with names on the function declaration.

N - Type hierarchy
The ones who are below are those who can accept more general data. so (int,int) is below int.
As a result top of the tree if `nothing`.

N - Should we consider `(int)` same as `int`?
If we do so, a func which expects `(int)` can be called with an integer.

N - What about function pointer/lambda?
A lambda has a `func` type. The lambda we want to send to a function should have a type which is subtype of expected type.

N - Go does not permit adding a new function to an existing type if the type is outside file of new function. Can we do the same thing here? It will help organizing the code.
But we do not want to tie data (type) and functions.

N - The implicit subtyping for empty types can be confusing sometimes. Is it possible to make it more explicit and readable.
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
You cannot send a `DE` when `SE` is expected. Two named types can never be equal.

N - what happens if I send a `(int,int)` when `(int)` is expected?
If both are tuples, then this is a simple case of inheritance. If tye is not specified, it's ok and we can pass.
If type name is specified then they must match. but there is ambiguity so there will be error.

N - Golang has similar syntax for type assert and extract.
`x = y.(int)`
`switch ( y.(type)` 
Can we make them similar too?
Similarly, `x.[]` is a good notation to use. 
custom cast can be done in custom functions.
`Circle.(Shape)`? Does not seem nice.
What about type checking? `::`
`if ( x :: int ) { y=int(x) ... }`
Does not seem a good idea.

N - Suppose that `type SE := int` and we have only one function: `func f(SE)` 
can we send an integer to it? NO.
We should not be able to do that.
if we only have `func f(int)` we can send int and SE to it? NO. Let's make things simpler.
In golang you cannot.
The simpler one is: If two functions we have, each will go to same type.
Make it simple: Same type always.
The purpose of defining named type is not to redirect calls to another type because those calls are already being made with underlying type. `type SE :=int` purpose is not to catch calls that are passing int. The purpose is defining new functions with new type (SE) and caller will send correct SE type not int.
So there should be no implicit casting. So that's why in golang it says, "A named and an unnamed type are always different".
`type SE := int` means internally SE is an integer and you can easily connvert it.
So as a result of this, you can never send `Heap` in place where `Tree` is expected.
But where `Tree` is expected you can pass subtypes of Tree.

N - should `int` be subtype of `nothing` or `any`?
You can send a circle where a shape is needed. shape is supertype and circle is subtype.
You can send any where int is needed? no.
You can send int where any is needed? yes. so any is supertype and int is subtype!
I think there are two different concepts here. any and super-sub typing.
any can be considered a sub-type of everything.
Maybe we should treat any and nothing separately. nothing is a type which does not have only one valid value: nothing.
any is a type which contains all types in the system (like int | string | ...).
These two can be considered keywords to mean a function can accept everything or nothing.
Other than these two, rules of parameter sending is specified with subtyping. 
So if f expects type T you can send a subtype of T. If f expects a Shape you can send a shape.
So we don't need to put any/nothing in the type tree.
You can send nothing where int is needed? no.
You can send int where nothing is needed? no.
An input cannot be of type nothing. 
It can only be used as output of a function or block. But this is not general.
It should be allowed as an input but it does not make sense.

Y - rename `any` to `anything` and `none` to `nothing`.

Y - loop can accept expression and will output an array:
`var x: int[] = loop(10)` same as `[0..9]`
maybe we can even remove 1..10 notation.
we can extend loop like `loop(2,20)` means 2 to 19.

Y - provide shortcut for tuple:
`x,y = func1()` will assign x and y output of func1.
`return 1,2` will return a tuple of two values.
`return (x=1, y=2)` same as above with name.
maybe we should write: `x,y = @func1()` so we are expanding a tuple.
`(x,y) = func1()` does not have a meaning. what is the left side?
`@` is inverse of `()`.

N - can we simplify function by saying its input is a tuple?
If so, we should permit sending subtypes to the function which makes things confusing.
Also we should permit optional values which makes method dispatch difficult.

Y - if we use function name as a variable it will be confusing.
`func f(x:int)->`
`var t: func(int) = f`
Maybe we should add a notation. The only advantage is prevent confusion.
When I see `t=u` and t is lambda, then is `u` another lambda or it is a function name?
`t=&u` this is more intuitive. but is used for continutation.
`t=^f` to denote pointer to a function.

N - `&` can be used for continuation in one line. for multiple line, create a block.

N - Returning modified data in output as an alternative for mutability is good but may be bad for performance.
`x=f(a,b,c,x)`
`func f(a,b,c,x) {...y=@x..return y}`
Is it possible that we keep things pure and also give permission to change the value?
I think, only if we provide lambda. Anything else will either be complicated or making things impure.
Giving lambda gives control to the outside world to control/mock things.
idiomatic way: return modified value
suppose in real-world we have a function which receives an array of 1000 customers and wants to mark something.

Y - Do we need `where`?
If we need it, it should be allowed in function definition too.
maybe we can extend where to allow modification through lambda. Then we can use it for mutable function input.
But first lets solve the method dispatch issue:
`func f(x: int where {$>12})...`
`var g:int = 12`
can we call `f(g)`?
Let's remove `where` it makes things simpler. And prevents future exceptions.

Y - add `ref` keyword.
what if inline lambda can change local variables. It cannot be shared between two threads because it is online.
BUT this will be a big exception.
But even haskell has mutable arrays.
What if we employ a concept similar to monad?
The function returns an action (lambda?) which will change the array. The caller will execute this action and it's local variable will be updated.
why not let the developer decide if something should be immutable or not?
everything being immutable is some kind of exception too!
Of course default is immutable for everything but function input can be mutable too.
But we should not go too far (an immutable array of mutable int, an immutable hash with mutable values, ...)
Now that function does not accept a tuple, we can have a special definition for function signature.
There we can denote if an input argument is mutable or not.
This definitely does not change anything about type or ...
We are not defining a NEW type. We use same types.
The only requirement: function should clearly indicate mutable input.
Sender should indicate argument which is being sent as mutable -> this will make code readable.
If I see `process(x,y,z)` I don't know whether any of these 3 arguments will be changed or no. But when there is a notation I know when I read the function.
C# has `ref` or `out` keyword. This is good because does not imply change in the type.
`func process(x: int, ref y: int)`
`process(t, ref u)`
Good but it is a bit long! 
We can replace it with a notation like `%` but I think `ref` is more descriptive (and intuitive at least for c# developers)
The good thing is that its not possible to use ref when declaring a tuple or any other place.
And a function can call another func with ref input either if argument is local or its a ref too.
This definition helps us keep method dispatch, type casting and many other places without a change.

Y - if we have `func process(ref x: int)` can we also have `func process(x:int)`?
I think we can have (gen. do not ban anything unless you really have to). But it would make code complicated but still readable.
Because when the call is made, we make clear which version we want to call.
So `ref` will affect method dispatch too.

N - q find cases where we have "you cannot" in the specification. These are exceptions.
Of course some of them are necessary: you cannot assign a string to int.

N - if we agree that function input is not a tuple, can we use `x:12` notation to send named function input?
It won't be intuitive and consistent.

Y - If named types can never be equal it will be against subtyping rules -> exception.
Named types are subtype if their underlying types are subtype.
So anyway someone can send a Heap when a Tree is needed.
The correct and general way: Named types are what their underlying types are in terms of subtyping. They are equal to their underlying type.

N - if we have `(x:int, y:string)` and two method candidates accept int and string, there will definitely be a runtime error in method dispatch -> runtime error.

N - if a method accepts `any` we should not be able to send anything to it except any.
is this correct? No: All types are subtypes of `any`

N - what about comparison?
what data types can be compared? `x==y` (other comparisons are only for int and float).
equality check is only possible for data of the same type, unless user has provided `opEquals` methods.

Y - User can check if a constraint is valid using `::` opertor.
`type Even := int where $ %% 2`
`if ( myNum :: Even ) ...`
And cast normallt: `var t = Even(g)` it will give exception if g is not even.

Y - `%%` operator for check divisibility `x%%2` = `x%2==0`

Y - if `::` is used with literals, it checks both for type and value equality. Else checks for type matching.

Y - What we are trying to achieve using `where` is available in some other languages and is called refinemenet types.
Perl6, Haskell, Rust (proposed), Ada
Check to see how it is implemented there and if it is general.
Can we instead of this general concept, use a sum type where each section has a criteria?
`type Num := int $>0 | int $<0 | int $==0`
Another option: where cannot be used to affect method dispatch. It will be executed when method is chosen.
Another option: Each data type has different states. we can put these states in a sum type and dispatch based on those sum types. Example of states: int (positive, negative, zero), file (open, closed), ...
We can do all these checks in the function too but this can happen in a lot of functions -> a lot of code repeated.
Advantage: With assert we have to do it everywhere we want to work with the data. but with where only once.
About method dispatch: We can do dispatch normally without where clause mentioned in function signature. Then when a method is chosen we can check where clause. 
If we encode this into a sum type, we can dispatch based on it's type too and leverage method dispatch.
`type MyInt := Positive where $>0 | Negative where $<0 | Zero where $==0`
`func process(x: Positive)`
`func process(x: Negative)`
But most of the time we only want to denote valid/invalid cases.
What about a specific data type: `type Validated := (x: any, validator: func(any)->bool)`
`type IntV := validated with { }` But this needs suppose from runtime.
Other solution which is not readable: function with specific naming.

Y - How does `where` affect inheritance?
if A inherits from B does it also inherit it's validations?
A valid Circle must be a valid Shape too!
If so, you must refer to them when you define circle:
`type Circle := (@Shape, r: float) where { $ :: Shape and $.r>0}`

Y - How does `where` affect method dispatch?
It just makes things more complicated everywhere.
Can't we just simplify it?
For example if `x` is casted to `PositiveInt` for a function call, then casted to `SmallInt` for another function.
Then can we call the first function again? No. The data has one type at each time. If we change type from PositiveInt to SmallInt, all the information about PositiveInt will be lost.
What about making data and type and predicates separate? 
Predicates can be like labels for a variable. We can assign as many labels as we want to a variable.
A function can check for any number of labels.
Labels are not changed until variable is changed.
Operations: Add a label to a variable, check if variable has a label.
A label is a function which returns bool.
Can we handle this transparently by caching function results?
`func isPositive(x: any) -> bool`
If this is called once for a variable, it's result can be cached. so next time another function calls this, it will use cache.
All of this can be handled behind the scene and transparently. No need to do anything by the developer.
Just put checks whenever you want. Just know that functions that receive a single input and output `bool` are predicate functions and are treated like labels.
This is a good example of reducing complexity while retainin much of benefits.

N - in `where` ability to define custom errors.

N - can we make `::` notation simpler and more intuitive like go, but expressive?
`::` is doing multiple things. in `if ( x :: int)` its a bool operator for type checking.
in `x :: { y:int -> ...}` it is a case statement.
But these two definitions are compatible.

Y - Clatify `with`.
We are using with subtyping. Now this is trying to give depth subtyping.
`type Point := (x: Shape, y: Shape)`
`type Data := Point with { Shape := Circle}`?
Are we going to have both? Doesn't it make things more complicated?
Can we simplify it?
What comes inside `with`? What is the purpose of with?
If IntStack is going to be a subtype of Stack, then we have depth subtyping.
`func push(s: Stack, x: any)`
We want to be able to send a Stack with same structure but different type (int) to push function.
covariant: a variable that can accept any of it's subtypes
`@` is used to width subtyping. `with` is for depth subtyping.
`func equals(x: any[], y: any[])->bool`
We can do width subtyping with `@` with minimum effort. What about depth subtyping?
Maybe we can do this similar to templates (by adding parameters that can be used for depth subtype)
`type Map := Source => Target`
`type MyMap := Map with { Source := int, Target := string }`
`type MyMap := int => string` same as above.
a map of `list<int>` to `list<string>`?
I feel that the effort to keep gen and orth and no exceptions, is making the whole subtyping more and more complicated.
Java does not let this subtyping to exist.
C++ makes it easy with generics but I think there is no inheritance.
Easy way: dont provide anything. Let the developer copy the super-type data structure.
`type Stack := StackElement[]`
`type IntStack := int[]`
`type Packet :=   (status: Data[], result: (x:int, y:int),       headers: xany[] => yany[])`
`type IPPacket := (status: int[],  result: (x:int, y:int), headers: int[] => string[])`
`type IPPacket := (^Packet{Data := int, xany := int, yany := string})`
We can make it super-flexible by type-generating functions.
C++ covers this type of subtyping with generics.
But in structural subtyping, we want types to match if their structures match. This should not rely on the designer of base type see the future and how his type will be used. 
Requiring use of generic types, will make language more complex and require designer of a type to forsee the future about how his type will be needed.
Let the designer of the base type do his job and design the type as he wishes.
The user, should be able to "customize" and "re-write" other types to create a new type.

Y - We should modify type system explanations to support depth subtyping too.

Y - Clarify about using `@` to subtype an array or sum type.
```
type arr := xany[]
type optional := Empty | xany
type arrInt := @arr{xany := int}
type optionalInt := @optional{ xany := int}
```
definition of `@` then will become too broad. Maybe we should use another notation.
`@` will solely be used on data and used to explode/clone data.
`&` can be used. This denotes some kind of reference which makes sense.
What happens to the original `&` opertor then?
Advantage: The definition of explode `@` does not make sense for non-tuple types.
So using `&` is a good idea. It duplicates another type at place of declaration.
We can call it "type duplication" operator. or type copy or type reference operator.
Let's make `^` a type copy operator and `&` to assign lambda to function.

Y - method dispatch.
A method will be chosen which satisfies most fields of the tuple.
`func process(any[])` - 0 fields are covered
`func process(Shape[])` - 2 fields are covered
`func process(Circle[])` - 5 fields are covered
if we call process with a Circle array, the third function above should be chosen.

N - Can we define the expected type in-place?
`func printName(x: (name: string))...`
Any data type that contains a string name can be passed to `printName`.
If we make function call with x parameter: `processData(x)` this will call a copy of processData function which accepts a parameter with `name` input (named or typed).

N - can we make type system simpler?
solution 1: remove subtyping.

Y - Use `&` to assign function name to a lambda.

Y - can we prevent casting circle to shape?
when we want to have only methods on circle and if something is defined for shape but not circle, dont call it.
`func process(s: Shape)`
we don't want to implement all Shape methods for a circle and we don't want runtime system to fall back to shape when a method is not defined for circle but defined for shape.
what about casting?
`func Shape(c: Circle) -> return c` this is the default behavior
`func Shape(c: Circle) -> assert false` this prevents calling any method which is defined on Shape, with an instance of Circle.

N -  As NASA found out, passing an object of type DistanceInInches to a function expecting DistanceInCentimeters can be problematic.
I think this typing is not ideal. You should have something like this:
`type Distance := (value: int, unit: CM | IN)`

N - What about continue execution?
Do we really need it?
Usage: When we are supposed to provide a simple expression, we can put multiple expressions and combine them using `&`.
No we don't really need it.

Y - we will need to define a lot of empty types for generics. can this be avoided?
`type Packet :=   (status: Data[], result: (x:int, y:int),       headers: xany[] => yany[])`
`type IPPacket := (^Packet{Data := int, xany := int, yany := string})`
we can say, `!T` will define internally a type T which is based off `anything`. It will not conflict with any other type.
And you can replace it with `^Parent{T:=int}` or `%`.
`%` local-anything-type creator will define a local type based off anything.
baseically `%T` means anything but can be referenced in child types to specialize the type.

Y - Remove operator overloading.
it is not general.
`opIndex` this needs reference access which does not make sense with the syntax:
`func opIndex(ref x: Customer, i: int, v: string) -> `

N - casting code must be written in the same file that type is defined.

Y - Disallow writing custom cast function with `TypeName(x)` name.

N - Strategy about casting: if we let user disallow cast from circle to shape, he should also be able to disallow cast from shape to circle which is against polymorphism that we have. 
The code can become really confusing.
Let's forget about casting at all. toString and normal conversion from int to string and ... will be provided by runtime using normal functions.
Casting notation is not confusing because function names must start with lowercase.

N - `var z = Car(age=121)` this is confusing and similar to function call. It's not. function name start with lowercase.

N - in go we can have:
```
if v, ok := value.(migrater); ok {
    v.migrate()
}
var c int
if c = b; a > b {
    c = a
}
```
Maybe we can use semicolon to group some statements together into a single expression.
But this hurts readability.
```
var (v, ok) = Migrater(value)
if (ok) v.migrate()
v.migate if (ok)
```

Y - use `!` for local anything type. `%` is used for numbers.

Y - adding paren to if makes code more readable. same as what we have for loop.

N - tree definition:
`type Tree := (x: !T, left: ^Tree{ T := !T }, right: ^Tree{T:=!T})`
Here using `!T` is mandatory because if we use plain T:
`type T`
`type Tree := (x: T, left: ^Tree{ T := T }, right: ^Tree{T:=T})`
it becomes confusing.
```
type Hash := !K => !V
type hh := ^Hash { K := int, V := string }`
;or
```

Y - maybe we can just eliminate `^`! if you want width subtyping:
`type Circle := (Shape, r: float)`
for depth subtyping:
`type IntStack := Stack{T:=int}`
or
`type IntRecord := (x:int, y:float, Stack{T:=int})`
using an unnamed field in tuple, means expand definition of that type here.
Also to simplify (as an option), you can assume order:
`type Stack := !A[]`
`type IntStack := Stack{int}`
here, if we don't specify name, first will be `A` second will be `B` and so on.
This makes syntax cleaner.
`type Tree := (x: !A, left: Tree{!A}, right: Tree{!A})`

N - Array cannot be used for queue or linked-list because it is supposed to be consecutive memory locations.

N - push
`type Tree := (x: !A, left: Tree{!A}, right: Tree{!A})`
`func push(x: Tree)->anything`
`func push(x: Tree{int})->int` this is ok
`func push(x: Tree{T})->T` not valid.
what comes on the right side of `{A := B}` must be either a concrete type or another alias.

N - method dispatch
`func process(s: anything[])`
`func process(s Shape[])`
`func process(s: Circle[])`
`var g: Shape[] = createCircleArray()`
static type of g is shape array but dynamic type is circle array.
```
type LinkedList := (x: !T, next: ^LinkedList{ T := !T })
type ShapeLL := ^LinkedList{ T := Shape }
type CircleLL := ^LinkedList{ T := Circle }
func process(x: LinkedList)
func process(x: ShapeLL)
func process(x: CircleLL)
```
```
type Tree := (x: !T, left: Tree{ T := !T }, right: Tree{T:=!T})
type ShapeTree := Tree{ T:=Shape }
type CircleTree := Tree{ T:=Circle }
```

Y - can we simplify polymorphism
we have two types: width and depth
width:
`type Shape := (name: string)`
`type Circle := (^Shape, r: float)`
depth:
`type Stack := %Element[]`
`type IntStack := ^Stack{ Element := int }`
Golang does not let you define two methds with the same name even if parameters are different.
When user writes `process(x,y,z)` there is a chance that his intended process function is not called.
Because of polymorphism and ... .
one solution: import only one file at a time.
this does not stop the problem but makes tracking easier.
langauges with multiple dispatch: common lisp, perl 6.
one approach: define fixed parameter, which cannot be overriden and determined at compile time.
`func process(x: Customer, f: !File)`
this function can only be called with second argument of static type of File.
obviously, you cannot overload this with other File children.
output of functions with the same name must be compatible.
```
func process(s: Shape) -> doWork(s)
func doWork(s: Shape)
func doWork(c: Circle)
```
The doWork call in process cannot be determined at compile time. unless we only have one doWork function.
problem is, a variable can have a lot of types which are implicit.
`var c: Circle = ...`
c has a Circle, Shape, Drawable, Comparable, Equalitable, Iterable, Object and anything type.
So if we make a call to `process` function which can accept all of above types, it might not be resolved at compile time.
maybe we also have `BigCircle` type and type of c becomes BigCircle at runtime.
what about zero size types?
```
func process(x: anything)
func process(x: Comparable)
func process(x: Iterable)
func process(x: Drawable)
type Comparable
type Iterable
type Drawable
type Circle := (r: Radius)
var c: Circle = (r=12)
process(c)
```
1. functions with named empty types are superior to unnamed (anything).
Still we have 3 candidates: Comparable, Iterable and Drawable.
There is no way we can prioritize these three.
-> Compiler error. unless we cast
`process(Drawable(c))`
`var s: Shape = Shape(circle)` still keeps original circle
`process(Shape(circle))` keeps original data
`var s: Shape = Shape(@circle)` clones circle into a shape.
`process(Shape(@circle))`

Y - What happens with this?
```
type A := (x:int, y: int)
type B := (x: int)
var t = A(x=10,y=20)
var y: B = (@A)
```
It should fail because we are providing extra input to y variable initialization.
But if we cast, it should be ok, because that is the point of casting:
`var y: B = B(@A)`

N - How do you write this?
```
ParseResult<V> VParser::parse_impl(ParseState state)
{
    ParseResult<A> a = a_parser.parse(state);
    if (ParseSuccess<A> * success = a.get_success())
        return ParseSuccess<V>{{std::move(success->value)}, success->new_state};
    ParseResult<B> b = b_parser.parse(state);
    if (ParseSuccess<B> * success = b.get_success())
        return ParseSuccess<V>{{std::move(success->value)}, success->new_state};
    ParseResult<C> c = c_parser.parse(state);
    if (ParseSuccess<C> * success = c.get_success())
        return ParseSuccess<V>{{std::move(success->value)}, success->new_state};
    ParseResult<D> d = d_parser.parse(state);
    if (ParseSuccess<D> * success = d.get_success())
        return ParseSuccess<V>{{std::move(success->value)}, success->new_state};
    return select_parse_error(*a.get_error(), *b.get_error(), *c.get_error(), *d.get_error());
}
```
```
loop(x: [a_parser, b_parser, c_parser, d_parser]) {
    var ok, result = @parse(x)
    if ( ok ) return process(result)
}
```

N - shouldn't we support multiple return?
`var ok, result = @parse(x)`
vs
`var ok, result = parse(x)`

Y - remove `.@`
We can also have:
`var ok, result = parse(x).@` which is weird.
this operator is used to clone a tuple, array or hash.
So it is useful.
The `.@` notation is used to convert a tuple to an array in the ref which is not really needed.
`var ok, result = (x=10, y=12)` this should be fine.
`var ok, result = (10, 12)`
so we can remove `.@` notation.

N - How can we do type specialization with nested data types?
The parameter should be defined in the main type too.
```
type Array := !T[]
type Stack := Array[] ;you cannot specialize this
type Stack := Array{ T := !T }[]
type IntStack := Stack { T := int }
```

N - in order to reduce complexity can we state parameter in a type must be anything to be specializable?
You can specialize type A if it has `anything` or `!T` types. You can replace them with the type you want.
We already have subtyping rules in place.
If we have `type Array := !T[]` and `type Stack := Array[]` then we can specialize Stack with another type which is subtype of `Array`.
Some more exaplanation about type re-write.
`TYPE{ A := B, C := D}` will be replaced by compiler, with definition of `TYPE` type and it will apply given transformations to the definition.

N - alternative for subtyping: group function definition redirection (whatever on circle, redirect to shape)
at runtime, dispatch will be only done for dynamic type of the inputs. no complicated algorithms. 
But user can define a group of functions at the same time to redirect some of those cases.
```
func process(s: Shape)
func draw(s: Shape)
func process(c: Circle)
funcs *(*Circle*) -> *(*Shape(Circle)*)
```
what if these mass rules have conflict? 
Then we can handle it at compile time?
```
func process(s: Shape, t: Color)
func process(c: Circle, t: Color)
func process(s: Shape, t: SolidColor)
...
process(myCircle, mySolidColor)
```
I don't think it will add any clarity. Will just make things more complicated and add a new notation.

N - example of method dispatch with multiple candidates:
```
Shape -> Circle -> GoodCircle
Shape -> Rect -> Square
GoodCircle + Square -> Sprite
var mySprite : anything = createSprite
process(mySprite)
;if we have function for Sprite or one of Square/GoodCircle it would be fine.
```

Y - if a function needs a parameter which must have fields from two types, it can be defined like this:
`func process(x: (TypeA, TypeB))` this is an in-place definition of a tuple which inherits from two other tuples.

Y - How do we solve diamond problem?
`type MyType := (A, T, B)`
`func process(x: (A,T))`
`func process(x: (T, B))`
```
func process(int, int, int, int, int)
func process(string)
type C := (string, int, int, int, int, int)
process(c) ?
```
there is ambiguity here in both cases. what if fields are not same?
in this case shall we match with the one which covers most arguments? 
I think a better solution which makes method dispatch simpler and more understandable is to issue a compiler error.
Only if there is ambiguity. 
For example for Shape-Circle case, if a method is not defined for Circle but for Shape, a call with Circle instance which is not ambiguous can be redirected to Shape.

Y - multiple dispatch
maybe we should only care to the dynamic type and function should specify dynamic types they can accept.
`Drawable >> Shape >> Polygon >> Rectangle`
`func process(x: Drawable, y: Drawable, z: Drawable)`
`func process(x: Polygon, y: Shape, z: Drawable)`
`func process(x: Rectangle, y: Drawable, z: Shape)`
`func process(x: Rectangle, y: Shape, z: Shape)`
`func process(x: Polygon, y: Polygon, z: Shape)`
`func process(x: Drawable, y: Shape, z: Polygon)`
suppose that we have these methods. when we make a call `process(a,b,c)` if dynamic types are R,R,R then no function will match the type completely. There are three options:
1. Provide an algorithm to select best match
2. Issue compiler/runtime error
3. Provide a mechanism to select default method
We can combine 2 and 3: You can define default method using `anything` type! and redirect to a good method. Else there will be error.
But how can we cast `anything` to `Shape`? This may not work all the time.
`func process(x: anything, y: anything, z: anything) -> process(...`

Y - When we have this:
`func process(x: Circle) -> process(Shape(x))`
the runtime type of x is not changed. It will still be Circle, so how can we force calling process(Shape)?
similarly:
`var t = Shape(myCircle) - process(t)`
which pocess should be called? Process(Circle) or process(Shape)?
static type of t is Shape (specified in the code), but dynamic type is Circle.
We dispatch a method call based on dynamic type of a variable so how can we ever redirect to another version?
Maybe we should keep 3 types: static, dynamic and dispatch.
`var t = createCircle - process(t)`
What about this? If static type of t is Shape and dynamic is Circle? Definitely process(Circle) should be called.
So, `Shape(t)` will change both static and dynamic type of the data. So, any further call to methods with this value, will consider it's static and dynamic type as Shape.
As a result, inside a method we are sure that static and dynamic type of input are the same.
But: `var cir: Shape = createCircle(); process(cir)`
if there is no `process(Circle)` this should call `process(Shape)` automatically! No.
If Circle inherit from Shape and Drawable and we have methods for both of these types, it will cause ambiguity.
Now that we are allowing multiple dispatch and multiple inheritance, things in the call-side are getting very confusing and ambiguous.
We should try to make this part as simple and stratight forward as possible.
If there is ambiguity (more than one choice) we should throw error.
User can cast a variable to a supertype, to remove ambiguity. `process(Shape(circle))` or `process(Drawable(circle))`.
We can say, in a function with more than one input, dispatch method can travel in hierarchy for the first argument but other arguments should exactly match dynamic type of the input. But this is too complicated.
User can easily write catch-all function:
`func process(x: Shape*, y: Drawable*, z: Drawable*) -> ...`
this will catch any call where x is Shape or it's subtypes, y is Drawable or subtypes and ...
Of course any other function with this name and 3 inputs must not have conflict with this.
Or maybe we can cover this in a sum type: `type ShapeOrChildren := Shape | Circle | Square | ...` No.
multiple inheritance with single dispatch
single inheritance with multiple dispatch
multiple inheritance with multiple dispatch!
another way: when calling a function, indicate which argument can be casted to parent type if needed.
automatic casting of an argument to higher type (Circle to Shape) means loosing data. And this should only be done with explicit permission of the caller/developer.
For a function with just one argument, polymorphism is easy. Just traverse inheritance graph upward. If multiple choices found, issue an error.
```
Drawable + Shape -> Circle
func process(Drawable)
func process(Shape)
process(myCircle) -> error : two candidates found
```
- If function argument type must match the dynamic type of the argument, how can we earn flexibility? 
1. By changing function signature `func process(x: Shape*)`
2. By changing at call site: `process(~x)`
"There are not that many real cases where double or triple dispatch is used" - http://hpac.rwth-aachen.de/teaching/sem-lsc-12/MultipleDispatching.pdf
So why make it so complicated?
- In case of single argument, we can look in type graph.
- More than one: what if second arg is an integer?
For each method call, first find candidates (same name and number of inputs).
Filter out the ones that type of argument conflicts with type of parameter being sent.
Remaining: If one -> call, if multiple and they differe on only one type -> traverse type graph
else error.

Y - If f is for Shape and we call it with Circle, it will be called with Shape.
If `f` calls another function which is for both Circle and Shape, which one will be called?
The one for Shape? Circle?
Option: If a parameter is named `this`, it can match with subtypes of that type. Else type must match.
`func process(this: Shape, x: Drawable, c: Color)`
here x and c must match given types. but `this` can be Shape or Circle or ... .
So when you call another method `method1(this, ...)` it be resolved to find best match.
So if we have `method1(Shape)` and `method1(Circle)` and `this` is not Shape but a Circle, it will call `method1(Circle)`.
This makes method dispatch simpler and more explicit and naturally prevents multiple dispatch problems.

Y - `&process(myCircle,$_,$_)(10)(20)` - does this make sense?

N - assign by value/reference
```
type AB := int | float | Customer
var t: AB = 9
var h: AB = x ;is this assignment done by value or reference? should be by value.
var g: int = int(x) ;is this possible? no. you should cast (and check type before).
var g:int = x :: int -> int(x), anything -> 0
```
Assignment of sum types, is based on type. if primitive is being assigned: copy else, reference.

Y - provide a mechanism to put multiple commands in the same line
`var x =10;x++`?
`a&b&c if (x>0)`
`loop(5) a&b&c`
`&`?

Y - shall we differentiate the notation for tuple? it is similar to function call.
what about type specialization?
```
type Point := (x: int, y: int)
var p: Point = Point(x=10, y=20)
var p: Point{int} = (x=10, y=20)
```
`[]` is used for hash and array
`()` for function call
`{}` for block and type specialization
if we use `{}` for tuple definition and literals (then we can use `a:b` notation) what about type specialization?
`%` and `^` are not used.
`a=b` notation implies a variable definition in tuple assignment.
```
type Point := {x: int, y: int}
var p: Point = Point{x:10, y:20}
@p ==> x:10,y:20
{@p} ==> {x:10,y:20}
var t,u = @p -> t=10, u=20
var p: Point(int) = {x:10, y:20}
process(x:10, y:20)
process(@p)
var p: Point(int) = {x=10, y=20}
type Record := { Vector(V:int), Stack(int), Map(int, string) }
```
What about calling a function with named input?
`process(x:10, y:20)`
we should use `a=b` when a is a defined variable.
summary of changes proposed:
- Type specialization: `T(A:X, B:Y, C:Z)` or `T(X, Y, Z)`
- Casting with specialization: `var p: Point(int) = Point(int){x=10, y=20}`
- Tuple definition: `type Point := {x: int, y: int}`
- Tuple literal: `var p: Point = Point{x:10, y:20}`
- Function call: `process(x:10, y:20)`
- Call by explode: `process(@p)` ==> `process(x: 10, y:20)`
- Explode operator: `@p ==> x:10,y:20`
- Cloning: `var x = {@p}`
- Explode tuple: `var t,u = @p -> t=10, u=20`

N - what if function output is a tuple?
`func process(x:int) -> {y:int} { ... }`

N - what is the syntax for casting? primitive, tuple, string, sum, func, ...
`int(x)` `x.(int)` `x:int` 
`Point(x:10, y:20)` or `Point(var)`
`Point(int)(x:10, y:20)`
`string(x)`
`OptionalInt(x)`
Maybe using `type(x)` notation is not really good because it's confusing with function call.
`x.(type)`
`x%type`
`{x:10, y:20}%Point(int)`
`Point(int)({x:10, y:20})`
`{x:10, y:20}.(Point(int)).process...`
`{x:10, y:20}.(Point(int)).process...`

Y - What if user wants to write a function with the same name as a type?
`func bool(x:int)`
`func string(t: Record)`
We can disallow that.
What about casting to string? maybe `toString` function.
There is no built-in casting. If you want to cast MyRecord to Customer, write a custom function for that.

Y - What about `%` for casting to make it super explicit?
`%int(x)`
`%string(x)`
`%OptionalInt(x)`
`%Point(var)`
`%Point({x:10, y:20})` --cast a tuple literal
`%Point(x:10, y:20)` -- cast an exploded tuple
`%Point(@t)` same as `Point(t)`
`%Point(int)(x:10, y:20)` -- casting combined with type specialization
then user can write functions with name of built-in types. one less rule.

Y - The notation for specialization is a bit weird. Can we make it more readable?
`type ShapeTree := Tree(Shape)`
`push(int)(intStack, intVar)`
`Stack(int)`
Alternatives:
`Stack<int>` - more intuitive and familiar
`push<int>(...)`

Y - Note: you cannot use `<>` notation when declaring a function or a type.
Only when you call a function or refer to a type.
`func push(Stack<!T>)` is refering to a type.

Y - Can we do the same specialization that we have for tuple, for functions?
```
type Stack := !A[]
func pop(x: Stack<!A>)->!A ;notation is same as type definition, we use !X or any type name.
;when we want to call push, we can specify value:
var t = pop<A:int>(intStack)
var t = pop<int>(intStack)
;for push
func push(x: Stack<!A>, y: !A)
push<int>(intStack, intVar)
push(intStack, 10)
```
This needs more typing but is more readable. And provides some level of generics.
What is exact explanation about this? 
What changes does it mean?
1. Function declaration is like type declaration. You can use any type and also use `!T` notation to simplify.
2. Function call: `functionName<A:B, C:D>(input1, input2)`
This will re-create the function and replace types with given types and make the call.
It depends on the implementation, maybe compiler just adds type checking.
question: How do we define a length function for Stack? (supposed to work with all stacks)
solution 1: use this, so parameter can actually be subtypes.
`func length(this: Stack)->int`
solution 2: define it as generic. user needs to specify type
`func length(x: Stack<!T>)->int`
`var y:int = length<int>(intStack)`
what if we have this?
`func push(x: Stack<!A>, y: !A)`
`func push(x: Stack<int>, y:int)`
if we call `push(a,6)` and `a` is `Stack<int>` which one will be called? Of course second one because there is full match.
if we call `stack<int>(a, b)`? still the second one should be called. because compiler wants to re-create `stack` using `int` but notices it is already defined. So just makes the call to the existing one.

Y - in order to increase readability, limit templating only to arguments marked with `!`.
Then, how can we limit it?
`!X` where type is single capital letter is reserved for general generics.
Other than that you can write `!MyType` to mean that this parameter must inherit from mytype.
```
type Map<K,V> := K => V
type Stack<T: Customer> := T[]
func push<T>(s: Stack<T>, x: T)
func push<int>(s: Stack<int>, x: int) ;specialization
func pop<T>(s: Stack<T>) -> T
func len<T>(s: Stack<T>) -> int   ;general function for all instances
var t : Stack<int>
var h : Map<int, string>
push(t, 10)
var y = pop(t)
x = len(t)
```

Y - is it possible to define a generic function which has no generic input?
`func process<T>(x: int) -> T`

Y - explain full method dispatch flow.
steps, options and choices.
named arguments, ref parameters, multiple hierarchies, generics, this parameters, primitives, array, hash.
first option: full match with dynamic
second option: this parameter, subtype match
last option: static type full match.
- Suppose that there is a call to function `f` with 3 input arguments. Here is the method dispatch process:
1. CL := find all functions with name `f` which have 3 inputs.
2. If inputs are named: remove from CL where there is name mismatch.
3. If there are `ref` inputs: remove from CL where there is ref mismatch.
4. DT1, DT2, DT3 = dynamic type of 3 arguments specified in the call.
5. find x in CL where type of parameters are DT1, DT2, DT3
6. If found one, call `x` and finish. If found more than one -> Error and finish.
7. for x: CL where name of one of parameters is `this`:
    7.1. T := type of this parameter
    7.2. AT := type of corresponding argument
    7.3. if AT is T or T's child, add `x` as a final candidate.
8. If there is only one final candidate -> call, if there is more than one -> Error
9. ST1, ST2, ST3 := Static types of 3 arguments
10. find x in CL where type of parameters is exactly ST1, ST2 and ST3
11. If found one -> call, if not found or more than one found -> Error

? - With new method dispatch mechanism, how does it affect subtyping rules that we have?
for function, tuple, sum, ...

