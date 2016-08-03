#Enhancement Proposals

N - should we have something like `Object` in Java or `void*` in C++? So that we can implement a `printf` method. Maybe we can somehow mis-use `auto` keywords for this. `int func(auto x, auto y)`. We can easily implement printf with String interpolation.

N - Support for concurrency built into the language
```
future<String> f = promise { ... }, { ... };  //plan to run first block in parallel, when done, run the second block
promise& class1.func1();  //run the statement in another co-routine at the moment
future<String> f1 = promise class1.func1(1, 2, 3);  //wait for call of invoke
future<String> f2 = promise { return "a"; };
f1.invoke();
f1.setCallback(...);
f1.cancel();
String result = f1.get();
```
This can be easily achieved by using std and anonymous function. Why add a new keyword?

Y - ternary operator is very messy but very useful (`a ? b:c`). Is there a way to make use of it in the language? Maybe:
`if a then b else c` or `b if a else c`. We only want to evaluate `c` if `b` is `FALSE` so this cannot be done with a library function. Another option: `iif(a, b, c)`.

N - Support for atomic operations in language level? This can be achieved using `core` so better not to add a new keyword/compiler feature for this.

N - Operators for regex? find/match/substitute? No. This is possible using core.
    `bool b = str =~ 'pattern'`

N - map/reduce/filter, arri implements a specific interface. will be done in core.
    arr2 = arr1.map<T>(x -> x+1);
    arr2 = arr1.filter(x -> x>0);
    arr2 = arr1.reduce((x,y) -> x+y);

N - serialization/deserialization: Better to be done in core
    `String x = core.ser.Serialize<obj>(obj1);`
    `obj r = core.ser.Deserialize<obj>(x);`
    
N - join/fork
    fork: using core,
    join: in future class
    
N - compare and swap, only for numbers
    `bool b = (x ? 1 -> 2);`

Y - Hash notation, like array with support for hash literals
    `int[String] hash1 = { "OH" => 12, "CA" => 33, ... };`
    behind the scene this will be a class.

N - Tuple data type. We have this in C++, C#, D and Java (to some extent). This cannot be implemented using templates because read/write value to the tuple does not have a specific data type.
    `tuple<int, name1, String, name2, float, name3> t = { 12, "Hello", 3.14 };`
    `int x = t.name1;`
    if we add support for identifier to templates, it is possible to implement tuple.

N - immutability for functions. Like C++ `const` we define a function as const which means it cannot change state of the object. These functions can only call other `const` functions. 
Go and Java and C# don't have this. Also we can have this by declaring fields of the class as final. 

N - Channels like golang. These can be easily implemented using templates and std lib. 

Y - null coalescing operator (`x = a ?? b` means `x = a` if a is not null, else `x = b`)

N - Functions cannot modify their input values, so why not send everything by reference? Because of the overhead of de-referencing.
