#Enhancement Proposals - Part 2

Read [Part1] (https://github.com/mm-binary/electron-lang/blob/master/backup/EEP.v1.md).

\* - Runtime - use concept of c++ smart ptr to eliminate GC

\* - Add native parallelism and communication tools.

\* - Introduce caching of function output (if it is not void)
Maybe this can be done automatically by runtime.

N - If we really don't want to end statements with `;` then use another notation for comment.

Y - In reference, try to just cover important high level topics and inside them explain details and edge cases. For example explain `enum` in Union type section.

Y - We can enhance import with other file systems like http:
`import /a/b` import from local file system
`import file/a/b` import from local file system
`import http/github.com/adsad/dsada` import from github

N - how can we mock a method? in a general way. so it won't be limited to testing. 
we can easily define a lambda to mock a method. but how to attach it to that method?
there is no manager, parent to accept this lambda.
proposal: built-in method: `mock('myMethod', <<lambda>>);`
to do mocking in the life-time of the current function. 
This should only be used for testing.
Y - Add regex operators for search and replace.

N - define something like seq in F# to have a generator function to be used in loops.
`for (x: seq(1..10))`

Y - how can we mock a function for testing?
`mock func1, func (x: int) -> string { return "AA" };`
at least, this can easily be done with built-in functions.
so lets not pollute syntax with it.

N - Some shortcuts can be very useful like:
`x = y if defined y` becomes `x = y if defined;`

N - For core - function to return hash representing a struct, used for serialization, and what about deser?
`string[object] result = serialize(myObj);`

N - Other than manual clone, provide a `clone` in the core to help developers.

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

Y - now that we are functional maybe we can use some of perl features.
`x if y`

N - lets declare primitives are passed by value and verything else is by reference.
then what happens to `=`? for primitives, duplicates, for others ref assignment.

N - how can we convert between const and others?-> answer: clone
`const int x = 12; int y = x; //y can be changed but not x. they are separate`
if it is a struct, we need to clone it.
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
just like OOP: `stack<int> s;` for s.push we don't need to specify type T because it is implicit with s.

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

N - using % to fetch annotations?
`%x` returns a hash of annotations on the data.
its type: `hash<string, hash<string, object>>`

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
template `stack<T>` where T must be a number
or T must conform to these methods.

Y - operators as functions?
`func adder5(x:int ) -> { x+5}`?no.
Haskell and F# have it.

Y - we cannot implement const using current require syntax.
`type const_int := int requires{ this == default(int) };` - this only ensures that new value is 0!
we need to add a new keyword: that representing the previous value. 
what does this mean?
this means the new value? or previous value?
for function we dont need this or that. but for type, we need both previous and current value.
this can represent the value being assigned. that the previous state.
`type const_int := int requires { that == default(int) };`

Y - replace this with $> and that with `$<`. no this is not readable.
also $0 and $1 is not good too.
this/that.
$0 means old
$1 means new.done.

Y - can we remove or change decorator to make it a keyword or non-built-in feature?
proxy 
facade
around
bundle
like extends it has to be third person present tense.
boxed
wrapped
what if there are multiple methods with that name? compiler can automatically find the fn with correct syntax.
```
//general definition of a function
type fp<T, U> := func(T) -> U;

//decorator function - accepts a function and returns a function with same signature
//returned function will wrap f function and do some other tasks during the call
func make_bold<T, U>(f: fp<T,U>) -> fp<T,U> 
{ return fp<T, U> { U out = f(T); return "<B>" + out + "/B"; } }

@make_bold   //T is tuple(x:int) and U is tuple(string), compiler can infer them
func get_data(x:int) -> string
apply make_bold($_, 'a', 'b')
{ 
  return x.toString(); 
}

//when you call get_data, the wrapped function will be called.
```

Y - can we change requires keyword? its too long.
ensure
check

N - can we make templates more internal?
like haskel?

N - When we have `type x := struct extends Parent1, Parent2, Parent3 {` is it mandatory to re-define all methods of parents for type x? no.

Y - if A inherits from P1 and P2 and these two inherit from PP and there is a method x defined on PP, it is availavle for A too. But A does not implements it. it P1 and P2 both implement this method x, when we write `aObj.x` which of these two should be called?
`func x(p: P1)->int ...`
`func x(p: P2)->int ...`
`type A := struct extends P1, P2;`
`var v: A{}; var t = A.x();`
in Java with default methods, this behavior results in compiler error. type A must implement method x.

N - easy syntax for composition function redirection
`func x(a:Data, b:int) -> int { return a.x(b); }`
`func x(a:Data) -> a;`
it doesn't mean `a.x`! fn redirection is when I function x is called, it should just call function y.
`func x(a:Data) -> y(a;`
no it needs a lot of modifications and special syntax.

Y - replace $1, $2,... with array-like syntax: `$[0]`
so we can use slice syntax on it.

N - easy syntax for struct which has either.
`type DoW := struct { isSAT: bool; isSUN: bool; ... } ensure(either(isSAT, isSUN,...));`
`type DoW := struct { SAT; SUN; ... };`
`type DoW := struct { SAT; SUN; ... };`
except for enums, it won't be readable.

Y - for primitives, we can have operator `=` overridden for them to assign them by value.

N - Stack/heap allocation?

N - adding some prefix to fn names as a grouping mechanism.

N - Like oop where we should rely on interface not implementation, we should extend from types with no fields. and rename extens to implements.
But if everything is transparent and auto-binding, we cannot ban this.
It needs more thinking.
we have polymorphism.
When we have a function that takes T, we can send anything other than T as long as they have exactly same fields.
so, if a type has no field, we can pass ANY struct instead of that.
HOW can we indicate in a function that we need as input a variable x of type X which has method F implemented on it?
I want to be sure if I get Y instead of X, I can call F on it. If I get Y instead, it means Y contains all required fields. so I can call F on it.
so how can we re-use code? implement function on the parent type. we can override function for a child type anytime we want.
do we need to explicitly indicate a type inherits from another type? No.
if we have T1 and T2 as empty structs and function `f` is defined for T1 and T2 separately with different bodies, what should `f(x)` do if type of X is something other than T1 or T2?
`f(a: T1)...`
`f(a: T2)...`
compiler error shown be thrown. there is ambiguity.

N - If a type has no field, is it same as interface? what if it has a set of methods which have code? this will be same as java interface with default methods. 

N - avoiding inheritance from types with fields makes instantiation of the type easier.
yes. but if inheritance is auto-inferred then we don't need to do anything special.

N - to organize function, we can name them from genearl to specific part:
`stack_prepare_data`

N - inheritance without methods? I want a Stack type which inherits from List struct. But I want my own methods on Stack. I don't want to have 100 methods defined on stack -> solution: composition.
But if a struct inherits from a field-less type and wants just methods to implement, we can simply write them.
interface implementation check is based on duck-typing.
`type X; func f1(a: X, b:int) -> int...`
`func dowork(b: X)...` function dowork expects `b` input of type X. so it expects to be able to call: `f1` and pass b.?
question is: how do we know if data of type T1 can be passed where data of type T2 is expected?
`func (==)(a: EqChecked, b: EqChecked) -> bool { return eq_check(a, b); }`
`type EqChecked := struct;`
`func eq_check(a: EqChecked, b: EqChgecked) -> bool;`
any type that has above method implemented for itself, can be used when EqChecked type is needed.
`type Event := struct { x:int };`
`func eq_check(a: Event, b: Event)->bool { return a.x == b.x; }`
`type Stack := struct; func push(s: Stack)...; func pop(s: Stack)...;`
`type MyStack := struct {}; func push(s: MyStack)...; func pop(s: MyStack)...;`
When Queue can be used instead of Collection? what if there are some methods on Collection which don't have anything for Queue? 

N - can we simplify ensures with accepting only one value and using a built-in function called: const to make sure a value does not change?

N - constraint can be used for testing too to ensure output.
reverse, test should be used to make sure output of func is correct.

Y - provide a mechanism for explicit inheritance. we cannot re-type all the fields.
and what if those fields change?
but normal inheritance will make instaitiaion of struct complex.
what about compose as inheritance?
suppose that we want to define a ordering relation. 
```
type Ord := struct;  //now field can come here
func compare(a: Ord, b: Ord)->int; //compare two structs and return the bigger one
type Stack := { x: int; y: float; ...}
```
What will happen if someone calls `compare` on stack? Its not a valid call.
so polymorphism only based on fields, is not a good way.
structs must explicitly indicate their types.
Of course it will be possible to do casting. so if its not explicit but fields are ok, user can cast.
we need a mechanism to state type A can be used instead of type B or C or ...
so, Stack can NOT be used instead of type Ord. we just don't mention that in Stack definition.
but for ComplexNumber type, we definitely mention that.
of coutse parent types must match fields of the current type.
`type BMWCar := struct {...}` we want to state BMWCar can be used instead of Car type.
`type BMWCar := struct {.} extends Car;`
`type BMWCar: Car := struct {.};`
`type BMWCar := struct {.};`
`type BMWCar := struct {c: Car};`  this definition 1) adds required fields to BMWCar and states bmwcar can be casted to car.
but what if struct has two members of that type?
`type BMWCar := struct {current_car: Car; prev_car: Car};`
do we really need automatic and transparent casting?
if some method needs a car, just send `bmwcar1.current_car`. 
but sometimes we need this. e.g. when the member is an empty market type.
```
type Ord := struct;  //now field can come here
func compare(a: Ord, b: Ord)->int; //compare two structs and return the bigger one
type ComplexNumber := { x: int; y: float; x: Ord;}
var a: ComplexNumber;
var b: ComplexNumber;
bool h = a>b; //this will call compare method on a and b.
```
if there is just one, you can ignore casting, but if you have two fields of that type you must cast explicitly.

Y - better keyword for ensure -> constraint, pre/post (for type, assignment, for function, call). 
require
requires
check
contract
expects
invariant
assert

Y - can we have `var x: int assert(...)`?
should be possible because we can easily define this as a new type and use it instead.
what about function input? if we can do that, we may be able to use `assert` for function as a post-condition.
`func f(x: int assert($[0]>1), ...)`
also in assert on a variable we can use var name? no, because assert is called before value assignment.
lets have this: `x: int assert(const(x));` which makes sure value of x has not changed. 
and then we can say, assert is called AFTER method call, variable assignment, struct modification.
so we may need to change name assert to stress it is post-condition type.
contract
guarantee
or a shortcut like: $, @, !, <>, :
`type x := int[$_>0];`
`var x : int[$_>0];`
`type x := struct {...} [$_.x > $_.y];`
`func ff(x: int[$_!=0], y: int[$_>1]=1)-> bool {}`

N - fn definition replace -> with : ?
Scala: `def addInt( a:Int, b:Int ) : Int`
`func get_data(x: int, y:int) : int { return x+y; }`
pro: is general and orth
con: maybe we need to stress more about the result type of fn
con: when we use a fn as input of current function, `:` will get mixed together and code will be unreadable.
`func map<T>(f: func(T) -> T, arr: T[]) -> T[];  //map function`
`func map<T>(f: func(T): T, arr: T[]) -> T[];  //map function`
`func map<T>(f: func(func(T) -> int) -> T, arr: T[]) -> T[];  //map function`

N - how can we write casting code to cast type X to type Y?
e.g. cast DoW type to int.
`func int(d: Dow) ...`

Y - when is assert for struct called? 
after any change in it's fields.

Y - when is assert for field called?
before any change in it's value? 

N - Extend constraint to define default value.
required -> non-nullable means has to have value
lazy -> not needed here
you can set default value using: `x: int = 11;` syntax.

N - use namespace for functions and structs.
how to solve expression problem?
no we have modules.

N - shortcut for const: .x
`x: int [.$_];`
`x: int [.$_];`
`x: int [const $_];`

N - indicate cached data
`proto fib (|) is cached returns NonNegativeInt {}`
we have decorator for that.

Y - syntax for function delegation
`func a(x:int)-> x+1;`

N - trigger when field value is changed?

N - same syntax for func and lambda
`a: func(x:int)->int = { return x+1;}`
`func a(x:int)->int { return x+1;}`
`func a(x:int)-> x+1;`

N - polymorphism
what if struct BMW has a struct Car and we have `f(BMW)` and `f(Car)` and we call: `f(myBMW.Car)`?
f(Car) should be called. but if we call `f(myBMW)` f(BMW) will be called.

Y - lazy evaluation is like build_x in Perl.
`lazy val cheapOrders: Seq[Order] = orders.filter(_.price < 50)`
we may define a variable lazy
or a function which accepts an int. we can pass `f(1,2,3)` which returns an int but as a lazy. so it will be called only when that parameter is used. but this is not useful because that parameter must be used or else its redundant. but there maybe some cases like if/else where its not called.
`int x = lazy(expression);`
`do_work(a, x);`
x block will be called only when it is accessed. 
`type x := struct {count:int};`
`func create_x() { return x{count: lazy(call_function1(10000))}}`
`int x = lazy(expression);`
`int x ~ expression;`
`int x = &expression;`
we prefer keywords and try to keep operator usage at minimum. so code will be simpler and more readable.

N - constraint on function enter
```
func get_data(x: int, y: int[$_>0]) -> string[const $_] 
{
}
```
this will be inconsistent and make code ugly.
lets do it in assert.

N - replace `$_` with `$`?
also in the chaining.
but $ is used for input array. this will confuse things.
we have `$[0]` notation too.
`func get_data(x: int, y: int[$_>0]) -> string[const $_]`
no lets keep it.

Y - is constr part of type?
`var x: int[const($_)] = 11;`
`var y = x; y++;` 
is this valid?
if y is a copy of x, its ok.
if y points to x, then no.

Y - remove decorators?
applications: logging, validation (we have constraint), caching (lazy), permission check, transaction, monitoring, timing (external tool), error handling.
we have `meta` to add metadata to be used later.
permission check: is a one line, either decorator or one line assert.
of course developer can write a `make_bold` general function.
decorator for 1/2 line of code is not good. and that's the case for timing, permission, logging and error handling.
for validation and caching we already have tools in-place.

N - `=` assigns by what?
copy for primitives, ref for everything else. unless you override the operator.
how to make a copy of a data? `y = x{};`
and how can we duplicate a reference? `y=x` will use = operator
`x{}` will duplicate x. so we can force assign to copy.
but how can we force assign to reference? we really don't need that.
if you need a reference to x, just use x. 

Y - using `$$` instead of `$_` for constraints.
still for chaining, we will use `$_`.

N - add a shortcut instead of either. because sometimes number of fields is high and its not good to repeat all of them.
`[union($$)]` - we add union type

Y - suffix syntax for if and for
`x++ for(10);`

Y - rule of locality: let the developer put the code at the nearest location to where it applies.
code for validation of a variable is best to put when variable is defined (constraints).
we should not be writing two highly related piece of code, far from each-other.

Y - same as default(T) we need undef(T) so for a linked-list of when customer is not found, we can return undef.

Y - define enum data type
```
type DoW := enum { SAT=0, SUN=1,... };
x: DoW = DoW.SAT;
if ( int(x) == 0 ) ...
```
we want excellent support for all types. so lets define a separate keyword for enum.

Y - better support for sum type. define them and check their tag and support for enum.
Basically union is a single simple variable, but you can choose which kind. It is a combination of struct + enum, enhanced for memory.
```
type maybe_int := union {
  Nothing: bool;
  data: int;
};
x: maybe_int = maybe_int{data:12};
y: maybe_int;
y.Nothing = true;

//you cannot have two flags with the same name, but same type is OK -> for enum
type int_float := union {
  age: int;
  average: float;
};
a: int_float = int_float{age:12};
b: int_float = int_float{average:3.14};

if ( a.age? ) int x = a.age;
if ( a.average? ) float f = a.average;
```

Y - add reverse chain operator `<=`
`finalize_operation(1,9,4, $_) <= get_customers <= (1,9)`
sometimes top-bottom makes more sense. but this is only a syntax sugar. compiler will convert them to `=>`.

Y - can we generalize `$_` notation?
we have `add(x,y)`. `add(4,$_)` will be an anon-func which adds 4 to the input.
`var t = add(4,$_);`
`var y = calculate(4,a, $_);` ~ `var y = func(x:int) -> calculate(4,a,x);`
`var y = calculate(3,$_,$_);` ~ `var y = func(x,y:int) -> calculate(3, x, y);`

Y - anonymous union?
what is syntax for anon-struct?

Y - `$` is not an array.
- The `$` array contains function inputs. This is useful specially in lambda expresions.
we use `$0` for first argument not `$[0]`
maybe now we can use `$` instead of `$$` for constraints.

Y - monad
a monad is a type which supports `>>=` opertor.
```
func (>>=)(x: Maybe<T>, f: func<T,U>) -> U
{
  if (x.IsNull) return default(U);
  return f(x.value);
}
```
then if we have: `y=x >>= calculate`; if x is null, y will be null without invoking calculate function.
if x is not null, calculate will be called.
what if calculate has multiple inputs and one of them is x?
`y = x >>= calculate(a,b,$_);` if x is null y will be null, else, calculate(a,b,x.value) will be called.
in `>>=` the `calculate(a,b,$_)` is a function which accepts a single input and gives an output.
we can even have: `y = (a,b) >>= calculate;` or `y= (a,b) >>= calculate(4, $_, $_);`
so depending on the implementation of `>>=` for this case, it may or may not call `calculate(4,a,b);`
can we just use `=>` operator?
`Maybe<int> t = ???; t => div(5,$_);`
if t is null, `=>` will return null, else will call right-hand function.
I think this is possible. but you cannot implement both `=>` and `<=` only `=>` compiler will handle to conversion.
```
//a => b when a is Maybe<T> and b is a function which takes T and outputs U
func (=>)(x: Maybe<T>, f: func<T,U>) -> U
{
  if (x.IsNull) return default(U);
  return f(x.value);
}
```
note that input of `=>` can be a single value which is anon-struct:
`y = (a,b) => calculate;` in this case, `=>` will be called with input, anon-struct and output = output of calculate.
Also output of => can be different from f output. For example it can have additional information about calculations.
```
//we can specialize => code
type someF := func(x:int)->int;
func (=>)(x: Maybe<T>, f: someF) -> U
{
  if (x.IsNull) return default(U);
  return f(x.value);
}
```

N - define anons in fn definition using () not {}

Y - typed functions
How can we say the `f` parameter should match with some functions which take int and return int. not all of them?
for int: `int x = 12; type xint := int; t: xint = 11; func(x:xint) -> xint {}`
in above code, f accepts only xint which is basically int but different type. 
how can we do this for functions?
we can easily use type to alias a function definition, but when I define a new function, I don't specify it's type.
for lambda, it is ok. 
`var ff : myLambda = func(...)`
but for function:
`func somef(x:int)->int {}`?
suppose we have: `type FX := func(x:int) -> int{}`
and `type FY := func(x:int)->int{}`
for lambda: `var t: FX = func ;..` and `var y: FY = func` have different type but same signature.
what about normal functions?
maybe we can do this: `func myff(x:int) -> int {} : FX;`
`func myff(x:int) -> int : FX {}`
`func name(inputs) -> output : f_type {}`
of course, f_type must match with inputs and outputs of the function.
when we have above, we can write something like: `func (=>)(x: Maybe<T>, f: FX) -> U`
and this code will only be called when we have `x => f` and f is defined using above notation.

Y - lets allow constraint everywhere including anons and lambda.

N - is there a way to define constraint for a function?
`func f(x:int[$>0]) -> int[$<0] {}`
no. constraint is defined on DATA. function is not data.

N - current syntax to defined tryped function is not good.
`func f2(x:int) -> int : FX { return x+1}`
because its like `x:int` but x is a variable, a data storage.
`f2` is not a variable. so dev may ask, why he cannot add constraint to `: FX` part?
when defining a lambda variable, its totally fine to write: `var ff := FX = {...}`
`type FX := func(x:int) -> int;`
`func f2:FX(x:int) -> int { return x+1}`
`func f2(x:int) -> int { return x+1}`
Let's remove typed functions. Type of a function is its signature + it's name.
so we don't need to assign a type to a function because it already has all needed.
BUT when we are accepting an input of type function: 
```
type FX := func(x:int) -> int;
func f1(x:int) -> int { return x+1; }
func f2(x:int) -> int { return x+1}

func g1(f: func(x:int)->int) -> int { return f(6); }
func g2(f: func(x:int)->int) -> int { return f(4); }
```
in above code, g1 and g2, both accept f1 and f2. what can we do to make `g2` only invoked for f2 and not f1?
we can use the name instead of type.
`func g2(f: f2) -> int { return f(4); }`
so, g2 can only be called with a function named `f2`. but what if we have: `func f2(x:int)` and `func f2(x:float)`?
we can include name in the signature.
`func g2(f: func f2(x:int)->int) -> int { return f(4); }`
but this does not make sense. if g2 is supposed tyo ONLY work on f2 function, why not add its code to that function?

Y - non-int enums. general enums. not too general -> union
`type DoW := enum { SAT=0, SUN=1,... };`
`type State := enum { ACTIVE='active', DISABLED='disabled' };`

N - calculated properties for struct
can we define properties (like OOP methods but without any input). 
These are properties of the struct which are calculated based on other things.
They cannot be void and they cannot have input.
You are read-only. 
`x: int = 1;`
`age -> calculate_age($$);`
`age -> lazy calculate_age($$);`
`age -> $$.x + $$.y;`
no this makes syntax confusing. just use a normal function.
which one is more readable:
`f: float = contract1.risk_markup;`
`f: float = calculate_risk_markup(constract1);`
second one is better and more gen/orth but we need to have a caching mechanism and its better to be transparent.
this means I don't need to do anything special. just call `calculate_x` everytime you need the data. the function is responsible to cache the data.

Y - memoization of function output
solution 1: keyword :
`func f(x: int) ->int { return memoize(x+1); }`  //everything will be handled by runtime if there is a return memoize
but this is not general and orth
solution 2: give each function a hash-map as a storage.
`func f(x:int) -> int { var cache = this.cache; } `
this is too general and can be mis-used.
how/when should this cache be cleared? we should give function power to control it.
also this should be testable. it should be possible to empty the cache or manipulate it.
this cache cannot be inside an input data because maybe input is a simple int:
`func calculate_fibonacci(x: int) -> long { //a lot of calculations }`
a simple 50 integer input can cause a lot of processing. next time we want to have result of previous calculation at hand.
its good it we can either return cached value or used it! for example to simplify further calculations.
`if ( cache has result for n-1 ) n_1 = cache[n-1];`
so it's better not to be a simple in-flexible.
requirements:
1- flexible, I should be able to fetch data for other set of inputs of my function -> just call the function with that input
2- private: only I should have access to it
3- ability to clear the cache
4- testable
what if we decorate function with something like `pure` so runtime will cache output automatically?
1- just call function with whatever input you want
2- anyone has access directly and it makes sense
issue:
maybe input is complicated and caching does not make sense
maybe function is pure but very simple
`func calculate_fibonacci(x: int) -> long cached { //a lot of calculations }`
- what if I want to cache for x minutes or of size N?
x makes no sense.
we can define a LRU cache of size N.
but should this be implemented in syntax level?
there are a lot of things similar to cache which will be useful in future.
even for caching: what is size of the cache? which arguments should be part of cache key? when/how shall cache be removed?
we can simulate static variable with cloure. This will be a more general/consistent solution. 
```
func calculate_fibonacci(x: int) -> long 
{
   var cache: int[int];
   return func(x: int) -> long { return cache[x] if defined cache[x]; d_calculation and save; return result }
}
long result = calculate_fibonacci(100);
```
but outer function is supposed to return `long` not a function!
this is the corret syntax and the standard/general/consistent way to do it.
```
func create_func(a:int) -> func(x:int) -> long
{
   var cache: int[int];
   return { return a+cache[x] if defined cache[x]; d_calculation and save; return result }
}
//what we now need is a static/single/const instance of the function that create_func gives us
//problem is: in the module leve we can only have functions and types. not variables
//what is we define an alias? like type
func test1(x:int) -> long {some code}
func test2(x:int) -> long :: create_func(4);
func test2 :: create_func(4);  //full signature is optional
func fib :: create_func;
```
we have `func A :: B;` where A is an identifier and B is an expression call with constant/literal inputs.
`B` must evaluate to a function matching with `A` signature (optional). When parsing this statement, `B` will be evaluated without any context (there is no outside code to provide input to B, it should be called with literals or no input). result will be a lambda function which is assigned to name `A`.
this simulates static attributes, is private to the function, is flexible (function can clear the cache or implement any caching policy).
can we make this syntax shorter and remove extra function and the stress on calling once?
```
func fib(x:int) -> long = 
{
   var cache: int[int];
   return { return a+cache[x] if defined cache[x]; d_calculation and save; return result }
}
```
body of the `fib` function is determined by once calling the provided block which returns the actual function to be called.
So, on the first call to fib, this block is executed to BUILD the function body. any call afterwards will just call the created function. This is like: `x: int = 5;`. but instead of 5 we have a function.

N - can I write `int x :: get_data;`? No. `::` is only for functions. use `=`.

N - can I write `var x :: calculate_func`. No. `::` is not for building variables, its for module functions. You can use normal `=` operator for this.

N - review the interface concept


Y - special syntax sugar for default value. 0 for int, empty for structures, ...
`var x:int = default(int);`
You can omit type if it can be inferred.
`var x:int = default;`
`var h: hash<int,int> = default;`
`func f(h: hash<int,int> = default) {}`

N - remove optional value for arguments. if they are optional, they will be null?
if its important for caller, pass something for them. else they will be null.
because if we define default value `5`, bad things will happen if we later change it to 6.
this makes writing expressive code easier. lets keep it.

Y - can we make the syntax more elegant for functions defined with closure?
```
func fib(x:int) -> long =
{
   static var cache: int[int];
   var %cache: int[int];
   var cache: int[int] = _get_static_data("cache");
   var cache: int[int] = _query_function_storage<int[int]>("cache");
   
   return a+cache[x] if defined cache[x]; d_calculation and save; return result;
}
```
maybe we can make use of default parameters. also this makes us able to test the function by passing an empty cache.
but what if we really want a new instance on each call, as the default value?
`func fib(x:int, cache: hash<int,int> = hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
`func fib(x:int, cache: hash<int,int> := default) -> long { return a+cache[x] if defined cache[x]; }`
this only makes sense for non-primitives. No! we can also use int or float and they will keep their values.
`func fib(x:int := 7, cache: hash<int,int> := default) -> long { return a+cache[x] if defined cache[x]; }`
x will be initially 7 but with any change in the function it will preserve it's value.
but `:=` is confusing.
`func fib(x:int := 7, cache: hash<int,int> = {}) -> long { return a+cache[x] if defined cache[x]; }`
but this is not explicit.
`func fib(x:int ~ 7, cache: hash<int,int> ~ hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
`func fib(x:int =~ 7, cache: hash<int,int> =~ hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
so can we use `=~` syntax inside function too? if we use above definition, we should be.
but it will make things complicated. we should make the syntax somehow dependent on the function definition.
`func fib(x:int =~ 7, cache: hash<int,int> =~ hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
and if we allow for static variables inside function, then static default arguments will be irrelevant. lazy devs will use static local vars.
`func fib(x:int, cache: hash<int,int> =~ hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
but using default argument value for static purposes seems un-intuitive!
allowing for module local variables is bad too. makes code messy and finding root of bugs hard.
let's narrow application of this. so we won't have static variables at all. if they are evil and introduce global state and are hard to test. sugar coating static variable in a confusing syntax for default function parameter value does not solve any problem. the initial goal is to be able to cache function output. but we want to be flexible (cache n items, clear cache, ...). because of that I don't want to just add something like: `func f() -> long : cached {return 5;}`
what if we create two functions?
no.
what if a function can add something private to the input struct? no. maybe input is a single integer number.
the problem of general function output memoization is equivalent to having static variables.
general: ability to clear cache and define cache size.
maybe we can have general memoization without static.
add cached keyword with n parameter. provide a runtime function to clear that cache.
how can I test this? runtime function to disable caching.
`func fib(x:int) -> long cached(4) { return a+cache[x] if defined cache[x]; }`
`func fib(x:int) -> long cached(4) { return a+cache[x] if defined cache[x]; }`
I think current solution, using closure, is the most flexible one.
But it's making source code files confusing.
so: without closure, module-level variables and `cached` keyword -> the solution will be default parameter value.
`func fib(x:int, cache: hash<int,int> =~ hash<int,int>{}) -> long { return a+cache[x] if defined cache[x]; }`
so what about having: `var x:int =~ 11;` inside the function? can we have it?
if answer is YES, the there is no need for that in default args, if no, we don't have gen/orth.
do: module level variable rejected, closure rejected, default arg value rejected. keyword rejected.
the only solution: runtime functions:
`var cache: int[int] = _query_function_storage<int[int]>("cache");`
But this is basically same as static but more confusing.
module-level fields: this is basically global variable.
another solution: let caller worry about it. define it's own closure and create a lambda. use lambda whenever it needs to
but that won't be testable too!
lets use some method similar to module level field but limited to a function.
`func fib(x:int) -> long  |cache: map!(int,int)| { return a+cache[x] if defined cache[x]; }`
function fib assumes an outide closure which has a cache variable.
yes. this is static but function-level. so what's the difference with having `static int x` inside the function?
how can we empty the cache from outside? how can we test? how can we disable caching?
what about this?
using convention for argument name. arguments who start with underline are optional.
and if they dont have `=` to specify their default value, they will be provided by runtime as a static data storage.
`func fib(x:int=6, cache: hash<int,int>) -> long { return a+cache[x] if defined cache[x]; }`
pro: we won't have default VALUE for arguments, only optional.
pro: although it is optional but outside code can pass a value for it so its testable.
pro: consistent with current syntax.
con: we always have preferred using keywords. now why switch to a convention that no one is familiar with?
pro: this makes things simpler. instead of writing keywords everywhere, we just include/omit underscore.
pro: syntax is consistent with the rest of the language. 
pro: function definition is just input + output, no need to include lots of keywords.
but we want to completely remove `=4` from function definition. how to distinguish between optional and static?
using double underscore?
`func fib(x:int, _output: string, __cache: hash<int,int>) -> long { return a+cache[x] if defined cache[x]; }`
parameter names that start with single underscore means they are optional.
and we can use `missing` to check if a parameter has a value or no.
but for NULL/nil we have union/option type. so we don't need syntax to return undef or set a variable to undef.

Y - using dlang notation ! for templates

Y - `__` prefix for optional but runtime provided arguments is a but confusing. maybe we can change it.
`func fib(x:int, _output: string, _cache: hash<int,int>) -> long { return a+cache[x] if defined cache[x]; }`
can we implement this as a constraint? `x: int[$static]`? but then it can be used in all other places too. not a good idea.
`func fib(x:int, _output: string, _cache: hash<int,int>) -> long { return a+cache[x] if defined cache[x]; }`
there are 3 types of arguments:
1- normal
2- optional, if you don't pass a value they will be missing
3- auto-filled, if you don't pass value, runtime will provide value
so type 3 is not considered optional.
`func fib(x:int, _output: string, $cache: hash<int,int>) -> long { return a+cache[x] if defined cache[x]; }`
if argument name starts with `$`, if missing, runtime will provide value.
but questions arise: can we declare such variable inside a function? or inside a struct?
how caller can do it?
`auto f = (int x)-> long { var cache:...; cache[x] = fib(x); ... }`
then pass `f` to the other functions.
this is better and simpler. 

Y - back to the original problem: property.
we want to have methods calculate something for a struct. like `risk_markup` for Contract struct.
Now :
`func risk_markup(c: Contract)->float { //a lot of calculations; return result; }`
how can we cache above function? so clling `risk_markup(c1)` multiple times for same c1 won't have extra overhead?
let's add `cached` keyword. let runtime handle memory problems.
`func risk_markup(c: Contract)->float cached { //a lot of calculations; return result; }`

N - letting code re-define operators is not a good idea. makes code unreadable.
`y=x+5` do you really know what this does?
This is OK. Developer is responsible for that and no one can stop him choosing a bad name for a function, too.

Y - declaration, assignment
does first do the second too?
`x: MyData; func(x);` what will func receive? null or empty MyData?
initialization and assignment happens as soon as you declare a variable. so `x:int` makes x have value of default(int).
same for any other variable/struct. if you want, you can later edit the fields or assign upon declaration:
`x: MyData{a:1, b:2};`

N - when struct has no field, use another keyword like interface. No. we can have interface-like struct with fields.

N - can we re-define dot operator on a struct? No. it already has its own meaning.

N - comparison check must be clear. we should know when we are ref comparing and when data comparing.

N - what happens upon incorrect casting?
there is no casting. if struct A want to be castable to B, it needs to define a member with that name. That's all. 
and casting will be done automatically.
but we have data conversion. e.g. converting string to int. can we do these using functions and remove any special notation for casting?
There is no incorrect casting. The casting function is defined, its input and output are specified too.

N - defining no-input methods like OOP? e.g. String.Trim?
or functions that don't get any non-primitive input?
`str1.trim();`
`trim(str1);`

N - if a function's first argument is X, we can write X.function_name.
`func f(x:int, y:int) -> long {}`
`func save (x:int) to (y:file) -> long {}`
save a to ff
`func (f: file) save (x:int) -> long {}`
f1 save(p)
f1 save(t)
`func contains(l:list, x:int) -> bool {}`
`func (l:list) contains(x:int) -> bool {}`
if ( contains(list1, 10)) ...
if ( list1 contains 10 ) ...
but what if we want to compose this?
if ( not contains(list1, 10)) ...
if ( not list1 contains 10 ) ...
so although infix notation makes code more readable, but when combined with other notations, is not readable.

Y - let user only override some globally known opertors which are not limited to math.
like `[], =, ==`. because others are only used in rare cases, make code un-readable and cause confusion about precedence, ...

Y - maybe we need to cast MyDate to empty struct and cast it back. is that possible?
This only applies to empty struct. Any other struct has some field which MUST match with some field in the original data and so we can explicitly specify that field.
So let's choose a name for empty struct! but we can have lots of empty structs: Object, Comparable, ...
Each acts as a marker. in implementation we will need to explicitly save visible and actual type of each variable.
so anyway: we will need to cast `DateTime` or `Stack` or `int` or `File` to an empty struct. 
casting TO empty struct would be str8fwd. `var s = EmptyStruct(myFile);`
But this is not casting! what would be input of that function which casts EVERYTHING to Object? what would be it's body?
We can say, to cast TO object, just write assignment: `var o: Object = MyStack;`
but what about the other way? `var s: Stack = myObject`? No. Just write `var s: Stack = Stack(myObject);`
runtime will do it. 
`var o: Object = Object(myStack);`
`var s: Stack = Stack(myObject);`
both are ok and runtime will handle conversion as long as type matches or target type has no field.
if none of these two are satisfied, you have to have an appropriate function.

Y - it doesn't feel right to use `struct` for a type that does not have fields.
lets use protocol, interface, contract.

Y - make interface/contract/protocols separate and use separate keyword and when defining struct act like Haskell: `deriving Eq` so instances of this struct can be compared for equality.
structs that have no field are representing interface.    
we use interface, but for implementation act like Go. define appropriate members and that's all.

Y - How exactly are we going to implement polymorphism? Is it really needed? Isn't it too OOP-based?
To what types can MyStruct be casted? To all interfaces. and everything that it composes.

Y - What should be syntax for template based function? Do we need to specify type arguments?
`func adder(T a, T b) -> T { return a+b; }` //how do we know if T is a struct or a typename?
`func adder!T(T a, T b) -> T { return a+b; }`
`func adder!(T,S)(T a, S b) -> T { return a+b; }`
`var t = adder(10,15);`
`var t = adder!(int,int)(10,15);`
`type tuple!(S,T) := struct { a: S; b:T; };`
`var t: tuple!(int, string);`

N - QUOTE:"since I don't really believe in EVER passing collections around outside the protection of a containing class, I'm not completely convinced that the benefit of generics outweighs the enormous cost imposed by its huge syntax addition.
I'm not talking about just wrapping any collection in an arbitrary class with a bunch of setters and getters, I'm talking about including all the additional data and business logic needed to manipulate that collection's data.
After that, I rarely need more than one or two casts, and to replace those two casts with the mess that is generics just doesn't seem to add up (at least with the way I code)"
Macro as an alternative to templates?
remove templates and use primitive typrs: array, hash, list to handle that.
maybe we can even have array behave as a list too.
`var x: int[] = {1,2,3}; x.push(5);`
in that case we will need a good interface mechanism so we can write functions which act on interfaces.

Y - generics & polymorphism: implementing stack as arraylist, implementing expression evaluator.
```
type ArrayList := int[];
type Stack := struct { _storage: ArrayList; };
func push(s:Stack, x:int) { s.append(x); }
func pop(s:Stack) -> int { return s.get(); }
func length(s:Stack) -> int { return length(s._storage); }

type Collection := struct;
func length(c: Collection) -> int;

func main() -> int {
  var c: Collection = Stack{};  //from data point of view this is ok because you can cast it
  var x = length(c);  //there is a length function defined for collection type so its ok. at runtime, length for actual type of c will be called.
}
```

Y - cant we simulate lazy evaluation with lambda?
`x: int = lazy y+1;`
`x: func () -> int = { return y+1;}`
we can also simulate with a type + custom get function:
`type lazy_int := func()->int;`
`func get_value(x:lazy_int) -> { return x(); }`
`x: lazy_int = {return y+1;}`
`int r = x;  //x is evaluated and function is called`
`var t: lazy_int; t = x; //this does not call evaluate because types match`
so we only need an `evaluate` or cast or calculate custom function. 
we can call it casting.
Is it transparent? If a function expects an int, can we send a `lazy_int` instead?
one way is to handle it in runtime, and let user send function/lambda which returns int, instead of int. 
other way: add operator for get_value or a getter for int of lazy_int, where lazy_int is a struct containing int + lambda.
first solution is cleaner. we treat any function `func () -> T` same as T except it is lazy.
so when you have `func adder(x:int, y:int) -> int` maybe x or y are functions. In the code everything is the same.
In runtime, when variable is just being transferred, it doesn't change. but when it's value is read, function is executed.
whet if we have `x: int = lazy_Var;`  -> this is reference assignment
or `t: int = lazy_var{};` to clone lazy_var. 
both are transferring, to the outside world, both are int variables. inside they carry a lambda.
as soon as we have: `t = lazy_var+1` then we HAVE to run the function.
cloning just clones the lazy variable with it's function pointer. no evaluation is needed.

Y - can we define cached lambda? yes it should be possible.

N - what are things that make learning language or reading a codebase or changing the code hard?
I'm trying to do another round of making language simpler. Simple to learn or read or maintain.
User should not be forced to look at 10 different places to know what does function X do.
1. cached - I hope there was a more straightforward solution for it.
2. exceptions
3. Optionals. starting with `_` may be confusing.
4. Not having real encapsulation. So if I change something, I may need to update 100s of places.
5. Making changes in a codebase, should not need large amount of mental effort or widespread change.
6. Caller has to have full control over what happens. So if callee can make any change outside of return value, it will make things hard to change later.
7. annotations
-> try to eliminate as much as possible of these.

Y - if we ban functions change value of their inputs, then pass by ref or val does not matter.
function can simply return multiple values instead of changing a field in an input argument.
but we can have: `x: MyStruct = input_arg; x.field1++`
and it still changes function input.
if we send all by copy it would be ok (and useless) to change values but it is also expensive.

N - It's better if name of the cast function is not same as struct. So we can have template base casts.
`type Stack!T = ...`
how are we going to write a function which casts `int` to `X!T`? We cannot write a function with generic name.
`func Stack!T...`
but: `func cast!Stack!T(a: int)...` would be ok.
Another example: We define a generic array list and want to be able to cast array to it.
`type AList!T := ... + functions`
`func AList!T(a:T[]) -> AList!T {}`
`x: Alist!int = ...; t = AList!int(int_array);`
this is fine I think.

Y - can we replace exceptions with union?
how to handle exception in lazy block, or in lambda?
lazy is removed.
maybe we can also add a shortcut like perl's OR.
and an easier syntax to indicate function will return a union. MyStruct or Error
can we do exceptions with monad?
because even Go has this but they say, please use it in really specific cases.
monad needs developer to write lots of code.
`x = get_network_page(1,3) // 5;`
`exp // exp` means evaluate left side expression. if any exception happened, evaluete next one.
you can combine them:
`x = get_data(1,5) // 9;`
but `//` is for comments. let's use another operator. For now `#`
you can chain them:
`x = func1(1,2) # func2(1,9) # 10;`
if there is no `#` and we have an exception, `defer(exc)` will be executed.
can we eliminate `defer(exc)`? 
what if I want to return something:
`count = get_count(x) # return 5;`
`count = get_data(x) # t++;` -> if there is exception it will be `count = t++;`
`get_data(x) # t++;`
problem with exception: they add hidden control flow, they are complex, 
how can we catch exception for a block?
```
{ func1; func2; func3 } # exc_handler;
```
we can define synthetic-block to handle exception for a block. and remove `defer(exc)`
defer is mostly used for resource release. 
you cannot apply `#` to the whole body of a function.
how can we access details of the exception? maybe some runtime method. `core.get_error`
and: `core_set_error('no file'); return;`
by entering `#` section, the error is automatically cleared. 
`#` kicks in if some error exists in runtime error storage. we can assume `$0` inside `#` means the error but this conflicts with function input. we can use `$$`. 
so if we have access to the exception details, then we can eliminate `defer(exc)` notation.
we can use keywords instead of `#` and `$$`. 
`except/guard/trap` and `error`.
what about normal `defer`? it's used to close file, release memory, unlock mutex, close a socket.
we can define that code when declaring a variable.
`var x: Socket = get_socket(1,2,3) guard;` adding guard keyword means when going out of scope of this function, call `dispose` function on the variable.
it's not a good candidate for constraint.
`var x: Socket; x = get_socket(1,23); x.connect...`
where/how should we put guard keyword?
We don't need defer. Each type which is not part of return value, will have `dispose(x)` called on it.
so for file, we can write `dispose` function which just closes the file. and this is called even in case of an exception.
so we just need to eliminate `defer(x)`.
in adder: `func adder(x,y:int)->{ assert condition1;}`
caller: `var x = adder(5,6) # adder(1,0) # { log("error occured " + $$); exit(5); };`

Y - what if function has optional input and reads them without checking?'
`func f(x:int, _y: int) { if ( missing _y ) ... }`
we can implement this with fn redirection.
`func f(x: int, y: int) ...`
`func f(x: int) -> f(x, 10);`

Y - can we eliminate data annotations?
usage: json customization
e.g. we have a Customer struct, when saving it to JSON format, we want to ignore some fields.
but a general method for JSON needs reflection: `func to_json(x:Object)`
so, we will need to write a custom function.

N - function cannot change it's input. can we have a syntax for this?
e.g. `int x = 12; f(&x);`
`func f(x:int&)...` where in& denoted frozen int.
Let's do this behind the scene. There is no other good usage for this. Just makes syntax clumsy.

Y - problem with auto dispose call. maybe code s not readable
but this is C++ way (RAII).
what about mutex? same. 

N - try to remove/eliminate as much special syntax as possible
template
catch and error
ok constraints
ok input indicator `$_` and `$i`
ok chaining
ok union check for empty value

N - like Haskel, can we separate function definition and type?
`func adder(int,int)->int;`   //everything about types
`func adder(x,y) { return 5; }`  //everything about names and body
`type adder := func(int,int)->int;`
`adder(x,y) = { return x+y; }`
`adder(x) = adder(x, 6);`
`type adder := int -> int -> int;`
`type comparer := int -> int -> (int -> int -> bool) -> int;`
using `->` for both input and output makes syntax clearer. 
instead of `func(int,int)->bool` we have `int->int->bool`. maybe we can even drop func keyword.
`->` somehow implies order. You have to provide a before b, if we have `a->b`.
`type adder := int,int,int;` but this doesn't imply the transformation nature of function.
`type adder := int -> int -> int;`
`type gen_adder!T := T -> T -> T;`
func adder(x,y).
what is the advantage of separating these? it's possible to have a type same as a function but function definition should be easily done in one line. makes dev confused.
`func adder(x:int,y:int)->int { return x+y; }`
`func adder(x:int -> y:int -> int) { return x+y; }`  //keeping output inside paren seems incorrect
`func adder(x:int -> y:int) -> int { return x+y; }`  //keeping output outside, makes syntax similar to what we had before
`type adder := int -> int -> int;`
`func adder(x:int -> y:int) -> int { return x+y; }` 
what is use of separating singature from body, if it's going to be used only once? (most of the time)
`func adder x:int -> y:int -> int { return x+y; }` 
no.

N - if above happens (separate func signature and def), lets remove type keyword.
`MyInt :: int[$>0];`
`Customer :: struct {}`
No. There should be a keyword to highlight.

Y - we have `$1, $2,..` for arguments but `$0` is free. can we use it to reduce complexity of the language?
candidates: Error, 

N - do we need templates? yes.
what happens if we ignore all templates and just use `Object` everywhere?
possible problems:
monad: `func (=>)(x:Maybe!int, f: func(int)->int)`
operator overloading
map/filter definition
list processing
collections like stack/queue/...
algorithms
I think we need them. In FP we care much more about data and it's structure. so we need to have appropriate faciilities too.

Y - what about deeper hierarchy? If Customer has Person field and Person has Picture field, can we call picture-related functions on a customer? It's only one level.

Y - shall we prohibit re-writing already implemented methods for parent types?
suppoer we have Persona with `dump` method. Customer contains Person. calling `dump(customer1)` will call it on Person.
but we may need to have a more specific dump for a customer. Solution is to use interface. Include appropriate interface and write your methods for customer.

Y - polymorphism should be like Go. child can hide methods written for parent.

N - do we need catch and error? maybe we can add a more consistent error handling.
`var x = adder(5,6) # adder(1,0) # { log("error occured " + $0); exit(5); };`

Y - including constraint in function definition makes code clumsy. Can we make it better?
pro: constraint is where it matters.
con: hardly ever we have a constraint which is only used once. so better to define a type for it.

N - we can implement code of `=>` operator to have monad.
so if function accepts `int` and we have `maybe!int` we can call it transparently.
but what if argument is not alone?
`maybe5 => adder(5, $_)` this is ok and works.
`(5, maybe4) => adder` what about this?
our `=>` implementation is something like this: `func (=>)(x: Maybe!int, f: func(int) -> U) -> U`
so?
we can write it like this:
`maybe4 => (5,$_) => adder;` but we will loose f function then.
shall we add a new operator? or make it less transparent by forcing user to call a method?
even if we force user to write a method for this, its signature will be the same.
`func bind(x: Maybe!int, f: func(int) -> U) -> U`

Y - Why do we need a special `_init` method in a module?
`import core.st.Socket;`
`import core::st::Socket;`

Y - now that dot is solely to be used for struct, lets change package addressing. changed to `::`

N - Let's let functions decide which parameters to receive by ref and which by value.
notation to specify input type is reference.
notation to send reference of something to a function. maybe we can ignore this. but better to have it so its explicit.
`func adder(x:int, y:int) -> int { return x+y;} a=adder(b,c);`
`func adder(x:int&, y:int&) -> int { return x+y;} a=adder(&b,&c);`
then we can define `&` variables which are references to other variables.
`var x: int&; x = &u;x++` will update value of u.
`var x: MyStruct& = MyStruct{a:11};`
`var x: MyStruct = MyStruct{a:11};`
then what about a function pointer?
`func adder(x:int, y:int, converter: func(int)->int ) -> int { return converter(x)+converter(y);} a=adder(b,c);`
this I think, is added complexity, new notations, making function signature more confusing. 
Let's have the rule of pass by reference + cannot change arg values.

N - when debugging, we may want to call a function without import. like use data::dumoer

Y - if its possible to call function directly using namespace, what happens to polymorphism?
maybe we really don't need polymorphism.
maybe function pointers are the solution for problems like expression evaluation.
each node of the tree will contains a fp for processing.
expression evaluation is basically strategy design pattern.
hence we may not need the dynamic interface behavior we had. just some static interfaces.
but when we write `type x := struct {...interface X;}` doesn't it somehow mix data and code?
so how can we print value for a given data?
suppose we have `x:Object` input, now `print(x)`. what does this do?
if type of X is Customer, if there is print for Customer, it will be called, else it's external type will be used.
each variable has two types: external/static type which is specified in the code
and internal/runtime type which is provided at runtime
Of course if struct A contains B and there are functions for B, we can call them via `myObjectA.Bfield` but this is explicit method dispatch.
having polymorphism even with interfaces, will bring up problem of method dispatch.
if we have interface Comparable and structs Int and Decimal.
`f(x: Comparable)`
`f(x: Decimal)`
`f(x: Int)`
when we call f with a variable of type Comparable, at runtime it can be redirected to any of these.
Haskell and Clojure both ban function overloading because of the way they handle method dispatch.
if we support it, we will have multi-dispatch and not two-dispatch.
`f(x:Comparable, y: Square)`
`f(x:Decimal, y: Shape)`
if we call f with a decimal and square, which of the above methods should be called? we had this issue before.
so, each variable of type T can either represent a data of type T or I1 or I2 or ...
where Ii is an interface where type T satisfies.
all types can inherit from one or more interfaces.
but if we do this at the time of defining data, it is mixing functionality with data. 
Let's do it implicitly. for interface, we can explicitly extend another interface.
but for other types, just define appropriate methods. 
`type I := interface; func f(x:I)`
`type A := struct; func f(x:A)` so A implements interface I.
if we cann f function with a variable of type I, at runtime f(A) will be called if actual type is A and we have appropriate function. else general f will be called.
I think the definition of an interface should be bound. We cannot let everyone define anything anywhere and add it to interface. This makes large codebase maintenance confusing.
```
type Comparable := interface {
  func do_compare(????
```
can't we just remove interface?
then how can we do these?
- Sorting a mixed set of objects
- Adaptive collision algorithms
- Painting algorithms
- Personnel management systems
- Event handling
maybe we can do this through template specialization.
we can have:
`func add!T(a:T, b:T) -> {}`
then:
`func add!int(a:int, b:int) -> { return a+b;}`
as a result, add is a simple single-method interface that has an implementation for integer.
then, if we call `add(x,y)` and x,y are int, then add!int will be called. else add!T will be called.
- sorting a mixed set of objects.
`func compare!T(a:T, b:T)...` if you want, implement compare for your type. 
but we cannot have mixed objects. either `List!T` or `T[]`.
- adaptive collission: we can have sphere, asteroid, shuttle and enemy. to check collission:
`func collides!(T,U)(originator:T, target:U)`
how can we keep a single list for all elements of the game? all spheres, shuttles, ...?
we can define `Obj` as something like `void*`.
or to make it more specialized, we can define a dummy/market type. and tag all of our types with that type.
and then `Dummy[]` array can contain any type which is tagged with Dummy.
- Painting algorithm: func paint!T, func paint!Circle, ...
now problem is a way to treat all subtypes same. so we can have an array/list/collection of shapes. each element of which can be square, circle, ... .
we can define parent type and have types inherit from parent. but again we will have dispatch ambiguity problem.
`func check!(Circle, Shape)`
`func check!(Shape, Circle)`
then check(Circle, Circle)?
can't we have simple inheritance in structs?
`type Object := struct;`
`type Circle := struct : Object {}`
`type Square := struct : Object {}`
`func paint!T(o:T) {}`
`func paint!Object(o:Object){}`
`func paint!Circle...`
`func paint!Square...`
`Object[] o = {Circle{}, Square{}};`
this gives us same result as interface, but does not add a new keyword and it's own complexity. but builds upon existing tools.
and is simpler and less confusing.
so we have two separate concepts: template specialization, struct inheritance

Y - we should ban calling functions directly using module name prefix.

Y - Simplify template method specialization.
`func compare!T(a:T, b:T) -> bool ...`
`func compare!int -> a>b;`
`func compare!int -> $1>$2;`

Y - if parent has a constraint and child has too. when value of child changes, validation logic for all of them should be called.

Y - same as cast and constraint, we can define casting logic using template.

Y - Let user define custom type checkers to be used in constraints.
What about having them implicitly defined, just like disposable?
`func validate!T(old: T, new:T) -> void`
implement this for types that you want to be checked. No need to make code dirty writing code inside`[]` and using `$`.
`type MyInt := int;`
`func validate!MyInt(old: MyInt, new: MyInt) -> { assert new > 12;}`
pro: use can do other things like logging too, can re-use existing code, more flexible, we are using existing tools, code will be much cleaner `x:myint` instead of `x:int[$>1 and $<12 and $ != 8]`
con: it can be confusing to find validation logic, needs much coding
If we force dev to mark validatable type, it is bad because DRY!
I can define month type using this: `type DateTime := struct { month: int [$<12]; }`
but with validate: `type DateTime := struct { month: mmonth; } type mmonth := int; func validate!mmonth -> assert $1>12;`
we can simplify above with ability to define type inside field definition:
`type DateTime := struct { month: mmonth := int; } func validate!mmonth -> assert $1>12;`
but this is confusing. can we use mmonth outside? where? are there limits? apparently mmonth type is defined INSIDE a struct, so shouldn't be accessible outside it but its not consistent.
Let's not send previous value because it makes runtime system much more complex.
you can easily implement validation for the whole struct which eliminates need to define a new type.
`type DateTime := struct { month: mmonth; } func validate!DateTime -> assert $1.month>12;`
what happens to `const`?
do we really need it? now that functions cannot modify their input, almost everything is const.
the only possible modification is withing the owner of the data, which should be ok.
we can easily extend `validate` method to other types too: `pre_validate` and `validate`.
but this is not necessary. 

Y - A mechanism to limit template argument.
`paint!T` is not correct. we want to be a child of `Shape`.
`paint!(T: Shape)(obj:T)`
we can use same constraint that we have for function inputs.

Y - for inheritance its better to have `+` -> extends
`type Circle := Shape + struct { ... }`
rather than: `type Circle := struct: Shape { ... }`
its more readable.
but this is not addition. maybe target type does not have any field. we are also appending the type.
`type Circle := struct { ... } extends Shape, Obj1, Obj2;`

Y - multiple inheritance. what if `Circle` is inheriting from `Shape` and `Oval` and we have `f` method for all of them
and we call `f` for a circle object?
if there is f(Circle) then definitely it will be called.
but what if there is no such method?
`type Circle := struct extends Oval, Shape;`
`func paint!Oval`
`func paint!Shape`
`var c: Circle = Circle{...};`
what should happen when we write `paint(c)`?
- we can explicitly call appropriate method by casting: `paint(cast!Oval(c));` or `paint(cast!Shape(c))`
- what if runtime/compiler needs to infer which one to call? It cannot. 
obviously there should be a runtime error, if this call is made.

N - easier notation to define func with nullable return.
`func find_customer(x:id) -> Maybe!Customer `

N - extend the `validate` notation. 
- a code to be called when value of the data element is changed (per type/per instance)
- like AOP: a piece of code to be called before/after change in a variable or all variables of a specific type.
`var x: MyData; on_change x, { assert $1>1; };`
`var x: MyData; x.change_handler { assert $1>1; };`

Y - ability to have events, publish, broadcast, subscribe in the code.
its best if we can do this using already available tools.
we can easily do this via a struct which contains data + list!handler.
the only thing is to prevent outside from changing value of the data. they have to call a special function to do the update.
OR: we can have `validate` method for the data so that each time it's value is updated, in the validate, we call all subcribers.
but then, validate will not be a good name. we should rename it. also we want to be called AFTER value is updated.
but validate wants to be called BEFORE value is updated. so we need to mechanisms:
`before_update` and `after_update`
or `updating!T`, `updated!T`.
can we simplify this? maybe use `before_update` only and return calls to be made after update.
or: wrap around the whole update process. so: `update!T` is responsible to update T, type. 
it can ignore the update, validate and throw exception, update and call something, update to some other value, ...
but how can this be implemented for complex data types?
`update!Customer(new_value: Customer)`? 
what is signature of the function? I/O?
how should the function update the actual variable?
how should it ignore update?
changing the update process is dangerous because it is adding hidden side effects.
Let's not do it. when there is `x=10` in the code, either x should be come 10 or some exception should be thrown.
this can be applied both on simeple and complex data types. so it's not possible to have both prev and new values.
either we have: `after_update` and a reference to the variable.
or `before_update` and ? we cannot have two values.
so the only possible time to call is after update is being done. we call this method to validate and verify and broadcast things and ... .
`after_update!T`
`on_update!T`
function name should be a verb if they are changing internal state or noun if they are returning something.
`validate!int`
`updated!int`
what about vairables? define custom type form them.
this is same as dispose. we make things implicit by using a convention and defining appropriate functions.
but problem is, what to do with corrupt value? either throw exception or exit.
but if exception is caught? then we have a var with corrup data. but that should be fine because code has set that value and code has caught the exception.
how can we inform a set of subscribers that some value is changed? use already available tools.

N - type matching for union to be used if type is unique.
`if (mm.Data?) ...`
`match(myVar: int = mm) ...`

Y - as function cannot change it's arguments, `[]` and `=` operators cannot be implemented easily.

Y - it's painful to define new types each time I want to have validation/observation.
dispose is something which is common for all variables of the same type.
but validation logic may just match to some integers and not all of them.
alternatives:
- inline code: what we had before `x: int[$>0]`
- property/setter: `x: int [aset]`
- code-base: `setter(x, { assert $1 > 0; })`
code-base can be used for variables too but thats not a big plus.
it's better to have observer logic as near to type definition as possible but at the same time, not pullote the type definition.
`m: int [validate_month]`
`func validate_month(month: value) -> bool {}`
pro: you can use `int` type for month.
con: you have to mention function name.
what if we use convention here?
`type x := struct { month: int };`
`func validate_x_month(x: month) {}`
`func validate_x(x: month) {}`
can we have template specialization with part of a type and not a type?
`func validate!T(x:T) {}`
`func validate!x.month(x: int) {}`
no this is so confusing.
but `validate_x_month` name is too casual and ambiguous.
`m: int [validate_month]`
`type x := struct { month: int [validate_month] } [validate_data_func];`
basically this is what we had before, but clearer as there is not need to write inline code.
and we can force to have this only in type definition and not function/local variable definition.
so when defining `type A :=` in the right side you can use `[A]` notation for the whole type or it's parts to define a function to be called after the value of variables of that type are changed.
can we write `$_` in this part? `month: int [validate_month($_,1,2)]`. No. it makes everything more consuding.
can we extend this notation to before/after?
can we extend it to getter/setter?
`m: int -[validate_month_before] +[validate_month_after]`
can we just eliminate all these special case notations and use already available tools?
define a struct, mark the field private, so outside code should not modify it (if they do, there will be warning).
then in your local module, handle the update and call appropriate methdos to validate/broadcast/... .
con: the user code must call function to change the data. but we want to have first-class data. we don't want to put function in front of the data in a mandatory and enforcing way. it owner of the type wants some special case handling of data, this should be transparent from outside world. 
so outside just writes: `var d : DateTime; d.month=11;` and behind the scene, the validation should be called.
summary of findings:
- we don't want to add validation per-type. because it is paintful to define new type for each new validation logic.
- it's better to have logic definition as near to type definition as possible.
- it's better not to add any new notation or syntax or keyword.
- it's preferred if we can have this everywhere (for local variables, function input, ...)
current option: `m: int [validate_month]` mentioning function name to be called after any change.
option 2: define inline new type: `m: month := int` and have `func updated!month`
option 2 con: there will at some point be a clash of type names. and they are hidden in other types definition.

N - in perl we can assign a string to an object of type DateTime and it will automatically handle conversion.
here we have `cast` method. It's good enough.

Y - we can have built-in lists using same notation as array.
every array can be extended by calling `push`. 
if you want to define a list from beginning, dont specify size.
if you specify a size, it will be a mixed list.
`var x: int[3]`  //hybrid list
`var x: int[]`  //pure list
`var x: int[3] = {1,2,3}` //hybrid
`var x: int[] = {1,2,3}` //pure
`add_element(x, 10);`

Y - property-like members in struct
`type x := struct DateTime { d:day; s: String -> { d + y + m }; };`
`type x := struct DateTime { d:day; s: String -> { d + y + m }; };`

N - Treat `if` as a function which accepts a range and a lambda
same for `for`.
`if ( x>0 ) { ... } `
no. this makes language more complicated.

N - now that function cannot modify input, how can we implement stack push or pop? (maybe we can return a lambda which is supposed to to the modification, and caller has to invoke it)?
solution1: let developer decide whether some variable will be immutable or mutable. so if type is mutable, function can modify the input.
immutability will make testing harder. but makes developer's life easier. Because he doesn't need to write lots of code and use shortcuts to do some ordinary task. if we have mutability, caching decision will become harder and more complicated.
`var y = x{item1=10, item2=x.item2+10, ...}`
how am I going to add something to a list?
`ls = ls.add(x);`
`var ls: list!Customer`

N - TEST: think about how to implement a pricing engine/vol-surface/economic events and contract object in new approach.
economic_events:
```
//assuming we have primitives
type DateTime := struct {
  year: int[$>1900];
  month: int [0<$<13];
  day: int [0<$<31];
  hour: int [0=<$<24];
  minute: int [0=<$<60];
};

type Currency := enum { USD, EUR, JPY, GBP };

type Event := struct 
{ 
  source: string;
  release_date: DateTime;
  title: string;
  currency: Currency;
  impact: int [$>0 and $<5];
};

type Maybe!T := union {
  data: T;
  None;
};

type Node!T := struct {
  data: T;
  next: Maybe!Node!T;
};

type List!T := struct {
  head: Maybe!Node!T;
};

type PositiveInt := int [$>0];

func get_data!T(list: List!T, index: PositiveInt) -> T {
  var temp = list.head;
  temp = temp.next for(index) # log("index out of bounds!");
  return temp;
}

type MEL := Maybe!List!Event;

func get_events_for_period(allEvents: List!Event, start: Date, end: Date) -> List<Event> 
{
   var ff = func(d1: Date) -> bool { return d1.epoch >= start.epoch and d1.epoch <= end.epoch };
   return allEvents => filter ff, $_;
   
   //OR
   
   return allEvents => filter {$1.epoch >= start.epoch and $1.epoch <= end.epoch}, $_;
}

type probability: float [validate_prob];
var prob: probability = 0;

type Contract := struct {
  dateStart: DateTime;
  dateExpiry: DateTime;
  datePricing: DateTime;
  underlying: Symbol;
  payout: int;
  currency: Symbol;
  type: ContractType;
};

func calc_markup_std(c: Contract) -> float {};
func calc_markup_new(c: Contract) -> float {};

func select_markup_impl(c: Contract) -> func(c:Contract)->float 
{
  if ( c.type == ContractType.CALL ) return calc_markup_std;
  return calc_markup_new;
}

func get_probability(c: Contract, _e: EngineConfig) -> float 
{
  var markup_calculator: func(c: Contract)->float;
  markup_calculator = select_markup_impl(c);
  
  
  
  var risk_markup: float = markup_calculator(c);
}

```

Y - some more thinking about template syntax for fn definition and call and specialization, and how it is used to implement dynamic method dispatch at runtime and inheritance and polymorphism.
when defining a template function, type variable is mandatory for the original function.
for every other specialization, its not needed.
here paint function is based on the shape type it is working on. not the color.
`func paint!(T:Shape)(o: T, c: Color)...`
`func paint(o: T, c: Color)`
`func paint(o: Circle, c: Color)`
`func paint(o: Square, c: Color)`
paint can only be called with polymorphic input of type Shape. Meaning instead of a Shape we can pass any data type inheriting from shape.
this is wrong becasuse original paint function has only one template arg. 
`func paint(o: Square, c: SolidColor)`
`type Shape := struct { name: string; }`
`type Circle := struct extends Shape;`
`type Square := struct extends Shape;`
`type Color := struct {};`
`type SolidColor := struct extends Color;`
if original definition of paint, says `func paint!(T:Shape)(o: T, c: Color)`
if we call paint with a Circle and there is no `func paint(o: Circle, c: Color)` then above function will be called.
now assume we have:
`func paint(o: Square, c: Color)`
`func paint(o: Square, c: SolidColor)`
then it is considered invalid and there will be a compiler error. why? because `paint` function has a single polymorphic input which is named `T` as the first argument.
if we have:
`func paint(t: Shape, c: SolidColr)`
`func paint(c: Circle, l: Color)`
then what does calling paint with a circle and solidcolor mean? There is ambiguity and that's why we need to base the dispatch on the template argument: T. So according to this definition, first paint function is invalid because we cannot have two paint functions with same input type for their first argument. 
so `func paint(T:Shape)(t: T, c: Color)` means you can define as many `paint` functions as you want with different sub-types of Shape, but they all must have `c: Color` as their second input argument.
you cannot overload based on color or it's sub-types. 
if you want, you have to modify paint function:
`func paint(T: Shape, C: Color) (t: T, c: C) -> ...`
then you can define:
`func paint(t: Circle, c: Color)...`
`func paint(t: Shape, c: SolidColor)...`
then calling paint with a circle and a solid-color. what happens? we will still have the same problem. Although this time it is more explicitly stated. Developer has explicitly specified that paint should be dispatched based on shapre/color combination.
anyway `paint(myShape, myColor)` or `paint(myCirlc,e mySolidColor)` happens.
If we have `paint(m: Shape, c: Color)` or `paint(m: Circle, e: SolidColor)` then everything is fine.
we need to specify rules of dispatch. 
rule 1 - dispatch is based on runtime type of inputs. so if function to be called has n inputs (i1,...,in) with runtime types (t11,...,tmn) and there are m candidate functions with the same name and input count (f1,...,fm).
we have to decide which of `fi` functions to call.
call is made with n variables `v1,...,vn` so if function name is `myFunction`, we have:
`myFunction(t1,...,tn)` where `ti` is runtime type of `ith` parameter.
and we have:
`f1(t11,t12,...,t1n)`
`f2(t21,t22,...,t2n)`
`...`
`fm(tm1,tm2,...,tmn)`
which `fi` should be called? 
1. single match: if we have only one candidate function (based on name/number of inputs), then there is a match.
2. dynamic match: if we have a function with all types matching runtime type of variables, there is a mtch. Note that in this case, primitive types have same static and dynamic type.
3. static match: we reserve the worst case for call which is determined at compile time: the function that matches static types. 
Note that this binding is for an explicit function call. when we assign a variable to a value and value is a function, the actual function to be used, is determined at compile time according to static type. so `var x = paint` where type of x is `func(Circle, Color)` will find a paint function body with matching input. you cannot have x of type `func(Shape, Color)` and assign a value to it and expect it to do dynamic dispatch when called at runtime. there is a work-around which involves assigning a lambda to the variable which calls the function by name and passes inputs. in that case, invocation will include a dynamic dispatch.
in C++ with same settings as shape, color, solidcolor, circle, calling with null, null gives:
`call of overloaded 'paint(NULL, NULL)' is ambiguous`
in C++ dispatch is based on the static type. so when you call a function with a variable of type `Shape` but holding a `Circle` it is calling `paint(Shape)` not `paint(Circle)`. I think it only uses runtime type for dispatching when polymorphic class is involved.
our requirement is definitely multiple dispatch.
so based on above resolution rules, do we still need to use templates and specialization?
remember applications of polymorphism: shape collission, expression parsing, sorting objects, painting shapes.
if we eliminate need for template, still developer can play with template + polymorphism.
if we eliminate template, how will resolution work? based on all inputs? yes. it can be based on all inputs.
if we use template for dispatch, then non-template parameters will be dispatched according to their static type.
but forcing developer to use templates for polymorphism makes code more complex. what if we just use all parameters for dispatching according to above rules?
What if type `Circle` has more than one parent? e.g. `Shape` and `Oval`.
`type Shape := struct;`
`type Oval := struct;`
`type Circle := struct extends Shape, Oval;`
The problems that we try to solve (sort, collission, parsing, paint) all need single inheritance. calculate intersection needs multiple dispatch.
but we also have interfaces in the same way we define struct. we should be able to inherit from any number of interfaces. so if we want to enforce single inheritance, we need to add a separate keyword for interface and implementing them. or make it transparent. anyway, I think this is against gen and orth to force developer to inherit from only one struct. he should be able to inherit a struct from any number of structs and so on. so (theoretically) for each struct we have a tree hierarchy (or maybe a graph).

Y - remove properties. let language be as consistent as possible.

N - Now that polymorphism is more specified, do we need template methods?
yes.
`void push(int[] stack, int data)`
`void push(float[] stak, float data)`...

N - can we add `reference` type so functions can modify inputs if they are of reference type?
`func add(x: int&, y: int&) -> { x = x+y; y++; }`
`add(&i,&j);`
pro: by default function input is immutable. so developer will use that default unless there is a real need.
like implementing a push to stack.
con: this makes language more complex and GC/runtime more complex.
how can we assign these?
`var x: int& = &y;`?
`var x: int& = 10;`?
isn't it possible without using this new type?
`func add(x: int, y:int) -> struct{x: int, y:int} { return {x: x+y, y:y++}; }`
yes that's possible.

N - can we use a different notation to define struct/union/enum? using anon-struct in function definition makes code un-readable.
`type x := struct [a: int, b: int, c:int];` then what happens to validation function name?

N - Use C notation for function input:
`func adder(int x, int y) -> int { return x+y;}`
this is more like C, C# and Java.
and for variable definition:
`int x = 12;`
`auto x = dsadsaD();`
I think having explicit `var` keyword is better.

Y - lets remove `=>` customization.
the notation of customization of `=>` for different types is not simple. what if I have a call to `f` with `Option<int>` which doesn't use `=>`? There should be a unified mechanism not one which relies only on `=>`.
`func (=>)(x: Maybe!int, f: func(int) -> U) -> U
{
  if (x.Null?) return default(U);
  return f(x.value);
}`
invoke is used when function is called. no matter we use `=>` or normal call.
`func invoke(x: Maybe!int, string s, f: func(int, string) -> U) -> U
{
  if (x.Null?) return default(U);
  return f(x.value, s);
}`
`func invoke/bind(x: Maybe!int, string s, f: func(int, string) -> U) -> U
{
  if (x.Null?) return default(U);
  return f(x.value, s);
}`
what is application of monad? why do we need to provide it in a transparent manner?
if there is a call to `f` which accepts int, transparent monad will convert a call to it with `maybe!int` with a null if input is empty or cast appropriately.
examples of monads: logging monad, pre-condition, post-condition, ...
we need a piece of code to be executed whenever a function is invoked.
we should be able to filter by: function input, output, name, 
actually this piece of code will be responsible to make the call and return the value. so it has authority to discard the call if it needs to.
one good candidate is convention. but what if we want to have it for all functions with any name which have `int` input?
`func adder`
`func invoke_adder` 
`x = adder(1,2)` this will call `invoke_adder`.
`func invoke(f: func(int)->U, maybe!int m)` this will be called when a function is called which has single input of type `int` and any output.
`func _invoke(f: func(T)->U) -> U ...` this will be called when any of the functions in current module is called.
applications we are looking for: logging, validation, conversion of maybe!int,
all must be transparent, but this also means less readable code which is not good.
what if dev is required to explicitly call these? then it will be a normal function and no support in runtime/syntax is needed. because if there comes a problem or bug, we need to scan the whole files to find those `invoke*` methods. that's why constraints also must be explicitly stated in type definition.
so we don't need this in syntax level. 

N - plan: bootstrap in a C compiler, then for next versions, write the compiler in Electron language itself.
We have to determine what should be included in the boostratepped version.
Easier: write the whole compiler in C. Should prepare a complete list of features, their importance and assign them to compiler versions.
decisions that have to be made: 
VM or native code or transcompiler? 
LLVM/libJit/None? if VM, bytecode format? 
as this is a hobby project, why not start from scratch?
currently, I will generate assembly (or pseudo-assembly) code which will be compiled to native code using another library like libyasm or `as` by end-user. 
so compiler will lex and parse source code, generate AST, then convert AST to assembly. 
then `as` or some other tool, will compile and generate executable.
reason for AST is for optimization. maybe we want to inline or optimize some code.
so we will keep AST in memory and when processing is finished will translate it to assembly.
1. lex and parse -> AST
2. process and optimize AST -> AST
3. translate AST -> assembly
4. compiler assembly -> executable

N - Is having multiple functions with same name a good thing? Doesn't it cause confusion?
`func draw(x: Shape)`
`func draw(x: Circle)`
`var t: func(x: Shape) = draw;` 
`t(myCircle)` does this call draw(shape) or draw(circle)?
I think it's fine. Let's just act just like C. When you bind value to a variable, the exact type that you specify is used.
But this is not C. we can assume that `t=draw` will match any function named draw which has a signature conforming to t type. 
In other words, dynamic dispatch does not work with function pointers.

N - Cant we replace generics with polymorphic types?
usages of generic: collections, `option<int>`, ...
we can also define tempalte-based data structure and functions

Y - replace `$0` with some other thing like `$$` because its confusing.
we can assign function name to `$0`. `$!` for exception

N - ability to define function on one (or more?) inputs. like go.
based on the semantics developer should be allowed to specify argumetns which come "before" function name.
(s: string).split(c: char) -> ...
It will make things confusing.

N - lets permit change of input if its not explicitly marked as immutable
if we do this, we can no longer test functions easily. but still same input will cause same output.
marking immutable: local vars, function inputs, struct members.
immutability makes things complicated specially when combined with array or generics.

N - `func(x:int, y:int -> int)` instead of `func(x:int, y:int) -> int`
so if a function returns a function or accepts a function, the signature will be easier to read

N - do we need explicit interface declaration? Like Number, Comparable, ...
But we can define it as a normal type + a set of functions on it.

Y - use array mode `$[0]` instead of special variables `$1`

N - have eveything implemented as library even and/if/for/...
this is not an academic language. it must be practical.

N - what are language's constraints? Can we reduce them?
We have to make the language manual as small as possible.

N - Can we make exceptions easier?

N - do we need to explicitly state we are overring a method or extending a type?

Y - what if we replace inheritance with composition?
If so, what should be done for interface inheritance?
What should be the name of the composed field? 
```
type Shape := struct {}
type Circle := struct {
  s: Shape;
};
func area(x: Shape) {}
var c : Circle;
area(c);  //we can cast c to Shape
```
what about object parent? do we need it?
What's use of object? Providing some basic methods like equals and hash.
we can implement this with template methods.
```
func toString!T(t: T) {}
func getHashCode!T(t: T) {}
```
currently I see no need for an `object` global parent.
 
Y - what if struct has an integer and we call a method which accepts int and struct type.
there should be a way to emphasize our intention of composing them to inherit their implementations.
maybe by adding appropriate cast methods.
`func cast!(Circle, Shape)(c: Circle)->Shape { return c.shape13; }`
So if there is ambiguity, compiler will throw error unless there is a cast function.

N - any easier or more robust solution instead of `cached`?
1. each function has a private static storage.
the function takes an implicit input provided by runtime. like in `$[-1]`
As of now, its removed from spec. Later we will add it back if we find a good solution.

N - for memoization we can use default value for input arguments
but what would be the syntax?
`func draw(x:Shape, cache ~= Map{}) -> {...}`
Then if we have this `~=` new notation, we should be able to use it inside function too (orth). then there is no need for the default arg value because we can have this inside function. Then we won't have a pure function -> this last one is ok I think.
Maybe we can use normal `=` notation and mention that default arg values are generated only once by the runtime. so if it's a primitive, it's ok but if it's a struct, then all function instances will share the same cache -> not good for multi-thread.
also if we cannot modify function input, then we cannot add anything to this cache.
you "can" return different output with same input if there is some kind of static data in the function.
so any kind of static data is bad. even in the function inputs or through runtime helpers.
this is not really essential part of lang design at this step. so we will cover it laster.

N - let's enable functions to change their inputs.
Its very good if function is pure but let the developer decide about this.
`func calc(x: Person) { //cannot change x }`
`func calc(var x: Person) { //can change x}`
It this compatible with `$[0]` notation? by default these are not mutable unless there is a function signature for current code which states they are. so `$[0]` is just a pointer to the inputs. If they are marked as mutable, then they are.
What about local variables? What about struct members?
Struct members cannot dictate whether they are mutable or not. the user does this.
local variables are marked with `var` so they are mutable.
how does this change the way we call the function?
`func calc(var x: Person)...`
`var x: Person{name:'mahdi';}; calc(x)` or `calc(var x)` or `calc(&x)`?
`calc(x)` is not good because we have to stress the fact that `x` WILL be changed after call to calc.
`&x` is similar to C notaton but is it orthogonal? can I use this notation in other places?
having ability to return multiple values, why we cannot just return the changed value?
`func calc(x: Person) -> Person { return y; }`
actually we return multiple items using anon struct.
if immutability is so good, why not enforce it even upon var creation?
but everything immutable is not practical in some cases. We should have room for mutability for make it explicit.
e.g. data structures, sort, ... they all need mutability
or we can define some mutable local variables, but they will be immutable outside when returned or sent to other functions.
how about this?
```
var x: int = 12;
var y: int = x+1;  //y is assigned a value upon creation
var z: int = { //a block of code which can change value of z };`
```
we have a special variable like `$@` which is 'mutable' and represents the output which will be assigned to the variable.
in this way, it is only allowed to change value of local variable and only once and in a specific location (upon declaration). so how can this be used to implement quick-sort?
```
func quick_sort(x: int[]) -> int[] {
  var result: int[] = {
    int pivot = x[mid];
    int i=0;
    int j = n-1;
    while ( i <= j ) {
      while ( x[i] < pivot ) { $@[i] = x[i]; i++; }
      while ( x[j] > pivot ) { $@[j] = x[j]; j--; }
      $@[i] = x[j];
      $@[j] = x[i];
      i++;
      j--;
    }
  };
  retrn result;
}
```
one way is to do this in native functions (sort, ...) but its not orth.
can we nest two of these into each-other? probably no. because if so, we cannot reuse `$@`. we can just use return statement. but it must be explicit in the code. 
```
func quick_sort(x: int[]) -> int[] {
  var result: int[] = {
    result[0] = 11;
    result[1] = 12;
  };
  return result;
}
```
the block on the right side of `=` is called mutable block and it's local variables are mutable. it has read-only access to data outside. 
to work with the original variable we have three options: special syntax like `$@`, use same name `result` or return something.
`$@` cannot be nested.
`result` is not readable. `var result = { result = 12; }`!
maybe return.
`var result: struct{name: string, age: float} <- { return x; };`
```
func quick_sort(x: int[]) -> int[] {
  var result: int[] <- {
    int pivot = x[mid];
    int i=0;
    int j = n-1;
    while ( i <= j ) {
      while ( x[i] < pivot ) { $@[i] = x[i]; i++; }
      while ( x[j] > pivot ) { $@[j] = x[j]; j--; }
      $@[i] = x[j];
      $@[j] = x[i];
      i++;
      j--;
    }
  };
  retrn result;
}
```
by using result statement, we can nest this block. and it is readable.
so everything everywhere is immutable unless inside mutable block which is used upon variable declaration and `<-` notation inside which all local variables are mutable.

Y - custom operators?
like `>`, `=`, `+`, ... .
we can map these to function names. so if there is something like `add` for type T, then `a+b` will call it.
same for `[]`. `x[10]` will call `op_index(x, 10)`.

Y - for interoperability, common functions and other use cases we need the root type.
we can name this `object` or `struct{}`. but what if it is a union or enum?
`type`?
object is not good because we dont claim to be OO.
but object is intuitive.
`object`
`var x: object`
also we can use some runtime lib functions to get real type of an object.

Y - maybe we can remove notation for the current exception `$!` and catch `#`.
`call_f(); (exc) { print exc; exit(5); }`
`{ ... code block } (exc) { print exc; exit(5); }`
`{ ... code block } except(x) { print x; exit(5); }`
but we must stress that only one except block is valid. so somehow it should be bound to the closing `}`. or semicolon.
`{ ... code block } if($!) { print $!; exit(5); }`
Either we should specify type of exception or add the object type.
`{ ... code block } except(x:int) { print x; } except(y:object) { print y; }`
`{ ... code block } except(x:int) { print x; } except(y:object) { print y; }`
`{ ... code block } var x: int = recover(); print x;`
`var y: object; { ... code block } catch(var x:int) { print x; } catch(y) { print y; }`
to be more consistent and orth, we can have `get_exception!T` which can be called for different types of exceptions.
`{ ... code block } var x: Maybe!int = get_exception(); if ( x.value?) { ... } `
this elimintates `#` and `$!` notation and is consistent with other syntax definitions.
only problem: biolerplate. 
`if ( get_exception!object().value? ) ...`
its ok I think. If we don't want biolerplate either we have to introduce macro or use shortcut symbols. both are not good.

Y - shall we replace `$x` notation with some keywords?
done for exceptions. we now only have `$[0], $[1], ...` and `$_` which seems reasonable.

Y - maybe `<-` notation is not a good thing. it is like a shortcut to bypass language features.
let's remove this notation and provide enough library functions to cover 90% of use cases for mutability (sort, data structures, ...).

Y - as a shortcut, we can use `$` to refer to `$[0]`. so validators can be more expressive. 
So `$` won't mean an array of function inputs.

Y - use keyword for validation.
`var x: int[$[0]>10]`
`var x: int with {$[0]>10}`
`var x: int with {$[0]>10} with {$[0]<100} with { check_value($[0]) };`
`type x := struct { x: int; y:int; } with { $[0].x < $[0].y };`
but we state that everything is immutable. so values don't change. But if I have an integer variable, its value will change some of the time.
`var x: int with { $[0] > 0 }; x= 11; x = x+10; x=x-100;`
so validator is compatible with immutability.

Y - suppose we have `Base` struct and `Derived` structs. Two methods `add` and `addAll` are implemented for both of them.
if `addAll(Derived)` calls `addAdd(Base)` which in turn calls `add(Base)` then a call to `addAll(Derived)` will NOT call `add(Derived)` but will call `add(Base)`. When `addAll(Base)` is called, it has a reference to `Base` not a `Derived`. 

Y - shall we change the syntax for import to stress we are importing files?
`import core::st::Socket;`
`import /core/st/Socket;`
`import core:st:Socket;`
`import core>st>Socket;`

Y - what about a package? what defines a package? 
a package is a directory which contains a set of source files and other directories.
this dir can be named `network` located inside `package` directory.
then we can use this package and all of it's functions by using: `import package::network::;`
`import package/network/**;` to import everything recursively
`import package/network/*;` to import source files under network dir

Y - what if two functions with same name exist in two packages we want to import?
import the first one normally. and then get a function pointer to the second function.
`import core/pack1;`  //import entire file
`func myFunc(x:int) -> /core/pack2/myFunction;`   

N - can we enhance the language to support automatic and transparent parallelization?

N - add `val` so variables declared with val cannot be re-assigned.
`val x: int[] = {1,1,1}; //ok`
`x=[1,2,3]; //wrong`
every data is either function input or local variable.
function inputs: cannot be changed or re-assigned.
local variables: `var` can be re-assigned but `val` cannot.
immutable means cannot be changed but its ok to re-assign:
`var x:int = 12; x = 13;`
now, shall we add `val` keyword used to define local variables which cannot be re-assigned?
this can be used to define constants.
for inside a struct, items cannot be re-assigned because this means mutability of the parent data structure.
`val x: int = 19; x= 11; //error`
`var x: int = 11; x = 12; //ok`
in this case, `var` will define mutable data because of the name. This is similar to Scala.
In any case, function input is immutable. struct members are immutable (unless the struct itself is mutable).
we are not using immutability advantages, only we are allowing the developer to have a choice between mutable and immutable.
so types can be mutable or immutable based on the instantiation in the code (use var or val).
local variables can be declared using var or val.
function inputs: they are all immutable?
`func add(x:int, y:int) -> {x++; return x+y;} //error! inputs are val by default`
`func add(val x:int, val y:int) -> {x++; return x+y;}`
`func add(var x:int, val y:int) -> {x++; return x+y;} //ok, you can change x because it is var note than you cannot add with a val as first argument`
`func add(var x:int[], val y:int) -> {x[0]++; return x+y;} //ok`
Note that when a function input does not have modifies, its `val` by default.
If function expects `var` you must send a var but if it expects `val` you can send either var or val.
`var hash1: int[string]`.

N - Original comments about invoke:
We have `invoke` and `select` keywords. You can use `future<int> result = invoke function1();` to execute `function1` in another thread and the result will be available through future class (defined in core).
Also `select` evaluates a set of expressions and executes corresponding code block for the one which evaluates to true:
```
select
{
    read(rch1): { a = peek(rch1);}
    read(rch2): { b=peek(rch2);}
    tryWrite(wch1, x): {}
    tryWrite(wch2, y): {}
    true: {}  //default branch
}
```
You can use select to read/write from/to blocking channels.

N - What about this code?
`val x : Customer{...}; var y = x;`
It is invalid.

N - If we have an immutable array, what is type of array elements? Are they also immutable?
What about hashmap? and other data structures?
can we define struc elements as val or var?
`type x := struct { var a: int; val y: int;};`
Anything defined with `val` must be assigned upon instantiation of the type.
`var t: x{a:10};` here you can change t to anything else or change it's `a` but you cannot change it's `y`.
Let's say, for array, elements are same as the array variable itself. if array is mutable, it's elements are too.
`val x: int[3] = [1,2,3]; //you cannot change x or x[0] or x[1]...`
`var y: int[3] = [1,2,3]; //you can change y and it's elements.`
If you need anything more specialized, define a struct with appropriate type and mutability indicator.
Same for hash. hash keys are immutable but values are same as hash itself.
But doesn't this make thing more complicated. Now we have 3 types: auto (based on the container), val and var.
Let's make indicator required for struct.
So the rule of mutability same as the container, only applied to array and hash.
Scala has mutable and immutable hashmap. Maybe we should have too or maybe `var/val` can achieve that.
How can we have an immutable array with mutable items?
`val x:int[]`
`type s := struct { var x: int}; val arr: s[];` //here arr is immutable but it's elements are not.
`func add_days(dt: Date, days: int) -> Date { val d: Date; ... ; return d; }`
`var date1 = add_days(my_dt, 10);` //is this code ok? the function is returning an immutable variable but its assigned to a mutable variable.
in scala you can assign return value of a function (which is returning a val), to a var and change it.
data that we want to control being immutable/mutable:
1 - local variables (can be array or hash)
2 - function inputs
3 - function output
4 - types (struct members)
I think the way scala is handling this is not consistent and orth.
If we are looking to have const/non-const data types, shall we also add reference types?
`var x : int& = &y; //x points to y`
no. We assume everything is passed by reference. If it is const, you cannot modify it in any way.
Shall we incorporate mutability as a special syntax? Instead of adding `val/var` everywhere, add a prefix/suffix to the type.
`var x: int;`
`var x: ^int;`
`var x: int~;`
`var x: int[];`
`var x: array!int;`
`var x: int[string];`
`var x: hash!(int, string);`
can this be done in a more logical and orth way?
like `var x:int; x.freeze();`
or `type mut_int := int with { false };`
Why do we need const? It is like static typing. Enforces some basic rules to the code which reduces probability of error.
Go: Everything is mutable, if you need imm, just mark fields as private.
Maybe we can provide immutability with a template type.
`var x: mut!int;`
`var x: imm!int;`
`var x: const!int;`
its too much code. It should be simple and short.
Let's have imm by default. So everything is immutable unless its type has a specific predix/suffix. 
We can achieve some mutability with imm types (clone and return). And adding mut to the language makes it more complex.

N - shall we use a notation instead of `var` because really, it's not a variable anymore.
`var x: int = 12;`
no explicit and keyword-based is better.
but this is wrong to use `var` keyword. 
Use `val`.
what if we allow for both but only for local variables? for types -> same as parent, for function input: val.
`val x: int[3] = [1,2,3];`
`var x: int[3] = [1,2,3];`
var means item can be re-assigned and it's state/elements can be changed.
val means only re-assign.
if we cannot send a `var` to other functions for modification by reference, then it won't be much useful.
`def`, `my`, `auto`, `set`, `let`, `val`
Start variable name with `$` like Perl?
`#x: int = 12; x = 11;`
lets keep var. they are variable because they can be re-assigned.

N - a more programmatic definition for const
`func f(x: int {const($)}) -> ...`
not useful.

Y - object can be thought of as an empty struct.

N - we can add pointer type.
`var x: int*` or `var x: int&`
same as C and these types can be considered mutable.
`var x: int[]&; //x is a pointer to an array`
`var x: int[&]; //x is a normal array containing pointers`
but we already have this built-in. Because everything is a reference.
`var x: customer{name='aa'}; var y=x;` then y and x are pointing to the same thing.
or `var y = x{}; //clone x so y and x point to different things`

N - protocol
Clojure has protocol similar to interface. Then when defining a new type, it can be used to define API.
but we still need inheritance to have code re-use.
```
type drawable := protocol {
   draw(this) -> long;
   stats(this, int[]) -> string;
};
```
we can have this with an empty struct.

N - maybe we can eliminate polymorphism.
`type Shape := struct;`
`type Circle := struct {x:Shape...}`
`type Square := struct {x: Shape...}`
`func paint(o:Shape) {}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
Why do we need paint for shape?
Even if we do, at compile time, compiler can merge all `paint` functions into a single function which checks for input type.
Anyway, from the coding perspective, nothing changes and at runtime we will still need multiple dispatch.

N - some idea for organizing: refer to everything inside a module (file) using module name prefix.
you can alias when doing import or import local so you don't need prefix.
but then we will loose transparent method dispatching.

N - How we want to solve fragile base class problem? 
If base class has inc1 and inc2 and derived class overrides inc1 calling inc2.
and later in base, inc2 calls inc1, it will cause infinite loop.
```
type Parent = struct {x: int};
func inc1(p: Parent) -> inc2(p);
func inc2(p: Parent) -> Parent { return Parent{p.x+1} };

type Child = struct { p: Parent; };
func inc2(c: Child) -> inc1(c);
```
golang does not have this issue because you cannot override a method which is written for the contained variable. When struct A contains B, calling a method on B, will have an instance of B not A.
So on the first call, when you pass an instance of A and we have a function for B, A is cast into B, and after that, the function will have a B, not an A.

Y - we need to explicitly define which contained elements in a struct are to be inherited and used in polymorphic situations. Else there can be unwanted consequences.
`type x: struct { a: int; }`
x can be used as an integer without us wanting that. If we call a method that accepts an integer with an x instance, compiler won't complain.
one solution: unnamed field.
one solution: syntax sugar for casting
```
type Square := struct { shape: Shape; size: int };
func cast!(Square, Shape)(s:Square) -> s.shape;  //normal code

type Square := struct { 
  shape: Shape; 
  size: int;
  //functions that take a single input named this, poninting to the parent type
  func cast!Shape -> this.shape;
  //No this is too big exception
};

func cast!(Square, Shape) -> $.shape;
```
for inheritance, we need a cast function.
for interface, nothing is needed. just implement those methods.
So if a class wants polymorphism, he has to define appropriate cast functions.

N - enforced private methods just like enforced imm.
there is not much advantage there. a warning message is enough.

N - if we get a hash representing a type `var h: object[string]` and we call `to_string` for data inside the hash, will it call appropriate methods?
It should. The code that creates that hash, stores actual types into the output (it does not cast).
But when we call a function on a contained type, runtime will cast the data.

Y - pre requirement for built-in templates: `with` for function as pre and post conditions:
`func AA(x: int) with {pre_check} -> int { ... } with { post_check}`
One solution: we can define two `with` blocks for function. pre and post.
`func pop(s: Stack) with { pre_conditions on inputs} -> object { ... } 
with { post_conditions }`
pre-condition has access to function inputs only.
post-condition has access to function output (`$`) and inputs (by their name).

Y - maybe add a shortcut for type checking:
`y :: long` equals to `typeof(y) == typeof(long)`
to decrease boilerplate code.
It returns true if `y` is long or can be casted to long.

Y - everything is immutable even local vars. right?

Y - replace word `object` with something else like `any`.

Y - How can we eliminate templates?
usages:
collections like stack/queue/...
algorithms (sort, search, ...)
operator overloading
map/filter definition

```
type Stack := struct { x: object[]; };
func push(x: object, s: Stack) -> ...
func pop(s: Stack) -> object {...}

type StackInt := Stack!int;
//specialization
fun pop(s: Stack) -> int ...;
```
or instead of object, we can use convention (what if a function takes 10 inputs of object and stack?).
```
type Stack := struct { x: T[]; };
func push(x: T, s: Stack) -> ...
func pop(s: Stack) -> T {...}

var x: Stack!int{};

```
or to be more consistent:
```
type T := object;
type Stack := struct { x: T[]; };
func push(x: T, s: Stack) -> ...
func pop(s: Stack) -> T {...}

var x: Stack[T=>int]{};
```
we can add a general rule for all instantiations to filter some type. Meaning replace some type with a more specific type.
So if a struct has a member of type `Person` we can define a new type based on that struct but replace `Person` with `Man` type. So in all references to that type, read and write to that member will be type checked to be of type `Man`.
So as a result, if type uses `object` it means it can accept all types.

```
type T := object;
type Stack := struct { x: T[]; };
func push(x: T, s: Stack) -> ...
func pop(s: Stack) -> T {...}

//like validation code but for read/write filter. This cannot be only code, we also need notation
//because we want to pass this type over to other places. but we can name it accordingly and do not rely on 
//a new notation. Suppose that we have a function which expects a Stack of strings. What should be the type of input?
func ff(x: Stack) ...  //no
func ff(x: StackString) ...  //yes, and StackString defines those codes for type checking
```
so we can define types just like before BUT same as the way we add `with` code, we can add type checking code.
```
type Stack := struct { x: object[]; };
//maybe we can even re-use validation logic
type IntStack := Stack with { typeof(x) == typeof(int) };
//OR if you like messy code
func push(x: int, s: Stack with { typeof(x) == typeof(int) }) -> ...
```
what about algorithms? e.g. quick_sort function. we can just use object and specialize if we need.
```
func quick_sort(x: object[]) -> object[] { ...};
func quick_sort_int(x: int[]) -> int[] { return quick_sort(x); }
```
map and filter can be considered built-in notations if need be.
same for operator overloading. Any of these can be specialized by writing functions with correct name and specialized types.
```
func map(x: object[], pred: func(object)->object) -> object[] with { typeof(pred) == typeof(func(typeof(x))->typeof(x)) }
...;
```
This means we need to add `with` to function too, to do some pre-requisite checks, which will be executed before function starts.
can we make checks compile time? 
I prefer not adding a new notation for compile time vs runtime checks. Compiler will execute `typeof` checks at compile time. Others will be at runtime.
`... with X` means X will be checked when the function is called or when the data is changed.
or maybe it's better to define it like this: it is called before function execution or creation of the item (all data are immutable, so we don't change but create).
For example what about `List<Dictionary<String, Long>>` in Electron?
`type CustomHash := Hash with { typeof(x) == typeof(string) } with { typeof(y) == typeof(long) };`
`var x := List with { typeof(x) == typeof(CustomHash) };`
question: how do we know types used in `with`? is it `x` or `key` or `type1`? We have to see the code or doc.
How do we implement a linked list? Its difficult with everything being immutable.
```
func add(ll: LinkedList, i: item) -> LinkedList with { $.x :: i } with { ll.x :: i } { ... }
var x := LinkedList with { $.Item :: int };
x = add(x, 10); //ok
x = add(x, "AAA"); //compiler error
```
`with` in the definition of `add` function above is confusing. It is for the function or for the output?
`func AA(x: int) -> int { ... }`
Pop code:
`func pop(s: Stack) -> object { ... } with { s.Item :: output }`
How can we use output type to specify conditions? Maybe we need a new notation?
But `with` for function is supposed to be executed 'before' function starts. So we shouldn't have access to output.

Y - in struct definition use comma instead of semicolo, like anon struct. will be more consistent.

Y - can we remove enum or replace it with union?
`type DoW := enum { SAT=0, SUN=1,... };`
`type DoW := int with { $ == 1 or $ == 2 or ... };`
enum is not consistent with other concepts that we have. `with` is not good here because options can be too much.
```
type DoW := union {
  SAT,
  SUN,
  MON
};
```
And developer can write a function to get numerical values for each value.

Y - A method to define constants:
`func PI -> 3.1415;`

Y - How can we use `::` notation with array and hash?
for example type of x should be same as elements of array or key or value of a hash?
`x :: y` means same type
what if `y` is an array and I want to refer to type of elements of `y`?
```
var x: int;
var y: int[3] = [1, 2, 3];
var same = x :: y[];  //y[] means type of elements of y array
var z: int[string];
var same2 = x :: z[];   //z[] means type of values inside z hashtable
var same3 = x :: [z]    //z[] means type of keys of z hashtable

```

Y - can we simulate union (and enum) with struct + with?
Does immutability of variables make this earier/different?
Maybe using `with` + some special function is better, more consistent and more general that defining a new type.
We will only have one type: struct. which can be customized to do a lot of things all powered by validation.
`type DoW := struct { isSAT: bool, isSUN: bool, ... } with { union($) };`
Another shortcut we can add: users can eliminate type if it is bool.
`type DoW := struct { SAT, SUN, ... } with { union($) };`
To have custom values, easily write a cast method to cast this type to int.
`func cast(x: DoW) -> int { if ( x.SAT ) return 10l ... }`
Then if we use this method, do we still need `?` notation?
`type Optional := struct { Empty, value: any } with { Empty xor value };`
`type OptionalInt := Optional with { value :: int };`
Problem is: Union works with value being set or unset. But we don't have anything like `unset` value.
Advantage of unset is to save storage. We don't care about that. So let's assume everything is set. So how are we going to know which value is represented in the union? For example optional union?
`type Optional := struct { Empty, HasValue, value: any } with { union($.Empty, $.HasValue) };`
`union($)` means only one of boolean members of `$` can be true.
`type Optional := struct { Empty, HasValue, value: any } with { union($.Empty, $.HasValue) };`
so to make things easy to understand we have to either keep union type or add `undef` literal.
with `empty`:
`type Optional := struct { Nothing, value: any } with { Nothing or empty(value) };`
I think using `empty` is better but shall we add a literal or add functions for checking?
Literal makes more sense. `if ( x == empty )`
candidates: `empty`, `nil`, `null`, `none`, `nothing`.
`none` is better. So each variable has a value of `none` when it is not assigned a value.
By using this, we have optional built-in!
`type Optional := struct { Error: string, value: any } with { union($.Error, $.value) };`
`union` means only one of members can be non-none.
What about enum?
`type DoW := struct { SAT, SUN, ... } with { single_true($) };`
can we make `single_true` or `union` notation more consistent and intuitive?
`type DoW := struct { SAT, SUN, ... } with { xor($) };`
`type Optional := struct { Error: string, value: any } with { union($.Error, $.value) };`
But a lot of exceptions can happen in the code when it is working on a variable, expecting it to have some value but it is none! Like NPE or all problems with null values!
Is there a third option?
Goal: we want to support union types. But we don't want to add a new `union` keyword or introduce new `none` literal. 
solution 1: special function (only one field can be initialized upon instantiation of this struct).
`type Optional := struct { Nothing, value: any } with { union(value) };`
it is a bit inconsistent, but lets us escape from problems of `none` and `union` keyword.
but we also need a way to check which field is assigned a value. 
other solution: exactly like C, make storages overlap, so dev needs to add some boolean flags to determine which variable is assigned.
```
type Optionsl := struct {
  flag: struct { NothingIsSet, ValueIsSet } with { xor($) },
  data: struct { Nothing, Value: any} with { union($) }
};
```
It's not a good notation to define a struct and specify its low level storage requirements with `with`.
maybe we can do this via `::` operator.
```
var x: any = 12;
if ( x :: int ) ...
if ( x :: string ) ...
x = "12";
...
```
so the check will be type-based not name based.
or maybe we can define a `static type` version of any?
`type MaybeInt := any with { $ :: int or $ :: bool } with { $ :: int or $ == true };`
`var x: MaybeInt = 12; if ( x :: int ) ... `
Can we make it simpler? Like defining a label for value of the variable? Something like enum.
`var x := any with { $ :: int or $ :: NONE };`
`x=12; x=NONE;`  This is not good. Makes code un-readable.
`type MaybeInt := struct { value: any, hasValue: bool }`
What is we have special syntax for literal labels?
`var x := any with { $ :: int or $ == @NONE };`
`type DoW := any with { $ == @SAT or $ == @SUN or ... };`
`type DoW := any with { $ in [@SAT, @SUN, ...] };`
`var x: DoW = $SAT;`
we assign custom literals to possible values of a variable.
what is the type of a variable which is holding a custom literal?
Custom literals are bound to types. You cannot use them freely.
`var x = @SAT; //WRONG`
`var x : DoW = @SAT;`
So:
1) To define enums, define a variable and use `with` to specify it's possible values using custom literals
2) To define union, define a variable of type `any` and use `with` define it's possible types (and possibly custom literals)
`type bool := any with { $ in [true, false] };`
So what does this mean:
`type person := struct { name... } with { $ == @AA };`
This means any variable of type `person` can only have value of `@AA` regardless of elements of the struct. Syntactically it's ok although does not make sense.
But this syntax is confusing. Most of the time, we want to keep the original data AND have custom literals.
`type person := struct { name... } with { $ :: ? or $ == @AA };`
`type person := struct { name... } with { $ == @AA };`
The nature of custom literals is not consistent with `with` clause. We have to add a new notation.
```
type OptInt := struct { value: any, none: bool };
```
So let's do this: Instead of adding the new thing (custom literals), we use bool fields.
we can add a new notation that `x = y` can also mean `x.y = true;`.
or we can use `@` here: `x=@y; => x.y = true;` so `@` notation is used to set a flag. but what abt imm?
`var x : Dow{@SAT}` means `var x : Dow{SAT: true;}`.
So we still need `with` to enforce enum valid types. 
About union:
`type MaybeInt := struct { value: any, hasValue: bool }`
`var g: MaybeInt{@hasValue};`
`if ( g.hasValue )`
But technically we can have a MaybeInt which has a value and `hasValue` is set to false. 
But that is responsibility of the developer, I think.
`var h: MaybeInt{value:12, hasValue: false};`
we can set default value for hasValue to false. So dev has to set it explicitly when he needs it.
so:
1) To define enum, define a struct with appropriate bool fields and `with` clause to enforce only one of them can be true.
2) To define union, define a struct with any field + bool flags for possible values.
We can use `@` notations as a shortcut for bool fields:
```
var x: Dow{@SAT};
if ( x.SAT ) ...
```
But eliminting it does not harm syntax.
Maybe we can add a special function which enforces dev to set value only for one field. So when he is instantiating, he can set value only for one field.

Y - Make syntax for enum and union easier.
```
type DoW := struct { SAT, SUN, ... } with { xor($) };
var x: DoW{SAT};
if ( x.SAT) ...
var y = x{SUN}; //error -> both SAT and SUN are set to true
```
union:
`type IntOrBool := any with { $ :: int or $ :: bool };`
xor is not correct for enum. If three fields are set, it will return true.
`type DoW := struct { SAT, SUN, ... } with { xor($) };`
We can use `$.*` as a notation to represent elements inside a struct. 
In this case, using a vararg method we can easily enforce enum criteria:
`type DoW := struct { SAT, SUN, ... } with { single_true($.*) };`
or we can have a built-in function which given a struct, returns an array of `any` variables: `internal($)`
`type DoW := struct { SAT, SUN, ... } with { single_true(internal($)) };`
Then we can define a shortcut for this:
`type DoW := struct { SAT, SUN, ... } with { enum($) };`
This `internals` can also be used for serialization.
can we have a mechanism to see if some field of a struct is "set"? If so we can easily define a struct with this condition.
Like:
`type IntOrBool := struct { x:int, y: bool } with single_set($);`
But this will only be good good for union. For enum, we need to enforce a single field is "true".
`type IntOrBool := struct { x:int, y: bool } with single_set($);`
NO! Checking if a field is set, is really a special case.
We try everything to avoid null or nil or nullable types. 
Question: How can we define dow enum?
`type DoW := struct { SAT, SUN, ... } with { enum($) };`
This should be general. What if we want to have at most two fields to true?
`type DoW := struct { SAT, SUN, ... } with { 1 == count {$ == true}, $.*) };`
`$.*` is an array of items inside `$`. Or we can say it is a hash where key is field name and value is value.
Can we do the same for all variables? `var x = Person{...}; x.*`
So we can introduce a new notation `A.*` where A is any non-primitive variable.
`A.*` for a primitive will give you the variable itself (a single-element array).
`A.*` for a struct, will give you an array filled with values inside the data structure.
Advantage: We can implement general filterings like what we need for enum.
What about union?
`type IntOrBool := any with { $ :: int or $ :: bool };`
We really don't need anything special for union type. There is no need for enhancement or shortcut. Its fine.
Somehow it feels wrong to add this feature only for the sake of enum. For serialization, we can simply use functions.
Problem is: if we add a magical function like `enum`, can we call it elsewhere?
`type DoW := struct { SAT, SUN, ... } with { 1 == count {$ == true}, $.*) };`
What if we define a function which returns number of fields in a struct which are equal to `x`: like `eq_count`
`type DoW := struct { SAT, SUN, ... } with { 1 == eq_count($, true) };`
Problem: This is not general! What if we need to filter by elements which are positive? Or any other filtering?
This is not general and is not flexible.
How can we make this as flexible as needed but without adding any new exception or new notation?
1) `$.*` notation
2) a function like `members($)` which returns array of fields inside struct
3) A new notation to define it based on `int`
```
type DoW := int with { $ == 1 or $ == 2 or ... };`
```
We should have a mechanism to define constants.
but I don't want to add a new keyword. only `func` and `type`.
What if we use the const keyword?
```
type DoW := int with { $ :: DoW } //force values for this type to be only DoW type, not int;
const SAT : DoW = 1; 
const SUN : DoW = 2;
...
var g: DoW = SAT;
g = SUN;
g = 1; //wrong!
```
Advantage: we can have string enums or of any other type.
Advantage: It's more intuitive.
Advantage: No need for special syntax

Y - Shortcut for with:
`with { some_func($) }` can be written as: `with some_func;`

N - with clause can be considered as a constructor.

Y - What happens if we refer to an un-initialized any variable?
They "must" be initialized.

N - For struct, if type is not specified, it is boolean.

N - instead of `cast` function why not having a function with the same name of the target type?
But naming convention for types is `CapitalLetter` but for functions it is `name1_name2`.

===============================

Y - replace with keyword with assert also use it for pre/post condition check for function.

Y - Instead of variadic functions, we can define an array input. Then user will send an array literal with any number of input he wants.

Y - About exceptions. If function A has a failed assert, what is the mechanism to run? How/where will runtime search for `get_exception` calls?
What if there is no exception? What will this (`get_exception`) return?
Maybe we need to add another function `has_exception`.
Maybe we can add a mechanism like `dispose` but for a function. This can also cover the case where function needs custom cleanups. This code will be called after function exit (normally or because of assert failure).
```
func adder(x: int, y:int) -> int 
{
  var g = call_method();
  return x+y;
} 
assert { if ( $ > 0 or has_exception() ) ... }
```
We can re-use assert for post-condition, cleanup and exception handling.

N - In order to simplify variadic function, we can assume `$` is an array.

Y - variadic function: accept an array as last input

N - the new template system: how does it affect polymorphism and casting? No effect.

Y - as casting is important for polym. too, maybe we should simplify its syntax.
`func cast(s:Square) -> $.shape;  //normal code`
`func Square#Shape -> $.shape ;special syntax to define casting functions`
But target can be implied from output type. But it's better to explicitly indicate that.
`func cast(Square) -> $.shape`
Another approach: define casting logic upon defining data. But this is mixing data and behavior which we dont want.

N - does `x :: int` use static type of x or dynamic type? Should use dynamic because for static it is decidable from source code.

Y - we dont need semicolon at the end of line. You cannot put multiple statements in one line.
Then maybe we can make use of semicolon somewhere!
Maybe for comments! then user "can" mis-use and put semicolon at the end of the line
Then can we use // or `#` for another purpose?
To prevent mistakes where user puts two statements and compiler reads the second as a comment,
';' must be either first character of the file or it must follow whitespace.

N - add concept of protocol. maybe we can use `assert` for this.
```
;there must be a paint function defined according to below signature for any type which can be casted to Shape
type Shape := struct {...} assert @paint($_, int, int) 
type Circle := struct {x:Shape...}
func Square -> $.shape;  //normal code
```
can we use @ notation in other places?
`if (@paint(int, float)) ...` Seems ok.
Can we use this notation for static checks? E.g. check for consts?

N - Replace assert keyword with `@`
Then for function checking, we can use '%' or ?
No. assert is explicit which is a good thing.

N - can we simplify protocol definition?
`type Shape := struct {...} assert @paint($_, int, int)`
and possibly remove @ notation?
maybe we shouldn't be using assert. Assert is supposed to do runtime check for data.
This is not for data and it not supposed to be at runtime.
`type Shape := struct {...} has paint($_, int, int)`
In this way we will remove @ notation and its usage in other places.
`type Shape := struct {...} supports paint($_, int, int), delete($_)`

Y - Can we simplify casting?
`func Square#Shape -> $.shape`
`type Shape := struct {...} -> Shape $.shape, -> int { return $.x + 5 }`

N - Can we make runtime type checking more flexible and robust?
`func pop(s: Stack) -> any { ... } assert { $ :: s.x }`
It is better to have consistent definition for :: so both parameters must be values?
To get unique type identifier: `id(x)` as a core function will return a number representing type of x.
`type_id(x) == type_id(y)` is the same as `x :: y`? No. Maybe they have different types but can be casted.
`x -> y`
This can be represented as a cast-only function look-up.
`exists(id(x), id(y)) ;there exists a cast function for x which outputs y type`
`if ( x -> type_id(y) )` if you can cast x to y
`if ( x -> int)` or `if ( x -> type_id(y) )`
but `->` is already used for function definition. I prefer not to reuse it here but would like to have a notation which implies direction.
`if ( x.(int) )`
`if ( x =? y )`

N - Why do we need `supports` keyword? Can't we just implement those methods normally and override them in children?
```
type Base := struct {}
type Derived := struct {base: Base} -> Base $.base
...
var x:Base = get_data();  //runtime type of x is Derived
;calling method m on x where we have implementations for Base and Derived should call Derived impl.
```
remove supports keyword.

Y - The syntax for defining custom cast is not consistent and intuitive.
`type Square := struct {...} -> Shape $.shape, -> int { return $.x + 5 }`
`type Square := struct {...} as Shape = $.shape, as int = { return $.x + 5 }`

N - Does implicit casting work well with current method dispatch?
we have f(Shape,B,C). and x:Square can be casted to Shape.
now a call to f(x,y:B, z:) will try to find f(Shape, B, C) first, if runtime type of x is Shape.
But if x is a Square, it will look for f(Square, B, C) first. 
Seems there is no conflict here.

N - Like Haskel ability to define a function for literal input.

N - Adding sum types?
`type Result  := struct { OK: int | Failed:int}`
`type Result  := struct { OK: int | Failed:int, response: string}`
We already have any with assert.

N - use `::` in function definition to impact method dispatch.
```
func draw(c: Canvas, s: Shape) -> ... at runtime this function will be called for inputs of dynamic type Canvas and Shape or static type of Canvas and Shape. 
func draw(c :: Canvas, s: Shape) -> ... ;can accept a Canvas or any type that can be casted to Canvas + A shape
```
This can make runtime method resolution more powerful and robust. 
But this will make coding confusing. This should be handled automatically behind the scene.

Y - using assert for everything is not very good. Can we add another keyword? 
usages of assert: making sure something holds, function pre-condition and post-condition, data type checking.
`func AA(x: int) assert { pre_check } -> int { ... } assert { post_check }`
maybe we should use something else for data type checking. `+`? no. a word is better.
`bind`, `with`, *`where`, `filter`
`var m: int assert {validate_month};`

N - How do you define a tree?
`type Tree := any where { $ :: NonEmptyTree or $ :: void }`
maybe we can eliminate any (because it is too general here) and also `::`.
`type Tree := NonEmptyTree | void`
`type Tree := struct { root: Node, left: Tree, right: Tree} | void`
`type Tree := struct { root: Node, left: Tree, right: Tree} | Empty`
`var r: Tree = Empty`
`if ( r :: Empty ) ... `
Here Empty is a type not a value. We are defining a type (Tree).
`type A := B | C` means variables of type A can have values of type B or type C.
Each type can be primitive, struct or label. Valid values for a label must be defined elsewhere.
`type bool := true | false`

N - to enhance caching, if function output is void, we dont cache it or functions that call it (because probably it is having some side effects) -> moved to next phases

N - we should be able to define const inside a function. No we may not need const.

Y - Maybe[Int] can we force programmer to deal with missing value cases?
`type OptionalInt := any where { $ :: int or $ :: void }`
void means variable has no data. It can be used as a label to denote it is not an integer.
`type OptionalInt := any where { $ :: int or $ :: void }`
`var t: OptionalInt = 12`
`var r: OptionalInt = void`
so `void` is both a data type and a literal. `void` variables can only have the only value which is `void`.
When we define a type, we are specifying possible values for it. This can be done either by redirecting to other types (`type age := int`) or by specifying literal values. `type level := 1 | 2 | 3`).
This literal value can be a number or string or a label or any valid literal (e.g a data structure).
`type level := 'Hello' | 'World';` - level is a string type 
`type level := Hello | World` - level is a new type which can be either Hello or World
`type level := Hello | 'Hello' | 1 | 6 | world | 'world' `
`var t: level = Hello`
`var t: level = 1`
`var t: level = 'world'`
`type DoW := SAT | SUN | ...`
`type Dow := 1 | 2 | 3 | 4 | 5`
`MaybeInt := int | None`
This is like union in C but cleaner:
`type Address := string | int`
`type Address := struct { x: int, y: int | string }`
But other languages continue to pattern matching so compiler can detect and prevent errors.
For example to calculate depth of a tree in Haskell:
```
data Tree = Empty
          | Leaf Int
          | Node Tree Tree
depth :: Tree -> Int
depth Empty = 0
depth (Leaf n) = 1
depth (Node l r) = 1 + max (depth l) (depth r)
```
One option is to define function based on the real internal type:
`type Tree := Empty | int | struct { node: int, left: Tree, right: Tree}`
`func depth(x: Empty) -> 0`
`func depth(x: int) -> 1`
`func depth(x: struct{node:int,...} ) -> 1+depth(x.left)`
Shall we make label/values distinct from other keywords? for example prefixing with `#`?
This will make code more readable. 
`type Tree := { Empty | int | { node: int, left: Tree, right: Tree}}`
But for function definition, it does not make sense to write: `depth(x:Empty)`
I think we should define function based on the type not literal values.
```
func depth(x: Tree) -> 
{
  var result = match(x) {
    case Empty return 0
    case y: int return 1
    case z: {node:int, left: Tree, right: Tree} 
  }
}
```
But this means adding a lot of new things. Can we still use `any` with some enhancements?
`type Tree := any where { $ :: @{Empty} or $ :: int or $ :: NormalTree }`
`type DoW := any where { $ :: @{SAT, SUN, ...}}`
But this is not intuitive!
The definition of sum type is intuitive but the pattern matching is not.
```
func depth(x: Tree) -> 
{
  if ( x == Empty ) return 0
  if ( x :: int )
  { 
    var y = int(x);
    return 1;
  }
  
  if ( x :: NormalTree ) 
  {
    var z = NormalTree(x);
    return 1 + max(depth(x.left, x.right))
  }
  
  ;or
  ;use switch and make it an expression like defining anon function
  result = switch ( x ) {
    case Empty -> 0
    case y:int -> 1
    case z:NormalTree -> ...
  }
}
```
So we can use switch for checking value or type. And it is an expression, not statement.
`type Tree := { Empty | int | NormalTree }`
`type DoW := { SAT | SUN | ...}`
```
var i = switch(dow1) {
  case SAT -> 0
  case SUN -> 1
}
```
We can also drop the struct name. So anonymous struct will not be a different thing.
`type Point := { x: int, y: int}`
`type Tree := { Empty | int | NormalTree }`
or maybe we can even drop braces? yes.

N - in sum type, can we map symbolic values to other values?
`type Dow := { SAT=1 | SUN=5 | ... }`
No this is complex. Add a cast function to cast it to int and define whatever custom number you need.

Y - we permit operator customization for types but they have to be defined at the place of definition of the type.
Advantage: they make code more readable because seeing `x==y` and knowing type of x, we can easily verify operator code.
Disadvantage: Makes code reading more difficult. 
It's better to eliminate op cust except the ones that are really needed: equality check.
But this one can also be eliminated. Equality means same binary representation. If you need for reference equality use core functions: `if ( ref(x) == ref(y)) ` else `if ( x == y) ` will always check all data inside x and y to be the same.
So: we don't permit any kind of operator customization.

Y - dont use const.
to define a const: `func PI -> 3.14` or `var x: float = 3.14 where { false }`
First one can be used in module level and second one in function level.

Y - we have only basic data types and define others based on basics: Number, String, ...
`type int := Number where { bits = 16 }`
So primitive data types will include number, string,
Not bool -> can be defined using sum types.
Maybe bit - to define binary and blob data. But bit can also be defined using sum types.

Y - set default value for data types?
`type OptionalInt := any where { $ :: int or $ :: void } default = void`
This will help developer provide sane defaults to the data type
So general format for define data type will be:
`type x := int where {...} as A={...} as B=... as C=... default=...`
Also: `type Pt := {x: int default=5, y: int default=0}`
or maybe we can even make it simpler:
`type Pt := {x: int=5, y: int=0}`
To prevent confusion with casting, we must define default value first, then casting functions.

N - programmer may make a mistake and change order of values when initing a type. 
e.g. `type pt := struct {x: int, y:int} ... var g = pt{1,4}` 
should be replaced with: `var g = pt{x:1, y:4}`
what about function call?
`func log(day:int, month:int)...log(1, 9)`
instead: `log(day:1, month:9)`
This will add a lot of overhead. It is optional.

Y - Drop c-like for loop? `for(x=0;x<100;x++)`
`loop(10)` means repeat 10 times
`loop(var i in x)` iterate over an array or keys of a hash, dont need to specify type of i as it can be inferred
`loop(var i in [x])` loop over keys inside the hashtable - not useful
`loop(var s in x[])`  iterate over values of hash - not useful
`loop(var x in range(0, 100, 2))` - 0, 2, 4, 8, ...
what about while?
`loop(x<0)`
`loop(x)` repeat x times
So the structure is: `loop(num)` or `loop(var)` or `loop(condition)` or `loop(var x in y)`

Y - If we add sum types, maybe we don't need the struct keyword at all.
`type pt := { x:int, y:int}`

Y - can we simplify type system more? For array and hash.
`type x := {x:int, y:int}`
`type array := {int^10}` is an array of 10 integers `array.0` will return the first item.
hashtable is actually an array of tuples (product type). so it is combination of sum and product type.
`type tuple := { key: string, value: int}`
`type population = tuple^10` an array of 10 tuples.
How to make this dynamic size? `x^`.
How to address? for hash we want to address using key (although addressing with index does not harm).
`type dyn_array := int^inf;` inf means infinity so it has a lot of space for data (as large as memory)
`type dyn_array := int^;`
`type population = {key: string, value: int}^`
`type rec = { string, int }` this definition does not have name. So we have to refer to fields using index.
`var s: string = rec1.0`
`x.0` means first item inside x. If it is a struct with name, this should also be possible.
`x.i` means i'th item.
`type population := {string, value}^`
`type point := {int * int}`
`type point := int * int`
`type point := (int, int)`
maybe we can eliminate braces and only use paren.
`type point := (x:int, y:int)`
`type scores := int^10`
`type scores := int^`
but having a dangling ^ at the end of line is not good looking. 
`type scores := int^@`
`type scores := int^!`
@ is better. We can say its a notation to represent dynamically resizable types.
`type point := (x: int, y:int)`
`var scores: int^@ - scores.0 = 12`
`var scores2: (string, int, int)^@` - this is an array of struct
`scores2.0.0 is a string`
`var scores3: (name: string, age: int, score: float)^@`
scores3.0.name is same as scores3.0.0 
we can also replace numbers used for indexing or accessing fields with variables.
`type population := (string, int)^@`
Then what will be the difference between array of struct and hashtable? 
Internally they are the same. only in hashtable we need indexing for fast access.
so `population.0` will refer to the first tuple inside the population array.
But how to say we want to address the tuple whose key is `0` not the first item?
`population.[0]`? Then we need a mechanism to define key.
`type population := (key:string, int)^@`
The key is a named field with the name `key`?
Or it can be the first item inside the tuple (note that it can also be a struct).
`type population := (key:string, int)^@`
Also we need to emphasis that key cannot be duplicate.
So we need a notation to say which field is a key (so it must be unique and will be used in addressing).
`var population: ([key]:string, int)^@ -- population["UK"] = 19; -- population.0.0 is key`
`var pop: (string, int)^@ where { index(0) }` on each change update internal index based on first field.
what if we use functions for set/get a hashtable?
`var pop: (string, int)^@`
`hash_put("uk", 5)`
`hash_put("us", 9)`
`hash_put("in", 19)`
`var size = hash_get("in")`
Basically we are using an array as a hashtable. 
`var pop: (string, int)^@ = hash_init()` this will initialize storage and config for hashtable.
What if `hash_put` receives an array which is not `hash_init`ed? it will throw an exception?
What if I want to write my own function dealing with hash? 
We are trying to have a powerful type system. Assigning such a task to a core function is not good.
Because in user functions we will have something like this which is not efficient:
`func process(pop: (string, int)^@ ) -> { assert is_hash(pop);}`
This is awkward and inefficient.
We have to have a notation for hash. Maybe something new.
`var pop: (string: int)` - no we are already using `:` for a very different purpose.
`var pop: (string -> int)` - confused with function
`var pop: (string % int)` - maybe
`var pop: (string % int)^@` - a hash is a special dynamic array after all. We have to include this in our notation.
`var pop: (string, int)^@`
Maybe we should not have hashtable as a built-in type. But literl hash is very useful.
`type hash := (string, int)^@ where is_unique($, 0)`
`var size = hash_get(hash1, "uk")`
`function hash_get(x:(any, any)^@)->any {} where { $ :: x.[] }`???
We also should review the notation to specify hash key/values with `::`.
`var pop: (string % int) -- var size = pop."uk" -- pop."us" = 100`
`var pop: (string % int, string) -- var size = pop."uk".0 -- pop."us" = (100, "A")`
`var pop: (string, int % int, string) -- var size = pop.(0,"uk").0 -- pop.(5, "us") = (100, "A")`
This seems reasonable.
so:
`var hash: (string, int % int, int, int)` to define a hashtable
`var pop: (string, int)^@` to define a dynamic array
`var pop: string^4` to define a static array - `pop.0 = 11, t=pop.1`
Can we use the C-like notation to address array and hash?
`pop[0] = 11; t=pop[1];`
`hash["A", 5] = (5, 1)`
It is more intuitive for people who already know C-like languages.
What about arrays definition?
`var pop: (string, int)[]` - dynamic array of tuples
`var pop: string[4]` - static array of string
Seems ok.
`if ( my_array :: int[] )`
`if ( my_array :: [] )` if it is an array
`if ( my_array :: (int, string)[] )`
`if ( my_hash :: (string % int) )`
`if ( my_hash[] :: int)` check type of values
`if ( [my_hash] :: string)` check type of key

Y - paren or braces for type definition? this only applies to struct and hash.
`var hash: (string, int % int, int, int)` to define a hashtable
`var point: (int, int)`
`var point: (x:int, y:int)`
`var point: {x:int, y:int}`
I think paren is ore intuitive with the way we call a function.
Also it can give developer ability to pass a struct when calling a function which has same fields as function input.
`func adder(x:int, y:int) -> ... var t = (1,5); adder(t)`

N - what is notation to clone? and instantiation?
`var x: (n: int, o:int) = (1,1)`
`y = x(o: 5);`
This is a bit confusing. X is a variable but is treated like a function.
`y = x with (o:19)` - a with b means copy a and apply b changes to it.
`y = x with z with p with n with (o:33)` - we can chain it. 
But this should be similar to instantiation.
`var y = Point(x:10) with (x:9)`
`var y = Point with (x:10) with (x:9)`
`var x: Point = (x:10, y:12)`
Maybe mentioning type is not necessary. If they have same fields then they are the same type.
Even an anonymous type can be a typed variable.
If you want type enforcement, mention the type.
`var y = x with ()` this is a clone of x
`var y = x` - y will point to x - so changing x will change y
this is another source of ambiguity. `x=5;y=x;x++` this will make y, 6 which is not expected.
Unless we change the notation of `=` to COPY data.
or say: `=` will copy for primitive (non tuple, non sum) types. or maybe we can say COPY happens only for number data type because it's length is pre-specified.
Cloning alone is not enough for us because cloned variable will be immutable so it will always be exactly same as the original.
`var p1: point(x:10, y:20)`
`var p2: p1(x: 19)` -- y will remain 20
`var p = func_call()` type can be inferred
`var g = (x:1, y:2)` in some cases type cannot be inferred.
`var g: MyType = (x:10, y:20)`
`var h = g with (x:199)`
`var h = MyType(g)` - but what if we want to clone anonymous (type-less) tuples?
`var g = h` this will copy the reference not the data
`var g = dup(x)` too long, should be simpler
`var g := h` - what about this? no. this is used to define types.
`var g = save_data(h)`
Maybe we can add a notation to make a copy. so: 
`var g = @h`
`var g = save_data(@h)` this is useless because save_data won' be able to change h.
or we can also do this manually:
`var g = (x:h.x, y:h.y)`
`var g = MyType(h.x, h.y)`
`var g = MyType(x:h.x, y:h.y)`
Or if it is too much code, user can write `clone` function for that type. But this is a convention not a rule.
summary in the next point.

Y - assignment operator will copy only for number data type. For anything else, reference will be copied.
There is no built-in clone operator. If you need it, write it yourself.

N - where should we put code to dispose a type?
`dispose` function? yes

N - if everything is immutable, how can we have dynamic array and hashtable?
If they are local variables, they are mutable. But function inputs are not mutable.

Y - The notation for casting is a bit un-intuitive.
`type Square := struct {...} as Shape = $.shape, as int = { return $.size + 5 }`
When we create a new `Square` we write: `var t = Square(x:10)`
So we treat type name as a function. When we want to cast something to `int` we write: `var t:int = int(my_string)`
So why not do this for custom types?
Write a function with the same name as type name. This can also be used as a constructor if it's inputs are exactly matching with the type fields.
For example to convert MyType to string, write this function: `func string(x: MyType))` and when someone writes: `var ggg = string(myType)`
In the same way we can write: `var g = int(myVar); var t = MyCustomer(myVar)`
Pro: Simple, consistent, extensible (You can write custom ctors)
Con: It is hard to find casting function for a type. Maybe we need to look into a lot of modules.
Problem: Type names and function names have different naming convention.
Maybe we should loose this requirement.

Y - simplify the language even more! what can we move to external libraries?
Optimize for debugging and maintenance.
Currently the most complex features are: templates, inheritance, polymorphism and dispatching, type constraints.
Templates provide static polymorphism.
can we replace polymorphism with union types?
q: (If you want to remove polymorphism) How can I extend an existing type and add behavior on top of it?
Let's keep poly. But without adding anything new. We just compose parent type. Add appropriate casting functions and that would be all. We can define functions for parent or child and at runtime, the appropriate function will be called.
And when a function for parent, is called with an instance of the child, and that function, calls another function which has two candidates for both parent and child, which one should be called? This depends on the casting. 
If it is a hard cast, the target, is really of destination type (Parent) so the second call will be redirected to a function for parent.
If it is a soft cast, then the result will still carry it's real type. This type cast is more like simulating a type rather than creating a new type. So in this case, a call to another function, will use the real type.
So hard cast string to int: result is int with type int.
Soft cast string to int: result is int with actual type string.
But doesn't this make it confusing? We will need a new notation.
And this means having data variables which can have more than one type. So:
`func do_work(x: int) -> { ...}` 
Inside do_work I expect an integer, but it can have other types too, which show themselves when I make a function call.
Can we model this with a data type? It will be more consistent and orth.
Like `bound` data type which is a tuple with a number of elements of different types which are bound together. It can be used in place of any of it's child types. But how can we handle modifications? If someone changes the `int` representation, what should happen to the `string` type? Answer is: we have only one piece of data + a number of "representations". So when we change, we change the single truth. But this cannot be true all the time. Can it be?
Example: We have string data and two functions. `first` and `second`. first is defined for int (which returns it's input), and second is defined for both int and string. If we call this: `second(first(string_var))` which version of `second` will be called?
string -> int -> call to second.
Providing with soft and hard cast, make it flexible for the developer. If it is a real type conversion, do hard cast. If it is for polymorphism and he wants it, do soft.
This should be handled in the casting function so it will be more flexible. But the notation should be simple.
As a result, this concept can be used anywhere else, not only in cast functions.
So inside `first` both `x :: int` and `x :: string` will return true.
so:
`func int(s: string) -> { ... }` you cannot define both soft and hard cast for a single conversion.
`func int(s:string) -> native_cast_int(s)` - this is a sample of hard casting
`func int(s:string) -> { return native_cast_int(s)`???
We want to say, when you want to cast ... (this is not restricted to casting).
So: We want to say, create a new data item of type X but add one more implicit type to it Y and return the result.
`return result ::: int` ?
But this is too flexible and so it will be confusing.
lt's limit this only to casting (a function with specific name, has only one input).
If we use a notation inside the function body, it should be possible to use it elsewhere. but we cannot decide on what a casting function should do. 
suppose that we defined this function, what would happen if the data changes?
`func int(s:string) -> ... ;; var g = int(mystring);g++;` what would happen to mystring?
we cannot permit limitless soft casting. 
soft casting is only possible when we do not create a new variable, but only return the original input or part of it. 
so can we make this transparent?
`func Shape(s: Square) -> s.shape;`
Is this going to be soft cast, all the time?
```
implicit func Shape(s: Square) -> s.shape;
func draw(s: Shape) -> prepare(s)...
func prepare(s: Shape) ...
func prepare(s: Square) ...
...
var mySquare = create_square();
draw(mySquare);
```
we should state if a cast function can be called implicitly. For example using `implicit` keyword.
Soft cast can only be done with implicit casting functions.
but maybe an implicit cast needs to be hard cast.
we have implicit/explicit and hard/soft cast.
explicit is always hard but implicit can be hard or soft.
`func Shape` is explicit and hard
`func Shape&` is implicit and hard
`func Shape&&` is implicit and soft
can we change the naming convention? data type names and function names be `my_data_type` and `my_func`: This is not good because it eliminates one factor of readable code.
They say implicit type conversion is not good, so it must be explicit which means name of the function is up to the developer so we don't need to pay attention to it at this level.
For implicit conversion, it is a special case, because it will return a member of the struct, so maybe we don't need to define a function for this. because it makes everything more complex. there are millions of possibilities in a function which we don't need. we just need `return this.memberX`. 
```
type Square := (s: Shape, size: int)`
```
The only case that I think is possible, is to use convention on the field name.
`type Square := (_s: Shape, size: int)`
`type Square := (_s_: Shape, size: int)`
`type Square := (implicit s: Shape, size: int)`
What if instead of embedding parent in child, we embed child in parent?
Can the whole thing be replaced another way? Even if this means writing some more lines of code?
Our goal is to have ability to re-use a pre-written code AND (?) represent a variable with multiple types.
Let's define an interface but on data not behavior.
So interface is a type and other types will be considered it's children if they have the same fields with the same name.
Then a function can accept the interface type and we can pass any other type that is a child of that type.
Can this replace polymorphim and give us code reuse?
`type Parent := (name: string)`
`type Child := (name: string, age: int)`
`func getName(p: Parent) ...`
`getName(my_child)`
Here `my_child` is an instance of `Child` but it will be passed to `getName` as a `Parent`.
if we have `getName(c: Child)` it will be called. Else `getName(Parent)` will be called -> code reuse
`type Employee := (name: string)`
`type Accountant := (name: string, age: int)`
`type Manager := (name: string, salary: long)`
Now an instance of Accountant or Manager can be cast to Employee easily. So we can have:
`var g:Employee[] = [createAccountant(), createManager()]`
`for(x in g) print(x)` appropriate print for Employee or Accountant or Manager will be called.
any method call on Child which does not have an implementation, will be redirected to methods written for parent. But even there, if they make a method call which is implemented both for child and parent, the one for the child should be called.
So if you write a method called `m` for Manager which has a candidate for Employee, and call `print` which is for employee, but with a manager, and inside the print, `m` is called, the one for manager will be called. 
Now, what about the ntoation? Should we just re-write parent's fields in the child? 
How to specify parent for a child? A new notation? A convention?
This means expand another struct and may have other uses. We want to explode a tuple.
`type person := (name: string, age:int)`
`func print(name: string, age: int) ...`
`print(my_person)` this won't work. Because print expects two inputs. BUT all of them with the same name and type are defined in person. So this is also done in python with * operator:
`print(*my_person)` - but this is done on the data level. We want to have it on type/definition level.
`type person := (name: string, age:int)`
`type manager := (salary: int, p: *person)` this will cause two things: fields of person will be exploded into manager definitio and they will be accessible either directly or through `p`. AND manager will be a sub-type of person. So it can be implicily casted to person.
Of course the `*` notation is general so it can be applied anywhere for data or types.
`var g: int[] = *my_three_int_tuple`
This is called unpacking in Python.
Of course if there is a conflict as a result of applying `*` there will be compiler errors.
So, we can have polymorphism which is easy and does not add a lot to the notation.
And for type unpacking, the name is optional. 
SUMMARY: 
To define an inheritance, just include parent structure inside child strucure with unpacking on it's type. You can even remove the name. For example: `type Child := (age: int, *parent)` This means all fields of parent structure will be unpacked inside the child and the child can be dynamically casted to parent if need be.
You can apply unpacking operator on data too: `var g: int[] = *my_three_int_tuple`
But if we can eliminate the name, is it possible to eliminate name for other fields too? No. So it shouldn't be allowed for this case.

Y - what does this mean? `type t:= (*int[])`
or `type t:=(x: *int)`.
`*` has no effect in this case. Same for value unpacking.

Y - What is the notation to instantiate a type?
`type Point := (x: int, y:int)`
`var x = Point(1, 9)` or `var x = Point(x:1, y:9)`
This is using a type like a function.
We don't support custom ctor. If users needs one, he can add a function and call it.
`var x: Point = (1, 9)` or `var x: Point = (x:1, y:9)`
This is better because there is no confusion between type name and function names.
So, we don't have a special syntax to instantiate. We just create an anonymous tuple and set the type.
What if we want to instantiate without setting values? assign to `()`

Y - How to clone? We can use explode operator.
`var x: Point = (*original_var)`

Y - remove all occurences of struct

Y - mentioning name (for inheritance) should not be possible because then `*x` will do two things.

Y - Naming convention: `myFunction`, `MyDataType`, `my_var_name`, `my_module`.

================end of v 0.8====================

Y - explode can even be used to define function input or output. Anywhere you want to define a tuple.
Calling explode for a sum type will just paste it's contents.

Y - should we ban unnamed fields? what about unnamed function inputs? No they should be allowed.
At least we need them for function output. So tuples with unnamed fields should be allowed.
So data types or function inputs without name should be allowed.

Y - state the way to define body-less functions. used to simulate interfaces.

N - What about generics? Do we need them? yes.
Applications of generics: Sort, Algorithms, Data structure.
Algorithm: They can accept the general case type (`sort(c: Comparable[])`).
For data structure: We provide basic structures like hash-map and array. For others: write your own code.
For example a set: it is an array with some conditions.
`type Set := []` -> `var g: int[Set]` - we want a notation which can be used to "customize" an array or hash but keep their original notation.
`type Set := (`
`var g: int[] `
Why can't we use constraints?
`var g: int[] where { is_set }`
`type Set := int[]`
`type IntSet := int[]`
We need an array or hash with their own methods. So user cannot simply insert or remove something without calling those methods. we can show a set as a map: `var my_set: bool[string]`
Data structures are data with special behavior. But we are keeping these two separate. Because of that, it is difficult to define advanced data structure here.
we can use constraints.
`type TreeNode := any`
`type Tree := (left: Tree, right: Tree, value: any)`
`var myTree: Tree where { $.value :: int }`
`func addAll(x: Tree where { $.value :: int})`...
This seems fine and simple.

Y - `*` is used both for multiplication and unpacking.
Maybe we should use `@`.

N - review map function.
```
type mapInput := any
type mapOutput := any
func map(f: func(mapInput) -> mapOutput, arr: mapInput[]) -> mapOutput[] where { mapInput :: mapOutput }
//these calls are all the same
new_array = map({$+1}, my_array)
new_array = map({$+1}, my_array)
new_array = map {$+1}, my_array
```

Y - What about this? `var x,y,z = *my_int_array`. Like Python
And how can we ignore the rest of explode output?
`var x, ??, z = (1, 6, 5, 1, 11, 21)` x will be 1 and z will be 21
Like Go we can use `_`. This is used only for explode operator on data.

Y - How explode handles the case where there is name mismatch?
`func add(x: int, y:int) ...`
`var h = (t:10, u:20)`
`add(@h)` ?
It should fail. because function states it needs inputs with that specific names (this is a contract).
In other words: How can we make a tuple with unnamed fields?
We want to convert `(x:10, y:20)` to `(10, 20)`.
`var h = (t:10, u:20)`
`var g = @h` -- wrong, right side is two variables, left side is one
`var g,h=@h` -- correct
`var g:(int, int) = @h` -- can we assign a named exploded tuple to an unnamed tuple?
`var g:(int, int) = (x:10, y:20)` this should be possible.
So, can we pass an unnamed tuple for a function input which has named? Yes. But:
`var g: (x: int, y:int) = (t:10, h:20)` what about this?
`@x` will not create a tuple by itself. You have to enclose it in `()`.
We can use `x.@` to denote a list of values inside the `x` tuple.
`var g: @point` is same as `var g: x:int, y:int` so its wrong
`var g: (@point)` is correct.
`var g = @mypoint` is same as `var g = x:10, y:20` so it's wrong.
`var g, _ = @mypoint` is correct.
So, we can compose `@` with others.
`var g = (my_point.@)` is same as `var g = (10, 20)`
`var g = (@my_point, z:20)`. g will be `(x:10, y:20, z:20)`
`@my_point` will translate to `x:10, y:20`
`my_point.@` will translate to `10, 20`
`@MyType` will translate to `x:int, y:int`
`MyType.@` will translate to `int, int`
`var x = (@my_var)` will clone the variable.

N - can't we use `MyData` instead of `@MyData`?
Applications of @: clone, call function with a tuple, inheritance.
Allowing `MyData` means having named and unnamed fields inside a tuple.
`type x := (MyData, x:int)` here `MyData` is an unnamed field.

N - Allow `*int` so tuple inherits from int.
But this means to be an int: `type Point := int`

N - review notation for lambdas.

N - What do we need to support rpc? We need to call a method by name and return it's output in a general format.
in go: `err = client.Call("Arith.Multiply", args, &reply)`
Suppose that a Python code wants to call one of my functions. It has no way except passing method name.
But in server side, I can register them with names:
`rpcRegister("Update", myUpdateFunc)`
in Python: `result = server.call("Update", 1, 8, "A")`
Then what is the definition for `rpcRegister`?
`func rpcRegister(name: string, f: func(input: any)->any)->...`
We possibly store these in a map.
Then inside the server when we want to call func:
`var fn = map[name]`
`var result = fn(input)`
How do we convert an array of inputs to function input?
`func receiveCall(name: string, inputs: any[]) -> { var fn = map[name]; return fn(?) }`
We need to convert an array to a tuple with unnamed fields.
`var g=[1,2,3]` we want to have (1,2,3).
we can do this with a map: 
`output = map (x: any, tuple: any) -> (x, tuple.@), g`

Y - Also notation to access tuple values when it is unnamed.
`var t : (int, string) = (1, "A")`
`var number_one = t.0` dot notation makes more sense.

Y - Add helper functions to detect type of variable: `type tuple := any where { is_tuple }`
We want to have `any` but it must be a tuple or an array or ... . How?
`::` is used to check exact type. `x :: int[]` or `y :: Point`
But what if I want to have a tuple or an array of any type?
`x :: any[]` will return true for any array
`x :: (any)` will return true for any tuple
Line 397
`x :: []` check for any array
`x :: ()` check for any tuple
`x :: %` check for any hashtable
`x :: int[]` check for array of specific type
`x :: int%` check for hash of specific key
`x :: %int` check for hash of specific value

Y - Why notation for hashtable should be the same as notation for array?
`var ht: int[string]`
`var str1 = h[10]`
`var ht: int%string`
`var str1 = ht%"mydata"`

Y - the notation of hash combined with string seems not very good.
`hash1%"B" = 19`
`hash1"B" = 19`
Maybe we should use functions for this, instead of adding a new notation:
`set(hash1, "B", 19)`
`var t = get(hash1, "B")`
But I prefer language to be expressive.
`hash1:"B" = 19`
`hash1?"B" = 19`
`hash1 += "B":19`
`hash1 += "B":19`
`hash1."B"`
`hash1{"B"}`
`hash1/"B"/`
`hash1<"B">`
`hash1 "B" -> `
`hash1{"B":5}` set
`hash1{"B"}` get
The notation to define hashmap type and it's values (read/write) and literals should be consistent and make sense. 
definition `var hash1: string : int`
set `hash1{"A" -> 5}`
get `hash1{"A"}`
literal `hash1 = {"A" -> 5}`
Maybe we should use `=>` notation and use another symbol for chaining.
definition `var hash1: string => int`
literal `hash1 = {"A" => 5}`
set `hash1{"A"} = 5`
get `hash1{"A"}`
we can use `:>` and `:<` for chaining.

N - All variables are immutable but can be re-assigned? What about local variables?
Can I pass a read/write reference to a function?
You can pass a function reference which changes the value:
```
var g = [1,2,3]
do_work(g, func(index: int, value: int) -> g[index]= value)
;OR
do_work(g, { g[$1]= $2 })
```

N - can we make use of `//` now? No.

Y - how to clone an array or hash?
`var a = [1,2,3]`
`var b = [@a]`
`var h = string => int = {"A"=>1, "B"=>2}`
`var g = {@h}`

Y - where is used for type constraint, pre-cond, post-cond and catch exceptions.
It is too much. OTOH we use `assert` only to validate and throw.
Maybe we should simplify our notation for exception handling. We now have sum type.
Any function that has an assert or where clause or calls another such function, has potential to throw exceptions.
`func add(x: int, y:int) -> int { ...}` this can return either an `int` or an error.
`func add(x: int, y:int) -> int|Exception { ...}`
`var g: int = add(5,6)` - what if this returns an Exception? 
`assert` is underlying exception throwing mechanism (where is using this behind the scene).
and it is shortcut for: `if (!condition) return exception` - but for clarity and generality, we don't allow code to return exception directly. instead of writing `return exception` you must write `assert false`.
`var g: int = add(5,6) # {...}` the second block will run if function output has an exception.
Can we make this general? If function `f` is returning `A | B | C | D` we want to have different cases for each return type.
```
var g = switch(f(a,b,c)) { 
  case x:int -> x 
  case y:exception -> ...
}
```
So for every function call which is potential to exception, this can be done.
Exception is nothing more than a tuple with useful information.
The only rule is you cannot instantiate it directly. You must use `assert`.
So every potential function has a `| exception` attached to it's output type, behind the scene.
If we allow users to create instances of `exception` then we won't need anything special for exception handling and catch.
throw exception: `return exception(1,2,3)`
catch exception: switch and case.
For throw, we already have `assert` as a helper, not a shortcut.
for catching, we can define a shortcut.
`func func1() -> int { ... }`
`var g: int = func1() // { ... }`
we put a code block which will either return from function or set an appropriate value for `g` of correct type.
But how to get the exception? We remove the sum type notation because it needs a lot of exceptions.
throw exception: `assert false`
catch exception: `//` - if function is potential and there is no `//` after its call and throws exception, we will just jump outside.
How to get exception?
`var g: int = func1() // { ... }`
1. functions
2. global variable or symbol which is read-only.
What if I accept the exception?
`var g: int|exception = func1()`
This is totally fine and will work.
Now how can we simplify this and make language more expressive?
We can make `//` more useful.
`var a: int|string=func1()`
`var b: int = a // 0`
`//` is used in conjunction with sum types to act as a shortcut for `switch`. `x = A // B` if x type does not match with A then B will be evaluated to get a result of type of x. Inside `B` we can refer to result of `A` using `$` notation.

Y - notation for case in switch is same as function call. change it.
```
  result = switch ( my_tree ) {
    case Empty 0
    case y:int -> 1
    case z:NormalTree -> ...
  }
```

N - show we ban `void` functions?
This does not affect the `//` notation for exception handling. Even if function does not return anything, we can write:
`func1(1,2,3) // `?

N - can input of a function be a sum type?
`fn add(x: int|string) -> { ... }` yes.

N - can we use Traits as a replacement for inheritance and polymorphism and method dispatch?
https://blog.rust-lang.org/2015/05/11/traits.html
It does not change anything. 

N - I think, dynamic dispatch should happen even if we are calling a function pointer.
```
draw(Shape)
draw(Circle)
var f: func(Shape) = draw;
f(my_circle)
```
This should call `draw(Circle)` even though type of `f` is `func(Shape)`.

Y - enforce naming and order in the source code file or else compiler will give warnings.

N - simplify the language even more! 
what can we move to external libraries?
Optimize for debugging and maintenance.
Currently the most complex features are: type constraints.

N - e.g. writing regex to parse and execute each line:
`w arg+ -> invoke w with arg+`
`x'['y']' -> get_index`
`x'{'y'}' -> get_hash`
This is too ambitious and keeping gen and orth while having this is difficult and make language complex.

N - Can we remove `::` operator and change the way template works?
```
type Stack := any[];
func push(s: Stack, i: any)...
func pop(s: Stack) -> any ...
```

Y - in order to indicate type A behaves as interface I, in golang, you only need to write appropriate methods.
can we have this here?
So for example the `Comparable` type does not have any member and has only one function. If I have a `Circle` and a `Comparable` function for it, can I pass an instance of `Circle` instead of `Comparable`?
I should be able to do that. 

Y - enforcing a set of functions for a type is not straightforward.
In Golang they use interface but it has a boundary and limit in the code.
Here we use types and their functions can be defined anywhere. It is a good thing and bad thing.
What if we have: 
`type Alpha`
`func f(x: Alpha)->float`
`type Customer := ( ... )`
And `f` is not implemented for `Customer`?
And we call `f(myCustomer)`.
This will depend on how `f` is implemented. If it has a body, it will be called. If not, compiler error.

Y - Is this correct?
`var x: Car   ;init x with all default values`

Y - We cannot check `::` at compile time all the time. 
`func f(x:any where { $::Circle })...`
If we send a Shape to f, compiler cannot check it's dynamic type.
And templates which are applied at runtime are not useful (suppose getting a runtime error about sending string to an int stack).
first of all, `::` is applicable only to `any`.
For template, we don't really care the type of the data. We want types to match with other types.
```
type Stack := any[];
func push(s: Stack, i: any) where { s :: i[] } ...
func pop(s: Stack) -> any ...
```
And by the way, ` s:: i[]` is not readable at all. 
```
template(Stack(T)) 
{
  type Stack_T := T[];
  func push(s: Stack_T, i: T) ...
  func pop(s: Stack_T) -> T ...
}
```
Why not use interface types?
```
type storable

type Stack := storable[]
func push(s: Stack, i: storable) ...
func pop(s: Stack) -> storable ...
```
In this way, we can get rid of `where ::`.
Maybe we can also remove `::` and `any`. 
Or maybe we can just move `any` to core: `type any`
So it will not be anything special. Any type (even primitives) is an `any`.
What about `::`? It was introduced to make template implementation easy. But now, we can replace it with core functions.
`type(x)`
If anyone needs it they can use it. 
What about map?
`type mapTarget`
`func map(f: func(mapTarget) -> mapTarget, arr: mapTarget[]) -> mapTarget[]`
We can enforce same type constraints, simply by using types. Like above. `mapTarget` is basically same as `any`.
`func f(x: any=>any) {...}` inside f I want to check if hash keys are int or float.
How can I get type of keys or values of a hash? We can simply add appropriate functions to core: `typeOfHashKey`.


Y - can we simplify `switch` more?
```
  result = match ( my_tree ) 
  {
    5 -> 11,
    "A" -> 19,
    local_var -> 22, ;check equality with a local variable's value
    Empty -> 0,
    y:int -> 1,
    z:NormalTree -> { return 1+z },
    any -> { -1 } ;this is default because it matches with anything
  }
```
We use match for type matching and switch for data matching.
Each part of match is a lambda expression without `func` keyword. In match you can use any type and the lambda which matches with that type as input, will be executed.

Y - What if we allow functions to specify literals as inputs too? So we can use match instead of switch.
`func fixed(5:int) -> 9` 
`func fixed(5) -> 9` 
`func fixed(x:int) -> x+1` 
So calling `fixed(5)` will give you 9 but `fixed(7)` will give you 8.
Calling `fixed(g)` will call one of two above definitions based on the value of g.
This will help the notation for match with fixed values, make more sense.

Y - `=>` is used both for chaining and hash!
Also `ht{"A"}` is a bit clumsy.
`=>` notation is readable and intuitive.
`var hash1: string => int`
`hash1 = ['OH' => 12, 'CA' => 33]`
`hash1["B"] = 19`
Let's use `=>` for hash and hash literals and use `==>` for chaining.

Y - just like match, make if an expression too.
`val max = (x: Int, y: Int) => if (x > y) x else y`

N - swap `=>` and `->`? To be more like Scala? `->` is used in Swift and Haskell for function notation.
`=>` implies some kind of assignment but `->` denotes a transformation.
So I think current status is better.

Y - can we make `if` a special case of `match`?
```
  result = match ( my_tree ) 
  {
    true -> 11,
    any -> { -1 } 
  }
```

N - can we use tuple for AND condition and sum type for OR condition and remove those operators?
`if ( a, b, c ) then ... else ....`
```
match reduce(both_true, [@(a, b, c)]) {
  true -> ...
  any -> ...
}
```
A tuple will be matched to boolean true if all of it's elements are true else it is false.
A sum type will be casted to true if any of it's elements are true. else false.
This is a matter of casting. We define `if` as an appropriate syntax sugar.
`func bool(x,y)`
`func bool(x|y)`

Y - for generality function we should also accept other types like sum or primitively . Not only tuple. This is complex but is the generality. But the convention is to enclose it inside paren.
So it you want to pass a tuple as inputs, you have to explode it.

Y - Also function input can include literals too. So (5,x:int) matches with (y,s) if y=5

N - It does not make sense to explode a type as an array because it's data might not be of the same type.
It makes sense because it gives us generality. 

Y - When calling a function, if a single call is being made, you can omit `()`. So instead of `int x = f(1,2,3);` you can write `int x = f 1,2,3;`.
This is mostly used for map and similar functions. But it's not good. We don't want to have exceptions and special cases.

Y - If function can have multiple inputs, how can we model `map` or any function that accepts a general input?
`func map(f: func(mapInput) -> mapTarget, arr: mapInput[]) -> mapTarget[]`
option 1: use `any` to denote this
But if we can make this more orth and gen is better.
option 2: declare that function must accept a tuple. inside that tuple you can define whatever you want. And that explains why all function definition and calls must have parens.
```
func f(x:int, y:int) -> ...
...
var g = (x:10, y:12)
f(g) ; is this correct? no
f(1,9)
f(x:1, y:9)
f(@g)
```

Y - state that match operator is the same way we find function to call. 
`match (5, x) { (5,9) -> ...`

N - Any easier way for sub typing? Rather than explode. Maybe then we can remove this operator.
Explode does two separate things now: explode and indicate subtyping.
applications of explode: Make it easy to call a function, cloning,

Y - can we generalize if/match/loop with tuples because they have parens?
then maybe we can define loop/match/if as native functions.
`if(condition) lambda`
`match(tuple) list of lambda`
`loop(condition) lambda`
`loop(tuple) lambda`
`loop(num) lambda`
We can say, loop accepts a tuple (which can have n elements). And ANDs them all.
Each element can use `and` and `or` operators.
So loop and if can be modeled as a function.
But then we will need to use comma for lambda:
`if(condition, lambda)`
`if(x>0, {print(x)})`
`if x>0 {print(x)}`
`if(x>0) { print(x)}`
`add(5,6)`
`add(5) 6`
what about else?
`if(x>0) { print(x)} else { write(x) }`
loop can accept either a number of a lambda for it's condition.
`type anyHash := any => any`
`func loop(cond: int | any[] | anyHash | func(any)->bool, body: func(x:any)->loopOutput)->loopOutput`
`loop(5) { print('hello') }`
`loop(x>0) { print('hello') }`
`loop(arr1) { print($) }`
`loop(arr1, { print($) })`
`func map(arr: mapInput[], f: func(mapInput) -> mapTarget) -> mapTarget[]`
`x= map(arr) { $+1 }`
`x= map(arr, { $+1 })`
> If last input of function is a lambda, it can be put outside paren when calling it.
What about loop for iteration? 
Problem is: We may need to bind a variable to the iteration value.
`loop(arr1) { print($) }` - this is not really readable
Advantage: We can define iteration for our own type. Then people can use `loop` to iterate over anything we want. Like implementation of custom iterator.
`loop(arr1) { print($) }`
If you want custom name, define a more complete lambda:
`loop(arr1) (x: int) -> { print(x) }`
break and continue can also be handled using exceptions.

N - if we want to say a function can accept anything what should be the notation?
`func x(any)`?
`type anyHash := any => any`
`type anyPrimitive := int | float | string ...`
`type anyTuple := any`
It does not make sense to have a function that can accept any number of inputs each of them having any type.

Y - Now that `->` is only used for functions, maybe we can eliminate `func` for lambdas

Y - better formization of void. Maybe unit? It is a normal type which has only one value:
`type void := void`
And compiler helps to change `return` to `return void`

N - Polymorphism in just a way to customise matching when specific functions are being called.
Maybe it can be achieved without a special syntax.
```
type Shape := (...)
type Square := (*Shape...)
type Circle := (*Shape...)
match Square with Shape
```
I think when a function needs a `Shape` it needs something that `.size` and `.x` and `.y` are applicable to.
So this is something like duck typing in Go: When a type has appropriate functions, it has implemented an interface automatically.
Here: When a type has appropriate fields, it has subtyped from it automatically.

N - Const?
`func PI -> 3.1415`

Y - declare that map can work on anything as long as they have support for `loop`. So its not only for arrays.

N - can we get rid of `any`? It's not anything special. Just a definition in core.

Y - clarify about optional values and literal inputs.
`func add(x:int, y:int, z:int) ...`
`func add(x:int=15, y:int, z:int) ...`
`func add(x:int, y:int, z:int=9)...`
call:
`add(x,y)` will call 3rd version
`add(15, y)` will call 3rd version
`add(15, y, z)` where z is not 9, will call 2nd version
in function definition giving value to a parameters, means it should be exactly equal to that value or it should be missing.
order of match: for (a,b,c) tuple when calling function:
Functions with that name which have 3 or more inputs will be tested.
- Functions with exactly 3 inputs have higher priorirty than those with 3+ inputs with optional values.
- Functions with higher input value equal to values of a, b, c have higher priority.
So, first search for funcciont with 3 inputs then 4 input with last one optional, then 5 inputs ...
In each case, first check functions that have all 3 pre-set, then 2 pre-set then 1-preset then no pre-set.
If in each step, two cancidates are found, give error.
For example:
`func add(x:int=9, y:int)`
`func add(x:int, y:10)`
calling `add(9, 10)` will result in two candidates -> runtime error.
if input is unnamed then ok. If it is named, we have an extra condition: input names must match.
and `(x:10, y:20)` will match `(x:int)` which is foundation of subtyping.

Y - the exception to separate last arg if it is lambda, can we make it more general?
For example, you can write tuple `(a,b,c)` as `a b c` if ????
`var x: Point = 1 2`
Of course this is acceptable only if there is no conflict.
`func add(x:int, y:int)`
`add 5 6`
Like Perl function call.
But this will make code "un-readable".
`map(my_array, { $ + 1 })`
`loop({x>0}, { x++})` this is not expressive and is not readable.
`loop {x>0} {x++}`
We can add a compiler trick here:
Types of loop: int, iteratable, lambda - then body is a lambda.
`loop(5) { lambda}`
`loop(array) { lambda }`
`loop({lambda}) {lamda}`
To make third case cleaner we can add compiler syntax sugar `while`:
`while (X) { lambda }` means `loop({X}) { lambda }`
But I don't like to add new words to remember.
`loop({x<100}, {x++})`
```
match ( { cond } ) {
true -> { lambda },
false -> { return }
}
```
But how to signal a `repeat`?
`loop` cannot be a normal function. It must be native and built-in. But it can be overriden for specific types and the override code can use the internal one.
Maybe we should stop supporting loop with condition. And make `loop` like `if/else` a compiler syntax sugar which maps to match. But how to signal a repeat?
Another solution: Like Haskell, use recursive functions and available map/fold/reduce/... functions.
`loop(5) f()` -> `(x:int) -> { if ( x == 0 ) return; f(); $$(x-1)}`
`for(int x=0;x<100;x++)` 
we have 3 types of loops: counted `loop(10)`, predicated `while(cond) f()` and iteration `for(x: array) ...`
The third one can be easily done via map and other functions:
`for(x:array) f()` -> `map(x) f()`
the first one is a special case of the second one:
`loop(10)` -> `while(x<10) { f();x++; }`
The second one is the main one.
`while(cond) f()`
maybe we can use match or add cmatch for continuous match.
`match (tuple ) { a -> code, b-> code }`
we can have `loop` keyword to repeat a block infinitely. then finish the loop using break.
`loop match(tuple) { ... break ... }`
its not readable.
infinite loop: a function which calls itself.
`match ( true ) { true -> code }` this is infinite loop if it is continuous.
`loop ( pred ) { 
  true -> { f() },
  false -> break
}`
`loop match ( pred ) { 
  true -> { f() },
  false -> break
}`
Why not `loop` primitive which is not based on any other thing?
`loop(count) ...`
`loop(pred) ...`
`loop(x:array) ...`
`loop(t: hash) ...`
what if we want to have a custom iterator over an object? 
we need loop to be a function. but how are we going to implement it? one way is to have just a `forever`-like keyword and exceptions. continue -> return, break -> throw exception.
```
func loop(x: int, lambda) -> { 
  var i: int = x
  match { 
    lambda
    x--
    if ( x == 0 ) return exception
  } {
    exception -> return,
    any -> repeat ;or we can say, if there is no match, it will be executed again
  }
}
func loop(pred: lambda, body: lambda) -> {
  match (
  x = match (pred) {
    false -> false,
    true -> body, true
  }
  ) {
    false -> return
  }
}
```
- maybe we should make match syntax more readable
- if condition is not satisfied then repeat is a bit implicit and not readable. we should add a keyword for that.
so inside match we can have `return` which returns from current function.
`repeat` to re-evaluate match.
```
func loop(x: int, lambda) -> { 
  var i: int = x
  match (x)
  {
    0 -> return,
    any --> { x--; body; } ;maybe we can say --> means run and repeat
  }
}

func loop(pred: lambda, body: lambda) -> {
  match (pred) 
  {
    true --> body
  }
}

func loop(a: array, body: lambda) -> {
  var iterator = getIterator(a)
  match (has_next(iterator)) 
  {
    true --> body(get(iterator))
  }
}
```

Y - How can we make match a real expression?
How can we signal from inside the body, a vaue? with return?
Then how to really return from parent method?
```
  result = match ( x ) 
  {
    1 -> { body },
    2 -> { body },
  }
  ;You can shorten this definition in one line:
  result = match (my_tree) 5 -> 11, 6-> 12, Empty -> 0, any -> -1
```
break -> return inside case body
continue -> return inside case body but with a repeat
result of a match expression is the data in the last return executed.

N - can we use `-->` notation for function definition too? NO! it does not make any sense.

Y - having multiple statements in a single line can make code readable sometimes.
so we need something like `;` but gen. if we always need it then we should need it for blocks too.
can we use `==>`?
`doThis ==> doThat`
This should be possible.

N - Change comment starter? 
We don't need semicolon to separate statements. We have chain operator.

Y - can we have a more beautiful notation for chaining?
`x ==> f`
a two character notation.
`get_evens(data) >> sort(3, 4, $_) >> save >> reverse($_, 5)`
We can also use bash pipe: `|` but this is left to right chain. 
we can also have an operator for "chain if successfull"

Y - How can we put multiple statements in one line?
chaining is not good because its not designed for this.
`|`?
`&`?
`x++ & body`

Y - result of a match is the only return statement that we have or `none`
What if it is a loop?
```
func loop(x: int, lambda) -> { 
  var i: int = x
  return match (x)
  {
    0 -> return,
    any --> { x-- & body } 
  }
}
```

? - What if there is conflicts because of type constraints when calling a function?
`func add(x: int where { $>=0 })...`
`func add(x: int where { $<0})...`
What happens if I call `add(10)`? Compiler/runtime error or just call appropriate function?
If we want to evaluate all those checks, they might have some unwanted side effects.
The correct behavior is to check them too.
But maybe we should just remove them and only allow `where` for function pre and post condition.
Currently `where` is used for type constraint and making local variables constant.

