#Enhancement Proposals

Note: Y = Approved, N = Rejected/Clarified, \* = On Hold

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
    `int[String] hash1 = { 'OH' => 12, 'CA' => 33, ... };`
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

Y - Simpler switch: If case body is big, it's better to use if. If it's small we can use this:
```
switch(x)
{
    1: return 1; //if block is just one line, you can omit brces
    2: { return 2; }
    3: { return 3; }
    4, 5: x++;
    _: { return 0; }  //default
}
```
This will remove `case` and `default` keywords. 

N - Omit parantheses from if/for/switch. This will decrease code readbility. 

N - Add annotation for documentation of a method or class or interface: `@doc('dsdsadsad')`

Y - Calling methods (including constructor) by providing parameter names: `x.setData(name: 'start', value: 10);`. This will make code more readable without adding much complexity. 

N - Remove braces, like Python (We may also need to decide about notation to define anonymous functions).
    It's a bad idea to have language's semantics rely on invisible characters. Go doesn't do this.

N - Remove void keyword. No, explicit is better than implicit. `int f1() { ...}; f2() { ... }` they are same thing but seem different because of removal of void.

N - remove semicolon from end of lines. Go and Python don't have this.

N - Remove sub-package concept. We only have a set of packages. This is what golang does / But hierarchy is the key to handle the complexity. Also we don't have such a concept, it's just a feature. 

\* - How should we specify version number of a package? How should we address the version of a dependency? Later for package/build manager compoennt this will be decided.

\* - How can we define assertion and other directives in interface methods?

\* - Conventions to define unit tests in the code? How to define startup and finalization methods? Define test data input table and expected output?

Y - No annotations? Configuration should not be part of the code, and most of the time they can be replaced with good design patterns like decorator or ....

N - We expect all `import` statements be grouped together. So why not merge them all like go?

\* - Disable sending param values as another template type to a template: `auto x = tuple<tuple<tuple<int, ivar>...`
Values for template parameters should be either one of primitive types or a simple class name. Later to be decided.

N - Remove template and generic code? Everybody seems complaining about them in other languages. No. We have relied heavily on this (tuple, map/reduce, ...). We just make sure this will be as simple as possible without ambiguity and complexity. Being strongly typed is one of powers of Electron and removing templates will force us to loose this property too. 

N - Object creation syntax should be completely readable and not to be confused with any other construct. Is it so? Yes it is. We don't need `new` keyword here.

Y - Support for higher dimension array as a single block memory allocation. `int[,] x = int[5, 4];` or `int[][] x = int[5][4]`. The second version is more powerful because we can have `x[0]` as an int array of size 4. But it won't be a continuous block of memory. Second version can be implemented using template and collections. So we will support only the first method.

Y - regex is not readable. Let's remove its dedicated operator and use string methods instead (startsWith, endsWith, contains...).

N - Make string, primitive or have a primitive and a non-primitive string type? non-primitive is basedOn the primitive.

Y - Return bitwise operators. In some cases like hash, encryption, digital signature or network based code this can be useful.

N - If all fields of a class need to be defined in a single location in the file, why not merge them all like import statement?
```
struct
{
    int x;
    const int y = 12;
}
```
Then we can state that interface cannot have a struct section. (Alternative names: data, fields, def, definition, allocate).

Y - Is semicolon required at the end of directives? When you are 'defining' something (method, struct, ...), you don't need to place semicolon but when you are requesting something to be done (by compiler or OS or CPU) it is needed. If we totally remove semicolon from language this differentiation will not be needed. We cannot force semicolon everywhere because inserting semicolot at the end of method body is unusual. As a general rule, semicolon is not required after closing braces. 
N - `@param` should only be allowed at file level. Do we really need `@param` at method level? Seems not.

N - Assume we want to use a template class. `int n = 5; auto x = AClass<n> {};`. Will `AClass` be generated using value of `5` or `n`? You have to send `'n'` not `n`.

Y - Remove `@` for assertion. Use `assert` keyword which is more readable. And for pre-post condition, use normal syntax and `defer` keyword respectively. For class-wide assertions, we can re-use same keyword. Assume how can someone take a look at assertions in a big file when we use `@` notation?

N - Rename `@@` to `@expose` because it is explicit. 

Y - Remove `@deprecated` this can easily be achieved using file level assert.

Y - More explicit syntax for anonymous function/interface to access outer methods information. Simple using variable names from parent method or class is not elegant and also it's too implicit. One solution is that compiler generates a new class on the fly which implementd target interface and according to the given code and method bodies. And at the end adds a private variable names `_outer` of type parent class which can be used to access public fields and methods of the container class of the parent method of the anonymous function. 
```
IX x = () -> this._outer.dataMember;
```
This method is explicit, not confusing, easy to read and understand. But does not provide access to the parent method, which sometimes can be extra useful. Access to the parent method is more important. So `this` will contain read-only set of parent method's variables. 

Y - Remove `@doc` directive. Define a special comment for this purpose: `/// dsadsada`

N - How can someone refer to the static instance of a class? Using name of the class: `auto x = MyClass`; It's not good to use `MyClass` both as a type and as a variable. One solution: `MyClass.instance`. But still `MyClass.myMethod(1)` is valid. It is so rare to refer to static instance of a class, but this will be useful to implement singleton pattern. You can add a method which returns `this`. Calling it on the static instance will give what you want.

Y - We need to use an existing method in places where an interface is needed. e.g. `Intrf1 x = this.method1` where method1 complies with Intrf1 requirements, but it's name may not be exactly the same.

Y - Instead of compiler directives, can we use keywords? `delegate` prefix instead of `@expose`. 

N - Replace `@basedOn` with a keyword: `basedon`. Not good can be read `base don`. `includes`.

Y - Replace `@param` with a keyword. This can be replaced with a comment of special format. `//<T>` or `//<T=int>`. This must be on top of the file. Or we can use `type` and `token` keywords. But this is really non-runtime keyword. Does not produce any CPU instruction. We can use `tokens` section like `import` section. Simpler solution is comment embedding, but how to tell if it is token or type? single character is always type. 

Y - Instead of a complex `@expose` directive, add a simple keyword which exposes the whole object. And let developer customize that with function definition syntax. `auto func1 -> this.var.func1;` (this is too confusing).
`int func1(int x) -> this.var.func1(x);` This is better which we already have.

Y - Remove inhertance of interface in a class and only have `extends` for interfaces. For class, we act like Go (if it implements interface methods, it is of that type). No `extends` and No `implements`. Just like Go. Then what does an empty interface mean? Means any object (Any class).

Y - Implement `exposed` using internal constructs.

Y - With removal of basedon/includes/extends/implements, how can I implement enum? Convention (consts with literal primitive values)

Y - In go interfaces can be embedded too. We should use `extends` keyword.

N - Is it possible to remove `struct`? struct is responsible to define data members of the class and it's zero state. 

Y - Shall we disable constructor like go? Then how can we enable only static access? We can remove the notation of constructor. Each class can define a method to create instance of it and other use it's static instance to call it. If there is no such method or it is private, other cannot instantiate and can only use the static instance. Class can define a method which takes input values to initialize data.

N - Can we create instances of classes in `struct` section? Only const init with literals.

Y - Let's disable init in struct. Only setting literals for const should be supported. Like go.

Y - Go has tags. Shall we add something similar? 
```
struct
{
    int x { key1 -> 'value1', key2 -> 'value2' ... };  //this is a hash-like structure
}
```

N - Can we have tags for methods or class or interfaces? No! We can simulate these with member fields.

N - Provide enum facility by a base class and template. This is too compelx. 
```
//<T, L1, V1, L2, V2>
struct
{
    const T L1=V1;
    const T L2=V2;

    T value;
}

void assign(T value)
{
    if ( value == N1 ) this.value = value;
    if ( value == N2 ) this.value = value;

    throw {'invalid value'};
}
```

Y - `{}` can be confusing sometimes. Can we replace it with another operator to create an instance of the current class? `@`.

N - With more usage of template, we need something like `typedef` in C++ or `alias` in D. `alias myint = int`. No, this can be done using composition and `* ->` operator. 

Y - Provide enum using it's own keyword: `enum(int)`
