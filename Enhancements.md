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

? - using `$$` instead of `$_` for constraints.
still for chaining, we will use `$_`.

? - add a shortcut instead of either. because sometimes number of fields is high and its not good to repeat all of them.
`[union($$)]`

? - suffix syntax for if and for
`x++ for(10);`

? - think about how to implement a pricing engine/vol-surface/economic events and contract object in new approach.
economic_events:
```
//assuming we have primitives
type DateTime := struct {
  year: int;
  month: int;
  day: int;
  hour: int;
  minute: int;
};

type Currency := struct 
{
  USD: bool;
  EUR: bool;
  JPY: bool;
  GBP: bool;
} [union($$)];

type Event := struct 
{ 
  source: string;
  release_date: DateTime;
  title: string;
  currency: Currency;
  impact: int [$$>0 and $$<5];
};

type List<T> := struct {
  head: T;
  tail: T;
};

func ([])(List<T> list, index: int) -> T {
  T temp = list.head;
  temp = temp.next for(index);
  return temp;
}


```
