
? - Use protothreads for lightweight threads implementation

? - Everything is a file
Use this for stdio, sockets, ... 
inspire from linux Kernel

? - We can add a built in function to convert between struct and json.

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

? - Module alias. they will be used a lot.
maybe we should define their own naming convention
