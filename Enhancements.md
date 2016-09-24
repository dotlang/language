#Enhancement Proposals


Y - decorators - another try
lets define some native, built-in functions. 
1. `func` data type means any function.
2. `invoke(x)` where type of x is fund or any other function, will call x.
```
func html<T>(id: string, f: func, i: input) -> T
{ return func(x:int) "<div id=$id>" + invoke(f) + "</div>"; }
@html("tt")
func test(x:int) -> string { print "A" + x + "B"; }
```

Y - if function can return two results, then we have tuples half supported.
let's add official support for them, then define a generic function and decorator based on it.
`var x: int = 11;`
`var t: tuple(x: int, y: int, z: float) = (1,2, 3.1);`
`t.x = 8;`
`var t: tuple(x: const int, y: int, z: float);`  
if tuple only has one field, it is same as variable, and does not need field name
`tuple(x: int) ~ tuple(int) ~ int`
now a function accepts a tuple and returns a tuple.
tuple is like anonymous struct.
`func print(x: int, y:float) -> string ...` output is `tuple(string)`
`func print(x:int, y: float) -> (a: string, b: int) { ... }`

now we need two more keywords: `func` representing any function, `tuple` representing any tuple.
`type fp<T, U> := func(T) -> U;`
`func make_bold<T, U>(f: fp<T,U>, input: T) -> U { U out = f(input); return "<B>" + out + "/B"; }`
```
@make_bold   //T is tuple(x:int) and U is tuple(string), compiler can infer them
func get_data(x:int) -> string { return x.toString(); }
```

\* - how can we mock a function for testing?
`mock func1, func (x: int) -> string { return "AA" };`
at least, this can easily be done with built-in functions.
so lets not pollute syntax with it.

Y - now that we are functional maybe we can use some of perl features.
`x if y`

N - lets declare primitives are passed by value and verything else is by reference.
then what happens to `=`? for primitives, duplicates, for others ref assignment.

N - how can we convert between const and others?-> answer: clone
`const int x = 12; int y = x; //y can be changed but not x. they are separate`
if it is a strct, we need to clone it.
or we can define normal type and reference type. normal type acts like primitives, they are copied.
like `int` in C.
reference type is like `int&` in C.
and what about const? and how can we manage all notations when combined?
e.g a hash of `const reference int` with value being `reference float`:
`x: ref_float[const ref_int]`
`x: float&[$int&];`  //$ is like static which means constant. $ prefix, & suffix
so we can define ref, const and ref-const for any type.
`x: $int&[];` //x is an array which is const and a reference.
`y: int[$&];` //x is an array containing const references to other ints. 
`int x = 12; int& y = x; y++;` this will increase value of x
`int x = 12; int$& y = x; y++` this is not allowed as y is const, but we can change value of x
`int, int&, int&&` - can we have a const which is not reference? of course we can. 
so we have 4 cases: non-const non-ref, const non-ref, non-const ref, const ref
`&` for reference type - like C pointer
what about constant? if we assign a keyword, it will be more readable. if we assign a character, it will be more expressive.
`int.`?
`int:` ? confusing with all definitions and hash.
`int^`
`int%` - we can say if first letter start with capital but this will apply only for structs.
`int?`
`const ref int` - we already have a long syntax for func definition
`int~` and ~ can mean variable - so default will be immutable.
`int~&`
we can use ~ for mutable and ! for reference.
`int~[]` means a mutable array
`int[~]` means an immutable array containing mutable integers
`int![]` means an array reference
`int[!]` means an imm array containing ref integers.
`x: int~![string~!]` means x is a hash-table whose keys are ref-mut-string and values are ref-mut-int. but what about the x itself? is x mutable? how can we define a hash-reference? syntax becomes so complex.
`x: map~!<int~!, string~!>;`
even if we only have const,
`x:const int[const string]` x keys are const string and values are const int. but what about x itself?
`x: const map<const int, const string>` this is more readable but too long!
so x is const and we cannot re-assign it.
`const int x = 12; int y = x; ` this is wrong! we cannot cast const to non-const.
but we can cast non-const to const.
if you need, you can clone the const. `const int x=12; int y = ~x`;

N - reference type
`int x = 12; int& y = x; y=9;` this will change value of x too. right?
`int x=12;int& y=x;`
this reference type makes things more confusing.

Y - behavior of =? passing arguments?
primitives are passed by value and = duplicates their value. just like java
other types (types) are passed by reference.
`type x := int;` x is same as int, so it will be passed by value.
if you want to pass something by value? wrap it inside a struct.
tuples are passed by value too.
but this will be confusing. I want to know what exactly will happen when I write `x=y`
suppose that I don't know their type!
we can assume everything is a reference. passing is by reference.
if you want to have it not changed pass a copy by `~`.

N - adding constraint on struct fields. No other language has this and it makes everything more complex.

N - if we can provide a tuple, we can remove notation of `$_`.
`get_data => sort(1, $_) => reverse => print (out, $_)`
will become:
`(1, get_data) => sort => (out, reverse) => print;`
but first version is more readable. and if get_data returns a tuple?
anyway, I think, if fn returns a tuple, it is still one thing.
so `(1, $)` when $_ is output of a function which returns (1,2).
means -> `(1,1,2)`?

\* - Some shortcuts can be very useful like:
`x = y if defined y` becomes `x = y if defined;`

Y - replace tuple with struct without name.

Y - Maybe we can define constraint on a type.
`type x := int requires{ x > 0 };`
`type x := const int requires{ x != 3 };`
if above is possible, also we should be able to define that for a struct!
`type x := struct { x:int, y:float; } requires(x != y);`
requires can only be defined on type. not functions.
but it should be possible to use this notation for pre-conditions:
`func ff(x:int) -> string requires(x!=0) {...}`
you cannot use requires when defining lambda expression. but if expression has a type, the type can have this.
This cannot be defined for anonymous types like lambda or tuple.

Y - maybe we can have better syntax for inheritance:
`type x := struct : Parent1, Parent2, Parent3 { x: int; y:float };`
this syntax is more readable.

Y - implicit inheritance. StructA inherits StructB it contains it's fields with same name and type and functions.

N - can we replace struct with a better name? NO.

N - can we say tempalte parameters for function are always inferred by compiler? yes
We just need to specify type when dealing with template for structs.
just like OOP: stack<int> s; for s.push we don't need to specify type T because it is implicit with s.

N - How requires is inherited?
`type a := int requires {x>0};`
`type b := struct :a {int h;}` -> requires b.a>0

Y - can't we define `const int` as a new type like:
`type const_int := int requires{ const_int == nil };`
or instead we can use `default` keyword. 
`type const_int := int requires{ const_int == default(int) };`
or:
`type const_int := int requires{ const_int == 0 };`
but if we use 0 here, what about structs?
`type const<T> := T requires{ T == 0 };`?
`type const<T> := T requires{ T == default(T) };`? so even if they make any assignment to default(T) it will be permitted but value won't change because it is already default(T)

Y - replace type name with something else in requires.
`type x := int requires{ x > 0 };` this does not make sense
`type x := int requires{ $! > 0 };`
or
`type x := int requires{ this > 0 };`

Y - union data type: is it really needed?- no we can define using struct + requires
`type nullable_int := union { x: int; nil: }`?
we can label some of valid values for a sum type. This is just an extension of enum. 
it can be used to define nullable type. 
`type DoW := union { SAT; SUN; ... };`
can't we implement union with struct + requires?
`type DoW := struct { isSAT: bool; isSUN: bool; ... } requires(this.isSAT xor ...); `
we can say, struct members which don't have a type, are flags, and their type is `bool`.
`type DoW := struct { SAT: bool; SUN: bool; ... } requires(this.isSAT xor ...); `
advantage: we won't need union as a new data type and also enum.
dis: syntax will look weird.
`Dow dd = Dow{SAT: true;}`
`if ( dd.SAT ) ...`
`type nullable_int := struct { x: int; nil: bool; } requires(either(x, nil));`?
we can define a special operator `either` so when it is used in the requires part, compiler will optimize for storage.

N - replace strange $_ $$ symbols with good names?
for $$ it does not make sense to change it. same for $_

N - Syntax for list? Just use templates.
we only provide special syntax for arrayand possibly for hash.
we will have set, list, queue, stack, ... but not in syntax level.

N - can we further simplify decorator?
```
@make_bold
func get_data(x:int) -> string make_bold { return x.toString(); }
```
Y - we have same syntax for casting and decorator!
use keyword for casting.
`float f; int x = !int(f);`

Y - accessing inputs using $ array?
`$[0]` - no it is used for array which has data of the same type
`$0, $1, ...`

Y - remove const keyword from documentation.

N - can we define (like Haskel):
`func f(x:int) -> int ...`
`func f(5) -> ...`
No. its not beautiful and makes runtime/compilation hard. we can do this via `if` easily.

Y - syntax for hash:
`x: int[]` for array
`x: int[const string]` for hash. key of hash cannot change so must be const.
`x: const map<const int, const string>`
it is possible to define mutable key but developer will be responsible for that.
`x: const int[const string]` means a hash which key and value are both constant int and strings.
but is x const itself?
now that we don't have const:
`x: int[string]`
`x: cint[cstring]`
etc.

N - list type
`x:int; y: [int];`? y is a list of int.
no. lets use core tempalte types.

\* - using % to fetch annotations?
`%x` returns a hash of annotations on the data.
its type: `hash<string, hash<string, object>>`

\* - define something like seq in F# to have a generator function to be used in loops.
`for (x: seq(1..10))`

Y - vairadic functions?
`func print(x: int, params int[] rest) {...}`
params is just a hint to the compiler to create appropriate array
if we define such a function how will decorator work on it?

Y - can we merge require and data annotations?
or make annotations in a keyword format:
`x: int requires { x>0 } annotate {json:ignore};`
annotate accepts a key:value pair and all annotations will be a hash-table.

Y - replace inheritance with extends keyword.

Y - casting syntax: remove !
`!int(x)` -> `int(x)`
for every struct, we have a function with the same name to cast a variable to that type.

Y - cloning - we don't need `~`.
`x : MyType = {x:1, y:2};`
`y : MyType; y = x{};`
`y : MyType; y = x{y: 5};`  //we can modify in the same syntax

N - we cannot say: if `f` expects it's input to have function F supported, it must have type T so that ?
do we need interfaces here?

Y - How can we constraint a type in template?
template stack<T> where T must be a number
or T must conform to these methods.

Y - operators as functions?
`func adder5(x:int ) -> { x+5}`?no.
Haskell and F# have it.

? - think about how to implement a pricing engine/vol-surface/economic events and contract object in new approach.
