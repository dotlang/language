## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Simple**: Easy to learn, read, write and understand. Consistent and logical, as much as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable developers to develop, maintain and operate large and complex software projects, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer a set of pre-defined rules over keywords in the language.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptios and best practices)
2. A JIT interpreter/compiler
2. Debugger tools (for future)
3. Package manager (for future, used to create, install and deploy packages, something like CPAN, PyPi + their client-side tools)

Why not compile to native code using an ahead-of-time compiler? Because with the ever increasing scope of open source software and Software as a Service revolution, almost always you either use an open source library/framework or use a web-based service. Two main benefits of native code compiler are:

1. Hide some advanced algorithm or intellectual property
2. Performance

As I said, the benefits of the first one are more and more diminishing in the current IT world. For the second part, a JIT compiler can be at par with an ahead-of-time compiler (if not better). Other than that, the JIT compilation provides more flexibility and better optimization techniques.

Of course the disadvantage of this approach is that the user of your software needs the the JIT compiler in addition to the source code. For the source code, we can make the process as straightforward as possible, using packaging techniques.

###Paradigm

Electron is a declarative, object-oriented programming language with GC memory. 
The target of this programming language is distributed server-side network software which normally handle a lot of remote clients.

###Keywords

1. **Conditional**: `if`, `else`, `switch`, `case`, `default`
2. **Loop**: `for`, `while`, `break`, `continue`
2. **Control**: `return`, `defer`, `throw`, `promise`
3. **Type handling**: `void`, `const`, `auto`, `null`, `this`
4. **Other**: `error`

Usage of these keywords is almost same as C++ or Java, so I omit explanation of them in detail.

### Primitive data types

- **Integer data types**: int8 (char), int16, int32 (int), int64, uint8 (byte), uint16, uint32, uint64
- **Floating point data types**: float32 (float), float64 (double)
- **Others**: bool

### Operators

The operators are almost similar to C language:

- Conditional: `and or ! == != >= <=`
- Bitwise: `& | ^ ~ << >>`
- Math `\+ \- \* % ++ -- ** `
- Other `{} =~`

### Data passing

Primitives are passed by value. Everything else (array, string, classes, ...) will be passed by reference.

Although `string` is not primitive, but all string literals will be handled by the compiler behind the scene.

### General structure

Code is organized into packages. Each package is represented by a directory in the file-system. Packages have a hierarchical structure:

core  
|-----math  
|-----io  
|-----sys  
|-----net  
|-----|-----http  
|-----|-----tcp  
|-----|-----socket  

In the above examples `core.math, core.io, core.sys, core.net, core.net.http, core.net.tcp, core.net.socket` are all packages. Each package can have a number of source code files. Each source code file represents one class. Because some OSs have case insensitive naming for file/directory, it is suggested that name of packages and source code files be all lower case. You can separate parts of a name using underscore (e.g. `data_structures`).

Syntax for definition of fields and methods is very similar to other OOP languages like C# or Java.

###Most basic application

Here's what an almost empty application looks like:

file: `simple.e`
```
int main()
{
    return 0; 
}
```

This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except no input it sent to the `main` function).

###Classes

Each source code file represents a class which can be a simple class (like a normal class in other OOP languages) or an interface (same as interface in other languages). 

If class has no fields or constructor, and none of the methods have a body, then it's an `interface`, else it is a normal class. In a normal class, all methods must have bodies. 

Normal classes can be referenced using instance notation (`var_name.memberName`) or static notation (`class_name.memberName`), which will refer to the special instance of the class (static instance). The static instance of class will be initialized upon first reference (static means state-less so it does not need any initialization code upon creation).

Notes:
- It is invalid for a class to have bodies only for some of methods. Either all of methods should have bodies or none of them should have (no abstract class).
- There is no inheritance. Composition is encouraged instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is considered public.
- You can prevent usage of a class as a non-static class by defining normal constructor as private.

###Class members

- Class members starting with underscore are considered private and can only be accessed by other class members.
- Some basic methods are provided by default for all classes: `toString`, `getHashCode`. You can override the default implementation, simply by adding these methods to your class.
- You can define default values for method parameters (e.g. `int func1(int x, int y=0)`).
- You can overload functions based on their input/output.
- Constructor is a special method named `new` with implicit return type (e.g. `new() { return {}; }`). The `{}` allocates a new instance of the current class in memory. 
- Compiler will add an empty normal constructor to the class if it doesn't have any.
- The syntax to initialize variables is like C++ uniform initialization (e.g. `class1 c = class1 {10, 4};` or `interface1 intr = class1 {3, 5}` or `class1 c = {3}`).
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`). In statis class, you have to refer to them using `class_name.memberName` notation.

###Compiler directives and annotation

You can add compiler directives to the code. These are like Java's annotations or C# attributes. They all start with at sign (`@`). Below is a list of them:

- `@assert`: Insert runtime assertations (pre/post-requisite for a method) defined before function definition (e.g. `@assert(x>0) int func1(int x) { ... }@assert($!=0)`).
- `@import`: Include another package (e.g. `@import(core.data)` to include all classes inside a package (not it's sub-packages), `@import(core.data -> .)` to import classes inside `core.data` without need to use prefix, so `core.data.stack` will become `stack`), `@import(core.data -> cd)` same as previous example but `core.data.stack` becomes `cd.stack`.
- `@basedOn`: Indicate this class implements methods of another interface or this interface includes another interface.
- `@annotate` (or `@@`): Apply a custom annotation (e.g. `@@class1 {1, 2, 3}`).
- `@expose`: Delegate some method calls to a class member. This can be done for all public methods of the class member (`@expose`), some of them (`@expose(method1, method2)`) or all except some (`@expose(!method1, !method2)`).
- `@template` and `@enum`: Explained in the corresponding section.
- `@deprecated`

###Templates

You can use compiler directive `@template` to indicate current class/method is a generic one. You can define arguments of the template like `@template(T)` and use `T` inside the body of the class or method. Value for `T` must be a type-name. The template directive can be attached to the whole file or a single method.

To use a generic class you use this syntax: `class1<int> c = class1<int> {}`. When you instantiate a generic class, compiler will re-write it's body using provided data, then compile your code. Example:

```
template(T)

T x;
```

You can also define template based methods (but not template based fields):

```
@template(T)
int add(T x, T y) { ... }


//calling add method
int result = obj1.add<int>(1, 2);
```

You can use `@template` when defining interface members but you cannot specify default parameter values in an interface definition. 

```
//interface1.e
@template(T)
int adder(T a, T b);
```

To escape from all the complexities of generics in other languages, we have no other notation to limit template type or variable template types.

###Exception handling

- You can use `throw` keywords to throw an exception object and exit current method: `throw {1, 2}`
- You can catch thrown exception in your code using `if` command and `error` global variable: `int y = func1(); if ( error ) ...`. You can silence an error by writing `error = null`.
- You can use `defer` keyword (same as what golang has) to define code that must be executed even in case of exception.

###Anonymous class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface. If the interface has only one method, the definition can be in short form.

```
//short form, when interface has only one method
interface1 intr = (x, y) -> x+y;
interface2 intr2 = x -> x+1;  //you can omit parantheses if you have only one variable
interface3 intr3 = this.method1; //if method1 confirms to interface3, you can use it as the value

//long form
interface1 intr = interface1 
{
    int function1(int x,int y) 
    {
        return x+y;
    }
};
```

You can use a similar syntax when defining methods:

```
int func1(int x, int y) -> x+y;
```

###Enum type

Enum data type is a special kind of class with a set of possible values. Each possible value is tagged with `@enum` directive. Any variable of type of that class can only have one of those tagged values.

Example:
```
//day_of_week.e file

@enum
const int SAT = 0;

@enum
const int SUN = 1;

//...

//main.e file
day_of_week dow = day_of_week.SAT;

```

###Misc

- **Naming**: Suggestion: camelCasing for methods, fields and variables, lower_case_with_underscore for package and class names, UPPERCASE for `@enum` names and template arguments.
- **Operator overloading**: A class can overload `[]` and `==` operators for it's instances by having methods called `setData`, `getData` and `equals`.
- **Checking for implements**: You can use `(interface1)class1` to check if `class1` implements `interface1`.
- **const**: You can define class fields, function arguments, local variables and function output as constant. You can only delay value assignment for a const variable if it is non-primitive. If value of a const variable is compile time calculatable, it will be used, else it will be an immutable type definition.
- **Literals**: `0xffe`, `0b0101110101`, `true`, `false`.
- **Digit separators**: `1_000_000`.
- **For**: You can use `for` to iterate over an array `for(x:array1)` or repeat something `n` times `for(n)`.
- - **Suffixed if and for**: `return 1 if x>1;`, `x++ for(10)`, `x += y for (y: array)`.
- **Arrays**: Same notation as Java `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]`.
- **Special variables**: `$` refers to the result of last function call (used in post-condition assertion).
- **String interpolation**: You can embed variables inside a string to be automatically converted to string.
- **Ternary condition**: if/else as an expression `b if a else c` is same as `a ? b:c` in other languages.
- **Hashtable**: `int[string] h = { "OH":12, "CA":33 }; h["NY"] = 9;`

###Core package

A set of core packages will be included in the language which provide basic and low-level functionality (This part may be written in C):

- Calling C/C++ methods
- Reflection and extracting annotations
- Data conversion
- Garbage collector
- Exception class

###Standard package

There will be another set of packages built on top of core which provide common utilities. This will be much larger and more complex than core, so it will be independent of the core and language (This part will be written in Electron). Here is a list of some of classes in this package collection:

- I/O (Network, Console, File, ...)
- Thread and synchronization management
- Serialization/Deserialization
- Functional programming: map/reduce/filter
- String and Regex
- Collections (Stack, Queue, Linked List, ...)
- Encryption
- Math
- ...

#Package Manager

The package manager is a separate utility which helps you package, publish, install and deploy packages (Like `maven` or `dub`).

#Decision points

N - should we have something like `Object` in Java or `void*` in C++? So that we can implement a `printf` method. Maybe we can somehow mis-use `auto` keywords for this. `int func(auto x, auto y)`. We can easily implement printf with string interpolation.

Y - Support for concurrency built into the language
```
promise& class1.func1();  //run the statement in another co-routine at the moment
future<string> f1 = promise class1.func1(1, 2, 3);  //wait for call of invoke
future<string> f2 = promise { return "a"; };
f1.invoke();
f1.setCallback(...);
f1.cancel();
string result = f1.get();
```

Y - ternary operator is very messy but very useful (`a ? b:c`). Is there a way to make use of it in the language? Maybe:
`if a then b else c` or `b if a else c`. We only want to evaluate `c` if `b` is `FALSE` so this cannot be done with a library function. 

N - Support for atomic operations in language level? This can be achieved using `core` so better not to add a new keyword/compiler feature for this.

N - Operators for regex? find/match/substitute? No. This is possible using core.
    `bool b = str =~ 'pattern'`

N - map/reduce/filter, arri implements a specific interface. will be done in core.
    arr2 = arr1.map<T>(x -> x+1);
    arr2 = arr1.filter(x -> x>0);
    arr2 = arr1.reduce((x,y) -> x+y);

N - serialization/deserialization: Better to be done in core
    `string x = core.ser.serialize<obj>(obj1);`
    `obj r = core.ser.deserialize<obj>(x);`
    
N - join/fork
    fork: using core,
    join: in future class
    
N - compare and swap, only for numbers
    `bool b = (x ? 1 -> 2);`

Y - Hash notation, like array with support for hash literals
    `int[string] hash1 = { "OH":12, "CA":33, ... };`
    behind the scene this will be a class.
