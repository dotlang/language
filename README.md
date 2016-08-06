## Electron Programming Language

###Note: This pet project is a work in progress, so expect a lot of changes.

After having worked with a lot of different languages (C#, Java, Perl, Javascript, C, C++, Python, D) and being familiar with some others (including Go, Scala and Rust) it still irritates me that these languages are sometimes seem to _intend_ to be overly complex. This doesn't mean I don't like them or I cannot develop software using them, but it also doesn't mean I should not be looking for a programming language which is both simple and powerful.

That's why I am creating the new programming language: Electron. 

I will follow 3 rules when designing this language:

1. **Simple**: Easy to learn, read, write and understand. Consistent and logical, as much as possible. Software development is complex enough. Let's keep the language as simple as possible and save complexities for when we really need them.
2. **Powerful**: It should enable developers to organize, develop, test, maintain and operate a large and complex software project, with relative ease.
3. **Fast**: Performance of the final output should be high. Much better than dynamic languages like Python. Something like Java.

I know that achieving all of above goals at the same time is something impossible so there will definitely be trade-offs where I will let go of some features to have other (more desirable) features. I will remove some features or limit some features in the language where I think it will help achieve above goals. One important guideline I use is "convention over configuration" which basically means, I will prefer using a set of pre-defined rules over keywords in the language.

This project will finally consist of these components:

1. A specification of the language (Formal specification + Examples, descriptions and best practices)
2. A JIT interpreter/compiler
2. Debugger tools
3. Package manager (Used to build, create, install and deploy packages, something like CPAN, PyPi + their client-side tools)

Why not compile to native code using an ahead-of-time compiler? Because with the ever increasing range of open source software and Software as a Service revolution, almost always you either use an open source library/framework or use a web-based service. Two main benefits of AOT compiler are:

1. Hide some advanced algorithm or intellectual property
2. Performance

As I said, the benefits of the first one are more and more diminishing in the current IT world. For the second part, a JIT compiler can be at par with an ahead-of-time compiler (if not better). Moreover, the JIT compilation provides more flexibility and better optimization possibilities.

Of course the disadvantage of this approach is that the user of your software needs the the JIT compiler in addition to the source code. For the source code, we need to make this process as straightforward as possible.

###Paradigm

Electron is a object-oriented and imperative  programming language with garbage collection memory management. 
The target use case of this programming language is distributed server-side network software.

###Keywords

1. **Conditional**: `if`, `else`, `switch`, `assert`
2. **Loop**: `for`, `break`, `continue`
2. **Control**: `return`, `defer`, `throw`
3. **Type handling**: `void`, `const`, `auto`, `null`
4. **Other**: `error`, `this`, `import`, `struct`, `extends`

Usage of these keywords is almost same as C++ or Java, so I omit explanation for most of them in detail.

### Primitive data types

- **Integer data types**: `int8` (`char`), `int16`, `int32` (`int`), `int64`, `uint8` (`byte`), `uint16`, `uint32`, `uint64`
- **Floating point data types**: `float32` (`float`), `float64`
- **Others**: `bool`

### Operators

The operators are almost similar to C language:

- Conditional: `and or not == != >= <= ??`
- Bitwise `& | ^ << >> ~`
- Math `+ - * % ++ -- **`
- Other `{}`

### Data passing

Primitives are passed by value. Everything else (array, string, classes, ...) will be passed by reference.

Although `String` is not primitive, but all string literals will be handled by the compiler behind the scene.

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

In the above examples `core.math, core.io, core.sys, core.net, core.net.http, core.net.tcp, core.net.socket` are all packages. Each package can have a number of source code files. Each source code file represents one definition. 

Syntax for definition of fields and methods is very similar to other OOP languages like C# or Java.

###Most basic application

Here's what an almost empty application looks like:

file: `Simple.e`
```
int main()
{
    return 0; 
}
```

This is a class with only one method, called `main` which returns `0` (very similar to C/C++ except no input it sent to the `main` function).

###Classes

Each source code file represents either an interface or class. What separates these two is that, an interface has no fieds, and all method are without body. Everything else is considered a class. 

Each class's instances can be referenced using instance notation (`varName.memberName`), or you can use static notation (`ClassName.memberName`) which will refer to the special instance of the class (static instance). There is an static instance for every class which will be initialized upon first reference (static means state-less so it does not need any initialization code upon creation). You can use class name to refer to it's statis instance: `auto x = MyClass`.

*Notes:*
- Note that you cannot have bodies only for some of the class methods (no abstract class).
- There is no inheritance. Composition is encouraged instead.
- If a class name (name of the file containing the class body) starts with underscore, means that it is private (only accessible by other classes in the same package). If not, it is public.
- The order of the contents of source code file matters: First `import` section, then compiler directives, struct section and methods. 

###Class members

- Class members starting with underscore are considered private and can only be accessed by other class members.
- Some basic methods are provided by default for all classes: `toString`, `getHashCode`. You can override the default implementation, simply by adding these methods to your class.
- You can define default values for method parameters (e.g. `int func1(int x, int y=0)`).
- You can overload functions based on their input/output.
- There is no specific constructor. If class wants, it can define methods to create instance of it and other can use the static instance of the class to invoke that method. The `{}` allocates a new instance of the current class in memory:
```
//MyClass.e
MyClass new() { return {}; }

//main.e
MyClass x = MYClass.new();
```
- The syntax to initialize variables is like C++ uniform initialization (e.g. `Class1 c = Class1 {10, 4};` or `Interface1 intr = Class1 {3, 5}` or `Class1 c = {3}`).
- When accessing local class fields and methods in a simple class, using `this` is mandatory (e.g. `this.x = 12` instead of `x = 12`).

###Templates

You can define template arguments and their default values using comment in the beginning of the file. 

```
//tuple.e
//<T, TNAME, R, RNAME>
//<R>
template {
    type T;
    token TNAME;
    type R;
    token RNAME;
}

T TNAME;
R RNAME;

//main.e code
tuple<int, 'age', String, 'name'> student;
```

To escape from all the complexities of generics in other languages, we have no other notation to limit template type or variable template types.

###Exception handling

- In case of exception: `throw {'something wrong happened'};`. This will initialize `Error` class (defined in core) and return immediately from the function (Returning default value for method output type).
- You can catch errors using `if` statement: `if (Error.isSet()) ... `.
- You can silence an error using: `Error.reset()`.
- You can use `defer` keyword (same as what golang has) to define code that must be executed upon exitting current method.

###Anonymous function/class

You can define anonymous classes which can act like a function pointer. Each anonymous class must have a parent interface. If the interface has only one method, the definition can be in short form. 
Note that both short and long form, the code only has read-only access to variables in the parent method. No access is given to the parent class. 

```
//short form, when interface has only one method
Interface1 intr = (x, y) -> x+y;  //specifying type for input is not needed
Intr6 intr5 = () -> 5; //no input
Interface2 intr2 = x -> x+1;  //you can omit parantheses if you have only one variable
Interface1 intr = (x, y) -> { 
    method1();
    method2(x,y);
};

Intr5 pa = this.method1; //compiler handles change in the name

//long form
Interface1 intr = Interface1 
{
    int function1(int x,int y) 
    {
        return x+y;
    }
    
    int functio2(int x)
    {
        return x+1;
    }
};
```

You can use a similar syntax when defining methods which have only return statement:

```
int func1(int x, int y) -> x+y;
int func1(int y) -> this.member1.func1(y); //delegate calls 
```

*Closure*: All anonymous function and classes, have a `this` which will point to a read-only set of local variables in the enclosing method (including input arguments).

###Extended primitives and Enum type

You can define classes which are based on primitives. These classes will be just like that primitive data type + some extra methods that you have defined. Note that you cannot add non-const fields to these classes, because their base type is a primitive. These classes are called extended primitives.

Enum data type is an extended primitive type with a set of possible values. Each const definition of the based primitive type with capital letters is one of those possible values. Any variable of type of that class can only have one of those tagged values. 

Example:
```
//DayOfWeek.e file

//no methods, all data fields are const of primitive with literal values
struct
{
    const int SAT = 0;
    const int SUN = 1;
}

//...

//main.e file
DayOfWeek dow = DayOfWeek.SAT;

```

An instance of an extended primitive which is not enum, can be treated just like a primitive. So you can pass them instead of primitives in your code or pass a primitive instead of an extended primitive.

###Misc

- **Naming rules**: `camelCasing` for methods, fields and variables, `lower_case_with_underscore` for packages, `UpperCamelCase` for classese, `UPPERCASE` for enumerated names and template parameters.
- **Checking for implements**: You can use `(Interface1)class1` to check if `class1` variable implements `Interface1`.
- **const**: You can define class fields, local variables and function output as constant. You can only delay value assignment for a const variable if it is non-primitive. If value of a const variable is compile time calculatable, it will be used, else it will be an immutable type definition.
- **Literals**: `0xffe`, `0b0101110101`, `true`, `false`.
- **Digit separators**: `1_000_000`.
- **For**: You can use `for` to iterate over an array `for(x:array1)`.
- **Suffixed if and for**: `return 1 if x>1;`, `x += y for (y: array)`.
- **Arrays**: Same notation as Java `int[] x = {1, 2, 3}; int[3] y; y[0] = 11; int[n] t; int[] u; u = int[5]`.
- **Special variables**: `$` refers to the result of last function call (used in post-condition assertion).
- **String interpolation**: You can embed variables inside a string to be automatically converted to string. If string is surrounded by double quote it won't be interpolated. You need to use single quote for interpolation to work.
- **Ternary condition**: if/else as an expression `iif(a, b, c)` is same as `a ? b:c` in other languages.
- **Hashtable**: Same as enhancement proposal.
- **Const args**: All function inputs are `const`. So function cannot modify any of it's inputs' values.
- **import**: Include other packages:
```
import
{
    core.math,   //default import, core.math.c1 becomes core.math.c1
    core.math => mt,  //import with alias, core.math.c1 becomes mt.c1
    core.math => _,  //import into current namespace, core.math.c1 becomes c1
}
```
- **assert**: You can use this to check for pre-condition and with `defer` it can be used to check for post-condition. `assert x>0 : 'error message'` or to throw exception: `assert x>0 : {'error message'};`.
- **Documentation**: Any comment before method or field or first line of the file starting with `///` is special comment to be processed by IDEs and automated tools. 
- **Delegation**: `* -> this.memberName` will convert all method calls like X to `this.memberName.X` if member has X.
- **Extension**: `extends ABCD;` means current interface is based upon ABCD interface.
- **Call by name**: `myClass.myMember(x: 10, y: 12);`


###Core package

A set of core packages will be included in the language which provide basic and low-level functionality (This part may be written in C):

- Calling C/C++ methods
- Reflection
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
- Bitwise operators (and, or, shift, xor, ...)
- ...

#Package Manager

The package manager is a separate utility which helps you package, publish, install and deploy packages (Like `maven` or `dub`).
Suppose someone downloads the source code for a project written in Electron which has some dependencies. How is he going to compile/run the project? There should be an easy and transparent for fetching dependencies at runtime and defining them at the time of development.
