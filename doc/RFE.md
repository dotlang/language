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



N - We can add a built in function to convert between struct and json.

Y - Builtin support for testing and doc
compiler will drop any unused function in the final output. 
from compiler's perspective, unit tests are a set of functions in the modules of the project that must be executed.
they don't have any input or output.
because there is no one to give them input. compiler cannot provide input.
If a test needs input, you should wrap it into a caller function.
so it will be in the form of: `fn{...}` in the source.
They don't have a name (because no one's gonna call them). no input. no output.
so:
```
_ = fn{ ... }
```
can be a unit test. but we want to make it more explicit.
option1:
`__ = fn{...}`
so:
module level functions that have no name are unit test.
But this is not good. We want them to have names to describe what/how they are testing.
e.g.
`testProcessWithInvalidInput = fn{...}`
so:
module level functions, without input that start with `_test` are considered test functions.
if they are not used anywhere, will be dropped from compiler output.
but you can force compiler to run them: `dotc test myProject`

N - Can we have a pattern that people can easily find functions/types/... in a file
`process = fn(x:int -> string) ...`
`number = 10`
`fn/type/val`
`val x = 10`
`fn process = ...`
no. confusing.

N - Is having optional arg compatible with lambda?
I need a function that has no input. can I pass a function that needs `int|nothing`?
I don't think this should be possible.
But if I have a lambda that needs `int|nothing`, I can call it without args. 

N - Can I treat file/socket/console and all other IOs as channels?
or maybe I can say: everything is a file.

N - We can use closure to provide encapsulation and privacy.
that is what is used in js.

Y - re-org website
part 1 - intro
part 2 - basic: types, functions
part 3 - advanced: generic, modules, concurrency
part 4 - examples

Y - Question: What comes on the right side of `:` when defining a type alias?
can I put a generic function on the right side?
no. type alias is for named types. `identifier : identifier`

N - Should we make `dispose` more built-in?
`dispose(x)`
`x = ` no x is suppose to be immutable.
`_ = x`
`nothing = x`
`x = nothing`
`x = _`
but isn't this against immutability?
what if another thread is using x?
I think you should not be able to dispose anything.
Just some specific functions that can be used to close a file, ...
and they are typed, so you cannot call them with any other type
`x = _`
re-using underscore is not good here.
`x = nothing`
this does not make sense because maybe x is an int, we cannot assign nothing to it.
but we can say this is a special case and syntax sugar. 
what if x is used from another thread/function?
but, we can say any runtime use after `_` will result in runtime error.
Because sometimes you really need to close a resource.
for example a file descriptor, you want to explicitly close it.
for example: I open a socket, read data, process data (takes time) and then I want to close the socket.
now, I don't want to finish everything, then close the socket.
but we can simply enclose this logic in a function: open socket, read data, close socket
and call above, then use its output for processing.
let's for now forget this. no dispose. no free. automatic dispose/close.

Y - if I have a sequence of `fn(->int|float)` can I put a function that returns int, in that sequence?
I should be able to do that.
`x: fn(->int|string) = fn(->int) {...}`
So when I have `fn(T->U)` any function that can accept T (or more) is all right.
any function that returns U (or less) is all right. 
it is not all right if function does not accept part of T, or can return more than U.

Y - If underscore has no meaning, why not ban it?
so underscore will be for destruction and lambda creation only.
so putting `_` at the beginning of a binding/type name can have a special meaning? or it can be banned.

Y - The concept of process mailbox means a lot of stuff in the background.
replaces it with something like a channel object which we can send to or receive from functions
but what about `select`?
notations we need:
1. define a channel with no or some buffer: 
  `ch = 0`, `ch = [0,0,0]`
  `ch_r, ch_w = makeChannel(0) #or 1 or n`
2. read from channel: `ch_r(timeout_ms)`
3. write to channel `ch_w(data, timeout_ms)`
4. close channel: call `dispose`
5. select: idea: don't do it yourself, give developer primitives and let him (or std) handle that
if we make read, tryRead, and write, tryWrite, then what?
so, tryRead will reutrn nothing if cannot read. or the data read
tryWrite will return nothing if cannot write. or the data written
then user can use these to write their own select. or, we can provide a helper too.
this will also enable us to write our own default case: a function that always does the job.
what if we cannot close a channel? you can signal (using another channel) that this channel is no longer valid.
and stop reading from the channel.
we want to make it simple and minimal.
`ch_r, ch_w = makeChannel(size, identifier)`
Pro for fn for channels: we can compose them easily
the reader function can be called with a timeout which when `nothing` means just peek.
`ch_r: (timeout: int|nothing -> string|nothing)` or maybe int timeout which when 0 means peek
In this way, select can be implemented via the developer.
All functions have similar signature: readers: `(timeout: int -> T|nothing)`
writers: `(data: T, timeout: int -> T|nothing)`
close channel: this is a write nature operation, so we should have access to write function.
writing nothing means close.
q: How to create a channel with 0 or more buffers?
we want to avoid magic functions.
`ch_r, ch_w = [0]` int channel with buffer of 1 cells
No. 
another option: We have a `Channel` struct type that when you create, a new channel will be created for you.
but this means a lot of stuff in the background:
`chr_, ch_w = Channel(int)(size:0)`
so, essentially, we not only create the struct, we also create a channel in the background, which is bad because it is hidden.
why not use core functions? we will need functions for file, net, IO, ...
`ch_r, ch_w = createChannel(int, 10)`
can we only have channels with 0 size and build buffered channels using them?
can we say, buffered channel of size 10 is 10 unbuffered channels?
I think we can do this. For a channel with buffer size b we need b+1 unbuffered channels.
b channels for the data and the last channel to keep track of two pointers (read/write).
With every call to read/write, we update the b+1th channel with new indices.
We just need to make sure, calls to read and write function are synced.
This b+1th channel can also be used to sync read and writes.
Because when I read its contents, another function wanting to read will have to wait, until I'm done and have written updated values.
now, assuming we only have unbuffered channels: `ch_r, ch_w = createChannel(int)`?
If unbuffered channel blocks on write, we cannot do this.
rather than that we need buffered channels of size 1.
Then, how can I block when writing, to make sure my data is picked up?
can we replace read write function with something other than fn: read is a member in a struct, write is instantiating struct. 
no this will be confusing.
Crystal: `channel = Channel(Int32).new`, `channel.send(1)`, `value = channel.receive`, `channel = Channel(Int32).new(2)`
Kotlin: `val channel = Channel<Int>()`, `channel.send(x * x)`, `println(channel.receive())`, `Channel<Int>(4)`
q: how does select work with read and also with write?
q: How can we have a channel with transformation (e.g. compress, or logging)?
unbuffered channel: write blocks if no reader, read blocks if no writer
write block: write to a buf1 channel, wait until it is read
read block: read from buf1, you will be blocked if nothing is there
how can a writer know if the data in the channel is read? peek operation.
`ch_r: (timeout: int|nothing -> string|nothing)`
if we call reader with a timeout, it will timeout after that time, 0 for immediate return: will give T if something is there or nothing if nothing is there
NOW: if we call `ch_r` with `nothing` as timeout, it means a peek: return nothing if channel is empty, or return the data if it is there.
and peek is immediate by nature, there is no block or timeout.
q: how can this be done with good performance? Let's say I want to: block until the data is read. And a normal function call + sleep is not performant.
`ch_r: fn(timeout: int|nothing -> string|nothing)` nothing as timeout means peek (do not remove)
`ch_w: fn(data: int|nothing, timeout: int|nothing -> bool)` write nothing to close
we can add a core fn to sleep (idle) until one of channels are ready.
q: how to create a new channel?
`ch_r, ch_w = createChannel(int)` this will create a channel of size? 1
we can (have to validate) simulate buffered channel using size 1
but what about size 0? 
properties of size 0:
1- if you read and no writer, you will be blocked
2- if you write and no reader, you will be blocked.
for 1, you can peek until there is something there.
for 2, you write and peek as long as something is there.
- another mechanism would be useful: wait for signal
so, when I peek on a channel, don't sleep, register something so that the channel will notify me.
idea: can we have a third function for peek?
q: with peek we are exposed to concurrency issues. what if I peek something, but then someone else reads it?
why not use read with 0 timeout?
`ch_r: fn(timeout: int -> string|nothing)` 0 as timeout means return immediately
`ch_w: fn(data: int|nothing, timeout: int -> bool)` write nothing to close
properties of size 0:
1- if you read and no writer, you will be blocked
2- if you write and no reader, you will be blocked.
for 1, just read. if no writer, then channel is empty. so you will be waited.
for 2, write. but then, how can I make sure it is read? 
we can use another channel for this. we write, and wait for the other channel. when reader reads, it will send a signal on the other channel.
q: why do we need to close a channel?
q: what happens if I close a channel that has data? it makes sense that a closed channel is cleared and empty. so no more data can be read.
what happens if you close twice: nothing
when happens if you read from closed channel: it is always empty, so reader will give you nothing
how can we know if a channel is closed? maybe it is empty! what is the difference? anyway, there is no data there.
if you need more information, use another channel to relay those metadata.
so:
PROPOSAL
1. we create a channel by cakking `createChannel(int)` this will give us a reader and writer function
2. `reader: fn(timeout: int -> string|nothing)` 0 as timeout means return immediately
3. `writer: fn(data: int|nothing, timeout: int -> bool)` write nothing to close
4. You can close channel multiple times
5. You can read from a closed channel which will give you nothing
6. When you close a channel, all the data will be removed
q: why do we need to "close" a channel? write stop writing, reader won't have any more data to read!
so:
3. `writer: fn(data: int, timeout: int -> bool)` 
to simulate write block until data is read, you can write the data and then immediately write something else.
it will be blocked until prev data is read (for channel of size 1)
idea: can we use compare-and-swap instead? can it simplify things?
but suppose we have a producer and consumer threads. how can producer put work for consumer? we can define a cas for work,
the channel concept will make concurrency easier to reason and writing code easier.
also: support size (default to 1) when creating a channel.
we can add a core function that has a map of all channel functions to their identifier. this can be used for select or other functions (if needed)
q: can we eliminate need for timeout?
if we want to remove timeout and do it via a channel (or function), there should be a mechanism that accepts two (or more) functions that read from channel (one of them might be timeout)
then it calls them in parallel and keeps calling until? but if calling read locks the caller (if there is no data)...
maybe we can add a built in function (generic one), that actually works on functions (any function, can be channel read/write functions)
No. the underlying concept is we don't have unlimited timeout. Any IO operation must be limited in time. just like when I say `int|nothing` caller should
take into account for nothing.
similarly, user of a channel, should take into account the timeout. so, timeout is always part of the equation.
so, maybe it is all right to have timeout with function signature for channel read write.
how will select work? it will be in std and not in core. we only have createChannel in core.
in std: define select function that accepts a number of functions (either reader or writer).
`multiRead = fn(items: [fn(int->???`
this is a generic function but its input is variable size and with multiple types.
maybe it is worth adding a new keyword. but it will be really channel specific.
```
nothing_or_int_or_float_or_string = superSelectRead(100ms, chr1, chr2, chr3) #it doesn't make sense to have timeout in select.
int_val = superSelectWrite(100ms, chw1(data1, _), chw2(data2, _), chw3(data3, _))
```
can we use `//`?
`int_or_float_or_nothing = chr1(100ms) // chr2(200ms)` this makes sense, somehow
`index_num = chw1(data1, 100) // chw2(data2, 200)`
but we need to remove timeout right? because it doesn't make sense `chr1(100) // chr2(200)` means wait 100ms for channel1 reader then try channel 2 reader.
`int_or_float_or_nothing = chr1(0) // chr2(0)` 
above is better. but still does not imply loop/repeat.
we can define a function that says: evaluate fn, if it is nothing then repeat again until it is not nothing. 
`int_or_float_or_nothing = eval(fn{chr1(0) // chr2(0)}, 200ms)` and this can be a simple generic function.
what about write?
`type1_or_type2_or_nothing = eval(fn{chw1(data1, 0) // chw2(data2, 0)}, 200ms)`
problem:
- this is ordered, but we want it not to be
- this will not work with variable channel count
`int_or_float_or_nothing = select([fn{chr1(0)}, fn{chr2(0)}], 200ms)`
`type1_or_type2_or_nothing = select([fn{chw1(data1, 0)}, fn{chw2(data2, 0)}, 200ms)`
so:
`select = fn(items: [fn(->T|nothing)], timeout: int, T: type)`
we can even combine reader and writer functions.
`result = select([fn{chr1(0)}, fn{chr2(0)}, fn{chw1(data, 0)}])`
`reader: fn(timeout: int -> string|nothing)` 0 as timeout means return immediately
`writer: fn(data: int|nothing, timeout: int -> int|nothing)`
now, we can have a fn for timeout:
`result = select([fn{chr1(0)}, fn{chr2(0)}, fn{chw1(data, 0)}, timeout(100ms)])`
pro of now having timeout as arg of channel func: it will be simpler,
con: people may forget to use timeout when calling channel ops
`result = select([chreader1, chreader2, fn{chw1(data)}, timeout(100ms)])`
NO. the assumption of select is that, functions will return immediately telling if they have a data or not.
unless: we change it 180 degrees: reader and writer functions will always return immediately and tell you if they have something or not.
so, no timeout will be needed.
and then, if we want to synchronize? then what? we call select. select will keep trying on any given function until it has non-nothing result.
`reader: fn(-> string|nothing)`
`writer: fn(data: int -> int|nothing)`
`select = fn(items: [fn(->T|nothing)], T: type)`
`result = select([chreader1, chreader2, fn{chw1(data)}, timeout(100ms)])`
but select's input cannot be sequence of functions that have `T|nothing` as output.
it is `fn(->int|nothing)|fn(->string|nothing)|fn(->float|nothing)`
but it can also be interpreted as: `fn(->int|string|float|nothing)`
if I have a sequence of `fn(->int|float)` can I put a function that returns int, in that sequence?
I should be able to do that.
`x: fn(->int|string) = fn(->int) {...}`
this is covariance we had before. if somewhere they need a fn that returns `int|string` I can pass a function that returns int, or a function that returns string.
if we need a function that accepts `int|string` I should be able to call it with int or string or union.
so: PROPOSAL
`reader: fn(-> string|nothing)`
`writer: fn(data: int -> int|nothing)`
`select = fn(items: [fn(->T|nothing)], T: type -> T|nothing)`
`result = select([chreader1, chreader2, fn{chw1(data)}, timeout(100ms)])`
1. we create a channel by cakking `createChannel(int, size)` this will give us a reader and writer function
2. no close
3. read and write function return immediately with the result: nothing if no data to read or cannot write, or the data read or written.
4. you can combine it with select and timeout built-in func to have a waiting mechanism.
5. select will keep trying each function until one of them gives a non-nothing output.
6. makeChannel is built-in, others are in std.
it is good except, if we later want to use the built-in core function to get identifier of a channel function, it will be difficult.
why we may need that?
- when in select, I may want to use an OS level mutex to be notified when a change happens. but where will the mutex be? how can i access it?
- the function cannot use it because it is supposed to return immediately.
in linux we have sem_post to increase semaphore and sem_wait to wait (with timeout) for semaphore to be decreased.
without timeout, it will not be efficient. 
function (reader/writer), checks and returns immediately. but with a timeout, the function can wait on a semaphore/mutex or any other helper.
but assume we have timeout, how can select work then? assume we have two reader functions with timeout.
we can't. we should try each of them, and sleep for a short period of time.
example: producer-consumer with multiple producers. each consumer has an array of channels corresponding to producers.
now, how can consumer wait for any of producers? 
option1: check p1, wait, check p2, wait, check p3, wait, ...
option2: set a signal so that when either of p1, p2, p3 are ready tell me, with timeout of X.
the timeout function does not make any sense. it has internal variable state! it is not a function.
maybe we should use a timeout argument.
`result = select([chreader1, chreader2, fn{chw1(data)}], 100ms)`
but anyway, still it will be pulling strategy: try, sleep, try, sleep, ...
here (https://coderanch.com/t/486179/java/Wait-multiple-semaphores) they say, it is a sign of design issue if a thread needs to wait for multiple mutexes.
"Threads should wait for one type of work, do that work, and go back to waiting for more work. If there are more than one type of work, with more than one work queue, maybe it is a good idea to split it off -- and have different worker threads on each queue."
again, assuming we use pulling, we still don't have a semaphore. if we enforce "only channel functions" then select, can use built-in function to get semaphore of a channel function.
but not for writer!
here (https://github.com/golang/go/blob/9e277f7d554455e16ba3762541c53e9bfc1d8188/src/runtime/select.go) golang, sleeps waiting for one of channels to wake it up.
maybe, the idea of channel identifier is not too bad. but, we can hide it from the user: you can only select with a chr/w function.
and, then we can say, channel functions block all the time if the channel is not ready. solution: use select.
select is a built-in function. 
now, what about channel writer function?
`fn{chw1(data)}` is a new function.
we want channels to be composable. so we use functions.
we need something more than a function so that we can do low level optimizations.
option1: when creating a channel, return r and w function and a channel identifier.
in select: send channel identifier too. this is too complicated.
option2: send data separately from channel w function
option3: have a dedicated syntax.
option4: functions (r/w) have a special syntax that when called with that input, will give their internal channel id.
our aim:
goal1: be simple and minimal
goal2: be composable
goal3: support for variable number of channels -> not high priority
goal3 prevents dedicated syntax.
but even with dedicated syntax, if we are composable, what extra can it do?
`reader: fn(int|nothing-> string|nothing)`
`writer: fn(data: int, arg: int|nothing -> int|nothing)`
reader and writer have an additional runtime arg that can be called through runtime or select.
`reader(nothing)` will just read for you. `reader(x)` is called through runtime to do something special.
`result = select([chreader1, chreader2, chw1(data, _), timeout(100ms)])`
now with this change, select becomes a bit simpler. no need to wrap chw around fn.
runtime can pass all sorts of arguments to them. 
of course user can ignore this arg and call it normally, but runtime functions like select make use of that extra argument.
**PROPOSAL**
`reader: fn(extra:int|nothing-> string)`
`writer: fn(data: int, extra: int|nothing -> int)`
`select = fn(items: [fn(int|nothing->T)], T: type -> T|nothing)`
`result = select([chreader1, chreader2, chw1(data, _), makeTimeout(100)])`
1. we create a channel by cakking `createChannel(int, size)` this will give us a reader and writer function
2. no close
3. read and write function block if channel is not ready, then will return with the data read/written
4. you can combine it with select and timeout built-in func to have a waiting mechanism.
5. select will keep trying each function until one of them gives an output.
6. makeChannel/select are built-in, others are in std.
7. this is simple, minimal and composable. supports variable number of channels. 
q: can we re-use concept of `//` here instead of select function?
con: won't be able to use with variable number of channels.
we have a list of functions. input of each is `int|nothing`, output is type of channel.
`result = chreader1 // chreader2 // chw1(data, _) // makeTimeout(100)`
but, here functions cannot return `nothing`. so the meaning of `//` will be altered.
unless, we get back to the old way: return immediately with nothing if not ready
and compiler can handle functions ordering. but another problem: `//` is ordered.
what about using `///`?
`result = chreader1 /// chreader2 /// chw1(data, _) /// makeTimeout(100)`
in this case: pro: we won't need to worry about select function signature.
we can also use `//` and say, in this case, compiler will handle it. but it is not intuitive. two contradictory uses of `//`
one usage is ordered and one is random on purpose.
the select is a function itself: it will return as soon as any of its internal functions return.
so we have a super function. no input (all inputs are already there), output is or of all types.
timeout and default can be provided via built-in functions.
so, we need an expression that defines a function. creates a new function.
`selector: fn(extra:int|nothing->int|string|float) =  chreader1 /// chreader2 /// chreader3 /// chw1(data, _) /// makeTimeout(100)`
if we follow this path, we may also be able to support variable channel count.
`(chreader1 /// chreader2 /// chreader3 /// chw1(data, _) /// makeTimeout(100))()` will make the call but with what input?
we cannot give the input, so either `select` core fn should do that or the syntax we want to have, will not support it.
so lets have a syntax that also makes the call and everything. does not give us a function, but the result.
`result = chreader1 /// chreader2 /// chw1(data, _) /// makeTimeout(100)`
again, no need to return nothing. calls will be blocked until channel is ready for the operation.
we can also use `||` this is used in csp to show parallel execution. 
but `||` is not good because it will be confused with OR.
**PROPOSAL**
`reader: fn(extra:int|nothing-> string)`
`writer: fn(data: int, extra: int|nothing -> int)`
`result = chreader1 /// chreader2 /// chw1(data, _) /// makeTimeout(100)`
1. we create a channel by cakking `createChannel(int, size)` this will give us a reader and writer function
2. no close
3. read and write function block if channel is not ready, then will return with the data read/written
4. we have select as operator `///`
4. you can combine it with select op and timeout built-in func to have a waiting mechanism.
5. select will keep trying each function until one of them gives an output.
6. makeChannel are built-in, others are in std.
7. this is simple, minimal and composable. supports variable number of channels. 
what happens if I use a normal function? this shouldn't happen. unless that normal function is backed by a channel function.
but anyway if this happens, a runtime error will happen.
q: now that we want to add a new notation, can we make it simpler?
q: is `///` a good operator?
`result = chreader1 \\ chreader2 \\ chw1(data, _) \\ makeTimeout(100)`
we can use back slash, but it will become confusing: which one is which.
`//` for nothing check
`\\` for select on multiple functions
q: if underlying OS, gives us the read/write result directly, then composing functions into each other will not be possible.
specially in select. I sleep waiting for channel X, and when it is ready, it will send the data
this can be implementation dependant. 
to make it simpler:
`result = chreader1 /// chreader2 /// chw1(data) /// makeTimeout(100)`
Let's make it implementation independent.
suppose that in implementation, we notice that after select for read, when I wake up data is already read. So I simple ask the function to keep it.
call the main function and get the data.
problem happens with write (?): I tell it to try to write, sleep, when I wake up:
1 - if data is not written yet: call function to write
2 - if data is written, the one that has passed through wrapper function is written. so its all right and I can continue.
so, we can continue with function composition. we still need that additional int argument that is the communication channel between runtime and channel function.
`result = chreader1 /// chreader2 /// chw1(data, _) /// makeTimeout(100)`
each element in `///` will be a function that accepts an `int|nothing`.
you can also provide a default:
`result = chreader1 /// chreader2 /// chw(data,_) /// 100`
the last item can be a non-function which means the default value, returned if none of functions have a data.
q: what if channels are for function that accepts an int? then what should/can be put for default?
we cannot ban having channels of lambdas.
solution: instead of a value, use a core function: `defaultChannel(x)`
q: can we have channels of channels? yes. these are functions that accept/return other functions.
**PROPOSAL**
`reader: fn(extra:int|nothing-> string)`
`writer: fn(data: int, extra: int|nothing -> int)`
`result = chreader1 /// chreader2 /// chw1(data, _) /// makeTimeout(100) /// defaultChannel(200)`
1. we create a channel by calling `createChannel(int, size)` this will give us a reader and writer function
2. no close
3. read and write function block if channel is not ready, then will return with the data read/written
4. we have select as operator `///`
4. you can combine it with select op and timeout built-in func to have a waiting mechanism.
5. select will keep trying each function until one of them gives an output.
6. makeChannel are built-in, others are in std.
7. this is simple, minimal and composable. but does not support variable number of channels.

N - Using `()` for struct doesn't feel right.
`Point = struct(x: int, y:int, data: float)`
`location = Point(x:10, y:20, data:1.19)`
`point1 = struct(int,int)(100, 200)`
```rust
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```
```golang
type Person struct {
	FirstName, LastName string
	Age       int
}
person{"Bob", 20}
anonymousStruct := struct {
	NESCarts 	[]string
	numberOfCarts   int
}{
	nesCarts,
	numberOfCarts,
}
```
```kotlin
data class User(val name: String = "", val age: Int = 0)
val jane = User("Jane", 35) 
data class Person(val name: String) {
    var age: Int = 0
}
```
why did we drop braces for struct? to prevent confusion with fn. if we have fn and struct in a function args, they can be confusing.
`Point = struct(x: int, y:int, data: float)`
`location = Point(x:10, y:20, data:1.19)`
`point1 = struct(int,int)(100, 200)`
struct keyword is like `fn` keyword. but without `{}` afterward.
`struct(...)` defines a struct type.
this looks good.

Y - Can we mix two channel functions?
Maybe it doesn't make a lot of sense to separate channel reader and write.
it is like having private variables.
`reader: fn(extra:int|nothing-> string)`
`writer: fn(data: int, extra: int|nothing -> int)`
`channelFunc: fn(data: string|nothing, extra: int|nothing -> string)`
to write: `channelFunc(data)`
to read: `x = channelFunc()`
it will be simpler.
how does runtime call this?
to write: `channelFunc(data, arg)`
to read: `channelFunc(nothing, arg)`
if you want to give someone r-o access you can wrap channel function in another fn:
`readerOnly = fn(runtime: int|nothing->int) { channelFunc(nothing, runtime) }`
`result = chFunc1(nothing, _) /// chFunc2(nothing, _) /// chFunc3(data, _) /// makeTimeout(100) /// defaultChannel(200)`

N - do we need contracts? like golang
```go
contract stringer(T) {
	T String() string
}
```
for generic functions and types, we may want to say "T" is not a general type for all available types.
But any type used for T must have these properties: ...
q: can this help with polymorphism? e.g. an array of shapes?
if I say `T: SHType, x: [T]` x is a sequence of type T. But T can only have one and only one value.
this is called existential type.
but, does contract define a new type? or it just represents a set of existing types?
if new type -> we can have a sequence of shapes
but if it is set of existing types then `[T]` can have only one element type, even though T can represent multiple types.
lets for now put it away.

N - contrats
existential types
polymorphism
do we want to define a notation to specify a group of types or a notation to define a new type?
```haskell
data Worker x y = forall b. Buffer b => Worker {buffer :: b, input :: x, output :: y}
```
lets not do it now. maybe later.

N - If we want to have polymorphism, we can re-use the concept of sum types: `int|float`
but provide tools to "describe" types in the sum type definition.
so we don't enumerate them, we describe them. and any type that conforms to that description will be in that group.
then: `T = description of shape`
then I can use `[T]` as an array of shapes.
or I can use `T` as a generic type argument.
`draw = fn(T: ShapeType, x: T, c: Canvas)...`
but then, we need to work with variables of type T which are sum type. can we use common properties of them?
but what problem will this solve?
There is inclusion polymorphism where we say `Student` type or any other type that includes a student's fields are all right.
but this is just a simple type conversion. convert your type to student and call the function.
maybe in order to increase performance in this regard, we can do something.
but this won't be at language level.
We can do this: When you filter out fields from a struct, result will be light weight. it will not be a completely new data struct. but just pointers to original struct.
anyway, this is for the compiler.

N - Is there anything we can remove?
unify the concept of map, seq and function.
`x: [int] = [1,2,3]`
`x: [string:int] = ["A":1, "B":2, "C":3]`
`x = fn(s: string->int) { ... }`
or unify struct with map. say: struct is a map.
but when will be type of keys on that map? string? then it will become really perl-like and it won't be good for performance.
unify sequence, map and function.
how can we unify seq: 
`[string]` is `[int:string]` and compiler will help write keys so you only need to write values.
fn Input to Output is a map. input is a struct. output if function output.
but it will be confusing..

N - How can we implement a set of map of string to object (e.g. a set of documents read from ElasticSearch)?
How will the Elastic API look like? `document: [String: int|string|float|Document]`
`Attribute = int|string|float|Document`
`Document = [String: Attribute]` is this allowed? should be fine.
if we have the data model we can define the struct:
`Document = struct (name: string, age: int, ...)`
`data: [Document]`

N - Shoudl we allow reverse call of function?
`f(x)` vs `x::f(_)`?
`(x,y)::f(_,9,_)`
not for now.

Y - Can we embed contract in fn?
e.g. this function, when called with a connection, will release the connection.
Goal is to make software more maintainable and prevent bugs.
This can be partly done via documentation, proper naming, good design, named types and other language features.
e.g. after I call function remove with a db connection, can I still use it?
can I remove a connection from pool and later return it?
types of contract:
- pre-requirements of a function
- post requirements of a function
- requirements of a type
can we embed contract for types in the generic function?
```
LinkedList = fn(T: type -> type)
{
	Node = struct (
	    data: T,
	    next: Node|nothing
	)
	Node|nothing
}
```
on one hand it is useful. but otoh it makes language more complex.
in some languages like Java or Scala they just provide some basic functions like assert, assume, ...
there is also dependent types
complexity: deciding and reasoning about equality of two types becomes difficult.
in the easiest form, contract for a type is its constructor.
```
MyInt = int { _>=0 }
```
But, can I use `int{_>=0}` as type of a function argument?
if so, what can I use to call the function?
question: is `{_>=0}` part of the type? 
it should be. so `MyInt` and `MyInt2` are not the same thing.
but if I have `save = fn(x: int{_>=0} -> ...`
can I call save with a normal int?
q: what about multi-value types like struct or map or seq?
```
Point = struct(x:int, y:int) { _.x!=_.y}
Months = [string] {length(_) == 12}
```
q: what if I call a function inside contract? it is fine. nothing hidden is happening. the fn will be called each time a binding of that type gets a value.
`save = fn(x:int, y:int->float){x<y} { ... }`
so, all examples that we have:
```
save = fn(x: int{_>=0} -> ...
Point = struct(x:int, y:int) { _.x!=_.y}
Months = [string] {length(_) == 12}
save = fn(x:int, y:int->float){x<y} { ... }
```
it will put a performance cost and make type system complicated. 
is there a way to make this simpler or more minimal?
for fn, you can put anything you want inside the fn body.
for types, we want to have a check function to make sure the value assigned is a valid one.
```
Point = struct(x:int, y:int) { _.x!=_.y}
```
why not embed this logic inside a normal function?
```
PointTemplate = struct(x:int, y:int) #{ _.x!=_.y}
_PointTemplate = fn(x:int, y:int -> PointTemplate) {
	assert(x!=y)
	PointTemplate(x: x, y: y)
}
```
but nothing prevents people from creating instances of Point without calling createPoint.
so be it.
rather than creating more rules and exceptions and dos and donts, let them use existing features.
but, this may make sense to say: this type should not be created directly, it can only be created by calling function X.
so, how can we tell this?
naming? but naming convention for types and functions are totally different.
maybe we can name these functions same as types. But then they will be confusing as they look like generic functions.
```
PointTemplate = struct(x:int, y:int) #{ _.x!=_.y}
PointTemplate = fn(x:int, y:int -> PointTemplate) {
	assert(x!=y)
	PointTemplate(x: x, y: y)
}
my_point = PointTemplate(x: 10, y:20)
```
we normally create bindings by putting struct name and then values inside `()`. 
if there is not `PointTemplate` function, then `PointTemplate(x:10, y:20)` will instantiate the struct.
but if there is such a function, this will be a function call. not a struct instantiation.
this is a little bit confusing.
```
PointTemplate = struct(x:int, y:int) fn{
	assert(x!=y)
}
my_point = PointTemplate(x: 10, y:20)
```
this looks much better. we define PointTemplate as both a struct and a function.
and as it seems, fn is part of the definition.
q: can we have this fn notation for other types?
```
PointTemplate = struct(x:int, y:int) fn{ assert(x!=y) }
MyInt = int fn{ ... }
SeqInt = [int] fn { ... }
Map1 = [string:int] fn { ... }
```
Either we have to make it complicated with lots of rules and notations.
or we have to add lots of exceptions: you can define this but only for this type and not that type.
Idea: put contracts in comments
this way, we are explicitly stating they are not part of the real code.
also we are explicitly stating that this is not part of the function/struct type
but they can be checked by runtime in debug mode.
Also as this is a code, it can only be placed inside a code block: function or maybe struct
```
save = fn(x:int, y:int -> nothing) {
  ##(x<y)##
  ...
}
PointTemplate = struct(
  ##(x!=y)##
  x:int, ##(x>0)##
  y:int  ##(y<0)##
)
MyInt = int ##? there is nothing to refer to
```
so this only works for struct and function. not named type, sequence or map.
we can add a new notation to refer to value of the type (named type, seq, map, ...) but it will be confusing.
but not having this for seq/map/... is also confusing.
solution: if you really need this, enclose them in a struct. so that they have a name.
Also this will not be available for unnamed structs as there is no field name to refer to.
we call this contract. 
**PROPOSAL**:
1. you can define contracts inside a function body or struct body.
2. fn contracts will be executed at the time execution comes to their location.
3. struct contracts will be executed all at once when a value is assigned to them.
4. you can disable contract check and compilation using a compiler flag.
5. You can call any function inside a contract.
6. if a contract evaluates to "false" a runtime error will happen. anything else will be ignored.
7.
```
save = fn(x:int, y:int -> nothing) {
  ##(x<y)##
  ...
}
PointTemplate = struct(
  ##(x!=y)##
  x:int, ##(x>0)##
  y:int  ##(y<0)##
)
```
So, basically you can put contract anywhere in the code or struct definition.
you can use contract in an inline type, although it will make code messy.
what would be a good notation for contract?
- it should start with `#` comment notation
- it should be very easily detected in the source code both by eyes and the editor
`##x<0##`
`#ensure(x<0)#`
`#assume(x<0)#`
we can use assert core function: we have assert function in core that can be normally used to make assertions.
why comment? why not simply use assert?
for struct, we can allow using assert in the struct definition.
but advantage: 
- no change in notation
- no need to use comments, just call assert
- no need to change fn
- no ambiguity: can I call assert inside a fn call?
for struct:
```
PointTemplate = struct(
  x:int,
  y:int,
  assert(x>0),
  assert(y<0),
  assert(x+y<100)
)
```
here, people may ask: why can't we call other functions inside struct definition?
actually, this is a mini-function that is executed everytime a new PointTemplate is created.
"AFTER"
so, can't we make it look like a function?
```
PointTemplate = struct(
  x:int,
  y:int) {
  assert(x>0)
  assert(y<0)
  assert(x+y<100)
}
```
so, no new notation is needed.
it looks like a function (inside braces, lines of code, ...)
and it should be just like a function: you can write any type of code in it.
`func = fn(x:int, y:int -> int) { ... }`
`S1 = struct (x:int, y:int) { assert(x!=y) ... }`
`data = S1(x:10, y:100)`
actually, we are calling a pseudo function called S1 which creates a new instance of the struct, and runs some code.
**PROPOSAL**:
1. you can use assert core function to do assertions/pre-req/post-req/ensure/contract/...
2. you can put a `{}` after a struct type definition and write a code there. it will be executed after any instance of that struct created.
3. you can disable compilation and checking of asserts during compiltation.
Example:
```
PointTemplate = struct(
  x:int,
  y:int) fn{
  assert(x>0)
  assert(y<0)
  assert(x+y<100)
}
```
this is better. we use `fn{...}` so that it is actually a valid function. it is more orth.
but we still cannot use a lambda here. because we are relying upon closure (sort of), to access struct fields.
```
PointTemplate = struct(
  x:int,
  y:int) fn(x:int, y:int->) {
  assert(x>0)
  assert(y<0)
  assert(x+y<100)
}
```
but this is messy and confusing.
```
PointTemplate = struct(
  x:int,
  y:int) fn{
  assert(x>0)
  assert(y<0)
  assert(x+y<100)
}
```
you can however, call you own function:
```
PointTemplate = struct(x:int, y:int) fn{ checkData(x,y) }
```
**PROPOSAL**:
1. you can use assert core function to do assertions/pre-req/post-req/ensure/contract/...
2. you can put a `fn{}` after a struct type definition and write a code there. it will be executed after any instance of that struct created. This can be used for contract or logging or any other usage.
3. you can disable compilation and checking of asserts during compiltation.

N - The notation of channel function, if we compose it inside another fn and want to call the wrapper in a select, it should return immediately.
so does it support `nothing` result?
`chFunc: fn(data: string|nothing, extra:int|nothing-> string)`
- pass nothing as data, if you want to read
- extra is used by runtime
suppose that I have a logging wrapper on top of the channel. 
so the wrapper is a function:
```
originalCh = ...
wrapper = fn(data: string|nothing, extra: int|nothing -> string) {
	log("calling channel func...")
	originalCh(data, extra)
}
```
- we can say: protocol is if extra is not nothing, do not interfere with the call and also ignore the output, but this is too much
suppose that I want to implement `///`: I will need to call ch functions and pass them (or ask them), their pid or file identifier or anything.
so I will need them to return! if they don't return, things will be complicated.
lets focus on this later.

N - Can we define a generic function that can accept any function?
e.g. a logger function/auth/validators/...
we can simple define some pre-defined functions (generic) and use them.
e.g.
`fn1 = fn(x:T, T: type -> nothing)`
`fn2 = fn(x:T, y:U, T: type, U: type, V:type -> V)`
`logger = fn(f: T, T: type -> ?`
it makes things complicated.
and we don't support generics at runtime.
example: a method tha is supposed to process some data, also have a validator for them, which is optional.
`...validator: fn(x:int->boolean)|nothing...`
how can I call validator only if it is not nothing?
write a hlper function. but then function should be generic. we don't want to write one function per use case.
`optionalInvoke = (x: fn(???)|nothing, input:XYZ -> OUT_TYPE)... if x is nothing then return nothing, else call x`
either we have to:
1. have a notation which is nothing-aware
2. have generic variadic functions -> this makes things complicated but will also be useful for other cases lokie logging
`x = y // 9`
`//` is applied on two values and checks for nothing
`result = nothing // x(data)`
no. this is confusing.
`result = x // nothing // x(data)`
`result = [fn{nothing}, fn{x(data)}][isNothing(x)]()`
`result = checked(x, fn{x(data)})`
```
checked = fn(t:T|nothing, result: fn(->U), T: type, U: type -> U|nothing) 
{
[fn{nothing}, result][isNothing(t)]()	
}
```
But here we are calling `x(data)`. Is that ok?
correct way is to write:
```
tryInvoke1(x, data)
tryInvoke1 = (x: fn(T->U)|nothing, input:T -> U) 
```

N - for values we have `x//1` so we take x or if it is nothing, we take 1.
what about functions? is there an easy way to do this?
if it is nothing -> use this value
if it is not -> just call it
`result = func1(1,2,3)//0`
`result = (func1//fn{0})(1,2,3)` but this is not correct. 
`result = func1//(1,2,3)` this will return nothing if func1 is nothing, otherwise will make the call
`result = func1//(1,2,3)//0` but it is not intuitive
`result = func1(1,2,3)//0?`
function or nothing is not a good idea maybe
maybe it should always be a function and you can pass an actual function or a simple `fn{nothing}` for it.
another solution is ifelse or `?:` operator.
`X//Y` says if x is nothing use Y. but what if it is not?
`result = func1//(1,2,3)//0` but it is not intuitive
`result = func1//0//(1,2,3)` not intuitive
`result = func1?(1,2,3)`
or we can just say optional functions can be called. and result will be nothing if they are nothing.
we can say, nothing can be a function that accepts any number/type of inputs and returns nothing.
`x = nothing`
`is_nothing = x(1,2,3,4,"A")`
but this is super confusing. nothing is a function ...
`x = func1 // func2 // ???`
what if we make it the other way around: if func1 is nothing then use X, otherwise run this piece of code (which calls fn)
`r = getValueIfNull(func1, 10) // func1(10,20,30)`
```
getValueIfNull = fn(x: T|nothing, default_value: U, T: type, U: type -> U|nothing) {
	[nothing, default_value][isNull(x)]
}
```
so, if func1 is nothing, we will have 10, otherwise getValueIfNull will return nothing. in this case, we will make the call.
if func1 is not nothing, this will return nothing, which will cause the call.
we should find a better name for this function.
so, basically we are swapping. nothing becomes a valid value, otherwise, will return nothing.
we swap valid with nothing and nothing with some value.
`swapNothing`?
```
r = swapNothing(func1, 10) // func1(10,20,30)
swapNothing = fn(x: T|nothing, default_value: U, T: type, U: type -> U|nothing) {
	[nothing, default_value][isNull(x)]
}
```
BUT still func1 is not a pure function. it is function OR nothing.
`x = int_or_nothing // 10` type of x will be int
`r = swapNothing(func1, 10) // func1(10,20,30)` if func1 returns int, type of r will be int
swapNothing returns `int|nothing` but problem is on the right side of `//` 
we cannot simply invoke a `fn|nothing`
invoking a `fn|nothing` is like referencing an object in java, there will be runtime error NPE at runtime if we make a mistake
and compiler cannot do anything to prevent that.
`func1//(1,2,3)` no
`(func1//NopFunc3)(1,2,3)`
one way: we define `NopFunc` functions that take 1,2,3... inputs and return nothing. 
these can be defined in std.
then we `//` with them. compiler should infer the argument types.
```
NopFunc1 = fn(input: T, T: type -> nothing)
NopFunc2 = fn(input1: T, input2: U, T: type, U: type -> nothing)
...
(func1//NopFunc3)(1,2,3)
```

N - Module alias. they will be used a lot.
maybe we should define their own naming convention
But we use `..` for module aliases. which is different enough.

N - Maybe we also need some helpers to make writing common codes easier.
e.g. if/else

N - This can also be a good syntax `[a;b;c]` rather than `[a,b,c]`

N - Can we have a `match` like rust?
it can be used with enums and unions and other values.
```
//with unions
result = match exp
	[
	 int : (x: int -> string ) { ... },
	 string: (y: string -> string ) {...}
	]
//with values
result = match exp
[
	value1 : fn{1},
	value2:  fn{2}
]
```
so we have `reulst = match exp hashMap`
where hashMap's keys are types or values and values are functions that all return the same thing.
in case of types, those functions have a single input of type provided.
can't we redue this to a map lookup? what we already have?
```
//with unions
result = 
	[
	 int : (x: int -> string ) { ... },
	 string: (y: string -> string ) {...}
	][typeof(exp)]
//with values
result = 
[
	value1: fn{1},
	value2: fn{2}
][exp]()
```

N - swift has argument label
```swift
func greet(_ person: String, from town: String) -> String {
    return "Hello \(person)!  Glad you could visit from \(town)."
}

greet("Bill", from: "Cupertino")
```
now above function call reads very much like english
```
find = fn(data: string, in target: string)...
```

N - When we see this `location = Point(x:10, y:20, data:1.19)`
how do we know whether it is a struct or a generic function call?
if we are allowed to write `location = Point(10, 20, 1.19)` then this becomes a bit more complicated.
what about using `{}` for structs?
`location = Point{x:10, y:20, data:1.19}`
pro: differentiate from generic functions
cons: will be same as code blocks
kotlin: `data class User(val name: String, val age: Int)`
Scala: `case class Message(sender: String, recipient: String, body: String)`
Oberon2: 
```
ObjectDesc* = RECORD
		x-,y-: INTEGER;
	END;
```
struct init without `:` should be forbidden.
function call with `:` should be forbidden.
generic functions all have a type argument.
structs have all values as arguments

Y - Same as functions, allow if create a struct and don't set value for `|nothing` member, it will automatically be nothing.

N - variadic args
Here https://dave.cheney.net/2014/10/17/functional-options-for-friendly-apis
author has suggested a very concise way of implementing APIs which are extendable, accept defaults and are easy to use.
for example a config class and a set of lambdas which change sth in the config.
this can be implemented via a sequence.

N - By using optional args, we have this:
`seq = fn(start_or_length:int, end:int|nothing -> ...)`
but argument name is not very clear.
we want to have:
`x = seq(5, 20)`
or
`x = seq(10)` from 1 to 10
we cannot have two `seq` functions.
if we accept structs as function input maybe we can do this:
```
seq = fn(start: int, end:int | length:int -> ...) {
	//if input is lenght then ... else ...
}
```
then you can call seq like: `seq(1,2)` or `seq(10)`.
Like haskell:
```
fact :: Int -> Int 
fact 0 = 1 
fact n = n * fact ( n - 1 ) 
```
but we don't want to have multiple bodies for functions. so we have one body, with all alternate argument combinations.
but using `|` can be confusing.
```
seq = fn(start: int, end:int) { ... } fn(length: int) { ... }
```
So `seq` is a function that has two bodies. because it can accept two input types.
but this is soo confusing when combined with other stuff like lambda.
if I write `seq(_,_)` and both bodies have two args, which one will it mean?
no. let's don't add this new syntax which is completely new.
`seq = fn(start_or_length:int, end:int|nothing -> ...)`
we can write:
`seq = fn(start:int, end:int)`
`seqLen = fn(length:int)`

N - Allow `|` notation for arg name (and struct fields)
`seq = fn(start|length:int, end:int|nothing -> ...)`
so start and length are labels pointing to the same thing.
and if we allow/force arg name when calling function, it can also use any of these two names.
with named args, we can never change function arg name but we have the same thing with structs.
maybe we can transparently make struct and fn call args interchangeable.
and allow above notation for struct too.

N - struct use as function args
the syntax is really similar. maybe we can merge them to simplify language and increase orthogonality.
`process = fn(x:int, y:int -> int ) { x+y }`
`process = fn(struct(x:int, y:int) -> int ) { x+y }`
if we allow named args, what happens to function assignment?
for example if I have `process = fn(x:int, y:int)`
can I assign it to a variable of type `fn(a:int, b:int)`?
There are many similarities between struct and fn args:
- `|` notation (above item)
- nothing default/optionals
- visual similarity
which one is the primary one? can we say fn args is a struct?
can we make them interchangeable? 
so we can call a fn with args or a struct
q: what about args with one struct type input? won't it be confusing?
maybe we can re-introduce struct destruction operator.
but what problem are we solving? 
- we want to unify two concepts so that number of concepts one needs to keep in mind decreases.
Python: `myfun(1, *("foo", "bar"))`
advantage: named arguments
so we can write: `greet("A", from: "London")`
code will be more readable.
but if we do it, it should not be optional. it must be mandatory.
so, we can say, all functions accepts structs as input. compiler provides syntax sugar so you dont need to have double parens.
`process = func(x:int, y:int -> int)`
`process = func(struct(int,int)(x:int, y:int) -> int) ...`
`process(1,2)`
`process(struct(int,int)(x:1, y:2))`
but messing with functin type is confusing. we rely on fn type a lot.
and a new hidden rule will make those stuff confusing.
and having labels is also confusing. it promotes using one field for multiple purposes.
this does not exist in any other lang except Swift

N - Can we use `_` in struct initialization to automatically define a lambda?
`ptGenerator = Point(x:10, y:20, z:_)`
what would be the advantage?

Y - notation to edit a struct should be better. having to re-write all fields is daunting.
`another_point = Point(x:11, y:my_point.y + 200)`
we can use `//`:
`another_point = Point(x:10) // my_point` but `Point(x:10)` is not valid.
`another_point = Point(my_point, x:10)` you can mention any number of structs of the same type
they will all be merged

N - Why not properly cast type name and value for nothing and error?
`Nothing` will be the type and `nothing` the value
`Error` will be the type and `error` the no-op value
because these will be used alot and all lowercase makes them easier to type.

Y - using seq and map for conditional is more a mis-use.
`x = seq[condition]`
`x = mymap[value]`
we can replace this with a switch/match:
if/else uses true/false?
or maybe we can add their own notation: ifelse. but this can be done via function. so no need. 
just implement what is absolutely essential.
again we need a separator! `{}` is not good because it is supposed to only be for function (and prob soon it will be used for errors too)
```
result = expression @value: expression, @value2: expression2, @value3: expression3
```
we can go and implement sth like Racket or Scala for pattern matching but it will be very complex for reader of code and writer of it.
let's keep it as simple as possible.
type of pattern matching:
- value matching (if a=b)
- condition mathing (a: if <10 then ...)
- tuple-matching: if a=1 and b=2 then ...
- union matching: if float then ... if int then ...
- regex matching
- enum matching
- multipel cond: if X and Y then ...
maybe its time to use `{}` for this purpose
```
result = match(expression) {
	value1 => expression1
	value2 => expression2
	value3, value4 => expression3
	_ => expression4
}
result = match(union) {
	x: int => expression1
	y: float => expression2
	_ => expression4
}
result = match {
	value1>0 => expression1
	value2<10 => expression2
	value3==0 and value4!=0 => expression3
	_ => expression4
}
```
expression can also be anonymous struct: `(x,y,z)` and matches will be like `(1,2,3)`
can't we do this via functions or other tools? this needs a lot of new notations:
- match keyword, `=>` braces
we define `match` function in core:
`match = fn(exp: boolean, value1, lambda1, value2, lambda2, ...)`
but then we cannot prevent evaluation of all cases. what if one of them is a comp heavy?
`match = fn(exp: T, cases: [Case(T|nothing,U)], T,U: type -> U)`
`Case = struct(value: T, handler: fn(->U))`
there is an important diff between this and error handling.
error handling is a syntax sugar + enables what was impossible before (early ret)
to make code more readable. we can live without it but there will be lots of indents and complexity in the code.
this is not a syntax sugar. we are adding a new notation and construct to the language.
so for error handling, it is not as big a deal as this.
what if we can do this without a new notation?
`match = fn(exp: T, cases: [Case(T|nothing,U)] -> U) ...`
`Case = struct(value: T, handler: fn(->U))`
`matchVal = fn(exp: T, cases: [ValCase(T|nothing,U)] -> U) ...`
`ValCase = struct(value: T|nothing, value: U)`
so we can cover match on value (with value or lambda).
for union we will address this separately.
```
result = process(1,2,3)
data = match(result, [
	(1, fn{ "it is one" }),
	(2, fn{ "it is two" }),
	(3, fn{ "it is three" })
])
```

N - general union
what remains is a match over union.
`result = match(int_or_float, fn(x:int -> string) ..., fn(y:float -> string)...)`
but how are we going to define match function?
`result = match(int_or_float, [fn(x:int -> string) ..., fn(y:float -> string)...])`
`matchUnion = fn(x: T|U, cases: [fn(T -> V) | fn(U, V)])`
how can we have this for any number of cases? e.g. a union with 3 or 4 types
we want to define a generic type with a union type which can be a mix of multiple union types.
`matchUnion = fn(x: T|U|B|N|M, cases: [fn(T -> V) | fn(U, V) | fn(B->V) | fn(N->V) | fn(M->V)])`
this can also be useful in polymorphism and variadic generics.
but this is complicated.
what if we can have a map of `T` to a funct that has T? will this solve our problems?
a map of `T` to a function that has no/some input and gives you `U`.
this can definitely help with polymorphism because this will be our vtable.
with matchUnion: cases will be exactly that map. lets call it magic map
`matchUnion = fn(x: T|U|B|N|M, cases: magicMap(T,U,B,N,M,fnxV))`
but what about the first item? a general union?
how can I write a generic function that accepts general union type?
so we need two things: general union, magic map
maybe only having magic map is enough. we can look up in the magic map with a union and it will give us what we want.
`magicMap = map of T|U|V|B|N|M to functions of those types`
`MagicMap=[T:fn(->T)]`
no this will be too complicated to write and read. 
lets drop it.
no match for unions.

Y - A dedicated syntax for error handling?
Rust: `f.read_to_string(&mut s)?`
Go2:
```
handle err {
	return fmt.Errorf("copy %s %s: %v", src, dst, err)
}
check io.Copy(w, r)
```
we need to define a universal error structure, like Java (Exception) or Rust (`Result<T,E>`).
and it should be nestable (like a linked list).
and it should be extendable/composable (you should be able to mix multiple unrelated libraries each throwing their own errors).
for example passing a function X to function `process` where X can throw an error.
```
error = struct(source: string, type: string, message: string, additional: string, nested_error: error)
example of source: com.a.utils
type:FileNotFound
message: Path is invalid or file is missing
additional: ...
```
and how do we deal with error?
```
result_or_error = process(data)
hasType(result_or_error, error) @ enrichError(result_or_error, "Failed!")
```
This means support for early return.
```
result_or_err@err //err is a keyword
result_or_err@enrich(err, "Failed")
result_or_err: error? //syntax for type check: var:type? gives you a boolean
res_or_err: error? => enrich(res_or_err, "Failed") compiler will automatically cast r_or_e to error on the right side of => , here we have 4 new things: ?, => and early return concept and compiler auto-cast
hasType(r_or_e, error) => enrich(r_or_e, "Failed") //her we have 3 new things =>, early return concept and compiler auto-cast
getTyped(r_or_e, error) 
```
1. error handling should be done asap, this helps readability and compiler output generation and performance
so instead of `if (x) {.....} else return error` we should do `if (!x) return error; othertiwse ...`
an example with single-return and guard clauses:
```
public Foo merge (Foo a, Foo b) {
    Foo result;
    if      (a == null) result = b;
    else if (b == null) result = a;
    else
    {
        result = // complicated merge code goes here.
    }

    return result;
  }
```
a problem with this is mutable state. maybe we can fix this with an uninitialised var which is only assigned once.
`try(result_or_e, fn(e: error -> error) { error("A", e.type, ...) })`
`try(result_or_e, { enrichError(result_or_e, "Failed") })`
`result = @try(process(data), enrichError(_, "Failed"))` this calls process(data), if result is error, calls the lambda (enrich) and does early return with the result. otherwise, assigns result fo result (which is not an error)
`result = @(process(data), enrichError(_, "Failed"))`
`result = @(expression, error_lambda)`
`@ = fn(data: T|error, handler: fn(error->error), T: type -> T)`
`@ = fn(data: T|U, handler: fn(U->U), T: type, U: type -> T)` but this is too generic and not very useful
questions:
1. can we mix multiple `@`s?
2. can we use `@` with concurrency stuff?
3. can we use `@` in struct init function or tests?
4. what if inside`@` is not union of error?
5. can I pass `@` as a lambda to a function?
6. can I use `@` with other types as long as handler matches?
using parens gives the impression that this is a function and raises all of above questions.
`result = expression => enrichError(_, "Failed")`
visually it is not very intuitive
`result = expression catch lambda_accepting_error`
why give user ability to write a function! just create an error struct (pointing to the current error) and return
`result = expression => (source: "A", type: "B", ...)`
`result = expression || error(source: "A", type: "B", ...)`
`result = expression || makeError("A", "B", "Data", _)`
so left side of `||` is `T|error` and right side if `fn(x:error->error)`?
cant we use the same thing for early return? assuming we don't need a new notation/syntax
`isError(expression) || makeError("A", "B", "Data", ?)`
what is the purpose of early return? to check for errors or validations. 
`expression orelse error()`
`exp || R` R can be a value that will be an error value that will be returned. but how can we refer to the current error then?
`result = exp || fn(x:error->error)`
if exp is of type `T|erro` we can be sure that type of result will be T.
`result = exp "or in case of error run this and immediately return from current function the value you get" fn(x:error->error)`
`result = exp orthrow funcErr(_)`
`result = exp guard funcErr(_)`
or maybe its better if we do not mix this with `=`:
`result = getData(...)` this can be T or error
`result guard funcError(_)`
but the bad thing is again we will have to destruct result to make sure it is T now, while if we combine it with `=` compiler can do that for us
`result = exp guard funcError(_)`
basically this is a combination of catch and return.
`result = exp or raise funcError(_)`
and we can say error return can only be done via raise keyword. but why limit that?
we should be able to mix this: for example if a function input is int, and function B reutrns int or error, I should be able to write:
`functionA(functionB(1,2,3) || makeError(_))`
maybe we should not allow for error customization. just return the error. if you want customization, then do it properly.
`x = @exp` meaning `if exp is int|error, if it is error then return it and exit immediately, otherwise, save int part in x`
but it can be confusing when mixed.
`x = @exp.field` now what part does `@` apply to?
if we treat it like a function then this will be resolved, but we will be moved back to square one:
1. can we mix multiple `@`s?
2. can we use `@` with concurrency stuff?
3. can we use `@` in struct init function or tests?
4. what if inside`@` is not union of error?
5. can I pass `@` as a lambda to a function?
6. can I use `@` with other types as long as handler matches?
`@ = fn(data: T| error -> T)...`
no. making this a function will make a lot of confusion.
it should be an operator. 
defining an operator specifically for a single type looks like a lot but error handling is important.
q: how can we simplify error type?
and just like other operators like math or `.`, this operator has its own precedence:
`@exp` means if exp is an error, then return it immediately, otherwise unwrap it.
```
error = struct(source: string, type: string, message: string, additional: string, nested_error: error)
```
golang defines it as an interface that has an `Error` method. but we don't have inheritance.
maybe with generics?
```
error = fn(T: type -> type)
{
    Result = struct (
        data: T,
        next: Result|nothing
    )
    Result
}
```
or maybe we can use type:
`error = struct(code: type, data: string, nested_error: error)`
it we want to have a dedicated operator, maybe it makes sense to have dedicated struct too.
a struct that has a type, so client can use compiler tools to make sure it is checking correctly.
`saveData = fn(... -> int | float | InvalidArgumentException | FileNotFoundException)`
and we have:
`InvalidArgumentException = struct(error: error, ...)`
`FileNotFoundException = struct(error: error, ...)`
`x = @saveData(1,2,3)` now x will be `int|float`
how do we define an exception that is gonna be filtered by `@`?
if it is a type with name ending with `Exception` or `Error`? not two options. 
Error is more general.
**PROPOSAL**
1. An error type is any named type that ends with `Error`
2. `@` operator works like `@expression` and if expression is an error type, returns it immediately. otherwise unwraps it.

Maybe we can also allow changes with `@`
`x = saveData(1,2,3)@[FileError: fn...`
or maybe allow for a log or some other code. no change in the error, just log sth.
`x=saveData(1,2,3)@fn(x: FileError|EmptyError ->){...}` 
after `@` we can have a lambda. it will be called if it can accept the error.
no this is too much.
but still we need a notation that can be mixed
e.g. `@f(@x, @y...)`
`@x+@x`
`@x.field` -> what is precedence of `@` vs dot?
it is confusing to some extent but so it `+` in `1+x.t` which comes first?
but still it is a bit confusing. the concept of early return, hidden inside an operator.
e.g. what if I pass a lambda which has this?
```
data = sortData(items, fn(x:int, y:int -> int) { @process(x) + @process(y) }
```
above means that the lambda can also return an error. 
so, sortData may return that too! even though it is not aware of that.
sortData is a function with output of type `[int]`
so it has no idea about errors. 
but it should. if not, then error becomes an invisible thing that is hidden from developer eyes.
he sees a fn that returns an int, but it might also return other errors.
another issue: we may need to re-shape error. 
e.g. if divisionByZeroError has happened, I don't want to return it to caller, but I want to return InvalidArgError.
```
x = saveData(1,2,3)@  //this will return in case of error, without any change
x = saveData(1,2,3)@SaveError(name: "A", type: "B", ...) //in case of error, return SaveError
```
q: how can I access the original error after `@`?
q: this will reduce mixability.
if we treat it like a fn, it can also cause confusions, but otoh above will be easy to achieve.
`[]` is for seq and map and is already overloaded with semantics
`{}` is supposed to only be for functions
`<>`?
something that is not like a function but explicitly determines the scope will be good.
`[[...]]`
maybe we can embed this in function call.
```
int_var = processData(1,2,3,4){}
int_var = processData(1,2,3,4){ code to run if error happened result of which will return, like a catch }
int_var = processData(1,2,3,4) {
	
}
```
no new notation! but still we need a notation to refer to the error from previous call.
```
int_var = processData(1,2,3,4) fn{ //function with no input and output inferred from code
	
}
```
if we put `fn{ ... }` in front of the call, then it will catch all errors.
if we put `fn(x:int->int)` it will be called only if output is of type int.
but this is too much flexibility which means too many moving parts -> lots of cases for orth.
we should limit it so that it can be used only as much as absolutely needed.
`int_var = processData(1,2,3)@MyError(code: "Err", message: "Error processing", source: _)`
still confusing. what if I put a dot at the end? is it applied to `MyError`? or the whole thing?
`int_var = @(processData(1,2,3), fn(x: MathError -> SaveError) { ...}, fn(x: IOError -> SaveError) { ... })`
we have two error handler functions above.
but we should be this simpler. no multiple fns. only one fn. no input. output is inferred:
`int_var = @(processData(1,2,3), fn{...})`
`int_var = @[processData(1,2,3) fn{...}]`
what if we don't want to make any changes?
`int_Var = @[processData(1,2,3)]`
ok. let's use `{}` for this.
`int_Var = @{processData(1,2,3)}` in case of error, return the error without any change
`int_var = @{processData(1,2,3) fn{...} }` 
still I wish it could be simpler.
we want sth that:
1. is composable
2. visually has borders
3. allows you to just return error or return sth else using your code
`int_var = processData(1,2,3)@`
example: a web server during start up wants to set up a socket with specified port.
if port is already in use, an error will be given to web server. now what should web server do with that?
```
socket = openSocket(port_number) //now if socket is already in use, I want to first log it and then return InvalidPort
```
but whoever throws the error should log it. not the higher level.
this operator encourages people to ignore errors which is bad. so we should be very careful.
it should do the minimum which is absolutely needed. anything else: just do it the normal way
we can resolve the need to change by having just one error type.
so `error` becomes a core type. defined in core but not built-in
`error = struct (source: string, message: string, extra: string, parent: error)`
`socket = @openSocket(port_number)` this will create a new child for error, automatically set its attributes and set its parent to 
the error returned from openSocket function and return the result.
`error = struct (type: string, source: string, message: string|nothing, cause: error)`
sometimes we need to actually do sth based on the error type.
for example if it is http404 we should exit but if it is xyz we should retry.
so we need a type that uniquely determines the error.
string is also ok but:
1. it is not guaranteed to be unique
2. it is difficult for compiler/ide to provide services before runtime. like code completion or making sure exception type is correct.
but we said type, must be compile time! now, how can I use runtime variables of type type?
`error = struct (key: type, message: string|nothing, cause: error|nothing)`
`socket = @openSocket(port_number)` this will return error if any and immediately exit current function
now, what if I want to return an error of type X if any error has happened?
`socket = @{MyErrorType}openSocket(port_number)`
if openSocket returns an error, a new error will be returned which wraps that error, with this new type: MyErrorType
`socket = @{MyErrorType, "This is my error messsage"}openSocket(port_number)`
can this be more elegant?
`socket = @{error(MyErrorType, "My message", _)}openSocket(port_number)`
`socket = openSocket(port_number)@error(MyErrorType, "My message")`
it makes more sense to have the notation "after" function call, not before it.
`socket = openSocket(port_number)catch(error(myErrorType, "My message"))`
`socket = openSocket(port_number)throw{error(myErrorType, "My message")}` {} is confusing because people will think it is a code block
`socket = openSocket(port_number)@myErrorType("My message")`
`socket = openSocket(port_number)@`
`result = expression@`
`result = expression@CustomErrorType`
or maybe we can create the error instance:
```
err = error(type: MyErrorCustom, message: "This is my error")
result = expression@     //return the generated error
result = expression@err  //return this value in case of error
result = expression@MyErrorCustom  //wrap generated error in a new error of this type
```
**PROPOSAL2**
1. There is a new core type: `error = struct (key: type, message: string|nothing, cause: error|nothing)`
2. You can append an expression with `@` to indicate, if error happened, exit immediately and return the error as result
3. `@` can be suffixed with a type or value to determine error type
a nice advantage of this is that we can have early return with any type. because who can limit us to use a value of type `error` after `@`?
`result = fnCall(1,2,3)@nothing`
lets remove the case where we can specify a type after `@`. it is doable with `@err` model and if you're really interested in short code then just use `@`.
**PROPOSAL2**
1. There is a new core type: `error = struct (key: type, message: string|nothing, cause: error|nothing)`
2. You can append an expression with `@` to indicate, if error happened, exit immediately and return the error as result
3. `@` can be suffixed with a value to determine return value. if it is of `error` type, compiler will automatically set its `cause`.
why a value? why not an expression?
`result = fnCall(1,2,3)@makeError(4,5)`
**PROPOSAL2**
1. There is a new core type: `error = struct (key: type, message: string|nothing, cause: error|nothing)`
2. You can append an expression with `@` to indicate, if error happened, exit immediately and return the error as result
3. `@` can be suffixed with another expression to determine return value. if it is of `error` type, compiler will automatically set its `cause`.
this can be easily used for any kind of validation which is primary use for early return.
set up a validation function which returns error if data is invalid.
like `nothing` we should have something like `err` as a no-op error instance to be used for quick cases.
or maybe use `error` itself.
in case you want to compose values using `@` you can use this:
`result = process(1,2)@ + process(3,4)@`
`result = process(1,2)@nothing + process(3,4)@nothing`
what if the result is a function?
`data = process(1,2)@getData(11)()` now, does getData return a function which we call and produce error value for process call?
or maybe process returns `error|fn` and here we want to call the function?
lets use `@[...]`
`result = process(1,2)@ + process(3,4)@`
`result = process(1,2)@[nothing] + process(3,4)@[nothing]`
**PROPOSAL2**
1. There is a new core type: `error = struct (key: type, message: string|nothing, cause: error|nothing)`.
2. we also have a value `error` of error type which is a no-op error.
3. at operator is used like these: `expression@` or `expression@[expression]`
4. if left hand side expression resolves to an error, it will be returned (first case) or result of expression will be returned.
problem: what if result of expression is a seq or map itself? then this notation will be confusing.
maybe we should use `{}`.  we don't use fn prefix so it won't imply this is a function.
`result = process(1,2)@ + process(3,4)@`
`result = process(1,2)@{nothing} + process(3,4)@{nothing}`
**PROPOSAL2**
1. There is a new core type: `error = struct (key: type|nothing, message: string|nothing, location: string|nothing, cause: error|nothing)`.
2. we also have a value `error` of error type which is a no-op error.
3. at operator is used like these: `expression@` or `expression@{expression}`
4. if left hand side expression evaluates to an error, it will be returned (first case) or result of expression will be returned.
5. if expression we return resolves to an error, it will be bound to original error through `cause` field. also location field is auto-populated via compiler/runtime.
===
rather than allowing users to create error types with any invalid value they want, we should provide a core function for this.
they only need to specify type and message. other fields can be auto-populated. or we can set this rule that, you cannot set a value for location and cause.
and type? so it will be only message. but type is setable by user because they know the actual exception type.
no lets leave it like that and don't add a new exception/rule to the language.
can this be simpler?
I can write `error@` to immediately exit and return error
or `error@{5}` to immediate exit and return 5
can I write this: `x = divider(5, _)@{0}`?
so if divider returns error it will return 0?
no. left hand side expression is a lambda. 
I should write a proper function like this:
`x = fn(a:int->int) {  divider(5,a)@{0} }`
still people can misuse this: they can create a fn that returns error if sth is false.
then: `checkWithError(cond)@{-1}` so if cond is false, function will return -1 immediately
almost anything can be misused.


N - (this is broken into multiple sections coming after this section)
We should provide some sane defaults and compiler helps for union types. 
so that stuff like map of key to functions of different types becomes better handled.
If all options of a union have sth similar, can we use it without union dereferencing?
for example if they are all functions that have no input but have different outputs.
rather than a map of `T` to `fn(T->U)` for example, we can have these as a list.
this can make things less complicated.
but how do we define that list?
`MagicList = struct ( T: type, data: T, handler: (T->U), next: MagicList|nothing)`
type of next, is MagicList of any type. we don't care. 
this is fine for saving data or putting data there.
but what about reading data from a magic list?
suppose that I have `x: MagicList`, what can I do?
`if x.data is of type G then call handler with this value and get U`
but we don't have any idea what will U be. so how can we save U?
`MagicList = struct ( T: type, U: type, data: T, handler: (T->U), next: MagicList(?, U)|nothing)`
now, `MagicList(?, U)` means magicList of some type that I don't care about and U which is same as U I have here.
lets continue with an example. what are examples: vtable, match for union
```
vtable = [Circle : drawCircle, Square: drawSquare]
Vtable = struct(type: T, handler: fn(T,Canvas, float -> int), next: Vtable(?))
shapesTable: Vtable = (type: Circle, handler: drawCircle, next:
				(type: Square, handler: drawSquare, next:
					(type: Triangle, handler: drawTriangle)))
					
findHandler = fn(table: Vtable, T: type -> fn(T, Canvas, float -> int)|nothing) {
	if ( T == table. type ) then return table.handler
    else return findHandler(table.next, T)
}
```
this does not allow to treat all union options the same, though.
another example: match for union types
```
matchUnion = fn(data: ?, branches: Branch(U) -> U)...
Branch = (T: type, handler: (input: T -> U)
```
but then I will need to define types for each match or vtable that I need!
too cumbersome and error prone.
what if I had a feature that having a value of type T (which I don't know at compile time), and a list of functions that accept one input of type X and have same output int,
I can find appropriate function based on T and call it and get the result?
first q is, how can I store a list of functions that accept different types? 
in other words, how can I store a list of bindings of different type? different in some part but have similarities too.
what about a list?
`list: [fn(T->int)]`
why a list? this breaks a lot of assumptions. I cannot define type of this properly.
we want a super-function.
it binds multiple different but similar functions.
upon calling the super function, one of its children will be called.
this is determined at runtime.
type of super-function represents common parts + using generic for the different part.
for example: we have drawCircle, drawSquare and drawTriangle functions.
what if I want to have a function like `draw` that can accept any of these?
```
draw = fn(shape: T, canvas: Canvas, arg: float -> int ) {
    (shape)${
        drawCircle(_, canvas, arg),
        drawSquare(_, canvas, arg),
        drawTriangle(_, canvas, arg)
    }
}
```
so notation is: `my_struct${lambda1, lambda2, lambda3, ...}`
and lambdas should all accept my_struct.
the one which has a matching type with my_struct will be invoked.
this is not composable.
we don't know the exact "type" of this expression.
if sth doesn't have a "type" it is not good. not orth/composable/...
so we have types for each of those functions. but we don't have a type for all of them collectively (except for a convoluted union type).
- In Haskell ad-hoc polymorphism is achieved through typeclasses 
- Typeclasses are a mechanism for overloading the meaning of names (values and functions) for different types.
when I say a function's input is of type of a typeclass, it means that that input can be of any type that satisfies that typeclass.
meaning that input is of type T where T supports the function that is defined in the typeclass so I can easily invoke that function.
for example I can define Num typeclass with `+-*/...` operators as list of functions it has.
then I can say `Point` is a Num and implement all above for a Point.
typeclass desribes behavior we expect a type has. each type implements that behavior in its own way
with example of Person and Employee for inheritance in oop, we can define Person as a typeclass and implement it for an Employee:
```haskell
class Person a where
  firstName :: a -> String
  lastName :: a -> String
  age :: a -> Int
  getFullName :: a -> String
```
now, we can define a typeclass for drawing. then implement it for Circle, Square, Triangle, ...
```
class Shape
    draw :: T -> string
    
drawCircle = fn(c: Circle -> string) ... implemented for Shape
drawSquare = fn(s: Square -> string) ... implemented for Square
```
Or we can define `Ord` typeclass and use it as argument type in sort function.
Or `Stringer` typeclass which gives you string representation of a type. then use it in print function.
or a find function where it looks up a value in a seq, needs to be sure type of that value is "comparable".
a `Bounded` typeclass, assures you the type that implements it has two functions defined: min and max which give min and max possible values
we need 3 concepts:
1. how to define a typeclass?
2. how to implement typeclass TC for type T?
3. how to use typeclass in a function?
3 is easy. we can use `type + TypeClass` for declaration in function args.
for example for shapes:
```
#1 define typeclass
typeclass drawShape = fn(shape:T, c: Canvas, f: float, T: type -> string)
implement drawShape for Circle as drawCircle
...
process = fn(item: T, T: type+drawShape -> ...) {
...
str_value = drawShape(item)
}
```
above example is also doable with function lambda.
but what if have a seq of shapes?
```
renderScnee = fn(item: [T], T: type+drawShape -> ...) {
...
str_value = drawShape(item)
}
```
we can think of typeclass as an interface. we need to implement interface for all of the types that need it.
then when in use, we say function has an argument of that interface type.
so its not generic.
```
process = fn(item: Shape, c: Canvas, f: float -> int) {
    drawShape(item, c, f)
}
```
q: What if I want to have different implementations of a typeclass for the same type? and use them based on the situation?
under the hood Haskell is using a dictionary of functions. key is type, value is function. this becomes sth like a vtable.
why not use the same?
a good question is: How can I write a generic printf function?
similar to interface, rather than declaring X is of interface type, we can say X is `T`, and provide functions to work with it separately as pointers
two advantages of typeclass:
- can be used with multiple different types in the same function. for example a sequence of shapes
- can be extended easily. if you have a new type, just implement typeclass for that new type and you automatically have that typeclass for your type.
simplest example: `toString` in `printf`.
we need a convert function for all types. they cannot have the same name.
and we don't want to use a convention.
`printf` is a function that accepts any value and writes it to stdout as a string.
now, printf is an easy function assuming we have the toString for all types. 
`printf = fn(x: T, T: type -> nothing) { writeToStdOut(toString(x)) }`
now we can have this:
`printf = fn(x: T, toString: fn(T->string)) { writeToStdOut(toString(x)) }`
but:
q: what if we have multiple inputs? for example a printf with `n` arguments? or a sequence?
q: can it be automated enough so i dont have to repeat function names, and flexible enough so that I can feed my own (new) functions?
in java I write:
`void printf(ToStringSupported x) { writeToStdOut(x.toString()) }`
let's say, we use a real dictionary method but it can be either manually built or use the default, but this default should not be a hidden/implicit default.
that global dictionary has all default methods. if you need, you can modify a copy of it and change the handler(s) you want.
but, we are an immutable language. how can we have this?
one solution: define separate functions with different naming but similar syntax. mark them with a tag.
then use core to get a dictionary of all functions with that tag.
or even drop the dictionary. just use core to call it.
this is essentially dynamic dispatch.
```
$toStrTag
toStringInt = fn(x:int -> string) { ...}
$toStrTag
dasdsadsa = fn(x:float -> string) { ...}
...
printf = fn(x: T, T: type -> nothing) {
    str1 = invoke($toStrTag, x)
    ...
}
```
problem1: it is not typed.
```
ToStrTag = fn(x: T, T: type -> string)

$toStrTag
toStringInt = fn(x:int -> string) { ...}
$toStrTag
dasdsadsa = fn(x:float -> string) { ...}
...
printf = fn(x: T, T: type -> nothing) {
    handler: fn(x: T, T: type -> string) = lookupFunctions(ToStrTag, T) //among all functions with this tag, find the one that matches with x of type T
    str1 = handler(x)
    ...
}
```
now, it is typed. the only loose part is `lookupFunctions` which it the core function.
q: what if we have multiple (and related) types?
q: `lookupFunctions` is a super-function. it is not a normal function. maybe it should be replaced with a notation.
examples for this:
- toString
- getHashCode
- isEqual
- drawShape
- compare
- getMinValue
- getMaxValue
- NumericAdd
- NumericMultiply
- Convert (this one has two types)
Let's continue with printf example:
```
ToStrTag = fn(x: T, T: type -> string)

//if function definition does not match with ToStrTag, compiler will complain
//if two function definitions have overlap, compiler will complain
toStringInt: ToStrTag = fn(x:int -> string) { ...}

dasdsadsa: ToStrTag = fn(x:float -> string) { ...}
_: ToStrTag = fn(x:Customer -> string) { ...}
_: ToStrTag, fn(Client->string) = fn(x:Client -> string) { ...}
...
printf = fn(x: T, T: type -> nothing) {
    #you can define your own local overrides here
    myFunc: ToStrTag = fn(x:int -> string) {...}
    //lookup a function of type ToStrTag (first local scope, then outer scopes) 
    //that can accept x as input
    str1 = &ToStrTag(x)  //among all functions of this type, find the one that matches with x of type T
    ...
}
```
`&` without `(x)` makes no sense. 
maybe it should be like `ToStrTag&(x)` so people don't assume they can write `&ToStrTag` alone.
the only big issue is this part: `toStringInt: ToStringTag = ...`
does this make sense?
`dasdsadsa: ToStrTag = fn(x:float -> string)`
left side says, type of this binding is a function of T to string. but right side is not generic.
maybe we can write this:
`dasdsadsa: ToStrTag(int) = fn(x:float -> string)`
now this makes complete sense because based on everything we have in the language, it is a correct expression.
and when I write `str1 = ToStrTag&(x)` it means, based on type of x, find appropriate function and call it.
```
ShapeRender = fn(T: type -> type) { fn(shape:T, canvas: Canvas, arg: float, T: type -> int) }
drawCircle: ShapeRender(Circle) = fn(c: Circle, canvas: Canvas, arg: float -> int) {...}
drawSquare: ShapeRender(Square) = ...
drawTriangle...
...
shape = getShape()
ShapeRender&(shape) //shape can also be a union, runtime will find appropriate function to call and call it
```
q: what if nothing is found? will it be a runtime error?
a: it should be a runtime error. compiler will check most of the cases, but anyway, if not there it is like calling a method on a child class which is not implemented.
q: can I use union of type classes to look up into functions of both types?
a: what comes before `&` is a gneric type. so, in principle this should be possible but what is the use case?
if I have `V=T|U` type as generic, then `V&(args)` will consider functions of tag T or U.
q: is it possible to assign a new type class to an existing code? for example function is in a lib I cannot change.
a: yes. you can write a wrapper
```
#assume we have libFunc
myFunc: ToStrTag(CustomClient) = fn(x: CustomClient -> float ) { libFunc(x) }
#then:
result = ToStrTag&(myClient) #this will call myFunc which will call library function
```
so, what should we call this? type class is to Haskelly. interface is too OOP.
- polyfunction
- superfunction
- multi-function
- supergeneric function type
do we need a new name? It is just a type. like other types. it is generic and it points to a function.
there is nothing special about it, at least when we define it.
1 - define a generic function type: `ToStrTag = fn(T: type -> type) { fn(x: T, T: type -> string) }`
2 - when declaring functions, mark their type based on above type: `intToStr: ToStrTag(int) = fn(x: int -> string) { ...}`
3 - when needed, use `Type&(...)` notation to call a function from above group.
this can be used for hash, equality, tostr, conversion, ordering, polymorphism and lots of other use cases.
expression problem: for shapes and drawing them.
- if we add a new operation: just write their functions and types.
- if we add a new shape (e.g. Oval), just write functions for it.
lets find a good name for these. these generic fn types are created with a purpose.
these are not functions. they are "types" and they are generic.
- signature type
- prototypes
- tag
- annotation
"type signature" or "signature type"? seond one makes more sense.
**PROPOSAL** 
**Signature Types**
1. Signature types are generic function types that can be used to group multiple functions matching with their signature.
example: `ToStrSignature = fn(T: type -> type) { fn(x: T, T: type -> string) }`
2. any matching function, will need to be explicitly marked as having the signature type. Note that named types are never equal to underlying types.
example: `toStringInt: ToStrSignature(int) = fn(x:int -> string) { ...}`
3. you can use `&` to invoke any of child functions matching with a signature type and pass required arguments.
example: `str_val = ToStrSignature&(int_var)`
4. this is like interfaces in Java but with only one function per interface
==
still we have an issue with printf. how can we have multiple args of different types? not easily. 
it can have a sequence of strings.
the only issue is we treat a fn-type like an actual fn. but is can be justified by `&` usage and advantages that it will have.
q: can we have a signature with multiple types?
when we invoke, we only invoke one function.
the only advantage is to group multiple related functions.
for example `Num` typeclass in Haskell has all num-related functions like add, divide, ...
also another advantage is we can write a function generic on type T, and declare that type must satisfy all those functions.
q: how can we declare function needs `T` matching with a signature?
we don't always do that. client function doesn't have to be generic. it can be on anything.
but consider shape example:
```
ShapeRender = fn(T: type -> type) { fn(shape:T, canvas: Canvas, arg: float, T: type -> int) }
drawCircle: ShapeRender(Circle) = fn(c: Circle, canvas: Canvas, arg: float -> int) {...}
drawSquare: ShapeRender(Square) = ...
drawTriangle...
...
process = fn(shape: T, T: type ...) {
    ShapeRender&(shape)
}
```
this is all good, but is there a way to say `T` must satisfy `ShapeRender` signature?
```
process = fn(shape: T, T: type ...) {
    ShapeRender&(shape)
}
```
if caller function is generic, compiler will do the check during code generation step.
if it is not, compiler knows types of everything. so it will be one single type T or a union of multiple types (T1, T2, ...)
now, if we have ShapeRender for T (or for T1, T2, ...) then it is fine.
otherwise, compiler will throw an error.
so runtime error will not happen.
but still the user of my function, will not know what they need to implement.
if they call `process` function above, they need to first implement `ShapeRender` function for their type. 
but that's fine. author can add that to the documentation, also they can rely on compiler errors.
but on the plus side, langage will not be polluted.
right now, the only "actual" change in notation is `&()` call notation.
if there are multiple candidates for a signature call, we can override by defining a local function. they have higher priority.
some more examples:
```
Eq = fn(T: type -> type) { fn(a: T, b: T, T: type -> bool) }
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
abcd = fn(a:int, b:int -> bool) ...
```
even if we don't mention signature type, the type of function matches with signature. 
so, during runtime, how can we find out signature children? we can do this at compile time and provide choices at runtime.
but in above, there should be no difference between `intEq` and `abcd` functions.
so, why should a call to `Eq&` pick intEq and not abcd?
the point is, named types are never equal to anything else.
so `Eq(int)` and `fn(int,int->bool)` are two different types! even tough they have same type and input and output.
```
lookup = (data: T, source: [T], T: type -> int|nothing) {
	foreach(source, fn(item:T-> boolean) {
        if(Eq&(source, data)) then return true;
    })
}
```
so: re union issue we can write this:
```
int_or_float=getData()
handler1: NumHandler(int) = ...
handler2: NumHandler(float) = ...
result = NumHandler&(int_or_float)
```
can I write this? `Eq&(int_var, _)`? in this case you can because `int_var` is enough to for compiler/runtime to find type needed.
but `ShapeRender&(_)` is not valid. because without an input, we don't have anything.
we may still want to have a "fallback" implementation. for example for toString, if it is not implemented for some type, we don't want to exit app. just return some fixed string.
we can use `nothing` for this purpose.
```
ToStrTag = fn(x: T, T: type -> string)
toStringInt: ToStrTag = fn(x:int -> string) { ...}
dasdsadsa: ToStrTag = fn(x:float -> string) { ...}
fallback: ToStrTag(nothing) = fn(x: nothing -> string) { ... }
...
str_value = ToStrTag&(my_customer) #not found -> call ToStrTag(nothing)
```
basically, `T&` will give you all functions that implement generic type T (which can have one or more generic arguments).
`T&(...)` will invoke the one that matches with input args provided.
lookup:
- local function
- parent functions in order
- local module
- imported modules in order
but then it will be too opaque. you won't be able to tell, exactly which function will be resolved when for example you call `ToStr&(int_var)`
lets do something else: 
- local function
- parent functions
- local module
- all the scope
if at any stage found one -> use it
if found multiple -> error
if not found anything -> try `nothing`, if not found runtime error
other examples of typeclass/interface:
- iterable: when you want to iterate oversomething which is not seq
q: can I define signature for a group of types? for example all seq? or all Stacks of any type?
e.g. equality for stack of T is equality of Ts of both stack
```
Eq = fn(T: type -> type) { fn(a: T, b: T, T: type -> bool) }
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
Stack = fn(T: type -> type ) { struct (data: T, next: Stack(T)) }
intStackEq: Eq(Stack(int)) =  fn(a: Stack(int), b: Stack(int) -> boolean) ...
stackEq: Eq(Stack) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...
```
does this make sense? `Stack`? is it a type? if so, we should be able to use it elsewhere.
`stackEq: Eq(Stack)` should mean, this function is implementation of `Eq` signature for all Stacks regardless of their generic type.
can I use `Stack` type in another function?
for example: `process = fn(x: Stack, y: data ...)`
if we allow above, this should also be allowed, which means any stack of T and we don't care what T is.
this is like interface: if I have toString interface, can I implement it for a `Stack<T>` in Java?
yes. I can easily add `implements ToString` to the definition of `Stack<T>` class and write the code.
what about this?
`stackEq: Eq(Stack(U: type)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...`
q: what is type of this? `x = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...`
is it `fn(Stack(T), Stack(T) -> boolean)`?
lets say `Stack` represents all stack types regardless of their generic type.
so we can use it as an input of any function. of course that function does not care about internal type of stack. if it did, it had to include a generic type.
`len = fn(s: Stack, ...`
then we can implement `Eq` for all Stacks like this:
`stackEq: Eq(Stack) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...`
But this is a very important distinction. In haskell we can write:
```
instance Functor Maybe where
  fmap _ Nothing = Nothing
  fmap f (Just a) = Just (f a)
```
so fmap typeclass for `Maybe<T>` can have different results based on the value. if it is nothing, then result is nothing. otherwise it is calculated using given function.
so can we write `nothingHandler: Functor(nothing) = fn...`
and `somethingHandler: Functor = fn...`?
that should be fine. but where is the function `f` in Haskell's code when we write `f a`?
Functor applies a function on something. if that something is nothing then result is nothing. otherwise f is calculated. 
for example f can be `+1`
```
Functor = struct(data: T, map: fn(mapper: fn(T->R) -> Functor(R)))
```
maybe we should get rid of functors and keep it simple. because functor is a combination of interface and struct.
we have a limited interface support via type signature but it is just a function, not struct.
Also it looks like functor are merely lambads with pre-set stats: `process(5,_)`
so back to first question: Assuming I have a type signature, how can I define it for a generic type?
for example, implement equality for Stakcs.
option 1: force user to implement it for each concrete type
option 2: `stackEq: Eq(Stack(U: type)) = ...`
option 3: `stackEq: Eq(Stack) = ...`
option 2 is a completely new notation.
option 3 is a huge change but not sth new.
so if we have: `Converter = fn(T: type, U: type -> type) ...`
then `Converter` is a type, `Converter(int,_)` is a type.
but not including types is confusing. Converter is supposed to have always two type arguments.
so maybe we can use place-holder for that. meaning we don't care. just like assignment placeholder.
`x: Stack(_)`
`y: Converter(int, _)`
```
Eq = fn(T: type -> type) { fn(a: T, b: T, T: type -> bool) }
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
Stack = fn(T: type -> type ) { struct (data: T, next: Stack(T)) }
intStackEq: Eq(Stack(int)) =  fn(a: Stack(int), b: Stack(int) -> boolean) ...
stackEq: Eq(Stack(_)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...
len = fn(x: Stack(_) -> int) ...
```
and this can be used to implement vtable!
```
Vtable = struct(type: T, handler: fn(T,Canvas, float -> int), next: Vtable(_))
shapesTable: Vtable = (type: Circle, handler: drawCircle, next:
				(type: Square, handler: drawSquare, next:
					(type: Triangle, handler: drawTriangle)))
Draw = fn(shape: T, c: Canvas, f: float -> int)
drawCircle: Draw(Circle) = fn(shape: Circle, c: Canvas, ...
drawSquare: Draw(Square) = ...
...
x = Draw&(my_shape)  #runtime call resolution
y = Draw&(my_circle) #compile time call resolution
```
but we should formalize this notation a bit more. is it a union? is it a compile time thing or runtime?
**PROPOSAL: Signature Types**
1. Signature types are generic functions. These are similar to Java interfaces that have only one function.
example: `ToStrSignature = fn(T: type -> type) { fn(x: T, T: type -> string) }`
2. To define a child function of a signature type, you should define a concrete function with same signature and explicitly set its type. This is similar to implementing an interface in Java. Note that named types are never equal to underlying types.
example: `toStringInt: ToStrSignature(int) = fn(x:int -> string) { ...}` this defines a child for `ToString` signature for `int` type.
3. You can use `&SignatureType(args)` notation to invoke a child functions matching with a signature type and pass required arguments.
example: `str_val = ToStrSignature&(int_var)`
4. We have the `Type(_)` notation which is a wildcard for a generic type and denotes all generic types regardless of their T type.
===
it would be good if the syntax could be more like a function. 
one option is to define that function:
```
Draw = fn(shape: T, c: Canvas, f: float -> int)
drawAnyShape: Draw(_) = Draw& #but then, what is type of drawAnyShape? remember: anything without a proper type, is an exception to the language
```
another option: tag the type definition with a function name (instead of `&` notation)
```
Draw = drawShape: fn(shape: T, c: Canvas, f: float -> int) 
```
if we use above notation, then `drawShape` will be a function we can invoke with a shape or union of shapes as `shape` argument (first argument) and it will redirect to the appropriate function.
but if we call it with `int`, then there will be a runtime error (or maybe compiler error) because we don't draw an int.
what if we do this for other stuff?
`Customer = x: struct(name: string, age: int)`
it makes no sense and there will be a compiler error
what if I use it with non-functions? not allowed.
this can only be used with generic function types.
and will represent all functions that are of that type.
(btw we dont need a fn define generic function. it is needed for data types)
```
Eq = isEqual: fn(a: T, b: T, T: type -> bool)
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
Stack = fn(T: type -> type ) { struct (data: T, next: Stack(T)) }
intStackEq: Eq(Stack(int)) =  fn(a: Stack(int), b: Stack(int) -> boolean) ...
stackEq: Eq(Stack(_)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...
...
bool_val = isEqual(var1, var2)
```
what is type of `isEqual`? can I pass it to another function?
separating the definition of the type/function and invoking it, causes confusion.
what if instead of defining a generic type, we define a generic function?
does `Eq = fn(T,T->bool)` make sense? this does not conflict with generics rules?
```
isEqual = fn(a: T, b: T, T: type -> bool)
isEqual(int) = fn(a:int, b:int -> bool) ...
Stack = fn(T: type -> type ) { struct (data: T, next: Stack(T)) }
isEqual(Stack(int)) =  fn(a: Stack(int), b: Stack(int) -> boolean) ...
isEqual(Stack(_)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...
...
bool_val = isEqual(var1, var2)
```
but having a function named `isEqual(int)` is confusing.
how can I bind a normal function like intEquals to a generic function like `isEqual`?
we make isEqual a type (and not a function) and then I ca define type of `intEquals` as `isEqual`.
```
Eq = fn(a: T, b: T, T: type -> bool)
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
Stack = fn(T: type -> type ) { struct (data: T, next: Stack(T)) }
intStackEq: Eq(Stack(int)) =  fn(a: Stack(int), b: Stack(int) -> boolean) ...
stackEq: Eq(Stack(_)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...
...
result = Eq&(var1, var2)
```
But `Eq&` is not an actual expression. so we cannot pass it to somewhere else.
can this become more explicit?
`result = Eq[var1, var2]`
no. looks like map/seq
what if we have a notation to look up function? and then we use it to call.
but it will be to verbose.
like: `result = Eq[var1, var2](var1,var2)`
or: `Eq.(var1, var2)`
or: `Eq(int)(var1, var2)`
or: `*Eq(int)(var1, var2)`
where `*` means find correct function implementation
`Eq(int)` specifies the type.
`*Eq(int)` means find the best function that is of type `Eq(int)`
this is a look up of function by type. can we generalize it?
lookup a function of type X and give it to me. of course I know the type and it is a valid type.
`Eq` is generic type.
`Eq(int)` is concrete type
`*Eq(int)` gives you a ptr to the function of that type (if exists)
`$Eq(var1, var2)` does above in one step.
`$Eq` is invalid in its own. you have to use `$Eq(int)` to find a function of that type.
and then call it: `$Eq(int)(var1)`
so I can pass `$Eq(int)` to another function because it has a valid type: `Eq(int)` or `fn(int, int->bool)`
and we can use a syntax sugar so: `$Eq(int)(var1, var2)` becomes: `$Eq(var1, var2)`
`$Eq(var1, var2)` will call a function of type `Eq(int).`
so I can pass `$Eq(int)` to a function to be used for int comparison.
also, if needed I can pass `Eq` itself (it will be a generic argument) and inside that function I can use `$T(arg1, arg2)` to have compiler/runtime automatically find correct implementation.
it is the other way around compared to java. In java we write interface, implement it and use implementations.
here we have interface but don't use implementations. we work with interface and runtime/compiler automatically finds correct implementation for us.
but: this will no longer support union types.
but it can.
we can say `$Eq(int|float)` will find a function for `int|float`.
but using the shortcut: `$Eq(int_or_float_var)` the if no function found for `int|float` it will look based on runtime type of the binding.
still confusing. not very simple.
problem: generic functions don't have a type.
this is against everything we have written with `Eq` and all.
```
Eq = fn(a: T, b: T, T: type -> bool)
intEq: Eq(int) = fn(a:int, b:int -> bool) ...
```
First line above is not ok. we cannot define a generic type with itself. we can define a generic function.
second line is also incorrect. because we don't have a generic type.
lets get back to the original problem: we want to have interface/typeclass support.
so that things like drawing a shape or converting something to string or getting hashcode of something would be easily done.
another usage: if we have a union of types, we should be able to call a function based on the type.
goals/requirements
1. support for runtime dispatch for union types
2. support for compile-time dispatch with generic argument
3. vtable-like implementation
but 3 is used to specify (for example) draw functions for different shapes and use it to find which function to call. which can be achieved using 2.
rather than `findHandler(my_vtable, T)(x,1,2)` we can write sth like `$DrawShape(x,1,2)`
so lets simplify 2. lets walk throught with a simple example: Equality check.
we want equality check for all of important types and then in a generic function based on `x:T` we can write `isEqual(x)` to invoke the appropriate function.
suppose all of the types we have are int and float and string
we want:
1. 3 functions for equality check for int, string, float
2. a notation to call something which resolves to one of above 3 functions. based on type of some input
basically, 1 is a map of type to function. but we cannot use an actual map because value type is complicated.
what about actually defining signature types as a type template for a number of functions:
```
SigEq = fn(a: T, b:T, T: type -> bool)
intEq = fn(a: int, b:int -> bool) ...
floatEq = fn(a: float, b: float -> bool) ...
stringEq = fn(a: string, b: string -> bool) ...
...
```
why not send the old function pointerr to where we need it? rather than using runtime/... to find correct function to call:
`process = (x: T, y: T, equalitChecker: fn(T,T->boolean) ...`
and what about other requirements? vtable maybe?
if we can do vtable, we will be able to (almost) easily do runtime dispatch using union value. we just need to get type at runtime.
vtable is essentially a map where value's type depends on key.
it is `[T: Handler(T)]` but T differs for each entry and each value has a type based on key.
this looks like "Dependant types"
basically we have a list of dependant pairs, where "type" of second item depends on the "value" of the first item.
so it is more like `[type: Handler(?)]`
ok. we can replace this with a function and put all the logic we need inside the function body. so we just call the function with common arguments and it handles everything.
so the only remaining requirement is: dynamic dispatch based on union type.
so if we have a generic function like `draw` and a binding of type `Circle|Square` I want to call draw function with actual runtime type of the union.
```
Circle = ...
Square = ...
Triangle = ...
draw = fn(shape: T, c: Canvas, arg: float, T: type -> int) ... #this works fine and is a generic function
..
x: Circle|Square|Triangle = readShapeData()
#now, how can I call draw?
draw($x, c, 1.1)
```
so `$` operator attaches to a union binding and unwraps.
what is type of `$x`? we don't know at compile time. it can be any of union options.
so, the only place we can use it is where any type is allowed: generic function
so I cannot write `y = $x` because then type of y is unknown.
we can write it like this: `${expression}` and it gives you unwrapped value of exp result (which should be a union, otherwise it is same as static type).
we prefer small, simple notation which are easy to comprehend, write and read.
what if we need different impl for different types? we can do it via a map in the generic function.
```
Circle = ...
Square = ...
Triangle = ...
drawCircle ...
drawSquare ...
drawTriangle ...

draw = fn(shape: T, c: Canvas, arg: float, T: type -> int) {
    [
      Circle: drawCircle(shape, _, _),
      Square: drawSquare(shape, _, _),
      Triangle: drawTriangle(shape, _, _)
    ][T](c, arg)
}
..
x: Circle|Square|Triangle = readShapeData()
#now, how can I call draw?
draw($x, c, 1.1)
```
but this won't work. because `drawCircle(shape, _,_)` should throw compiler error if we call `draw` with a Square. 
another option: write a generic function, write implementations of it for concrete types with same name. runtime will handle everything else.
```
Circle = ...
Square = ...
Triangle = ...
drawCircle  = fn(shape: Circle, c: Canvas, arg: float, T: type -> int) ...
drawSquare  = fn(shape: Square, c: Canvas, arg: float, T: type -> int) ...
drawTriangle  = fn(shape: Triangle, c: Canvas, arg: float, T: type -> int) ...
draw = fn(shape: T, c: Canvas, arg: float, T: type -> int) { drawCircle, drawSquare, drawTriangle }
..
x: Circle|Square|Triangle = readShapeData()
draw($x, c, 1.1)
```
back to the first proposal: tagging for functions
```
$toStrTag
toStringInt = fn(x:int -> string) { ...}
$toStrTag
dasdsadsa = fn(x: string -> string) {...}
...
```
option 1: tag concrete functions + call generic function with union
option 2: call generic fn with union + keep a map of type to handler
option 3: vtable (which is same as the map)
option 4: a match notation specifically for unions
```
draw = fn(shape: T, ca: Canvas, T: type -> int) {
    result = match ( shape ) {
        c:Circle -> drawCircle(c, ca),
        s: Square -> drawSquare(s, ca)
    }
    
    result
}
```
but the idea of tagging functions together is very interesting.
for example for Eq, we can tag all functions checking Eq for a specific type with a tag
- when we have a new object: Just implement the logic with that tag
- when we have a new operation, define a function with tag and implement for all types we need
```
eq = fn(a: T, b: T, T: type -> bool) {}
eqString$eq = fn(a: string, b: string -> bool) { ... }
eqNumber$eq = fn(a: int, b:int -> bool) { ... }
...
process = fn(data1: T, data2: T, T: type -> bool) {
    bool_result = eq(data1, data2)
    bool_result
}
```
notation for tagging a function?
`eqString_eq`
`eqString(eq)`
`eqString$eq`
q: should tab become part of function name? maybe not.
in java we write `public class EqString implements Eq` so class name is completely different
`eqString::eq`
`eqString eq = fn...`
`eqString: eq` no. this is super confusing, we expect a type after `:`
the notation should imply the separation of function name and tag name.
`eqString[eq]`
`eqString{eq}`
`eqString+eq`
can a function implement multiple tags? that will be very rare.
it is not like java, a class has n functions and each function can implement some interface.
but here we have just one function.
so lets assume a function can have only zero or one tag.
`eqString+eq` this read: `eqString which adheres to eq signature is defined as ...`
```
eq = fn(a: T, b: T, T: type -> bool) {}
eqInt+eq = fn(a: int, b:int -> bool ) ...
eqString+eq = fn(a: string, b: string -> bool) ...
...
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
}
```
1. any generic function can be a signature
q: what if signature fn has a body? that will complicate things. it must have an empty body
so:
signature fn definition -> normal except the fact that we don't return anything
impl fns: normal except `+eq` notation after fn name.
fn call: normal, we just call the signature function
now, what if input is a union?
still we will need `$` notation to unwrap:
```
bool_val = eq($int_or_string, $int_or_string2)
```
**PROPOSAL**:
1. Signature function is a generic function without body
2. you can implement signature function for any concrete type by defining a fn with compatible signature and add `+signature` to fn name.
3. when you call signature function, it will automatically be redirected to an impl based on argument type.
4. You can use `$union_val` to unwrap a union binding to its internal type.
===
the empty body is not very elegant. lets say they don't have a body.
but then it will become kind of opaque and hidden from the user. 
why not add a notation to do the redirection? in this way we may be able to do some common stuff too?
for example:
```
eq = fn(a: T, b: T, T: type -> bool) {
    a2 = preprocess(a)
    +eq(a,b)
}
```
this gives us some flexibility but at the same time increases complexity: we need a new notation for calling impl function.
lets just have no body. 
but we need some mechanism to make this explicit.
```
# $ for signature - like annotation in Java
$eq = fn(a: T, b: T, T: type -> bool) {}
$eq eqInt = fn(a: int, b:int -> bool ) ...
$eq eqString = fn(a: string, b: string -> bool) ...
...
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
}

bool2 = eq($int_or_string, $int_or_string2)
```
q: how can I implement eq for all stacks?
```
#this is like an interface, in interface there is no code or body, just definition
#so here we only define input and output
eq = fn(a: T, b: T, T: type -> bool)
eqInt :: eq = fn(a: int, b:int -> bool ) ...
eqString :: eq = fn(a: string, b: string -> bool) ...
eqStack :: eq = fn(a: Stack(T), b: Stack(T), T: type -> bool) ...
eqIntStack :: eq = fn(a: Stack(int), b: Stack(int) -> bool) ...
...
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}

bool2 = eq($int_or_string, $int_or_string2)
```
on one way, we want to make this explicit so we use `$` to visually differentiate this.
otoh we want this to be as least distruptive as possible so that we can re-use existing notations and concepts.
can we do `$` with a function?
```
unwrap = fn(a:T, T: type -> T)
unwrapInt :: unwrap = fn(a:int -> int) { a }
```
yes that is possible and we can say compiler will automatically implement this for all available types.
but does it make sense? I call unwrap with `int|float`. so it should be called with that type, not int, if the binding has an int.
so we still need `$`.
we also need sth to denote in a function that argument should have some signature
```
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
}
```
q: shouldn't `:: eq` be on the right side? because this is not about name of a function but about impl.
```
eqInt = fn(a: int, b:int -> bool ) :: eq ...
```
q: what about default impl? maybe that is what we can put instead of empty body
```
eq = fn(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn(a: int, b:int -> bool ) :: eq ...
eqString = fn(a: string, b: string -> bool) :: eq ...
eqStack = fn(a: Stack(T), b: Stack(T), T: type -> bool) :: eq ... #we dont write type after eq. compiler will infer
eqIntStack = fn(a: Stack(int), b: Stack(int) -> bool) :: eq ...
...
process = fn(a: T, b: T, T: type -> int) :: eq(T) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}

bool2 = eq($int_or_string, $int_or_string2)
```
`:: eq` means this function is implementing eq for a more concrete type. like int or `Stack(T)`.
`process = fn(a: T, b: T, T: type+eq -> int) {` so we can call `eq(a,b)`
`process = fn(a: T, b: U, T,U: type+convert -> int) {` so we can call `convert(a,b)`
or:
`process = fn(a: T, b: T, T: type -> int) ::eq(T) {` so we can call `eq(a,b)`
`process = fn(a: T, b: U, T,U: type -> int) ::convert(T,U) ::eq(T) {` so we can call `convert(a,b)`
second is better because it is more intuitive (`eq(T)` vs `T: type+eq`) and puts the dependency outside function header.
fn header is for defining input and output types and that should be it. signaturs we expect should be outside but still cannot be in the body as they are not code
q: maybe we should also put generic types outside fn decl?
`process = fn(a: T, b: T -> int) ::T ::eq(T) {` so we can call `eq(a,b)`
`process = fn(a: T, b: U -> int) ::T ::U ::convert(T,U) ::eq(T) {` so we can call `convert(a,b)`
lets discuss this point as another section.
**PROPOSAL**:
1. Signature function is a normal generic function (body is default implementation)
2. you can implement signature function for any concrete type by defining a fn with compatible signature and add `:: Signature` after fn header.
3. when you call signature function, it will automatically be redirected to an impl based on argument type.
4. You can use `$union_val` to unwrap a union binding to its internal type.
```
eq = fn(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn(a: int, b:int -> bool ) :eq { ... }
eqString = fn(a: string, b: string -> bool) :eq { ... }
eqStack = fn(a: Stack(T), b: Stack(T), T: type -> bool) :eq ... #we dont write type after eq. compiler will infer
eqIntStack = fn(a: Stack(int), b: Stack(int) -> bool) :eq ...
...
process = fn(a: T, b: T, T: type -> int) :: eq(T) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}

bool2 = eq($int_or_string, $int_or_string2)
```
===
using same notation for two different purposes is a bit misleading. 1. we are implementing this signature function, 2. we expect T to satisfy this signature function.
provide vs expect
in java: `implements X`, vs `item: X`
but here we can have multi-parameter signature function.
we have two concepts: provides/implements and expects
implements `:` expects `::`
if we can define a default body for signature function, why do we need to emphasise an expectation?
I mean, this is not so helpful for the compiler. it is only some kind of documentation for the user to know what they need to provide before calling this function.
rather than `::T` we should use `T:eq` or `T,U:convert` because it makes mose sense. we say `T:eq` which means T satisfies `eq` function.
and how can we mix these two? 
a function that implements a type signature but also has some generic arguments which need to be implementing some signature?
`test = fn(...) T:eq, U: eq, V,Z: convert, :signature1 { ... }`
and maybe we should make them more explicit by using something to surround them:
`test = fn(...) [T:eq, U: eq, T,V: convert, :signature1] { ... }`
`test = fn(...) [eq(T), eq(U), convert(T,U), :signature1] { ... }`
we should make order explicit: first signature you are satisfying then expectations:
`test = fn(...) :signature [eq(T), eq(U), convert(T,U)] { ... }`
so, any function call which uses generic type `T` must have a clause in `[]` section. otherwise it will be a compiler error.
**PROPOSAL**:
1. Signature function is a normal generic function (body is default implementation)
2. you can implement signature function for any concrete type by defining a fn with compatible signature and add `: Signature` after fn header.
3. when you call signature function, it will automatically be redirected to an impl based on argument type.
4. You can use `$union_val` to unwrap a union binding to its internal type.
5. You can also put a `[...]` clause after fn header to declare your expectations for generic argument.
```
eq = fn(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn(a: int, b:int -> bool ) :eq { ... }
eqString = fn(a: string, b: string -> bool) eq { ... }
eqStack = fn(a: Stack(T), b: Stack(T), T: type -> bool) :eq ... #we dont write type after eq. compiler will infer
eqIntStack = fn(a: Stack(int), b: Stack(int) -> bool) :eq ...
...
process = fn(a: T, b: T, T: type -> int) [ eq(T) ] {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
test = fn(...) :signature [eq(T), eq(U), convert(T,U)] { ... }
bool2 = eq($int_or_string, $int_or_string2)
```
===
it should be very explicit to know which signature does a fn implement. because now we are adding some kind of opaque processing.
when I call `eq` it may not call `eq` itself and it may call another function. so it should be very clear and explicit and easy to find and follow.
what about clashes? if we have to impls for one signature func?
can we do this for enums too? like having a function that accepts an enum and write impl for different enum values.
maybe we should explicitly mark if a function allows it to have impls. But this will mean restrictions on the coding side.
why not let them do whatever they want? of course we assume they know what they are doing.
q: can this cause infinite loop? if impl calls generic function? no. it will be a recursive call. it becomes infinite loop only if there is no condition to terminate recursion.
todo:
1. make it more explicit if a fn is impl a signature
`eqString = fn!eq(a: string, b: string -> bool) { ... }`
2. what about clashes: two same impls?
suppose that we have: `eqString = fn!eq(string...)`
and I import another module which has: `customStringCompare = fn!eq(string...)`
I prefer that, rather than adding a new notation during import or invoke, lets stick to the original rules of resolution.
if you want to override, define a module-local impl, that calls the actual function.
`myOverriderFn = fn!eq(string...) { customStringCompare }`
3. enums?
```
process = fn(a: int, day: WeekDay -> bool) { default impl }
processSaturday = fn!process(a: int, day: Saturday -> bool ) :eq { ... }
```
But `Saturday` is not a day. and also, enums have a fairly limited set of possible values.
NO.
4. what is order of resolution? this should be simple and well documented.
it should be same as finding a function. current fn -> current module -> imported modules
but wait, we cannot just call a function from imported module. 
`You can ignore output of an import to have its definitions inside current namespace.`
should we only look into these imported modules for a candidate or not?
5. can we write impl for a union typed argument of a signature function?
```
process = fn(x:int|float, ...)
processInt = fn!process(x:int ...
```
No. Lets not make things more complicated. the purpose of this signature types is providing a limited feature set for polymorphism.
6. problem is, when looking at a generic function, we have no way of knowing that it is supposed to have implementations.
and this makes reading code difficult.
`eq = fn!(a: T, b: T, T: type -> bool) { default impl }`
7. is it possible that `eqInt` implements `eq` and `eq` implements another function?
like `eqIntStack` implements `eqStack` which implements `eq`
`eq = fn(a: T, b: T, T: type -> bool) { default impl }`
`eqStack = fn:eq(a: Stack(T), b: Stack(T), T: type -> bool) { default impl }`
`eqStackInt = fn!eqStack(a: T, b: T, T: type -> bool) { default impl }`
this will be a source of confusion. which one should I say I implement? the top one (eq)? or nearer one (eqStack)?
we can say: you can only implement a signature type and `eqStack` is not a signature type.
signature functions have `fn!` in their definition.
**PROPOSAL**:
1. Signature function is a normal generic function (body is default implementation) but has `fn!` instead of `fn`
2. you can implement signature function for any concrete type by defining a fn with compatible signature and add `!signature` after fn keyword.
3. when you call signature function, it will automatically be redirected to an impl based on argument type, if not found, will run default the body.
4. You can use `$union_val` to unwrap a union binding to its internal type.
5. You can also put a `[...]` clause after fn header to declare your expectations for generic argument.
6. If there are multiple candidates for calling impl function, you can resolve the conflict by writing a module-local function and redirect to the correct impl.
```
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn!eq(a: int, b:int -> bool ) { ... }
eqString = fn!string(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = fn!eq(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
...
process = fn(a: T, b: T, T: type -> int) [ eq(T) ] {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
test = fn!signature1(...) [eq(T), eq(U), convert(T,U)] { ... }
bool2 = eq($int_or_string, $int_or_string2)
```
===
This has become too big: typeclass -> wildcard for generics -> tagged functions -> functor
lets break it up into multiple smaller pieces.

N - Can I define a named type inside a function?
no longer relevant.


N - support for wildcard for unions
this can be helpful with vtable implementation or signature types implementation for generic types
`Eq = fn(a: T, b: T, T: type -> bool)`
`stackEq: Eq(Stack(_)) = fn(a: Stack(T), b: Stack(T), T: type -> boolean) ...`
`Vtable = struct(type: T, handler: fn(T,Canvas, float -> int), next: Vtable(_))`
**PROPOSAL**
1. When specifying type of a binding, if it is a generic type and we don't care about the actual type value (we support every possible type) we can use `_` instead of the generic argument.
2. for example `Eq(Stack(_))` means binding is of type function which accepts two arguments of generic type `Stack(T)` but does not care about what T is. It can be anything.
I find this a bit confusing.
q: How do we address an binding of type of a generic function?
for example suppose that I have this:
`Handler = fn(T,T->string)`?
`process = fn(data: T, handler: Handler(T)?`
ok. IIRC we don't have a "type" for generic functions. we only have type for concrete functions.
so this is a valid type `fn(int->string)`
but `fn(T->T)` is not a valid type.
generic functions and data structures (which are also expressed via a generic function) are meta-functions. so they don't have their own type.
each of their implementation has a type though.
we no longer need it.

N - Shall we put generic type stuff outside fn header?
`process = fn(a: T, b: T -> int) ::T {`
if so we can then say generic type must be one letter capital and all other types must be more than one letter long
does this mean we will remove `type` keyword?
how does this work with concurrency, error handling?
what comes between `fn(...)` and `{` should be compile time checks.
q: if we remove `type` keyword, what will change?
q: how does this change data structures?
```
LinkedList = struct (
        data: T,
        next: LinkedList|nothing
    )
```
we can invoke a generic fn just like a normal fn and compiler will take care of checking argument types.
but we cannot do that with generic data structure.
if I want to create a new linkedList, I must specify type of its data.
what if a generic function accepts a generic fn? for example, sort needs a compare function.
`sort = fn(a: [T] -> [T]) [T] { ... }`
`sort = fn(a: [T], cmp: fn(T,T->int) -> [T]) [T] { ... }`
maybe we can say you can have at most 4 generics args: `T, U, V, X`
the problem is: we always have to repeat `T: type` and never pass it when calling a function. so what's the use of this?
this looks like a big change. lets not do it.

N - (discussed in another section) Use `[eq(T)]` notation to declare what a generic function expects from its generic type.
You can also put a `[...]` clause after fn header to declare your expectations for generic argument.
```
process = fn(a: T, b: T, T: type -> int) [ expects eq(T) ] {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
test = fn(...) [implements signature1, eq(T), eq(U), convert(T,U)] { ... }
```
- we may later also add functions to use inside `[]` to say: `T must be an array` or `T must be a struct with a field name`
or `T must be a struct compatible with this struct H` this last one is starting point for structural polymorphism and can be achieved compile time.


N - (explained in another item) How can I easily call draw functions for shapes based on value of a union binding?
`x: Circle|Square|Triangle`
`drawCircle, drawSquare, drawTriangle`
now, how can I call correct function based on runtime type of x?
what is the most 

N - Can we use the `process = fn(...) [eq(T)]` notation for data structures too?
e.g. we want set to only comparable types.
we can do the same for data structure. a generic data structure will look like a method. but it starts with a capiral letter so different from function.
```
LinkedList = struct(a: T, next: LinkedList(T)) [ type(T) ... ]
#when using:
x: LinkedList(int)
```
does not look intuitive. lets continue to use functions:
```
LinkedList = fn(T: type -> type) {
	...
}
```

N - Signature functions
1. Signature function is a normal generic function (body is default implementation) but has `fn!` instead of `fn`
2. you can implement signature function for any concrete type by defining a fn with compatible signature and add `!signature` after fn keyword.
3. when you call signature function, it will automatically be redirected to an impl based on argument type, if not found, will run default the body.
4. If there are multiple candidates for calling impl function, you can resolve the conflict by writing a module-local function and redirect to the correct impl.
```
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn!eq(a: int, b:int -> bool ) { ... }
eqString = fn!string(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = fn!eq(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
- we should not have default impl. having body for this generic fn is like having body inside interface.
- and don't use `!`. it is very different from other things. use `=0` instead of body.
- we can say after `fn(...)` there is a `[...]` section to describe compile time requirements on types.
- this section can also include whether this fn is implementing another fn.
- we may later also add functions to use inside `[]` to say: `T must be an array` or `T must be a struct with a field name`
or `T must be a struct compatible with this struct H` this last one is starting point for structural polymorphism and can be achieved compile time.
q: are these limitations part of value or type? if value, then we will have issue with generic data types.
if type then type assignment and comparison becomes difficult. 
but in Java it is part of type. when we write:
`static <K,V> Multimap<K,V>	filterEntries(Multimap<K,V> unfiltered, Predicate<? super Map.Entry<K,V>> entryPredicate)`
all above items are part of function type.
so:
**PROPOSAL: Signature functions**
1. Signature functions are generic functions without body (`=0` instead of body) and are like Java interfaces (A).
2. you can implement signature function for any concrete type by defining a fn with compatible signature (B)
3. when you call signature function, it will automatically be redirected to an impl based on argument type. (C)
4. If there are multiple candidates for calling impl function, you can resolve the conflict by writing a module-local function and redirect to the correct impl.
```
#A
eq = fn(a: T, b: T, T: type -> bool) = 0

#B
eqInt = fn(a: int, b:int -> bool ) [implements eq] { ... }
eqString = fn(a: string, b: string -> bool) [implements eq] { ... }
eqStack = fn(a: Stack(T), b: Stack(T), T: type -> bool) [implements eq]  ... #we dont write type after eq. compiler will infer
eqIntStack = fn(a: Stack(int), b: Stack(int) -> bool) [implements eq] ... #you cannot impl eqStack because it is not a signature function

#C
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
- we may later also add functions to use inside `[]` to say: `T must be an array` or `T must be a struct with a field name`
or `T must be a struct compatible with this struct H` this last one is starting point for structural polymorphism and can be achieved compile time.
we can define a small set of notations for here.
`eq(T)` expects T to have impl for eq signature
`eq` this function implements for eq signature
`T.name: string` T is a struct and has name field of type string
`T.name: S` type of name is S
`T.Point` T type is a struct and has all fields from Point type
`T.List(S)` T is a struct and has all fields from `List(S)`
`process = fn(a: T, b: T, T: type -> int) [eq(T),  T.age:int, T.Point, T: List(S)] {...}`
between these, `eq` notation is the most confusing.
lets use `!` notation. 
`eqInt = fn!eq(a: int, b:int -> bool ) [constraints] { ... }`
the fact that `eqInt` is implementing `eq` is not part of its type.
and also it is not part of its name.
we dont want to change anything in the name part because it is important and later might be used in other places like `_` operator to create a lambda.
`T.age:int, T.Point, T: List(S)` these are not really needed.
`T.age:int` -> pass age separately 
`T.Point` pass point separately
`T:List(S)` pass List(S) separately
so the only necessary part is signature implementations: what signatures should generic types implement.
`process = fn(a: T, b: T, T: type -> int) [eq(T), Iterable(T), Serializable(T)] {...}`
What are some important Java interfaces? how can we have them here via signature types?
- Iterable
- Serializable
- Closeable
- Cloneable
- Observable
q: why can't we add a new function to inputs of process to check for equality?
`process = fn(a: T, b: T, eq: fn(T,T->bool), T: type -> int) {...}`
we can definitely do that. problem will be: everytime when I call this function, I will need to remember what function does that for me.
and think we can have 100s of types and 10s of common functions.
what function does equality check for Customer? what function does serialization for a Connection?
what function does clone for an Employee type? 
rather than keeping track of all of these, we organise them and automatically fetch them during compile time based on tags that we have introduced.
but is it worth it?
option 1: keep using functions as inputs to pass all the logic you need. new type: write new functions, new functions: implement for important types
option 2: `!` notation, `[eq(T)]` notation. 
so, for example: for iteration, rather than having `foreach = fn... [itearble(T)]`
we write: `foreach = fn(data: T, ..., iterate: fn(T->T)...`
remember: it is better having smaller number of powerful features that compose well, rather than having lots of confusing and less elegant features that some cannot compose with each other.
option 1, keeps language simple but needs lots of coding. actually coding is almost the same because we still need to implement the logic for our type. 
for example if our function expects types to be comparable, we need a compare function for our types. the only difference is that with this option, we need to explicitly "pass" functions that does this. rather than having compiler/runtime infer the function for us (which is a hidden part).
option 2: makes writing code easier because after we implement the logic for our type, we don't need to do anything and wiring them is automatically provided by compiler/runtime.
I think it is a matter of convenience vs. flexibility. 
option 1 gives you flexibility but is less convenient 
option 2 is more convenient but less flexible and adds new notations: signature generic function and `!eq` notation and `[eq(T)]` notation..
just like error handling with `@`, we need to compare these two.
is the convenience worth loosing flexibility and added syntax?
new syntaxes:
1. `=0` notation to indicate a function is interface: `eq = fn(a: T, b: T, T: type -> bool) = 0`
2. `!` notation to say we are implementing a function: `eqStack = fn!eq...`
3. `[eq(T)]` notation to imply requirement for generic type: `process = fn(a: T, b: T, T: type -> int) [eq(T), Iterable(T), Serializable(T)] {...}`
we can get rid of 1 and 2. re 1, we make body allowed and all generic functions are signature functions.
re 2, we can say it is implied/hidden/opaque. so if a function has the same signature, then it is an implementation. just like go: if your class
	has methods with same signature as interface, then your class is implementing that interface.
3 is also informational. it is not needed by compiler, just by developer.
```
eq = fn(a: T, b: T, T: type -> bool) { default impl which can be exit/assert(false) }
eqInt = fn(a: int, b:int -> bool ) { ... } #it is implied that this fn implements eq, because it has same signature
process = fn(a: T, b: T, T: type -> int) [eq(T)] {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
problem: in Golang functions have names and they match with interface, but here function names must be different. so there is a high chance that we have lots of functions withtwo input arguments of type int. 
can we express these as functions? and then use that function name as type?
```
eq = fn(a: T, b: T, T: type -> bool) { false }
myCustomEqInt = fn(a: int, b:int -> bool ) { ... }
process = fn(a: T, b: T, T: type, eqHandler: fn(T,T->bool) -> int) {
  #nothing new, just call eqHandler when you need to
}
```
issue is now, we want to describe "relation" between types and it conflicts with the way we denote argument types.
we always write `a:int, b:float` we don't need to say type of a and b together, they are separate and isolated.
why can't we do the same for `T`? because a function has multiple inputs. so, for example if we have `convert = fn(a:int, b:float -> string)`
it has two types. so if I want to make sure I can call it in my generic function, I must be sure that we have this function for BOTH types.
```
eq = fn(a: T, b: T, T: type -> bool) { false }
myCustomEqInt = fn(a: int, b:int -> bool ) { ... }
process = fn(a: T, b: T, T: type, eqHandler: fn(T,T->bool) -> int) {
  #nothing new, just call eqHandler when you need to
}
```
what about this? we just allow a similar limited functionalit for unions.
for example: shape drawing.
we have good functions to draw circle, square and triangle
we also have `Shape` type which is a union of above types.
now, I want to call correct function for my Shape.
what is the easiest way?
```
shape = loadShape()
fnMap = 
result = 
```
we need a data structure to keep these functions. we cannot write them everytime we need them.
this can be for 10 types over 6 functions. so we need to keep track of a central location to save all of the functions that do this.
option 1: wildcard for generics -> dependant type
option 2: combine functions with unwrap operator. how?
```
drawers: [type: fn(T????
```
option 3: a new notation like switch
```
draw = fn(x: Shape, c: Canvas, a: float -> int) {
    ???	
}
```
we can use a map but fn has no input, it uses clousure to get the shape and unwrap/cast it. but need to closure means no data struct.
option 4: save a ptr to draw function in shape, and when you need it call it.
it is ok if we have to write a fn for this. we don't escape from writing some more code if it makes sense and prevents things become hidden.
and it gives us more flxibility.
```
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

drawFunction = fn(Canvas, float -> int)

#function to get another function to draw the given shape
draw = fn(shape: Shape, c: Canvas, f: float -> int) 
{
    [
        Circle: drawCircle(c???, _, _),
        Square: drawSquare(...)
    ][type(shape)](c, f)
}

shape = loadShape()
result = draw(shape, my_canvas, 1.12)
```
another option: a squeez notation to compress multiple similar functions into one.
but we will loos lots of flexibility. what if we have more than one generic type? what if we need some kind of logic?
```
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

drawFunction = fn(Canvas, float -> int)

#function to get another function to draw the given shape
draw = fn(shape: Shape, c: Canvas, f: float -> int) 
{
    [
        cr:Circle -> drawCircle(cr, _, _),
        s: Square -> drawSquare(s, _,_)
    ][type(shape)](c, f)
}

shape = loadShape()
result = draw(shape, my_canvas, 1.12)
```
what about changing union structure? so that it has all types together.
more like C unions, + a tag that shows which one is active.
another option is using field name within union
```
Shape = s: Square|c: Circle|t:Triangle
Shape = Square | Circle | Triangle
x: Shape = ...
x.type represents current type in x
```
another option: `.1, .2, ...` to refer to inner types
```
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

drawFunction = fn(Canvas, float -> int)

#function to get another function to draw the given shape
draw = fn(shape: Shape, c: Canvas, f: float -> int) 
{
    [
        Circle: drawCircle(c???, _, _),
        Square: drawSquare(...)
    ][type(shape)](c, f)
}

shape = loadShape()
result = draw(shape, my_canvas, 1.12)
```
Just like structs: in fn input we see `Point` but in code we write `.x`. we have some kind of opaqueness.
here too we can say it can be treated like a struct with `.1, .2, ...`. Just like struct, IDE can help user find out real type of these.
and we can say `.0` is type.
```
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

Shape = Circle | Square

#function to get another function to draw the given shape
draw = fn(shape: Shape, c: Canvas, f: float -> int) 
{
    [
        Circle: drawCircle(shape.1, _, _),
        Square: drawSquare(shape.2,...)
    ][shape.0](c, f)
}

shape = loadShape()
result = draw(shape, my_canvas, 1.12)
```
what about a generic function of type `T|U` and we pass `Square|Circle|Triangle` to it?
then if `x: T|U`
then `x.1` is of type Square.
`x.2` is of type `Circle|Triangle`
`x.0` can be Square or `Circle|Triangle`.
another option: In gnerics we dont allow flexible union. Meaning generic type cannot be union!
but this does not make sense. Generic is just like any other type.
and if generic function expects `T` I can pass `int|string`
so if it expects `T|U` I should be allowed to pass `int|string` or `int|string|float`.
so, lets move this to another title and mark signature functions as No.

Y - Do we allow struct values without field name?
`x = Point(1,2)`
we should.

N - Use `$int_or_float` notation to unwrap a union when calling a generic function.
4. You can use `$union_val` to unwrap a union binding to its internal type.
bool2 = eq($int_or_string, $int_or_string2)

N - Remove `type` keyword. any type name which is one capital letter is generic type.
what about generic data types? these are functions that accept only type argument.
but what if user sends other args like int? even literal ints? why limit? if they are functions we should be able to define/call them anyway we want.
`ValueKeeper = fn(T: type -> type) { struct(data: T) }`
`ValueKeeper = fn(T) { struct(data: T) }`
no. removing type will make it difficult for generic types and then we will need to add other notations elsewhere.

N - interfaces
we can write a classic style function which takes function args for the job.
and another function which passes appropriate functions as lambdas.
```
Eq = fn(T: type -> type) { fn(T, T -> bool) }
lookup = fn(x: T, arr: [T], T: type, cmp: Eq(T)) { ...}
lookupInt = lookup(_,_,int, fn(a:int,b:int->bool){a==b})
```
will it be useful?

N - To solve draw problem, we can have this notation:
```
draw[T] = fn(shape:T , ...)
draw[Circle] = fn(c: Circle...)
draw[Square] = ...
...
shape: Circle|Square = getShape()
draw[typeof(shape)](shape, ...)
```
first of all, this is not possible without union types.
also with addition of `$` notation this can be written like:
```
result = shape${
	fn(c: Circle -> ...
	fn(s: Square -> ...
```
it is more flexible and powerful.
and it can be put inside a function so we just need to call the fn.

N - A simple composable ifElse operator like `?:`?
it should be much more intuitive and simpler than a function call, otherwise why bother?
`result = cond${trueExp|falseExp}`
`result = (x>0){10|20}` here we need mandatory `()` for cond.
`result = {|x>0|10|20}` added chars: `${|}` 4 characters: prefix, boundary marker, item separators
`sign = {|x>0|true|false}`
is it easily composable?
`data = {|x>0|true|{|x<0|9|{|x=0|10|0}}}`
`data = (x>0?true|x<0?9|`
I'm not sure. it adds complexity to stuff that code reader needs to remember. and is difficult to compose.
but otoh it is very common and having expressions in these cases means more and more on-the-fly lambdas.
`data = ifElse(isValid(x), 1, 2)`

N - One more thing we should consider is searchability of the language. 
If someone wants to grep or grok a large source code to find samples of X, this should be done easily.
this means: more keywords, less notations
this means: each notation should have one and only one mearning

Y - Better support for unions
Just like structs: in fn input we see `Point` but in code we write `.x`. we have some kind of opaqueness.
here too we can say it can be treated like a struct with `.1, .2, ...`. Just like struct, IDE can help user find out real type of these.
and we can say `.0` is type.
```
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

Shape = Circle | Square

#function to get another function to draw the given shape
draw = fn(shape: Shape, c: Canvas, f: float -> int) 
{
    [
        Circle: drawCircle(shape.1, _, _),
        Square: drawSquare(shape.2,...)
    ][shape.0](c, f)
}

shape = loadShape()
result = draw(shape, my_canvas, 1.12)
```
what about a generic function of type `T|U` and we pass `Square|Circle|Triangle` to it?
then if `x: T|U`
then `x.1` is of type Square.
`x.2` is of type `Circle|Triangle`
`x.0` can be Square or `Circle|Triangle`.
another option: In gnerics we dont allow flexible union. Meaning generic type cannot be union!
but this does not make sense. Generic is just like any other type.
and if generic function expects `T` I can pass `int|string`
so if it expects `T|U` I should be allowed to pass `int|string` or `int|string|float`.
what happens if I access `shape.1` when the second item has something? there should be a runtime error.
another advantage of this is that with `shape.0` compiler gets a chance to verify map has all required cases based on union type definition.
**Proposal: Enhanced unions**
1. Each binding of type union allowed `.0, .1, .2, ...` notations.
2. `.0` represents current type of the union
3. `.1` represents value inside union if it has the first type of the definition.
4. if `.0` says union binding has second type in it and you refer to `.1` there will be a runtime error.
5. Fix example of polymorphism
===
maybe we should allow ref to any of `.1, ...`.
in the happy scenario where developer checks first, there is no difference.
in the bad scenario we will ignore the error! which is not good. there are times that we should fail fast.
one more thing that can be useful: `T|nothing` types.
`result = (validator//NopFunc3)(x, y, z)`
suppose that we have a function or nothing and we want to call it if its not nothing.
```
result = [
	nothing: 
][validator.0]
```
q: why use `.0`? why not use a better name like `.type`?
can't we have a generic function that accepts a function or nothing, and if nothing return nothing, otherwise call the function?
can't wehave this notation:
`union1.1(a,b,c)//union1.2//union1.3(1)`
so, `.1(...)` means if union has that type make the call, otherwise return nothing.
problem: maybe `.1` call actually returns nothing!
```
int_or_float.1? means int value or nothing
```
`union1.1?(a,b,c)//union1.2//union1.3(1)`
we can reverse the order:
```
result = [
	nothing: fn{nothing}
	
][validator.0]
```
but having to always write a map is difficult. sometimes its difficult to repeat complex types.
we can say `.1?` is a boolean that says if `.1` has data.
`result = ifElse(validator.1?, fn{validator.1(x,y,z)}, -1)`
we can replace it with type: 
`result = ifElse(validator.type == nothing, -1, fn{validator.1(x,y,z)})`

```
data = match(shape.type, [
	(Circle, fn{ drawCircle(shape.1) }),
	(Square, fn{ drawSquare(shape.2) }),
	(Triangle, fn{ drawTriangle(shape.3)} )
])
```
can we have a better notation than `.1`?
`int_or_float.int` gets the int value. but this is not good for complex types.
but we don't allow complex types! a union definition must be between type names, not type literals.
`Type1 = fn(int, float -> [string]) | ...` is not valid.
so if they are all type names like primitives or named types we can do this:
`int_or_float.int`, `int_or_float.float`, ...
but this dot notation is against struct syntax. what comes after dot is a field name.
but the good thing is, type is documented.
bad thing is, we need to type a lot.
`shape.Circle`
maybe we should use something else, not dot.
but we can think of union as a type of struct.
this struct, has a `type` field and n fields for n types.
and only one of those fields has a value.
we can force a label/name for each type but it makes union type definition complicated.
`Iof = int|float`
`x.int`, `x.float`, `x.Customer`
or maybe we can use `.[]` notation.
we can also have `.()` notation for fn type unions, so it gives nothing if union or nothing, or else calls the function.
or maybe we can mix these two: `.[T](...) // X` if type is T, make this fn call, otherwise X.
we need a notation that:
1. is error resilient. so built-in we can guard against errors
2. easy to use and intuitive
3. gives you internal type of the union
maybe we can use a notation like error control but say: if type was not X then do that.
`data = int_or_float.int[...]@.float[...]`
`data = int_or_float.int?{...}`
`resut = x.type1{...}.type2{...}.type3{...}`
`result = x.(a: type1){a+1}.(b: type2){b-3}`
with above notation, we don't need magical type and `.0, .1, ...`.
how can we determine types? what if some `.(...){...}`s are missing? what will be the result?
we may enforce this at compiler level: you must have cases for all types.
`result = shape.(c: Circle){c.size}.(s: Square){s.item}`
```
result = shape
	.(c: Circle) { c.size }
	.(s: Square) { s.item_size }
```
what type is what we write after the dot? is it a function? it looks like a function. so it must be a function.
```
result = shape
	$drawCircle
	$drawSquare
	$drawTriangle
result = union_var$func1$func2$func3
```
maybe we can extend this notation to have prefix function call. rather than `f(x)` we write `x$f`?
```
result = int_var$intHandler
```
can we bound this? so that it can be composable with other expressions?
`result = int_var$(intHandler)`
`x = int_var${intHandler}`
q: what if we have multiple inputs? that should not be allowed. if allowed, it makes everything more complicated.
`${...}` looks like error control. 
`$[...]`
`$(...)`
but this is not good. because when it defies the notation of union.
`int_or_float$int_function` is wrong! because right hand side of `$` should have only one input of the left hand side type.
lets minimize usage of this notation so it will be a simple and minimal notation which is easy to use.
each notation should be for one and only one task.
```
result = shape
	${drawCircle}
	${drawSquare}
	${drawTriangle} + 9
result = union_var$func1$func2$func3
```
option 1: `${...}` so it will be better composable
option 2: `$...` it will need `()` to be composable but will be easier to type.
**Proposal: Enhanced unions**
1. You can use `${...}` notation to check and run multiple functions, one per union type option.
```
result = union_binding${fn1}${fn2}${fn3}
result = shape
	${drawCircle}
	${drawSquare}
	${drawTriangle}
```
2. Items after `$` should cover all cases for union. otherwise it will be compiler error.
3. Fix example of polymorphism
===
how can we simulate `type` then? 
```
result = shape
	${1}
	${2}
	${3}
```
but above is not ok because we expect a function!
we can say: an expression or a lambda can come inside `{...}`
but lambda is an expression too!
```
result = shape
	${fn{1}}
	${fn{2}}
	${fn{3}}
```
still the functions do not have an input! how does compiler know which item to run for each type!
```
result = shape
	${fn(c: Circle -> int){1}}
	${fn(s: Square -> int){2}}
	${fn(t: Triangle -> int) {3}}
```
I think double braces `}}` is fine.
here is how we can simulate `.type` notation.
can we do this for enums?
Of course not! because here we are dealing with types so we can use lambdas.
enums are values. how can we encode a value check? lets just use normal functions and select/case.
this `union_binding${fn1}${fn2}${fn3}` notation does not look very composable.
`union_binding.(fn1, fn2, fn3)`
and if we make list of fns a seq, it will be more composable/orth, so developer can keep a sequence of functions.
but that's not possible because those functions have different types, so lets don't encourage that.
`union_binding${fn1, fn2, fn3}`
```
result = shape${
	fn(c: Circle -> int) {1} ,
	fn(s: Square -> int) {2} ,
	fn(t: Triangle -> int) {3}
}
```
what if we have more than one union?
```
result = (shape, canvas)${
    fn(s: Circle, c: SolidCanvas -> int) {...}
    fn(s: Square, cc: RedCanvas -> int) {...}
}
```
in this case, a wildcard mechanism might be useful.
for example a function that does NOT expect those types can be a catch-all.
```
result = (shape, canvas)${
    fn(s: Circle, c: SolidCanvas -> int) {...}
    fn(s: Square, cc: RedCanvas -> int) {...}
    fn(cp: BlueCanvas -> int) { ... code for all shapes and blue canvas }
}
```
but determining this via compiler is complicated and makes reading code difficult.
it should be developers responsibility. they can do this inside the function.
**Proposal: Enhanced unions**
1. You can use `${...}` notation to check and run multiple functions, one per union type option.
```
result = union_binding${fn1, fn2, fn3}
result = shape${
	drawCircle,
	drawSquare,
	drawTriangle
}
result = (shape, canvas)${
    drawCircleWithRedCanvas,
    drawSquareWithBlueCanvas,
    ...
```
2. Items after `$` should cover all cases for union. otherwise it will be compiler error.
3. Fix example of polymorphism
===
maybe adding an `else/default` function makes things easier and it is explicit enough.
```
result = shape${
	drawCircle,
	drawSquare,
	drawTriangle,
    fn{0}  #a function with no input means catch all function/else clause
}
```
can we make the notation even more compact?
```
result = (drawCircle(shape) || drawSquare(shape) || drawTriangle(shape))
```
Using comma to separate functions is not very nice. 
`result = shape(drawCircle(_) || drawSquare(_) || drawTriangle(_) || fn{0})`
we can say: if you add functions it will give you a suprt function that can be treated just like a function of union of them.
but then it will become to enforce by compiler and it make it availble for every other use case so it becomes nonpractical for compiler to check full coverage.
lets limit it to this limited use case.
`result = shape(drawCircle(_) || drawSquare(_) || drawTriangle(_) || fn{0})`
- what if one of the functions accepts a union? it can work as OR in conditions.
q: how do we combine functions? we have never done this before. 
we can combine via new line.
```
result = shape${
	drawCircle
	drawSquare
	drawTriangle
}
result = shape${drawCircle drawSquare drawTriangle }
```
can't we re-use `//` here? because it really matches with our use case.
assuming functions don't return nothing.
but even if they return nothing, we can continue and rest of the functions won't match.
`result = shape${drawCircle drawSquare drawTriangle }`
`result = shape${drawCircle // drawSquare // drawTriangle}`
so, we can say, if function cannot accept that union's internal type, we move to the next function.
basically, this will be a new use case for the same notation.
pro: no need to invenent a new notation for this, no need for comma, intuitive to some extent
con: one notation is now a bit more complicated.
`result = shape{drawCircle // drawSquare // drawTriangle // fn{10} }`
**Proposal: Enhanced unions**
1. You can use `${//}` notation to check and run multiple functions, one per union type option.
```
result = union_binding${fn1, fn2, fn3}
result = shape${
	drawCircle //
	drawSquare //
	drawRectanbleOrOval //
	drawTriangle
}
result = (shape, canvas)${
    drawCircleWithRedCanvas //
    drawSquareWithBlueCanvas //
    fn{10}
}
```
2. Items should cover all cases for union. otherwise it will be compiler error.
3. If one of the functions accepts a union, both types will be matched.
4. Fix example of polymorphism
===
but re-using an existing operator for a different purpose is dangerous and confusing.
so whenever I see `//` I should look around it to check if it is inside `${}`
```
result = shape${
	drawCircle,
	drawSquare,
	drawRectanbleOrOval,
	drawTriangle
}
```
comma or newline (space).
**Proposal: Enhanced unions**
1. You can use `${}` notation to check and run multiple functions, one per union type option.
```
result = union_binding${fn1, fn2, fn3}
result = shape${
	drawCircle ,
	drawSquare ,
	drawRectanbleOrOval ,
	drawTriangle
}
result2 = (shape, canvas)${
    drawCircleWithRedCanvas ,
    drawSquareWithBlueCanvas ,
    fn{10}
}
```
2. Items should cover all cases for union. otherwise it will be compiler error.
3. If one of the functions accepts a union, both types will be matched.
4. Fix example of polymorphism
===

Y - Shall we have a notation for a function that has one input of type `T` and output inferred?
to be used with unions.
then we can just extend this: `fn(int, Circle)` for a function the accepts these two but doesn't care about their value.


Y - How does default case work with `///` operator?
If we want to process them by random, then it does not make sense. 
suppose that we have 3 cases with default case and one of those cases is active.
now `c1 /// c2 /// c3 /// default` may randomly hit the default and return with default, and ignore `c2` the active one.
there should be a mechanism to say: check these and if none of them were active then return X.
but this select call is supposed to be blocking.
we can do this via a timeout. `c1 // c2 // c3 // timeout(1ms, 105)` so if any of channels are active, it wil be picked up, otherwise after 1ms we will have `105` default value.
yes, but it is a bit counter-intuitive.
but we can do this via the runtime arg. just pass something to see if this is a default channel or not.
or maybe we can say this:
- select always picks by order no matter what
- if you need randomization, you need to mix them via a helper function and do it yourself.
so this randomization function will call one of the inner channel fns depending on a random flag.
can we use the same notation of union select for here?
```
union_type = shape${
    fn(Circle) { 5 }
    fn(Square) { 4 }
    fn{0}
}
# all items in select accept a single argument int|nothing which is used for runtime
data = select {
	chFunc1,
    chFunc2,
    chFunc3(data, _)
    makeTimeout(100)
    defaultChannel(200)
}
```
nope. it is structurally incompatible with union select.
ok there is another way: the default function has a different contract. all other channel functions have `int|nothing` but default function accepts `nothing` ?
then runtime can differentiate.

N - Explain a bit more about concurrency
- select: does it block if none of cases are ready?

N - Can we use module as a type of interface?
so interface means a module that implements some specific functions.
but it is difficult to do that. its not flexible

N - We need built in support for map/filter/reduce?
we can implement map and filter and find via reduce: https://maurobringolf.ch/2017/06/implementing-map-filter-and-find-with-reduce-in-javascript/
```js
function map(arr, fn) {
	return arr.reduce((acc, item) => [...acc, fn(item)], [])
}
function filter(arr, fn) {
	return arr.reduce((acc, item) => fn(item) ? [...acc, item] : acc, [])
}
unction find(arr, fn) {
	return arr.reduce((acc, item) => fn(item) ? acc || item : acc, undefined)
}
```
so it works like this:
```
reduce = fn(seq: [T], reducer: fn(acc: U, item: T -> U), start: U, T: type, U: type -> U) { ... }
#for example for a find operation:
result = reduce(int_list, fn(acc: bool, item: int -> bool) { if (item == result ) then return true otherwise return acc}, false)
```
but is it also efficient?
for example for a map operation on 1000 element seq, we will create 1000 arrays of sizes 1 to 1000
unless we can come up with an efficient way.
- if we use a language notation, there will definitely be some other use cases which won'y be able to fit and we will need to define core fns.
but if we define some basic core functions, anything else will be simply a combination of them without needing to add extra notations.

N - A notation for slice of a sequence
```
a[0:10]
a[:10]
a[0:]
a[:]
```
Maybe later. does not need anything and nothing else is dependent on this.

N - Should we make it easier to group a number of functions together? Maybe they have closure over some internal variable, for example.
and we should be able to easily add to that group.
but functions each have their own signature.
so this is actually a struct of functions which is already available.
```
c = createCircle()
draw = fn() { ... c ... }
print = fn() { ... c ... }
...
return (draw, print, ...)
```

N - Can we allow `${}` for enums too? then it can handle if/else.
```
result = is_valid${
    true { 5 }
    false { 6 }
}
result = ${
    isValid(data) { 5 }
    isStaleData(date) { 6 }
    true { ... }
}
```
No we are going to use match.

Y - The notation for channel read/write is confusing. even for me. I sometimes get confused.
create channel will give you a channel identifier? 
`x::()` will read from channel
`x::(w)` will write to channel
but using functions gives us advantage of composing.
but then it becomes ugly because we need to add runtmie arg and include it everywhere!
and this will be a new data type. just like go.
Channel can be a generic data type.
and it can have two functions: read and write + other functions that can be useful like getBufferSize, peek, ...
```
Channel = fn(T: type -> type) {
    struct {
        identifier: int,
        tp: type,
        getStatus: fn(->bool),
        max_size: int,
        read: fn(->T),
        write: fn(data: T -> ),
        close: fn(->)
    }
}
```
and then we deal with those functions.
Same for channel select. we can do it in a function in std.
**Proposal**:
1. No notation for channel read or write or select.
2. Channels are generic structs that have all needed functions.
```
Channel = fn(T: type -> type) {
    struct {
        identifier: int,
        tp: type,
        getStatus: fn(->bool),
        max_size: int,
        read: fn(->T),
        write: fn(data: T -> ),
        close: fn(->)
    }
}
```

N - (moved to above item) Remove notation for channel select.
https://wiki.dlang.org/Go_to_D#Select
Here in dlang, they do this via a normal function.
In Quasar:
```
SelectAction sa = Selector.select(Selector.receive(ch1), Selector.send(ch2, msg));
```
Kotlin:
```
select<Unit> { // <Unit> means that this select expression does not produce any result 
        fizz.onReceive { value ->  // this is the first select clause
            println("fizz -> '$value'")
        }
        buzz.onReceive { value ->  // this is the second select clause
            println("buzz -> '$value'")
        }
    }
```
I think we can rely on this being done on std with help from core (in the Channel struct).

N - if we adopt match, can we replace `//` with it?
`result = a // b`
`result = match a==nothing { b, a}`

N - After adding match, remove the note that using bool for seq index makes it int.

N - Should we use a keyword for switch? with above proposal, we will use `!{}` for struct, so struct keyword will be gone.
we can trade it with `select` or `switch` or `match` keyword.
maybe then we can extend it for 3 purposes:
1. expression switch
2. union type switch
3. channel selection
```
result = x ${ 
    fn(a: int -> int) {a+1},
    fn(a: string -> int) {5},
    fn{100}   #default case when none of above functions can accept x
}
```
Scala:
```
x match {
  case 0 => "zero"
  case 1 => "one"
  case 2 => "two"
  case _ => "other"
}
```
Kotlin:
```
when (x) {
    1 -> print("x == 1")
    2 -> print("x == 2")
    else -> print("x is neither 1 nor 2")
}
```
Rust:
```
    match x {
        1 => println!("one"),
        2 => println!("two"),
        3 => println!("three"),
        _ => println!("anything"),
    }
```
Go:
```
switch i {
    case 1:
        fmt.Println("one")
    case 2:
        fmt.Println("two")
    case 3:
        fmt.Println("three")
    }
switch {
    case t.Hour() < 12:
        fmt.Println("It's before noon")
    default:
        fmt.Println("It's after noon")
    }
    switch t := i.(type) {
        case bool:
            fmt.Println("I'm a bool")
        case int:
            fmt.Println("I'm an int")
        default:
            fmt.Printf("Don't know type %T\n", t)
        }
switch v := x.(type) {
case nil:
    fmt.Println("x is nil")            // here v has type interface{}
case int: 
    fmt.Println("x is", v)             // here v has type int
case bool, string:
    fmt.Println("x is bool or string") // here v has type interface{}
default:
    fmt.Println("type unknown")        // here v has type interface{}
}
```
match/switch/when: I think match makes more sense.
`result = match item { ... }`
where item can be missing, a value expression, an enum expression or a union. for missing, cases can be conditions or functions for channels.
```
result = match item {   #simple match with value
	1 => 40
    2 => exp1
    3 => {
        cmd1
        cmd2
        cmd3
        resut
    }
    default => exp3
}
result = match {        #match with conditions same as match true { ... }
    isValid(data) => 10
    isWrong(data) => 9
    default => { ... }
}
result = match enum_day_of_week { #same as value
    Saturday => exp1
    Sunday => exp2
    default => exp3
}
result = match:shape { #match on union inner type
    c:Circle => exp1 #here inner is of type Circle
    s:Square => exp2 #here inner is of type Square
    default => exp3
}
result = match:: {
    data = channel1::() => 5+data #read
    data = chFunc2::() => 6-data
    out: chFunc3::(data) => 2
    makeTimeout(100) => -1
    default => 100
}
```
left side of `=>` can be expressions. they will be evaluated in order.
advanced pattern matching: multiple items, regex, range match(a to z)
for vlaues you can use `a,b,c` to match with any of them
for conditions, you can use `and, or` to combine conditions. but again, `,` will act as OR
for `match::` this is not supported :-(
for union match, only one is supported
q: what if key expression is multiple? e.g. a struct?
then values can be structs. for union, value can be struct (of type). note that we can store type literals in a struct.
range match: not useful. makes things more complicated.
regex: for later
**PROPOSAL**:
1. We will add two new keywords: `match` and `default`.
2. General syntax is `left_side_value = match exp { cases }`
3. exp can be a value (value binding or enum), missing, union or `::` for channel selection
4. cases are of the form `exp1 => exp2`, exp1 can be a value (for bindings), `x: type` for union or channel operation for `match::`
5. top expression can be a struct (of values or types) in which case, exp1 in cases should be on the same structure.
examples:
```
result = match item {   
	1 => 40
    2 => exp1
    3 => { #this is not a lambda, just a separator
        cmd1
        cmd2
        cmd3
        resut
    }
    4 =>
    5 => 
    6 => 100 #on item for 3 cases
    default => exp3
}
result = match {        #match with conditions same as match true { ... }
    isValid(data) or isGenera(item) => 10 #or conditions
    isWrong(data) && isOutOfScope(x) => 9 #and conditions, you can also ue or
    default => { ... }
}
result = match enum_day_of_week { 
    Saturday => exp1
    Sunday => exp2
    default => exp3
}
result = match shape { #match on union inner type
    c:Circle => exp1 #here inner is of type Circle
    s:Square => exp2 #here inner is of type Square
    default => exp3
}
result = match channel { #channel is the keyword for channel data type
    data = channel1::() => 5+data #read
    data = chFunc2::() => 6-data
    out: chFunc3::(data) => 2
    makeTimeout(100) => -1
    default => 100
}
```
q: can we use default in partial matches? `5, default => ...`
q: a shortcut for `match x { true => a, false => b}`? ifelse?
the more flexibility we give, the more edge cases and assumptions we need to make.
we should define a critical mission for `match` keyword and only deliver that.
- nore match for multiple items. only one expression
```
result = match item {   
	1 => 40
    2 => exp1
    3 => { #this is not a lambda, just a separator
        cmd1
        resut
    }
    4 =>
    5 => 
    6 => 100 #on item for 3 cases
    default => exp3
}
result = match {        #match with conditions same as match true { ... }
    isValid(data) or isGenera(item) => 10 #or conditions
    isWrong(data) && isOutOfScope(x) => 9 #and conditions, you can also ue or
    default => { ... }
}
result = match enum_day_of_week { 
    Saturday => exp1
    Sunday => exp2
    default => exp3
}
result = match shape { #match on union inner type
    c:Circle => exp1 
    s:Square => exp2 
    default => exp3
}
```
match without operand is used to compress multiple if statements. we do not like compresson. let them write it normally.
```
result = match item {   
	1 => 40
    3 => fn{
        cmd1
        resut
    }()
    4 =>
    5 => 
    6 => 100 #one item for 3 cases
    default => exp3
}
result = match enum_day_of_week { 
    Saturday => exp1
    Sunday => exp2
    default => exp3
}
result = match shape { #match on union inner type
    c:Circle => exp1 
    s:Square => exp2 
    default => exp3
}
```
we need a syntax sugar for this:
```
result = match item { 1, 2 }
result = match item { 
    1
    2
}
result = match isDone 10 20
result = match isDone 10:20
result = match isdone 10, 20
>>> result = match isDone { 10, 20 } #this is valid only if using expressions, for code block, you should normal syntax
result = match isDone ( 10, 20 )
```
Having multiple items can be useful. but can't we do it via struct?
```
result = match item {   
	1 => 40
    3 => fn{
        cmd1
        resut
    }()
    4 =>
    5 => 
    6 => 100 #one item for 3 cases
    default => exp3
}
result = match enum_day_of_week { 
    Saturday => exp1
    Sunday => exp2
    default => exp3
}
result = match shape { 
    Circle => Circle.[shape]... 
    Square => Square.[shape]...
    default => exp3
}
result = match isDone { 10, 20 }
result = match a,b {
    10, 20 => 1
    20, 30 => 2
    30, default => 100
    default, 20 => 100
    default => 90
}
```
but can't we easily do this by map?
```
result = [   
	1: 40,
    3: fn{
        cmd1
        resut
    }(),
    6: 100 #one item for 3 cases
][item]
result = [ 
    Circle: Circle.[shape]... 
    Square: Square.[shape]...
][type(shape)]
```
Are we trying to simplify something which is not complicated?
`result = [10, 20][isDone]`
so, essentially the only thing we really need is a core function to return internal type inside a union.

N - How can I type a literal with a named type?
`MyInt = int`
`processData(12)` but processData needs MyInt
how can I cast?
golang: `processData(person{"Bob", 20})`
we can generalise `&` notation: `T&{literal}` will cast literal to type T, of course literal and T should be of the same type.
`processData(MyInt&{12})`
This is described in the section about structs

Y - If we allow for `:` and `::` notations for union, can we get rid of union switch?
```
result = x ${ 
    fn(a: int -> int) {a+1},
    fn(a: string -> int) {5},
    fn{100}   #default case when none of above functions can accept x
}
result = switchCoreFunction(shape, Circle, fn...
```

Y - if we adopt new notation for match and cast for union, remove the part that says about destructing union type.

Y - A better notation for struct
- type definition
- binding/literal decl
- assignment/copy/modify
Rust:
```
struct User {
    username: String,
    email: String,
    sign_in_count: u64,
    active: bool,
}
```
`{}` is used for code block, import, union select and error handling!
`[]` for array and map
`()` for fn call
```
#named type definition
Point = struct (x:int, y:int) 
Point = struct (int, int)

#instantiation
Point(100, 200) 
Point(x:100, y:200) 
struct(int,int)(100, 200) 

#modification
third_point = Point(point1, point2, point3, z: 10, delta: 99)
```
maybe we can keep using `()` but make it more elegant/explicit/beautiful.
right now it looks like function and generic functions, which is confusing.
```
#named type definition
Point = <x:int, y:int>
Point = <int, int>

#instantiation
Point<100, 200>
Point<x:100, y:200>
<int,int><100, 200>
<100, 200>

#modification
third_point = Point<point1, point2, point3, z: 10, delta: 99>
```
```
#named type definition
Point = !(x:int, y:int)
Point = !(int, int)

#instantiation
Point!(100, 200)
Point!(x:100, y:200)
!(int,int)!(100, 200)
!(100, 200)

#modification
third_point = Point!(point1, point2, point3, z: 10, delta: 99)
```
so `!` comes before `(` which denotes struct type or literal.
so, why can't we just use `{}` now?
```
#named type definition
Point = !{x:int, y:int}
Point = !{int, int}

#instantiation
Point!{100, 200}
Point!{x:100, y:200}
!{int,int}!{100, 200}
!{100, 200}

#modification
third_point = Point!{point1, point2, point3, z: 10, delta: 99}
```
if we use `//` for comments, we can use `#` here too. 
but `!` implies not. and also is an operator `!=` so is a bit confusing.
we should try to come up with a syntax which is easy to parse by compiler if we do that, it will also be easy to read for a developer.
`{...}` notation for struct is not very clear because same notation is used for function body.
```
#named type definition
Point = &{x:int, y:int}
Point = &{int, int}

#instantiation
Point&{100, 200}
Point&{x:100, y:200}
&{int,int}&{100, 200}
&{100, 200}

#modification
third_point = Point&{point1, point2, point3, z: 10, delta: 99}
```
can we have two notations for type vs. literal of struct?
`&{...}` for literals
`^{...}` for type
or maybe use struct keyword!
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`Point&{100, 200}`                     | `Point(100, 200)`                 |
|`Point&{x:100, y:200}`                 | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`Point&{point1, z: 10, delta: 99}`     | `Point(x:11, y:my_point.y + 200)` |
what is type of `&{12}`? it is an unnamed struct with one int field.
now, if `MyInt = int` and I write `MyInt&{12}` then what is type of the result? it should be MyInt.
these two are having conflicts.
what about this? `&{x:100, y:200}.(Point)` which does casting?
`12.(MyInt)` it is a bit counter intuitive. I expect type to come first.
but we usually have `x:int` so we have data/var then type.
`12.(MyInt)` is like `12: MyInt`
we can say, all struct bindings are untypes unless we provide a type for them.
`&{x:100, y:200}.(Point)` this is better than `Point(&{x:100,...})`
because `(&{` is 3 notations one after each other which is confusing and also I need to add an end boundary with `)` at the end.
`&{x:100, y:200}:Point`
`12:MyInt`
`x:MyInt` this is confusing. is it decl or type cast?
`x::MyInt` 
`12::MyInt`
`&{...}::Point`
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}::Point`                   | `Point(100, 200)`                 |
|`&{x:100, y:200}::Point`               | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`&{point1, z: 10, delta: 99}::Point`   | `Point(x:11, y:my_point.y + 200)` |
`myint_var = 12::Point`
`my_circle = shape::Circle`
we can then use `::` for casting in general.
cast named types.
numbers (int, float, byte ...)
union to inner types `shape::Circle`
- can we save the result? can we check if conversion fails? for union?
we can say, `::` returns `nothing` if conversion fails.
`shape::Circle` if not nothing, then is of type Circle
in golang we write: `t, ok := i.(T)`
we need to somehow consolidate two things here: result of casting, and if casting was successfull
we can do it like golang:
`circle, ok = shape::Circle`
but how can I directly access to ok without assignment? I need this for match.
solution: wrong `::` will give you runtime error. you should use match to make sure it is correct.
problem: is not composable!
`shape::Circle.radius` this is super confusing. what does `.` act on? we want it to act on the whole expression.
`shape.(Circle)`
what about structs?
`&{point1, z: 10, delta: 99}.(Point)`
another way:
`Point&{point1, z: 10, delta: 99}`
`Circle{shape}`
`MyInt{12}`
so for struct literal, we use `&` prefix. for other values we just weite `{}`
or:
`&Point{point1, z: 10, delta: 99}`
`&Circle{shape}`
`&MyInt{12}`
but, we want to discriminate this from code block.
`&T{literal}`
- explicitly different from code block or match block
- is composable
- two different meaning about what comes after `&T` but that should be fine.
but what about match?
match has a special semantics for union types and we use this notation inside union matched blocks.
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&Point{100, 200}`                     | `Point(100, 200)`                 |
|`&Point{x:100, y:200}`                 | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`&Point{point1, z: 10, delta: 99}`     | `Point(x:11, y:my_point.y + 200)` |
`myint_var = &MyInt{12}`
`my_circle = &Circle{shape}` gives Circle or a runtime error
we can make this more flexible by saying: cast will return nothing if cast is not possible.
on one hand, we need `&Circle{shape} // ???` everywhere, otoh we don't need to check for correctness of the casting.
note that this is only for unions. for everything else, it is checked and enforced at compile time. so we don't need to worry about that at runtime.
I think with match, this is not very useful. we add a match clause and inside that we are sure about the type.
still there is some confusion. `&MyPt{100}` is a struct litearl of type Point. `&MyInt{100}` is named type, MyInt.
in both cases, type is what we have between `&` and `{`. what comes inside `{}`? on the left, it is struct
on the left it is a number (or can be anything).
what about this? we use `&` only for struct literals?
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`Point&{100, 200}`                     | `Point(100, 200)`                 |
|`Point&{x:100, y:200}`                 | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`Point&{point1, z: 10, delta: 99}`     | `Point(x:11, y:my_point.y + 200)` |
`myint_var = MyInt{12}`
`my_circle = Circle{shape}` gives Circle or a runtime error
so the syntax is `T{V}` or `T&{V}` for structs.
still they overlap.
note that struct type is also a named type. so we should be able to use `MyInt{12}` notation.
we should say, literal comes inside `{}`. which makes sense for named type. but for struct named type:
literal includes `{}`! -> conflict
int literal: 12
point litearl: `&{100,200}`
type conversion: `literal.Type` but this is not composable.
type conversion: `litearl.(Type)`
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}.(Point)`                  | `Point(100, 200)`                 |
|`&{x:100, y:200}.(Point)`              | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`&{point1, z: 10, delta: 99}.(Point)`  | `Point(x:11, y:my_point.y + 200)` |
`myint_var = 12.(MyInt)`
`my_circle = shape.(Circle)` gives Circle or a runtime error
or, if we want to decrease shift key press we can use `[]`.
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}.[Point]`                  | `Point(100, 200)`                 |
|`&{x:100, y:200}.[Point]`              | `Point(x:100, y:200)`             |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`&{point1, z: 10, delta: 99}.[Point]`  | `Point(x:11, y:my_point.y + 200)` |
`myint_var = 12.[MyInt]`
`my_circle = shape.[Circle]` gives Circle or a runtime error
or: we can use `T[litearl]` notation. Can't this be confused with array/map? for seq and map, what comes before `[]` is a binding name.
we can also use `T.[]`
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`Point.[&{100, 200}]`                  | `Point(100, 200)`                 |
|`Point.[&{x:100, y:200}]`              | `Point(x:100, y:200)`             |
|`Point.[&{point1, z: 10, delta: 99}]`  | `Point(x:11, y:my_point.y + 200)` |
`myint_var = MyInt.[12]`
`my_circle = Circle.[shape]` gives Circle or a runtime error
maybe we can simplify this.
we can say `T.L` this is not composable by itself. but is composable for structs.
also, people can write `T.(L)` if needed to be composable.
but it is too similar to struct element access.
what about `T::L`
it should be `L::T` because we put item first and type second.
in go we write: `person{name: name}`
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`Point{100, 200}`                      | `Point(100, 200)`                 |
|`Point{x:100, y:200}`                  | `Point(x:100, y:200)`             |
|`Point{point1, z: 10, delta: 99}`      | `Point(x:11, y:my_point.y + 200)` |
`myint_var = MyInt{12}`
`my_circle = Circle{shape}` gives Circle or a runtime error
- we can say `&` is needed for struct literals without type
- now, the syntax for typed struct literal, is similar to casting. maybe we should have a different notation for them.
`myint_var = MyInt(12)`
`my_circle = Circle(shape)`
but then, is this a type to cast or a generic function to call?
Maybe it is ok to use `T{L}` in all cases (struct literal, union cast, named type cast).
we say result of `T{L}` is of type `T` all the time.
`L` is a literal which can be `12` or `shape` or list of fields for a struct.
- can we remove `&` from `&{100,200}`?
- when `L` is `200` we don't know whether it is a named type casting of 200 or a cast to struct. it can be both. the named type can be a struct.
so, we need to see what the type is.
why are we using the same notation for struct and casting? these are two different things.
although we can say that struct literal is "casted" to a named type, but no casting happens in fact.
let's discuss casting in a separate point.
**PROPOSAL**
we define a new notation for struct. which is more distinct from fn call.
| new                                   | current                           |
|-----                                  |---------                          |
|`Point = struct {x:int, y:int}`        | `Point = struct (x:int, y:int)`   |
|`Point = struct {int, int}`            | `Point = struct (int, int)`       |
|`&{100, 200}`                          | `struct(int,int)(100, 200)`       |
|`Point{100, 200}`                      | `Point(100, 200)`                 |
|`Point{x:100, y:200}`                  | `Point(x:100, y:200)`             |
|`Point{point1, z: 10, delta: 99}`      | `Point(x:11, y:my_point.y + 200)` |
but why not unify them? we can say we have a general casting. and we have untyped struct literals. these can be cast to a named type via casting notation.
of course compiler will optimize that to stop an actual casting to happen, but in reading/writing it will be more unified and consistent.
casting notation is: 
`T{L}` not good because conflicts with struct. then we will have to write: `Point{&{x:100,y:200}}` which is confusing.
`T.(L)`
`T.[L]`
`T ? open L close`
`T open L close`
`L:T`
`L:[T]`
`12:MyInt`
```
Point = struct {x:int, y:int}
Point = struct {int, int}
&{100, 200}
&{100, 200}:Point
&{x:100, y:200}:Point
&{point1, z: 10, delta: 99}:Point
myint_var = 12:MyInt
my_circle = shape:Circle
```
we can even say `union::type` will return a boolean which says whether the type is right or not.
if we need to mix, we can mix because after `:` we expect just one identifier.
so `x:func(int->int)` is not correct.
`y:int|float` is not correct.
why not?
we can say any valid type is accepted.
but if it is not a simple identifier, you will need to `()` the whole thing to prevent confusion.
we can generally say `::` is a tryCast which will return `T|nothing`
so it can be used for casting string to int or union to its type.
**PROPOSAL**
1. We use `Binding:Type` expression to do casting.
2. This can be used to cast primitive types, named types, struct or unions.
3. `Binding::Type` can also be used to do a try cast which returns `Type|nothing`
can't we simulate `::` via `:T|nothing`?
this is for unions mainly. so we write: `my_shape:Circle|nothing`. if `my_shape` has a circle, we will have a circle, if it has square or ... we will have a nothing.
`my_str:int|nothing` same. if string is not a valid number, we will have nothing.
i think this makes sense and is orth.
**PROPOSAL**
1. We allow `exp:Type` notation to do cast from exp to Type.
2. This can be used for primitives, named types, struct or union.
3. struct literals should be prefixed with `&` and are in `&{...}` form.
4. You can cast to `T|nothing` to allow room for failures. In case casting to `T` is not possible, you will have a nothing.
```
Point = struct {x:int, y:int}
Point = struct {int, int}
&{100, 200}
&{100, 200}:Point
&{x:100, y:200}:Point
&{point1, z: 10, delta: 99}:Point
myint_var = 12:MyInt
my_circle = shape:Circle
maybe_circle = shape:Circle|nothing
```
but `&{x:100, y:200}:Point.x` is a bit confusing. because `.x` and the actual struct on which we get x field is far from it.
so, visually, it is difficult to read.
`maybe_circle = shape:Circle|nothing`
we can use `T::V` notation.
`maybe_circle = Circle|nothing::shape`
`Point::&{100, 200}`
```
Point = struct {x:int, y:int}
Point = struct {int, int}
&{100, 200}
Point::&{100, 200}
Point::&{x:100, y:200}
Point::&{point1, z: 10, delta: 99}
myint_var = MyInt::12
my_circle = Circle::shape
maybe_circle = Circle|nothing::shape
```
still, `Circle::shape.radius` looks strange. we need more separators/surrounders
which means we cannot use `:` or `::`
`MyInt:(12)`
```
Point = struct {x:int, y:int}
Point = struct {int, int}
&{100, 200}
Point:(&{100, 200}) #this is not good. too many letters
Point:(&{x:100, y:200})
Point:(&{point1, z: 10, delta: 99})
myint_var = MyInt:(12)
my_circle = Circle:(shape)
maybe_circle = Circle|nothing:(shape)
```
what about this? we need `struct` and `&` to make struct distinct from code block.
what if we use a different notation?
`Point:(&{x:100, y:200}`
go: `rectangle{10.5, 25.10, "red"}`
why not force type for all struct literals? when do we need a struct literal without type? when we want to return multiple items from a fn.
maybe we should allow that.
```
Point = struct {x:int, y:int}
Point = struct {int, int}
&{100, 200} #this is now invalid
Point{100, 200} #normal struct litearl. type is mandatory
Point{x:100, y:200}
Point{point1, z: 10, delta: 99}
myint_var = MyInt{12}
my_circle = Circle{shape}
maybe_circle = Circle|nothing{shape}
```
and, have a distinct notation for casting.
go: `var b MyInt = MyInt(a)`
```
myint_var = MyInt(12)
my_circle = Circle(shape)
maybe_circle = Circle|nothing(shape)
```
the only problem: we will not know if `T(x)` is a generic function or a type cast.
`MyInt(x)` is def a type cast.
generic function accepts types and only types.
**PROPOSAL**
1. We use `T{...}` notation to define struct literal. Type is mandatory.
2. Casting is done via `T(x)` notation.
3. You can cast a union to `T|nothing` to do a safe check about type inside the union.
4. Remove `${}` notation.
5. Remove `.0` notation to access struct fields.
- when type is mandatory, fields have all names. so `.0` notation is no longer needed.
```
Point = struct {x:int, y:int}
Point = struct {int, int}
Point{100, 200}
Point{x:100, y:200}
Point{point1, z: 10, delta: 99}
myint_var = MyInt(12)
my_circle = Circle(shape)
maybe_circle = Circle|nothing(shape)
```

Y - Allow functions to return multiple items
and ban structs without type.
`x = fn(a:int, b:int -> int,int) { ...  5,6 }`
so on the right side of `->` you write a comma separated type list
and caller must provide bindings for each return, or `_` to ignore it.
`x,y = getTwoValues()`
`x,_ = getTwoValues()`
can this cause confusion when defining a fn?
```
x = fn(x:int->int, float|string, fn(...->...))
```
no. this looks like a natural extension to single return functions.
has no side effect on existing code that returns one type.

Y - a compact ifelse?
kotlin: `val result = if (condition) trueBody else falseBody`
`a = 1 > 2 ? 3 : 4`
Haskell:
```
if var `rem` 2 == 0 
      then putStrLn "Number is Even" 
   else putStrLn "Number is Odd"
```
F#: `if boolean-expression then expression1 [ else expression2 ]`
`result = trueCase if condition else falseCase`
i don't like above because it is a bit confusing. I see `trueCase` but the important part (condition) is coming later and it affects the whole thing.
`result = if condition trueCase else falseCase`
`result = if isValid 100 else 200`
`result = data // 100` this is an if else in itself.
maybe we can modify it.
`result = if data == nothing then data else 100`
`result = data == nothing // data // 100`
`data == nothing // data` will evaluate to nothing if data is nothing
it will evaluate to data if data is not nothing.
`data == nothing // data` ~ `if data == nothing then nothing else data`
`condition // result` ~ `if condition == true then nothing else result`
`condition || result` if condition is not met, then result, else nothing
and we mix above with `//`
`condition || resultFalse // resultTrue`
but this is not intuitive. i want true case to come first.
`result = data == nothing // 100 // data`
`result = cond // trueCase // falseCase`
we can use `//` with boolean
so, if `T // x` and T is not accepting a nothing and T is a boolean then this is if.
`bool_item // x // y` means if bool_item is true then x else y
so this is built of two parts:
1. `bool_item // x` this will evaluate to nothing if bool_item is false.
2. `something // y` this is normal `//` we have seen before.
but using `//` for a different purpose is confusing. 
let's use `::` which means: `A :: B` will evaluate to nothing if A is false, or B if A is true
`A :: B` ~ `if A == true then B else nothing`
so we can write:
`result = data == nothing :: 100 // data`
but how do we separate `// data` to not be included as a part of  `100` expression?
`result = data == nothing :: (100 // data)`
`result = (data == nothing :: 100) // data`
one option:
`result = (data == nothing).{100} // data`
so lets simplify. we don't want ifElse construct.
we want to be able to write this:
`if A == true then B else nothing` having A condition and B expression.
`A.{B}` is one option (we can later mix this with `//` to provide else.
`(A).{B}` to have complete borders
`result = (data == nothing).{100}`
but then we can just use `()`:
`result = (data == nothing) :: (100)`
but still we need a surrounder for the whole things.
`result = (data == nothing :: 100)`
so with else:
`result = (data == nothing :: 100) // data`
`result = (cond :: exp)` ~~ `if cond then result = exp else result = nothing` ~~ `result = [true: exp, false: nothing][cond]`
or `[cond: exp, !cond: nothing][true]`
`result = (data == nothing : 100) // data` no this will become confusing.
**PROPOSAL**:
1. A new operator `::` is added which is a syntax sugar to support if statement.
2. `(exp1 :: exp2)` will first evaluate exp1, if it is true, then result will be exp2, otherwise, it wil be `nothing`.
3. You can mix `::` with `//` to provide ifElse.
Example:
`home_dir = (has_home :: getHomeDir()) // "/root"`
how can we chain these?
`home_dir = (is_root :: "/root") // (is_default_user :: "/default") // (is_unknown :: "unknown") // "/tmp"`
`x = (is_root@ :: helper@)` means evaluate is_root, if error then early return.
if false then x will be nothing. if true then evaluate helper.
q: if I write `cond() :: exp()` when will exp() be evaluated?
- if will not be evaluated (exp will not be called) if cond evaluates to null.
**PROPOSAL**:
1. A new operator `::` is added which is a syntax sugar to support if statement.
2. `(exp1 :: exp2)` will first evaluate exp1, if it is true, then exp2 will be evaluated and determine expression result, otherwise, exp2 will not be evaluated and result will be nothing.
3. You can mix `::` with `//` to provide ifElse.
Example:
`home_dir = (has_home :: getHomeDir()) // "/root"`
how can we chain these?
`home_dir = (is_root :: "/root") // (is_default_user :: "/default") // (is_unknown :: "unknown") // "/tmp"`

Y - Should we formalize docs?
e.g. for functions
normal comments start with `#`
special comments start with `##` as first two characters of the line.
they can be in markdown.
they can appear for:
bindings and types and functions
```
## some documentation about g and what it does
g = ...

## 
some docs about this type
x:int - comments about this input
output - comments about the output
##
DataTypeX = struct {x:int, ...}
```

N - The `..` notation for modules is not common and if we want developers to use module namespaces more, will be difficult to work with.
```
Socket = import("../core/st/socket")
data = Socket..processData(1,2,3)
```
in go we have `fmt.Println`
in Rust we have `char::from_digit(4, 10)`
`..` is weird. 
we have two options:
1. use special naming for modules + `.`
2. use another operator and normal naming
- pony: `use "time" ... time.now()`
- ocaml: `module Gr = Graphics;; Gr.open_graph " 640x480";;`
- hack: `namespace NS2 { use type NS1\{C, I, T};`
- Elm: `import Json.Decode as D ...D.Decoder`
- c++ `ContosoData::ObjectManager mgr;`
- python `import draw ... draw.draw_game(result)`
- ruby `require "trig" require "action"`
y = Trig.sin(Trig::PI/4)
we can use `\` just like the way we address modules.
but these are different things. `\` in the module path represents files, but inside the file we dont have a filesystem.
`x=import '/dsadasd/net/http'`
`x..NetSocket`
`x\NetSocket`
if we go with options 1, it should be a very easy to type prefix/suffix.
with option 2, the operator should be a single keypress.
`->`? no
almost everywhere we use `.` so lets' stick with it. (so we will have `.{a,b,c}` to import multiple items
so, we need a special naming for module items.
these are not bindings. you cannot pass them to a function.
you can only use what is inside them. 
what are one press keys that are easy to type? `,.;'[]`
none of them are good. maybe we should stick with `..`\

Y - In oop languages we can use `a.b.c.d` notation to easily chain multiple function calls. so we can have:
`customers.filter(x -> x.name...).filter(...).map(c -> ddd).allMatch(...)`
but in dotLang, we need to write sth like `allMAtch(map(filter(...` which is not intuitive.
we can put these functions inside seq or map and treat them as structs, but it is not intuitive and also not extensible (what is user defined a new function?).
we need a notation to do the chaining:
F# `100 |> addone |> double`
something like `$`?
`x$addOne` is like `addOne(x)`
then, can we use a struct for multiple elements? no. it makes things complicated, what if we really want to send the struct as input?
what if a fn returns multiple output?
can we still chain them? if so then we should allow for initial chain. a chain with multiple inputs
`x$f`
`(x,y)$f`
`x$f$g` where f produces two inputs and g accepts two inputs
`x$f$g(1,_)`
`(x).f`
`x.(sort(_,1))`
`x..sort(_,10)..map(toInt,_)..`
we can use double dot here.
`(1,2,3)..add3Numbers`
`(1,2)..add3Numbers(100,_,_)`
`get3Numbers..add3Numbers`
so syntax is: 
`binding..lambda` which is same as `lambda(binding)`
`binding.(lambda)`
but we need `()` both for binding and lambda. 
`x >> filter(_, isPositive)`
we use and, or, xor. so `&|^` are available!
`x | filter(_, isPositive)` this makes sense and is compatible with bash notation
`(1,2,3) | add3Numbers`
`students | map(_, convertStudent) | filter(fn(x: Student -> bool) { ... }) | calculateAverage ...`
one good syntax sugar is to say: if lambda on the right side of `|` has only one input we don't need to write `(_)` but that is already there.
what I want is:
`students | filter(isGoodStudent)`
rather than:
`students | filter(isGoodStudent, _)`
`filter = fn(x: fn(t: T -> boolean, T: type -> fn(list: [T]->[T])) { ... }`
we can act like Haskell and say if f has two inputs, giving only one of its inputs, creates a lambda that has one input.
but that is too much change.
UNION TYPE USES `|`
`students || filter(isGoodStudent, _)`
`student ^ filter(isGoodStudent, _) ^ map(createNewStudent, _) ^ calculateAverage`
`map(createNewStudent, _)`
if you really want to have the simple notation of `map(xyz)` then write appropriate function.
a function that accepting a mapping function, generates a mapper function that accepting a sequence, generates a new sequence.
**PROPOSAL**
1. Introduce `^` operator for function call composition. So rather than `f(g(x))` we can write `x ^ g ^ f`

Y - Its better to use `::` for composition because it is easier to type.
`f(g(x))` becomes `x :: g :: f`
and for conditional, where `x ? y` evaluates to y if x is true, othertise nothing, we can use `^`?
or maybe `?` and it makes sense
`home_dir = (is_root ? "/root") // (is_default_user ? "/default") // (is_unknown ? "unknown") // "/tmp"`

N - Maybe we should change comment character. so we can write code easily in markdown code block.
this seems fine
```
#dsada
x = 12
```

N - a use case: Chromedp library in golang. we have different command types (e.g. getDocument, getComputedCss, getSnapshot, ...)
and each command has its own optional set of parameters.
for example, getDocument has an optional depth, so they design it like this:
```go
dom.GetDocument().WithDepth(-1).Do(ctx)
```
so, when you call getDocument, you just get an empty struct with no parameters.
by calling `withDepth` you set value for depth inside that struct.
then calling `Do` will perform that action.
`Do` and `withDepth` and `withPierce` are functions defined for the type generated via `getDocument`.
So, people have optionality and also visibility: by pressing dot they can see all available options they can do.
in D we have UFCS, uniform function call syntax:
```
void func(X thisObj);

X obj;
obj.func();
```
we can support that.
what if x is a struct?
then pressing `.` in the IDE, will show its members + all functions that accept x as their first argument.
`x.print` calls `print(x)`
what about functions in other modules?
`x.module1..draw()` calls `modules..draw(x)` because draw has one argument of type T and type of x is T.
by combining this and named types, we can achieve above goal.
But this does not work well with modules and also with functions that return multiple elements.
we have `::` which can be used to achieve something similar to above.

N - Can we say, excluding last argument(s) from function call creates a lambda?
`add = fn(x:int, y:int -> int) ...`
`add5 = add(5)`
maybe change function decl to something like Haskell?
`add = fn(x:int -> y:int -> int)`
then `add(1)` will give you a lambda
`add(1,2)` will give you an int
this will make fn composition easier:
`5 :: add(4)` means `add(4, 5)`
what about this? `5,4 :: add`
or `5 :: 4 :: add`  no this is not correct.
`(5,4) :: add` is same as `5,4 :: add`
can we use this to model multiple outputs?
`getData = (x:int -> int -> int)`? if we pass an int, we will get a function that gives us two integers? no.
`getData = (x:int -> int,int)` multiple items can be only be at the end of the list
if we force `fn(x:int -> y:int -> int)` notation, then are we still allowed to write
`fn(x:int, y:int -> int`)? no. there should only be one way to do something.
in Scala we have: `def modN(n: Int)(x: Int) = ((x % n) == 0)`
`println(filter(nums, modN(2)))`
and it is called currying.
another option: let function writer handle this:
instead of `getData = (x:int -> int -> int)`
function writer can write: `getData = fn(x:int -> fn(int->int))`
this is better, needs to change and gives fn writer option to decide about this.


N - How can we have streams in dotlang?
In java there are two types of streams:
- used to work woth collections in a declarative mannger (e.g. map this array, filter this hashtable, ...): this is already there 
- used to read a series of data where we don't know about size/end.
In Java the base stream class has these:
- close
- read
- reset
- skip
also we can write to a stream.
what are applications?
- reading from a file
- reading from network
- reading from a memory region
they all have an internal "position reference" or "next avialable byte" which means they are inherently mutable.
just like createChannel, we can have `createStream` with all the custom logic we need.

N - Early return via `@` notation?
`result = validateData(a,b,c)@{makeError(InvalidArgument)}`
i'm not sure if it is worth that.

N - Extensibility
there are three types:
- function overriding: multiple functions with the same name accepting different arguments
- generic: one function one code block but works with multiple instantiations of one generic type
- subtyping: one function one code block but work with different types that have something in common
do we need third item above?
for example: a function that prints out customer name:
`Customer = struct {name: string, address: string}`
`printCustomer = fn(c: Customer -> ...)`
and you can call it with whatever type you want as long as it has fields of a customer (same name and type)
so you can call it with Employee too (if employee struct has string name and string address)
```
Employee = {name: string, address: string, empId: int}
e = createEmployee()
printCustomer(e)
```
if we want above there are two options:
1. Allow it built-in: you can just pass it and compiler/runtime will handle conversion
2. Allow for more powerful casting: not only you can cast float to int, but also you can cast Employee to Customer (because they have same field name and types)
second option is more powerful and less disuptive to the current status.
first option above is called Structural Type System (https://en.wikipedia.org/wiki/Structural_type_system)
> Structural subtyping is arguably more flexible than nominative subtyping, as it permits the creation of ad hoc types and protocols; 
also first item allows you to define a function which accepts empty struct, and you can call it with anything you want.
the opposite of 1 is nominal subtyping where types should explicitly declare their parent types.
maybe we can mix 1 and 2: you can cast struct type A to B if A has all the fields of B in the beginning.
this either means in A definition, you explicitly mention B fields, or embed B inside A.
so first way (mentioning B fields) is the normal way.
but the second way, embedding, needs some syntax:
```
Customer = struct {name: string, address: string}
Employee = {Customer, empId: int}
```
but again, you don't really need this new notation. you can define a field in Employee of type Customer:
```
Customer = struct {name: string, address: string}
Employee = {c: Customer, empId: int}
printCustomer = fn(c: Customer -> ...)
e = createEmployee()
printCustomer(e.c)
```
In Golang you have above but with noname embedded struct, you don't need to explicitly mention name:
```
type Ball struct {
    Radius   int
    Material string
}
type Football struct {
    Ball
}
//Here Football has all the fields of Ball
func (b Ball) Bounce() {
    fmt.Printf("Bouncing ball %+v\n", b)
}
//so, if you have a function which works on a Ball
fb := Football{Ball{Radius: 5, Material: "leather"}}
fb.Bounce()
//you can call it on with a FootBall
```
I prefer the explicit method, where you add a field of type Ball in FootBall struct and have functions that accept Ball.
```
Customer = struct {name: string, address: string}
Employee = {c: Customer, empId: int}
printCustomer = fn(c: Customer -> ...)
e = createEmployee()
printCustomer(e.c)
```

N - Trait/type-classes/toString/getHashCode/serialize/compare
We sometimes need to implement something for our types to be used everywhere
e.g. to be used as a map in hash function, you must have a way to calculate hashCode. This is done 
by runtime/compiler for basic types (int, function, seq, ...) but you can override or write for your own types.
first problem with this is it is a bit hidden, there are things that happen behind the scene and are not explicit.
but it doesn't have to.
there are two use cases:
1. Key type for map must have a way to get hashcode
2. my generic function can only accept type Ts where T has some functions supported.
basically 2, is explicit version of 1. 1 is special use case and it hidden in nature (when declaring a map, I don't specify any requirement or hash function).
also 1 can be modelled via 2 (a generic function in core to create a map but expects a key type which has functions provided)
so the scope is:
- When defining a generic function accepting generic types T, U, V, ..., I want to be able to put restrictions on these types.
- By restrictions, I mean there should be appropriate functions defined for these types.
- Now, as soon as we want a function there are 2 questions: what is the function name? and what is the function signature?
- We can specify signature because it is the core requirement. but what about name?
- e.g. a find function on a sequence of type T, needs a comparison function.
- But we can accept that comparison function as a function argument.
- yes we can. but the point of this feature is to make things easy. So we don't have to pass a function all the time.
- when we want to make things easy, there are certain decisions that language designer/compiler/runtime make instead of the developer.
- so this by default decreases flexibility.
as a result, this is essentially a tradeoff between flexibility and easy of use.
high flexibility: define function input arguments based on what you expect from your generic types. Anyone calls you fn need to provide those functions.
`finder = fn(a: T, b: [T], comparator: fn(T,T->bool)...`
ease of use: implicitly define expectations for your functions and anyone who calls your function, needs to use types that meet those expectations.
`finder = fn(a: T, b: [T]) [eq(T)]`
`eq = fn!(a: T, b: T, T: type -> bool)`
for above case, `eq` is not a binding, because we don't want to provide a code block as the default impl for equality check.
so, it is a type.
`Eq = fn(T, T, T: type -> bool)`
this is a generic type. a generic data type. doesn't it need a fn?
```
Eq = fn(T: type -> type) {
    fn(T, T -> boolean)
}
```
maybe. but anyway, `Eq(T)` is a type for a function that checks equality of two bindings of type T.
now, easiest way to have this feature is:
`finder = fn(a: T, b: [T], T: Eq(type)) ...`
this means, e.g. if I cann finder with an int:
`finder = fn(a: int, b: [int], T: Eq(int))...`
so, T must be of type `Eq(int)` which means, T must be a function?
no. 
T can be any type, but we filter that to the types that support Eq. but how are they going to support that?
if we allow for implicit support it will be hidden, automatic and less flexible.
if we allow for explicit support, then even if a type does not already support, you can easily define a redirect function with support and redirect to the function that does the job.
so, we want "explicit support" which means, a function explicitly says: yes I implement Eq for type `int`.
and in finder function I can write:
`finder = fn(a: T, b: [T], T: type+Eq) ...`
q for future: what about multi-type constraints?
for now, let's focus on single type constraints.
so, we have a finder function:
`finder = fn(a: T, b: [T], T: type+Eq) ...`
and Eq type:
```
Eq = fn(T: type -> type) {
    fn(T, T -> boolean)
}
```
this means, you can call finder with any type you want, as long as it satisfies Eq type contraint. 
Note that type constraint is just a type itself. (q: can type constraint be a struct? why not)
you can define a type constraint as:
```
HasNameField = struct {name: string}
getData = (a: T, T: type + HasNameField)...
```
and inside getData you can refer to `a.name`
although this does not make a lot of sense. if you want that, don't define a generic function. just define a function with `name: string` argument.
so let's say, generic type constraints can only be functions.
```
Eq = fn(T: type -> type) {
    fn(T, T -> boolean)
}
finder = fn(a: T, b: [T], T: type+Eq) ...
```
Now, we have a generic type (nothing new) and we have a finder function (`+ Eq` is new).
You can call the generic `finder` function with any input, as long as input has a type T which satisfies `Eq`
This means, there should be a function with some name, in the current namespace, which explicitly declares implementing `Eq` and has a suitable syntax.
ok. suppose I have a very complex type called `Constituent` but two constituents are equal if just two of their fields are equal. I don't need to compare rest of 100 fields.
```
Constituent = struct { id: string, field1: string, field2: int, field3: float, field4: string, ...}
```
or let's work on a different example: `toString` - suppose a log function writes to some output and needs to convert input to string.
```
Stringer = fn(T: type -> type) {
    fn(T -> string)
}
log = fn(a: T, T: type+Stringer) ...
```
but then I can just call string function on constituent myself.
I'm not sure, but this new addition to language `+Eq` and a new notation to explicitly say this function implements this type constraint.
Maybe it's too much. 
old proposals:
```
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn!eq(a: int, b:int -> bool ) { ... }
eqString = fn!string(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = fn!eq(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
...
process = fn(a: T, b: T, T: type -> int) [ eq(T) ] {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
```
#A
eq = fn(a: T, b: T, T: type -> bool) = 0

#B
eqInt = fn(a: int, b:int -> bool ) [implements eq] { ... }
eqString = fn(a: string, b: string -> bool) [implements eq] { ... }
eqStack = fn(a: Stack(T), b: Stack(T), T: type -> bool) [implements eq]  ... #we dont write type after eq. compiler will infer
eqIntStack = fn(a: Stack(int), b: Stack(int) -> bool) [implements eq] ... #you cannot impl eqStack because it is not a signature function

#C
process = fn(a: T, b: T, T: type -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```

N - Should we allow for varargs functions?
Now that we want to do most of built-in stuff via functions, they can make things easy. rather than defining a seq type and literal,
we define function vararg.
for example to simulate switch statement, or enum matching or printf.
`switch = fn(x: [T], handlers: fn(T->boolean)...`
in golang:
```
func sum(nums ...int) {
    fmt.Print(nums, " ")
    total := 0
    for _, num := range nums {
        total += num
    }
    fmt.Println(total)
}
```
and what happens inside the function?
the variadic argument will be a normal sequence. you can check its length or get its elements.
**PROPOSAL**
1. Allow for variadic functions: these functions can have one last argument of type `T...` which means caller can send any (including 0) number of items for that argument.
2. Inside the function, the variadic is just a normal sequence.
q: what if a variadic fn wants to call another variadic fn? can it just pass `x` input arg? it should be.
so:
**PROPOSAL**
1. Allow variadic functions `sum = fn(x: int... -> int)`
2. Inside function, variadic arg is just a sequence
3. You can call a variadic function with a list of items `1,2,3,4,...` or just pass a sequence instead: `[1,2,3,4]`
4. Above helps a variadic function call another variadic function.
we have this in Java, Scala and Golang.
q: can't we change it and say: if last arg of a function is a sequence, you can write a list of literals.
this should be possible if seq and variadic want to be interchangeable.
then what real advantage does variadic give us?
here is argues that variadic is not essential and without it lang will be simpler:
https://pointersgonewild.com/2012/02/27/are-variadic-functions-necessary/
so, no.

N - List of statements that we have: 
- assignment (`a = b`)
- run in parallel (`a := b`)
- ensure
- import `_ = import(...)`

N - Should we add some notations to mix switch with enums?
or maybe we can add a function, but how is it going to check we have covered all cases for the enum?
`DayOfWeek = enum [saturday, sunday, ...]`
enums look like array. we can define a function to accept enum type + map of value to handler to do the job.
and that function can use core to check we have covered all enum cases.
so we just need a function in core to let us know about enum cases and check if we have all of them covered.
But we cannot define sucj a function. because that will be a generic function which can only accept enums.
no other language has this. why should we?
I don't like adding a new keyword for this. maybe we can still use a normal function.
core can give us a function to return number/values of an enum, or nothing if it is nt enum. 
and a generic function can use this.
but that above core function is not a runtime function, it is a compile time function
which is fine.
**PROPOSAL**
1. Add this to enum section: Core has functions to convert enum type name to a sequence of values + a function to act as a switch statement which also,
makes sure all cases of the enum are covered.

Y - Should we allow creation of a struct without any type?
for example for `switch` function we need a tuple: value and handler.
if data matches with the value, then handler will run. now if we don't want to define a new struct type for this tuple, 
we can just write:
`switch = fn(data: T, struct{value: T, handler: fn(T->int)}... -> ...)`
and call it via:
`switch(my_number, {value: 10, handler: AAA}, {value: 12, handler: BBB}, {value: 13, handler: CCC})`
no prefix is not good. there must be something.
`_` is an option, although it has many other usages.
`&{value: 12, handler: AAA}` is also good.
`Point2new = Point{100, 200}` is ok so we can even write:
`&{12, AAA}`
but on the caller side, all fields have names.
**PROPOSAL**:
1. You can use `&{...}` notation to create a tuple on the fly without any specific type.
but what if I write: `x = &{10, 20, 30}`
then what is type of x? how can I access fields inside x?
but why would someone need to create a tuple on the fly without a type? why not define separate bindings?
if you want to pass them to some other function, you need a type for them.
solution: no change. you still need types. but you can omit them if they are available.
**PROPOSAL**
1. If type of struct can be inferred from the context, then you can omit type when writing a struct literal and replace with `&`.
this is a syntax sugar.
so you can write: `switch(my_number, &{value: 10, handler: AAA}, &{12, BBB}, &{13, CCC})`

N - If fn returns multuple items, will `@{...}` support that?
yes why not.
`callProcess()@{1,2,3}` if call process failed, return these 3 integers.

Y - With early return `@{}` we now have a case for defer.
defer: close a connection, close a file, release a resource, ...
we advertise for transparency and "everything happens because of a developer's command".
So this type of "automatic release behind the scene" is not a very good thing.
but otoh, compiler has all the information it needs to decide about closing something (maybe we need to formalise that).
just like function resolution which does not need explicit instructions from developer.
we can say: if we have a function called `close = fn(x: T ...)` then anywhere using a binding of type T, this function will be called.
but again, it is too much hidden stuff.
so, what can we do? should developer decide when to close a file?
and what if they forget?
- close a file, db connection, open sql statement, socket, context, channel, ...
just like error handling where we force user to take an action in case of error, it is also better to be explicit here too.
even though compiler can infer stuff, it is better if developer explicitly closes resources.
this also frees us from "close/dispose function name" protocol and makes things more flexible.
so it is like `defer` or `finally`.
`conclude`
`eventually`
maybe we can mix this with "post-requirement": crystal has `ensure`
but post-req is sth totally different.
**PROPOSAL**:
1. In a function body, we can use `ensure fn{expression}` whic means lambda will be called after function is finished (either normally or early return via `@`)
example:
```
f = fileOpen(...)
ensure fn{fileClose(f)}
```
can we refer to function output inside ensure? if yes then it can be used to implement post-requirements
```
process = fn(x:int -> a:int, b:int) {
	...
    ensure fn{a>0}
    ensure fn{b>0}
}
```
ensure just calls the function. throwing error or logging something or ... should be done by the user.
option1: functions can define a name for their output
option2: ensure can be either an inputless function, or a function with input matching function output and no output.
in the latter case, input to ensure function will be output of the parent function.
```
process = fn(x:int -> int, int) {
	...
    ensure fn{a>0}
    ensure fn{b>0}
    ensure fn(x:int, y:int ->) {...}
}
```
option 2 does not need any change in the notation. we re-use functions with ensure.
if a function has no output, then case 1 and 2 are the same and we cannot have any kind of post-check.
`ensure` does not imply it will run "at the end of function execution".
- ensure
- eventual
- conclude
- final
- finally
- defer
and it only applies to current semantic function. not higher ups.
q: what if we have multiple defers? they will run in reverse order just like golang.
q: what if we have defer inside defer? what comes after defer is a function. so it can have its own "defer" but they will be its own, not for the parent function.
q: defer inside `@{}` block? not allowed. because you can only have exp inside early ret block. defer is a stmt.
**PROPOSAL**
1. You can use `defer lambda` notation to tell runtime to call lambda after function finished. lambda has no output.
2. lambda can be inputless (called finalizer), or accepting inputs matching with parent function (called post condition).
3. the lambda for defer, is a normal function so it can have its own defer.
---
we have another option: destructors for structs.
but there are two problems:
- it is a bit hidden still
- not flexible enough. e.g. what about closing a channel easrlier than function close, or post-req?
defer in Go: 
> This actually has nothing to do with not having "classes" in Go: the language designers just avoid magic as much as practically possible.
But are we going to have GC? If not, then C++ way may make more sense: destructors.
and similarly, we do have ctors.
types of gc: mark-and-sweep or tracing, reference counting
Discussion of pro/cons of above two: http://flyingfrogblog.blogspot.com/2013/09/how-do-reference-counting-and-tracing.html
ref counting:
- during compilation, compiler inserts statements like `retaing` and `release` to keep track of ref count for any reference
- if reference count drops to zero, it can be freed at the spot. so it is deterministic.
- so it is not a background process.
mark-and-sweep vs. ref count performance can be seen in androind vs ios performance.
But can't this be checked later? Do we need to know type of GC in advance for lang design?

we definitely need clean-up code for our objects.
m&s or tracing: Java,Go: no dtor, `defer` in golang, `finalize` in Java
refcount: Swift, C++ (with smart pointers): has dtor
problem is, when I allocate an OS socket, I want to be able to release it as soon as possible because it is a precious system resource.
now, if in future we decide to do m&s, can we still use destructors?
or, if in future we decide to use refcount, can we still use `defer`?
can we make choise of GC method independent from release mechanism?
I don't like dtor because it is hidden. I like things to be transparent and "manual".
so, if I pick `defer` method and later decide to go with refcount, would that be possible and make sense?
let's assume we have `defer` system and we want to use refcount GC.
I think actually, this will even help GC because its logic will be easier. It won't need to "call" any dtor.
so there are two things:
1. manage memeory (release, allocation) - this is handled via GC (m&s or ref-count)
2. manage resources (this is handled via defer)
for the second item, we definitely need defer because each resource has its own release mechanism.
**PROPOSAL**
1. You can use `defer lambda` notation to tell runtime to call lambda after function finished (after leaving function body). 
2. The defer lambda has no output and can have no input (called finaliser) or inputs same as parent function output (called post condition)
3. the lambda for defer, is a normal function so it can have its own defer.
---
so we have these control mechanism:
1. `@{}` notation
2. normal exit
2. defer
another option: use dtor. they will be automatically called when they are moved out of scope. and maybe they can be called explicitly.
so, when defining a struct, you also have an option to define dtor.
rust does that. automatic drop call when resource is no longer needed.
**ambiguity 1 with defer: what if I release sth in defer but return it?**
```
defer fileClose(f)
...
return f
```
and we really don't know post-condition check because in case of error there is no such check and in case of happy path, we can simply insert the code to do that.
what about nested dtor? 
we can say dtor is defined as:
- for primitives, seq and hash: free their memory and their elements
- for structs: free memory and call their dtor function
q: what if map has n elements? do we also free key and values? yes. c++ does.
problem with dtor is being hidden.
the ambiguity of defer, assumes fileClose function closese a file. but this is a mutation.
bigger issue with defer is that it is inherently doing mutation.
**defer pros** - explicit and transparent and more flexible
**defer cons** - ambiguous - what if we release/unallocate something in defer and then return it (e.g. close a socket or kill a process)
**dtor pros** - will only release something which is going out of scope
**dtor cons** - it is hidden and implicit and not flexible
can we make defer non-ambiguougs? for example, if something is checked on defer, it cannot be returned. but it is confusing.
can we make dtor explicit? maybe tell developer they have to call dtor in their code. in that case it will not be dtor, but will be `deinit`
and, we can say any binding which is deinited, cannot be returned.
and you call deinit with `x = _` notation. 
but this is also confusing. I want to be able to call properly named methods: `closeSocket`, `killProcess`, `destroyConnection`...
these functions are mutating. they change something that makes the binding unusable. so we cannot refer to the binding after call or return it.
so, we can have any function we want and call it in a defer block. But how can we prevent return? in a simple, elegant manner?
```
conn = openConnection(...)
defer fn{closeConnection(conn)}
...
return conn
```
how can we prevent above scenario naturally?
we can say, defer runs just before return. so return cannot refer to something released in a defer.
or, we can "bind" defer code to the binding so that when binding is out of scope, that defer will run.
it can run when current function finishes. or when parent function is done or ...
so we, attach a dtor to it. Basically, we combine dtor and defer: it is explicit because we must attach the code and it is flexible because its our code.
but this must be done when the binding is introduced. 
q: can a binding have multiple dtors?
with dtor it is just one. but with defer we have the same issue. we may call fileClose multiple times in the defer code.
let's for now forget about this ambiguity.
```
file = fileOpen(...)
file.deinit = fn{...}
```
the "binding" between deinit code and the binding can be done in a struct field.
we are immutable, so we can create a copy or ask creator to set deinit field for us.
```
file = fileOpen(..., fn(x: File ->){...})
```
so, whenever file is out of scope, the deinit lambda will be called.
but deinit, cannot be inputless. in that case it can do anything.
it must have one and only one input which is the binding to be dtored.
or, we can even use eisting functions
`file = fileOpen(..., fileCloseHandler)`
fileCloseHandler is a function which accepts a File.
so, we can only have one handler. even though chaining is possible by developer.
```
file = fileOpen(...)
actualFile = File{file, _destructor: fn{...}}
```
it is a bit, verbose and confusing. because then we should say this is a "special" attribute for a struct.
and has special treatment.
what about using through a keyword?
```
file = fileOpen(...)
defer file :: fileClose(_) #1
vs. defer fileClose(file) #2
```
number 1 is our option.
number 2 is the Golang version. in number 2, we don't know the subject of defer. 
so, we can only call the code whatever it is, at the end of the function.
and also, no 2 is too flexible. you can write anything.
but 1 is a bit more restricted. you must have a function with only one input.
`defer file :: fileClose(_)` means: when `file` bindign is out of scope and no longer referenced, call `fileClose` for it.
so it is explicit, transparent, flexible, works with scope so doesn't get trapped with return with ambiguity
the only concern: what if I call it more than once?
I think this can be a compiler error or runtime error.
or we can support multiple calls. just call all of them in fifo order.
`finalise file :: fileClose(_)`
after this, you can still return the file. this finalize code will stay with the file binding, until it goes out of scope.
and it works with any bindings.
but, can't runtime do this automatically? for any binding, call correct dtor when it goes out of scope.
because, under what circumstance, do we want to call something other than `fileClose` for a file which is moving out of scope?
I think this is a 1-1 mapping between type and dtor. 
it is good to force developer to do stuff so code is better maintained, but not for trivial stuff which is easy to do with compiler.
```
PointTemplate = struct{x:int, y:int}
    fn{
        assert(x>0)
        assert(y<0)
        assert(x+y<100)
        log("a new instance of point-template is created")
        validateCheck(x, y)
    }
```
the validation function needs access to struct fields. which is why we need to have it there.
but outside struct, is really counter intuitive and different.
can't we move both validate and dtor inside struct?
```
PointTemplate = struct{x:int, y:int, 
	_invariant:}
```
if we move these inside struct, we have to have same notation of `A:B` then we have to find a field name for them which makes things complicated.
```
PointTemplate = struct{x:int, y:int}
    fn{
        assert(x>0)
        assert(y<0)
        assert(x+y<100)
        log("a new instance of point-template is created")
        validateCheck(x, y)
    }, fn{
        fileClose(handler)
    }
```
can't we make use of `{}` for struct type decl?
we don't want to call another fn because we need to pass all needed parameters.
but, what if I write `f2 = f1` and f1 goes out of scope. this function should not be called because we still have f2.
so, the code will only run when binding is out of scope and no longer referenced (depending on GC strategy).
we want to define these functions but don't (can't) define them inside struct block.
and also, these functions are not part of type. are they?
if I have `struct{int,int}` can I assign binding of that type to a PointTemplate binding?
no. they are different types. so these two functions ARE part of type.but we don't want to put them inside struct.
maybe we can even define them separately. in that case, they don't need closure-like access. they accept an instance of that type.
```
PointTemplate = struct{x:int, y:int}
    fn(p: PointTemplate->) {
        assert(x>0)
        assert(y<0)
        assert(x+y<100)
        log("a new instance of point-template is created")
        validateCheck(x, y)
    }, fn(p: PointTemplate->) {
        fileClose(handler)
    }
```
or
```
PointTemplate = struct {x:int, y:int} invariantFunc, deInitFunc
```
can we extend this notation for other useful functions like `toString` or `hashCode`?
```
PointTemplate = struct{x:int, y:int}
    {
        _invariant = fn(p: PointTemplate->) {
            assert(x>0)
            log("a new instance of point-template is created")
            validateCheck(x, y)
        }
        _destructor = fn(p: PointTemplate->) {
            fileClose(handler)
        }
    }
```
why not put function outside struct section?
```
PointTemplate = struct{x:int, y:int}

_invariant = fn(p: PointTemplate->) {
    assert(x>0)
    log("a new instance of point-template is created")
    validateCheck(x, y)
}

_destructor = fn(p: PointTemplate->) {
    fileClose(handler)
}
_toString = fn(p:PointTemplate->string){
    ...
}
```
Is this not like protocol/interface? but single type?
so, we can say: any type that supports this function is implementing this protocol.
`_toString: fn(x: T, T: type -> string)`
no. this is too complex.
for above cases, just define whatever function you want and pass it to wherver needs to convert T to string.
we need this mechanism for special cases where runtime needs to do stuff. you cannot pass functions to runtime because you don't 
know when exactly is binding going to be out of scope.
```
PointTemplate = struct{x:int, y:int}

_invariant = fn(p: PointTemplate->) {
    assert(x>0)
    log("a new instance of point-template is created")
    validateCheck(x, y)
}

_destructor = fn(p: PointTemplate->) {
    fileClose(handler)
}
```
but if we decouple them so much, then it will become confusing.
q: can we set default values for struct members? if so, we can use fields with default name.
so, if a struct field has default value, you cannot change it.
```
PointTemplate = struct{x:int, y:int, 
    _invariant: fn(x: PointTemplate->) = pointChecker,
    _destructor: fn(x: PointTemplate->) = pointDeinit
}
```
no one can stop developer to continue the same and define e.g. toString:
```
PointTemplate = struct{x:int, y:int, 
    _invariant = pointChecker,
    _destructor = pointDeinit,
    _toString = ...,
    _myFunc = ...,
    _calculateHashCode = ...,
    _isEqualTo = ...
}
```
so, all above fields are normal fields with the change that you set value for them.
the only special fields are `_invariant` and `_destructor`.
**PROPOSAL**
1. When defining a struct, you can set values for some of the fields. These won't accept values when struct is instantiated.
2. There are 2 special values for a struct that are used by runtime, if defined.
3. `_invariant` is the validation logic. a function that accepts parent type and returns nothing.
4. `_destructor` is de-init code. called via runtime when binding is out of scope and no longer needed.
---
why not follow the same with other functions like hashCode, toString, ...? and make them special.
so when I write `string(my_point)` compiler will call `_toString` for `my_point` if defined.
but what for? instead of `string(my_point)` just call `my_point._toString()`.
for any case where you manually call a function, you don't need a support from compiler/runtime.
The support is only needed for invaraiant and dtor.
But again this is binding data and behavior, at language design level. 
we don't want this.
In Rust, you never have to close a socket.
But, how many system resources do we have? file, socket, net, ...
we can handle them at core level. so, if you have a very custom data type that needs resource release, do it yourself and don't rely on runtime 
to do it for you.
but, it is not orth. having something for "special" types but not for user types.
so we want to 1) unbind data from behavior, even if behavior is critical. 2) allow this dtor for all types.
but I don't want to have a case where dev A defines type T without dtor and dev B who uses type T, defines a dtor for it.
one option: when creating a struct, also provide invariant and dtor for it.
but what if developer forgets? maybe we can force it?
```
File = struct { ... }
my_file = File{...} ???
```
No. creator cannot state what invariant should be for a type.
**defer pros** - explicit and transparent and more flexible
**defer cons** - ambiguous - what if we release/unallocate something in defer and then return it (e.g. close a socket or kill a process)
**dtor pros** - will only release something which is going out of scope
**dtor cons** - it is hidden and implicit and not flexible
why not use defer, but run the lambda when binding goes out of scope?
so if we destroy binding in defer but return it, defer will not run until binding is out of scope.
so, it changes from `defer lambda` to `defer binding lambda`
but still it will be confusing. because in a function, if I get a file handle, should I assign a fileClose for it or is it already done?
and also, the dtor is fixed. you shouldn't be able to provide your own lambda here.
so we get back to the previous option: bind a function to a struct as invariant or dtor.
and if we do that, we should be able to do other stuff functions too: which means OOP like classes.
if we do that, structs will have some fields + some functions. isn't it same as a module?
then we can say, import's output will give you a struct!!! that you can pick from. then we no longer need `..` notation because
"module is a struct".
except for types. if we allow for types to be defined inside a struct, then they will match completely.
we had this discussion before and decided not to do this.
*cases against allowing function inside struct, which makes struct same as module*
- q1: what is output of import? is it struct type or a struct itself?
- "defining functions inside structs is nice but will be a huge problem when solving expression problem. "
- "fn inside struct, can we allow it to have access to parent struct? no. because we assume functions and structs are totally different. "
- https://github.com/ziglang/zig/issues/1250
- "But if you then decide to allow "functions on structs" you kill that uniformity. "
So, let's not do this. Struct can only have "data" (including function pointers but not actual functions).
and behavior will be outside struct as independent functions.
now, we want to bind one or more functions to a struct. these functions cal validate or destruct struct when needed.
how can we bind and not bind?
why do we need this?
Examples fro k8s repo:
```
storage, _, server := newStorage(t)
defer server.Terminate(t)
defer storage.Store.DestroyFunc()

s.RLock()
defer s.RUnlock()

tf := cmdtesting.NewTestFactory().WithNamespace("non-default")
defer tf.Cleanup()

_, s, closeFn := framework.RunAMaster(nil)
defer closeFn()

s, err := m.OpenService(service)
if err != nil {
    return fmt.Errorf("could not access service %s: %v", service, err)
}
defer s.Close()
	
ctx, cancel := cloud.ContextWithCallTimeout()
defer cancel()
```
I think we can fix defer's con:
**defer cons** - ambiguous - what if we release/unallocate something in defer and then return it (e.g. close a socket or kill a process)
we can say it will throw a runtime error or if compiler can, it will throw compiler error.
so, we do not bind dtor to struct. we just define it there prob with a convention.
and in the code user has to manually, explicitly call it:
```
file = fileOpen(...)
defer fileClose(file)
```
this change is mutation of the state. is it ok with multi-thread or immutability?
we do this when leaving function. so no one will longer access this.
can we make it more clear what binding is worked with in a defer block?
like: `defer(file) fileClose(_)`
dtor way needs binding between struct and dtor function which is not good.
**PROPOSAL**
1. For precious resources (built in or user defined), there is a release function defined.
2. After instantiating the resource, you can use `defer release_func` to invoke release function when resource goes out of scope.
---
But this makes no sense. If it "MUST" be called, then why not do it automatically?
because then there needs to be a binding. 
and if we allow for binding of a type to resource release function, then it should be allowed for other actions too.
or maybe not. We can only allow for release. not for other purposes.
```
Point = {x:int, y:int} fn{validation}, ~fn{destroy logic}
```
we definitely want to keep functions outside the type, not inside struct. because this will mean binding data and behavior.
but, putting them after the type definition is not very readable.
can't we put them as standalone functions?
like tests: `Module level functions that start with _test and have no input are considered unit test functions.`
We can have a naming convention. but what if we have a type alias?
```
Point = struct {...}
_Point_dtor = fn(...)
MyPoint : Point
_MyPoint_dtor = fn(...)???
```
nope. this must be done at the point of type decl to avoid confusions with type alias, named type and naming conventions.
so, this extends struct type declaration.
```
Point = struct {x: int, y:int} 
```
This is an important topics because it affects robustness and reliability of apps.
Example of resource:
> anything that needs to be cleaned-up (file handle,sockets, locks, values from a foreign runtime...)
In golang, you have to manually close a socket or file. so why not do the same here?
Rob Pike: Clear is better than clever.
> Instead of hiding resource management somewhere else, manage the resources as closely to the code where they are used and as explicitly as you possibly can.
q: what if we release/unallocate something in defer and then return it?
I don't want to force developer to specify binding which is freed in defer. because it will be a limitation.
but, if I write `defer fileClose(h)` and I am returning `h` in the function, what should happen?
issue is, I always assume immutability. with this assumption, `fileClose(h)` makes no change to `h`
but resource management is all about mutation: mutate a socket, connection, file, memory range, ...
so, I think this is the bigger issue with defer: if we allow user to decide when/what to release, it exposes mutation to the application.
and this is against some important assumptions.
**defer pros** - explicit, transparent, flexible
**defer cons** - ambiguous, exposes mutation
**dtor pros** - hides mutation, handles out of scope so no issue with return + release
**dtor cons** - hidden, implicit, not flexible, needs binding of a function to a piece of data
so, let's focus on cons of dtor:
- not flexible: you should be able to define dtor for any of your types, that is all flexibility we can provide
- implicit: if it was explicit it would expose mutation, you can make it explicit by a syntax though: `x = _` for example
- hidden: same as above, we need to hide details here, or else developer can access mutated variable
- binding of type to function: the big issue
**Proposal**
1. Type owner can define dtor for the type which will run when bindings of that type go out of scope
2. There should be a mechanism to manually invoke dtor like `x = _` so compiler can also check x is no longer used
3. big question: how should dtor be defined for a type?
---
dtor: 
- should be bound to a type so that type alias or named type cannot make it confusing
- should be a normal function. we don't want to "invent" something new.
Maybe we can mis-use casting notation. So, dtor will run when you cast a type to `nothing`.
now, it allows people to write a casting for a type if it is not already defined but that does not do any harm.
we add support for defining custom casting functions.
BUT then we will have same name functions!
```
Point = struct {x:int, y:int}
nothing = fn(item: Point) { ... } #then we will have lot of functions with same name
_ = fn(item:Point) {...} #does not make sense
```
or: 
we can define a function named same as type. BUT they are named differently. 
that's fine. this is a special function. so it will be named like a type. 
it will then look like generic functions.
but for now lets ignore that.
```
Point = struct {x:int, y:int}
^Ponit = fn(item: Point -> nothing) { validation code }
~Point = fn(item: Point -> nothing) { dtor code }
```
above works fine. is explicit, flexible, no need to bind function to the type.
hides immutability of the data. 
but what I don't like is the fact that we add two new notations. I prefer names/keywords rather than `%W$#$#@$~`
- if we use a fixed name like `dtor` then we will have multiple functions with the same name
- if we use prefix char then it will be confusing
- if we use random names, then how can we bind?
we can do sth else:
- inside struct def, define a field of specific type. set value of it to the dtor function
- or we can say dtor function should have the same name as that field
```
Point = struct {x:int, y:int, _dtor: fn(x: Point -> nothing)
```
but with `~TT` naming convention we still have the issue of type alias and named types.
so these functions MUST attach to the type definition, and because they are not going to be part of a struct, they can be defined for any named type.
```
Point = struct{x:int, y:int}, 
	validate = fn(x: Point -> nothing) {...}
	destroy = fn(x:Point -> nothing) {...}
```
OR: we can just discard this whole thing. no dtor, no defer, no custom deinit, ...
user cannot define custom dtor. for special resources of the system, runtime automatically handles that. 
no need to worry from user side. 
it is not very flexible and it is hidden and cannot be controlled much but using this way we avoid a can of worm.
and also, user can manually call dtor function if they like.
but opening a connection without closing it, looks a bit weird. but this is what C++ is doing all the time.
RAII is important and so is deterministic destruction.
other option: allow assigning values to bindings inside struct.
but do not go further so that modules will be separate from structs.
q: if we have nested structs, how does closure work for these functions?
let's not have closure at all. module is different from struct, no type in struct.
**Proposal**
1. You can define validator and dtor for a struct type and set values.
2. This will give you some kind of oop like behavior.
3. some of struct fields can have compile-time values.
4. when creating a new binding of struct type, you cannot set value for those fields.
---
what else do we want to support?
Java object has these methods:
- toString
- equals
- getHashCode
- validate
- finalise
q is: can we extend this? but this binding of struct and function prevents extension of existing types.
```
Point = struct { x:int, y:int,
	 validate = func(x: Point -> nothing) { ... }
}
...
p = Point{...}
p.validate(p)??? yes you can call it like this.
```
struct does not give you closure. function does.
so struct members which are functions with values (like dtor or vtor) do not have direct access to their owner struct fields.
so, let's just limit this to vtor and dtor:
```
Point = struct { x:int, y:int,
	 _ = func(x: Point -> nothing) { ... } #destructor
	 _ = func(x: Point -> nothing) { ... }
}
...
p = Point{...}
p.validate(p)??? yes you can call it like this.
```
BUT this is still confusing. what if I have:
`p = Point{...}`
`q = Point{...}`
the `p.dtor(q)` or `q.dtor(p)`. are they different? p and q are not the same. so how can I know if p.dtor and q.dtor are same?
so:
- we cannot add function inside struct because of confusion with modules and naming and requiring a new exception for struct
- we cannot add function outside struct because then it will be confusing. others can add it for types that don't already have it. and name needs to be unique.
what about tagging proposal we had before?
**Proposal**
1. We can tag a function with another function type
2. tag is like interface
3. we have special tags to define validator and dtor
4. we can have custom tags for toString, getHashCode, ...
5. generic functions can use custom tags to define their expectations.
6. and we don't support multi-type tags.
```
vtor = fn!(a:T, T: type -> nothing) 
dtor = fn!(a:T, T: type -> nothing)
socketDtor = fn!dtor(a: Socket -> nothing) ...
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = fn!eq(a: int, b:int -> bool ) { ... }
eqString = fn!string(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = fn!eq(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
...
process = fn(a: T, b: T, T: type+eq -> int) {
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
tagging concept is not very obvious. mixing tag name in `fn!` is not very good.
```
vtor = fn!(a:T, T: type -> nothing) #this is a type generator. call it and it will generate a new function type
dtor = fn!(a:T, T: type -> nothing)
socketDtor = [dtor] fn(a: Socket -> nothing) ...
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = [eq] fn(a: int, b:int -> bool ) { ... }
eqString = [eq] fn(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = [eq] fn(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
...
type.eq means AND of type and eq. type means all types. eq means all types that implemented eq contract
process = fn(a: T, b: T, T: type.eq -> int) { #if eq has not default impl, then T must have implemented eq contract
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
we can call it contract instead of interface or tag.
How do we refer to all of the types that have implemented eq contract? `T: type.eq`
but dot is for structs.
`T: type&eq` `&` is used for automatic type inference for struct literal.
`T: type+eq` is good.
```
vtor = fn(a:T, T: type -> nothing) #this is a type generator. call it and it will generate a new function type
dtor = fn!(a:T, T: type -> nothing)
socketDtor = [dtor] fn(a: Socket -> nothing) ...
eq = fn!(a: T, b: T, T: type -> bool) { default impl }
eqInt = [eq] fn(a: int, b:int -> bool ) { ... }
eqString = [eq] fn(a: string, b: string -> bool) { ... }
eqStack = fn!eq(a: Stack(T), b: Stack(T), T: type -> bool) ... #we dont write type after eq. compiler will infer
eqIntStack = [eq] fn(a: Stack(int), b: Stack(int) -> bool) ... #you cannot impl eqStack because it is not a signature function
...
type.eq means AND of type and eq. type means all types. eq means all types that implemented eq contract
process = fn(a: T, b: T, T: type.eq -> int) { #if eq has not default impl, then T must have implemented eq contract
    bool_val = eq(a, b) #here we call the function that implements eq signature and matches with type of a and b
    bool2_val = eq(int_stack1, int_stack2)
}
```
no.
confusing. lots of new notations. means more connections means less flexibility.
let's define function outside struct. but it must come exactly after struct. nothing in between.
```
Point = struct { ... } +myCustomValidatorFunction -pointDestructor
myCustomValidatorFunction = fn(x: Point -> nothing ) { ... }
pointDestructor = fn(x: Point -> nothing ) { ... }
```
`+x` means run function x exactly after an instance of this struct is created.
`-x` means run function x after an instance of this struct is gone.
with above notation, you don't need to put functions exactly after struct. but it would make sense to do so.
we should be able to write `fn` directly, or to mention function name.
```
Point = struct { ... }
	+fn(x: Point->nothing){...}
	-deleteMyPoint
```
q: can we do this for other types too? like a sequence where it makes sure it only has N elements?
q: how can I explicitly call this?
- vtor is called automatically. but dtor can be called via `x = _`. after this line, you cannot refer to x.
```
Point = struct { ... }
	+fn(x: Point->nothing){...}
	~deleteMyPoint
```
**Proposal**
1. You can define validator and destructor for named types.
2. Validator function is defined with `+` prefix, `~` for destructor.
3. validator is called exactly after an instance is created
4. destructor is called exactly after instance is gone out of scope.
---
but actually, we only need this for struct. what do we have other than struct? seq, map, primitive
none of these are system resources.
so, let's bind it to struct definition
```
Point = struct { ... }
	+fn(x: Point->nothing){...}
	~deleteMyPoint
```
this is a 3 element. there should be a separator.
```
Point = struct {
	x: int,
	y: int,
	Point(x: Point -> nothing) {...}
	~Point(x: Point -> nothing) {...}
}
```
q: what if we make everything more explicit? both vtor and dtor.
you can define a vtor for your type in which case, user must call it to create that type.
you can define a dtor for your type in which case, user can use `defer` to invoke it.
Another proposal:
1. no need to treat vtor differently. Just define a creator function that does all the logic and ask users to call that, rather than `Type{...}`
2. dtor is a simple function.
3. `defer` keyword can be used to invoke dtor explicitly. must be used.
q: what if I refer to something after calling dtor? compiler does now know if `f(x)` is a dtor or not.
q: dtor exposes mutation. and is ambiguous. 
But this makes no sense. If it "MUST" be called, then why not do it automatically? because automatic, means lot of notations to make it explicit what needs to be called.
returning a destructed binding, is a runtime error.
like golang working with a closed channel.
how should dtor work? not all dtors expose mutations.
we can add a notation to say after calling this function with input X, you can no longer use X. but that will be a lot or notation and memory requirements in dev mind.
we can also throw runtime error.
q: if I call `process(file)` will it close my file?
we can say: you can destruct a binding only if you have created it. but how are we supposed to know if a function call will destruct the binding?
**if we allow developer to manually, explicitly destruct a precious system resource, it will expose mutation to the outside world.**
1. no need to treat vtor differently. Just define a creator function that does all the logic and ask users to call that, rather than `Type{...}`
2. No support for dtor or defer. Runtime will handle those resources which are limited.
BUT this means we can only define those resources in core! db connection, socket, file, ...
but, what am I supposed to do in dotLang for example to close a file? not call os/system/core level functions?
ok, in order by bypass immutability concerns, I can write `x = _` after which x is not reachable.
but what if X is already being used in parallel code.
nope! 
**the only valid case which has no confusion and does not endanger immutability, is automatic resource release by runtime when it is safe to do so**
which means, when binding is not in scope, release it.
and it is only needed for some special resources:
- file
- socket
- thread
- process
if we allow `fileClose` function, then it implies mutation. so we shuold not have such a function.
even `x=_` is like that.
**Proposal**:
1. no need to treat vtor differently. Just define a creator function that does all the logic and ask users to call that, rather than `Type{...}`
2. No support for dtor or defer or `x=_`. Runtime will handle those resources which are limited, and release them when they are no longer referenced.

Y - instead of adding a fn after struct for validation, can't we define it inside struct definition?
like a field named `validate` inside the struct?
no. against our rule of separation of data from behavior.
but, we can define a function to create instance of the struct. and inside that function we can implement that logic.
`x = Point{....}` this can call a function to create/post-process a new instance of Point.
maybe we can use custom casting function. 
based on above, we can use `+x` notation.
```
Point = struct { ... }
	+validatePoint
	~deleteMyPoint
```
we don't need it at language level.



? - What are top examples of apps that must be written in dotLang?
- app server
- web server
- database
- jq
...?


? - Golang has two important features: subtyping by struct embedding and support for interface
nominal subtyping: types are sub only if explicitly specified
structural subtyping: types are sub, only if they struct like that
if we have a function that sorts a list of supertypes, can it also work on list of subtypes?
A pitfall of structural typing versus nominative typing is that two separately defined types intended for different purposes, but accidentally holding the same properties (e.g. both composed of a pair of integers), could be considered the same type by the type system, simply because they happen to have identical structure.
http://whiley.org/2010/12/13/why-not-use-structural-subtyping/: The issue is really about what is more important: flexibility or safety.
assume we have a function that sorts Humans. We have a list of employees but each employee is a human (has a human field or has attrbiutes common with human struct).
so how can I use this function to sort employee list?
we can limit it, exclude anything non-struct and demand composition, not inclusion.
```
Human = struct {...}
Employee = struct{ h: Human, ... }
```
now you can pass an employee to a function that needs human
`processHuman(my_employee)`
but you can easily write: `processHuman(my_employee.h)`
but, what if you have a seq? or a map of them? or a graph/tree/list or other data structures?
q: does this affect named types as being separate types?
q: what if Employee has two attributes of type human?
q: How deep do we go? do we also check struct types inside employee.h?
I think this will make compiler difficult.
it reads human, but when writing output, it should write parent.
note that this does not involve runtime function call dispatch.
another idea:
if there is a function F that works with Human and I have a list of employees or any other type, I can call F but pass employee + an implicit conversion function.
so i don't generate a new type. All types already exist.
I just pass type T, where type S is expected, but also pass `fn(T->S)` with it. usually this conversion is simple and can be inlined by compiler.
```
T = struct {x:int}
S = struct {y:int, z: float}
process = fn(x:T->nothing) { ...}
s_item = createS(100,1.1)
#now I want to call process, but pass s_item
process(s_item+fn(s:S->T){s.y})
```
what about more complicated types? like a tree? or a map?
nope. this needs to be automatic. either by explicit marking from developer, or implicitly by runtime based on rules.
this cannot be done by passing a simple lambda. type may be at different locations (or types).
so if we want to have this, there needs to be rules.
subtyping: Allows me to call functions that need shape with a circle
what if function returns a shape? what if function calls another function that needs circle? or shape?
another way: manual conversion to fit with target function's requirement
because there is no mutation, function can only read data.
https://news.ycombinator.com/item?id=20583176: SML gets this right in my opinion. If I create a record `{foo = "abc", bar = 123}`, I can pass that record on to ANY function that needs a record that looks like {foo:string, bar:int} fields because it looks at the structure rather than the type of the record constructor.
https://wiki.c2.com/?NominativeAndStructuralTyping: Many of the statically-typed FunctionalProgrammingLanguages, such as HaskellLanguage and the numerous variants of ML, are structurally typed.
structural subtyping is also not very safe. because they can be misused. In this system, for example, WeightInKg and WeightInLb are same. so you can pass any of them to a function that needs them. because they both have a floating number attribute.
but we can limit that: types are interchangeanle with their child structs.
so, `Circle = {s: Shape, r: float}` then Circle can be treated as a Shape. e.g. sent to a function that needs a shape.
or a seq of circles can be sent to a function that needs a seq of shapes.
what about field name?
what if Circle has two shapes?
https://news.ycombinator.com/item?id=13253066: Go doesn't have subtyping. It has coercions,
Go does not have function overloading so maybe this (subtyping) is enough to make language useful enough.
if we have `Circle = struct {s: Shape, t: Shape, x: float}` then calling a shape function with an instance of circle will cause confusion.
q: what if circle has `Shape|nothing`? can I send it to a function that expects `Shape|nothing`?
what about `Shap|int`? if we limit this to structs, it won't work well with union types.
so let's say: You can pass type T to a function that needs type S, if T is a struct and has a field of type `S`.
what if T has Y and Y has S?
this ends to all sorts of confusions and questions. for each of them, either we need to add a new rule or a new limit or exception or convention.
alternative: don't do it. developer can just write a map/conversion to convert S to T as he needs.
