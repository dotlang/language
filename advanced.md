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

```swift
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
pointer = process(int, _) #valid, type of pointer is fn(int, List(int)->float)

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

```swift
#A
Socket = import("/core/st/socket")
Socket = import("../core/st/socket")

#B
Module = import("/http/github.com/net/server/branch1/dir1/dir2/module") #you need to specify branch/tag/commit name here

base_cassandra = "/http/github/apache/cassandra/mybranch"`

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
2. You can call `createChannel(type, size|nothing)` core function to create a new channel. This can be used for communication and synchronization across tasks.
3. A channel is represented via a function that can be used to read from or write to the channel (Example A).
4. Calling channel function will block current thread if channel is not ready to read/write.
5. You can use `///` operator to do a select among multiple channel operations (Example B). This will pick any of possible channel operations which is ready.
6. Channel functions have an extra runtime argument of type `int|nothing` which is used by runtime.
7. You can wrap a channel function inside another function as long as you preserve the runtime argument.

**Examples**

```swift
_ := process(10, 20)

chFunc = createChannel(int, 10)

#pass channel to a task
int_result := process(10, chFunc)

#write data into the channel (blocks if channel is full)
chFunc(100)

#read data from channel (blocks if there is nothing to read)
data = chFunc()

#A
chFunc: fn(data: string|nothing, extra:int|nothing-> string)

#B
#do any of below operations if the corresponding channel is ready
#result will be the data read/written
#makeTimeout creates a timeout channel which after 100ms, returns nothing and unblocks select operation
#defaultChannel creates an always ready channel so if none of the other operations are ready, it will return 200 as result
result = chFunc1(nothing, _) /// chFunc2(nothing, _) /// chFunc3(data, _) /// makeTimeout(100) /// defaultChannel(200)
```
