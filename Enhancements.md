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
This can be easily achieved by using std and anonymous function. Why add a new keyword? LATER: we need a keyword because this is fundamentally different than a method call or thread creation. But it should be very simple.

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

Y - Remove special treatment for hash (except for hash literals). So name will be `hash<K,V>` and `[]` will become `set/get`. Like Java. so `return {'A':1, 'B':2}` will be automatically converted to a `hash<string,int>` class. Same can be done for array. So we will have an array class with normal methods and variables. Only compiler provides some basic services to make working with them easier. Special services: Literals (for hash and array), read and write values (`[]`);

Y - We can mark string as a char array, so it will have it's own class + some compiler services to handle string literals and operators (+ ... ). But other than that it will be treated just like a normal class. So we will have primitives and classes and nothing else.

N - Calling `==` for reference types, should invoke `equals` method or check equality of their references? Common sense says `==` should compare two values on the left and right. Not calling a special method.

N - What if a function expects a `Stack<T>` and does not mind the type of `T` (some utility function which works on stacks of any type, e.g. get size of stack or some other thing which is not included in the original class).
We cannot solve this problem, by giving users ability to extend the stack class and add methods. Because what if it needs two stacks or it needs stacks of different types or different generic classes?
They can add all these functions to a class which exposes `Stack<T>` and it a `<T>` template. or they can use a base interface. There is no need to remove templates or make them more complex than how it is now.

Y - By adding default static instance for all classes we are doing a lot of things wrong. 1) we are explicitly introducing global variables, 2) adding an exception for class and instance creation 3) adding special syntax for static initialization of the class. Let's remove them. What about singleton? It's not as important as solving mentioned problems. 
Also we can assume classes without `struct` section are static so utility classes like `Math` can be easily implemented. Same should apply for a singleton class. Because if a class has state, maybe it should not be single. 
Solution: Static methods are those who don't have `this` argument. Consequently they won't have access to struct members because they dont have `this`.

N - Rust and many functional programming langs, define almost everything as "mutable" meaning they cannot change once they have values. can we incorporate this? But for a complex and big object, this is not practical. 


Y - Why use two names for data types? If everyone knows double why use float64?

Y - No public fields? Then how a constructor is defined? How to organize fields and methods? What about the underscore rule for private data? 
One solution: Fields will still be inside `struct` definition. They all need to start with lowercase letter.
For methods (instance/static), if they start with uppercase, they are public. lowercase means private.
But classes are all public (file-name cannot be case sensitive, we cannot have two rules for public/private and also this is how go handles it).

Y - Difference between instance and static method can be their parameters: if the first argument is of type of the class, then its instance else its static. But its better if static and non-static are not mixed.
This also will help us eliminate some exceptions imposed on the constructor syntax. 


N - Return `while` keyword. It only makes the language confusing to use `for` as a loop with condition. Then there would be two ways to do conditional loop. 

Y - When we say constructor is a special method (1st exception), which has no return type (2nd exception) and can be called on a class without having an instance (3rd exception), and has a special call syntax (4th exception) it is not consistent with other OOP concepts. In perl constructors return values and use `bless` to make result an object. 
We can remove 2nd exception (it has a return type) and 4th (give it a name). For 3rd exception, if we define static methods as those who don't have `this` argument, this can be solved. So a class can have a combination of static and non-static methods. so for MyClass: `MyClass new(int x) { MyClass result = #!@#!#!; result.x = x; return result; }`.
The only special thing and exception here is the name of the method. Because there should be an standard way. But if it is really exception, then why mention the method name? It's better to define a convention/advice here and let developers choose the name of the constructor(s). Users will need to read the documentation to see if they need to call `new` or another static method.

Y - If we want to have something like 'goroutine' we need to support them at the syntax level. like `promise`? (But for communication channel and future features like opComplete, ... we can rely on core and std). Because this will create a new type of thread (a coroutine), so it is an underlying difference. What are we going to write in the code handler for `promise` if it's a member of core? The whole thing should be implemented in the compiler and runtime system level. So we need a keyword here but keep it as simple as possible (e.g. we don't need return type, it can communicate with a channel or shared variable, we don't need an `onComplete` handler. How to stop them? (taken from a discussion about goroutines: Killing individual goroutines is a very unstable thing to do: it's impossible to know what locks or other resources those goroutines had that still needed to be cleaned up for the program to continue running smoothly."). Programmer should handle this in an idiomatic way. It can use channel or any other means for this but its not a good idea to force stop a promise (~goroutine). 
How to delay execution of goroutine? Again this can be done via channels. Wait for a signal then start the operation. So we really don't need anything other than a keyword which "starts" a promise. Something like `for` statement but with a totally different meaning:
`promise { //some code }` or
`promise obj.func(1, 9, 12);`
Exactly like the way to invoke `for` or `if` statements.

N - Can we have polymorphism when calling constructor? Something like:
```
ParentInterface pi = helper.getInterface();
MyClass mc = pi.new();
```
Can we make constructor, member of an interface? No. It's not possible but we can define an interface for a factory class. which has methods which when called, will create objects of specific interfaces.

N - Can we really know all types at compile time? What about interface?
```
MyInterface mi = helper.getInterface('sample_calculator');
mi.doSomething();
```
Can we say `doSomething` of which class will be called? No. We have to determine which method to call, at runtime. So we need to store type information with references.

Y - We should make compiler/tools development something parallel to core/std/software development. Means after language is fixed, create the most basic compiler (something which just works but is not beautiful, optimized or fast) according to language spec. Then start writing core/std/.... In the meanwhile, the compiler can be enhanced/optimized/refactored/re-written.

N - Shall we add a new keyword for immutable and let const be fore compile-time constants? No need. This can be handled by compiler/runtime and does not add burden to the developer.

N - Shall we have nested definitions inside `struct` section?
No. It is unneeded complexity.

Y - Shall we let developer add public fields? What if he only needs a small struct (e.g. Point or FileInfo) with only public members? This can be achieved using Tuple generic class. We can say, only const fields can be public. This makes sense with Point and FileInfo and at least makes sure object's state cannot be set by outsiders.

N - Research more about templates and generics and their use cases to make sure current solution makes sense in real world.

N - move template args from comment and use a keyword. we can remove them altogether.

N - Like Smalltalk: Everything is an object, even int. But the class (or compiler) decides whether it wants to be on-stack or on-heap. Compiler can decide so if class's size is small. For stack allocated classes, they are passed by value not reference but all this is handled by compiler. -> too much complexity

N - For stack-allocated classes, `this` is the data itself, not a pointer reference. so they need to have only one member (int, float, ...). If they have more than one data member, then `this` will become a reference. But what if a class has 4 byte members. Its still smaller than `double` type. Can we allocate it on the stack and `this` then refer to members on the stack?

N - If everything is considered a class and specific ones are allocated on the stack (handled by language or compiler), then we can define almost all operations as a method call. (`x+y` becomes, `x.add(y)` and ...). And this will be provided for all class so language will have orthogonality. (Casting, toString, Math operations, ... can be defined for every class, also classes can have their own methods, e.g. Data.Format). -> but this will make language complex, when I see x+y I really dont know what is going on until I see code for class of x and y.

Y - With current status for instance/static methods, what change do we need to apply to interfaces? Interface describes behavior of a class. So it is based on instances. Should all methods include `this`? What would be their type?
They definitely don't have a struct part. not even const.
```
//MyIn.e
int func1(int x, int y);
int func2(int x, int y);  should we mention this? What should be its type then?
```
All these discussions (static -> constructor -> naming -> interface issue -> ...) are because language is not simple and orthogonal enough. A truly simple, consistent and orthogonal language is really hard to design and implement but will be understood and written easily. 
Orhogonality says every combination should be possible. OOP and best practices, say some combinations are evil and harmful -> there is a conflict. If we go according to OOP advise, there will be no orth, more compiler checkings, more exceptions in the syntax, less consistency. I think I prefer orthogonality and let the developer decide how to implement the code. So if he wants to define static global variables (for example), it is possible but not advised.



=========================================



Y - We need a more orthogonal design even though we ignore some rules/best practices in world of OOP/SE.
The fact that some types are allocated on stack vs. some on heap makes language less orthogonal. We should give the developer choice of the storage. Of course when the developer has more choices, he will have more responsibilities too and the possibility of making mistakes will be higher but this will come at the benefit of having a simple (and powerful) programming language. 
* Everything is a class (even int or Class definition)
* Class can define anything public or private or const or non-const (method/field).
* Methods can return any number of elements (using tuple).
* Null? Each class CAN define a static member called `null` which all members are in zero state and methods throw exception. If not defined, the class cannot be null. This is up to the developer.
* As the Class definition is an object, it can implement interfaces and code can use interface to create instance of a class it doesn't know. `FactoryIntr fi = create_fi(); MyInterfaceObject mio = fi.new();` New will call an internal operator which will allocate space for class members on stack or heap?
* interfaces can contain both instance and static methods and variables.
* One way to achieve orth and simplicity is unification. See everything as one thing. e.g. say everything is a method/everything is an object. 
- Enum can be easily implemented by above rules and we don't need a special syntax/keyword. And of course, enum values don't need to be compile time constants.
- We don't have inheritance but we have composition. 
- `*` can be used to denote whether a method wants to receive it's inputs by value or by reference. 
- Function inputs are not const. We can write `auto x = MyClass.new()` or `auto* x = &MyClass.new()`.
- `int x= 12; iny* y = &x;` Like C.
- Now that everything is an object, we may be able to write better generics: Empty interface is parent of all objects even int and float. If you want more filtering change interface (E.g. we can define `number` interface which has operators + and - and use this type in the generic class. ...) this does not provide true generics but its enough. So we won't need template and generics. Also we will support `typename` and true generics.
- What about tuple then? It's just a helper. Not so much important. 
- The behavior with array and hash won't be special. because all other classes can define these operators. The only special thing will be processing hash-literals and array initializers. But for hash this is only when pre-processing code. generated byte-code will have method calls to insert those data into a hash. Same for array. `a[1:4]` will be just a method call to create instances of `slice` class. 
- So using `this` in instance functions is mandatory but not in static methods. 
- Do we need a static initializer?
- I think we need to keep `promise` because this is not a simple method call. it involves stack creation and handling, scheduling, ... . 
- We don't seem to need any change for anons because they confirm to "everything is an object" approach. Just remember that they too can return multiple values.
- We can use `async` instead of `promise`.
- Const? no change needed. It can be applied everywhere (orth) and has the same meaning (cons). Compiler should handle consts which have compile-time evaluatable value.
- exception handling? now that we return multiple values? There should not be a global variable. Classes can return multiple values like Go, or have an instance level error object. Up to the developer. 
- assertion? no change needed.
- interface definition? We can include `this` keyword in method definition without type to indicate it will be an instance method. As a result, we can define class methods in an interface too! another step towards orth and generality.
So in interface we have `int add(this, int x, int y);` in class we will have `int add(this, int x, int y) {...}`
The type of `this` is explicityl known to be current class so we can omit it. A little bit like an exception.
We can use `auto` here. auto means type is inferred. We can use it both in interface and class:
interface: `int add(auto this, int x, int y);` 
class: `int add(auto this, int x, int y) { ...}`
Auto here has same meaning in other contexts although it is a bit different.

N - Then what does `throw` do? We can eliminate this keyword and let the developer decide what to do. `defer` is enough to make sure resources are freed. Like go, `return`. Throw is in itself an exception. 

N - We are using dot both for package and for method/field name separation. 
Rust uses `::` separator. 

N - private/public? Saying private should start with _ or lowercase is some kind of limitation. but I think it helps make the language simpler. Now that developer can define public/private anywhere he wants, I think it's better to keep to underscore notation. Because it is more visible. But what about local variables? Is that an exception? (Then it will hurt orth and no exceptions rule). If we only add public and assume everything else is private, this will add a new rule and also makes the code less consistent because privates are normal while publics have a keyword. Adding 2 new keywords for this purpose is unneeded complexity. Enforcing capital letter is hard on file-system (for classes), so underscore is better. Also we can keep lowercase name for basic data types like `int` or `string`.

N - Maybe we can impose type checking to template by embedding. 
```
//mystack
struct
{
    Stack;
}

void push(int x) { this.Stack.push(x); }
```
But we will have two `push` one with general object and one with `int x`. Unless we hide the stack, not embed it. we add `typename` for type safety.

N - Can we borrow rust's macros? No they are complex.

N - Can we handle array/hash literals using language macro or something similar without special treatment of compiler?
Like the way rust vector initialization works. We can have an `assign` method on array and hash-map. They will be vararg.

Y - Can we define data members or even static methods in interface? According to consistency and orth rules, we should. Application: Define null value for a class. Of course they cannot have values because they will be useless. Class1 implements interface1 only if it has all methods and data members defined in interface1. 

N - Do we need varargs? This can be useful when compiler wants to translate `int[] x = {1, 2, 3, 4}` to a method call on array class. extra complexity.

Y - Do we need *tuple*? To support multiple return values? `auto x = func(); (int,int,int) func() { return 1,2,3;}`
Like `tuple(int, string, float) x = (1, 'a', 3.1); int y = x[0];`. Of course tuple is an object too, but an object which compiler helps us create. NO we don't need them. they can be implemented using normal classes. They make code complex and rise need for type alias. But we can assume `tuple` is a special class like an array. We cannot write one file per method. 
Notation of `[0]` is not good because it can be replaced with a variable: `tuple(int, float) x=...; int y = x[k];` What should compiler do here? Either we have to ban using variables in `[]` for tuple or use named items. But for named, if we have `tuple(int, int, int)` what should be their name? It's better if we have literal-only tuple. And also compiler will transparently handle tuples:
```
tuple(int, float) func1() { ... return (1, 1,4);}  //will create tuple
(int, float) func2() { ... return 1, 1,4;}  //will NOT create tuple
auto x = func1(); //x will be tuple(int, float)
auto y = func2(); //wrong! but compiler can make y of type tuple(int float) and assign values automatically.
auto x, y = func2(); //correct
```

Y - Should we support *type alias*? Currently we assume each file = one type. Adding type alias will make everything more complex. But with addition of multiple return value and tuple(?) and generics we may need this. NO. Even if it's needed it can be done by embedding. We can support transparent type alias but the code will seem obfuscated.
```
import package1.class2;

mytuple x = ...;
```
Where did mytuple come from? It is aliased in class2. I don't like to use `class2.mytuple` notation. Because it will be confused with methods. But it can easily be differentiated in the context.
```
int x = myclass.method1();
myclass.tuple1 t = some_method();
alias tt = myclass.tuple1;
or: type tt = const int&;
```
And when are two tuple types equal? When their member-types are the equal. So maybe mytuple and myclass.tuple1 are equal.
using `myclass.tuple1` as a data type is better than `tuple1` because at least we know the source of `tuple1`.
Example: `alias MYT = MyClass; auto x = MYT.new(10);` Type alias is not a new type/object, it's just an alias.
Tuple can help us enforce single return value. even if func returns multiple, it will be a tuple and compiler will handle it transparently.

Y - Think about *stack/heap allocation* notation. Do we need different notations? We have a single notation like `alloc` (to be decided later), which does allocation for you. You can either store the address or a reference to that address. But this will be ambiguous. Developer should not let compiler decide. He should have the power to say what he wants. 
`auto x = class1.new()`. But this is complexity. Let's just declare we need allocate memory for this class and have a reference to the class. With `*` we accept possibility of `int** x` but we can easily ban it, it's not banned in go. Who decides where to allocate? User of the class? Class developer? Compiler? It's not good to let compiler decide. But it makes thing less complex. Let the user and developer write their code (new, allocate, &x...). Then compiler will decide what to do. If user has a non-pointer data to a class instance, `x=y` will do a full-copy of memory (doesn't matter whether its on heap or stack). if `class1* x = ...; class1* y = x;` will just copy reference from x to y. So from developer perspective, there are classes and references. It doesn't matter where data is stored, only important thing is that data of type `class1` is sent by value while `class1*` is reference.
We want to be general and orthogonal but we also want to be simple with min rules. We don't want to have 10 rules about where something will be allocated. What if I request stack allocation but `new` returns something which is on heap or vice versa? In C++ the usert decides where to allocate the instance of the object. 
`int x = 12` this clearly has to be allocated on stack. compiler will translate this to: `int x = int.new(12);`
`tuple(int, int) y = 19, 20; -> tuple(int, int) y = tuple(..).new(19, 20);`
But clearly, this conflicts with the notation of `new` where the class may want to return a cached copy. maybe we should let go of this and `new` method concept. we have `allocation` and `initialization`. The first one can be on stack/heap and is decided by the user and done by runtime system. The object has nothing to do with this. Result of allocation is creation of a new instance of the class. `initialization` can be done via any of the methods. 
`auto x = MyClass{x:1, y:2}; //you can set values upon initialization`
So we don't need static method `new`. Its good because with embedding of types, static methods will be embedded too and we will have two `new` methods which will be confusing.
```
MyClass x = MyClass{} //this will allocate on the stack
MyClass* y = new MyClass{} //this will allocate on heap
MyClass* z = y;   //copy a pointer
MyClass t = x; //copy whole data
int x = 12; //stack
int* x = new int{12}; //heap
or: auto x = new Class1(a:1, b:2);
```
we can think of another better/more consistent word instead of `new`.
What if we want to have a pointer to data on the stack? `int* x = &stack_var;`?
What if the code sends a pointer to the data on the stack to some code which saves the ptr. Later the saved ptr will be invalid! One way is to prevent '&' on stack-allocated vars. We can remove `&` operator altogether. `*` denotes a pointer to heap. we can have `MyClass* y = x` if x is already of pointer type. But we cannot have `MyClass* y = &x` because maybe x is stack-allocated. As a result: How are we going to support double-reference? Let's just ban. (1 is a valid number so we have only 1 level of reference):
`MyClass* x = new MyClass{}; x.method1();`
We don't need de-reference operator, `(*x)` does not make sense because everything can be called via `x.` notation. Maybe we can even replace `*` with `&` like ref-var in C++.
so: `auto x = new Class1{};` will create `Class1*` data type and allocate on heap. `auto x = Class1{}` will allocate on stack. -> Later: we introduce `new` method + everything is on heap (unless compiler handles it differently transparently)

Y - *Generics* What is the class of `int[]`? Is it same as `float[]`? What about `myClass[]`? If we want consistency, we should let others define similar classes. `Tree<int>` same as `Array<int>` or `Queue<float>` same as `Hash<float, string>`. In order to have consistency we need generics. How are we going to represent a tuple? We need varargs generics. But how to stop falling into the endless trap of generics complexity? We can use Rust and Dlang ideas. 
```
//rust
fn print_area<T: HasArea>(shape: T) {
    println!("This shape has an area of {}", shape.area());
}
```
Electron:
```
typename K: interface1, interface2;  //if omitted, empty interface is assumed
typename V: interface2 = MyClass; 

void put(K key, V value) ...
V get(K key) ...
```
By this way we can have collections, array, hash. About tuple, we cannot use `[]` operator in them. So it should remain a `special` class which is handled by compiler. Although it is very similar to other classes. 
What

N - Can we incorporate uniform function call syntax like D to make language simpler? No makes code confusing. `func1(x,y)` where is func1 defined? `x.func1(y)` is more readable.

N - implications of embedding anonymous with static methods like new? We no longer have special `new` method. If both have `new` then there will be a conflict. WE embed instances of a class so no static method is embedded.

N - How to handle multiple pointer dereferencing? `int** x; int y= *(*(x));`?not valid.

Y - interface is a class. Implementing functions in a class is optional. If they are called and not implemented runtime error will happen. We can check `(class1)myObj` which returns true if myObj's class has all methods and data-members specified in class1.

N - we can also use type alias to alias an import:
`alias cd = core.data.util.stack`
This makes import complex. We already have `=>` notation.

Y - implement/extend vs embedding. Why we can implement as many interfaces as we want? because its guaranteed that there will be no conflicting implementations. 
we can expose as many members as we want and we can hide their methods by adding methods with same name and we can call them via `this.member.func` notation.

N - It is mandatory to have `class1& this` as first parameter for non-statics. It cannot be `class1 this`. Better to use auto here: `int func(auto this, int x)` which will translate to `const class1&`, because you cannot change value of `this`.
Later: There is no static vs non-static. 

N - What if methods of class have different type for `this`? Can we extend classes using this method? if this happens, then there is no need for struct and methods to be together. Like D's uniform function call syntax. This is complicated because, what about private functions? What about static functions? At least for calling notation we definitely don't want to support `f(x, y)` because it's non-OOP looking. 
Can we have `MyClass this` and `MyClass& this` like Go? for small classes like `int` we may want to use `MyClass this`. but this means the method has access to a "Copy" of the object. which we don't want. we always want to access original object.
```
int x;
x.method1();  //can method1 ++ the value of x?
```
If someone wants to add a method to a class, he can embed and extend it. Adding new functions to other classes by defining a function in another file and settings `this` to another type will ruin the whole system and rules.

N - Is const part of type alias? What about `&`? Yes.
```
type x = const int&;
x a;  //=const int& a;
const x& a; //=const int& a, you cannot apply const or & more than once
```

Y - The only exception is the way we create new instances. Either we can go everything be allocated on heap and provide `new` static method and accept low performance. Or we can say some things will be on stack.
```
auto x = MyClass{}; //allocate on the stack
```
What if we allocate everything on the heap and use stack only for call and return address?
+ providing enhancements like caching to handle small classes, like integer pool or ...
if we can do this:
benefit1: providing uniform new syntax 
benefit2: remove & from language because everything is a reference
benefit3: class methods will have `myclass this` parameter. not `myclass& this`
benefit4: we can ask a method to give us some class to call `new` which means constructor polymorphism.
disadvantage: performance cost when we work with basic types. 
maybe compiler can handle this and smartly and transparently converts stack-allocated to heap-allocated upon need.

Y - Can an interface or class, define static variables? how?
why differentiate between static and non-static methods? If static instance is just a normal instance (only created by compiler) then why it cannot be exactly same as a normal instance? As a result, we don't differentiate between static and instance variables. Each class definition has a single list of fields which is available to all instances (static or non-static). I even suggest to eliminate the word 'static' and assume everything is instance-level. We may even be able to remove `auto this` and simplify interfaces too. I think we added them in the first place to support notation of static methods. (Returning back to previous steps :) ).

N - Can we force a class to be only used through static methods? yes if we use `new` method to create instances and define it as private.

N - We can have `type this { ... }` to define instance members, instead of struct keyword. Why differentiate? Each class has a single list of methods and a single list of fields.

N - We "embed" an instance (so it doesn't have anything to do with static members), but when implementing an interface, we should implement whatever there is (instance and static). NO. A class means a single list of methods and fields. When we embed, we expose methods. When we implement, we write bodies for methods.

Y - Classes will have a static (correction: normal, we no longer have static things) method (advised to be named `new`) which you can call to instantiate. 
```
auto x = MyClass.new();
```
And this `new` method is exactly same as other methods. It can return multiple items, return const, ... .
Also we don't need to mention `this` or `auto this` in the parameter list. But to reference elements, we have to use `this.x` notation.

Y - Do we still need `&` sign? No. No longer pointer. Everything is a reference even `int x`.

Y - `int x = 12` how compiler will handle this? Is this feature provided for all classes?
This is same as `int x = int.new(12);` we can say that this can be implemented for other classes too if they have a 
method with any name, with only one input and type matches and method output is of type of the class, then it will be called. As a result, compiler is not bound to a method name. If there is more than one method then compiler cannot handle these cases.
```
MyClass mc = 19;
//in MyClass.e
MyClass new(int x) { return #@!#@!;}
```

N - What happens to `new` method of class when it is embedded? it is also exposed! so parent class either should have its own new method or hide it with: `MyClass new();` This is because we cannot add exceptions. We cannot say, for `new` it is not embedded. 

? - What should be inside `new` method?
```
MyClass new(int x) {
    MyClass result = {};
    result.x = x;
    return result;
}
```
We have to select a special operator like `@` or keyword like `alloc` or `{}`. Last one is better.


Y - Can we hide tuple? `int, float func() { return 1, 1.4; }` No. but we can standardize it.
If its hidden: One exception is removed from syste,
If its there: We don't need multiple return values.
We can have them an explain this exception like this: compiler creates appropriate classes and writes code for `[]` notations. So:
`tuple(int, foat) t = (1, 12.1);` will become something like this: `TFFT t; t.set1(1); t.set2(12.1);`
Tuples don't have `new`. Can you embed them? you have to be able to embed them or else this becomes a bigger exception.
If we want to remove the exception we need to add variadic template and a special notation for index counting!
Another solution: Statically define them (tuple with 1 element, 2 elements, 3, 4, ..., maybe 9). And compiler will convert `tuple(int, float)` to template call `tuple2(int, float)`. That's the only special thing that compiler will do, which is dedicated to tuple, no other class in the system has this feature. 
As a result: we don't support multiple-return types but we support returning tuples and compiler will handle them transparenty for you.
`tuple(int,float) func() return (1,2);} /*later*/ x,y = obj.func();`
compiler in above case, will convert return of `func` to `tuple2` type. create appropriate code for return. assign appropriate values for x and y.

Y - Anonym classes dont have static instance because they don't have a name.

Y - New keywords: `async (promise), type (alias), typename (template), exposed (embedding), tuple (multiple returns)` + operator for `new` method. Removed keywords: `null`, `promise`, `?? null checking`.

Y - How can we implement the code that we want to be executed when static instance is being created? We dont differentiate static and instance method. So maybe these should be in `new` method? But runtime system cannot send args so it cannot have inputs. But we don't want to be bound to names. So: 
When creating static instance of a class (lets find a better name), runtime system will execute private method of the class definition which has no output and no input, and have no name (if any).

```
void _() { //static initialziation }
```

N - compiler WILL NOT create anything for any class automatically. If your class needs to be instantiated, simply write: `auto new() return {};`

N - What about unit tests? We can rely on convention. Classes with `Test` prefix or methods with `test` prefix will be run in a test. this is a small matter and should not affect underlying syntax of the language.

Y - Better syntax for import `=>` seems too heavy. One way is using `type` for aliasing. But this is not a type. this is a package name. We do not import a single class. we import a package. `import core.utils.data`
one solution: `import a as b` or `import b=a`

Y - Better not to use `=` for type alias because this is not assignment. Something that we will use for import too. 
:=
for typename default value, type and import. Where we really don't mean setting value for a variable.
`type myt := int`
`typename TT := int`
`import myname := dsadsa`

? - So we can have abstract class, and we can embed them, and then override their missing methods. but if A is abstract, B embeds A and implements A's methods, will calls to 'A's missing methods' be redirected to B's implementations? If so, will B's implementations have access to private members of A? No. Definitely not. they are private. so in class A calling `this.method1` where method1 has no body, is OK and at runtime this will try to lookup methods in `this` (which can be of other types), and call it.
We will face a lot of such questions or ambiguities. It is important to behave according to the rule of least surprise. We should exactly define behavior of each of language constructs.
What about access to private methods? No it shouldn't have access. Implementing method is a member of container class. It does not have any type of special access to abstract class's fields or functions. 

Y - Can we use `type` to define easy enums? There is no easy enum. I we define something it should be applicable to ALL classes. we can say values must be fixed compile time calculatable.
`type DoW := int (SAT=0, SUN=1, ...)`
will be translated to:
`type DoW := int (SAT=int{0}, SUN=int{1}, ...);`

? - What is initial value of an instance variable of type class?
`MyClass x;` what does `x` contain? can I call `x.method1()`? Is it `nil`?
If so, can we return `nil` when we are expected to return `MyClass`?

? - Better keyword instead of `exposed`.

? - Calling a not-implemented method will throw exception or do nothing?

? - What happens if we expose a private variable? We don't want to ban that so there should be a consistent, orth, least surprised, general explanation for this situation.
All publics will become privates? f becomes _f

N - Suppose A implements some methods of B.If we send B's reference inside A, other will have a reference to a class which does not have complete implementations but this reference has implementations? Yes this is possible. If you want others to be sure method will be implemented just pass reference of A.
