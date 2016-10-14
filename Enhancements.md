#Enhancement Proposals - Part 2

Read [Part1] (https://github.com/mm-binary/electron-lang/blob/master/backup/EEP.v1.md).

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

\* - how can we mock a method? in a general way. so it won't be limited to testing. 
we can easily define a lambda to mock a method. but how to attach it to that method?
there is no manager, parent to accept this lambda.
proposal: built-in method: `mock('myMethod', <<lambda>>);`
to do mocking in the life-time of the current function. 

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
`proto fib (|) is cached returns NonNegativeInt {*}`
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
3. Optionals. starting with `_` may ne confusing.
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

? - TEST: think about how to implement a pricing engine/vol-surface/economic events and contract object in new approach.
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

var probability: float[$>=0 and $<=1] = 0;

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
