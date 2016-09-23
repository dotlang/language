Electron Enhancement Proposals
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

Y - Do we need both optional argument values and method overloading? Not probably. Because latter is only needed when former is not supported. So let's remove this functionality.

Y - Can't we remove tags? Instead of specifying tag for each member, class can add a `getTag` method (whatever name it wants) and when another methods will need tags, send output of this method to that function as a hash-ref. So for example 'json_converter` class will receive a json string + a hash + empty class, then will initialize empty class using hash data and json-string.

Y - Instead of using `exposed` or `* -> this.memberName` we use struct members without name (like go). We don't need their name because all public operations are available through `this`. By this way we can easily override functions by adding them to the owner class. 

N - Maybe in other places where we are using convention, we can do like anonymous field and remove some part of the source code and delegate the task to the compiler.

Y - In function declaration, let's remove -> notation. Although it has a little convenience but is not much readable.

Y - Same as the way we provide inhertance in classes, we can do similar in interface extension.

Y - Calling assert in the middle of method definition is not good. We use anonymous block. 

N - If class A embeds class B and still overrides some of B's methods, it is still possible to call overriden methods of B by using `this.B.methodName` notation.

Y - Lets standardize constructor name as `new` or `_new`. Because it will become too confusing when people want to create a lot of classes from a different vendors. But we can get rid of `new` and `@` keyword by adding a new instantiation method. We can also remove need for `_new` by stating that no class can prevent others from instantiating it. So there is no need to define `new` or `_new` methods. Other can use `MyClass.member` to access static instance or `auto x = new MyClass {x: 1, y:2}` to create a new instance. Any heap allocation means `new` in the back-end so even array or hash definition by using `[]` or `{a:b}` notations is handled by compiler to use `new`. Or we can even remove `new` and use C++ uniform initialization: `auto x = Class1 { initdata };`. Note that if `Class1` is name of an interface, this will create an anonymous class.

Y - What if we need some initializations for the static instance? Only the owner of an instance knows what to do for init but static instance has only one owner which is compiler. Without static init, the code should handle this but how can it guarantee that this will happen only once? We need to add a section to `main` and each time we need a static instance, call `MyStatic.init()` in that part. Solution: Without changing anonymous block, enable init-code inside this block.

N - How to do compile time checks? Like assert or check template args? Deprecated module? For deprecated we can add assert to static init block. For template args, compilation will fails if they are not appropriate. Let's do this later.

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

N - After all ambiguities are resolved, I will need to write specification where exact behavior of each statement and exceptions and notable points should be specified.

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

Y - Better and cleaner conflict resolution rules.
This does not happen for expose. At worst, item won't be promoted.
but for include, we have to decide whether we can or cannot include.
nobody should change a class behavior without its permission (empty methods). so if there is a conflict
it means compiler error.
we cannot add dot to methods names because then it will be mistaken with variable names -> confusing.
adding prefix makes the code un-readable too.
whatever we do for methods, is not extendable for fields. 
maybe we can say, included classes are all embedded within their own scope.
In this way, all fields and methods of the class are prefixed with a given symbol. If symbol is _xxx they all will be private. `include MC := MyClass;int x = this.MC.data;this.MC.method();` or 
`include __mc := MyClass;int x = this.__mc.data`
so, in syntax, it is same as expose. here we create a variable too but variable is mapped to this:
`this.MC` is same as `this`: `this.MC := this;`
```
expose MyClass;
expose MM := My2Class;
expose MyClass [MyClass::this := this.MyClass];
expose MyClass [MyClass::this := this];
expose MC = MyClass;
expose MC := MyClass;
```
expose creates a real variable. include creates a reference for scoping.
`this.MC.method1();` MC IS a variable but it can be either a real variable or a reference variable.
`this.MC = MyClass.new(); promote this.MC;`
`this.MC := this; include MyClass into this.MC; promote this.MC;`
expose is normal variable declaration (composition) + promote.
include is meta variable declaration + promote.
`MyClass mc [exposed];`
`include MyClass into this.MC;` => `namespace MC := MyClass; promote this.MC;`
`expose MyClass into this.MM;` => `struct{ MyClass MM;} promote this.MM;`
suppose that we don't have any promotion. just focus on include/expose behavior:
=> can't we just define the mixin as a normal class and pass `this` to it if its needed?
and for expose, we can simplify the syntax.
e.g.:
`struct { MyClass M; int x := this.M.x; } auto f := this.M.f;`
we don't want to be another D language. This should be simple. even at cost of not having some features.
so let's remove include.

Y - Using type with import to do aliasing.

Y - is syntax for typename intuitive? do we need multiple interfaces?

N - Easy way to check if method X has a body (is not undef)?
`if ( this.method1 == @fn<int,int> ) ...` is too long.

Y - Maybe its better to remove `:=` notation for method declaration.

Y - Better syntax for expose? 
Better is we reduce usage of `:=`. 
`expose MyClass;`
`struct { MyClass M; auto * := this.M.*;} auto * = this.M.*;`
```
struct 
{ 
    MyClass _var; 
}
```
lets force exposed variable to be private (user can easily map a public field to it).
and rely on a naming convention.
`MyClass __m;` OK
`MyClass _m_;`
`MyClass _$m;`
`MyClass _xData;`

Y - Let's reduce usage of `:=`
type, typename
`typename V : interface2`
what if we don't specify default value? Everyone has to specify type.
but how can we model tuple and fn then?
`typename V : interface2 = default`
let's assume there is no default and if type is not passed, it will be `void` type.
`typename V : interface2`
same as typename, we can use for type. we can even remove `:`.

N - If `Stack` is parent of `Stack<int>`, what happens if Stack has a default value for T?
How can we refer to Stack without any template arg? `stack<>`?
this may be the difference between `Stack` and `Stack<>`.
`Stack` means the stack class without any type related code (field and method)
`Stack<>` means stack class and set T to void.

Y - Using type for import alias is not good. Lets revert to `=>`

Y - Remove compare-and-swap operator. it is complex and makes language confusing. so `=>` is solely used for import.

Y - Can we somehow get rid of type? or at least make it class internal?
also same for typename. 
type: define tuple, type alias, enum.
if we remove type keyword, we have to find a way to do all of these.
what about removing typename?
`typename T interface1;`
`type T interface1;`
we can use convention. if type name starts with ??? it is a template.
`type __T interface1;`
`type $T interface1;`

`type X := int;`
`type Y := int(A=1, B=2);`
`type Z := (int x, float f);`
`type T := ?` 
when a type alias does not have a value, it means it will be provided by outside world. 
but how can we specify expected interface? do we really need it? we can write a comment!
`type T;`
`T.method1();`
now if someone creates the class with a T type that does not have method1, there will be a compiler error.
so typename is changed to type without value.

Y - Why do we need the `struct` keyword? It's functionality is just to separate variable definition from other parts but we don't really need a keyword for that.
the only usage is for basic types like int to define `struct(4)` to have 4 bytes allocated. but this is not for everybody.

N - can we define a class which forces to be allocated on stack? no. because it will complicate everything.
`int x = y+z;`

Y - How can we define local static variables? Each piece of code is located inside a method which is inside a class. 
a static local variable, is a variable added to the parent class which is only accessible by that method. 
```
int x;
int f() { this.x++; return this.x;}
```
how can we define `x` inside method `f` but denote it should preserve value between two calls?
`int this.x;`
`int _x;` variables starting with underscore are static.
first one makes more sense;
```
int f() {
int this._x;  //x should be uniqe inside the class. this is a private variable inside the class
int this.y;   //y is unique name and is publicly available
this.x++;
```
so methods can add fields to the class. in addition to the fields section of the class.
q1: this will make code un-readable. because we really don't know full list of fields of the class.
so -> local vars cannot start with underscore. 
if they start with `_` they are local static variables of the method. 
by this way, we are orth. underscore is valid inside a method. 

N - What if function argument name starts with underscore? is it valid? does it have a special meaning?
solution 1: they can have underscore and it does not have any special meaning.
```
int f(int x,int _y) {
    
}
```
this shouldn't be related to the type. 
1) it can denote not nullable arg.
2) we can say _ is forbidden. because it will confuse things with local static methods.

N - Can we implement memoization with local static fields? yes we can.
```
int f() {
    int _result = 0;
    if ( _result != @int ) return _result;
    
    defer(out) _result = out;
}
```

Y - when checking for undef, can we remove type if it can be inferred?
`if ( x == int@ )`
`if ( x == @)`

Y - Still `#` notation is not good.
`x # 5` will evaluate to 5 if x is in undef, else will be evaluated to x.
`x // 5`
`x ?? 5`
`y=x; if ( x == @ ) y=5;`
`x ?? 5` this can be better combined with `=`
`x ?: 5`

N - double underscore for exposed is a little bit irregular.
`MyClass _x; MyClass x := _x;` adding public field with the same name. but this is not as obvious as double under.
`MyClass MyClass;` public fields with the same name as the type, are exposed. adv: we are sure that they will be exposed only once.
`MyCalass _MyClass;` private fields with the same name as their type are exposed. but what about templates?
`Stack<int> _Stack<int>;`?
we cannot enforce name = typename in a simple manner.
`MyClass __x;`
`MyClass _x =:;`

N - Can we have python decorators?
normal way: write a new class, expose class X, write your own method which inside calls, `this.__var.method`.
No. they make code complex and are easily doable without new syntax.

N - can write `auto f = core.std.create((x, y) -> x+y);` for function definition?
it shouldn't be allowed. this syntax is a shortcut to assign one func to another.
if you need a more complex code, just write a body for the function.

N - Can we have a method named `Stack<int>`? This is needed for casting methods. -> yes we can.
Converting MyClass to YourClass: `yclass = @YourClass(mclass);`
1) call mclass.YourClass method: `yclass = mclass.YourClass();`
2) call YourClass.MyClass static constructor method: `yclass = YourClass.MyClass(mclass);`
now what if either of them is a template? yes. why not? we can even add `Stack<T>` method to a class and
have it with a dynamic convertor.

N - Shall we add something like perl POD? No. not in language spec.

Y - Assigning value to function input is allowed but has no effect outside scope.
most important usage: null set: `input ??= 5;`

Y - Being able to call a function which takes 5 arguments with 3 arguments is dangerous. developer can make mistakes. 
the code will accept 3 args and simply assume undef for the rest.
`int f(int x, int y, int @z);` this means z is optional and will be undef if it's not passed.
or we can return explicit optionals.
explicit is better than implicit. maybe function really needs some arguments. they cannot all be optional.
`@z` is confusing with `@` notation. `_` is also used for local static variables. 
`int f(int x, int y, int? z);` means z is optional. where else can we use `int?` notation? field declaration? no.
local variables? no.
`int f(int x, int y, Stack<int>? z);`

N - `int` should be just like other classes. So we have to think of a clean/good way of representing the class source code. memory byte needed and methods which are not implemented in the source.

N - Are we going to support reflection?

\* - How runtime should handle immutable types (e.g. int)? Can we treat them just like primitive non-class, and copy their value upon any method call? without allocating heap space.

Y - What is suffix for double literals? f or d? 
by default compiler tries to convert literal to shortest length.
`auto x = 12` if we want x to be long we should suffix it with `l`. 
Like hava `l` for long and `d` for double. 

N - Using `@` as an operator to check for null?
`if ( @x ) { }` @ClassName is for conversion
`if ( @this.MyClass ) {}` null checking
`if ( @MyClass ) {}` casting
`if ( M == @MyClass ) {}`
no. it will be confusing.

N - Still not comfortable with double underscore notation for exposed. 
also the field name should be optional but cannot be same as class name.
`MyClass __abcd;`

Y - Can we support template specialization? e.g. having `Stack.e` and `Stack<int>.e` files.
but we cannot have `<>,` in a filename. 
maybe we can replace `<>` with `[]` because `a[b,c].e` is a valid filename.
makes sense.

Y - `{}` can also be confusing. can we use another operator?
```
MyClass new(int x) {
    auto result = (x:1);
    resut.x = x;
    return result;
}
MyClass new() return $();  //shortest form
```
maybe we can use `$()`. It is also compatible with anonymous tuple notation too.
and `$(4)` will allocate 4 bytes of memory for `this`.
we shouldn't mention class name, it should be implicitly defined.

Y - `x==y` does it compare references or calls `equals` of `x`?
proposal: make ref equality and value eqality same thing, like string interning in java.
which means, primitive data classes must be immutable.
So, according to spec, `==` will compare references. To compare values you should use `equals`.
but for primitive classes, `==` is fine -> developer should not memorize which data it is comparing.
and interning will add overload to the runtime!
proposal: `==` has it's own operator called `equals`.
if `x==y` means they have the same content. but maybe they don't refer to the same thing.
so how can someone compare their references?
proposal: casting a class to int. `@int(x) == @int(y)`
casting a class to ref: `@ref(x) == @ref(y)`. `ref` is a built-in class which has `equals` operator to compare references.
can we use `if ( x :== y ) {...}`. It is simpler but maybe a little confusing.
what if a class does not have implementation for equals? it is like calling an un-implemented method.

Y - How should `int` set it's initial value? 
suppose we have `int x; x = 5; x = 6;` how is assignment handled in the code? 
we assume `int` is immutable. so is the above code possible? > no. it should throw error (by compiler or runtime, we don't care as of now).
you can write `int x=5; x := 7; x:= 8;`
or `int x; x = 5; x:= 7; x:= 8;`
initially `=` is ok but after assignment it's now allowed (for imm types).

Y - How can developer/compiler know if a class is immutable?
proposal: if class has an empty assignment operator? no. this is not enough.
if there is no field (e.g. `int`) or all fields are constant and immutable.
No. if class has a set of imm fields and re-assigns them, the state will change.
but having no field, is not enough for being immutable.
but for a complex class which wants to be immutable, what if we assign values upon instantiation?
maybe with a syntax like: `auto x = {x:1, y:2};` we can assign value to fields, upon instantiation.
so we need to define x and y as constant (assign some dummy value), and pass values in `{}`?
proposal1: add a new keyword. 
proposal2: define conditions: if class does not have any field then compiler assumes it is immutable.
why do we care if class is immutable? compiler can optimize the code if the variable is immutable. 

Y - How can we assign values for `const` fields of the class if they are immutable, after creation.
in `{}` we can assign value for any public field we want, but those with assignment in field section will not be re-assignable.
but we can assign value for fields normally using `result.value` notation.
but can we write `result._field1=12;`? we shouldn't be able to do that. we should add a method like `init` and call it from constructor. so we cannot set values in `{}` for private fields too.
suppose some fields are const and immutable, how can I assign values to them upon creation of the class?
proposal: fields with assigned value are const but can get value in instantiation operator (public or private).
I think methods of a class should have full access to all variables of the same class. Because else how can we write an `equals` or `clone_object` or `init_from` method in a simple and clear manner?

Y - immutability
if a class does not have any field and is immutable then compiler will do interning for it.
if a class is immutable and small (like `int`) when `f(int x)` is called, compiler can simply copy the value onto the stack. 
if we keep it on the stack, how runtime should handle this:
```
int x = 12;  //this is on stack
obj y = @obj(x);  //y is an object
int z = @int(y); //can we assign y to an int?
long z = @long(y);  //how can we know this is not correct?
//how can we know exact type of y?
```
proposal: in non-primitives, we store actual type. so when we have `obj y = @obj(x)` y needs to keep track of it's original type.

N - We should not have access to another object's private fields and methods even if current method if a member of the class. so how are we going to make sure, new instance is initialized? if we add a public method to do that 1) code becomes more compilcated. 2) other can also call it at anytime!
so, who is responsible for assigning private fields and calling private methods upon creation and how?
constructor is responsible for all that and it has access to all privates.

Y - Provide a more explicit syntax to declare container class has an implementation for an empty method of contained class.
In container: `int __member.method(int x) { return x+1;}`. Where `__member` is an exposed field which has `method` method empty. what will be type of `this` inside method body? Of course it cannot be contained class. So it will be container class. This may be a little confusing but is logical. but what does c++ do when a class override? It does not specify anything. But in C++ there is no composition but inheritance. 
By this way, we can provide implementation for multiple composed variables if they have methods with the same name.
the advantage: it is explicit and more flexible.
disadvantage: a little bit confusing.

Y - What if we have const fields (not re-assignable) but cannot determine their value in fields section?
`int x := 1; ... auto result = @(x: 5);` - does not make sense. assigning a dummy value.
`int x :=; ... auto result = @(x: 5);` - is not beautiful. although makes sense.
`const int x; ... auto result = @(x: 5);` - makes sense. but makes language more complex. but explicit is better!
`const` can be used in field definition to denote a field which will not be assignable once it has been assigned a value either through `=` or `:=`.

N - `const` is not good for a variable which can change. 

Y - Why `int x=6;x=7;x=8` is wrong? we are assigning new references to `x`. This does not mutate it's state.
nothing is wrong if variable is not `const`. If it is const, then any second assignment of ref or value is error.


Y - This whole `:=` and `=` and immutability and assignment and const is very confusing. Let's make it more clear and easy to udnerstand.
if `x` is int and immutable , we can write `int x; x:=5; x=7;`?
answer: both are ok and possible. for immutables, `=` works just like `:=`. 
but: `Int y = 5; Int x=y; x++;` -> this won't change value of `y` because x is now pointing to a new object.
if you need to have that effect, use holder classes.
`MyClass mc = ??; MyClass mc2=mc; mc2.change()` this will NOT change mc
`MyClass mc = ??; MyClass mc2:=mc; mc2.change()` this will change mc.
what about const values? They are not re-assignable so neither of `:=` or `=` is possible on them.

Y - if `a=b` will point a to b without data duplication both for primitives and for big classes, maybe we should remove `:=` notation and assume `=` does the job. If someone needs cloning, he can call appropriate method. 
so can we assume there is no need to `:=` and we only need `=` which assigns references?
This behavior is good for immutable primitives. also good for pure functional classes because there is no data to worry about. if someone needs a custom assignment which copies (and possibly modifies) internal state, we can add a method for that: `void init_from(MyClass obj){...}`. 
what about `==` and `:==` operators? `==` will call `equals` which by default compares references not their internal data. anyway developer is assured that if `x==y` they have same data. but maybe `x==y` returns false but they have same data. if it is important, appropriate method should be added. but this makes thing complex:
`int x=5;int y=x; y++; x++; ` now `x==y` returns false.
proposal: `==` by default will compare references unless it is being overriden by the class. If you want to make sure you dont compare references, call `equals` method of the objects. 
so for example there is no `++` operator. it is only a syntax sugar for `x = x+1` where `+` is customizable but `=` is not.
so basically `=` will behave like old `:=`. 

Y - Let's force class to set value for consts upon instantiation.

N - Shall we add a new keyword for method-local static variables?
makes sense because `_` prefix for static is different behavior and will be confusing.

N - can we define `static const x;`. No. `const` is only valid for field declaration.

N - can we have similar keyword for exposed?
can we compose `exposed` and `const`? yes. `static const int x`, `exposed const int x`.
we need a shorter and more beautiful keyword for `exposed`. ->`exp`?
but `static` is good and short.
$ is for instantiation and @ for casting. maybe we can make use of #. for static or exposed.
`int #x;`.
for exposed it is hard to add prefix. because for fields we already have `_` prefix.
but what about static? proposal: any variable starting with `#` is static, whether its a field or a local variable.
`int #x;` but `$` is better as it is similar to (S)tatic. 
proposal: let `#()` be operator for instantiation and `$` prefix for static variables/fields.
so if a field is defined using `$` prefix, it will only be accessible inside static instance. 
what about methods? if a method name starts with `$` it will be only added to static instance? NO>
We are making things more complex. there should be absolutely no difference between static and normal instances.
having prefix for variables to declare them as static but prohibiting using it for fields is against orth and gen.
so, we will use `static` keyword for this purpose. 
so we need a prefix for exposed variables. but we need these variables to be private. Not really!
they can be either private or public. but prefix won't be applicable if they can start either with alphabet or underscore. 
`int _#x;` -> ugly!
ok. let's use a keyword. `expose` is not good because it is a verb.
for now, let's post pone this decision. exposed is for variables starting with double underscore.

Y - you should be able to define a method-local variable using `const`. why not?

N - static scope:
developer can ask: Why I can define local variables using `static` but cannot do this for class fields! 
what about notation: `int this.x = 12;` this will add `x` to the current instance but it will be only valid within method body. lifetime scope will be same as outer class but access scope is just within the class.
this is more intuitive, does not breach orth and gen.
what about class definition? `int MyClass.x = 12;` will add a field only to the static instance?
`int MyClass.func(int x) {}` will add function only to the static instance?
so we can have `new` only available through static instance: `MyClass MyClass.new() return $();`
similarly, a static method should define it's static vars like `int MyClass.x = 12;`.
so:
we can define static function, field or variable. 
static functions are only available from static instance. `int MyClass.f() { return 5;}`
static fields are only available through static instance. `int MyClass.g = 12;`
static variables are only available inside the method. 
`int this.x = 12;` is static variable for a method
`int MyClass.x = 12;` is a static field so it shared between same method of all instance of MyClass.
actually we can provide different implementation for each instance: normal and static instance.

N - Let's use `static` instead of prefixing MyClass everywhere.

Y - Static variables are considered bad. But we ARE providing them indirectly through static instance. 
when normal and static instance are the same, we can simply cast an instance of the class without worrying whether it is normal or static instance. All this static keyword and MyClass. prefix started because we wanted to have static local variables. they are considered bad in the first place. ALSO enabling them makes language way more complex (because we want to keep generality and orth of the language). If developer really needs a static instance, define it without a constructor.

N - shall we explicitly define `this.` prefix for field and functions?
```
int this.x = 12;
int this.func() { return this.x;} 
```
makes code too verbose.

N - What if we want to override exposed empty method only in static instance?
`int MyClass.__member.method() {}`
no difference between normal and static instance

N - exposed variables are very important because they silently add to fields and functions of the class. 
we have to denote them through variable name. or else, developer may get confused if `this.x` is exposed or not.

Y - Providing body for an empty method, has a confusing syntax!
`int __member.method1() { return 5;}`
maybe contained class did not want to let other propose bodies for the method!
```
//contained class
const fn<int> m1;   //const undef field
int method1() = this.m1;  //method1 is redirected to m1
MyClass new(fn<int> m) return $(m1: m);  //construct an instance using given value

//container class
this.__member = MyClass.new(this.implementation);
```
this is better! So there is no virtual method or implementation provided from outside.

Y - `int x=5;int y=x;y++`
this does not change value of x which is consistent with what we see in other languages.
what about arrays?
`int[3] a;` -> `Array<int> a = Array<int>.new(3);`
`Array<int> new(int count) { auto result = $(count*4); }`
1) this class needs a field: length. so it won't be immutable.
2) set/get operators will be implemented outside. also we can implement `new` outside.
maybe we can use `native` keyword to define these cases.
`native MyClass new(int count);` -> this method has a body but the body is defined by compiler/runtime.

N - hash?
`Hash<String, Int> h1 = H....new();`
new/set/get are all implemented by compiler and called automatically.

Y - Let's have lowercase for primitives!

N - Why we cannot assign value to public methods? also why a class cannot assign value to its private methods?
why we cannot define `const` methods? makes things more complex.
if you want this, assign method like this `int f() = this.var;` and write to `var`

Y - Better syntax for optional arguments:
`int f(int x, int y, int? z);`
`int f(int x, @int y)`
`int f(int x, int @y)`
`int f(int x, int y=4)`

N - `build_x` is quite useful in our company. can we have such a thing?
Moose: `is: ro/rw, default, builder`
`int x := this.getx;`  lazy calculate value of x. 
can it be read/write? or only read-only?
if `getx` has two versions (one without input for read, one without output for write) it will be r/w.
if we only have `int getx()` it will be read-only.
if we only have `void getx(int value)` it will be write-only.
how to ensure lazy read?
default value: `int x = 11 := get`
`const int x = 11 := get` is wrong. x has a value and is read-only!
`const int x := get` is wrong. const means value should be provided upon declaration or instantiation.
`property int x` -> setting value of x will call `set_x` and reading will call `get_x`. if either of these methods does not exist means it is read or write only. you cannot combine property and const.
`property int _x` -> set__x. get__x.
we can enforce read/write only. how to enforce caching of value, and calling get__x only on the first case? 
q: how can we cache a function output? of course it does not have any input: `int get_x()`
define: `get_x` to read, `set_x` for write, `build_x` for only first-time get.
you can either have `get_x` or `build_x`. with get, its called upon each reference. with `build` it's cached, until 
value is changed by calling `set_x` (if available). 
what about naming convention? `buildX`, `getX`, `setX`. 
`property int myData;` -> `get_myData`? `get_mydata`? `getMyData`?
prefix should be combinable with field name. 
`my_var` -> get and set can have the same name. `int my_var()` for get, `void my_var(int x)` for set. 
`myVar`
q: how should get/set work? what is the variable to actually store data into?
`Property<int> x;` -> not flexible. what if I want to have my own set/get code?
I strongly prefer using convention here: `get_x, set_x, build_x`. 
`int get_x() { return this.x; }`
`void set_x(int x) { this.x = x;}`
`int build_x() { return 4;}`
why do we need get and set? the initial reason was for `build` and caching the value.
using get and set will add the the confusion as to how to handle the original value.
so `build_x` will be called upon first reference to `x`. 
whenever value of `x` is undef, and it is being read, `build_x` will be called. 
if you assign a value to it, build method will never be called. 
can we also have a method which is called whenever value is written to the field? this may be useful and does not introduce cnofusion. because I think there will be a need for a new keyword to explicitly tell compiler about this behavior for x. so let's make more use of this new keyword.
so if `x` is being assigned a value, this new method will be called before assignment.
e.g. `void updating_x(int new_value);`
but we have a full set of operators. If you need special behavior upon assignment, add it to `op_assign` operator.
but maybe we don't want to add a new class for this. we have `int x` and want to be notified when it is being updated.
-> if so, make it private and add `set_x` method yourself.
same for `get_x`. this can be easily handled using existing tools. and minimum confusion.
also we can implement `build` with `get_x`. 
```
int get_x() {
    if ( this._x == @ ) calculate_x();
    return this._x;
}
```

Y - also add default for switch. or maybe we can use `else`. 

Y - Can we make use of nonamed public function maybe for constructor. `MyClass (int x) { }`
what if we don't want to have a static instance? it's good if _ method creates the static instance too.
so it can return undef which means there is no static instance. but how are we going to instantiate the class then?
only static -> don't define constructor
only instance -> return undef in _ method. how to create those instances?
no. this is not good. this should be minimum possible code: `int main() { return 0; }`
there is no _ method. so by default, every class has a static instance: _ is implemented by compiler by default. you can override it. so _ creating the static instance is fine.
why there should be a difference between static and normal instance? why do they have separate methods and way of constructor?
why not write a normal class with a constructor. compiler calls the constructor to create the static instance.
code calls it to create normal instance. a single method is used for creation of instances of the class.
that special method is the unnamed method. so if unnamed method is private, means only compiler can call it -> it has only static instance.
if it is public -> it has both public and private instance.
if there are both public and private: everyone will call public.
if there is none: compiler defines default private constructor.
but no-named method makes reading code harder. `MyClass (int x) { return $(); }`
let's give it a symbolic name: `#`.
`MyClass x = MyClass(10);` //this will call unnamed public method.
`return this._(10);` this will call unnamed private method.
so compiler is just like normal code: it asks the class for an instance, assigns it to `MyClass` global variable and done.
(note: if you define constructor, it must accept no-input, else: compiler cannot call it so there won't be a static instance)
can we instantiate the class if it does not have a static instance? NO. 
so either there is no instance, or only static instance or both static and normal instance.
so static instance MUST be create-able, but normal instance can be either provided or no.
so static instance will use private unnamed no-input method: `MyClass _() {}` will create and return. or if not defined compiler will define.
normal instance will use public no-name method from static instance: `MyClass () {}`
`MyClass x = MyClass(10);`  
but this is confusing with casting! are we casting `10` to MyClass? or creating a new instance of MyClass?
NO! Casting has a @ prefix.
result: static instance is created by compiler automatically. _ method will be called if present, to initi the static instance.
if class wants to have normal instances too, for outside, it will define no-name method `MyClass ()` which others can call. But then there would be two ways to create instances of a class: static methods or no-name method.
solution: calling `$()` is only allowed inside noname method.
so how can we define a private constructor? why do we need one? 
static instance is mandatory. normal instance is optionals
static instance is just like normal instance. -> WRONG. it is not optional.
let's just ignore the concept of initializing static instance.
if we force developer to have a no-input constructor then static instance can be created normally.
what if we have const members which don't have values? then creating static instance is not possible!
so we cannot say compiler creates the static instance magically.
static instance must be created using constructor. so ctor should be able to work without any inputs.
but what if the developer creates the static instance with his own parameters?
e.g MyClass(10) be the static instance.
so: user can define public or private constructor. which is unnamed. it can have any number of inputs.
all is fine not considering static instance. 
static instance is created by compiler, calling public or private ctor of the class, without any inputs.
if class has no ctor, compiler will add `auto _() return $();` for creation of static instance.
if class has public ctor, it will be called by compiler to create sinstance.
if class has only a private ctor, will be called.
what are our goals?
1. we want developer have control over creation of sinst -> `auto _()` is required and will be added on demand.
2. we want developer disable instance creation. -> don't define unnamed public.
3. we want developer disable sint creation. -> not possible.
normal instances will be created by calling unnamed public method.
static instance will be created by calling unnamed private method.
calling `$()` is only allowed in unnamed methods. 
so unnamed public method is required if we need class to be instantiatble. `auto () return $();`
but private unnamed ctor is callable by static methods! so we don't really need public unnamed method. 
developer can just ignore public unnamed method and create instances by calling private unnamed.
and saying: you can only call `$()` inside this method is against orth and gen.
so: calling `$()` is allowed from everywhere. compiler will call `_()` to create the static instance. 
for creation of normal instances.
proposal: calling `$()` is only allowed inside `_()` method. any other method can call this to create an instance. 
adv: static and normal instance are the same.
we can also force calling `_()` only to public unnamed method. but interfaces for this will not be readable. 
can `_()` call other methods? yes and no. yes because it is a class method. no because there is no instance.
it does not have a `this`. it can create a new instance and call it's methods.
`MyClass _(int x=1) { auto result = $(data:x); result._method1(); return result; }`
proposal 1) all other methods should call _() to create a new instance.
proposal 2) no method can call _(). other methods have to use $() themselves.
proposal 3) there is no need for _(). compiler will automatically create the new instance of the class. init all fields. if there is a const field without having a value, it will be undef and cannot be re-assigned. class can have as many ctor as it wants, each of them calling $ to create new instance.
but initialization of the static inst can have lots of advantages. ok we will have _.
compiler creates stinst and calls _ for initialization.
but why limit _ to the static instance? because for other instances we have full control over inst.
can we say _ will be called after creation of all instances (static or normal)?
in _ we can say: `if ( this == MyClass)` to check if we are acting on the stinst.

N - What if MyClass has overriden `equals` but now somewhere needs to check for ref equality?
castnig to ref? `if ( @ref(this) == @ref(data) ) ...`

Y - Add a new operator: `defined x` which returns true if `x` is not undef. 
`if ( defined x )`
`if ( not defined x)`
this is more readable, than `if ( x == @ )` and also does not rely on equals operator which is good -> not good. not gen.
lets ban equality check for undef. `if ( x == @)` or `if ( x == @int)` or `if ( x == @int())`
lets completely remove notation of `@int()` and all its shortcuts.
but how can we send undef to a function then?
`if ( defined x)` is same as `if ( #x == #@ )`

Y - What are the operators that a class can override?
`if ( int1 == int2 ) ...` clearly needs data comparison
`if ( this == MyClass) ...` clearly needs ref comparison
let's ban overriding `==` opertor. 
same as `=`. it assigns reference. you want to customize call clone or duplicate.
in C# we have `equals` and `reference_equals`.
equals should return false if one of ops are undef.
we can have `==` and `!=` for data comparison.
`===` and `!==` for reference comparison.
or we can have `==` for data comparison which is overridable. and 
use `ref(x) == ref(y)` for ref comparison.
or: `if ( ref_eq(x,y)) ...` to compare two references.
`if ( x ~ y ) ...` not intuitive.
we can have built-in methods for ref comparison.
explicit is better than implicit. 
by default `==` compares member by member deep comparison. you can override it.
python has `id(x)` to return unique id of object.
`#x == #y` where `#x` returns unique id of x, which is `int`. same as `id` in python.

N - `future<int> ff = invoke this.method1();`
`invoke (future<int> ff) -> ff.result = this.method1();`
Can we make `invoke` as simple as possible?
what is role of future? get result, check if its done, check if there was an exception, get with timeout, event handlers
Future: state (running, success, exception), get(with optionaltimeout), onSuccess (for chaining), onException.
`future<int> f = ...; f.onSuccess = ?; f.onException = ?;invoke(f, method1);`
```
void invoke(fn<> function, future f) { 
defer(exc) future.onException(); 
defer(out) future.value = out;
function();
}
```
advantage of returning something in invoke: dev has control over the micro-thread.

N - `static`? although it is not recommended, but our principle is to let developers have as much as possible.
and rely on them to use it wisely.
but dev, can use private fields to simulate static.

Y - Can't I define a const field which redirects to a method?
like function: `int func2(int x) = this.func1` redirects calls to func2 to func1.
same for fields, and as we cannot assign to functions, it will need to be const.
`const int x = this.func2;` when I call `this.x` or other write `myObj.x` it will call func2 and return the value.
problem with above statement is that, rvalue's type does not match with lvalue.
we can use `:=` for this and function.
because we have assumed that function is read-only.
can't we implement this in another way with simplicity?
instead of `int func2(int x) = this.func1` we can write: `int func2(int x) { return this.func1(x); }`
but it won't be simple. we can define this syntax sugar: `f = g` means `f { return g(all inputs); }`
but we are re-defining meaning of `=`! let's use `:=`
what about fields? `int x := this.func2`
setting value for x will call `void func2(int x)` -> we discussed this before, where will be the real storage then?
so this can only be applied when reading the value of the field? isn't this the same as defining a nick-name for a function?
isn't this the same as calling input-less function without `()`? if we adopt this notation, we don't need to define `:=` to redirect field to method. 

Y - if we adopt, omitting () when calling input-less function, can this implement `const` for us?
`float PI() { return 3.1415;}`
`MyClass get() { return obj; }`
so basically we won't need const and `:=` for assignment.
we will have constants, ability to call a function when a (seemingly) field is referenced.
`float PI() {}` does not satisfy `float PI;` because second declaration implies r/w.
and we can write: `float PI() := this.calculate(3.14);` to redirect a call.
what happens to const? real constants have a fixed body like above example. 
so:
proposal: remove const from language. provide syntax sugar to write `a.b` instead of `a.b()`.

Y - replace `#` with `@ref` class. this class is built-in and can be used to compare references.

\* - serialization. we reflection for this, if we want to have developer do it -> core

N - `:=` notation for function decl, can hint compiler to inline method. 

\* - String interpolation `result of $x is $y'. OK.
single quote can be used for normal string. double quote for inperpolated string.

N - fantom: a?.func()     // safe invoke operator (like Groovy)
Groovy: `name = person?.name `
Ruby: `account&.owner&.address`
C#: `i = f?.Measure;`
I dont like this operator. It encourages the developer to ignore null data.

N - Discussion about including generics in Fantom:
http://fantom.org/forum/topic/1433
Eiffel has anchor which means method input or output type can refer to a field of the class.
`T1 method(T2 input) {...}`
benefit: there will not be a magical syntax: `MyClass<int, string>`.
`int func1(string s) {...}`
```
int x = 11;
Type T = int;
T[] d;
//later:
MyClass m = MyClass.new(T: int);
```
con: in this case we may have two instances of `MyClass` which cannot be converted to each-other?
no. stack of int and stack of float should have explicitly different type names.

N - Once methods only compute their result the first time they are called and then return a cached value on subsequent calls. `once Str fullName() { return "$firstName  $lastName" }`
we are already using `:=` notation. also these method may be longer than one line.
they cannot have any input parameters. so basically they are fields!
maybe we can use `:=` notation for this but it will become too confusing. `:=` will have 3 meanings!
`int x := this.calculate_data;` upon first usage of `x` it will be calculated and cached.
`int x := { do_calc; return 6; }` - this is confusing and is adding a new syntax construct.
`once int func() { return 5;}`
this is not general -> method must be input-less. so we will loose generality.
making it general (support all methods), will add a lot to the runtime system.

Y - more limitations for generics: single capital letters, types without value. ->No
we need to specify default + constraints for template type and be more explicit than `type T;`
more generic structure to instantiate generics: 
`Stack<int>` == `Stack<T:=int>` which can be shortcut to Stack<int>
class can provide default value for types: `type T := int;`
so without `<>` the class can be created: `Stack s = Stack.new();` is stack of int
`Stack<float> s = Stack<float>.new()` is stack of float.
how can we enforce type constraints? we want to state type T must implement type U, where U can be another type or a literal type name also we need the default value.
default value can be handled using normal syntax: `type T := int;`
for constraint:
`type T := int [+Type1 +Type2 +Type3];` adv: we can make template explicit.
`type T := int; @assert @Type1(T);` adv: we use existing syntax.
`type T := int [@Type1 @Type2 @Type3];`  //T must be castable to these types
`type T := int [];` //means T is a template argument -> this is same as int array!
so we don't need to have convention for this.
`type T := int @{};`
`type T := int @{Type1, Type2};`
Now, if someone writes `Stack s = Stack.new()` it will be what?-> this is not possible!
`Stack<int> s = Stack<int>.new();` //T will be int
what will be meaning of `Stack` and `Stack<>` then?
compiler for each template will create another class without any template type (definition and usage)
result will be a class which all template instances conform to. possibility to instantiate this will depend on the syntax of the ctor but we can cast other classes to it. so we can cast `Stack<int>` and `Stack<float>` to `Stack`. of course we won't have access to type-specific methods of stack in `Stack` class.
`Stack<>` means stack with default arg value.

Y - Let's remove template specialization. what if developer specializes and result is something totally different! it has to be conforming to base impl.

N - Fantom doesn't include support for 32-bit, 16-bit, and 8-bit integers and floats. There is only a 64-bit Int and a 64-bit Float.
what's use of this? primitives are classes.
we have 8, 16, 32 and 64 bits. we definitely need 8 for string. for unicode? we won't need 16 bit int, atleast.
we need 64 bit too, so: char, byte, int64, uint64.
what about 16 and 32?
if all data be 8 bytes, we will consume more memory.
but I think we can safely remove 16 bits: `short` and `ushort`.
for crypto or network code we may really need to work with a 16 bit data block, but this can be done via a simulator class.
also when working with other systems (C code, databases, web-service API, ...) we may need these types.

Y - remove `void` keyword. return `this` if you dont have anything to return.
if there is no `return` statement, function will return `this`, so code doesn't get messy.
but return type must be specified. user can write `~` to indicate return type is same as the class.
`~ new() := $();`
so user can easily chain method calls.
`x.method1() = yy;`
`x = yy;`
but note that this result cannot be lvalue. 
so `~` is a shortcut for name of the class. 
can we write `~.method2`? no. it can only be used as a type-name not variable name.
so it can be used for input type, output type, variable type, ...
`int x; ~ pp;` not elegant and explicit.
`int f(~ me, ~ other);` its better if we limit usage of `~` for input/output of function.
we can only limit usage of `~` to output type and this will mean implicitly return `this`.

N - non nullable types
`int!` cannot accept nil value.
by default, it will have `0` value (but `int x` will be `nil`).
but what about a class? `MyClass! x;`, `NetworkStream! ns`
how can we say T must be non-nullable in a generic class?
what happens when we create an array of these? `int![10] x;`
what if we want to create a non-nullable array of non-nullable integers? `int![10]! x`?
or we can act in reverse: all type are non-nullable unless we say so. `int` cannot be null.
`int?` can be null too. 
so methods that return `int` MUST return something. if there is a chance that they cannot return anything they have to change their signature to `int?`.
proposal: each class defines it's default value. if it is nil then it is nullable.
but a class can have default value of 6 and be nullable too!
it's better to define nullability at variable level.
we need to pay attention to array and complex objects.
what if we define an array `int?[]`, 
what will be default value of array of int? 
how can we have non-nullable array of nullable ints?
how can we have nullable array or non-nullable ints?
if Person is non-nullable, what should be it's default value?
how are we going to handle conversion? can we convert `int?[]` to `int[]`?
default assumption of all objects non-nullable by default makes thing difficult when developer has complex classes. 
what if we add it as a contract? then we can have contract for x being >0 too!
design by contract is an alternative, but it acts on class level.
what should be type of hashtable query? it can be non-existent or it can really be null.
`int? x = map["data"];` what does null x mean? map does not have this key? or the actual value is null?
it will add lots of complexity.
maybe we can narrow this: we want to declare output of a function or a field cannot be null.
maybe this can be boiled down to `assert` and `defer`.
if contracts are not part of code, then all intheritance and shadowing may become complex.

Y - design by contract - built-in support?
`@in(x>0)`  ensure x input is >0
`@out(out>0)` ensure output is >0
how can we share data? e.g. check if length of array is not changed before/after method?
contracts follow rule of explicity.
no sharing of data is supported. we are not trying to solve all of the world's problems.
if class A has method M with contracts, and class B composes class A. 
if B does not have method named M, it will be promoted (with all it's contracts).
if B hides it, then it won't be promoted but when its called it will have it's contract.
maybe we can use contracts for templates too. so we won't beed `@{Type1, Type2}` part.
so we will have 4 types of contracts: `expect, ensure, invariant, init`
- expect: checked before method execution
- ensure: after method execution
- invariant: before/after all public methods execution
- init: after instance creation, this is of type ensure.
`#check(this)` for invariant
`#check(in)` method pre-condition
`#check(out)` method post-condition
for template check:
`#check[in](@?Type1(T))`
`#check[in](x > 0)`
`#check[in]x > 0)`
`#require(x>0)`
`#ensure(out !=0)`
we can use `expects` for class invariant too, when it is defined before fields section.
so, we can simply add: `#ensure(out != @)` to make function output non-nullable.
`#require{x>0}`
`#ensure{out != @}`
braces is better because using paren implies we need semicolon at the end of the line
```
#invariant{this.x>0}

#require{x>0}
#ensure{this.result == out}
~ f(int x) 
{
    return x+1;
}
```

Y - `@int(x)` casts x to integer.
`@?int(float)` returns true if float can be casted to int.
`assert @?int(input1)`
`@int[float]`

Y - if `~ func();` is called it won't return null but `this`.

Y - Do we still need to provide values inside $? no

N - can we simplify type names? 
`Map<Stack<int[string]>, string[int[]]> data_types;`
maybe using `int#` for array of integer.
`int#string` for hash.
`Map<Stack<int#string>, string#int#>`
`int# arr = int#.new(3);`
or more explicit: `array<int>` and `map<string, int>`

N - can we make hash literals a language feature?
`h = { 1:10, 2:20, 3:30}`
no. scala can because it has a different ctor system.

N - more undef related operators
we have @ for undef and ?? for null casting. 
maybe `?.` but we already have this.

Y - more thinking about immutability.
return `const`. It is not covered completely by accepting `a.b` as `a.b()`.

Y - more clear syntax for func redir.
`:=` is used for type and typename. it's better if use another notation.
why not use `=`? because type of lvalue and rvalue are not the same.
`=>` is too messy and not beautiful.
`auto f :: g;`
`auto f :: 5;`
`auto f :: this.func(10);`
`auto f(int x) :: this.func(10,x);`

Y - local variables starting with underscore are static.
this can be used for caching or `once` effect (`build_x` in perl).

Y - For anon-func `_` can denote the only input, resulting in a shorter code:
`auto ff = (int x) -> x+1;`
`auto ff = _+1;`

N - instead of `->` notation we can simply use `=` and write anon-func or class inside some container.
we are already using `=`

\* - support for regex
match, grouping, replace
using regex in other cases (e.g. split string)
`s ~ regex` for matching, returns true or false
`list<?> groups = (s ~ regex)` grouping
`s =~ /regex1/regex2/` replace.
proposal: do all in library, except for normal matching `s ~ regex`

Y - now that we have contracts, lets use them as much as possible. 
e.g. type checking for typename.

Y - We may need more `#xyz`. How can we say some field should not be serialized?
golang, to ignore field in serialization: add `json:"-"`
omit empty field: `json:"omitempty"`
other use case: I have an object, I want all methods which are tagged with "get" and "put". they have same prototype.
golang webs use: `engine.Get("/hello", function(int x) ...);`
but we can simply build a hash[string, fn] and populate it for routing, but definitely annotation is more readable.
we can have a method that given an object, returns a hash(member name, metadata)
maybe we can make `#` syntax more general.
`#meta(x:1, y:2)` adds this metadata to the following definition.
`#meta.json(ignore:true)`
`#meta(json:false)`
`#meta{json, ignore:false, name: 'dsda'}`
we can assume when value of key is missing, it means: `key:true`
`#invariant, #require, #ensure, #meta`

Y - if we decide to have annot, maybe it's good to replace `#` with `@` to be more similar to java.
and use `#` for cast and undef. maybe then we can also eliminate usage of `#` alone.

\* - how to have multi-line string literal?
what abour interpolation?
maybe then the syntax can be used for regex too. no. why not use plain string? regexp does not need a lot of escaping.

N - other possible annotations: `#version`, `#artifact-name`, `#obsolete`, `#conditional` (for methods, hide the method when a condition is not satisfied, so calling it won't be compiled), `#doc`
can we replace these with keyword or convention?
doc - can be replaced with convention `///`

Y - remove invariant. it is too heavyweight at runtime.
require/ensure.
maybe we can remove `ensure` too because it can be done via `defer(out)`.
also, we can simulate require with assert.
invariant - remove
ensure - defer
require - assert
version - not needed
obsolete, conditional, ... - not really needed
but we need `meta`. if it is the only thing, we can remove the name and only include `@`. 
(so we will be back to the original problem: non-nullable types)
`@{json, ignore: false}`
`@(json, ignore: false)`
and for typename? we will be beack to `@{Type1, Type2}` notation. or maybe `#{Type1, Type2}`
or maybe we can simplift it more.
`(json:true, ignore: false) int f() { return 5;}`
`[json:true, ignore: false] int f() { return 5;}`
`[[json:true, ignore: false]] int f() { return 5;}`
`|<json:true, ignore: false>| int f() { return 5;}`
we need to decide whether we want metadata to be language-bound or core library-bound.
it's better (language will become simpler, if we delegate this to core and other modules).
but what about pre-req?
`@notNull(x)`  //btw, this is much more readable.
proposal: annotations are key + value where value is a tuple.
but if we follow above proposal, user should be able to define custom annotation keys! (gen)
so: `@{notNull, x}` which means `@{notNull:true, x: true}`
or we can have: `@{assert, x>0}` but then this cannot be handled in core, it should be part of language.
proposal: annotation is of form `@custom_name{key1:value1, key2:value2, ...}`
custom_name is whatever you want. value(i) is optional and is assumed to be true if omitted.
we need annotations for json and other things.
but if we add `notNull` annotation, who will enforce it? if language -> we wanted this to be part of core.
if core -> how? user should also be able to do this.
we can define two special annot. which will be executed before and after method execution -> No. not orth. 
lets just ignore contracts and assume they will be handled by defer and assert. 

N - I think we still need contracts. it makes code well-documented.
Is there a way to inject code at beginning or end of a method? 
a general and orth way.
python decorator is one example.
but we dont need general code. just some assertions. 
between invariant, pre-cond and post-cons: most important is pre-cond, then post and then invariant.
we can have some special ann keys: `@notNull(x)` but what about more complex conditions like: `x>y`
or `x-y<4`
maybe this: `@name{key:value, key:value,...}` there is another form which you can write code instead of key-values.
you annotate the method with code. 
`@require{x>0}`
OR:
`@check(before: x>0)`
proposal: in ann, value of a key can be an expression which will be evaluated when method is called.
NO. obviously we have two types of ann: meta-data and meta-code.
they have to have 1) separate notations 2)be general
meta-code: how can we have a general annotation for code? 
`@@` can be used for meta-code prefix.
meta-data: stored statically and calculated at compile time.
meta-code: calculated at runtime when this method is called.
meta-code -> meta-check (needs only an expression)
`@@{x>0}`
we can reverse this @ for meta-code and @@ for meta-data
`@{assert(x>0)}`
`@{x>0}` what about post-condition?
we can thnk of meta-code same as meta-data but compiler has the job of adding them to the code before compilation.
so `@check(x>0)` is a meta-data but also compiler will add the code to the beginning of the method body.
can we make the syntax more clear?
one reason against invariant is that it makes code un-readable. it adds code all over the class.
proposal: make it part of code
```
int f(int x)
require x>0;
ensure(out) out != -1;
{
...
}
```
this is more readable.
or `require: exp`
but this will make language more complex. but also, they are not required.
```
int f(int x)
require x>0;
ensure(out) out != -1;
{
...
}
```
how does this fit with expose and anon-func?
most contracts are: x>=0 and x should not be null. 
first can be achieve using unsigned type. second one, I have to think of something.
but let's not pollute the language and make everything double complex.
for other checks, user can use assert and defer.

N - maybe we can somehow force user to use `type` so complex types will be simpler.
`List<Map<int, Collection<String>>>`

Y - make assert always throw exception.

N - a notation like `%%MyClass` which means intertface of MyClass (only public methods without any body).
do we really need this? when we have `int f(MyClass mc)` we can pass any other class which conforms to `MyClass` to f.
as long as the object has all public members of MC it's fine.

N - How can I hide an exposed field?
define the same field with same type and assign your value.

N - If A has `int x` and B has `int x() { return 4;}` what happens?
x field will not be promoted because there is a member with the same name in the container class.

Y - Lets remove this part for anon-class: if anon-class has only one method, `x()` will invoke it.
this makes code, not readable.

N - ban anon-class with multiple methods and for one-method we can rely solely on `fn` template.
no. let's keep anon-class with multiple because it will make code much more easy.
for short-form (one method), the method name. they are anon!
we should be able to cast `fn` class to any other class with same arguments.
but on the other side, suppose we have a `startThread` method which expects a class having `start` method.
no this is not good.
when we write `Inter4 i = (x,y) -> (x+y);`
This means what? I want a new object of type `Inter4`. This object has only one method.
this is not needed. we are sure that the type does not have any code or fields.

Y - Why we cannot have anon-class based on any class?
because a class cannot have two methods with body and with the same name. so if class already has a method no one should be able to change it.
but what about fields? they make no problem. so they should be allowed. 

Y - Remove:  `g` can be a complex expression: `auto f(int x) :: this.g(3, x);`.
from spec. its making things complicated.

Y - can we use `::` notation for variables too? 
`int x :: this.getx(1);` Not this one.
or: `int x :: this.xp;`
when reading x, this.xp() will be called. when writing `this.xp(value)` will be called.
`myObj.x` this can invoke `myObj.xp` method or `myObj.x()` method. 
as a result of this, name of each member (field or method) must be unique.
does this conform with exposing? I think so.
if there is no `this.xp(value)` variable is considered read-only.
what is internal has a read/write field, but container has a read-only? Its fine.
because container has decided to change the behavior.
`auto f :: 4;` //this is a function mapped to 4. it definitely is not a field.
`auto f :: this.g` //this can be a property or a fn redirection.
`int f :: this.gg;` //this can be either a fn redirection (call gg when f is called), or a property.
is above code sufficiently readable?
let's make `()` mandatory. no. it makes code ugly, specially for fn redirect.
to make things even more different, lets remove `auto` for fn definition.

Y - what if A has `const int x` and container B has `int x`?
the const is making things complex.
either we have to remove it or make it explicitly clear whether it is part of the type or no.
maybe `int% x` meaning x is not re-assignable.

Y - can't we simulate const with a function returning the variable?
`const int x` -> `int _x; int x() :: this._x;`
the const is only saving us a few lines of code. because with const we only define the field.
with redirect, we need to define a field and the function.
ok. again lets remove const.

Y - So again, `$()` cannot contain assignment. right.

Y - annotation for non-nullable?
how can we say some variable is not nullable?
cases: class field, local variable, function input, function output
maybe we can have `int` and `int&`. the second one means a variable which is actually pointing to an integer.
how can we represent non-nullable array or non-nullable integers? `Array<int&>&`
purpose is to force developer to do the cast before call and check for null-ref.
q: how can we ensure on a compile-time level, that a call like `a.method1` does not fail.
I think we are already tackling the problem with built-in null-object pattern.

Y - `#` for instantiation, `$` for casting and undef?
`return $;`
`#` inside the code for casting, is a little unfamiliar for a C/C++ developer.

Y - What is the difference between `$Parent` and `$child`?
Both are null-objects. 
`if ( x == $parent ) ...`
`if ( x == $child ) ...`
which one should be true? both?
let's ban equality check with null-object, and use `defined`.
how can we return undef then? `return nil;`
`$int(4.4)`
`x = nil;` will assign nil value to x. 
`defined x` will return true if x is not defined.
lets just remove all undef and nil notations and use `nil` and `defined`.

Y - it doesn't mean to compare `nil`s. you have to use defined.

N - Now that we don't want to support reflection, maybe we can have some `enclose` like python decorators.
but we need to think about how it will fit with expose and anon-class.
can't we achieve this using expose?
```
MyClass __x;
new :: $;
int f(int x) {
    return this.__x.f(x+1);
}
```
it is possible but it's better if we provide a simpler syntax.
but we already have annotation. so this is not good for marking something or adding "data".
it should be useful for logic and business and code.
application: caching, 
`f :: MyClass.decorator(this.myF);`
```
@MyClass.decorator1
int f(int x) { return x+1;}
int decorator1(int x) { x++; return f(x);}
```
no. makes things complicated.

N - If class A has field `f` and it's container defined method `f` it will hide field f.
and if someone writes `int x = obj.f` where obj is of type InterfaceX, compiler knows that `f` is a field or a function. Because this is defined in the interface definition.

N - another approach for templates
```
int max(int x,int y) { ... }
decltype(x) max(T x, T y) { ... } //this is confusing
```

N - A notation to paste a method from outside in current class.
`@paste(Decoration.Cache(this.func))`
no. it is confusing.

N - Is there an advantage in specifying a method which does not need anything from `this`? or any field from this?

N - What can be done at the syntax leve to increase performance?
we can make all calls, static? meaning at compile time we know exactly which method should be called.
for expose, stress that compiler will add appropriate methods for delegation. 
another proposal: compiler can handle primitives more efficiently. 

N - we can define fields as meta-methods referring to the internal storage of the class.
`int x; x=1` becomes `this.__internal_storage.setBytes(4, 1);`
so, there will be no fields for compiler. each class is an internal storage (x bytes of memory) + a set of methods.
so read x, will be translated to a function: `__read_field_x` and writing to `__write_field_x`.
of course these functions can (and should) be inlined.

Y - Remove: Methods can assign values to their inputs, but it won't affect passed data.

Y - there are two ways to provide read-only field:
`f :: this.x;`
`int f :: this.get_f` and only define get_f with int output.
:: for fn can be used for: delegate to another fn, fixed const (like PI), return a field.
third one is not necessary, lets do it using normal function writing.
return consts like PI, same as above. actually all 3 cases can be done via normal fn writing.
but for field, it's not possible without :: operator. 
fn delegation needs ::
constant is much simpler with ::
why do we need :: for fields? 
`int x :: this.func;` //myObj.x will call func to get value.
`int func() { return ...; }`
the only difference is when we want to write value for the field.
`myOBj.x = 10;` will call `myObj.func(10)` to write the value.
`func :: this.x`
`void func(int x) { this.x = x;}`
doesn't above code achieve the same result? `int gg = myObj.func; myObj.func(11);`
I think we can remove `::` for fields. this will remove confusions so we can return `auto` for fn :: syntax.

N - it's good if we can define `int f(int x, int! y)` so I am sure that y won't be null.
`int! x; if ( y!= null) x=y;`

Y - how closure is going to be provided, now that we dont have const?
as input-less methods? possible.

Y - Do we need private unnamed method? for normal instance its not needed.
for static: field init can be done when declaration if it is simple values or reference to outside.
static instance should not rely much on "state". If it does, its better to be normal instance.
lets remove this method.

N - `int f((int x, float f) input)`
forbid above definition. it is making the code ugly and complicated.
use type to give it a name. forbid != gen


N - Implicitly calling methods on `nil` is dangerous. Assume what happens if we have:
```
MyClass mc = getData();
mc.save();
result["data"] = mc;
result["price"] = calculate_price(mc);
return result;
```
maybe we can add a check like `assert` to make sure something is not null.
```
int x = getData();
if ( x == nil ) throw "ERROR";
x.some_method();
//instead:
int x = getData();
validate x;  //assert defined x;
x.some_method();
```
or we can add shortcut for assert: `@`
but it is used for annotations.
`&defined x`

N - Let other classes have ability to act like `int`. Define storage, allocated using `$(32)` read and write.
no. this makes things much more complex because we will need to add lots of other concepts and methods.

N - What happens with this code?-> assignment, does nothing.
```
MyData x = nil;
x.var = 12;
```
I think we should force all instance variables as private.
or we can just throw exception if fields are accessed.
because if we force private vars and define `set_var_value(int x)` it will still have the same effct from outside view.
if we choose to make fields private, then maybe we should devise another notation for public methods.
how can we make it natural that classes cannot have public fields?
maybe:
```
int private_method(MyClass this,...){}
int public_method(MyClass this_public,...){}
```
proposal: all things to be private will be inside a `private` block. all others are public.
the ideas against using public fields is overwhelming. we can still define public function returning them using `auto f :: this.private_field;`
but we should not change the default simplest app notation. we should be as similar to java and C as possible.
```
int main() { return 0;}
```
by any means, this must be an acceptable class in our language.
question is: How can we make it natural and un-surprising that all fields and some methods are private while some other methods are public?
proposal: `public` keyword. `public int f(int x){}`
but dev will ask, what if I write: `public int x = 12;`
for methods, it will simply make method public and if you don't it will be private.
`int this.x = 12; int this.private_method(int x) {}`
the difference shoulbd be explicit and easily readable.
proposal: let's remove concept of fields. we will only have a private storage and tags.
no one should be concerned about internal fields and storage of the class except itself only.
maybe something similar to golang.
how can I make above changes and keep the language orthogonal.
`int f(int x, float f) {{ ... }}`
proposal: everything is private (field and methods). 
```
private { anything here is private because block name starts with underscore }
private { other privates }

//anything outside blocks is public
int f(int x) { return x+this.field1; }
```
OR
```
//all are private
int field1;

public int f(int x) { return x+this.field1; }
```
you can only define public methods. you cannot define public fields.
if you define a field, as public, it will automatically create getter/setter for it. you can easily override them.
`public int field1;` -> class will have `int field1()` and `this field1(int value)` for get/set value.
so we can have field and methods with the same name? if they have different access level? `x = this.field1` should this call `int field1()` method or retrieve value of `field1` field?
1-> we want to ban public fields. problem: naming will be a burden to always type underscore. 
let's accept the burden and say, private start with _ and others are public.
problem: methods are all fine, private fields are all fine. what about public fields?
`int x;` we don't want to ban this notation but we want to ban public fields.
so this notation must mean something else.
property?
If we allow public fields, it will cause problem with `nil` reference and also it is not advised anywhere.
but the language should be simple. this means minimum rules and regulations. minimum exceptions.
so let's see how can we enable developer to define fields and also have `nil`.
proposal: if field is public, it will automatically be a property. `mc.field(10)` for set, `int x = mc.field()` for get.
mapping to a private field with the same name prefixed with underscore. `_field`
but this is not beautiful. 
`int field :: this._field;`
whenever we have to decide between keeping language simple and consistent vs. forcing the developer to obey according to best practices of software design and OOP, let's choose a simple language. developer will be responsible for the other things.
so fields can be either public or private. same for methods.
`nil` object, does nothing. so calling methods returns null. reading fields returns null. settings values does nothing.

N - can a tuple be null?  -> yes it can.
`(int x, float y) xx = nil; xx.x=6;`
if we agree to hide instance variables, then tuple will not be anything similar to a class.
it then should be considered a collection of normal variables.
it cannot be nil but it's components can be. and they must be all public.
still it can be nil. so that we keep gen and orth.

N - if we decide to private all fields, how does this affect expose?

N - how interface is going to be implemented? if we decide to make all fields private.

N - provide easy mechanism to define property fields.
`::` is used for function redirection.
its better to have another notation for properties.
what is property? is it a field or method?
property is field + getter method + setter method.
where field is private. `_field`, getter: `int filed()` setter `this field(int value)`
`int _field :> field;`  //field name is _field and two methods named `field` for set and get are generated by compiler unless developer overrides them.
can the field be public? it should be allowed!
can the property methods be private? it should be allowed.
the only limitation is that we shouldn't have field with same name as method.
`int _field :> _accessor;` defines `int _accessor()` and `this _accessor(int)`. of course developer can override them.
can we merge these two methods? `int _accessor(int value=nil)` calling without input will return value of private field. calling with value will set value. but it's better if setter returns `this`. lets not merge them. so we can chain multiple calls to multiple setters. 
`int field :> accessor` public field, public accessors
`int field :> _accessor` public field, private accessors
what about notation?
`int field => accessor;` good.but similar to import.
`int field := accessor;`
`int field >> accessor;` good.
`int field !! accessor;`
`int field ~ accessor;`
`int field {accessor};`
`int field [accessor];`
but if we deinfe above `int x >> px;` and implement getter and setter, what will be the purpose of `>>` notation?
if we have `int >> px; int px() { return this.x;} void px(int x) { this.x = x;}` then `>> px;` part is not needed.
we will have redundancy and code will not be readable.
proposal1: compiler error. means, you CANNOT define both >> and relevant methods.
so, if you want compiler to write getter/setter for you, just add `int x >> dsa` but if you want to implement it yourself, don't add >> and write methods.
but the whole advantage of property is when you write some code for it (lazy loading, validation, ...)
can we achieve this using aop?
`weave {abcd} int x;`
or like C#:
`int x { get {return value;} set{x=value;}}`
we can achieve lazy loading with a no-input function. 

Y - remove `throw` and solely rely on assert.
`throw x` == `assert false:x;`
`assert condition:x` == `if (!condition) throw x`
we have redundancy.

N - replace assert with a shorter keyword.
`check, test`
but assert is more well-known.

N - support for decorator at compile and runtime.
decorator at compile time -> compose the object
delegated to AOP.

Y - support for AOP?
applications of aop: logging, validation, caching, permission check, transaction, monitoring, timing, error handling, 
`onEntry, onExit, onSuccess, onException` methods of a custom aspect in PostSharp. this aspect handles call of a method.
`onInvoke` replaces method with custom code.
`onGetValue` builder for a field or property
can be used for caching?
it can be applied to a method, property or all methods.
design must be readable, easy to remember and different enough to be noticed easily.
and flexible.
AOP should be supported only at compile time. runtime can be achieved via defining appropriate class or anon-class.
It can be implemented via code injection by compiler at compile time.
Also we have to make it explicitly clear that AOP will be part of the method. so even if the method is promoted onto a container class in future, it will still hold it's AOP. Remember, no one should be able to change class behaviour without it's permission.
and ordering of them and how they combine, must be explicit and clear.
AOP can be decorator and/or proxy design pattern.
with AOP We can implement DI too. Write a custom code for `get` of a property.
1. it should be applied to methods. get/set for properties are methods too.
2. types: before, after, succeed, exception, around (we can remove succeed and exception in favor of after).
3. they should be applicable to one method or the whole class.
we should be able to define a logging method inside the class (or outside), ane call it before each method call.
before, after, around
pre, post, around
entry, exit, invoke
```
//aspect code must be accessible to call: static instance, local field, local method, ...
%before{MyClass.afterHandler}
%before{assert defined x}
int f(int x) { return x+1; }
```
why not use convention instead of configuration?
define appropriate methods somewhere (other class or even same class).
then attach that instance as the aspect-processor
```
%aspect(this)  //run before and then before_f, method before calling f, same for after and around
int f(int x) { return x+1;}
```
maybe we can automate this. so by default `%aspect(this)` is applied to the class.
we can say: `auto result = $(this);` so `this` will be aspect-processor of the instance. 
but we want it to be more explicit: a keyword on top of the class:
`aspect this;` -> any instance of this class will have aspect processor set to this.
methods will eb automatically called upon corresponding conditions.
how can we send parameters to the aspect instance?
can data be shared between multiple aspects?
we can filter specific methods of the aspect-proecssor using casting to specific interfaces.
in class level, we should be able to say aspect should apply to the whole class or only public members.
`aspect{this}` `aspect{@OnlyBefore(this)}`
(we cal replace aspect keyword with weave)
`weave{this}` use `this` per all instance of this class. before running each method, call `before` of that class. 
same for after and around. 
`weave{MyClass.new(10)}` creates a new aspect-processor per instance of the current class.
how can we prevent infinite loop and circular reference? calling `this.before` before calling `this.before` before calling ... ?
one solution: mark aspect methods with a syntax which denote they won't be affected by any other aspect.
proposal2: don't permit setting aspect to `this`.
but still if aspect on MyClass is set to an instance of MyClass this will happen.
proposal: don't let using weave on variables of type of the current class. this is better and simpler.
`weave{OtherClass}`  //before calling any method of the current class call `OtherClass.before` method. same for after and around. this is so simple that we can easily add other methods too.
`weave{OtherClass.new}`  //you can pass literals or static things to the method call.
`weave{expression};`
you can define weave for the whole class or a single method.
`weave{otherClass.getHandler}`
how can we make it explicit that weave it part of code?
```
weave {OtherClass}
weave {MyClass}
weave {@OnlyAfter(ThirdClass)}
weave {@OnlyAround(Builder)}
int f(int x) {
    return x+1;
}
```
1. how to exclude whole-class-weave from a specific method?
2. how to apply a weave to only public methods? all methods?

`not weave {OtherClass}` do not weave this specific method
`weave {OtherClass}` 
lets only support single-element weave. it will be simpler and most of the time we really don't want to weave ALL elements (e.g. validation, transaction, timing, ... they are all normally applied to some methods).
so we won't need `not` notation too. 
`weave {Class1}`
what if we want to have the same aspect for specific methods of the class?
solution: define it as a private variable. and `weave {this.var1}` for all related methods.
note that, type of `this.var1` cannot be same as the current class because it will cause infinite loop.

Y - now that we only support method-level weaving, we can use `this` or var of same type because it is only applied to a specific method. we can even support function for weave.
`weave {obj1}` weave calls into obj1 methods
`weave {@OnlyAfter(this.func1)}` a single function will be executed after the current method is finished.
this will extend meaning of casting. you can cast class A to class B even if method names are not the same.

Y - multiple weaves are handled from inner-most to outer-most.
first inner-most is applied, on top of which next one. and outer-most is applied on top of all other aspects.

N - support for weave on fields. with read/write methods?  -> no support for fields.
`int x;`
`weave {MClass} int x;`
this is totally different than previous one because there is no code for `int x`.
Let's limit weave to methods. if you want it for a variable, define it as a property using `>>`. 
`weave {MClass} int x >> property1;` weave the static instance into calls to setter and getter of x.
what if developer writes his own implementation? 
solution1: still apply to custom impl methods -> code is not readable.
solution2: force dev to explicitly declare weavers. does not make sense and is ambiguous. what if he defined a different weave? which one will be used? both? this is source of ambiguity. 
we LET developer to define weaves but it will not override weave defined upon prop decl.
a better solution: do not let dev to declare weave on prop. if you need weave, declare your impl of getter/setter and weave there. so: weave is not supported on fields. only methods which are implemented. even for auto-implemented getter/setter you cannot weave.
>> AOP and mocking
you can mock class A by composing it. you can disable any Aspect by overriding the method.
>> AOP and testing
you can test aspect separately because its a separate method
you cannot and should not be able to test method without aspect

Y - casting notation ignores method name when output is a class with just one method and input is `fn` type.

N - built-in DI
maybe it should not be part of the language.

N - Let's remove static instance! its a special instance but we have to be general. and it stops us from having pure functions which is good for concurrency.
and makes debug and testing hard because after all, its some kind of global variable. 
we only need two things from static instance: 1) ctor 2) util methods like min/max
for ctor, we can act like golang. There is no ctor. use can only create an instance, and call methods on it.
for min/max: instance methods have input to an instance of the struct, static methods don't have it. 
but we need some namespace mechanism so names won't be clashed. `min` vs `Math.min`
If we prefix all method (static and instance) calls with class name it can become ugly, because class name can get too long.
so after this point there is no "STATIC" and "INSTANCE" methods. there is only one type of method: method. that's all.
`import Math; Math.min(1, 3); Math.max(2, 9);` 
ok you can use `type` to choose a shorter name. `type M := Math; x = M.max(1,20);`
but `M` is not a type! maybe it's better to change type keyword too. For example `alias`.
`alias M := Math; M.max(1,20);`
q: if we change type to alias, how are we going to implement enum?
to create instance: `Math mm = $(Math);`
`Math mm = new Math;`
`Math mm = Math.create(1, 2, 19);` //calling a method to create a new instance
q: how does this affect weaving? it doesn't.
q: this will remove `this` as return type.
q: this will remove static method-local variables.
q: how to implement singleton?  don't!
q: what about expose? it doesn't have anything to do with static.
promoted methods, need to have appropriate type which may not be easy to find.
suppose we have `int add(int x, int y, MyClass this, MyClass that)` in class A which is now exposed into class B.
how can we promote add method?
we have to rule that first argument type must be of current type, if its instance method.
if we expose __MyClass all instance methods are duplicated in parent with `this` type udpated and redirecting to exposed field: `int method1(Parent this, int x) :: this.__MyClass.method1(this.__MyClass, x);`
q: casting? it is a mechanism to filter methods. so when 
q: weaving? `wave {this.obj1} int f(MyClass this) { return 5;}`
q: calling normal methods? `int f(MyClass this); myClass.f()`
maybe we should add separate notation to access tuple field vs. calling instance methods.
q: interface? an interface is
`this := { int tt; }`
`int f() { return 5} //static => int yy = MyClass.f();`
`int this.f(int r) { return r+this.x} //instance => int ff = myObj.f(66);`
I prefer to have a simple and clean method name. without prefix or suffix.
`int f(this, int r) { return r+this.x} //instance => int ff = myObj.f(66);`
proposal1: files that their name starts with something special, contain only static methods. 
proposal2: if file has struct section, all methods are instance. else all methods are static.
let's treat static like instance:`auto m = $(Math); m.max(1, 20);` but this is ugly.
`Math.max` assumes Math is a static class (file does not have struct).
q: how can we implement abstract factory, factory method and other design patterns using this?
all this questions arise because we want to limit developer. it causes difficulty for us and developer.
why not let him free to do whatever he likes to do?
can user write pure functions with original state? yes. just don't use external state.
this applies for static instance and public/private fields.

N - if we remove notation of member function, what happens to static instances?
maybe, if there is no field in the class definition, then all of it's methods are static by nature.
```
struct {}
int max(int x,int y) {..}
MyClass = {int x, float f};
int max(Mylass mc) { return mc.x;}
```
but we don't want to loose public/private encapsulation. 
so each source file can contains a set of fields + methods. 
methods that have `this` input, are instance (have access to an instance of fields)
methods that don't have, they dont have access. but they can create a new instance of struct.
public functions are just normal other functions. so `int f(MyClass mc)` can be called via `f(x)` or `x.f()`.
no. there should not be two ways to do this. but having a general function like this is really useful. we can send `f` as a fp and call it via: `fp.apply(myInstance, ...);`
if everyone can call `$()` then it doesn't mean to have static method just to create an instance of a class.
so in a file we have a tuple + methods. those methods that have their first parameter `this` have access to fields inside the tuple. those with name prefixed with `_` can only be called by methods inside the same file.
file: tuple + public members + private members + public static + private static.
static means `this` is not an input. 
how can we call them?
`MyClass.public_function(myClass, 1, 2);`
`MyClass.static_public(1,2,3);`
how can we make it natural that dev cannot write `obj.field1` or `obj.field3=11`.


N - if we force all fields to be private, then the data will be the same between all classes which implement a specific interface.
```
int calculate(Intr1 ii) { ...}
```

N - can we have a new function type? and have function literals?
`12` is int literal, `{x++}` is fn litearl. no. function literal needs input. its not that simple.
anon-function is good.

N - good ideas from Haskell: 
1)define a function body for a specific parameter value:
fn [] = []
fn arrayt = ...
2)create function by calling another function with incomplete input
add a b = a + b
foo = add 10
foo 5 //result will be 15
`x = (x) -> fn(5, x);` 
3)create new function by combining two other functions.
using chain operator .
foo = (4*) . (10+) 
`f2 = (x) -> fn(g(4,x), 5, x);` 
4) head :: [a] -> a 
a is a type variable. it can be of any type.
fst :: (a, b) -> a  
(==) :: (Eq a) => a -> a -> Bool 
5) ==, +, ... are all functions and you can define your own operators like //
you can invoke these functions using infix notation

N - define tuple with private fields, and functions starting with _ have access to them.
what if all fields are private?

N - replace `::` notation with `=` like scala.
but it will be confused with fields.
`int x = 12;`
`int func = 12;`

Y - weave evaluates the expresion so you can put asserts there!

Y - Now if we don't want to support non-nullable data types, lets define `!x` as shortcut for `assert defined x`

N - some ideas that are good to be added to the language but (some of them) will break gen and orth:
no static instance -> rejected
no public fields -> rejected
immutability
non-nullable data types -> `!` operator

Y - Like perl mock where we can override a method. no one can change behavior of a class but they can easily expose the class instance and hide some of it's methods. we cannot define this using anon-class because this will require having a field.
This can be achieved with anon-class based on a template class, but can anon-class have fields?
to have fields, they have to have contructors. then we need call their ctor. which will need a new syntax.
```
//MyClass has some_method method
TT x = TT<MyClass>.new {
    int some_method() { return 0; } //override exposed variable behavior
};
```
we can call ctor upon declaration. but this syntax is messy! what is `new` needs inputs?
we don't need to expose! yes we do. let's assume this: anonmous class is exposing an instance of it's type. That's why we have all methods ready.
`MyClass mc = MyClass { };`  right side of `=` defines a class without name, which exposese `__MyClass` private variable.
question is: how is it instantiated? if it is an interface (no fields), it's fine we can ignore this. but according to gen we have to support EVERY class here. in Java they write `x = new MyClass() { methods }`.
we can write `auto x = MyClass.new(1, 2, 9) { methods };` result will be a class exposing an instance of `MyClass` created using call to new method.
by this way we can easily create proxy classes.
for shortcut syntax, the class type is pre-specified and does not have any fields. so compiler can easily handle that.
`auto x = (a) -> a+1;`

Y - Current notation for anon-class is not beautiful.
we want to create a new instance of a class which does not have a body yet!
and we want it to have member variables (so there must be a ctor).
we should not limit this to one, if we want to permit it. so anon class can contain any number of members.
so it will basically be a normal class!
but what does it mean to define `auto x = Interface1 { method1... }`
means x is an object of type `Interface1` and we want it to have these methods too?
this definition is collection of some methods (long-form), so why not define multiple short-form anon-methods?
`auto x = {method1:(x) -> x+1, method2: (y) -> y+2} ` ?
then how can we mock an object? we want to define an anon-class which exposes variable of type MyClass, and overrides one or more of it's methods. 
Let's break it into two parts: 1. define var 2. add methods
but it will make things more complex.
```
int g = 11;
auto X = {
    MyClass __x;
    auto new :: #;
    
    int method1() { return 5;}  //hiding promoted method of MyClass
    //we don't have access to static instance here because class does not have a name
    //only this. this.g (or this.g()) has a value of 11.
};  //X will be the static instance of the defined class
auto x_instance = X.new
```
this is more gen and orth and elegant. 
what about closure? inside this class we have a `this` which has some methods returning closure variables.

Y - change `<>` notation for template. `TT<MM>.method` is not beautiful.
D: `TFoo!(int)`
Scala: `val stack = new Stack[Int]`
Rust: `struct Point<T>`
`%TFoo(int)`
`&TFoo(int)` not good,
`^TFoo(int)`
`TFoo::int` not good

Y - make `auto` optional in defining function with `::` notation.

N - make expose notation more explicit. defining a variable like others is not elegant.
```
int x = 12;
int y = 19;
auto FF :: x+1;
expose MyClass;  //exposed var can be either public or private.
expose MyClass _mm;
```
this is a definition which has the potential to add fields and methods to the current class. how can we make it more explicit and elegant? 

N - Haskell like syntax to define operators: include the operator name and let user define his own operators like `:><`
how to set precedence and associativity of the new operator then?

N - Again: Immutability, how to enforce? How to help developer write it? how to check at compile time?
can we have immutability by convention?
like `assert defined x` we can have `assert frozen x` or shortcut `~x`.
it has to be variable (object) based, not class based.
or it can be class based. we can have MutHash and ImmutHash classes.

Y - `!x` means not x. is not readable with it's meaning.
`/x`
`^x`
`&x` this is good.

N - Syntax for freezing an object?
`x.freeze()` we should be able to un-freeze the object.
we need 3 things: 1) freeze object, 2)un-freeze object, 3) check if object is frozen
`~x`, `~~x`, `?~x`
`x = ~y`
`if ~?x` if x is frozen

N - make use of `^x` notation too.
we can use it as a short-cut for common code pieces.
maybe we can let user define `~` and `^` for it's classes.

Y - operator to clone/duplicate object -> `y = ~x`

Y - operator to get ref-id of object to compare. instead of `$ref(x)`
`y = ^x`

N - How can we disable static instance of a class?
we only want a ctor. That's all. 
proposal1: `assert this != MyClass;` on all methods.

N - can we use keywords instead of operators. because keywords are memorized easier.
@ -> annotation, no.
# -> instantiation.
$ -> casting. no
% -> template. no.
^ -> get ref-id
& -> no. is a shortcut itself.
Alternative for `#`
`new :: alloc`?

N - can we make `this` required and have static/instance methods in a class?
ctor -> don't add this input.
utils -> don't add this input.
no. it makes expose and shadowing methods complex. what would be meaning of this then?
this is against gen

N - we can use weave to retry calling a method upon exception.

Y - Separate static and instance methods:
`int f(auto this, int x) ...`  //this has only instance + fields
`int g(auto class, int x) ...`  //class has only other static methods
this or forcing fields to be private, are all non-orth. lets ignore them BUT help developer implement these ideas easily.
from OOP perspective, almost all static methods can be replaced with objects.


Y - forbidding calling ctor on non-nil instance makes some kind of exception. why not let this happen?
this makes things more meaningful for anon-class too.

N - how does new ctor affect templates?
template is a normal class with it's own ctor definition. nothing is different. 

N - can we define ctor in an interface?
the only way we can use the interface in class definition is to expose it. and ctor won't be exposed!
generally we can define ctor because after all, interface is a class.
but what if we have: `INumber x`. x may be of any type like `ComplexNumber` which expose INumber. so its possible that x does not have a ctor, or has one with different name or input argument. ok but we don't need a ctor because we already have an instance: x. if someone sends `$INumber` to this function, it will have access to ctor.
exposing ctor to container is useful if container does not have additional fields. but still, return value is of contained type not the container type. `this newnum(int size)` exists in INumber as a ctor.
if we expose it in `ComplexNumber` we will have this method. we can write a new ctor:
`this new(int size,int vol) { ComplexNumber result = #; result.__inum = $INumber.newnum(size); return result;}`
also `this` means instance of the current class. so what happens if ComplexNumber does not hide INumber ctor?
compiler promotes this method so:
`this newnum(int size) { ComplexNumber result = #; result.inum = $INumber.newnum(size); return result;}`
above can be generated by the compiler but what if ComplexNumber has more than one exposed variable?
in that case, dev MUST write some ctor for the class. and exposed ctors will cause problem when got called.
problem: returning a class with some fields not initialized. but thats what the developer should worry about. we try to make language general and orth. so we expose ctor too and dev should handle this cases (by hiding this ctor).

Y - ctor is just a normal method. we can even use :: for it.
`new :: #;` here output type is inferred to be `this.`
`#` creates a `this` output.
OR:
`new :: new2`
`new2 :: #`

Y - how can I call another ctor from current ctor?
I don't have a this. but I do have nil instance.
`this c1() { return #};`
`this c2(int x) { auto result = $MyClass.c1(); result.x = x; return result;}`

N - we can say ctor output type to be MyClass instead of this and somehow fix the `call on nil returns nil` rule.
this makes language even more general.
1) every call on nil instance gives you nil except for methods that return this.
2) every call on nil instance gives you nil except for methods which have this name.
no first choice seems better.

Y - how should the default ctor be called?
`SimpleClass sc = $SimpleClass.new()`
default ctor is created when there is no ctor defined. 
compiler sets its name to be new
what if there is another method named new? `int new() { return 4;}`?
compiler will complain. so `new` is the default name to use only if there is no ctor defined.
if we have `INumber` interface without any ctor, we can call `$INumber.new` to create a new instance of the class.

Y - we can have something like this pseudo-code:
`INum create(INum a, INum b) { if ?? return a.new() else return b.new()}`
and call it: `auto x = create($ComplexNumber, $NormalNumber);`
x can be an instance of complexnumber of normal-number. we can also send normal instances to create function.

Y - how to define ctor without a static code?
so how are we going to solve ctor problem? having a special `new` method which will be called when a new instance is being created. OR like golang we can just ignore ctor and add a syntax like `new MyClass` which is same as `#` to create a new instance of the class. Note that this will affect anon-class.
this type of new will have ability to set public fields too. like golang:
`auto x = MyClass {x:1, y:2};`
what if we make all fields private? we need to have a special method!
a special method which returns a new instance.
`MyClass new(int x) { ? }`
what if we assume the body of the source file is a piece of code to be executed. This piece of code can have input argument which are used to initialize fields.
```
int $%%x; //same as ctor input parameter
int y = x;
int f() { return 5;}
```
what if we assume, when we define MyClass we are defining an object. so `MyClass` itself is an object. which has an unnamed method. so `MyClass(1,2)` will call that method. this method can be abstracted so we can call method A with `MyClass` or `YourClass`.
to make it simpler, methods that start with `$` sign are class-bound. They are part of MyClass, not it's instances. But MyClass is an object so these are not static methods.
these methods are ctors and create instances of the class but as `MyClass` is an object, you can abstract over it.
```
MyClass $init(int x) { this.x = x; }
MyClass $init2(float f) { this.f = f; }
```
But what will be type of `MyClass` then? the instance objects or the static class?
proposal: methods that have the same name and return type as the current class will be promoted by compiler to a function-pointer. You can call this fp to create a new instance of the class, without having an existing instance.
q: will these methods have access to `this`?  NO.
So for each class we'll have a set of function pointers. their type is `fn<a,b,c,d>` and their output type is the class type. we can pass these fps to factory methods or anywhere that need to construct a new instance of the class.
`Point.FromXY` and `Point.FromFile` and `Point.FromString` are three fps that create a new instance of `Point`.
Maybe we can change `.` notation here to stress they are not "Static Methods".
goals: 1) ability to return instance of a class other than current, 2) return a cached instance 3) abstract over ctor
how can we call ctor for composed variable?
what if we fix ctor name to `new`, and let dev define multiple `new` with different input types?
its ok as long as satisfies other goals.
`MyClass new(int x) {...}` we can easily define new like this. and ban `this` inside method body.
but what would be the syntax to call it? `MyClass mc = MyClass.new(11);` ?
isn't this static? this is an exception. can't we not have exceptions?
`MyClass.new` is a fp. what if we name it like a class-less function but prefix class name?
`MyClass MyClass$new(int x) {...}` so new methods won't clash. and we call it: `auto mc = MyClass$new(5);`
`auto fp = MyClass$new`; fp will be a pointer to a function getting int returning MyClass.
`MyClass$` prefix helps avoid name clash. Can dev mis-use this feature? e.g. defining math.min?
we don't let developer write output type and make it implicit.
`MyClass$new(int x) { return ...}`  but this is an exception too!
or we can say that other than MyClass instances, we are defining a new MetaObject which contains methods which include `$`. Name of this meta-object (which is responsible for creating new instances) is `MyClass$`. So you can call these methods using `MyClass$.new` notation. Blueprint object for each class, MyClass, is called, say, MyClass$.
What about calling ctor from nil object? This really makes sense and to be more convenient we can rename nil to be more meaningful. The only problem is that, we agreed any call on `nil` object, returns `nil`. So how can this be added?
`$MyClass(nil)` gives you nil instance.
`$MyClass(nil).new(1, 2)` will call new method on the nill instance with these inputs. But according to our definition, this should return nil. we can mark methods to be available on nil instance. if this case, it wont return nil. the only way is to mark return value of the method as `???`. so:
`??? new(int x,int y) { ...}` this method can be called on the nil instance.
`MyClass new(int x)` NO.
`this new(int x)` maybe. 
so if a method is not ctor and returns `this` it's better not to be marked with output type as `this`.
`this method1()` implies that method1 does not need a this, does not refer to this.
`this new(int x) { MyClass result = #; return result; }` OR:
`this new(int x) { this = #; return this;}` this implies that method cannot use inside this
`this new(int x) { this = #;}` this will be automatically returned.
`this new(int x) { this = #; this.x = 12; }`
lets make return mandatory.
`this new(int x) { MyClass result = #; return result;}` its better in the sense that we are not assigning to this.
what if above method is called on a normal instance? `myObj.new(11)` nothing, it just works as expected. note that this methods does not NEED this variable, but if it is present, that's fine.
`this new(int x) { assert not defined this; MyClass result = #; return result;}`
but it is confusing to be able to create a new instance using methods of a normal instance. if we assume above notation, then this method will only be callable on nil instance.
`this new(int x) { return #; }`. compiler enforces a check to make sure this is undef in this method.
so `nil.new` is a working method and a function pointer which can be used anywhere to create a new instance.
what about default ctor? if class has no method with output of type `this` compiler will add this:
`this new() { return #;}`
no. compiler should not do this for developer. but we want to keep the most simple application: `int main() { return 0;}`
there should be expected defaults! so the default is to create ctor.
q: how to init exposed vars? in ctor, `this.__var = nilX.new(10);`
**Summary of findings for ctor**:
1-each class has a nil instance (to be renamed)
2. calling anything on nil instance returns nil except methods which return `this`.
3. calling above methods on a non-nil instance is not allowed.
4. these methods return a new instance and are ctors.
5. if there are no such method, compiler will create a default ctor.
6. sample: `this new(int x) { MyClass result = #; result.x=x;return result;}`

Y - when we expose variable of type MyClass, will it's ctor be exposed too?
no. we don't expose methods that don't have this. only non-this methods are exposed.
I think we should expose ALL methods. so conformance to the interface is achieved.
if we expose ctor, full conform will be achieved but calling it may give you incomplete class.
if we don't expose ctor, full conform won't be there. 
exposing ctor gives us gen and orth. let developer worry about not doing his job instead of making the language non-gen for this purpose.

Y - we can have private ctors called from public ctor.
if we can have method-local static var, we may be able to implement singleton by defining it in a ctor and return existing instance!

N - how can we mock a method of an existing object?
compose the object in an anon-class and hide that method.

N - do we really need to have anon-class with fields?
without fields, instantiation of anon-class is much simpler.
answer: gen

Y - define an easy short-cut to call a method on the nil instance of a class.
`$MyClass().method1`
`$MyClass` can refer to the nil instance. it can be a shortcut for `$MyClass()`.
`$MyClass.metho1` just one extra letter `$`

Y - shall we remove `nil` keyword?
usages of nil:
`return nil;` -> `return $MyClass`
`if x == nil` -> `if defined x`
`x=nil;` -> `x = $MyClassl`
makes sense, especially now that its not really nil.
yes.

Y - now that we have ref operator, let set default behavior of `==` to compare data.

Y - better name for `nil` instance.
default instance - good
empty instance

Y - For :: if name of f and g is the same, let dev omit f name. 

Y - `#` notation is really ugly. lets find a keyword for this.
`this new() { auto result = #; result.x=12; return result;}`
`alloc`  - good, for now
`new`
`birth`
`construct`

Y - extension method. how to handle utility classes like abs/min/max?
for abs, we can add it to int. or have extension methods like C#. so we can extend these types with their new responsibility insted of adding new util class.
how can we write an extension method in a simple and readable and elegant manner?
`int f(auto this, int x) { return x+this.y}`  //in MyClass file
`int g(OtherClass this, int x) { return x+1;}`  //in OtherClass file
if a source code file name has special syntax, it contains extension methods.
if it is included, the user code will have access to those extension methods.
The big thing is, fundamental assumption is method of Class A are all define in A.e file.
we may want to add methods to `Stack<float,int>` so including class name in filename may not be that easy.
but we will be adding methods to Stack class, not a specific case.
we can name extension methods for class A, in a file named `A.ext.e`.
so we won't really need `this` too because this type is implied from file name.
what should be `A.ext.e`? `
MyClass.e represents the main class.
Maybe `MyClass.xe`, but we shouldnt' change the main extension.
Maybe we have multiple extension method files, but they cannot reside in the same directory.
`MyClass.x.e` includes extensions.
`MyClass!.e`
`MyClass#.e`
somehow this is like partial classes in C#. we are putting implementation of MyClass into multiple files.
MyClass.e methods have access to private members. others have only access to public members.

Y - how does new ctor affect anon-class?
it cannot have nil instance. because it does not have a name. `$MyClass`?
for the short-form, there is no field so we can say compiler handles everything behind the scene.
`auto f = (x) -> (x+1);` - f is an instance of a class which has only this method. no ctor, no nil instance.
`auto f = { int gg = 11; MyClass __mc; int method1() { return 6+this.gg; }` what about this one?
proposal1: by default anon-class should have a `this new()` ctor to be called by compiler.
proposal2: we can assume `f` is the nil instance and call methods on it. so `auto g = f.myctor(11)`. but this makes the code longer.
proposal1 is better. if there is no `new` method, default ctor will be created and called.
proposal2 is more general. dev needs to write one more line but we remove restrictor for name of ctor in anon-class.

Y - can we write extension methods as ctor?
should be possible. we are trying hard to make ctor just a normal method. 
the only difference is output type which is some kind of marker for developer (this is a ctor!) and for compiler (this can be called on nil instance).

Y - can we assign default for a tuple? ans: no. should not be possible.
`auto x = (age:12, days:31); `
`(int x, float f) func1() { return (1, 2.3); }`
`type myt := (int x, float f);`
`myt func1(){ return (x: 1, f: 1.1); }`
should be possible to have gen. but how? if tuple has no name, its not possible.
`myt x;` what is value of x? it is a tuple containing two fields both of which are default instance.
tuples dont need ctor and dont have a name. 

Y - replace weave with `#weave`

N - can these ctor use static field? shall we keep static fields?
`int _x;`
`int this._x`
why add this we it can easily be implemented using private field?

Y - can extension methods file contain fields?no.

Y - we should separate short and long form for anon. because they behave differently.
short-form should be renamed to lambda or something like that.
long-form -> anon-class.
if we name them both as anon-class gen will be hurt because one form does not need instantiation the other needs.

\* - maybe later in core we add some helpers for mocking.

N - how can we mock ctor?
create a new class, expose MyClass. write your own ctor.
but when they call `$MyClass.new` it will be sent to MyClass.
like Perl mock a module.
don't! just pass an instance.

Y - Shall we return `struct` to make things more tidy in the source code file?

Y - using extension methods can make code confusing. adding new methods to an interface.
then cast won't work!
just consider `.x.e` continuation of the original file without access to private fields.
this shouldn't cause a problem.

Y - having two extensions is not good. its confusing.
why not name it same as original file?
`MyClass.e` can contain the original class or extension methods.
difference? the original class file contains `struct` section. 
what if ext file has struct too? methods will have access to internal struct + publics of the other struct.
and dev is responsible for name clash. 

N - what if we expose x which is exposing y. Y has some empty methods but they are no longer empty according to x. they have a redirection code to y.
maybe we need some mechanism for interface inheritance and another for class composing.
```
///X.e
int f();

//Y.e
X __x;
//so we will have this written by compiler: 
int f() { return __x.f(); }

//Z.e
Y __y;
//so we will have:
int f() { return __y.f();}
//but we want to implement X interface here
int f() { return 11; }
//above is ok, it will stop promoting X's f method.
```
we should not be exposing an interface to implement it's methods. just implement them! 
although exposing does not make any trouble.

Y - Can we force classes to define all fields as private?
then shall we prefix them all with `_`?
for methods this is good I think. but we can just state that fields are not public.
so if we expose MyClass, it's fields won't be promoted. only public methods.

Y - shall we have different syntax for field access vs. method access?
especially if fields get private by default.
`this#field1` good.
`this!field1`
`this>field1`
`[this field1]`
`this[field1]`
maybe we should use something else, not this.
`struct.field1` anyway using dot notation is not good.
it's better if its a single char without needing shift key.
`this/field1`
`struct.field1`
no it will be confusing.
`this_field1` no.
why not use something instead of this and keep dot?
`this@field1` - then what about annotations? 
we can use c# mode: `[title(key=value,...)]`
or C++: `[[title(key=value, key=value,...]]` - this one is more clear. 

note that `this!field1!field2` is not allowed.
what about tuple?
we are accessing fields.
`type myt := (int x, float f);myt m; m.x=11;`

N - we can have: `this@cache[t]@field1` but its fine.

N - Need to better think about what a tuple is.
do we really need it?
how is it created? what is it's ctor?
can it compose something?
`type myt := (int x, float f);myt m; m.x=11;`
what is value of `m` after definition? can we even use `m` anywhere?

Y - shall we use `[]` notation for tuple, instead of `@`?
`type myt := (int x, float f);myt m; m[x]=11;`
this somehow indicates it is not a class. but something like a hash-table.

N - can we compose something without promoting? just as an indication that we want to implement X in our class but dont need auto-definitions made by the compiler.

Y - What happens to ctor if we have two MyClass.e files both having private fields?
maybe we can ban defining ctor in extension methods.

Y - immutability by default?
http://www.yegor256.com/2014/11/20/seven-virtues-of-good-object.html
ok. let's return const.

Y - make field access syntax the same for class and tuple.
`t[field]` vs `this@field`
the first one is more intuitive but similar to hash. but it's fine. better than strange `@` notation.

N - we can remove struct because we simply enforce ordering of fields in the class. let's decrease indentations.

Y - maybe we should return `<>` for template and remove `%`. it is more intuitive and having two prefixes to refer to default instance of a template seems awkward: `$%Stack(int)` vs `$Stack<int>`

Y - can we just ignore tuple concept and act like golang?
functions can return multiple values: 
`(int a, float f) f() { return 1, 3.1;}`
calling those functions: `iv, fv = f();`
that's all we have for multiple-return.

Y - pre-requirement for MCSF: why do we need anon-class?
go doesn't have it. c# doesn't. only java.
if the syntax to define a class becomes cheap, dev can just define a normal class.
also we can use a set of lambda.
con: they are hard to test.
con: they make syntax clumsy.
I think we can remove them. they were only added to java to support some kind of closure but now we have lambda.

N - can we restore `this` notation to indicate method returns this?
then what happans to ctor?

N - how should we address default instance of a template?
`$%Stack(int)`?

Y - what about const?
`type x := struct { const int x;}` x should get a value upon alloc call.

Y - now that all fields are private, maybe we can replace `__` with `_`?
but `_` means private. all fields of a struct are private and only accessible to the methods of it.
`this[field1]`
maybe we can define a prefix for fields which will be exposed. e.g. `$`
or `%`. it was used for template but now we are using `<>` notation so `%` is not used anywhere else.

Y - now that all fields are private, expose won't cause a name clash for fields. we should only handle conflict for methods.

N - note that we still cannot override empty methods of the exposed type. unless, the exposed type provides some methods to set some function pointers.

Y - what about defer(out) when function has multiple outputs?
`(int a, float f) f() { return 1, 3.1;}`
for above function: `defer(a,f) ...`

Y - template: we dont need default and multiple interfaces for type-checking.
`struct Stack<T: Parent>`
we can remove typename.

N - gen similar syntax for array and hash.

Y - if we can define class-less functions, we can convert most of operators to functions.
like ref/copy/dup/...

Y - when we say struct fields are public they are public forever for all.
but when we say they are private: to whom? who can access? what about other files?
if we define struct as immutable, then making them public will have less risk.
also we can do the same for functions. convention to have them private. 
and at most, give some warnings if they are used outside.

Y - if we have classless func, we can define `range` and `map` to have `for` statement. no need to have a separate loop keyword.

Y - consistency is simple. 
order enforcing is not simple.
`int (int x).negative() { }`
its bettern to have 100 simple elements than 10 complex.
in FP we have data and function. and possibly interface.
in OOP we have data, function, interface, class.
things should look similar.
what are the things that absolutely are useful? abstraction, code re-use, 

N - With the receiver notation there will always be a confusion about difference between these:
`int (MyClass this).func(int x) ...`
`int func(MyClass this, int x)...`
are they the same? if they are, which one is better? How should I decide which one to use?-> confusion != simplicity
if they are different, what is the difference. they seem similar and we expect them to be the same -> law of least surprise.
If they are different: suppose that we have a function to send a message. what should be the prefix structure?
the message structure? the recipient? the sender? which one should be put first? everyone can have it's own idea and each setting will result in a different code.
calling a function by parameter name will solve the order issue completely.
`int f(struct1 s, struct2 t, struct3 u)...`
`int g = f(u: u1, t: t1, s:s1);`
so we don't even care which one comes first.

N - calling functions by name makes code more readable. what about forcing to call by name?
(about argument passing)

N - to achieve immutability and performance, we may provide some syntax to create a new object/record based on another one. which will be processed by compiler to generate efficient code.
`file f = ...; file f2 = clone(f, name='aa');`
or `file f2 = f.name='aa';`
`f = f.name='11'` f will be pointing to a new structure
`f = new struct{name='g'}; g=f; f=f.name=11;`
what is value of `g.name` is must be 'g'.
f.name is '11'.
if we implement struct fields as pointers behind the scene, this can be achieved.
`f = f.name='11'` will create a new f point all of it's fields to existing values of previous f, update name pointer.
or: we can implement runtime inheritance.
`g = f.name='11'` g will be a dynamic dispatch for it's fields.
all of g's fields will be redirected to f fields, except name.
in memory we have this for f and g and other data: 
`ptr memoryAddress; ptr parentRecord; ptr exclusiveFields;` something like this.

N - having things like `executefile('dsadsad')` in the code is just confusing. where is this function defined?
`time.sleep(5)` what does 5 mean? do I need to look at documentation for each method call?

Y - FP and OOP can be orthogonal. so employ both of them.
like Scala or F#

N - If I have a bound function to MyRecord, can I call it without an instance of myrecord?
`int f(Rec r, int x)`
`int (Rec r).f(int x)` two methods to define a function. this is not good.

Y - if a function expects FirstClass, and we send SecondClass (where SecondClass inherits from FirstClass), it is polymorphism.
SecondClass has some extra fields and associated functions. we really don't (and can't) call those extra because we expect a FirstClass. Also, from a data point of view, SecondClass has a field named "FirstClass". so why not send "obj.FirstClass" field to the function and it can also call corresponding functions too. because it has a first-class data structure. 
encapsulation is primarily used to hide implementation details. we can simulate them with `_` fields. 

N - what is the difference between:
`int f(MyClass mc, int x)...` -> f(mc, 10);
`int (MyClass mc).f(int x)...` -> mc.f(10);

Y - can we define 'receiver-less' functions?
e.g. filter/map/reduce/

N - proposal: treat predix of the function name, just like a variable. so it can even take a default value!
`int (MyClass mc).func(int x) {}`
`int (MyClass mc=$MyClass).func(int x) {}`
`int (MyClass mc // $MyClass).func(int x) {}`

N - the golang syntax to define methods is more explicit: `int [MyClass this].compare(Stack<T> a, Stack<S> b) {...}`
one class per-file is simpler and does not need to define `this`.
you can define `type A := int;` and define methods on A. `this` will be an integer in the code.
this is not achieved by implicit receiver.
simplicity -> dealing with functions instead of objects and classes.

Y - how shall we define an interface in the new form?
define a struct with possibly no fields.
`type Comparer := struct;`

N - how to define a method like compare or copy without adding a new struct?
e.g. `int [MyClass this].compare(Stack<T> s1, Stack<U> s2) { ... }`
can we define template methods? in addition to template structs?
`int [Stack<T> this].push(T data)...`
`int [Stack<T> this].compare(Stack<T> s1)...`  //compare with current class
`myClass.compare(s1, s2);`
if there are multiple types involved, write a specialized class.
if single type and same as current type? like above.

N - define a shortcut to define methods on a struct, if struct type can be inferred.
`int [Stack<T> this].compare(Stack<T> s1)...`
`int [Stack<T> this].push(T item)...`

N - prohibit value assignment in struct definition. we just define list of fields, components of the struct.

N - what about primitives like int?
`type int := struct(4);`

define a set of methods on that struct type.

N - we have struct (collection of fields), interface (collection of method definitions), enum (collection of values).
`type MyClass := struct { int x; }`
`type myInt := interface { methods }`
`type xxe := enum { values }`
`type xwe := int ()` for enum.
we can ignore interface and just use struct. so interface and class will be similar.
`int [MyInterface].f(int x);`
for each type (enum, struct,) we can define a set of methods.
interface can have fields too. 
what about exposing?

Y - adding receiver is a little bit un-natural.
`int (MyClass this) f()...`
instead of a normal function that everybody knows just like java, c#, go, c, perl, python:
`int f(MyClass this, int x) ...`
another thing: we write `MyClass mc = ...; mc.method1()`
but the owner of the `method1` is not myclass. it is a free-form function.
myclass is just a struct with some fields to none of which we have access!
`struct MyClass {...}`
what if we write: `method1(mc, 1, 2);`? seems to procedural.
receiver type says, this struct is what will sit on left-side of the dot when calling this method.
can we come up with another syntax which is as explicit as receiver method but more intuitive?
first of all, there is not a specific explicit grouping of methods which can be applied on a struct and there shouldn't be. so we can have extension methods or methods in other files.
so there is no indentation.
`int f(int x)`
`int (MyClass this) f(int x)`
`int MyClass.f(int x)`
(btw we can simply ban defining a function without receiver type. its like defining a function without output type).
`int (MyClass this).f(int x)` this seems better. it is more similar to the actual method call.
also by definition makes defining orphan methods meaningless.
`int {MyClass this}.f(int x)`
`int [MyClass this].f(int x)`  adv of this: makes receiver definition completely different from normal inputs.
also needs `[` which is a single key letter, does not need shift.
`int MyClass this.f(int x)`  this is confusing

N - Do we still have a base class for all template instances like `Stack`?
we have methods that are not bound to a type like T:
`int [Stack<T> this].push(T data)...`
`int [Stack this].clear()...`  this does not need type T, so if we write a method like `f(Stack ss)` we can call clear method on ss. but not push and pop. right?
`struct Stack<T> {...}`
is not intuitive.
what if I want to write a general method acting on any stack?
assume this is on class MyClass:
`int [MyClass this].func(Stack<T> ss) { ...}`
or I want to write a function to compare two stacks.
either template-enable your class with S and T, or use some common interface.
`int [MyClass this].compare(Stack<T> a, Stack<S> b) {...}`

Y - what about exposing an interface? it's meaningless unless we want to explicitly indicate that we are conforming to that interface. UNLESS interface has some fields. but again, expose just exposes public methods. so it's meaningless.

N - if we define a private method on MyClass, can it be accessed from another file's method which is based on MC?
what is the scope of private? is it shared between all functions receiving MC?
or current source code file?

N - pre-req for MCSF: how can we bind a method to a class?
suppose we have a class name and want to bind a method to it.
`struct A {int x;}`
`int A.f() { return 5;}`  //this is implicit not explicit
`int f(A this) { return 5;}` this is explicit but notation is not explicitly bound to A struct
`int (A this) f { reutrn 5;}` this is explicit about this and binding but what if we add another receiver?
`int (A this, B that) f() ... ` ? are we going to BAN this?
`int f[A this]() { return 5;}`
gen: binding is optional
gen: this name is optional. you can have any other name
`int (A this) f (int x, int y) { return x+y+this[xx];}`
//f below is defined on MyClass, but has no access to this. returns a this.
`this (MyClass) f(int x) { return alloc{}; }`
`this [MyClass].f(int x) { return alloc{}; }`
can they define: `int (MyClass) f(int x) {}` should be allowed. this is a real code of the class but does not need access to this. 
`int (Stack<T,U> this) pop() { ...}`

N - how to define class/interface/enum/template?
`struct MyClass { fields}`
`interface ABCD { methods }`
`enum AB { values }`
`template a(T,U,V) { fields + typenames }`  //or maybe struct
`struct Stack<T> { ... }`
`struct Stack<T: Comparable> { ... }`
`struct Stack<Comparable T, Disposable U> { ... }`

N - how to define members of template?
`int (Stack<T> this) push(T value) { ...} `
`int (Stack this) push(T value) { ...} `  //if we remove <T> is is implied?
and we won't have `Stack<>`. 
specialization is easy: `int (Stack<int> this) push...`
now that we don't have Stack<> and Stack as parent of all, we can write `int [Stack this].ff` and ignore type declaration for each fucntion. it is not explicit but typing `<T>` for each function is a pain.
shall we update struct accordingly?

N - having extension methods have access to class fields is a form of gen.
also those methods won't be called by anyone except the dev or people who trust him.
if code gets compiled without any metadata or documentation, field access will be meaningless. because what would be variable names? also compiler won't know what to do with `this[field1]` does the class even have this field?
we can have `_` for private private fields and other cal be accessed by ext methods. 
but this will be confusing.

Y - MCSF (Multiple class in single file)
in the current pure OOP method, we may need to define a lot of classes.
e.g. Printer, NoNullPrinter, ...
shall we use keyword `class`? if so, maybe we can go like golang, and it will make adding extension methods much more clearer?
so instead of class, we use struct.
```
struct MyClass { int x;}
int MyClass.f(int t) { return t+this@x; }
//in another file
import MyClass;
int MyClass.g(int y) { return y+this@x+this.f(10); }
```
what about interface? `interface x { method definitions; }`. what if we want to add empty members to a class? question is: what are they for? why do we need abstract class? to be inherited by another class? this is not allowed! so we simply cannot define empty methods. of course we can have the syntax sugar to return nil for empty methods.
we can have interface inheritance without complex syntax of composing: `interface A:x, y, z { methods }`
what about :: notation?
ctor: `this MyClass.new(int t) { return alloc{}; }`
what about methods that don't have struct name prefix? OR instead of prefix we can add it as first argument.
`int f(MyClass this, int t)`
this will help creating small classes.
other languages give access to private variables somehow, so why not give it to extension methods straight away?
maybe defining interface as a class was not a good idea.
what happens to anon-class and lambda? lambda is ok. anon-class: `auto x = { fields and methods; }; auto y = x.new();`
here we can make use of interface. `auto x = Interface1 { methods };` but this contradicts with the way we define other classes. remember: gen and orth.
what about function pointer? lambda.
what about template? maybe using `struct<T,U> {...}`. By this way, specialization of template becomes easier. 
I may need to re-visit and re-design most of concepts.
but honestly, in action defining 10 files each having 10 lines for 10 classes is a pain.
in Java we have one file per class. but in C# and golang there is no such limit.
then where should we place type and typename definitions?
what about enum?
what if a method is not bound to a type? like golang? this is gen I think. we should allow them.
how to define ctor?

Y - expression problem: we want to be able to extend program easily 
extend: adding new objects (for a shape system, adding triangle)
extend: adding new operation (calculate permieter for every shape)
easily: adding one new object or operation does not need modification of 1000 files
if we have Shape -> Rectangle, Circle, Oval, Square all having area function
extend1: adding `Triangle`
extend2: calculate `perimeter`
in OOP extend1 is easy: add a new class and inherit from shape
in FP extend2 is easy: add a new function and in it, for each type, define formula for perimeter calculation
both reverse is hard. adding perimeter function in OOP means updating all those classes
adding Triangle data in FP means updating all functions that are working with shapes
one solution is to act like OOP but only for data, not behavior. so structs can inherit from each other and functions work on structs. if a function works on Shape, we can send a Rectangle struct to it.  
addin Triangle: means a new struct inheriting from shape struct (struct = data only) + new function for area of triangle
adding perimeter: a new function (or multiple functions per shape type)
```
struct Shape { string name; }
struct Square: Shape { int side; }
struct Circle: Shape { int radius; }
function area(Square s) = s.side**2;
function area(Circle c) = c.radius**2 * 3.14;
//adding triangle:
struct Triangle:Shape { int side1, side2; }
function area(Triangle t) = return t.side1*t.side2*0.5; 
//adding perimeter - assume we don't have original source code for others
function perimeter(Square s) = s.side*4;
function perimeter(Circle c) = 2*3.14*c.radius;
//general function
function getName(Shape s) = s.name;
note that we can call getName with a shape or circle or square or ...
```
Let's call this structure inheritance or structure oriented programming.
you can hide a method in a child struct: if parent struct hash `clear` method, just define: `int clear(child c);` as an empty function.
you can override a method in a child struct and call parent struct's method in the code by `function(@parent(child))`
(casting).
note that if struct A includes struct B, calling a function which is defined on both A and B with `cast(Ainstance to B)` will call B version. now if that function calls another similar function, the chain will continue with B version functions.

Y - with struct inheritance, do we need interfaces?
I think we only need structs. When we expect a set of operations to be available (e.g. Comparable interface including methods for comparing data), we provide a struct and call required methods on that struct.

N - maybe we can use namespace or module to group functions.
so in the code instead of writing `produce_data` we write `db_structure.produce_data`.
and the prefix is not part of function name. it is module/namespace name.
so where should we define structs? in a namespace?

Y - basically we want to have OOP and FP.
FP exclusive features:
- first-class, pure and higher-order functions
- immutable data types, no re-assignment: if you see `x=???` you are sure it is the same value even at the end of function. so there is no `=` operator.
- lexical closure

N - how can we implement a stack in a immutable and struct-inherit system?
what is advantage of immutability?

N - how to implement array or hashmap?
we can replace array with a hash-map with int key.
doable in native code.

Y - what if we pass Circle to `int f(Shape s)` and f calls `Area(s)`?
which one will be called: `int Area(Shape s);` or `int Area(Circle c)`?
the second should be called. the function call is resolved according to the real type of the data. unless data is casted.
we can model abstract calss like this. 
abstract class = data -> struct, full methods -> functions, empty methods -> nothing?
concrete class = data -> struct inherit from abstract class data, methods -> implementation of empty methods of abstract data.
for empty methods we can just add an empty function so indicate what should be implemented for concrete classes:
abstract shapre class: `int area(Shape s);` is an empty function.
interface: a set of empty functions working on a data strcuture. 
data structure can be even empty.
so if in Circle we want to call `f(Shape)` if we call it like `f(@Shape(x))` and f calls `g(Shape)` and we have `g(Circle)` the g(shape) will be called. but if we call it like `f(x)` where x is of type circle, g(circle) will be called.

N - can we have mixin/trait/role in struc-oriented?

N - now inverse to the initial 'everything is an object' we have 'nothing is an object' :-)

Y - if function has only one input, providing parameter name when calling it is not meaningful.

Y - we can say fields starting with `_` are internal fields of struct. and functions that define that struct as `this` have access to those fields. but what if function needs access to internal fields of two structs?
if function input starts with `_` function has access to internal fields of that argument.

N - how can we implement strategy pattern in struct-oriented?
strategy? function pointer can helpful. but what if strategy has a state or multiple methods?
null? clojure has nil.
facade? define `struct s1: s_old` and define all methods you need on s1.
16 of 23 design patterns are not needed in lisp or dylan: http://www.norvig.com/design-patterns/img010.gif

N - to organize functions:
we can define a flat file hierarchy each file representing a module. and prefix module name to function and structs.
`prefix.element_name` - prefix cannot map to a directory because then finding definition of element will be hard.
we need to have an easy mechanism to find definition of a function.
haske as import: `import Mod as Foo`
clojure has require: `user=> (require '(clojure.java io))`
we can separate files that contain structures and function files.
we can force a flat folder (a folder like lib which contains ALL modules) and use underscore to separate name part if needed. or a one-level hierarchy: `lib` contains a set of files and folders. and there is no more folders.
in a module, we can export only some functions.
if we have a prefix like `module1.function1` then how can we add a new function without having access to the module?

Y - we can add a notation to specify mutable data types. when these are used in a struct or used in a function, it means function is not pure.

Y - now with this new approach, do we need generics? if yes, how should they be implemented?
I think we need it.

Y - can we use golang's expose here too?
```
struct A {int x;}
strut B { A; int y;}
B.A.x = 11;
```
functions that operate on A can accept a B too, because B can be easily casted to A.
also B.x will be mapped to B.A.x
so we should be able to define custom delgations too:
```
struct B{ A a;
int g :: a.xgg;}
```

Y - we should be able to add new operations for data types that are defined in external libraries.

Y - if we have struct A which inherits from B and call function `f(x)` where x is A and we have two f functions for A and B, which one should be called? what about the case where inside f we call `g(x)`?
if the function is only implemented for A, then there is only that choice.

N - suppose we have a message structure with AMessage and BMessage children. when we receive data from network/db/any external source it is a message but can be mapped to A or B message. just write `f(AMessage)` and `f(BMessage)` and call `f(deserialize(message1)`. Runtime will automatically call appropriate function.

N - what if we want to write a function to calculate intersection of objects.
f(obj1, obj2) - we have circle, square and rectanble.
we want f(rectangle, square) also handle (square, rectanble) case too.
this is doable with named arguments? `f(square arg1, rect arg2)`
no.
we can define `f(square, rect) :: f(rect, square)` or we can call it in correct order.
this is not a major problem.

Y - 
principles of OOP are: abstraction, polymorphism, encapsulation, inheritance (this last one is not necessary)
so refined principles: abstraction (hiding details) and polymorphism (multiple implementation under same name)
principles of FP: first-class functions (send a function with int output instead of a number), pure functions, immutability, lexical closure
OOP pro: 
cons of OOP: many small classes and methods are possible, 
FP pro: functions are composable
con of FP: a lot of functions which is hard to track.
we have abstraction by struct casting and polymorphism by defining a function for different types in a hierarchy.

N - can we define a function f on A and state it cannot be re-written for children?
why? if they decide they want to, they should be able to do that. 
in the child implementation, they can explicitly request calling A's f by casting.

N - what about building objects at runtime:
`attach(myStruct, f1, f2, f3)` will give you an object.
this object has myStruct as private data fields.
f1, f2, f3 all expect input of type myStruct which is already provided.
`attach(myStruct, f1(myStruct), f2(myStruct), f3(myStruct))`
`result = create { f1(x,y) => ff1(x, myStruct, y), f2(z, t) => ff2(z, t, myStruct) }`
from outside, myStruct is hidden, it will only have f1 and f2 functions.
`Interface1 result = create_interface<Interface1> { f1(x,y) => ff1(x,10,y), f2(z,t) => ff2(z,t,t,11) }`
we have a definition for interface1.
`int func1(Interface1 ii) { return ii.f1(1,2);}`
above can provide abstraction + encapsulation.
we can define an interface using a set of functions? but how to group them?
interface has no state or fields -> so we can simply group some functions. state is in function inputs.
but advantage is that we can have a hidden storage for data which provides encapsulation.
these internal functions can be hidden and un-accessible from outside. the only way to access them is through the given interface. the creator can even copose them. but do we really need an interface for that?
`func public_func = x,y -> private-func(1, x, y)`
a function which creates an interface can be the gateway to a module.
suppose reading a complex file. this modules can encapsulate all the logic and only expose required functions.
but how can we extend this?  how can we provide this for another file type? ans: by implementing same interface in another module which is implemented for another file type.
how can we add a new function to this interface? when there are for example 10 modules implementing it?
e.g. a function to calculate CRC of the file, which needs to be added for all file types? maybe if interface is like a hash-table, we can simply add a new entry. But it should have full access to file structure. visitor pattern can solve this. we should see how it can be fit in the current system.
maybe we can simulate interface with a super-function which can dispatch to other functions.
`struct super-struct {}; function f1(super-struct ...) {}; function get_super_struct() { return super-struct{10} }`
get-super-struct returns a struct which will affect dynamic dispatch at the runtime to redirect calls to f1 function.
and super-struct can inherit from normal-struct and we have two f1 functions for normal and super struct.
we can cast return of get-super-struct to a normal-struct so caller won't notice extra fields in super-struct but when he makes a call, it will be redirected to functions that accept super-struct.
to add a new functio we can simply implement it accepting super-struct. 
`normal-struct create() { return super-struct; } f(super-struct ss){} f(normal-struct ss){}`
we have polymorphism, inheritance (super inherits from normal), encapsulation (super fields are hidden from outside). and we have kind of abstrction because outside just needs to call f function. and f can call other module-private functions.
note that create returns a super-struct but outer world thinks it is normal struct. as a result, there must be a function accepting a normal-struct too. or else, it will become to messy and compiler won't be able to check anything before runtime.
so normal-struct contains public fields and super-struct contains private+public fields.

N - how can we solve expression problem while maintaining a module name prefix when calling functions?
when we specify module name, we are telling which function we want to be called but we should not decide about this.
we should write `prepare_data(data1)` and runtime will chose between 10 `prepare_data` functions from 10 different locations in the source code, which one is appropriate.
this is like OOP where we write:
```
ICar car = make_car(10, "A", ...);
car.deploy(10); 
```
we don't know which deploy will be called? the one in "ToyotaCar" or "BMWCar".
but pro os OOP is that when I type `car.` IDE or some other tool can give me "possible options" as a set of method calls that can be made on the car. but in FP, I have no clue.
```
car = make_car(...);  //can return car struc or bmw_car or toyota_car
deploy(car);  //before typing deploy, what are my options when calling a function?
```

N - how can an IDE help me when I want to write `deploy` method when it doesn't know what am I going to pass to the function? basically I can write name of any function at the beginning of that line.
what if we change the call syntax the other way around? `(car).deploy`?
this will call deploy function on the car struct but the advantage of this is that as soon as I finish `(car)` and type the dot, IDE can easily list all methods which:
1. accept a single argument
2. that single argument is of type `car`
or `(car)deploy;`
`(car)->deploy`
`car deploy` - the last work is function name
`10 20 multiply`
`10,20.multiply`
`(10 20).multiply`
`{10, 20}.multiply`
`car.deploy` - this is really like OOP!
we can have `int f(int x, int y)` and write `10.f` which will give a function getting int returning int. 
`(car)<-deploy`  do action 'deploy' on `(car)`
so we should change function definition accordingly.
`(int x, int y) deploy: int {}`
how can we compose functions then?
`((car).deploy,10).prepare` - the prefix paren is confusing
`car>deploy, 10>prepare` prepare gets output of car.deploy and 10
how can we get output of the function?
`int x = car.deploy`?
`int x = car>deploy;`
`int x = #car>deploy, 10>prepare#`
`int x = car>deploy, 10>prepare, 20>finalize` does prepare get two inputs and output goes to finalize or prepare gets one input and its output + deploy output go to finalize?
`int x = ((car).deploy, (10).prepare), 20).finalize;`
function definition: 
`int (car c, int x, int y).finalize {  ... }`
`def(scala, python)/fn (rust)/func (golang) int (car c, int x, int y).finalize {  ... }`
I think func is more descriptive. now that we are putting more effort on function, we should have a dedicated keyword.
`func (c: car, x: int, y: int).finalize -> int {  ... }`  //this is more similar to call by arg name
`func [c: car, x: int, y: int, int].finalize {  ... }`  //[] is cheaper than ()

`func int [car c, int x, int y].finalize {...}`
`func int [int a, int b].calculate {...}`
`int x = [c1, 10, 20].finalize;`
`int z = [[c1, 10, 20].finalize, 11].calculate;`  //typing this expression does not need pressing shift-key
what if we don't know exact signature of the function? we have a struct X and want to prepare_data for it. but there are other arguments. how can I invoke IDE's info for functions defined based on X? 
provide option to put arguments before or after function name! 
`func int [car c, int x, int y].finalize {...}`
call: `int x = [c1, 10].finalize[20];`
or we can simply write `[c1, 10].` and IDE will show us functions that accept at least two arguments of these types.
so let's remove optional ordering.
`func int [car c, int x, int y].finalize {...}`
but if we call `[c1,10].finalize` result will be a function, which takes an input y and outputs an int.
`[20].[c1,10].finalize` - seems weird!
`[y:20].[c:c1, x:10].finalize` - but dev does not know the name of arguments, in general.
what if I write `finalize(`? IDE will show me 200 functions. but it should provide me with some search/filter option.
let's not pollute the syntax.
`func finalize[c: car, x: int, y: int, int] { ... }`
`auto tt = finalize[c1, 10];` tt is a function getting an int returning int
`auto r = tt[20];` r is int
lets focus on correct, gen, orth syntax. IDE should handle all helps for dev.
defining anon-func:
`auto qq = func (c: car, x: int, y: int, int) {  ... }; int qq_result = qq(car1, 10, 20);  //we asume there is no other function named qq. if there is, priority will be with local anon-funcs; also you cannot define a variable with the same name as a function`
when we say `(int:x)f` x input can be anything producing int. so it can be a function too.
in anon-func we know input and output? maybe not.
`auto xx = int [int x, int y] { x+y }`
`int t = (10,20).xx;` syntax is similar to normal function call and it should be.
note that if there is already another xx function in the scope, it will be hidden.
defining a function which has input/output of type function?
this syntax is weird where we put arguments first

Y - syntax should be as readable as possible. `func fname (name:type) -> output_type` is better.
`func sort(x: int[], comparer: func(int,int -> bool) -> func(int, bool)) { bool b = comparer(10, 20); }`
`auto x = func(a:int, b:int -> int) { return a+b; }`
`auto x = map({$1+1}, array);` //input for map is func (int -> int), $1 refers to the first argument, map is also a 
`auto x = func( -> int) { return 10; }`  //verbose syntax
`int y = x();`
`auto x = func( int, int -> int) { return $1 + $2; }` 
when we assign anon-f to a variable, we should specify input and output?
`type comparer := func(int, int -> int);`
`comparer rr = { $1+$2};` when type of anon-func is implied, you can omit input and output an use $1, $2...
`comparer rr = func (int, int -> int) { $1+$2};`  //but if you specify func keyword, you have to write input output types. still input name is optional and you can use $ notation fucntion.
`comparer rr = func (int x, int y -> int) { x + $2};`  //you can always use $i notation.  

Y - what is definition of map? 
`func map<T>(f: func(T) -> T, arr: T[]) -> T[];`
usage:
`new_array = map({$$+1}, my_array);`
or `new_array = map<int>({$$+1}, my_array);`
type T can be inferred from inputs.
`void push<T>(T data, Stack<T> stack) { ... }`

Y - how to prevent function name collission? 
I want to define a temporary function in this file, how can I be sure its name is uniqe?
function names starting with `_` are not exported. they can only be called internally.

Y - ban $1 because it is not readable. 
if anon-func has only one input, we can use a notation like `$_` or `_` or `$$`.

Y - you can only define an expression for anon-func. if it is more complex, just define a normal function for it. 
output is not specified for lambda because it is inferred from expression type.
normal function: `func sort(x: int[], comparer: func(int,int) -> bool) -> func(int -> bool) { bool b = comparer(10, 20); }`
`adder rr = func { x + y };` input/output is inferred by type (adder) so you can omit them
`adder rr = { x + y };`  //the only case where you can ignore func is where type is specified or inferrable (e.g. in map)
`adder rr = func (x: int, y: int) -> { x + y };` output is inferred, input name is given
`auto rr = func { x + y };` wrong - input is not specified
`auto rr = func (x: int, y:int) -> { x + y };`  //when you use auto, you must specify input type. input name is optional.
`auto chained = func(x: int) -> { rr(x, 10) }`  chained will add 10 to the x input

N - in anon-func can we omit `{}` because it is expression.
`auto chained = func(x: int) -> rr(x, 10)`
`adder rr = x + y;` but how can we know this is not a statement? func should be required.

N - it is more readable to write: `data.action1(1, 2).action2(3, 4).action3(5)` rather than:
`action3(5, action2(3, 4, action1(data, 1, 2)));`
haskell has . for composition of functions.
we can write: `action1(data).action2($_, 3, 4).action3(5, $_)` where `$_` specified the place of item before dot in the input arguments.
`f(x,y)` can be written as `x.f($_, y)` or `y.f(x, $_)`
if f has only one input, we can ignore `$_`.
so: `data.action1().action2(3, 4, $_).action3($_, 5);`
`f.g` where f is a variable and g is a function, means calling g with f as input.
OR
`action3($_, 5).action2(3, 4, $_). action1(data)`
where `f.g` means run g and feed the result into f.
so instead of `f(x,y)` we can write `f(x,$_).y` or `f($_, y).x`
which notation is better?
suppose we want to rever sort even numbers.
`reverse.sort.even(num_array)` - math like
`even(num_array).reverse.sort` - OOP like
math like is better, I think. but OOP like is more similar to machine, it is more imperative.
`f.g.h(1)` means `f(g(h(1)))`
so dot operator can be used to chain method call? and fetch struct member?
it's not good to have two tasks for an operator. 
we should define another one:
`action3($_, 5) <- action2(3, 4, $_) <- action1(data)`
`reverse($_, 5) <- sort(3, 4, $_) <- evens(data)`
and if a function has just one input, we can omit `($_)`
`auto final_result = reverse <- sort <- even(data)`
this is an anon-func for function composition
`auto final_result = func (x: int[]) -> reverse <- sort <- even(x)`
`auto res = final_result(array1);`
`->` and `<-` together are cluttered. maybe we can replace one of them with another symbol.
`auto final_result = func (x: int[]) -> reverse << sort << even(x);`
`auto final_result = func (x: int[]) -> reverse($_, 5) << sort(3, 4, $_) << evens(x);`
we are not following the goal to make program as compressed and short as possible. 
so we make some things required that can be inferred by the compiler but indicating them in the source code makes the code more readable and self-documented.
OOP like it will be (preferred):
`evens(data) >> sort(3, 4, $_) >> reverse($_, 5);`
any idea for an alternative for >> which doesnt conflict with shift operator?
`evens(data) |> sort(3, 4, $_) |> save |> reverse($_, 5);`
`evens(data) => sort(3, 4, $_) => save => reverse($_, 5);`
`=>` is good. for hash we will use `key:value`

Y - we have to decide between `(int x)` (used in C, Java and C#) and `(x:int)` (Rust, Go) notation.
the normal variable assignment will be like C: `int x = 12` so it's better if we have same syntax in func definition.
which one is more readable? 
`func sort(x: int[], comparer: func(int,int -> bool) -> func(int -> bool)) { bool b = comparer(10, 20); }`
`func sort(int[] x, func(int,int -> bool): comparer -> func(int -> bool)) { bool b = comparer(10, 20); }`
SO: Most of the time you need to find names of references/mathods fast (visually), not types.
SO: Pascal syntax is context-free, C syntax is context-sensitive.
so `x: int` is better.

Y - when output type is not specified, it is void. now that we don't have a class, return this does not make sense.
`func set(x: int) {}` 
does not have output, just input

Y - what if struct A inherits from B and C and we have this call: `A x = get(); f(x)`
but we have three f functions for B and C and A?
`struct A: B,C {int a;}`
`int f(A a) {}`
`int f(B b) {}`
`int f(C c) {}`
if get() returns an instance of B then f(B) will be called. C -> f(c)
if it returns an instance of A and there is no f(A) then there will be a problem.
when there is a call `f(x)` and real type of x is A, runtime will call `f(A)` function. if there is not such a function, parents of x will be investigated. if there is a `f(T)` where T is a parent of A, it will be called. no call will be made if there is ambiguity (no call candidate or more than one candidate).

Y - int/float/... all are special structs. so you can have functions working on int. and call them like:
`int x = 12; f(x)`

N - can we have mixin here?
a mechanism to define a number of functions for our new type?
just implement the new type from A where mixin functions are defined for it.
if you want to override, add function with same name on your type.

N - clojure has `:pre` and `:post` for assertion for functions.
we can have them too.
```
func sort(x: int[], comparer: func(int,int -> bool) -> func(int, bool)) 
:pre(x>0)
:post(out != 4)
{ 
    bool b = comparer(10, 20); 
}
```

Y - for immutability we need a notation to indicate a field is immutable.
also functions need to indicate they won't change an input.
what about arrays? an immutable array of int vs an array of immutable ints?
`int f(const int[] array)`
`int f(array<const int> array)`
`int f(const array<int> array)`
or like dlang:
`int f(const int[] arr)`  arr is a const array of normal int
`int f(const(int)[] arr)`  arr is a normal array of const ints
`int f(const const(int)[] arr)` arr is a const array of const ints
obviously, if all fields of a struct are marked as const, you don't need to specify const before typename. 
or we can have `m` alternative for each primitive type: `int` is mutable, `mint` is not.
what about structs?
`func f(x: int, y:int) -> float { ... }`
lets default to mutable data. and define immutables with `&` or `!` or `$`?
`func f(x: &int, y:int) -> &float { ... }`
`func f(x: &int[], y:int[&]) -> &float { ... }`  //x is an immutable array containing imm ints, y is a mutable array containing immutable numbers.
using const keyword is better and more readable.

Y - can a function return multiple values?
in haskel, scala and rust it can. 
`func f(x: int, y:int) -> (float, double) { return (1, 9); }`
`(x,y) = f(1, 20);`
shall we support this?
`auto t = f(1, 10);` if yes, how addressing should be done? `t[0]`? `t._0` like scala, `t.0` like rust?
now that we have structs, why add a tuple data-type? dev can easily define a struct.

Y - how to create a new struct? what about templates?
`struct A { x: int; }`
`var r : A{ x: 10}` or `r : A{ x: 10}`
`var r : Stack<int>{};`

N - but if `struct A {int x;} struct B:A{}` then with access to a variable of type B, we have access to `x` too!
unless we provide access only to fields explicitly defined inside the struct. or:
`struct B { A; }` then we cannot write `B.x`? we should be able to do that.
so, we have access to the whole hierarchy but calling a function is dispatched based on the real type of variable.

N - function redirection
`func f(x: int, y:int) -> other_g(x,y);`
`func f -> other_g;`

Y - if function has one statement, we can remove {} and return.
`func f(x: int, y:int) -> x/y;`

N - call by value of ref? 
when data is immutable, it doesn't matter. 
`func f(x: &int, y:int) -> &float { ... }`
x cannot be changed.
but y can be. so, is it passed by value or reference?
we can use `int` for passing by value. `&int` for pass by reference (int pointer).
and `%int` for passing by reference but immutable. 
but adding `%` everywhere we work with struct is difficult.
let's default to pass by reference. so `int` means pass by reference and mutable.
`&int` means pass by reference and immutable.
`%int` means pass by value. `%A` means value of struct is passed by value.
what about passing structs by reference and primitives by value?
so for values, it is immutable or at least doesn't matter.
but in functional, we put more importance on the data. so we should be capable to support different options and features about them.
`int[] arr`
`const int[] arr`
`int[const] arr`
`const int[const] arr`
lets keep immutable and remove notation of pass by value.
eveything is passed by reference. if you want to preserve func change it's value use immutability features.

N - can we use function output like a value in an expression?
`effective_start(contract).plus_time_interval('3d');`
No. We don't have dot notation for call a function

N - what about putting function name first?
`f: func(x: int, y:int) -> float { ... }`
its not beautiful and its confusing.

Y - pass by reference or value. 
if it is const -> it doesn't matter. if argument is mutable?
lets give dev option to control this. by default data is passed by reference.
`func f(x:int) -> float {}`
shall we introduce `new` and heap/stack allocation? No. don't make everything more complex.
everything is passed by reference even primitives. If you want to prevent other func change value,
either make sure arg is const or send a copy.

Y - what should be behavior of `=`?
`x=y`
= does ref assignment. x=x+1;
`x=1;y=x;y++` makes x 2.

Y - operator to make a copy?
`x=y`
`x=$y;`

Y - what if x is const and I pass it to `func f(x: int) -> int {}`
this should not compile. you can only have `x:int` as input if you really want to change x.
if you don't want: `x: const int`
then user can pass int or const int.

Y - what about enums?

Y - shall we combine struct and type?

Y - do we need alias for import?
no we don't need it.

Y - a better syntax to clone. how to handle =?
`x=$y` to clone.`=` does ref assignment.

Y - can we replace auto with var?

N - do we still need all undefined/defined and & operators?

Y - review special syntax section

Y - how can we know if a struct is immutable?
if all of it's members are const.

Y - how to have defer with a function that returns multiple items?
dont provide defer for output

N - what about operators?

Y - shall we make `()` optional? what about comma?
like perl, can we declare paren optionsl? or even comma?
`new_array = map({$$+1}, my_array);`
vs.
`new_array = map {$$+1}, my_array;`
vs.
`new_array = map {$$+1} my_array;`
will this decrease readability?

Y - pre and post

\* - how to define primitives?
`type int := struct(4);`

Y - what does it mean if a field of struct starts with _?
can this apply to anon-fields?
```
type x := struct {
    a: int;
    b: int;
    a:: A;  //this will be promoted
    _b:: const B #json{ignore};  //this will not be promoted
};
```
if it starts with `_` it is not promoted, but still castable to that type.
we can say, any struct type which is defined inside a struct, means inheritance, so they can be cast. 
what about promotion? if it doesn't have a name, it will be promoted.
no. this can have un-wanted side-effects. we have to explicitly specify parent structs.

Y - Let's remove fields redirection. and function redirection.

N - can we define `if` as a function?
`if(condition) {block}`
condition is input, block is another input. 

N - do we need aspects? 
how can we model `around` aspect?
we need to have functions that accept other functions which are of any type.
this can be modelled by a general-purpose function type. which does not accept anything and output is same as function output.
`type ptr<T> := func () -> T;`
applications of aop: logging, validation, caching, permission check, transaction, monitoring, timing, error handling, 
except for caching all others can be done via before and after.
maybe we can add checked types: `type XX := int {>0};`
and then: `func f(x: XX)`
enum is a special kind of checked-type.
can we define a checked type based on a struct? we should be.

N - removed features: field and fn redirection, optional comma in fn call, function chaining.

Y - can we typedef a function type? yes. and use it as type of input/output of another function.

N - exception handling is like a complex goto. shall we keep it?
https://news.ycombinator.com/item?id=2599012
https://www.quora.com/Why-do-some-people-recommend-not-using-exception-handling-in-C++
https://blog.jooq.org/2013/04/28/rare-uses-of-a-controlflowexception/
http://c2.com/cgi/wiki?DontUseExceptionsForFlowControl
Later. No. Exceptions are necessary sometimes.
we will keep defer (as catch and finally) and assert (as throw).

N - what about throw and defer? assert?

N - Let's generalize what we have in enum and introduce checked types.
`type XX := int {>0};`
`func f(x: XX)` means x must be a positive integer.
checked types advantage: provide enum feature, const?, pre-condition and post-condition.

N - can we use fn redirection + some code instead of decorator and tuple?
```
func f(x:int) -> int :: 
```
i/o of f is determined by function it is redirected to.
no. it is confusing.

N - decorators: in order to have a general wrapper function like python, we can assume function input to be a tuple and output be a tuple too. so: `func f1(x: int, y:int) -> int `
`func g(f: func(T...) -> T...) -> func(T...) -> T... { return func { var x = f(a); log(x); return x; } }`
`func new_f = g(f1, 2, 5);`
when we call `new_f` it will wrap around a call to `f1` and log it's output.
we should simplify this syntax. maybe we can define `x: func` to denote that x is a function with some input and outputs.
or maybe we can define a function-call variable type which contains function name and it's inputs.
`func make_bold(f: func) -> func { return "<B>" + f + "/B"; }`
`func g = logger(f1);`
when we call g, it will do logging on f1 result. g has a syntax same as f1.
`type fp<T, U> := func(T) -> U;`
`func make_bold<T, U>(f: fp<T,U>, input: T) -> U { U out = f(input); return "<B>" + out + "/B"; }`
```
@make_bold
func write(x: int) -> string 
{ return "A" + x + "B"; }
```
maybe we can add some language constructs to eliminate tuple and all this confusion.
but if we add tuple, we will have `defer(out)` too. 
adding tuple will complicate everything. input can be a tuple, output too. stack of tuple ...
when we have struct, adding tuple will add to the confusion.
let's use function composition.
`func write(x:int) -> string ...`
`func write_bold(x:int) -> string { return "<b>"+write(x)+"</b>"; }`
what about this?
`func make_bold(f: func) -> U { U out = f(input); return "<B>" + out + "/B"; }`

N - decorators for contracts
maybe we can achieve this with function composition + lambda.
```
func pre_check<T, U>(f: fp<T,U>, input: T, lambda: func) -> U 
{ assert lambda; U out = f(input); return "<B>" + out + "/B"; }

@pre_check {x>0}
func write(x: int) -> string 
{ return "A" + x + "B"; }
```
NO. we cannot have decorator and tuple without making language much more complicated. let's just use assert.

N - Add tuple type. So functions will be always returning one thing. and we can have decorators.

N - a simpler syntax to define functions
`func write(x: int) -> string  {...}`
`func write { => prepare => findCustomer; }` input is fed into prepare and output of findCustomer is output of function.
this definition is cryptic and hard to read. I have to find findCustomer to see output of the function.
`func write(x: int) -> string  {...}`

Y - chain functions
`evens(data) => sort(3, 4, $_) => save => reverse($_, 5);`
or if methods have only one input:
`evens(data) => sort => save => reverse;`
`5 => add2 => print;`
`(1,2) => mul => print;`?

Y - in composing if parent has no field, we can use `:: X` to ignore a field name.

N - tidy notations
`$$` single input in lambda
`$_` function chaining
`@` casting
`#` annotation
`~` clone

\* - If we have a Car -> Toyota and Color -> Red relationship and we have:
`func f(c: Car, r: Red) ...`
`func f(t: Toyota, c: Color) ...`
and user calls `f(myCar, myColor)` where myCar is of type Car, holding a Toyota and myColor is of type Color holding a Red, which method will be called?
compiler should throw error. Because there is no `f(Car, Color)` if there is, at runtime it will be called.

Y - What if I import two modules and both of them have type `A`? 
What if I import two modules and both of them have function with same name, one acting on A one on B which inherits A?
`import core.std; import data.big;`  -> both have `struct T`
I can use `core.std.T` and `data.big.T` but if name is too long, I will need an alias in import.
`import core.std => ss;` -> ss.T
`import core.std;` -> T
what about functions? if I call `core.std.prepare_t` function by: `prepare_t(t1)` and `data.big` has `prepare_t` function acting on a specialized type?
for function we should not have this problem because even if they have same name, their signature is different. 
but for struct, we can use type alias: `type x := core.std.x;`

Y - Don't promote. If type is casted, they already have whay they want. If it's not casted, use `a.b` notation.

Y - Like python, a function which is executed when module is imported.
