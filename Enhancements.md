#Enhancement Proposals

Note: Y = Approved/Language Spec Changed, N = Rejected/Clarified, \* = On Hold

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

Y - null coalescing operator (`x = a ?? b` means `x = a` if a is not null, else `x = b`). This can be simplified more to `?` because we don't have usual ternary opertor.

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

N - How can we define assertion and other directives in interface methods? No need for that.

\* - Conventions to define unit tests in the code? How to define startup and finalization methods? Define test data input table and expected output?

N - No annotations? Configuration should not be part of the code, and most of the time they can be replaced with good design patterns like decorator or ....

N - We expect all `import` statements be grouped together. So why not merge them all like go?

N - Disable sending param values as another template type to a template: `auto x = tuple<tuple<tuple<int, ivar>...`
Values for template parameters should be either one of primitive types or a simple class name. Later to be decided. We cannot do that.

N - Remove template and generic code? Everybody seems complaining about them in other languages. No. We have relied heavily on this (tuple, map/reduce, ...). We just make sure this will be as simple as possible without ambiguity and complexity. Being strongly typed is one of powers of Electron and removing templates will force us to loose this property too. 

N - Object creation syntax should be completely readable and not to be confused with any other construct. Is it so? Yes it is. We don't need `new` keyword here.

Y - Support for higher dimension array as a single block memory allocation. `int[,] x = int[5, 4];` or `int[][] x = int[5][4]`. The second version is more powerful because we can have `x[0]` as an int array of size 4. But it won't be a continuous block of memory. Second version is the natural result of applying `[]` more than once.

Y - regex is not readable. Let's remove its dedicated operator and use string methods instead (startsWith, endsWith, contains...).

N - Make string, primitive or have a primitive and a non-primitive string type? non-primitive is basedOn the primitive.

Y - Return bitwise operators. In some cases like hash, encryption, digital signature or network based code this can be useful.

Y - If all fields of a class need to be defined in a single location in the file, why not merge them all like import statement?
```
struct
{
    int x;
    const int y = 12;
}
```
Then we can state that interface cannot have a struct section. (Alternative names: data, fields, def, definition, allocate).

N - Is semicolon required at the end of directives? When you are 'defining' something (method, struct, ...), you don't need to place semicolon but when you are requesting something to be done (by compiler or OS or CPU) it is needed. If we totally remove semicolon from language this differentiation will not be needed. We cannot force semicolon everywhere because inserting semicolot at the end of method body is unusual. As a general rule, semicolon is not required after closing braces. 
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

Y - Instead of compiler directives, can we use keywords? `delegate` prefix instead of `@expose`. We can remove

N - Replace `@basedOn` with a keyword: `basedon`. Not good can be read `base don`. `includes`.

Y - Replace `@param` with a keyword. This can be replaced with a comment of special format. `//<T>` or `//<T=int>`. This must be on top of the file. Or we can use `type` and `token` keywords. But this is really non-runtime keyword. Does not produce any CPU instruction. We can use `tokens` section like `import` section. Simpler solution is comment embedding, but how to tell if it is token or type? single character is always type. 

Y - Instead of a complex `@expose` directive, add a simple keyword which exposes the whole object. And let developer customize that with function definition syntax. `auto func1 -> this.var.func1;` (this is too confusing).
`int func1(int x) -> this.var.func1(x);` This is better which we already have. 

N - Remove inhertance of interface in a class and only have `extends` for interfaces. For class, we act like Go (if it implements interface methods, it is of that type). No `extends` and No `implements`. Just like Go. Then what does an empty interface mean? Means any object (Any class). This can be achieved using anonymous members in the struct section of interface.

Y - Implement `exposed` using internal constructs: `* -> this.member` to expose all public members.

N - With removal of basedon/includes/extends/implements, how can I implement enum? Convention (consts with literal primitive values)

N - In go interfaces can be embedded too. We should use `extends` keyword. No this will be done by anonymous fields.

N - Is it possible to remove `struct`? struct is responsible to define data members of the class and it's zero state. 

Y - Shall we disable constructor like go? Then how can we enable only static access? We can remove the notation of constructor. Each class can define a method to create instance of it and other use it's static instance to call it. If there is no such method or it is private, other cannot instantiate and can only use the static instance. Class can define a method which takes input values to initialize data.

N - Can we create instances of classes in `struct` section? Only const init with literals.

Y - Let's disable init in struct. Only setting literals for const should be supported. Like go.

N - Go has tags. Shall we add something similar? 
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

Y - Provide enum using it's own keyword: `enum`

N - We have `@` which allocates on heap. We can easily add another operator like `#` which allocates on the stack. 
But what happens when for example method returns a variable which is allocated on the stack? No, this is not good.

Y - We don't have ternary operator `?:` so we can rename `??` to `?`.

N - Define value classes and then we can say primitives are classes too (so you can write intVar.method) but still manage them on the stack. No, this makes everything too complex. 

Y - Having separate import is more readable than an import block.

N - What happens if exception is thrown in an assert, after return (in a defer statement)? Return value won't be changed but exception will be thrown.

Y - Do we need both optional argument values and method overloading? Not probably. Because later is only needed when former is not supported. So let's remove this functionality.

Y - Can't we remove tags? Instead of specifying tag for each member, class can add a `getTag` method (whatever name it wants) and when another methods will need tags, send output of this method to that function as a hash-ref. So for example 'json_converter` class will receive a json string + a hash + empty class, then will initialize empty class using hash data and json-string.

Y - Instead of using `exposed` or `* -> this.memberName` we use struct members without name (like go). We don't need their name because all public operations are available through `this`. By this way we can easily override functions by adding them to the owner class. 

\* - Maybe in other places where we are using convention, we can do like anonymous field and remove some part of the source code and delegate the task to the compiler.

Y - In function declaration, let's remove -> notation. Although it has a little convenience but is not much readable.

Y - Same as the way we provide inhertance in classes, we can do similar in interface extension.

Y - Calling assert in the middle of method definition is not good. We use anonymous block. 

N - If class A embeds class B and still overrides some of B's methods, it is still possible to call overriden methods of B by using `this.B.methodName` notation.

Y - Lets standardize constructor name as `new` or `_new`. Because it will become too confusing when people want to create a lot of classes from a different vendors. But we can get rid of `new` and `@` keyword by adding a new instantiation method. We can also remove need for `_new` by stating that no class can prevent others from instantiating it. So there is no need to define `new` or `_new` methods. Other can use `MyClass.member` to access static instance or `auto x = new MyClass {x: 1, y:2}` to create a new instance. Any heap allocation means `new` in the back-end so even array or hash definition by using `[]` or `{a:b}` notations is handled by compiler to use `new`. Or we can even remove `new` and use C++ uniform initialization: `auto x = Class1 { initdata };`. Note that if `Class1` is name of an interface, this will create an anonymous class.

Y - What if we need some initializations for the static instance? Only the owner of an instance knows what to do for init but static instance has only one owner which is compiler. Without static init, the code should handle this but how can it guarantee that this will happen only once? We need to add a section to `main` and each time we need a static instance, call `MyStatic.init()` in that part. Solution: Without changing anonymous block, enable init-code inside this block.

\* - How to do compile time checks? Like assert or check template args? Deprecated module? For deprecated we can add assert to static init block. For template args, compilation will fails if they are not appropriate. Let's do this later.

? - Add a variable type `void` where it can only be written to (which does nothing) but it cannot be read. Maybe this become useful. What about empty interface?

\* - Add a function to core which creates an array: `range(10)` creates array with values `0..9` can be used in for loops.

Y - Just like the way we can omit block in if/for/switch/... we should be able to do so for methods:
`int f(int x) return x+1;`

Y - Rename `_` in switch statement and import. Renamed to '*' in switch and removed from import. 

Y - Can we provide a shortcut for `if (Error.isSet())`? 
```
//throw applies on classes which implement exception interface
error = MyException {strMesssage, intCode, stringData};
return null;

or
if ( error != null ) 
{
    //work with e error 
    if ( (MyException)e) { ...}
    return e.basicData;
}
//OR
catch(e) return 5;
//OR
catch return 4;
```
So we have a global variable names `error` which you can initialize or check for null.
What about assert? `assert x>0 : 'some error'` will set error and return.
`assert x!=0 : exit()` if right side of `:` has a statement, it will be executed.

Y - Can we remove enum or replace it with other things? `const`

N - Shall we add multiple return? So we won't need global `error`. What happens to method definitions? Anon func?
`(int,int) f(int x, int y) return y,x;`
This adds to the complexity. No.

Y - `import a.b =>;` will import into current namespace;

N - To decrease complexity, either   
remove templates and replace them with something else (like built-in linked-list and force user to create custom classes for other structures like stack, or addition of equivalent of void*)  -> (NO, adding void* will make compiler and runtime complext and language hard)  
or   
remove hash and replace it with a template (everything will be template except for array)
Temoplates are needed to help developers be productive, so if we are going to have them, let's make the most use of them. 
Everything will be a template as much as possible: LinkedList, Set, Stack, ...
What about Hash? int[string] h; We can make it built-in or make it part of core and let compiler handle everything.
What about Array? `int[] x; int[,] y;` -> We need this as a built-in.
`int[string] h = {};`
If we add `void*` we will loose type information at compile time (assume a method which receives a `void*` argument) then runtime and compilation becomes much more complex.   
In order to be usable, we need to provide the minimum features (stack/heap, primitives, special behavior for string, array and hash) which we do. But for other things, we try to be consistent in behavior and orthogonal (so there won't be exceptions, if a feature is provided, it should be usable everywhere).
The simplest language would have no special syntax for array or string or hash. But it won't be useful.

? - Remove special treatment for hash (except for hash literals). So name will be `hash<K,V>` and `[]` will become `set/get`. Like Java. so `return {'A':1, 'B':2}` will be automatically converted to a `hash<string,int>` class. Same can be done for array. So we will have an array class with normal methods and variables. Only compiler provides some basic services to make working with them easier. Special services: Literals (for hash and array), read and write values.

? - We can mark string as a char array, so it will have it's own class + some compiler services to handle string literals and operators (+ ... ). But other than that it will be treated just like a normal class. So we will have primitives and classes and nothing else.

? - Calling `==` for reference types, should invoke `equals` method or check equality of their references?

N - What if a function expects a `Stack<T>` and does not mind the type of `T` (some utility function which works on stacks of any type, e.g. get size of stack or some other thing which is not included in the original class).
We cannot solve this problem, by giving users ability to extend the stack class and add methods. Because what if it needs two stacks or it needs stacks of different types or different generic classes?
They can add all these functions to a class which exposes `Stack<T>` and it a `<T>` template. or they can use a base interface. There is no need to remove templates or make them more complex than how it is now.

? - By adding default static instance for all classes we are doing a lot of things wrong. 1) we are explicitly introducing global variables, 2) adding an exception for class and instance creation 3) adding special syntax for static initialization of the class. Let's remove them. What about singleton? It's not as important as solving mentioned problems. 
Also we can assume classes without `struct` section are static so utility classes like `Math` can be easily implemented. Same should apply for a singleton class. Because if a class has state, maybe it should not be single. 

? - Rust and many functional programming langs, define almost everything as "mutable" meaning they cannot change once they have values. can we incorporate this? But for a complex and big object, this is not practical. 

? - Like Smalltalk: Everything is an object, even int. But the class (or compiler) decides whether it wants to be on-stack or on-heap. Compiler can decide so if class's size is small. For stack allocated classes, they are passed by value not reference but all this is handled by compiler. 

? - For stack-allocated classes, `this` is the data itself, not a pointer reference. so they need to have only one member (int, float, ...). If they have more than one data member, then `this` will become a reference. But what if a class has 4 byte members. Its still smaller than `double` type. Can we allocate it on the stack and `this` then refer to members on the stack?

? - If everything is considered a class and specific ones are allocated on the stack (handled by language or compiler), then we can define almost all operations as a method call. (`x+y` becomes, `x.add(y)` and ...). And this will be provided for all class so language will have orthogonality. (Casting, toString, Math operations, ... can be defined for every class, also classes can have their own methods, e.g. Data.Format).

? - Why use two names for data types? If everyone knows double why use float64?

? - No public fields? Then how a constructor is defined? How to organize fields and methods? What about the underscore rule for private data?

? - Difference between instance and static method can be their parameters: if the first argument is of type of the class, then its instance else its static. But its better if static and non-static are not mixed.

? - move template args from comment and use a keyword.

? - Return `while` keyword. It only makes the language confusing to use `for` as a loop with condition. Then there would be two ways to do conditional loop.

? - When we say constructor is a special method (1st exception), which has no return type (2nd exception) and can be called on a class without having an instance (3rd exception), and has a special call syntax (4th exception) it is not consistent with other OOP concepts. In perl constructors return values and use `bless` to make result an object. 

? - If we want to have something like 'goroutine' we need to support them at the syntax level. like `promise`? (But for communication channel and future features like opComplete, ... we can rely on core and std).

? - Research more about templates and generics and their use cases to make sure current solution makes sense in real world.

? - Can we have polymorphism when calling constructor? Something like:
```
ParentInterface pi = helper.getInterface();
MyClass mc = pi.new();
```
Can we make constructor, member of an interface?

? - Can we really know all types at compile time? What about interface?
```
MyInterface mi = helper.getInterface('sample_calculator');
mi.doSomething();
```
Can we say `doSomething` of which class will be called?


? - We should make compiler/tools development something parallel to core/std/software development. Means after language is fixed, create the most basic compiler (something which just works but is not beautiful, optimized or fast) according to language spec. Then start writing core/std/.... In the meanwhile, the compiler can be enhanced/optimized/refactored/re-written.
