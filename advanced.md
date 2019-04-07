# Generics

1. There is a special data type called `type`. Bindings of this value (which should be named like a type), can have any possible "type" as their value.
2. Every binding of type `type` must have compile time literal value.
3. Generic types are defined using module-level functions that accept `type` arguments and return a `type`. 
4. These functions must be compile time (because anything related to `type` must be) (Example 1). 
5. This means that you cannot use a runtime dynamic binding value as a type.
6. You also cannot assign a function that receives or return a type to a function-level lambda.
7. Note that a generic function's input of form `T|U` means caller can provide a union binding which has at least two options for the type, it may have 2 or more allowed types.
8. If a generic type is omitted in a function call (and it is at the end of argument list), compiler will infer it (Example 6). 
9. Generic functions are implemented as functions that accept `type` arguments but their output is not `type`.

**Examples**

1. 
```rust
LinkedList = fn(T: type -> type)
{
	Node = struct (
		data: T,
		next: Node|nothing
	)
	Node|nothing
}
```
2. `process = fn(x: LinkedList(int) -> int)`
3. `process = fn(T: type, ll: LinkedList(T) -> ...`
4. 
```
process = (T: type, data: List(T) -> float) ...
pointer = process(int, _) #valid, type of pointer is fn(int, List(int)->float)
```
5. `process = fn(T: type, x: [T], index: int -> T) { x[index] }`
6. 
`push = fn(data: T, stack: Stack(T), T: type -> Stack(T)) {...}`
`resutl = push(int_var, int_stack)`

# Modules

1. Modules are source code files. 
2. You can import a module into current module and use their declarations. 
3. You can import modules from local file-system, GitHub or any other external source which the compiler supports.
4. If import path starts with `.` or `..` it is a relative path (Example 2), if it start with `/` it is based on project's root (Example 1).
5. Project root is where the compiler is executed.
6. If the specific absolute module path does not exist, compiler will look into parent modules (if any). If still not found, compiler will try to download it from web. Compiler will support specifying specific branch/release/commit when importing a module. Compiler will keep track of current module root and all parent module roots. If a dependency is not found in any of parent roots, it will be downloaded into top most module root (If it is a zip file, it will be decompressed).
7. The result of importing a module is called a module alias which if named, should be named like a binding and used with `..` notation to access definitons inside module. 
8. You can also ignore output of an import to have its definitions inside current namespace. 
9. You can also use `..{}` notation to only access some of module's symbols (Examples 9 and 10).
10. Absolute paths that start with http or https will be downloaded from the net if not available locally.
11. You can import at module level only.
12. You can use `@` notation to indicate required tag or branch name. This part allows using `+` and `*` to indicate versions equal or higher to x or any version are acceptable (Example 8).

**Syntax**

`ModuleName = import("/path/to/module")`

**Examples**

1. `Socket = import("/core/st/socket")`
2. `Socket = import("../core/st/socket")`
3. `Module = import("/http/github.com/net/server/branch1/dir1/dir2/module") #you need to specify branch/tag/commit name here`
4. `base_cassandra = "/http/github/apache/cassandra/mybranch"`
5. `Module = import(base_cassandra + "/path/module") #you can create string literals for import path`
6.
```
Set = import("/core/set")..SetType
process = fn(x: Set -> int) { ... }
```
7. `my_customer = import("/data/customer")..Customer(name:"mahdi", id:112)`
8.
`T = import("/https/github.com/uber/web/@v1.9+.*/request/parser")`
`T = import("/https/github.com/uber/web/@new_branch/request/parser")`
`T = import("/https/server.com/web/@v1.9+.*.zip/request/parser")`
9. `Set, process, my_data = import("/core/set")..{SetType, processFunc, my_data}`
10. `Set, process, my_data = imported_module..{SetType, processFunc, my_data}`

# Concurrency

1. We have `:=` for parallel execution of an expression. 
2. Using `x := y` will initiate a new task as a child of the current task. Any access to the output of `:=` (`x`) will block current process until the child is finished.
3. Each task has an unbounded mailbox which can accept messages from any other task. 
4. Sending to an invalid task will return immediately with a false result indicating send has failed. 
5. Receive with an empty inbox, will block the current process. You can use built-in functions to access current task's functionality (pick a message from mailbox, send a message to another task, ...).

**Examples**

1. `msg = receive(Message)`
2.
```rust
int_result := process(10)
task_id = getCurrentTaskChildren().last()
is_accepted = sendMessage(my_message, task_id)
is_picked_up = sendAndWait(my_message, task_id)
```
