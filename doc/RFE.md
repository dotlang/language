N - Add to pattern section: Stack, Tree, loop

N - Allowing functions in a struct is just like defining a function to create instances of the struct.
And initialising those lambda fields inside that function and calling it to create a new struct.
It is a useful simplification. No new concept is added. Everything is the same: Closure, function, ...

N - Can we import a module inside a struct definition?
Or import it "into" a struct definition?
The code inside the module has access to outer world's functions. So it will compile without an issue.
But the code outside will not have access to a module which is inside a struct. Because then it needs to prefix with type name or instance name.
This can be used to resolve name conflicts in a much easier way.
option 1: Import statement inside struct definition
option 2: Assign output of import to a new struct type
This will not be a struct you want to instantiate because everything is type-level. 
option 2 is simpler.
But what about types?
Nope. Having types inside a struct does not make sense at all.
But what if we import it there? So we can "use" their types and bindings but they will not be part of struct and they will not be available outside the struct.
```
Customer = 
{
    @["/core/st/Helper"]
    name: string,
    family: string,
    g: HelperType
}
```
But it doesn't make sense to use `g` in Customer without importing the module.

N - How can I import a sequence of modules? Because now, sequence is not built-in.

Y - Why we cannot assign a generic function to a lambda?
```
process = (T: type, x: T -> x.name)
```
then how can I have a pointer to process?
`g = process(_,_)` then: `g(int, 22)`?
But I also can call `g(string, "A")`?
what would be type of g then? `g: (T: type, x:T -> string)`
But similarly, I can call `process(int, 22)` which will throw a compiler error!
So compiler just needs to track what function does a lambda point to, so that when there is a call, it can generate the source for that function if needed.
If we keep that data during compilation, we can allow assigning generic functions to a lambda.
One less constraint

N - What new things can we do with instance and type level functions?

N - Recent changes:
+ vararg
+ generics
+ byte
+ ptr 
- seq
- map
- compile time sequence

N - Can user play with `ptr`? e.g. by having address of the first element of sequence, calculate address of the second item (x+4)?
we can do it via core functions.

N - Can we replace vararg with a linked list?
I don't think so. we can do it the other way around: build LL using vararg function.

N - How can I have recursive processing for variadic functions?
just use core functions.
`getVar(input, 3)` get a new variadic arg from 4th element afterwards

? - Can we move channels to core?
Then we will have `rchan[int]` and `wchan[int]`
They definitely cannot be in std.
This will simplify concurrency section.
If we provide some underlying structure, channels can be moved to std.
Buffered channel is like a linked list. It is not easy but can be done with some effort.
Let's just focus on a syncronous channel.
Basically it is a linked list with 0 or 1 elements.
If no element -> block
if one element -> delete and return.
But this can be subject to concurrency issues if we don't do it atomically.
Linux API support for concurrency:
- mutex: `mutex_lock` and unlock
- semapure: `down` and up
mutex is a binary semaphore
so we just need to have support for semaphore.
and semaphore is defined like this:
```
struct semaphore {
    raw_spinlock_t        lock;
    unsigned int        count;
    struct list_head    wait_list;
};
```
so internally, it uses a spinlock for sync. this lock is used to protect when counter is going to be changed.
spinlock is a lock/release data structure. if another thread has locked it, your lock will wait until it is released.
But all these locks are to protect data modification. We don't have any mutable data so what are we going to protect?
In Erlang, threads send messages to each other. 
Also there are other applications for channel: file, network, console, ...
But are they?
Can we make this simpler?
Maybe a single channel type? Or just a lock?
Lock is not enough because we also need data. 
Maybe if we can simplify channels, `select` can be simplified too.
another solution can be something like Erlang: Each thread (or green thread) has a channel (implicit). That you can query or send.
we can say: `x := process(10)` will create x as a messageBox.
inside process you can write: `data = receive()` to get data from the messagebox.
and you can write: `send(x, my_data)` to send.
x is like a channel. You can pass x to any other thread to send data to.
But how can we "receive" data from a thread?
Let's say `x := process(10)` will reutrn an int, which is code-id (cid) or thread-id.
Then you write `send(x, 100)` to send something to process.
priority? You can filter when receiving:
`data = receive(my_cid, {priority: high})`
and note that, send/receive can be done on any type. So these must be in core.
`x := process(10)`
`send(x, int, 100)`
`int_num = receive(my_cid, int)`
any code can get it's cid with a call to core. 
cid=0 is for the main app.
when sending, we just send a data to a cid.
when receiving, we specify type and filter. type is mandatory but filter is optional.
so this means, we won't need channels, ro, wo, `!` and `?`. only functions and `int`.
what about select? Select is used to see which channel has a data.
similarly, we have multiple cids, and we want to do a receive (or send) on them.
1. this can be a vararg function
q: select
q: buffered channel
state of a process should be embedded in the arguments of the function. state change = recursive call with new state
`data = receive(my_cid, PriorityMessage, {priority: high})`
idea: threads can join to a group. when send, you can send to a group. when receive you can receive from a group
a thread can be member of multiple groups.
send to a group? what does that mean? it is just multiple send.
send to a group is intuitive, it is basically multiple sends in one statement.
but receive from a group: it will act like a select: if you receive from a group of 10 workers, (let's call them workers rather than CID or thread or process or ...)
maybe 5 of them have something for you.
Who should decide worker's group? itself? or the caller?
I think worker should be dummy. They don't need to know their group. They just send and receive message and do their job.
```
x := process(10)
y := process(20)
z := process(30)
new_cid := {x, y, z}
send(new_cid, int, 10)
receive(new_cid, int)
```
The above receive call will act like this select:
```
select {
    x: ...
    y: ...
    z: ...
}
```
The first worker which has a data, will return and we are done.
If multiple -> only one is returned.
If none -> block?
In Docker, 90% of selects are for read/receive. Why complicate everything with a select that mixes read and write?
how can we handle variable number of workers with group receive?
```
x := process(10)
y := process(20)
z := process(30)
new_cid := {x, y, z}
send(new_cid, int, 10)
receive(new_cid, int)
```
q: How can we get result of `process` if called async using `:=`?
answer:
```
x := process(10)
g = receive(x, int, {type: RESULT})
```
q: buffered channel -> everything is unboundedly buffered, sync via core functions
q: how can we detect if a worker is finished? core function.
q: select
q: variable number of recipients?
we can have `receive` and `blockReceive` so we can say if nothing there, wait (or `peek` and `receive`)
buffered: workers have unbounded mailbox.
so send will never block. but receive may.
maybe we should also have `pid := int` and use it for worker id.
in Erlang, receive does not block unless queue is empty: "If the end of the queue is reached, the process blocks (stops execution) and waits until a new message is received and this procedure is repeated."
the problem is sync-async is easily solvable.
in other words, we only have worker communications: workers send data to each other and they call `receive` to get them. we do not receive from a specific process, we just receive from my own mailbox.  of course we can add "sender-cid" just like priority.
0 is for main app worker
1 for stdin
2 for stdout
3 for stderr
q: maybe we should make sender, a standard part of messages. this can affect select support too.
also we may want to send a message and wait until the message is received (like golang send to a non-buffered channel)
but we can implement this via messages too.
send and wait for a message from this cid with this type.
select = receive from multiple cids - like a normal receive block if no message matches with this
select = receive with multiple cids
```
x := process(10)
g = receive(int, x) #receive an integer from x
data, cid = receiveMulti(int, filter, x, y, z) #receive an integer from any of these channels
```
we can also have similar for send:
`sendMulti(data, x, y, z)`
but as send never blocks, this is same as multiple calls.
blocking send can be implemented via send and receive (waiting for ack).
blocking receive is already provided.
BUT we don't receive "from" a specific cid.
We just receive from current inbox.
so rather than receiveMulti we can simply use receive but with a more complicated filter: receive a message of this type, where sender_cid is any of these.
if none, it will block as it should be.
how can we provide "or" in the filter?
1. use a struct to provide multiple values
2. use lambda
```
x := process(10)
y := process(20)
z := process(30)
Message = [T: type -> {sender: cid, data: T}]
g = receive(Message[int], {sender: {x,y,z}}) #g will contain a sender field
originator = g.sender
data = g.data
```
lambda solution is too flexible and difficult to optimize




? - End a function with `...}` to imply it should be called forever?
so how can we exit?

? - Why do we need `ptr` type? Can't we just use `int`?
Or just define it as `ptr := int`

? - Constraints with `type`?
`type{name:string}` is a struct with string name field
`type{}` is a struct
`type{draw:(int->int)}` has this function
`process = (T: type, x: type{get:(->T)})`
It is not really needed.
`Data = [T: type -> {name: string, data: T}]`
`writeName = (x: Data[_] -> print(x.name))`
Suppose that I have a type which has a name:string and data:int.
can I call `writeName` with that type?
```
HasName = [T: type -> {name: string}]
Customer = {age:int, id: int, name:string}

writeName = (x: HasName[_] -> print(x.name))
#can I call this?
writeName(my_customer)
```
I don't think so. It is against function resolution rules.
What if we also have a writeName with Customer?
Statically it is allowed because they are two different functions.
But with above proposal, there will be confusion which one to call.
the good thing about go is that the set of functions you can call for a specific type are flexible.
You can easily add support for function f to type T. If f uses an interface and you provide appropriate functions for T it will work fine.

? - Should have an easier conflict resolution method?
for methods with the same name or types with same name

? - Rather than channels, can we provide "tools" to build channels in the core?
we can build a channel using a mutex (what about immutability?).
and it is how channels are made.
Let's provide lowest level and let the code (core or std) implement higher levels.

? - And the problem of cache.
Most of solutions add some kind of opaqueness and confusion to the system.
