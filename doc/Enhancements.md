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

\* - For core - function to return hash representing a struct, used for serialization, and what about deser?
`string[object] result = serialize(myObj);`

N - now that function cannot modify input, how can we implement stack push or pop? (maybe we can return a lambda which is supposed to to the modification, and caller has to invoke it)?
solution1: let developer decide whether some variable will be immutable or mutable. so if type is mutable, function can modify the input.
immutability will make testing harder. but makes developer's life easier. Because he doesn't need to write lots of code and use shortcuts to do some ordinary task. if we have mutability, caching decision will become harder and more complicated.
`var y = x{item1=10, item2=x.item2+10, ...}`
how am I going to add something to a list?
`ls = ls.add(x);`
`var ls: list!Customer`

\* - Runtime - use concept of c++ smart ptr to eliminate GC

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

Y - add `val` so variables declared with val cannot be re-assigned.
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

? - maybe we can eliminate polymorphism.
`type Shape := struct;`
`type Circle := struct {x:Shape...}`
`type Square := struct {x: Shape...}`
`func paint(o:Shape) {}`
`func paint(o:Circle)...`
`func paint(o:Square)...`
Why do we need paint for shape?

N - protocol
Clojure has protocol similar to interface. Then when defining a new type, it can be used to define API.
but we still need inheritance to have code re-use.
```
type drawable := protocol {
   draw(this) -> long;
   stats(this, int[]) -> string;
};
```


? - we need to explicitly define which contained elements in a struct are to be inherited and used in polymorphic situations. Else there can be unwanted consequences.
`type x: struct { a: int; }`
x can be used as an integer without us wanting that. If we call a method that accepts an integer with an x instance, compiler won't complain.

? - some idea for organizing: refer to everything inside a module (file) using module name prefix.
you can alias when doing import or import local so you don't need prefix.


