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
    `int[String] hash1 = { 'OH' : 12, 'CA' : 33, ... };`
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

N - Add a variable type `void` where it can only be written to (which does nothing) but it cannot be read. Maybe this become useful. What about empty interface?

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

Y - `import a.b =>;` will import into current namespace; Changed to `:=`

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
This makes import complex. We already have `:=` notation.

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

Y - What should be inside `new` method?
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

Y - So we can have abstract class, and we can embed them, and then override their missing methods. but if A is abstract, B embeds A and implements A's methods, will calls to 'A's missing methods' be redirected to B's implementations? If so, will B's implementations have access to private members of A? No. Definitely not. they are private. so in class A calling `this.method1` where method1 has no body, is OK and at runtime this will try to lookup methods in `this` (which can be of other types), and call it.
We will face a lot of such questions or ambiguities. It is important to behave according to the rule of least surprise. We should exactly define behavior of each of language constructs.
What about access to private methods? No it shouldn't have access. Implementing method is a member of container class. It does not have any type of special access to abstract class's fields or functions. 

Y - Can we use `type` to define easy enums? There is no easy enum. I we define something it should be applicable to ALL classes. we can say values must be fixed compile time calculatable.
`type DoW := int (SAT=0, SUN=1, ...)`
will be translated to:
`type DoW := int (SAT=int{0}, SUN=int{1}, ...);`

N - Suppose A implements some methods of B. If we send B's reference inside A, other will have a reference to a class which does not have complete implementations but this reference has implementations? Yes this is possible. If you want others to be sure method will be implemented just pass reference of A.

N - Make the README file as short as possible. Example instead of explanation.

Y - How to handle bad exceptions where we cannot return error code? (like panic). We add throw and catch.

N - Better keyword instead of `exposed`.

Y - What is initial value of an instance variable of type class?
`MyClass x;` what does `x` contain? can I call `x.method1()`? Is it `nil`?
If so, can we return `nil` when we are expected to return `MyClass`?
If we add this new keyword and ban `return nil` it will not be gen or orth. Let's assume it implicitly.
`if not(x)` means if x is nil.

Y - When a variable is nil and we call one of it's methods, the method will be called normally with `this=nil`.

Y - Calling a not-implemented method will throw exception or do nothing? It cannot do nothing because it may have some return value. We can say it returns `nil`. Both are possible which one is least surprising and more orth? I think `nil` return is better. Because else, we ban calling not-implemented methods. Same as this, we can new `{}` every class even if it has no method body.

N - What happens if we expose a private variable? We don't want to ban that so there should be a consistent, orth, least surprised, general explanation for this situation.
All publics will become privates? No.

N - Benefits of `class1.nil`: default value when a variable is defined (class1 c, what is value of c?). 
How should we represent invalid state? Fawler calls this `special case` where for example in a "Customer" class there is a special sub-class called "Missing Customer".
When we add `MyClass mc;` to the struct, what will be the value of `mc` when class is created if it's not assigned in the constructor?
We should have an optional static property in classes which will be used for above cases + where developer needs.
named `nil` and it is initialized inside static constructor (`void _()`).
If there is no such thing in the class, all objects of that type MUST be initialized upon declaration.

```
const MyClass nil;
void _()
{
    this.nil = {};
    this.nil.data = -1;
    this.nil.message = "";
}
```

N - The notation that some objects have nil and some don't makes everything complex. Although its good to give developer to choose which one can and which one cannot but in other places we will be forced to put exceptions (e.g. calling methods on nil object returns nil object of the result UNLESS the return type does not have a nil defined where we throw exception!).
So it's better to have it at language level, and of course typed. 
This is a little confusing too because then we will have two special instances for every class: static instance and nil instance. Maybe we can join these and say nil instance is same as static instance but how are we going to implement "no behavior" of the nil instance?
nil can represent un-initialized variable or end of a linked list. And we may not really need typed nil.
So `nil` will be a keyword.

N - Things that compiler does for you automatically: calling static init method (_), array and hash literals, creating correctly typed interfaces for anonymouse functions, calling default constructor upon init (`myclass x = 12`), tuple handling.

Y - Idea: Naming for methods should be different from variables. variables `some_var` and methods `camelCase`. But there are cases where we treat methods like a variable (for anonymous). It's better to have same naming for them. But we treat class names as variables too (static instance)!
Except for package, everything else can be mixed together! Still method and variable are separate things. They can be assigned but they are different. so I propose this:
class: UpperCamelCase //for sure
package: UpperCamelCase //for sure
method: camelCase
variable, argument, field: lower_case
`int release_date`
`int getReleaseDate()`

Y - Make use of `=>` and more of `:=`. 
`:=` is used in 3 places for import, type and template. I think it's enough.
`auto $ => this._var.$;`. This can replace exposed and also is more configurable.
`auto data => this._var.some_field;` redirect read and writes.
```
auto $() => this._var.$();
auto $() => this._data.$();
auto $() => Math.$();  //composing static instances!
auto method1 => this.vvf.handler;  //automatically generate definition
```
what about fields? public fields are changeable so they should be trated just like above methods
```
struct {
    MyData d;
    auto sample => d.sample; 
}
```
other options: `handles` like Perl, delegation
This syntax is a little bit confusing.
`expose this._var;`
`expose methd := this.var.method1;`
`expose this._var.field1;`
`expose ff := this._var.field2;`
but where should these be defined? in struct? in method part? they do not fit any of them. 
we should change the syntax to match parts.

```
struct { int x; }
struct { auto x => this._var.field1; }
struct { auto $ => MyClass._var.$; }
struct { auto <T> => MyClass._var.<T>; }

int f(int x) { ... }
auto g => this._var.method1;
auto $ => this._var.$;
```
what about new? What about operators?
There should be a mechanism to expose a sub-set of methods and fields of a variable (this.var1). This subset can be defined by another class (or maybe the class of this.var1 itself). Actually the 'other class' here plays role of an interface. we exopse a variable according to a contract specified by an interface. Of course this interface is implemented by the class of the variable:
`MyClass var1; expose var1 as MetaClass1;`
`MyClass var1 [MetaClass1];`
`MyClass var1 [handles MetaClass1];`
`MyClass var1 [delegate MetaClass1];`
`MyClass var1 {MetaClass1};`
`MyClass var1 +MetaClass1 +MetaClass2` //support for exposing members of multiple interfaces
`MC v1 => MetaClass1, MetaClass2;`

N - Now that everything is a class, there is NO compile time evaluatable constant!
No. We have object literals like `12` or `'this is a test'`

N - Now that everything is a class how are we going to set default values for method arguments? See object literals.

N - Now that everything is a class, how do we handle literals like:
`int x = f(1, 2, 3, 'hello');`
Creating automatic object literals

Y - Maybe we can remove `default` keyword.

N - Do we need to re-define mechanism of `switch` with everything-class approach?
`switch` calls `op_eq` or something like that behind the scene.

\* - After all ambiguities are resolved, I will need to write specification where exact behavior of each statement and exceptions and notable points should be specified.

N - Current way to handle `int x = 12`is not good. Looking for a method with any name which accepts `int` and output is instance of the class. There may be more than one method or the only method may have completely other purpose.
Maybe we should use casting operator to cast something to the class.   
There is a paradox here! if everything is a class, then how will we initize `int x=12`? for doing assignment, we need to have an instance of `int` with value of 12. but what is type of `12` itself here? What will be the input of the method which initializes an instance with `12`? Literals are starting points to initialize basic data type classes. Now that `int` or `float` are not keywords, we only can do something like this: `operator=(int other_number)` and call this operator with something which has a value of `12`. Who/how will create a valida `int` instance using given literal? (same for other data types like string).   
one way: if the struct section of the class has only one member and its type is same as the rvalue, it will be a copy. 
q:What am I really going to write in struct section for int?  
a: `instruct runtime to allocate 4 byte for me`, the job is done in methods which will be hidden from eyes of end-developer because they will be implemented in the runtime system. There it will treat that 4 bytes as an int and do operations on it.
ok, how will we handle `12` literal?  
What about these: `int x = 12;` vs `int x; x = 12;` They should be the same. So the first one should be executed in two steps like the second one. 1) create an invalid state (maybe we should change the name), 2) update invalid state by calling `=` operator. `int x = nil; x = 12;`  
Maybe we should call it `base` state.  
What will be the syntax for `opertor=`? Finally at some point, we need to rely on compiler/runtime to convert that literal to an object, or else there will be an endless loop. Same as the way compiler handles literals for array and hash. But this should be provided for ALL classes. we cannot say, this is something only for these special classes. So what's the solution?
We should ask for help from the class itself. We should send the value bytes to some method of the static instance of the class. `int op_assign(byte[] data);`. too complicated.  
can't we just dump `byte[]` into struct of the class? if class has invalid state, `= literal` will just dump bytes into it's struct. (Internally rvalue literal is not modifiable so we can cache them).  
we cannot write `operator=` or `op_assign` for this purpose because it will make things extra complex. Going with the dump approach is better. `int x = 12`. Who initialized `x`? what if the `int` class does not have a public constructor?  
`int x = int.new(12)` makes sense? it doesn't! because still we need to convert 12 to an instance of `int` class!  
The main problem is with literals (in assignment, in method call, in default argument value, ...)  
Here definitely compiler should do the job. We can say all liteterals will be converted to their corresponding class. compiler will handle not generating two classes for two 1 literals.

Y - Object literals will be handled when parsing the code. They will be created and used and compiler will guess the best type for them. If you want to force a specific type, you must use `MyClass.new` or other mechanism to create instance of the class.

Y - Rule is, no memory should be allocated for a variable which is not instantiated. So `int x` or `MyClass mc` should not allocate any memory.

N - Do we need any notation to indicate something only belongs to the static instance? Suppose we have Person class and want to keep track of number of instances. In new we ++ it but this is copied for all instances! so for 1000 persons there will be 1001 copies of this var where only one copy is useful! maybe we can store it in a hash which is allocated only in static instance. But we want a mechanism where "obj1.count" and "obj2.count" refer to the same thing!

N - Maybe we can denote "MyClass.myMethod" to indicate a method is only callable on static instance. 
and `this.myMethod` for instance methods.
But most of the time either the class is supposed to be used as a static class (like Math), hence no constructor is defined and everything is OK. Or class is supposed to be only used as instance class. In this case, the static instance is just like other instances, and in the usage, code will call `new` and use the instance and has nothing to do with the static instance. Very rarely we have a class which needs both static instance and normal instance and their method MUST be different and normally we should decompose the class in such case.

N - Methods like + for int, will be inlined so we won't need to send address of the int to the method so we will be able to allocate them on the stack. but this is implementation details. 

Y - Maybe we can replace the whole re-implementation which can make the code un-readable with function pointers. The base class has a set of function pointers (single method interfaces), and the container will set them after instantiation. In this way we can implement strategy pattern or other similar patterns.
But what about method hiding?  Yes. Definitely. Anything that can make language with less rules and exceptions is good.

Y - Now that everything is a reference to a class, what's the meaning of `const`? We can almost define everything const and change everything inside them! I think const should mean real immutable.
`const int x = 12; x++;` we have not changed x, we have just called one of it's methods!
or in Math class `const float PI = 3.1415; PI += 4;` this is acceptable! only `Pi = float.new` is not acceptable!
We can define `const` as making internal/external immutable. You can pass a normal variable when a `const` is expected but not vice versa.

Y - Can we replace `tuple` using `type` and `struct`?
`tuple(int, float) x`;
`type myt := struct{int, float};` This is the compressed definition of an object where there is no method, fields have no name, and has `$0, $1, ...` notation to access it's members. It's better not to use `[]` operator because what will be return type of it then?. We can replace `$0` with other notation but not `_0` because underscore means private. 
maybe `.0, .1, ...`
We can call this anonymous struct instead of tuple! But still we need help of compiler.

N - Lazy getter like perl? No special behavior.

N - Casting is an operator itself. For example if `f` is float and we want to cast it to int.  
`(f as int)`  
`int.(f)`  
`int(f)`  
`int.new(f)` this completely makes sense but we have to provide a shortcut  
Shortcut for above can have a wider scope: shortcut for calling `new` but there is no `new` in the language syntax!
so let's forget a global shortcut and think of a `casting` operator which can be defined for classes.
`int(f)` will call `op_cast(float f)` on class `int`.

Y - Modify anonymous struct to have field names:
`type myt := (int x, float f);`
Pro: no need to write strange `$0`, more compatible with the way we define normal classes.
Con: It will be longer.
We can make name optional but will make thing more complex.
C#: `var result = (5, 20);` to define tuple
or `result = (count: 5, sum: 20);` with naming
`(int Count, int Sum) func()` when calling: `auto result = Tally(list); int x = result.Count;`
definint tuple literals: `var res = (sum: 0, count: 0);`
>But now that we want to use `type` to define tupe constructs, maybe adding name is not a big negative.
Why include word struct? we can omit it to make syntax more clear.
at one end: remove struct keyword and field names
at the other end: include struct and field names
It should be as easy as possible but I don't like code littered with $1, $0 and ... it makes code un-readable but one of my goals is make code easy to understand. So as easy as possible but with field name.
`type myt := (int x,float f)`  //defining tuple
`myt func1(){ return (x: 1, f: 1.1); }`  //return tuple literal
`x,y = func1();`  //unpack tuple
`auto x = (age:12, days:31);`  //tuple literal

N - Passing some compile time data to the code (e.g. release, debug, ...) which can be checked in the code.
This can easily be done via env vars or compiler options settings values on static classes:
`elec test.e --set MyClass.value1=9` This will set value of `MyClass.value1`.
How to do static check or conditional compilation? static checking upon compilation makes code and compiler complex.
lets do only `if` and compiler set value and `assert x != nil`.
These values will be set after creating the static instance and before calling static initializer.

Y - For type casting: `int x = f.int()` notation.
pro: syntax is consistent with others: a method named `int` is called. the operator notation is a little bit confusing.
con: if `f` is nil then what? we are using type name as method name? yes. its ok because int is not a keyword.

N - What is interpreation of these?
`void x` or `auto x = f.void()`.
Note that there is no standard on what this should mean. The fact that `x.int()` will cast x to int is something
in core. 
We can say `void x` is a variable where you can write to it but cannot read from it. Something like a sink.
But what is use of this? 
Maybe later. Maybe we can use this in templates. Where we want to define function pointer templates:
`func<int, float, char, byte> fp = ...`
`func: typename T; typename U: void; T apply(U input)`. 
If there is no input, U will be void and `int apply(void input)` means no input. This makes sense?
How can we implement such a thing? Goal is support for dynamic function pointers where user just writes input/output
and compiler infers the appropriate template.

Y - We can remove optional arguments with assuming missing arguments will be `nil`. And you can write:
`x //= 5` to set x to 5 if it's nil. and all parameters will be optional, then. 
Pro: more consistent, less syntax confusion, more flexible.
Con: maybe less familiar, more operators to learn, it is hard to know default value of arguments.

N - `int x = 12; int y = x; y++` will this change value of x?
This depends on how `=` operator is implemented for `int`. We expect it to `copy` value of x.
To make `y` refer to the same thing, `int y = x.ref()` which will return the x reference. In this case
`y++` will change value of x. x.ref may return `this`.

N - Can we have abstract methods? Can we do this so that compiler can write some call address at compile time?
suppose that we implement A's methods in B which contains an instance of A. What happens if in B's constructor we call A's constructor which calls some not-implemented methods which have body in B?
With adding each new feature, we are adding a set of cons and pros.
Pro: Makes sense, can be used to implement some of design patterns.
Con: Language will be harder to learn, can be implemented using function pointer, I prefer a simple orth language rather than a bloated language. Needs runtime method finding.
This may lead to need for protected methods. we should simulate protected by composing public methods.
This can be done if we assume methods as function pointers which are read/write. This adds no new notation.
`obj.method1 = this._mymethod;` or `obj.method1 = (x) -> (x+1);`. But this will have a lot of implications.
Pro: same behavior for field and method. read/write is defined for both of them.
So for fields we can read/write, for methods we can read/write/invoke. read by `x` write by `x=value` invoke by `x()`.
Who can write for methods? everybody? which methods can get values? all or only empty methods?
can we add new methods? definitely not.
if we say, only empty methods can be overwritten, this is not orth and general. but if everyone can change methods, then? is it bad?
this is limited to object instances. but can we handle protected?
How will this new method access private members of the class? This will add to the confusion.
We can implement abstract method by using fps.

N - If we compose X and define empty method A which exists in X too, the X method will be hidden from outer world and is only accessible by container object using `this.Xobj.Amethod` syntax. This is the natural behavior but also we can define appropriate interfaces for expose.

N - Ability to call input-less methods (property) without `()`
`int age() { return this._data; }`
`int x = obj.age;`
Note: This will interfer with notation of having methods as fields (ability to set method values at runtime to provide implementation for methods). `auto x = obj.age` what is type of x? is it int or is it a function pointer which returns int?

N - Naming: - **Naming rules**: Advised but not mandatory: `someMethodName`, `some_variable_arg_field`, `MyClass`, `MyPackage`. It's better for classes to start with lowerCase because then we can have `int` and `func` and ... .
`myClass`, `some_method`, `some_variable_arg_field`, `MyPackage`.

N - Trait?
trait vs composition: in trait, `this` is the container not the trait.

Y - No one should be able to alter class behavior without it's permission. Empty method body is some kind of permission which means others can propose bodies for this method. Other than that, container class cannot hide/shadow methods of composed objects. This makes sense for interfaces too because all they have is a set of empty methods which must be implemented.
```
//B class
int func();
int func2() { return func()+1; }

//A class
struct { B b => B; }
int func() { return 10; }
//Main method
A a;
a.func2();  //will this call A.func? it should.
```
we are changing value of `this` inside A (From A.this to B.this). but not for fields or private methods. 
`that` can be used to refer to the container. but we cannot assume the class is contained.
All this confusion and discussions about method hiding and overriding and rename and ... can be easily handles via other mechanisms like DI. Let's not make language more complex. But if something makes life easier for the developer then it's fine. 

N - When composing two or more objects, how should we handle conflicts?
rename/remove method? using hash? Rename is definitely not needed because eveything is inside the composed object until we hide something. This makes things more complex.
Even if we permit method overwriting, the new method won't have access to private vars. also there will be need for another mechanism to call the original method. 
solution: choose better method names, compose it in another class and compose that class, ...

Y - More control over co-routines (in golang dev mailing list they request for ability to set priority). Let's not use a keyword and move things to core. In this way we can have more control over the output. 
Do we really need a keyword `promise` for this? Can't we implement a special case in the `core`?

N - Ability to `paste` code from another class into current class: `mixin`. We can do this using expose. Although not exactly.

N - If class A wants to conform to interface I, it has to compose it with `=> I`. But what about interfaces which are not known by this class?

Y - Better syntax to check whether class1 conforms with class2? `if ((class2)class1) ...` is current notation.
`obj1 ~ Interface1`
`obj1 ~= Interface1`

Y - We can support implicit conflict resolution: If class1 exposes a and b and both have method `func` then a call to `class1.func` will be redirected to `a` if it is introduced earlier.

N - Treat methods and fields the same. They can be read/write/invoked. 
Note: `auto x = obj.age` what is type of x? is it int or is it a function pointer which returns int?
But no one should be able to alter class behavior unless it is explicitly permitted (empty method). 
current status:
field: read/write
method: read/invoke
`int x = obj.field1(); obj.field1(12);`  //read and write through invoke
`fp<int> = obj.field1` //read
maybe we can model everything through `read/invoke` mechanism. Treating everything like methods.
read will return an fp. invoke can be used to call or read or write.
`int field1(int value) { if ( value != nil ) current_data = 1 else return current_data; }`
This is not intuitive.

N - Now that everything is an object, can we add elements to `int[]`? No. Why? they can use `ArrayList` class.

Y - Syntax for throw/catch?
`throw 'a'; defer { auto x = catch(); }`
We can implement all this with a simple stack or storage system. store and retrieve. 
The only missing piece will be forcing exit. Maybe we need something like `strong return` or `forced exit`.
```
if ( error == 1 ) {
    global_stack.push("ERROR");
    strong_return;
}
//outside:
defer { if (global_stack.hasData()) { doSomething(); stop_strong_return; } }
```
but `strong_return` is `throw` and `stop_strong_return` is `catch`. unless we do some conventions!
For example, a strong return will be initiated if some variable it set (and only defers will be executed) 
and stop if it is cleared. For this purpose, we only need a simple flag. All other data (details of the 
exception) should be transmitted through another channel. For example `runtime.ex` is a bool which starts forced return
when it is set to true.
```
handle.setError("ERR");
runtime.ex = true;
return;  //!!??
//caller:
defer { if ( runtime.ex == true ) { runtime.ex = false; } }
```
but empty return does not make sense and is redundant. There should be two statements or function calls.
function call -> return will be missing. we need two keywords but throw/catch don't make sense now that they
are not going to send/receive anything.
`freturn`, `panic`, `eject`
but empty keyword without any parameter is not beautiful (we already have `break, continue`).
Maybe we can use `break` and `continue` here. 
Things we want to do: stop normal execution, check if normal execution is stopped, continue normal execution.
`break -1`, `runtime.isBreaking`, `continue -1`;
`set`, `check`, `reset`
`x=1`, `if(x)`, `x=0` -> but without keywords this 
`runtime.eject=true`, `if (runtime.eject)`, `runtime.eject=false`
The keyword should definitely act as return too, so we cannot simply set something.
```
data.setError("ERR"); eject; 
//outside
defer { if ( data.hasError() regain; ) 
```
```
data.setError("ERR"); runtime.mode=defer; return nil; 
//outside
defer { if ( data.hasError() runtime.mode = normal;) } 
```
This approach does not need a keyword at all.

Y - for post-condition checking, maybe its good to have a keyword/operator denote output of current function.
Also this can be used in `defer` to alter function output.
`defer(x) if ( x!= nil) x++;` this will be called after return and `x` is mapped to function output.

Y - Omit `() ->` when anon-func does not have input.

Y - Using `>` and `<` to check subclass superclass relationship? Note that type name is a static instance too. But how should we cast? 
`if (myObj > BaseData)` matches if myObj implements BaseData.
`if ( myObj < BaseData)` matches if BaseData implements myObj.
This is not very intuitive but is straightforward.
And does not resolve the problem of "type casting".
`if ( BaseData(myObj) != nil ) `  this is same as golang
`if ( runtime.cast(myObj, BaseData) != nil ) `

Y - Simpler than `iif`
`x = (x>5 : 1,2)`
`x = (if x>6 1 else 2)`
`x = (if x>6 then 1 else 2)`
`x = x>6 ? 1:2`
`x = iif(x>6, 1, 2)`
`x = x>6 && 1 || 2`
`x = x>6 and 1 or 2`
should be easy to compose:
`x = (if x>6 1 else if x<5 4 else 2)`
`x = (if x>6 1:if x<5 4:2)`  //second if is allowed in else section
`x = (if x>6 and x < 10 1, if x<5 4, 2)`  

N - What should happen when x is nil and someone refers to `x.data_field`? throw exception or return default value for data_field?

Y - Instead of runtime modes, we can have `throw x` to initiate exception and return and `defer(exc)` to recover.
`defer(out)` to catch function output, `defer(out, exc)` to do both.

Y - to handle built-in types we can define `struct(n){}` in classes which requests n bytes allocation for `this`, without any data field.

Y - Variadic functions?
go: `func sum(nums ...int) {`
c#: `void UseParams(params int[] list)`
java: `boolean bar(Object... values)`

Y - remove ternary operator

N - Read https://news.ycombinator.com/item?id=7277797 for reasons erlang is not popular'

N - Let's return default keyword. It will be used in switch and select. 

N - easier map/reduce/filter: -> core
`arr1.map(x -> x+1)`
`arr1.reduce(x,y -> x+y)`
`arr1.filter(x-> x>0);`

Y - Use `else` in switch:
```
switch(x)
{
    1: return 1; //if block is just one line, you can omit brces
    2: { return 2; }
    3: { return 3; }
    4, 5: x++;
    else: { return 0; }  //default
}
```

N - What should happen when we have `i == j` or `x = y`? suppose all vars are int.
`==` operator compares values for int.
for other types, `==` will compare references.
`=` operator makes a copy (for int)
for other types, `=` will point both references to the same thing. 

N - Lets have two operators, one for duplication and one for assign reference. Advantage: having uniform behavior
`x := y` will duplicate value of y
`x = y` will create a new reference to y
in smalltalk, assignment never creates a new value. so `x=y` will point x to y.
It should depend on the class and how it handles `=` operator. for primitives, it will clone and for others it will return reference. We can define `x = y.ref()` so x will point to y. and `x = y.clone()` so x will be a copy.
but `=` operator may refer to one of these two (duplication of re-reference), depending on the class.
If you want to be sure about the result, you can use `ref` and `clone`. but these are not standard.
same for `==`. You can compare `x.ref() == y.ref()` to enforce reference comparison. 
or `x.equals(y)` to enforce value comparison. `==` will map to one of these. 

Y - In smalltalk, `x:=y` makes x and y refer to the same object. and this is the only operator you cannot override.
everything is treated just like a class in Java: references no values. so if a parameter is re-assigned a value, 
original values are not changed.
We have `=`. 
Let's add an operator for `clone` data, unlike `=` which just copies the reference. `:=` is already used! but it is a really good candidate!
`:=` is currently used for: import ailas, type, typename default
`import aa := a.b.c; type myt := int; typename T := MetaClass1`
`import aa -> a.b.c;`
`import aa ::= a.b.c`
`import aa :=: a.b.c`
we can use `=` for these places.
`i := j; i = int.new(j);`
we can say `=` will work on references. to work on data, use constructor or methods you have:
`i = int.new(j); i = j.copy();` but it's good to have an operator for this purpose. 
It is not needed to be a combination of assignment and clone. we can define `:x` an opertor on x which 
clones x. so `y = :x` will assign a copy of x to y.
`y = &x` but this is confusing.
`y = @x`
`y = #x`
`y = $x` confused with perl and bash
we can have two operators for shallow and deep clone. e.g. @ and @@
or # and ##.

N - Ruby: frozen objects as an alternatives to `const`.
for compile time constant, we need them and it's ok. what about immutable data?
class fields
function argument
local variable
if we define a variable as const, can we assign it to a new object? can we mutate the object it is pointing to?
`const float PI = 3.14` if we can mutate reference the value of PI can be changed!
1) let people change PI and mutate consts, but don't let re-assign -> needs runtime checking
2) const means no re-assign and no mutation -> can be checked at compile time
but we cannot enforce no mutation on an object through compiler.

N - Future operators: Serialization/Deser (`string s = $obj1; x = #s`). 

Y - remove oeprator for deep clone. Lets have method for that.

Y - `@` for clone is not intuitive. maybe we can even remove it. Its only needed for primitives.
but things like this wont work if we remove this:
```
for(int i=0;i<n;i++) for(int j=i;j<n;j++) { ...}
```
any ++ on j will update i too! using `@` makes code pulloted.
maybe we can define default behavior for `=` as reference assignment and let classes override this.
so `int` class will have `op_assign` to duplicate the other value. 
what if we want to duplicate a big class? add your methods for that.
what if we want to reference assign an `int`? add method? `void ref_assign(int x) { this = x; }` maybe. but this 
should call `op_assign` which will duplicate vlue of `x`!
`x = y` will call `op_assign` operator on x which is supposed to duplicate (assume all are int).
or we can provide a core method for that:
`void construct_by_another_ref(int obj) { return core.reref(obj); }`
`int z = int.construct_by_another_ref(x);`
solution: if you want to assign reference, create another holder class. 
`MyClass x = MyClass.new(i);`
So both ref and clone are possible for all classes. But default behavior for `=` is determined by the class.

N - We can remove `{}` operator and replace it with anonym struct assignment. But `{}` does have a special meaning (memory allocation) which `()` does not.

Y - Can we remove `const`?
Maybe use something for compile-time constants and a more OOP style for constant and immutable.
What about assignability? can we assign non-const var to const obj.
can we pass const for template arg? for type declaration? 
what happens if we pass `int x` to `void f(const int a)`?  obviously, reverse is not possible.
we need immutability for keys of hash-table.
solution1: mark class as immutable
solution2: mark object as immutable using a method

Y - `type myt := (const int x, const float f);`
There are two types of immutability: variables based (define var type as const) which is immutable variable, class based (define class methods in a way that it's state won't change, like string or int) or immutable class. 
immutable reference is not useful for us.
if hash wants its keys to be immutable, it has to handle that. Store a copy and don't give it out.
mutable variable is not strong because we can have another reference which is not mutable. so its not guaranteed.
immutable can mean no change after constructor. but compiler doesn't know anything about constructor.
maybe we want a collection to be immutable in one case and mut in another.
if we want to define `int` immutable, how is `++` going to be implemented? no. we are not going to do that.
we need two things: constant values (object literals), and immutable classes (don't support change in state).
to support variables which cannot be re-assigned we can add some flag to the class, set it to true and `op_assign` will fail if it is called. Something like `bool can_be_reassigned`.
maybe we should rely on developer to write the class in immutable way.
const: in field decl means compile time const, in local var means only one assignment which calls constructor. in function input, means?
Lets remove `const` for local arguments. Use another keyword (and outside `struct` for compile time const, like type).
what about function input? we want to tell outside world: "I promise I won't change value of this argument. Of course it cannot re-assign the input, so change means change in the state of the object".
we can have permanent immutability (defined by the developer in the way he writes the class), and temporary immutability which is enabled/disabled at runtime. so if some class is not imm but we want to share it between threads, we can create and configure it and then make it imm. 
so we need to do two things: 1) a keyword to define constants outside struct 2) a facility/flag/method to make an object imm/mut at runtime. we can define an operator like `@x` which creates a read-only copy of x. in this way, there is no need to undo the read-only making. this is a deep read-only. we can replace operator with a method too and do not provide un-freeze method. user can clone the object if he is interested in reverting the action. but operator is more readable and findable. 
if you want others not being able to modify your object, give them a copy! but this is not good for performance or memory if you have lots of functions or threads.
its good to have something to make object read-only in-place so we can mark one part of an object read-only. when something is marked as read-only it cannot be re-assigned or changed. same for it's components.
`obj1.part1.make_read_only();obj1.part1.make_read_write();`
but this is a lot of work for runtime!
maybe a guarantee of not being able to re-assign it is enough.
solution: write your classes imm. share only imm classes with others.
function  are ok with re-assigning. they cannot re-assign input.
local var: it's local so developer can handle them.
class fields: they can be re-assigned by outer world too (if they are public). we can say, in struct `const` members can be assigned only once (if they are already nil). other than that, everything is handled by the developer. 
so we will have `const` to define object literals and struct members which can only be assigned once. deeper than this, it should be handled by the developer by defining appropriate methods.
What about object literals? we have two options:
1) object literals `const int x = 12` cannot be re-assigned but can be mutated (`x++`) -> same as other consts.
2) they cannot be mutated in any-way.
option one is easier to implement but 2 is better in terms of possible performance gain and code readability and optimizations. But if type of the variable is immutable, then first option and second one will be the same.
can we define something like `const myclass a = ...`, myclass being mutable and later want to change it? it is allowed (we are orth with min exception) but if you want to disallow it, use an imm type here. 
but there are places where we want to use mut object as imm -> this happens only for primitives, we will handle this by runtime and core.
we can guarantee to disable re-assignment with little performance loss. but for being read-only it is hard specially at runtime. `const int x =11;x++` should throw error. ok.
do we won't expose any state mutating method in primitives. `x++` will re-assign which will fire errors, but what if we don't want const and have `int i` and want to increase it's value? `x++` will be translated to `x=x+1` by compiler which re-assigns value of `i` to the new value without any problem. but `const int i=6` and `i++` will throw error.
according to compiler `lvalue = rvalue` will throw error if type of `lvalue` is const.
can we replace `const` with objects? for non-primitive, we can define a class which throws error on `op_assign`. for primitives, the same. but this will be a new type and combining it with normal `int` may cause problems. `cint x = 12` is constant int. `int y = x+11`? no. we need same type/class be able to be defined normal or const. 
const -> `op_assign` won't work. but its not enough/good to remove/disable this method. we need some declarative mechanism to make code readable. 
still we have this problem: `const float PI = 3.14; PI++`. 
one solution: classes can provide a method to disable change in the state. they will be responsible to enforce this check.
so: `const float PI = 3.14; PI.freeze(); PI++` last statement will cause runtime exception. ok.
and for `const myclass m = ...; m.update(1,2);` we are updating a const but its ok because const is not supposed to prevent this. for primitives: `const int x =12; x++` will throw error.
```
type myt := (const int x, const float f);
myt a = (x:1, f:1.1);
a.x++; //throws error
```
we can achieve `const` result by classes and add `.int` method for type conversion. and have compiler automatically call this in case needed. `cint x = 12; x++` throws runtime exception, because `cint` class checks state in `op_assign`. By this way we can implement full read-only classes too.
`type myt := (cint x, cfloat f);`
what if some function expects `int` and we pass `cint`?
`void f(cint x){} ... int a=12; f(a);` compiler will call cint.int(a) to create a new instance of cint using `a`.
`void f(int x){} ... cint a=12; f(a);`
MyClass.int() will convert an instance of MyClass to int. `MyClass MyClass.int(int x)` will create a new instance of MyClass based on int x. but this makes things more confusing.
there are 3 ways to provide const: 
1) a different class (int vs. cint)
2) same class with suffix (int vs. int&)
3) same class without suffix, only internal flags (int.make_const)
we want this to be compile-time check. for run-time checks, everything is to be done by the developer.
`const int g; g=1;` how is compiler supposed to know this assignment is the only one?
I think we cannot force this at compile time because we are allowing almost everything.
One solution: Using `{}` to set value for const members. so, const members cannot be assigned unless in `{}`.

Y - `const` and immutability: summary of findings
there only two possible places where we can enforce const at compile-time: upon definition and using `{}` operator.
we can also define `int` and `cint` for mut and immut variance. or `int` and `int&`. and do the casting automatically by compiler but it will have an overhead. does that make sense to cast const to non-const?
one solution for imm problem: pass copies of the object to others -> memory overhead if we have thousands of threads.
const variable: cannot be re-assigned -> ?
const class: state cannot be changed -> up to developer, we don't have anything
also we have object literals.
we can define `cint` which can accept an int and does not provide mutations or `op_assign`. we cannot cast `cint` to `int` automatically. 
for object literal we can say, `int x = 12` means x will never change, so no keyword will be needed to define an object literal.
Proposal: Any assignment in `struct` section, is either 1) object literal or 2) value.
for 1, compiler will assign rvalue to lvalue and no other `=` will be allowed. 
for 2, `op_assign` won't be called, the rvalue will be copied into lvalue upon instantiation and no assignment will be allowed by compiler. (const by nature).
so basically, 1 and 2 are the same. 
if you need to make some variable const (un-re-assignable) but cannot instantiate it on `struct` section (maybe you need some data to be passed to it), compiler/language cannot help you. 

N - How data casting is handled? for example when we have `float f = int_var;`
list the methods that compiler calls for casting and their priority.
first compiler tries to convert rvalue to lvalue by calling `float int_var.float()` method.
if method does not exist, tries `float float.int(int_var)`

N - Can we introduce zero cost type casting where no data casting is involved? it is dangerous.
and its not much needed.


N - We can even outsource `if` statement to core but there should be a trade-off.

Y - we can define `int` method for type conversion. what about converting to array? What if I want to convert string to `char[]`? what about template classes?
`char[] Array<char>() { ... }`

Y - Make composing easier by introducing some syntax like: `compose MetaClass1;` which adds a variable with the same name and exposes all public methods. and can be customized by adding interfaces. 
`MyClass v1 => MetaClass1, MetaClass2;`  
one solution: define a new section like `expose`.
```
struct {
    int x;
    float f;
    MyClass c exposed;
}

expose MyClass => MetaClass1, Meta2;
expose MyClass2;  //expose all public members
expose {
}
```
what about doing vtable works in a user-written method?
`this.extend(this.var1)`
`* => this.var1.* [MetaClass1]`
expose fields and functions separately.
think about a class which wants to extend `int`.
expose has two parts: data and methods. why not have them separated? 1) define member var 2) expose fields 3) expose methods. if we define it inside struct, it does not make sense to define methods there.
`:=` notation?
outside struct -> what about fields?
inside struct -> what about methods?
so maybe we need a separate section
what is purpose of struct? define fields of the class
what is the purpose of next section? provide method signature + bodies.
now we want to add a bunch/batch of methods and fields to the class.
`promote(MetaClass1(this.var1));`
```
struct { ... }
promote { var1 => MetaClass1; }
```
if user wants to filer/map exposed methods, he should do everything manually. We will support only basic expose which applies on all public members. `MyClass x;`?
what if we want to expose only methods or only fields?
let's have a two part definition: in struct we "can" expose fields. in outer, we "can" expose methods.
but this makes things more complex. exposing methods without fields, as a default behavior is not orth.
what if object methods were writeable and we could add to the collection? like `this.methods.addAll(this.var1.methods);`
`methods` acts like a hash-map. no! this will introduce a lot of complexities.
we can delete an exposed method by adding same method without body.
we can rename an exposed method by deleting it and writing our own method.
so we will expose all methods. user can remove/rename them.
also name is irrelevant. because there is only one expose per type. if we expose two fields of the same type there will be a lot of conflicts (we cannot define methods with the same name). so we can assume, field name is same as type name.
`this.MyClass = MyClass.new();`
`expose MyClass;` will add public fields to struct section and methods to method section.
`expose MM := MyClass;`
can we use convention here? no.
this should come before struct section, after type section.

N - How do we new anon class? `auto x = MetaClass { ... }`? Compiler is supposed to not know anything about this.
If type is interface (no data), we don't need to instantiate anything.
but if type is abstract class,

N - closure read-only access: clarify

N - note that static instance is not re-assignable same for `this`.

N - How can we define a stack to store arrays of all types? 
java: `void push(Array<?> x) { ... }`
java: `void push(Array<? extends IEnumerable> x) { ... }`
Not possible unless all of them have a common interface which can be used. 

N - So we can call `obj.method1.apply()` same as `obj.method1()`. because `obj.method1` is of type interface.

N - If we have many methods with the same name in a class definition and only one of them has a body, its fine.

N - The language can even compile to java bytecode. but its not good because end user will need to install jvm.

Y - Naming: Stack is better than stack. So Almost everywhere we want to have UpperCamelCase, except for basic data types.

Y - We can also have traits where all code of another class is coppied to the current class. 
like `include MyClass;`
or `mixin MyClass;`
what about constructor? it will be copied too. so either mixin should have no ctor or the parent class cannot have ctor.
`mixin MyClass<int>;`
include is better because using mixin will imply that we don't have trait. but our classes can be a mixin or trait.

Y - Also we need promise. if it is defined in core, compiler will need to have special attention to this special method.
start a co-routine -> `async` (scala), `invoke`, `tasklet`, 
`task<int> a = async func1(10);`
a.andThen(...);
a.wait();
`future<int> result = promise ...`
`result.wait(); result.andThen();...`
for future we can use channels. for 'andThen' we can compose/pipeline channels.
`fn<int> result = promise ...; int x = result();`
Still there is no need for keyword here.
`auto x = core.runtime.promise(...);`
`future<int> result = invoke a.getData(10);`
`future<int> data = invoke { x++; y.copy(); }`
`future<void> result = invoke { x++; }`
`future<stack<int>> dd = invoke { x++; obj.method1(); channel.sendData(1); return nil; }`


Y - Channel and go keyword built-in, select.
channel (read only, write only), buffered or un-buffered: classes in core
select 
time can create a channel which will send a signal at time "X"
maybe we can represent go's select using a special channel, multiplexer, this can support variable number of ch too
we can call `channel.canRead` or `channel.canWrite` to check for select statement.
we should be able to create a ticker class whcih will send to a given channel at a specific time.
```
select
{
    rchannel(a): { }
    wchannel(b): { }
    c: {}
    default: {}
}
```
will run appropriate code when any of choices is ready (rchannel is ready for read, wchannel ready for write)
or default if none is ready.
channels are very good candidates for core classes. 
But we are combining core classes with language syntax. is it good?
Read http://www.jtolds.com/writing/2016/03/go-channels-are-bad-and-you-should-feel-bad/ to solve some of Go's problems about channels.
what if we need to do `select` on a variable number of channels?
select on other data like mutex?
maybe we can combine for and select to support variable number of channels.
channels should have dup which enables multiple senders, each closing its own clone and channel will be closed when the last sender closes.
how should we store read output/write input?
```
rchannel r1 = ...;
rchannel r2 = ...;
wchannel w1 = ...;
wchannel w2 = ...;
rwchannel rw1 = rwchanne.new(r1, r2, w1, w2);
int d1,d2;
index = rw1.select({ r1: d1, r2: d2, w2: "A", w2: "B");  //index=0 -> r1 read data into d1, 3=> w2 wrote "B" data

auto mx = mxchannel.new(w1);  //multiplexer channel
auto c1 = mx.newChannel();
c1.send("A");  //send "A" to w1 channel
```
we can use `tryxxx` methods:
```
select
{
    rch1.tryRead(): { a = rch1.peek();}
    rch2.tryRead(): {b=rch2.peek();}
    wch1.tryWrite(x): {}
    wch2.tryWrite(y): {}
    true: {}
}
```
select will loop through items, until one of them returns true or not nil.
```
select 
{
    exp1: {}
    exp2: {}
    exp3: {}
}
```
select will evaluate all expressions until one of them is evaluated to true.

N - It is better for `invoke` to return a general `future` class so we can compose them more easily.
`future result = invoke a.getData(10);`
`future<int> data = invoke { x++; y.copy(); }`
`future<void> result = invoke { x++; }`
`future<stack<int>> dd = invoke { x++; obj.method1(); channel.sendData(1); return nil; }`
`int x = obj.method1(10);`
`future<int> x = invoke obj.method1(10);`

Y - Suppose we have a template class `future<T>` can we add a method which is supposed to work on another template class?
e.g: `void chain(future<S> otherFuture) { ... }`
`void chain<S>(future<S> other) { ... }`
`future<int> x;`
`x.chain<float>(ff);`
what if we remove typename for argument?
`void chain(future other) { ... }`  //this chain method accepts a future. future is a template class but we don't care about it's typename. it can be future<int> or future<float> or anything.
of course we can only call methods in `other` argument which are not bound to a typename. 
so when a class is defined and has one or more typenames, it can produce many variants. the most basic one is the original class without typenames applied. this will create an interface which is conformed by all created classes with concrete typenames. So in this class we are defining two things: A common part which does not rely on typenames (base interface) and a typename dependant part. All created classes: MyClass<int>, MyClass<float>, MyClass<x> conform to the base interface. so you can use the base interface "MyClass" to describe all of these classes. Of course the base interface does not have any field or method which is bound to typenames. so "MyClass" means MyClass definition without any of typenames.
so we can write `void store(Stack s)` where Stack is the base interface and we have `Stack<int>, Stack<float> ...`.

Y - InterlockedExchange and other atomic operators, compare and swap, only for numbers
`bool changed = (x == 1 ? 2);`
`bool changed = (x ? 1 -> 2);`
`bool changed = (x ? 1 => 2);`
`bool changed = cas(x, 1, 2);`
`bool changed = x => 1 => 2;`
`bool changed = x => (1, 2);`
`bool changed = x ? 1 : 2;`

Y - Shall we use a more consistent casting method used for both type and data casting?
`int x = float_var.int();`
`int x = int(float_var);`
`MetaC x = MetaC(myOBj);`
`int x = int.float(float_var);`
there are a lot of different ways to convert something to another type.
`myclass mc = myclass(obj1);`
above: cast obj1 to myclass. if obj1 type conforms to myClass it is ok.
if obj1 has a method called `myclass` it will be called.
if myclass has a method called `ObjType` (which is type of obj1), it will be called.
advantage of `()` notation is that you can easily concat it to a method casll: `myClass(obj1).method1()`.
`auto mc = myclass(obj1);`

N - can we embed and implement methods for the static instance? NO. `expose` statement includes a non-static instance of a class.

Y - Initial value of MyClass should be `MyClass(nil)`?
```
if ( found == true ) return @MyClass(nil);
MyClass x = @MyClass(nil);
if ( result == @MyClass(nil) ) ...
```
we can eliminate `nil` and instead write `@MyClass()`.
this is the casting syntax but without input, which gives empty/undefined/not-initialized state.
this can be short-cut by `@MyClass`.

Y - Make casting a little more explicit. e.g. `#MyClass(obj2)`
`int x = int(float_var);`
`int x = @int(float_var);` Good
`int x = $int(float_var);`
`int x = #int(float_var);`
`int x = !int(float_var);`
`int x = float_var->int;`
`int x = float_var as int;`
`int x = int((float_var));`
`int x = int<float_var>;`
`int x = int{float_var};`
`int x = int[float_var];`
`int x = $int$(float_var);`
`int x = cast<int>(float_var);`

Y - `??` shorter operator.
`y = x ?? 5`
`x ??= 5`
`if ( x == @MyClass )`
`y = x # 5`
`y = x || 5`
`y = x \ 5` GOOD
`y = x, 5`
`y = x; 5`
`y = x .. 5`
`y = x <- 5`
`y = x <- 5`

N - Enum and template, type alias, casting, null, tuple, ...?
`type DoW := int (SAT=0, SUN=1, ...);`
template: enum can be used for typenames
type alias: enum is defined using type alias.
casting: `int x = @int(dow_var);`
null: they are of type `int` so they can accept `@int` value.
tuple: enums can specify type for fields of a tuple.

Y - `y = x # 5`
`x #= 5`


N - How can we eliminate static instance of a class? If we don't really need it.
`_() { MyClass = @MyClass; }` but the static instance is not assignable.
`bool _() { return false;}` return false to discard static instance.
how can others instantiate class if it doesn't have any static instance?

N - can a class modify it's own methods?
e.g. cache method output, log, ...
it becomes complex.

N - What is the actual difference between `expose` and `include`?
Both import methods at the class level. 
in expose, called methods, have this pointed to the internal variable.
in include, called methods, have this pointed to the class itself.
can we combine both of them?
`expose MyClass [that=this.MyClass];`
`include MyClass [that=this];`
regarding hiding, deleting and renaming both are same. also for implementing bodyless methods.
methods -> exactly the same, methods are imported into the class
fields -> same, actually this.x will point to this.MyClass.x, but in include, this.x will refer to this.x
expose := introduce a field named MyClass in struct, for all fields of MyClass add same field to struct, for all methods of MyClass add same method to the class, these fields and methods will be mapped to the field
include := for all fields of MyClass add same field to struct, for all methods of MyClass add same method to the class, , these fields and methods will be mapped to this. 
`expose means attach to this.MyClass`
`include means attach to this`
maybe we can simulate expose as a special case of include. an include which pastes data from a member field.
`include MyClass;`
`include this.MyClass;` -> add this field to the struct of the current class, then embed all of it's.
`embed MyClass;` and `embed this.MyClass;`
`provide MyClass;` and `provide this.MyClass;`
expose: expose public methods of a field, nothing to do with private methods or any of fields.
include: expose public methods of a field, include private methods and all of fields.
`public MyClass;` and `publish this.MyClass;`
`+MyClass;` and `+MyClass => this.MyClass`
If the class has not state, then expose is exactly the same as include.
we can add a syntax to map fields. for methods it is pure code but for fields we cannot write code.
`int x := this.myobj.field5;`  //x is an alias for this.myobj.field5.
by this syntax, we will have a full coverage for expose using built-in syntax. 
so we can fully implement expose using normal syntax (delegate for methods and fields).
so again, how can we unify expose and include?
`include MyClass;` and `include this.vv := MyClass;`
when exposing, you can hide methods. when including, you cannot hide them -> we can enable hiding for inclusion.
when exposing, we don't have access to private methods, when including, we have.
`expose means public inheritance: Class x public y`
`include means full inheritance: see public and privates`
can we say, include is an expose which has access to private members?
the main difference is meaning of this inside methods. for include this is the same as container object.
include cannot be redirected to a member field. its definition is inconsistent with being restricted.
`expose MyClass as this.MyClass;`
`expose MyClass as this;`
`this += MyClass;`
`this += this.MyClass;`
expose and include are the same for public fields. they are similar for public methods too.
the difference is for private members. 
`include MyClass;` `include MyClass with privates;`
`expose MyClass [MyClass::this := this.MyClass];`
`expose MyClass [MyClass::this := this];`
we can eliminate the common part `MyClass::this :=`
`expose MyClass [this.MyClass];`
`expose MyClass [this];`
==
`embed MyClass into this.MyClass;`
`embed MyClass into this;`
==
`expose MyClass [this._myClass];`
`expose MyClass [this];`
==
`this += this._myClass;`
`this += MyClass;`
==
`bind MyClass to this;`
`bind MyClass to this.MyC;`
==
or a general re-direction system.
`this.* => MyClass;`
`this.* => this.MyClass2;`
==
expose works with variable
include works with class

N - In `expose` can we get the exposed object from outside instead of instantiating?
yes. Class is responsible for all of that.

Y - When we `expose MyClass` how are fields of MyClass handled? what happens to them? are they exposed too?
we do not support redirection of class fields. but we can add the syntax: `int x := this.obj1.field5;`
can we use this syntax in the code too? inside method body?
this is assignment but without cloning. if `int` assignment, duplicates upon assignment, `int x = this.obj.field1` will
put clone of the field1 into x. but if we really need a reference to that field we use this syntax.

Y - Same as what we have for fields `:=` we can have it for methods.
`int get(int x) := this.obj.myMethod;`  any call to `get` will be redirected to this.obj.myMethod.

N - What if a class requires existence of a method/field when being exposed or included?
This is related to conflict management. for `expose` this is not needed because exposed member does not interact with the parent class, but when including MyClass, how to specify it needs existence of a method or a field?
one solution: add the method or field inside the class and use it normally. When this is included in the parent class, it can provide body for the method. but for field, it cannot re-define the field because there will be conflicts. it will use the same field. 

Y - When we include MyClass and hide one of it's methods, how can I call the original method?
```
include MyClass;  //has myMethod
auto abc := this.myMethod;  //store a reference befor hiding myMethod
void myMethod() { this.abc(); }
```

Y - How developers can handle field conflicts? for include there is no problem because we expact included class to 
provide common fields. but what about expose?
we cannot say expose only copies public methods to the container class.
what if we expose two classes that have a common field?
one solution: if there is a conflict, nothing will be exposed. all of conflicting fields will be removed.
one solution: compiler error upon conflict in fields unless main class has a field with the same name.
