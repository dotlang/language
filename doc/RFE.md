
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

? - Can I treat file/socket/console and all other IOs as channels?

? - We can use closure to provide encapsulation and privacy.

? - Should we make `dispose` more built-in?
`dispose(x)`
`x = ` no x is suppose to be immutable.
`_ = x`
`nothing = x`
`x = nothing`
but isn't this against immutability?
what if another thread is using x?
I think you should not be able to dispose anything.
Just some specific functions that can be used to close a file, ...
and they are typed, so you cannot call them with any other type

? - If underscore has no meaning, why not ban it?
so underscore will be for destruction and lambda creation
so putting `_` at the beginning of a binding/type name can have a special meaning? or it can be banned.

