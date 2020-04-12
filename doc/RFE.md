X - Our goal is to minimize number of stuff the developer needs to keep in their head

X - Not only dot is easy for users, it should also be easy for developers.
so they should not need a lot to set up a dev env.

X - Use protothreads for lightweight threads implementation

X - Everything is a file
Use this for stdio, sockets, ... 
inspire from linux Kernel

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




? - A dedicated syntax for error handling?
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
1. There is a new core type: `error = struct (key: type, message: string|nothing, location: string|nothing, cause: error|nothing)`.
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


? - Do we allow struct values without field name?
`x = Point(1,2)`

? - We should provide some sane defaults and compiler helps for union types. 
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
2. any matching function, will be explicitly marked as having the signature type.
example: `toStringInt: ToStrSignature(int) = fn(x:int -> string) { ...}`
3. you can use `&` to invoke any of child functions matching with a signature type and pass required arguments.
example: `str_val = ToStrSignature&(int_var)`
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
