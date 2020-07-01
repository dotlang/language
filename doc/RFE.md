# Requests for Enhancements

X - modules and versioning
we can ask user to pin a specific version in their imports if they want deterministic builds
we need reproducible builds. meaning if I need `v1.5.*` of a dependency, it should compile exactly the same on my machine than any other machine (CI or team mate or ...)
now, this can translate to `1.5.1` or `1.5.2` depending on some factors. so we need to lock that.
one way compatible with current method is to act like this:
```
# autogen(/https/github.com/uber/web/@v1.9+.*/request/parser)
path=""
T = import(path)
```
when compiler compiles above for the first time it writes proper value for path and later will re-use it, until you run `dot update deps`
```
#autogen(/https/github.com/uber/web/@v1.9+.*/request/parser)
path="/https/github.com/uber/web/@v1.9.16/request/parser" 
T = import(path)
```
so this `@1+.*` syntax is only valid in autogen in comments. You cannot actually use it in import path.
If you want to import a module you must either:
1. specify an exact version
2. use autogen as above and let compiler calculate a fixed version.
3. the result will be inserted by the compiler as the value for binding after autogen.
4. the value will remain there until developer does a dep-refresh command to update them.
how can we have multiple modules/packages in one github repo?
These questions are not really needed for initial lang design and compiler impl.

X - Our goal is to minimize number of stuff the developer needs to keep in their head

X - Not only dot is easy for users, it should also be easy for developers.
so they should not need a lot to set up a dev env.

X - Use protothreads for lightweight threads implementation

X - Everything is a file
Use this for stdio, sockets, ... 
inspire from linux Kernel

X - We may need a function in core like `createStream` to create a stream with custom logic.
or to read from file or network

X - For future: support shortcut to define lambda
when function result is an expression and input/output types can be inferred from context:
instead of `fn(x:int, y:int -> int) { x+y }`
write: `x,y -> x+y`
or: `fn(x,y -> x+y)`

X - Core needs to have support for these
- serialisation deserialisation


? - Type classes or some other similar method to have some kind of flexibility in function call dispatch

