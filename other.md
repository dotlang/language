# Modules

Modules are source code files. You can import them into current module and use their declarations. You can import modules from local file-system, GitHub or any other external source which the compiler supports (If import path starts with `.` or `..` it is relative path, if it start with `/` it is based on project's root). If the specific absiolute module path does not exist, compiler will look into parent modules (if any). If still not found, compiler will try to download it from web. Compiler will support specifying specific branch/release/commit when importing a module. Compiler will keep track of current module root and all parent module roots. If a dependency is not found in any of parent roots, it will be downloaded into top most module root (If it is a zip file, it will be decompressed).

The result of importing a module is a module definition which if named, should be named like a binding and used with `..` notation to access definitons inside module. You can also ignore output of an import to have its definitions inside current namespace. You can also use `..{}` notation to only access some of module's symbols (Examples 9 and 10).

Absolute paths that start with http or https will be downloaded from the net if not available locally.

You can import at module level or inside a function. The output of import will be valid only inside its enclosing context.

You can use `@` notation to indicate required tag or branch name. This part allows using `+` and `*` to indicate versions equal or higher to x or any version are acceptable (Example 8).

**Syntax**

`ModuleName = import("/path/to/module")`

**Examples**

1. `Socket = import("/core/st/socket") #import everything, addressed module with absolute path`
2. `Socket = import("../core/st/socket") #import with relative path`
3. `Module = import("/http/github.com/net/server/branch1/dir1/dir2/module") #you need to specify branch/tag/commit name here`
4. `base_cassandra = "/http/github/apache/cassandra/mybranch"`
5. `Module = import(base_cassandra + "/path/module") #you can create string literals for import path`
6.
```
Set = import("/core/set")..SetType
process = fn(x: Set -> int) ...
```
7. `my_customer = import("/data/customer")..Customer(name:"mahdi", id:112)`
8.
`T = import("/https/github.com/uber/web/@v1.9+.*/request/parser")`
`T = import("/https/github.com/uber/web/@new_branch/request/parser")`
`T = import("/https/server.com/web/@v1.9+.*.zip/request/parser")`
9. `Set, process, my_data = import("/core/set")..{SetType, processFunc, my_data}`
10. `Set, process, my_data = imported_module..{SetType, processFunc, my_data}`

# Concurrency

We have `:=` for parallel execution of an expression. This will initiate a new task as a child of the current task. Any access to the output of `:=` will block current task until the child is finished.

Each task has an unbounded mailbox which can accept messages from any other task. Sending to an invalid task will return immediately with a false result indicating send has failed. Receive with an empty inbox, will block the current process. You can use built-in functions to access current task's functionality (pick a message from mailbox, send a message to another task, ...).

**Syntax**

1. Parallel execute `output := expression` 

**Examples**

1. `msg = receive(Message)`
2.
```
int_result := process(10)
task_id = getCurrentTaskChildren().last()
accepted = sendMessage(Message, my_message, task_id)
picked_up = sendAndWait(Message, my_message, task_id)
int_result = resolve(int, task_id) #wait until task is finished and get the result
```

