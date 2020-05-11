# Generics

1. There is a special data type called `type`. Bindings of this value (which should be named like a type), can have any possible "type" as their value.
2. Every binding of type `type` must have a compile time literal value.
3. Generic types are defined using module-level functions that accept `type` arguments and return a `type`. 
4. These functions must be compile time (because anything related to `type` must be) (Example A). 
5. This means that you cannot use any non-literal value as a value for a type binding.
6. You also cannot assign a function that receives or return a type to a function-level lambda.
7. Note that a generic function's input of form `T|U` means caller can provide a union binding which has at least two options for the type, it may have 2 or more allowed types.
8. If a generic type is omitted in a function call (and it is at the end of argument list), compiler will infer it (Example B). 
9. Generic functions are implemented as functions that accept `type` arguments but their output is not `type` (Example B).

**Examples**

```perl
#A
LinkedList = fn(T: type -> type)
{
    Node = struct (
        data: T,
        next: Node|nothing
    )
    Node|nothing
}

process = fn(x: LinkedList(int) -> int)
process = fn(T: type, ll: LinkedList(T) -> ...

process = (T: type, data: List(T) -> float) ...
#type of pointer is fn(int, List(int)->float)
pointer = process(int, _) 

process = fn(T: type, x: [T], index: int -> T) { x[index] }

#B
push = fn(data: T, stack: Stack(T), T: type -> Stack(T)) {...}
result = push(int_var, int_stack)
```

# Modules

1. Modules are source code files. 
2. You can import a module into current module and use their declarations. This can only be done at module level. 
3. You can import modules from local file-system, GitHub or any other external source which the compiler supports.
4. If import path starts with `.` or `..` it is a relative path (Example A), if it start with `/` it is based on project root (Example B).
5. Project root is where the compiler is executed.
6. If the specific absolute module path does not exist, compiler will look into parent modules (the module that has imported this module). If still not found, compiler will try to download it from web. 
7. Compiler will support specifying specific branch/release/commit when importing a module. 
8. Compiler will keep track of current module root and all parent module roots. 
9. The result of importing a module is called a module alias which if named, should be named like a binding and used with `..` notation to access definitons inside module. 
10. You can ignore output of an import to have its definitions inside current namespace. 
11. You can use `..{}` notation to only access some of module's symbols (Examples C and D).
12. Absolute paths that start with http or https will be downloaded from the net if not available locally.
14. You can use `@` notation to indicate required tag or branch name. This part allows using `+` and `*` to indicate versions equal or higher to x or any version are acceptable (Example E).

**Syntax**

`ModuleName = import("/path/to/module")`

**Examples**

```perl
#A
Socket = import("../core/st/socket")

#B
Socket = import("/core/st/socket")

base_cassandra = "/path/to/cassandra"

#you can use a string literals expression for import path
Module = import(base_cassandra + "/path/module") 

Set = import("/core/set")..SetType
process = fn(x: Set -> int) { ... }

my_customer = import("/data/customer")..Customer(name:"mahdi", id:112)

#E
T = import("/https/github.com/uber/web/@v1.9+.*/request/parser")
T = import("/https/github.com/uber/web/@new_branch/request/parser")
T = import("/https/server.com/web/@v1.9+.*.zip/request/parser")

#C
Set, process, my_data = import("/core/set")..{SetType, processFunc, my_data}

#D
Set, process, my_data = imported_module..{SetType, processFunc, my_data}
```

# Concurrency

1. Using `result := expression` notation will initiate a new parallel task (green thread) as a child of the current task. Any access to the result `result` will block current process until the child is finished.
2. You can call core function to create a channel. Channels can be used for communication and synchronization across tasks.
3. A channel is represented via a generic struct with functions to read/write data (Example A).
4. Other operations like `select` are implemented as functions in std.

**Examples**

```perl
_ := process(10, 20)

channel = createChannel(int, 10)

#pass channel to a task
int_result := process(10, channel)

#write data into the channel (blocks if channel is full)
channel.write(100)

#read data from channel (blocks if there is nothing to read)
data = channel.read()
```

# Errors

1. We have a struct type defined in core called `error` with a binding of the same name representing a null-op error.
2. `error = struct (key: type|nothing, message: string|nothing, location: string|nothing, cause: error|nothing)`
3. At operator is used to check for error and do an early return from current function.
4. At operator is used like `expression@` (return the error itself if expression evaluates to an error) or `expression@{expression}` (return right-hand side expression in case of error in the left-hand side expression)
5. If early return is of type `error` runtime will automatically populate its `cause` with original error.
6. Note that the expression inside `{}` will not be evaluated until the expression before `@` evaluates to an error.

Examples:
```perl

result = process(1,2)@ + process(3,4)@

result = process(1,2)@{nothing} + process(3,4)@{nothing}

data = validateInput(a,b)@{getDefaultReturnValue()}

```



