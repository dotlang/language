
? - Use protothreads for lightweight threads implementation

? - Everything is a file
Use this for stdio, sockets, ... 
inspire from linux Kernel

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

? - The concept of process mailbox means a lot of stuff in the background.
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



? - if I have a sequence of `fn(->int|float)` can I put a function that returns int, in that sequence?
I should be able to do that.
`x: fn(->int|string) = fn(->int) {...}`

? - Can I treat file/socket/console and all other IOs as channels?
or maybe I can say: everything is a file.

? - We can use closure to provide encapsulation and privacy.
that is what is used in js.

? - Should we make `dispose` more built-in?
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


? - If underscore has no meaning, why not ban it?
so underscore will be for destruction and lambda creation only.
so putting `_` at the beginning of a binding/type name can have a special meaning? or it can be banned.

? - Question: What comes on the right side of `:` when defining a type alias?
can I put a generic function on the right side?
no. type alias is for named types. `identifier : identifier`
