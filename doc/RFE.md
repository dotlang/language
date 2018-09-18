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

N - End a function with `...}` to imply it should be called forever?
so how can we exit?
and 99% of the time we want to recursively call self with a new argument set. so it is not good.

N - Should have an easier conflict resolution method?
for methods with the same name or types with same name
response: we cannot have methods with the same name.

N - Rather than channels, can we provide "tools" to build channels in the core?
we can build a channel using a mutex (what about immutability?).
and it is how channels are made.
Let's provide lowest level and let the code (core or std) implement higher levels.

N - And the problem of cache.
Most of solutions add some kind of opaqueness and confusion to the system.

N - Can we use this matching with messages for a union?
manually provide lambdas for each possible type.
`invoke(circle_or_square, (c: Circle -> ...), (t: Triangle -> ...))`
`invoke = (S,T: type, input: S|T, h1: (S->), h2:(T->))`
but what will be the body of the function?
receiving a `type` based on what is inside a union is dangerous.
maybe we can check for match types: `bool m1 = matchType(circle_or_square, h1)`
or: `tryInvoke(h1, circle_or_square, nothing)` try to invoke h1 with `circle_or_square`, if not possible return `nothing`.
`tryInvoke = (T: type, h: (T->), input: ?, default: x -> ?)`
`multiInvoke = (S,T: type, h1: (T->), input: ?, default: x -> ?)`
No. We have cast which returns a bool. That's enough.

N - If we can treat union like a struct, we can add member functions for it.
But can simply define a struct containing the union + member functions.

N - Constraints with `type`?
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
constraint for type can be checked at compile time. but for other types will be at runtime.
we can add this but I'm not sure about it's usefullness.
e.g. constraint to union -> only it's cases can be added (for candidateHandlers in polymorphism)
e.g. constraints to struct -> only for types with that members
```
Shape = Circle | Triangle | Square
ShapeType = type|Shape|
CandidateList = [T: ShapeType -> {X: ShapeType, handler: (T->), next: nothing|CandidateList[_]}]
```
and for struct:
```
QueryMessage = {key: string}
UpdateMessage = {key: string, data: int}
MessageType = type{key: string}
processMessage = (T: MessageType, msg: T -> msg.key)
...
processMessage(QueryMessage, q_msg)
```
Too much complication and not very much benefits.

N - Why do we need `ptr` type? Can't we just use `int`?
Or just define it as `ptr := int`
or `Ptr := int`
But it is not only a number. We need to keep track of size of the region too.
So let's just say it will be handled by core.

Y - Add to patterns: conditionals
How can we do this without sequence?
using indexed access to a memory region
add as a function in std
```
ifElse = (T: type, cond: bool, trueCase: T, falseCase:T -> get(T, int(cond), falseCase, trueCase)
get = (T: type, index: int, items: T... -> getVar(items, index))
```

N - Assigning to a binding which is not defined yet, make reading code difficult.
```
process = (->out:int) 
{
    out = f(out2)
    out2 = g(out3)
    out3 = ...
}
```
This was introduced to prevent declaring conditionals and early return
```
process = (x:int -> out:int)
{
    #if x is negative return early
    ???   
    #else
    out = innerProcess(x)
}
#we can write:
process = (x:int -> out:int)
{
    out = ifElse(x<0, 0, innerProcess(x))
}
```
The goal: make language simpler, more minimal and consistent and easy to read.

N - From go2 design: Error handling
```
x, err := strconv.Atoi(a)
	if err != nil {
		return err
	}
#becomes
handle err { return err }
x := check strconv.Atoi(a)
```
```
process = (x:int, y:int -> out:int)
{
    #if either of x or y are negative return 0
    #else return x+y
    out = ifElse(x<0, 0, out2)
    out2 = ifElse(y<0, 0, out3)
    out3 = x+y
}
```

Y - Can we move channels to core?
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
rather than having struct for field, we can have multiple filters.
```
x := process(10)
y := process(20)
z := process(30)
Message = [T: type -> {sender: cid, data: T}]
g = receive(Message[int], {sender: x}, {sender: y}, {sender: z}) #g will contain a sender field
originator = g.sender
data = g.data
```
But what is the type of `receive`?
`receive = (T: type, filter: {???}... -> T)`
`receive = (T: type, filter: T... -> T)`
So, can we say `{sender: x}` can be of type `Message[int]`?
Can we have this?
```
Point = {x:int, y:int}
f = Point{x: 10}
```
I don't think so. Every field must have a value here.
so, we specify all values for all fields:
`g = receive(Message[int], {sender: x, data: ?}, {sender: y, data: ?}, {sender: z, data: ?})`
q: filter is only for structs. right?
q: How does this whole thing work with union types?
`g = receive(Message[int], (m: Message[int] -> m.sender == x or m.sender == y or m.sender == z))`
then type of receive will be:
`receive = (T: type, lambda: (T->bool))`
Erlang does this via pattern.
Giving a message to a lambda which developer has written is a bit dangerous.
Basically, even the first argument of receive (type) is a filter.
`g = receive({type: Message[int], sender: {x,y,z}})`
what if we repeat sender?
`g = receive({type: Message[int], sender: x, sender: y, sender: z})`
we want to be able to receive from a dynamic number of senders. so this should be more flexible.
With lambda: 
`g = receive(Message[int], (m: Message[int] -> contains(senderList, m.sender))`
It will work fine with multiple dynamic number of senders too.
we can also use lambda for type!
`g = receive((m: Message[int] -> m.type == Message[int] and contains(senderList, m.sender))`
But as receive needs a generic type anyway, we don't need to repeat it:
`g = receive(Message[int], (m: Message[int] -> contains(senderList, m.sender))`
**proposal**
1. No channel notation, no channel send or receive
2. `:=` will return a worker id (wid) which can be used to send and receive data
3. Any two workers, can send message to each other: `send(my_data, wid1)`. which returns whether message was sent or not.
4. Any worker, can receive messages (block if nothing): `receive(int)`
5. You can also provide a filter for receive (only of this sender, ...)
6. Receive with multiple senders is like select
7. Send is not blocking, but if you need ack, you can receive and wait for "ack" response from recipient wid.
how can we say, receive anything? at least we have to know type.
other than that: a lambda that returns true for everything
How can we have a timeout for receive wait? use a special worker which returns what we want after a timeout.
send to a finished worker: it will return.
suggestion: we can add a bool return to send so we know whether message was delivered or not. e.g. is process is terminated, send will return false.
what about receive? What if I receive from a process which is already terminated?
To get result of a function (or exit code of a worker), we can use core: send me an update when this worker is finished
`coreRegister(wid1)` will send a message to current worker, when wid1 is finished.
receive from a terminated process will never work. It will never return.
How this works with file, console, network? You can get a wid any way you want.
```
std = 1  #in and out
send(std, "Hello")
send(std, SubscribeMessage)
```
using 0 for current wid is not good. Because it is not portable. What if I want to send my own wid to another worker?
How can I read from keyboard? with this new worker notation
With channels, you can specifically ask to receive data frmo a channel.
But here you receive from your own inbox.
`name = receive(Message[string], (x: Message[string] -> x.sender == std))`
This is not compatible with channels. With channel, you have a specific communication media so if the other side sends something, you (and only you) will get it.
But with this model, you cannot do it because socket does not know who is the listener.
Unless, we provide our wid when creating a reference to std or socket or ... .
```
socket_wid = createSocket(my_wid, ...)
send(socket_wid, "data")
receive(... sender == socket_wid)
```
Another advantage of this: We can host (migrate) a worker to another machine. It's just a wid.
the lambda for receive check is too much flexibility. can we limit it?
`g = receive(Message[int], (m: Message[int] -> contains(senderList, m.sender))`
user should be able to filter based on any field: sender, type, priority, ...
even if we only allow these fields in the filter, how are we going to handle arrays (dynamic number of values for sender).
`g = receive(Message[int], (m: Message[int] -> contains(senderList, m.sender))`
what if we use generics + lambda? any use of lambda will prevent compiler optomisation and allow room for misuse.
What is the absolute minimum we need here?
in Erlang pattern matching, the pattern must be calculated at compile time.
Anyway, how are we supposed to keep track of workers when their count is dynamic?
one solution: pre-specified range for wid and provide upper and lower bound for them when matching.
another solution: grouping. rather than relying on sender_id, rely on group_id and make it a fixed item.
```
x = process(10, "group1")
y = process(20, "group1")
z = process(30, "group1")
...
message = receive(Message, {sender_group: "group1"})
```
Ok. Now we only need to support a set of name/values for filter. Basically we need a sample 
instance of message type. any message whose fields are exactly same as the sample will be matched.
```
Message = {data: int, sender: wid, sender_group: string, priority: int}
...
msg = receive(Message, {sender_group: "AAA", priority: 1})
```
what about missing fields in the pattern? what is type of filter?
let's say: `nothing` is ignored in the matching process. so:
```
Message = {data: int, sender: wid, sender_group: string, priority: int}
Filter = [T: type
...
msg = receive(Message, {sender_group: "AAA", priority: 1})
```
But group is not always pre-defined or fixed.
I will still need `OR` support in the filter.
What about this: provide a lambda which extracts a field from message, and a value to match.
So filter is a lambda + target value. and we can any number of filters.
```
Filter = [S,T: type -> {lambda: (S->T), target: T}
Message = {sender: int, group: string, data: int}
receive(Message, Filter[Message, int]{lambda: (m: Message -> m.sender), target: s1_wid})
```
In this way we might be able to combine filters: AndFilter, OrFilter, ...
And receive will accept only one filter.
```
Message = {sender: int, group: string, data: int}
```
Scala pattern matching supports boolean predicates:
```
notification match {
    case Email(email, _, _) if importantPeopleInfo.contains(email) =>
      "You got an email from special someone!"
```
Basically, this is like polymorphism: a number of handlers for a number of cases (types: circle, triangle, ...) and an unknown
```
ReceiveHandler = [T: type -> {predicate: (T->bool), handler: (T->)}]
receive = (T: type, handlers: {predicate: (T->bool), handler: (T->)}...)
...
receive(Message, {predicate:(m: Message -> m.sender = 12), action:(m: Message -> processNormal(m))}, 
                 {predicate:(m: Message -> m.sender = 14), action:(m: Message -> processImp(m))})
```
Seems that predicate with lambda is the most practical solution. 
We can add a compiler warning if this predicate is not a simple expression.
1. No channel notation, no channel send or receive
2. `:=` will return a worker id (wid) which can be used to send and receive data
3. `was_sent_bool = send(my_data, receiver_wid1)`. 
4. `receive(int, handlers)`
5. Send is not blocking, but if you need ack, you can receive and wait for "ack" response from recipient wid.
6. Send to terminated/invalid wid returns false. receive from terminated/invalid wid will never return
We don't need a handler for receive. we just provide predicate.
```
Predicate = [T: type -> (T->bool)]
receive = (T: type, handler: predicate[T])
...
received_message = receive(Message, (m: Message -> m.sender == 13))
```
We can have a notation for send and receive:
```
was_sent = data>>wid
msg = <<(m: Message -> m.sender=1)
```
It is better for notation to be composable. So I can do something on the result immediately.
`x = <<(m: Message -> m.sender=12).source`
`was_sent = data<wid>`
`msg = {(m: Message -> m.sender=12)}`
`msg = ((m: Message -> m.sender=12))`
`msg = [(m: Message -> m.sender=12)]`
`was_sent = data->wid`
`was_sent = wid!data`
`msg = (m: Message -> m.sender=12)?`
```
was_sent = (wid<<data)
msg = <<(m: Message -> m.sender=1)
```
what about timeout in receive?
before receive we can initiate another micro-thread to send a message after x milliseconds 
```
#initiate a new thread which will send me a message after 300 ms
wid := timeout(my_wid, 300, {flag: false})
msg = <<(m: Message -> true) #wait for any message
{stop}>>wid
```
Let's make both notations the same:
```
was_sent = wid<<data
msg = <<(m: Message -> true)
```
immediate/eventual send
**Proposal**
1. `:=` will return a worker id (wid) which can be used to send and receive data
2. 
```
was_sent = wid<<data
msg = <<(m: Message -> true)
```
3. Send is not blocking, but if you need ack, you can receive and wait for "ack" response from recipient wid.
4. Send to terminated/invalid wid returns false. receive from terminated/invalid wid will never return
```
was_sent = wid<-data
msg = my_wid<-(m: Message -> true)
```
```
#it makes more sense to bring data first, when sending
was_sent = data::wid
msg = ::(m: Message -> true)
msg = ::lambda
```
Do we need a notation to represent current wid? I don't think so. put it in core: `currentWid()`
Example:
send and wait for ack:
`data::wid`
`::{sender:wid, type: Ack}`
Let's say after `::` you can put a binding (wait for exact message) or lambda (predicate)
`msg = ::(...)`
`createResponse(msg)::msg.sender`
**Proposal**
1. `:=` will return a worker id (wid) which can be used to send and receive data
2. 
```
was_sent = wid::data
msg = ::(m: Message -> true)
msg = ::(m: Message -> m == {source:1, type:2})
```
3. Send is not blocking, but if you need ack, you can receive and wait for "ack" response from recipient wid.
4. Send to terminated/invalid wid returns false. receive from terminated/invalid wid will never return
`:: msg1, msg2, msg3, lambda` wait for any of these -> no. too confusing.
`:: msg1` or
`:: (...)`
so: you cannot send a message which is a lambda. but this might be useful in some cases.
let's just have lambda. It is more general and you can put it inside a function to make call shorter.
- Let's address some of inefficiencies of actor model: implementing handshake model
- Limit mailbox
Suppose that a process wants to send a message, but wait until it is picked up.
We may want to implement a protocol, so wait after it is picked up for a reply.
```
was_sent = data=>wid
msg = (m: Message -> true)
msg = (m: Message -> m == {source:1, type:2})
```
Why should we have a special notation for this? Can't we rely on core functions?
```
was_sent = send(data, wid)
sendWait(data, wid) #send and wait for message to be picked up
msg = receive(Message, wid, (m: Message -> true)) #receive any message from this sender
msg = receive(Message, nothing, (m: Message -> m == {source:1, type:2})) #receive this specific message from any sender
```
let's put sender in predicate. So we can have a proper select.
```
was_sent = data>>wid
sendWait(data, wid) #send and wait for message to be picked up
msg = <<receive(Message, wid, (m: Message -> true)) #receive any message from this sender
msg = receive(Message, nothing, (m: Message -> m == {source:1, type:2})) #receive this specific message from any sender
```
Defining a notation for something complex like this, needs a lot of conventions which many people would find confusing.
Send, receive, send and wait, ...
Let's just stick to core functions.
```
was_sent = send(data, wid)
sendWait(data, wid) #send and wait for message to be picked up
msg = receive(Message, wid, (m: Message -> true)) #receive any message from this sender
msg = receive(Message, nothing, (m: Message -> m == {source:1, type:2})) #receive this specific message from any sender
```
What about socket, file, ...? which of these are inherently mutable?
file is not. 
```
f = open("a.txt")
data = read(f, int)
```
What if multiple threads read from this file?
```
f := open("a.txt")
send(f, "a.txt") #to write
receive(...)
```

Y - Can we have cache with message passing?
For cache at least we need a way to "receive" without removing item from queue.
But a cache can have a lot of subscribers. ok. They just need to have cache worker's wid.
Then they can receive. But cache is not supposed to send a message to every one of it's subscribers.
A cache can be a worker which accepts two types of messages: store and query
For store, it will update it's internal state for cache data
For query, it will send the result of cache query to the sender process.
With each store, it will call itself with a new state: the new cache which contains the newly added data
```
CacheState = Map[string, int]
cache = (cs: CacheState->)
{
    request = receive(Message[CacheStore])
    new_cache_state = update(cs, request)
    query = receive(Message[CacheQuery])
    result = lookup(new_cache_state, query)
    send(Message{my_wid, query.sender_wid, result})
    cache(new_cache_state)
}
```
This is closure, even inside cache function, we have access to itself.
Add to pattern section

N - Can we convert union to case class like in scala?
Will it make things simpler?
```
#Scala
abstract class Notification
case class Email(sender: String)
case class SMS(caller: String)
case class VoiceRecording(contactName: String)
...
def showNotification(notification: Notification): String = {
  notification match {
    case Email(email, title, _) =>
      s"You got an email from $email with title: $title"
    case SMS(number, message) =>
      s"You got an SMS from $number! Message: $message"
    case VoiceRecording(name, link) =>
      s"you received a Voice Recording from $name! Click the link to hear it: $link"
  }
}
```
maybe we can use a dot notation to make adding a new case to union more intuitive:
```
Shape.Circle = {r: float}
Shape.Square = {s: int}
...
Shape.Triangle = {x: int, y: int}
...
CandidateList = [T: Shape -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

draw = (s: Shape, element: CandidateList[_] -> )
{
    
}
```
But what happens to simple unions like `int | string`?
this is named union so we have to assign a name:
```
Data.Int = int
Data.String = string
process = (x: Data ...
```
Another problem: we cannot enhance it with generics
`Data = [S,T: type -> S|T]`
We cannot use generics because the definition is not in one location. we can
```
Shape.Circle = [T: type -> {r: float, data: T}]
Shape.Square = [T: type -> {s: int, data: T}]
```
And `Shape` can be used to limit number of types for a generic type:
`CandidateList = [T: Shape -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]`
proposal:
- No `|` for union notation. We use `A.B` naming where A is union name and B is subtype name.
- A binding of type A can hold any of the subtypes.
- You can cast a binding of type A to any of it's subtypes to check existence.
- Subtypes can be any type (simple, struct, ...)
advantage: extending an existing union is more intuitive (adding a new shape)
advantage: You can use it to constraint a generic type
q: should we have select for type matching?
q: Can subtype be another union?
```
MessageType.Voice = int
MessageType.SMS = string
QueryType.QType = ...
```
q: what about maybe/optional and DayOfWeek?
The dot notation is a bit confusing with struct. Can we use another notation? e.g. `Shape|Circle`
or think of it as a tag: `Circle@Shape = {...}` - in that case, can we have multiple tags for a type?
dot implies parent/child or container/contained relationship.
`|` implies or relationship.
we can have multiple tags: `Shape|Circle`, `Item|Circle`, ...
`Shape+Circle`
`Shape/Circle`
It should be a composable notation. 
Use regex? ShpCircle, ShpSquare, ... no too complicated
```
DayOfWeek.Saturday = 1 #this is a type which has only one valid value
DayOfWeek.Sunday = 2
...
```
```
Maybe[T: type].Nothing = nothing
Maybe[T: ty[e].Item = T
...
x: Maybe[int]
```
No. This is too complicated.
Can't we use current `Shape` union to restrict possible types?
`CandidateList = [T: Shape -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]`
we can but it will make reading code more difficult.
Let's let it stay the same.
the problem with this union is that it is not composable with generics easily.
We can have generic at union type level and at subtypes level which makes it super confusing:
`Processor[T: type].Handler[S: type] = (S->T)`

Y - Can we make union with constant values more explicit/consistent?
`Shape = Circle | Square`
`DayOfWeek = SAT | SUN ...`
we can introduce fixed types where there is only one valid value for them, like `nothing`.
If right side of type is a constant (compile time calculatable), it defines a fixed type.
```
Sat = 1
Sun = 2
Mon = 3
WeekDay = Sat | Sun | ...
x: WeekDay = Sat
```

N - Can we combine generics?
`process = (T: ||, G: ||, data: G[T] ...`
This is not for language. Mostly for compiler.

Y - Having access to common parts of union types may be confusing at some times.
and hidden.
There should be a way to "declare" those common parts.
So if I write `Shape = Shape | Square` writer of Square knows what should be included.
So what are these common parts? Having specific fields of name + type.
```
Shape = Circle | Triangle { id: int, process: (?->int) }
```
This is applied where we have a Shape and don't know it's actual type.
Why not make it easier to cast?
```
#all shapes have id:int which we want to return here
process = (T: Shape, s: T -> int)
process = (T: Circle, s: T -> s.id) 
```
This can be done via specialisation. or you can cast.

N - If we go ahead with replacing generics notation with union, we can replace polymorphism with generic speciaisation:
`draw = (T: Shape, x: T -> int)`
`draw = (T: Circle, x: Circle -> int) ...`
`draw = (T: Square, x: Square -> int) ...`
`draw(myCircle)` will call draw for Circle
`draw(my_triangle)` will call generic draw (code generated for Triangle)
so, how can I address these in a lambda?
`myLambda = draw(_: Shape, _)`
`myLambda = draw(_:Circle, _:Circle)`
using `_` with lambda hides the fact that argument is a type or a binding.
If we do this, then we will not need `_` notation in generics.
So when using `_` notation to create lambda, we should specify type for some arguments so that compiler will know which one to pick.
Let's think about it like this: It is only one function. Lambda will point to the main one, and depending on the argument values, one of available functions will be used.
```
myPtr = draw(_,_)
myPtr2 = draw
myPtr3 = draw(Circle, _) #this will point to the function for draw with circle
```
What if we have more than one generic arg?
`Shape = Circle | Square`
`Color = Blue | Red`
`draw = (T: Shape, C: Color, shape: T, color: C -> ...`
`draw = (T: Circle, C: Color, shape: T, color: C -> ...`
`draw = (T: Shape, C: Blue, shape: T, color: C -> ...`
`draw(Circle, Blue, my_circle, my_blue_color)` which one will this call?
I think there should be a compiler error. Because third draw conflicts with the second draw.
Any specialisation, should be as specific as possible. Because it marks an entire tree of hierarchy for providing implementation for.
So `(Circle, Color, ...` means any call for a Circle and Red or Blue will be directed to this function.
so when third draw says `(Shape, Blue)` it has conflict because we can call it with `Cirtcle, Red` which conflicts with the second draw.
```

Shape, Color => Circle, Color => Circle, Red
				 Circle, Blue
		Square, Color => Square, Red
				 Square, Blue
```
If you specialise, it will cover every more specialised function. So `(Circle, Color)` will cover `Circle, Red` and `Circle, Blue`
So:
**Proposal**
1. You can specialise a generic function by providing concrete types and same name. They will all be merged as one function.
2. When creating a lambda, you cannot point it to any specific function. You can only provide concrete types when defining the lambda.
3. Any specialisation, will also handle for more specialised functions. This applied for generic functions with more than one type.
4. If there is conflict between specialisations, there will be compiler error.

N - If I allow for union-based generics can I specialise for values?
```
process = (x: int, flag: true|false) ...
process = (x: int, flag: true) ...
process = (x: int, flag: false) ...
```
It will be a bit confusing. If process is called with `true` which function should be called?
Someone would say, the most specific function. But in presence of multiple candidates it is difficult to know which one it will be.
In OOP, it is easy to know the most specific function: it is determined by the runtime type: `my_circle.draw()` will call draw in Circle not Shape.
Think about complexity that this will lead if we allow generics specialisation: multiple implementations under the same name, confusion about resolutions, ...
We are basically simulating inheritance in a little bit more explicit way.
Generics was introduced to solve a different problem: writing reusable code/data types for all types.

N - If we allow using generics with union, In this case, polymorphism can become generics specialisation. If we can do that:
`draw = (T: Shape, x: T -> int)`
`draw = (T: Circle, x: Circle -> int) ...`
`draw = (T: Square, x: Square -> int) ...`
So compiler will generate draw code for Triangle but not Circle and Square. We already have them.

N - We can implement protocol or type-class or interface or trait using unions.
we define functions that a type group should support.
This can provide polymorphism. And if implemented correctly, maybe it won't have confusion and ambiguity of generics specialisation solution.
```
Shape = Circle | Square { draw: (T->) }
Shape = [T: anytype -> {draw: (T->) }
ShapeX = Shape[Circle] | Shape[Square]
```
No. This won't give us polymorphism becase this functionality is not same across all union types: It is different because input of the draw is different.
We can, however, remove that variable type and assume draw will be a member function:
```
Circle = {... draw: (int->string) { ...} }
Square = {... draw: (int->string) {...} }
Shape = {draw:(->)}
Shape = Circle | Square
```
And it is not an active definition: We don't say this is a union of all types that have this
But we say, all types that want to join this union, you must have these fields (name and type).
One way: Define it like a struct but enclosed in `||`:
```
Shape = |draw: (int->string)| #Shape is a union. Any type that you want to add to this union, must have these fields
#currently there is no type in shape
Shape = Shape | Circle #We have already defined draw field inside Circle
Shape = Shape | Square
...
```
How does this affect expression problem? If we want to add a new operation (e.g. print) and we have followed above model, it will not be possible.
Because to add `print`, I will need to change all structs and Shape type and add this function.

N - Use tagged union.
Advantage: With untagged union we should put a rule that "no overlap between types". But with tagged this is allowed.
How will it affect current polymorphism?
Proposal: Drop proposal for using union for generics, use `type` + make unions tagged
How will we have dynamic compile time generics then? 
What is the advantage of amending a union and adding new types to it? `Shape = Shape | Circle`? The only one is to have a type to use for polymorphism.
```
#define Shape type using compile-time dynamic union
Shape = Circle | Triangle | Square
Shape = Shape | Square

#Type of a function candidate which does a specific operation for a specific type.
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]
#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

#The draw function can be invoked on any shape
draw = (s: Shape, element: CandidateList[_] -> ) { #This is the only place where we need a Shape. and we want to make it extensible.
	if element.T is same as internal type of S, then call element.handler and return
	if element.next is nothing then return
	else recursively call with element.next
}
```
To implement polymorphism, the only place where we need a `Shape` is in draw. Can we eliminate it by using generics?
`draw = (T: type, s: T, element: CandidateList[_] -> )`
Yes, but how can I call draw with something I'm not sure about it's type. Remember the example where we read a shape from file/network/...
I think we cannot eliminate it.

N - We can say, union type when used as type of binding specifies range of possible values it can hold.
When used as a generic type specifier, shows possible types that generic type can hold.
```
process = (s: Shape) ... #s is a binding, so it can hold any shape
process = (T: Shape ... #T is a type, so it can be any Shape subtype
```
No change in syntax. No change in notation.
also we can say `Type = ||` means union of all possible types.
So no need for keyword `type`.
The difference is that values for `type` must be specified at compile time but for a binding of type `Type` their value can come at any time.
```
Stack = [T: || -> {data: T, next: Stack[T]}]
find = (T: ||, array: Seq[T], item: T -> int)
```
so:
**Proposal**: Replace generics notation with union types
1. When a union type is used for a binding, that binding may have value for any of it's types.
2. When a union type is used for a type specifier, it represents valid types for that type and that type can be used to specify type of other arguments.
3. `||` is a union type of all possible types.
If all types of a union share `name:string` then you can refer to it inside a generic function for that type.
Can we have a parameteric generic?
`process = (T: ||, X: ShapeHolder[T], ...`
So this also means I can define bindings of type `||`, which is same as `void*` or `interface{}`
`draw = (T: Shape, x: T`
We can prohibit using `||` for a binding but it is not according to universal rule of the language: orthogonality
**Con**: This makes things more complex. Right now we have `type` and that's it. But with unions, users can limit types, put constraints and maybe mis-use this by having access to common fields of a union, hence make it difficult to solve expression problem.

N - If we go with union for generics, we can add a new type: `anything` which is basically union of all types.
rather than `||`
It makes more sense than `||` or `type`.
Any binding of type `anything` must be assigned with a literal or another binding of the same type. So values are decided at compile time.
`process = (T: anything, x: T -> int)...`
`process(int, 10)`
`process(string, "A")`
anything is a bit too long and confusing. (maybe we should say anytype)
`nil`, `nothing`, `none`, `void`
`||`, `something`, `anything`, `any`
`int`, `float`, `char`, `byte`, `string`, `bool`, `nothing`, `type`, `ptr`
so we will remove `type`, and replace it with `||`?
If a binding is of type `anything` it can be anything.
If a type is, it can be any type.

N - How can we easily implement thread join?
```
wid = newProcess()
waitFor = (w: wid -> receive((m: Message -> m.sender = wid and m.type = DONE))
```

N - How to do complex logics or data validations?
`ifElse` and `::`

N - use `&` to get ptr for a binding or anything

N - Mayeb we should use `?` instead of `_` to show generic with some type.

N - Is there a way to call a function which accepts a Circle with a Shape type if we are sure args match?

N - Is there a way to get type id of a union?

N - (copied to next item because it got too long) Another alternative: Rather than providing compile-time union, let user implement an extensible union via a linked list
and an array of shapes via a linked list
```
Shape = {t: type, item: T, next: Shape}]
shape_type = Shape[Circle]{item: 
```
No.
We can have a linked list of "valid" types and prepend to this list in compile time:
```
AllowedTypes = {t: type, next: nothing|AllowedTypes}
shape_types = AllowedTypes{t: Circle, next: nothing}
shape_types = AllowedTypes{t: Square, next: shape_types}
shape_types = AllowedTypes{t: Triangle, next: shape_types}
```
Then we can define a safe seq:
```
SafeSeq = {data: Seq[{type, ptr}], allowed_types: AllowedTypes}
```
Then a method that reads shapes from a file, can return SafeSeq of shape_types.
Another way: use `+=`
```
Shape = Circle
Shape += Square
Shape += Triangle
data: Seq[Shape]...
```
This is same as what we already have.
Can we just have Haskell's typeclass?
```
Drawable = [T: type -> {draw: (T->int)}]
Circle = ...
Square = ...
Circle#draw = (Circle->int)...
Square#draw = (Square->int)...
process = (x: Drawable) ...int_var = draw(x)
```
Actually, in Haskell you use typeclass as a constraint for generic. But we want dynamic runtime polymorphism.
```
Drawable = [T: type -> {draw: (T->int)}]
Circle = ...
Square = ...
Circle#draw = (Circle->int)...
Square#draw = (Square->int)...
process = (x: Drawable) ...int_var = draw(x)
```
Another solution: Tagging a type. It is like union but extensible and each type can belong to multiple tags
```
Circle = ...
Square = ...
Circle@Shape
Square@Shape
draw = (x: Shape, ...)
```
Let's ask the question the other way around: Why do we need this?
Why not rely on a low-level solution like ptr+type?
When we keep a sequence of shapes, what is the type of what's inside the sequence? Is it a tag? => A new concept which makes language more complicated.
We prefer a solution which does not add a new concept, uses existing concepts, has an intuitive syntax and is expressive and easy to use.
If we can modify the ptr+type solution to be more static type it would be great. because it only uses existing features.
What about keeping original type in ptr (e.g. byte, Circle, ...) For a sequence this is ptr.
So, we enhance ptr to be more type checked: We provide a set of allowed types. But how? We don't have sequence.
variadic? Linked list? So internally, ptr is a number and a type which specifies size. at runtime we only need size but during compilation we need type too.
One advantage is people cannot mis-use ptr: A ptr to byte can be only used as byte. We cannot store an 80-bit double number in a byte ptr.
```
ShapeList = Seq[ptr of @Shape]
Circle@Shape
Square@Shape
```
But how can I draw shapes from a ShapeList?
Keeping a ptr with allowed types is what a union does.
Can we replace union with this? No. Union is simple and intuitive. ptr with type is not. it is not intuitive.
What is the current solution? Extensible union + linked list of functions
What is wrong with it? The problem is, no part of this needs `Shape` type except the final `draw` function. Why not drop this strange notation?
```
#define Shape type using compile-time dynamic union
Shape = Circle | Triangle
Shape = Shape | Square

#Type of a function candidate which does a specific operation for a specific type.
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]
#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

#The draw function can be invoked on any shape
draw = (s: Shape, element: CandidateList[_] -> ) { #here is where we need ?
	if element.T is same as internal type of S, then call element.handler and return
	if element.next is nothing then return
	else recursively call with element.next
}
```
We can follow what we do for functions, for types. But it will be complicated.
Maybe we should provide some feature to make defining a linked list easier.
A shape type is a linked list of types of x or nothing. But this is not a type. This is a linked list with values.
Of course linked list has a type.
```
ShapeType = [T: type -> {value: T|nothing, next: ShapeType[_]}]
createCircle = (->ShapeType[Circle]) ...
createSquare = (->ShapeType[Square]) ...
draw = (s: ShapeType
```
Maybe we should put linked list inside the type:
```
ShapeType = {t: Circle, value: Circle|nothing, next: nothing} #this is the original definition
ShapeType = {t: Square, value: Square|nothing, next: ShapeType}
ShapeType = {t: Triangle, value: Triangle|nothing, next: ShapeType}
createCircle = (->ShapeType[Circle]) ...
createSquare = (->ShapeType[Square]) ...
draw = (s: ShapeType
```
Order of execution of above ShapeTypes does not matter. It can be Circle->Square->Triangle or Circle->Triangle->Square
No. This is wrong. Type of ShapeType changes so type of `next` changes.
Instead of `Shape = Circle | Square | Triangle` we can break it into 3 definitions:
```
Shape = Union of all types below
Shape[0] = Circle | nothing
Shape[1] = Square | nothing
Shape[2] = Triangle | nothing
```
Finding all types that are part of shape might be difficult: find `shape = shape |` in the code.
Maybe we can eliminate this by adding a notation to extend a union:
```
IntOrString = int | string
Shape = Circle | Square
...
Shape |= Triangle
```
The notation should be so obvious that it is easy to search by human or software.
Or, define an implicit protocol. Any type that has these, is implementing the protocol:
```
Shape = { name: string, draw: (->) }
Circle = {name: string, r: float, draw: (->)}
Square = {name: string, s: int, draw: (->)}

#The draw function can be invoked on any shape
draw = (s: @Shape, element: CandidateList[_] -> ) { #here is where we need ?
	s.draw()
}
```
So, `@T` creates a union type (we don't want to invent a new concept), containing all types that implement it.
We need access to common parts of a union types. Is it ok?
There should be a way to "declare" those common parts. And `Shape` is that way (Note that Shape is just a normal struct, but we make it a protocol by `@` prefix).
So, when you have an argument of type `@Shape`, you can access the items mentioned in Shape struct.
```
Shape = { name: string, draw: (->) }
Circle = {name: string, r: float, draw: (->)}
Square = {name: string, s: int, draw: (->)}

#The draw function can be invoked on any shape
draw = (s: @Shape -> ) { #here is where we need ?
	s.draw(s.name)
}
```
And still you can follow the linked list method for handlers.
BUT: this may add unwanted types to the union. `@Shape` may include customer too.
Unless we manually include types in it.
```
Shape = { name: string, draw: (->) }
Circle = {name: string, r: float, draw: (->)}

Square = {name: string, s: int, draw: (->)}
Square=>Shape

#The draw function can be invoked on any shape
draw = (s: %Shape -> ) { #here is where we need ?
	s.draw(s.name)
}
```
But this is too much code. If we define the protocl with care, it should be fine.
Btw now `%{}` will be a union of all structs. But we don't want to use it in generics.
```
Shape = { name: string, draw: (->) }
Circle = {name: string, r: float, draw: (->)}
Square = {name: string, s: int, draw: (->)}

#The draw function can be invoked on any shape
draw = (s: %Shape -> ) { #We are given a type which supports name and draw. And that's what we need.
	s.draw(s.name)
}
```
**Proposal**
1. No change in struct notation. But you can use a struct as a blueprint to gather a union of multiple types that include it's fields.
2. `%Shape` where `Shape={name:string}` will be union of all struct types that have name of string.
3. You can define bindings of this special union type.
4. This can be used to provide polymorphism.
```
Drawable = { draw: (->) }
Circle = {name: string, r: float, draw: (->)}
Square = {name: string, s: int, draw: (->)}

#The draw function can be invoked on any shape
draw = (s: %Drawable -> ) { #We are given a type which supports name and draw. And that's what we need.
	s.draw(s.name)
}
```
Making things centralised makes reading and understanding the code easier. But also makes it difficult to maintain and extend.
What if I want to add support for a protocol to an existing type?
e.g. I have triangle in an imported library -> I cannot change it and add `name:string`. So that's why it's better to rely on functions.
Even for fields, i can simply add a function which returns that field from struct.
But as we do not support specialisation, It's better not to use generic functions.
Go: interface is just a set of functions. You can implement it for any type you want by writing those functions.
Haskell: typeclass is a function map
```
Drawable = [T: type -> { draw: (T->) }]
Circle = {name: string, r: float}
Square = {name: string, s: int}
drawCircle [implement Drawable on Circle] = (c: Circle -> ...) #this is an implementation for drawable protocol on type Circle
drawSquare [implement Drawable on Square] = (s: Square -> ...)
#Here compiler knows that Circle and Square are two types that support Drawable
#The draw function can be invoked on any type for which we have implemented Drawable
draw = (s: Drawable -> ) { #We are given a type which supports name and draw. And that's what we need.
	s.draw()
}
```
Another example: Compare function. I need a function working on something which supports equality check.
We want to combine this with union. So 1. we have a new type which is union of all types that support this protocol.
2. we have the protocol which shows us the common functions across all those types.
I think when writing a function, we should indicate what protocol it is implementing for what type.
Because otherwise, we should specify this connection either at module level or as function argument.
If a type does not implement a protocol, we can simply add that support by writing appropriate functions. But this connection cannot be automatic because we cannot have functions with the same name. And without function name, there is no way for compiler to draw these connections.
Rust: `impl Animal for Sheep ` signals to the compiler that we are implementing trait X for type Y
Haskell: `instance Eq Praat where` Defines Praat type implements `Eq`
There are two ways to make connection (which function is implementing each function in the protocol):
1. naming convention `Drawable = [T: type -> { T##draw: (T->) }]`
2. explicit in the definition: `drawCircle [implement Drawable on Circle] = (c: Circle -> ...)`
The first one is simpler but not very flexible. So if a function `circleDraw` already exists, we have no way to add support.
The second one is better but needs more change.
I really don't want to change the notation to define a function. Because it will have a lot of implications.
```
Drawable = [T: type -> { draw: (T->) }]

Circle = {name: string, r: float}
Square = {name: string, s: int}

drawCircle = (c: Circle -> ...) 
drawSquare = (s: Square -> ...)

#here we register types with protocol
Drawable[Circle] = { draw: drawCircle }
Drawable[Square] = { draw: drawSquare }

#Now, the compiler knows that Circle and Square are two types that support Drawable
#The draw function can be invoked on any type for which we have implemented Drawable
draw = (T: type, item: T, s: Drawable[T] -> ) { #We are given a type which supports name and draw. And that's what we need.
	s.draw(item)
}
```
We can say, `Drawable[?]` means union of all types that are registered with Drawable.
Similarly, if we have a multi-type protocol, `Comparable[?, int]` is all types that can be compared with int.
```
draw = (s: Drawable[?] -> ) { 
	Drawable[s].draw(s)
}

draw = (T: type+Drawable, s: Drawable[T] -> ) { 
	Drawable[s].draw(s)
}
```
We know that generics can only be invoked with concrete hard coded types. But what if that type is a union?
I think I should be able to invoke generic with a union type and compiler will implement all cases (because it is limited).
Of course in this case, the generic function cannot have `T: type` because it means implement this function for every type.
The type should be limited via protocols.
```
draw = (T: Drawable, s: T -> ) { 
	Drawable[T].draw(s)
}
draw(type(my_shape), my_shape)
```
Why can't we simply use a function pointer?
```
xdraw = (T: type, item: T, draw: (T->) {
	draw(item)
}

xdraw(Circle, my_circle, drawCircle)
```
Before draw, we should think about the function that will return a shape. What will be it's output?
```
Drawable = [T: type -> { draw: (T->) }]

#here we register types with protocol
Drawable[Circle] = { draw: drawCircle }
Drawable[Square] = { draw: drawSquare }

getShape = (name: string -> Drawable[?]) {
	if name is Circle return Circle{1.5}
	if name is Square return Square{2}
}
#Drawable[?] is a type which can be any of types for which we have defined Drawable
#it can be used as a type for a generic function or as type of a binding
xdraw = (T: Drawable[?], item: T ->) {
	Drawable[T].draw(item)
}

my_circle = getShape("circle") #type of my_circle is Drawable[?]

#below two are the same
Drawable[type(my_circle)].draw(my_circle)
xdraw(type(my_circle), my_circle)
```
You can call a generic function with a normal hard-coded type or also you can call it with a union.
Because with union, number of cases is limited, so compiler can generate code and dynamic function invoke code.
But we are not interested in a union here. Because it requires dynamic union.
We have a protocol. But still we need union. At least for output of getShape.
But `Drawable[?]` is not a union. It is a struct with some fields. but it's type is dynamic.
Above code, seems too complicated: Special notation `?`, setting value for a type, generic with union, ...
What is the problem:
1. We need a mechanism to specify our expectation about `T` in a generic function.
2. We want to have a better polymorphism.
About 2, can't we just follow the protocol method? Define a polymorphic function and bind it for different types to different functions.
```
#basically following hashtable approach but for generic type
#kind of specialisation
DrawPoly = [T: type -> (T->)]
DrawPoly[Circle] = drawCircle
DrawPoly[Square] = drawSquare

Shape = Triangle|Square
Shape = Shape | Circle

createShape = (s: string -> Shape) ...
my_circle = createShape("Circle")
DrawPoly[type(my_circle)]()
```
No. It is not intuitive to assign to `DrawPoly[Circle]`. Instead of this, let's just focus on existing solution and make sure it is comprehensive, easy, expressiev and re-usable.
So we have one problem:
- To explicitly specify expectations in a generic function.
1. We need a mechanism to specify our expectation about `T` in a generic function.
If we replace generic type with union and add something to specify common things between union types, this can be solved.
Just make sure we still can solve expression problem.
```
#every type that wants to join Shape union, must have these
Shape = { getName: (->string) } 
process = (T: Shape, g: T -> ...) { x = g.getName() }
```
So joining union is not automatic, not every type that has `getName` will become member of `Shape` union. 
We have to join them manually.
but it will be difficult to extend existing types to support a union.
```
#every type that wants to join Shape union, must have these
Shape = [T: type -> { draw: (T->string) } ]
Shape[Circle] = { draw: drawCircle }
Shape[Square] = { draw: drawSquare }

Shape = Shape | Circle {getCircleName}
process = (T: Shape, g: T -> ...) { x = g.getName() }
```
Another easier way: Add compile time check to make sure some functions are defined.
```
#in process we expect some functions to be defined for type T
process = (T: type, g: T, ...) 
defined: getName: (T->string)
{ ... }
process = (T: type, g: T, getName: (T->string)) 
{ ... }
```
`process = (T: type, g: T, getName: (T->string))`
`process = (T: type, g: T, getName: (T->string))`
Rather than relying on some special notation, let's just add a function ptr to the argument list.
Caller can decide which implementation to use for this. And it is completely visible and explicit.
Can we use this to provide easier polymorphism? We want different `getName` implementations based on `T`.
`process = (T: type, g: T, invokeGetName: (T ->string))`
We said, it does not make sense to specialise generic functions but what about generic types?
This can also help with polymorphism.
```
ShapePainter = [T: type -> { draw: (T->string) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }
...
process = (T: type, shape: T, painter: (T->string) -> ...
...
process(type(my_shape), my_shape, ShapePainter[type(my_shape)].draw)
```
So, we will need these:
1. Specialisation for generic types
2. Calling generic function with union
But maybe we can do without calling generic with union.
```
ShapePainter = [T: type -> { draw: (T->string) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }
...
process = (my_shape: Shape -> ... ) {
	painter = ShapePainter[type(my_shape)].draw
	str = painter(unwrap(my_shape))
}
...
process(type(my_shape), my_shape, ShapePainter[type(my_shape)].draw)
```
Seems that with generics call with union it is more readable:
```
ShapePainter = [T: type -> { draw: (T->string) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }
...
process = (T: type, shape: T -> ) {
	painter = ShapePainter[T].draw
}
...
process(type(my_shape), my_shape)
```
**Proposal**:
1. Keep compile-time dynamic union
2. Support specialisation of generic types. The syntax forces you to specify concrete type for all parameters
3. Support calling a generic function with a union type.
q: Should we replace `type` with union? Will this help? 
I see more and more complexity. How can we do this with only supporting specialisation for genneric types?
```
ShapePainter = [T: type -> { draw: (T->) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }
...
process = (shape: Shape -> ) {
	hapePainter[type(shape)].draw(unwrap(shape))
}
...
process(my_shape)
```
So the proposal is:
1. Support specialisation of generic types. The syntax forces you to specify concrete type for all parameters.
2. We need a notation to get internal type of a union. This results in calling generics with a union binding. But it should be fine.
3. If we have `draw: (Circle->)` and a shape which contains a Circle, there should be a simple mechanism to do the call.
```
#you can store any type specific data inside this struct
ShapePainter = [T: type -> { draw: (T->) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }
Converter = [S,T: type -> { convert: (S->T) } ]
Converter[Customer] = ... #invalid
Converter[Customer, Int] = ... #valid
...
#To draw some shape
my_shape = getShape(...)
ShapePainter[type(my_shape)]
draw = (shape: Shape -> ) {
	shapePainter[type(shape)].draw(unwrap(shape))
}
...
draw(my_shape)
```
We want to have one thing, but distributed in several files. Now the problem is: How are we going to connect all of them together.
This is the way we define dynamic union, generic type specialisation and polymorphism.
The problem with above code: ShapePainter is a type, but we are assigning a value to it.
The notation of linked list at module level, makes some sense: We define a module-level struct. Then we update it during compile time.
And note that if we use above solution, we will still need dynamic union.
```
#define Shape type using compile-time dynamic union
Shape = Circle | Triangle
Shape = Shape | Square

#Type of a function candidate which does a specific operation for a specific type.
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]
#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

#The draw function can be invoked on any shape
draw = (s: Shape, element: CandidateList[_] -> ) { #here is where we need ?
	if element.T is same as internal type of S, then call element.handler and return
	if element.next is nothing then return
	else recursively call with element.next
}
```
Maybe we can simplify the above notation and let it stay as a solution.
Maybe we don't really need polymorphism.
If we have `Shape = Circle | Square` and we add triangle, and we cannot modify existing code -> Then add a new type
`NewShape = Shape | Triangle` and forward other functions and ...
In this way we can use functions to cover all cases of a union.
We can say Haskell's type-class is same as generics.
And each instance is a specialisation of that generic.
read: https://koerbitz.me/posts/Solving-the-Expression-Problem-in-Haskell-and-Java.html
Another idea: Let union remain the same. Follow Haskell's approach.
To solve expression problem: Use typeclass, where you can implement a typeclass for any type.
And typeclass can be input of a function.
Rather than adding unintuitive notations, divide it into 3-4 small intuitive notations.
read: https://blog.codecentric.de/en/2017/02/ad-hoc-polymorphism-scala-mere-mortals/
Like what we did for concurrency: adding send and receive functions, instead of strange operators.
```
#you can store any type specific data inside this struct
ShapePainter = [T: type -> { draw: (T->) } ]
ShapePainter[Circle] = { draw: drawCircle }
ShapePainter[Square] = { draw: drawSquare }

...
getShape = (name:string -> ShapePainter[?]) {
	...
}

draw = (shape: Shape[?] -> ) {
	shape.draw()
}
...
#To draw some shape
my_shape = getShape(...) 
draw(my_shape)
```
But `Shape[Circle]` seems un-intuitive.
"Type systems with subtyping are dramatically more complicated than those without"
This means if we have this:
`coords :: [Coord]
coords = [a, b]`
We should be aware that a is of type CartesianCoord and also it is a Coord.
Implement both new type and new operation.
Do we really need to add support for expression problem?
Adding new cases to a type/operation can cause issues like fragile base class issue in OOP.
Is there a way to implement this without "ANY" change to the language?
We know in the operation side, this is possible using a linked list.
The only issue: extending union notation.
```
#you can store any type specific data inside this struct
Circle = {...}
Square = {...}

ShapePainter = [T: type -> (T->) ]
ShapePainter[Circle] = drawCircle
ShapePainter[Square] = drawSquare

Shape = ShapePainter[?]

...
getShape = (name:string -> ShapePainter[?]) {
	...
}

draw = (shape: Shape[?] -> ) {
	shape.draw()
}
...
#To draw some shape
my_shape = getShape(...) 
draw(my_shape)
```
No. This notation of generic type specialisation does not make any sense. Let's stick to the linked list solution for now.
```
#define Shape type using compile-time dynamic union
Shape = Circle | Triangle
Shape = Shape | Square

Shape = {}
Shape = {Circle, *Shape}
Shape = {Square, *Shape}
#now Shape is a struct of {Circle, Square}

#Type of a function candidate which does a specific operation for a specific type.
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]
#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

createShape = (name: string -> Shape) {...}

#The draw function can be invoked on any shape
draw = (s: Shape, element: CandidateList[_] -> ) { #here is where we need ?
	if element.T is same as internal type of S, then call element.handler and return
	if element.next is nothing then return
	else recursively call with element.next
}
```
What if we define a ptr with a set of valid types for it?
```
Shape = {s: ptr, types: {}}
Shape = 
```
idea: OOP solves expression problem by visitor pattern which basically means adding an extension point inside classes, so we can easily add new operations.
Maybe we should follow the same. put an extension point in the functions so we can easily add new types.
Another idea: We define a master functio with type Shape and it's value is defined by specialisations on the master function.
But this will no longer be a type.
Doesn't this conflict with SOLID rule: A Type should be open to extension, but closed for edits.
Another solution based on visitor:
- createShape returns an `accept` lambda which is the internal lambda of Circle or Square or ...
- Caller will have a lambda `accept` which it can call for different operations.
- We don't even need to store `accept` inside the type. It can be a lambda inside createShape.
But if we do it inside createShape, we won't be able to extend types.
```
Circle = {...}
Square = {...}

getShapePainter = (string: name -> (Color->)) {
	if name is "Circle" c = read_circle, return (Color->draw_c)
	if name is "Square" ...
}

painter = getShapePainter(name)
painter(Black)
```
Suppose that we add another op: reverseShape 
How can we compose these? reverse and then paint the shape?
Another idea: getShape returns anything type, but the internal type has an `accept` function.
You can call accept with the hander LinkedList and it will find it's own type and execute the handler function.
```
#this is the definition of handler function on a Shape 
#which is also input of shape's accept functions
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]

#we don't know what will be the head of CandidateList so we use `_`
Circle = {... 
	accept = (CandidateList[_] -> find handler for Circle type and run it on me)
}
Square = {...
	accept = (CandidateList[_] -> find handler for Square type and run it on me)
}

#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, next: nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

getShape = (string: name -> (CandidateList->)) {
	if name is "Circle" c = read_circle {
		c = Circle{..., accept: (x: CandidateList[_] -> innerAccept(x, c)),
					innerAccept: (x: CandidateList[_], c: Circle -> ... }
		return Circle{...accept...}.accept
	}
	if name is "Square" ... return Square {...accept...}.accept
}

painter = getShape(name)
painter(shape_handlers)
```
q: Do we need a notation to refer to the containing struct? Can't we hide this from outside? I think we can.
And maybe we can write one universal `innerAccept` function.
```
#this is the definition of handler function on a Shape 
#which is also input of shape's accept functions
CandidateList = [T: type -> {T: type, handler: (T->), next: nothing|CandidateList[_]}]

#we don't know what will be the head of CandidateList so we use `_`
Circle = {... 
	accept = (CandidateList[_] -> find handler for Circle type and run it on me)
}
Square = {...
	accept = (CandidateList[_] -> find handler for Square type and run it on me)
}

#Define a linked list of handlers for different types.
shape_handlers = CandidateList[Circle]{Circle, drawCircle, next: nothing}

#amend the list of handlers
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}

#adding a new shape
Triangle = { ...
	accept = (CandidateList[_] -> ...)
	...
}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}

#adding a new operation:
save_handlers = CandidateList[Circle]{Circle, saveCircle, next: nothing}
shape_handlers = CandidateList[Square]{Square, drawSquare, shape_handlers}
shape_handlers = CandidateList[Triangle]{Triangle, drawTriangle, shape_handlers}


getShape = (string: name -> (CandidateList[_]->)) {
	if name is "Circle" c = read_circle {
		c = Circle{..., accept: (x: CandidateList[_] -> innerAccept(x, c)),
					innerAccept: (x: CandidateList[_], c: Circle -> ... }
		return Circle{...accept...}.accept
	}
	if name is "Square" ... return Square {...accept...}.accept
}

painter = getShape(name)
painter(shape_handlers)
```
To prevent using `_`, I can add a new dummy type which only points to shape handlers.
```
HandlerList = [T: type-> {t: type, handler: (T->), next: nothing|HandlerList[?]}

#we don't know what will be the head of CandidateList so we use `_`
Circle = {... 
	process = (HandlerList[?] -> find handler for Circle type and run it on me)
}
Square = {...
	process = (HandlerList -> find handler for Square type and run it on me)
}

#Define a linked list of handlers for different types.
shape_handlers = HandlerList[Circle]{t: Circle, handler: drawCircle, next: nothing}
shape_handlers = HandlerList[Square]{t: Square, handler: drawSquare, next: shape_handlers}

getShape = (string: name -> (HandlerList->)) {
	if name is "Circle" 
		c = Circle{...}
		lambda = (x: HandlerList[?] -> if x.t == Circle then run x.handler(c) else return lambda(x.next))
		return lambda
	}
	if name is "Square" ... 
}

myShapeProcessor = getShape("Circle")
myShapeProcessor(shape_handlers)
```
`CandidateList[?]` cannot be resolved at compile time.
It seems that we should give up type at some point in the chain.
Seems above is the most sensible and consistent solution. Now we should try to make it easy.
e.g. making sure `Handler[?]` can accept parameter x. we can use `func<data>` but it is a large change.
Why not use core? canInvoke: `canInvoke(handler, my_circle)::handler(my_circle)`
`canInvoke = (x: (?->?), data: ?)`
What if we add a core function for: look over these handlers and invoke the one which is suitable with these inputs.
What is we use a struct with `n*2` fields, for `n` handler functions?
The more code we write, the more control we can have over the dispatch.
```
#no LL, no next, no type, no generics, only one big anonymous struct
handlers = {Circle, drawCircle}
handlers = {*handlers, Square, drawSquare}

HandlerList = TypeOf(handlers)

Circle = {...}
Square = {...}

getShape = (string: name -> (HandlerList->)) {
	if name is "Circle" 
		c = Circle{...}
		lambda = (x: HandlerList, i:int -> if x.i == Circle then run x.(i+1)(c) else return lambda(x, i+2))
		return (x:HandlerList -> lambda(x,0))
	}
	if name is "Square" ... 
}

myShapeProcessor = getShape("Circle")
myShapeProcessor(handlers)
```
No. adressing a struct with `.i` makes it like an array.
Using generic specialisation will still give us the problem of creating a dynamic Shape type.
But maybe if we combine it with visitor, it helps.
No. no no 
we want to:
- Avoid strange cryptic notations
- Easy and convenient and intuitive code
- Extensible to support new operations and new shapes (types)
questions:
- How should we be storing operations? (e.g. draw code for different types)
- How should we write a method which given a string, returns some type?
We have to unify.
So the create method, will not return some type. It will return a lambda which is all the same regardless of the type: given a list of handlers (q1) it will find the correct one and execute.
Now about question 1:
Maybe genrics is not the solution, if we don't want to have strong static compile time type (which we cannot have because that string can be anything and we don't want to introduce compile time union).
Solution: `any` type -> `ptr`
```
HandlerList = {t: type, handler: (ptr->), next: nothing|HandlerList}

Circle = {...}
Square = {...}

drawCircle = (x: Circle -> int) {...}
drawSquare = (x: Square -> int) {...}

#Define a linked list of handlers for different types.
shape_handlers = {t: Circle, handler: drawCircle, next: nothing}
shape_handlers = {t: Square, handler: drawSquare, next: shape_handlers}

getShape = (string: name -> (HandlerList->)) {
	if name is "Circle" 
		c = Circle{...}
		lambda = (x: HandlerList -> if x.t == Circle then run x.handler(c) else return lambda(x.next))
		return lambda
	}
	if name is "Square" ... 
}

myShapeProcessor = getShape("Circle")
myShapeProcessor(shape_handlers)
```
How can we make this better?
- Attach a secondary type to the function so anyone wants to call checks that.
Idea: Define a protocol (a function with `any` input), and specialize/extend it for different types
no.
But if we want to use `any` why so much complexity? just return ptr and do the iteration outside: No. Because we don't know the original type.
Clojure's protocols is like this but in handlers, there is a special type `this`.
idea: store handlers as ptr and when needed cast them to appropriate type. Advantage: No need to type checking inside handler.
```
HandlerList = {t: type, handler: ptr, next: nothing|HandlerList}

Circle = {...}
Square = {...}

drawCircle = (x: Circle -> int) {...}
drawSquare = (x: Square -> int) {...}

#Define a linked list of handlers for different types.
shape_handlers = {t: Circle, handler: ptr(drawCircle), next: nothing}
shape_handlers = {t: Square, handler: ptr(drawSquare), next: shape_handlers}

getShape = (T: type, string: name -> (HandlerList->)) {
	if name is "Circle" 
		c = Circle{...}
		lambda = (x: HandlerList -> if x.t == Circle then run cast(x.handler as T)(c) else return lambda(x.next))
		return lambda
	}
	if name is "Square" ... 
}

myShapeProcessor = getShape("Circle")
myShapeProcessor(shape_handlers)
```
The dirty part is in lambda. So maybe we can put it in a core function: given a LL and type, returns a lambda to invoke appropriate function + two lambdas to get next and get handler.
`invoke = (T: type, I: type, O: type, list: T, getNext: (T->T), getType: (T->type), getHandler: (T->(I->O))`
`shape_handler` is a table (list of rows). Same as vtable in c++.
**Proposal**:
1. Add to pattern section above code to explain how polymorphism is done
2. Use `&` to cast anything to ptr.
3. Add a function to core to de-reference a ptr
4. No `_` in generics.
5. No compile time union. All unions are fixed without any change.

N - If we follow `$x` notation, can we have optional args?
```
process = (x: int, y:int|nothing)
process = (x:int, y:nothing) -> process(x, 100)
process = (x:int, y:int) -> ...
```

N - `type{}` for types that must be struct.
So when we have `... (InType: type, args: InType -> invokePtr(OutType, func_ptr, *{c, *args}))` we are sure that `InType` is a struct.

N - Shall we allow using union instead of `type` keyword? But no further syntax.
Only union types are allowed. That's the only constraint.
If we stop union extension, then it will be of no use. (?)
No. Because then we cannot emphasis type relationship.
`process = (T: type, x: T, y: T ->` says type of x and y must be the same. but
`process = (x: Shape, y: Shape ->` does not say that.

N - With generics, how can we define a lambda? Because a generic function's signature relies on name of the first argument.
And in lambda or function type, we just ignore names.
`process = (T: type, g: T -> string) ...`
`view = (T: type, processHandler(type, `
Maybe we should provide type when creating a lambda.
q: What is type of `process` above?
Maybe we can use `$1` and `$2`... to refer to generic arguments.
This is same in Java and there, you must specify types.
```
process = (T: type, x: T -> string) ...

myLambda = process(int, _)
```
I think we cannot have generic lambdas. Because lambda is a runtime concept and generic is compile time.
If we have a function which accepts a generic lambda, it can be called with different functions. 
So we don't know what to call if we have `myLambda(int, 10)`.

N - Make sure LL way for polymorphism is powerful and re-usable for other cases, types, multiple-types, ...

N - `t: Circle` is t of type Circle or it's value is Circle type?
Maybe we should use `=` for values. To make it explicitly different.

N - Review examples section

N - If it turns out we don't need dynamic union, can we put more effort on pattern matching?

N - Proposal for polymorphism
```
HandlerList = {t: type, handler: ptr, next: nothing|HandlerList}

Circle = {...}
Square = {...}

drawCircle = (x: Circle -> int) {...}
drawSquare = (x: Square -> int) {...}

#Define a linked list of handlers for different types.
shape_handlers = {t: Circle, handler: ptr(drawCircle), next: nothing}
shape_handlers = {t: Square, handler: ptr(drawSquare), next: shape_handlers}

getShape = (T: type, string: name -> (HandlerList->)) {
	if name is "Circle" 
		c = Circle{...}
		lambda = (x: HandlerList -> if x.t == Circle then run cast(x.handler as T)(c) else return lambda(x.next))
		return lambda
	}
	if name is "Square" ... 
}

myShapeProcessor = getShape("Circle")
myShapeProcessor(shape_handlers)
```
The dirty part is in lambda. So maybe we can put it in a core function: given a LL and type, returns a lambda to invoke appropriate function + two lambdas to get next and get handler.
`invoke = (T: type, I: type, O: type, list: T, getNext: (T->T), getType: (T->type), getHandler: (T->(I->O))`
`shape_handler` is a table (list of rows). Same as vtable in c++.
**Proposal**:
1. Add to pattern section above code to explain how polymorphism is done
2. Use `&` to cast anything to ptr.
3. Add a function to core to de-reference a ptr
4. No `_` in generics.
5. No compile time union. All unions are fixed without any change.
```
VTable = {t: type, handler: ptr, next: nothing|VTable}

Circle = {...}
Square = {...}

getShape = (string: name -> (VTable->(InType: type, OutType: type, args: InType -> OutType))) {
	if name is "Circle" {
		c = Circle{...}
		:: (x: VTable -> (InType: type, OutType: type, args: InType -> OutType))
		{
			func_ptr = findEntry(x, Circle);
			:: (InType: type, OutType: type, args: InType -> invokePtr(OutType, func_ptr, *{c, *args}))
		}
	}
	if name is "Square" ... 
}

drawCircle = (x: Circle, g: Canvas, scale: float -> int) {...}
drawSquare = (x: Square, g: Canvas, scale: float -> int) {...}

#Define a linked list of handlers for different types.
draw_handlers = VTable{t: Circle, handler: &drawCircle, next: nothing}
draw_handlers = VTable{t: Square, handler: &drawSquare, next: draw_handlers}

my_canvas = createCanvas()
int_result = getShape("Circle")(draw_handlers)({Canvas, float}, int, {canvas, 1.19})
```
ptr is like `void*`. We don't store it's internal type. 
So `T: type` means T is a full type we can use.
`T: type[type]` means T is a generic type and needs another full type to be useful. Otherwise it will be like `Stack` generic type.
Or we can use `type[?]` to indicate that.
By the second we introduce constraints, we should also have it for `?`, which makes things even worse.
Also we need a means to cast back ptr.
**Proposal**:
1. Add to pattern section above code to explain how polymorphism is done
2. Use `&` to cast anything to ptr.
3. Add a function to core to de-reference a ptr: `ref(int, my_ptr)`
4. No `_` in generics.
5. No compile time union. All unions are fixed without any change.
6. Add a core function `invokePtr` to invoke a ptr which has a function inside.
For de-reference, it is different from casting. In casting, we change type of some data we have.
But here we want to get a typed binding pointing to where this ptr points at.
`*x`? No we have to specify type.
How can we add extra arguments?
in OOP, this vtable is attached to the instance/object, but here it is separated.
idea: Add a function to core to invoke a `ptr` with a struct as it's parameters and specific output type: `invokePtr`
Problem is we want to solve expression problem, don't add anything fancy and still support polymorphism.
```
Circle = {...}
Square = {...}

drawCircle = (x: Circle, g: Canvas, scale: float -> int) {...}
drawSquare = (x: Square, g: Canvas, scale: float -> int) {...}

VTableRow = {t: type, handler: ptr, next: nothing|VTableRow}
draw_vtable = {
	handlers: draw_handlers, 
	#we may add many different v functions (paint, print, save, ...) but for each we will have this helper func
	draw = 

#Define a linked list of handlers for different types.
draw_handlers = VTableRow{t: Circle, handler: &drawCircle, next: nothing}
draw_handlers = VTableRow{t: Square, handler: &drawSquare, next: draw_handlers}

getShape = (string: name -> (VTable->(InType: type, OutType: type, args: InType -> OutType))) {
	if name is "Circle" {
		c = Circle{...}
		:: (x: VTable -> (InType: type, OutType: type, args: InType -> OutType))
		{
			func_ptr = findEntry(x, Circle);
			:: (InType: type, OutType: type, args: InType -> invokePtr(OutType, func_ptr, *{c, *args}))
		}
	}
	if name is "Square" ... 
}



my_canvas = createCanvas()
int_result = getShape("Circle")(draw_handlers)({Canvas, float}, int, {canvas, 1.19})
```
What if we keep dynamic union and enable specialisation for generic functions?
```
Shape = Circle | Square
Shape = Shape | Triangle

draw = (Shape, Canvas, float -> int) #no body, means this is an abstract function

draw = (c: Circle, s: Canvas, f: float -> int ) ...
draw = (e: Square, s: Canvas, f: float -> int ) ...

#adding new function
print = (Shape, Canvas, float -> string) 
paint = (c: Circle, g: Canvas, f: float -> string ) ...

#adding new type
Shape = Shape | Triangle

getShape = (name: String -> Shape) {
	if name is "Circle" return Circle{...}
	if "Square" ...
}

my_shape = getShape("Circle")
int_var = draw(my_shape, my_canvas, 1.2)
```
You can assign a lambda to `draw` as an abstract function using: `myLambda = draw(_: Shape, _, _)`
or to sub-funcs: `myLambda = draw(_:Circle, _,_)`
What if there are multiple generics?
`draw = (Shape, Color, Canvas -> int)`
and color, canvas are both generics: `Color = Red | Green | Blue`, `Canvas = Paper | Screen | ...`
now, can I write a draw for Circle, but generic color? what will be the point?
Shall we say: Any function that has at least one union arg, must be abstract? So if it is not abstract, it must have concrete values for all args.
This makes sense and can decrease complexity.
This is just like Haskell, where when you write a function on a sum type, you use pattern matching to specify behavior for each type
```
isZero :: Int -> Bool
isZero 0 = True
isZero _ = False

toBeOrNotToBe :: Bool -> String
toBeOrNotToBe True  = "Be"
toBeOrNotToBe False = "Not to be"
```
Maybe we should follow the same. But only for unions.
So for the first definition: `Shape = Circle | Circle` which forces shape to be a union (if we have only one type).
- One may add their type to Shape but not sure what functions they need to implement. That is fine, they can use compiler or IDE to find out.
Let's don't make things more complciated because of this.
```
Shape = Circle | Square

draw = (Shape, Canvas, float -> int) #no body, means this is an abstract function, if it was Draw then it would be a type

draw = (c: Circle, s: Canvas, f: float -> int ) ...
draw = (e: Square, s: Canvas, f: float -> int ) ...

#adding new function
print = (Shape, Canvas, float -> string) 
paint = (c: Circle, g: Canvas, f: float -> string ) ...
paint = (c: Square, g: Canvas, f: float -> string ) ...

#adding new type
Shape = Shape | Triangle
draw = (x: Triangle, s: Canvas, f: float -> int) ...
paint = ...

getShape = (name: String -> Shape) {
	if name is "Circle" return Circle{...}
	if "Square" ...
}

my_shape = getShape("Circle")
int_var = draw(my_shape, my_canvas, 1.2)
```
This makes sense, but how can we extend `getShape`? It we add a new type like Triangle? Can we make this one generic too?
```
getShape = (name: String -> Shape) #abstract

getShape = (name: "Circle" -> Circle)???
```
If an abstract fuction has generic inputs, it's fine. we can easily decide for implementation when someones calls them.
But what if output is generic? Making decision based on input value is very simplistic. We can have other criteria for this.
We can say, any function with a union inpu must be abstract.
And no two abstract functions can have the same name,
Can we make getShape extendable?
Like a dispatcher function that calls other functions, this can be simply done via a map.
But that map will not be extendable. We can always use the LL method, same as what we were doing for polymorphism.
```
Creator = {name: string, creator: (string->Shape), next: nothing|Creator}
shape_creators = Creator{"Circle", createCircle, nothing}
shape_creators = Creator{"Square", createSquare, shape_creators}
```
This makes sense. We don't need to do anything for generic types. 
This is only about unions.
How does this work with generics?
```
process = (T: type, data: T, s: Shape -> int) #abstract and generic
process = (T: type, data: T, s: Circle -> int) ...
process = (T: type, data: T, s: Square -> int) ...
```
If we use unions for generics, will this be simpler?
```
Shape = Circle | Square

draw = (T: Shape, item: T, Canvas, float -> int) #no body, means this is an abstract function, if it was Draw then it would be a type

draw = (T: Circle, item: Circle, s: Canvas, f: float -> int ) ...
draw = (T: Square, e: Square, s: Canvas, f: float -> int ) ...

#adding new function
print = (Shape, Canvas, float -> string) 
paint = (c: Circle, g: Canvas, f: float -> string ) ...
paint = (c: Square, g: Canvas, f: float -> string ) ...

#adding new type
Shape = Shape | Triangle
draw = (x: Triangle, s: Canvas, f: float -> int) ...
paint = ...

getShape = (name: String -> Shape) {
	if name is "Circle" return Circle{...}
	if "Square" ...
}

my_shape = getShape("Circle")
int_var = draw(my_shape, my_canvas, 1.2)
```
The rule of generics is that you have to call it with concrete type. Now, how can i call a generic draw with a concrete type when I only have a Shape?
No. Let's keep these separated.
**Proposal**
1. Keep dynamic compile time union
2. Define abstract function: Any function that has no body
3. For any abstract function, you can define implementations with the same name but non-union types.
4. If someone calls the abstract function, it will be redirected to appropriate function with correct type.
5. You cannot have more than one abstract function with the same name.
6. Fix patterns section
7. You cannot address implementations of an abstract function via lambda. You can only point to the abstract function and your call will be redirected.
What happens if I call impl function with `Circle|Triangle`?
In impl section, you can impl for a union, as long as there is no overlap.
When calling, if we have a function for static type, it will be called. else the one for it's dynamic type will be called.
What if we have multiple arguments?
`process = (x:Shape, c: Color -> int)`
if I call process with Circle and `Red|Blue`, and in impl I have `Circle|Square, Red`
and `Circle|Square, Blue` what will happen?
oh too much complexity. Let's just say no union type in impl functions.
They must be concrete types. And if you want same code for multiple types, repeat code or call another function.
But impl functions must all have concrete types, not union types.
And when calling? You can call with anything. If it is a union type, dynamic type will be used to dispatch. else static type.
If we have multiple unions, dynamic type of all of them will be used to match.
**Proposal**
1. Keep dynamic compile time union
2. abstract function: A function with union args and no body. You cannot have one of these two.
3. For any abstract function, you can define implementations with the same name but non-union types. impl function must not have union inputs.
4. If someone calls the abstract function, it will be redirected to appropriate function with correct type.
5. You cannot have more than one abstract function with the same name.
6. Fix patterns section
7. You cannot address implementations of an abstract function via lambda. You can only point to the abstract function and your call will be redirected.
8. If you call a function with union type, it's dynamic runtime type will be used to dispatch. Otherwise, static type.

N - `type{}` for types that must be struct.
So when we have `... (InType: type, args: InType -> invokePtr(OutType, func_ptr, *{c, *args}))` we are sure that `InType` is a struct.

N - Shall we allow using union instead of `type` keyword? But no further syntax.
Only union types are allowed. That's the only constraint.
If we stop union extension, then it will be of no use. (?)
No. Because then we cannot emphasis type relationship.
`process = (T: type, x: T, y: T ->` says type of x and y must be the same. but
`process = (x: Shape, y: Shape ->` does not say that.

N - With generics, how can we define a lambda? Because a generic function's signature relies on name of the first argument.
And in lambda or function type, we just ignore names.
`process = (T: type, g: T -> string) ...`
`view = (T: type, processHandler(type, `
Maybe we should provide type when creating a lambda.
q: What is type of `process` above?
Maybe we can use `$1` and `$2`... to refer to generic arguments.
This is same in Java and there, you must specify types.
```
process = (T: type, x: T -> string) ...

myLambda = process(int, _)
```
I think we cannot have generic lambdas. Because lambda is a runtime concept and generic is compile time.
If we have a function which accepts a generic lambda, it can be called with different functions. 
So we don't know what to call if we have `myLambda(int, 10)`.

N - Make sure LL way for polymorphism is powerful and re-usable for other cases, types, multiple-types, ...

N - `t: Circle` is t of type Circle or it's value is Circle type?
Maybe we should use `=` for values. To make it explicitly different.

N - Review examples section

N - If it turns out we don't need dynamic union, can we put more effort on pattern matching?

N - (moved to next item) q: How can we use this to implement hashCode function?
```
getHashCode = (data: ?  -> string)
```
or toString?
```
toString = (data: ?  -> string)
```
This is really really similar to generics. Maybe we can replace generics with this?
Suppose that we have a special union called `any` which is union of everything.
```
getHashCode = (data: any -> string)
getHashCode = (data: Customer -> string ) ...
getHashCode = (data: Circle -> string) ...
getHashCode = (data: Square -> string) ...

Stack = Seq[any]
push = (s: Stack, x: any)
push = (s: Stack, x: int) ...
push = (s: Stack, x: string) ...
```
What is the difference? getHashCode has to be different for each type.
But push doesn't need to.
So maybe we can just implement abstract function. But then we won't have type safety.
We can have data of different types on a Stack.
And what about when output type is union? How can we keep type safety?
`receive = (T: type, predicate: (T->bool) -> T)`
`receive = (predicate: (any->bool) -> any)`
And when we need a predicate which accepts any, we can give any implementation for that? `int->bool` for example?
But without proper generic we won't have sequence and map.
```
Map = [K: type, V: type -> 
{ 
	ref: ptr, 
	get = (index: K -> coreRead(K, V, ptr, index),
	create = (data: {K,V}... -> Map[T])
	{
		result = coreAlloc(T, data)
	}
}]
```
what if we keep generic data types but remove generic functions?
```
Stack = [T: type -> Seq[T]]
push = (s: Stack[any], x: any) #abstract
push = (s: Stack[$1], x: $1) ...
```
Generic data structures are much more limited.
**Proposal**:
1. Drop generic functions
2. Add `any`
3. Add `$x` notation to write implementations for an abstract functions.
Again, you cannot address impl function. only abstract one.
`$x` notation means compiler will generate a new code for each call/type.
q: How will this affect seq, map, receive, send, cache?
cache is just and receive.
```
send = (x: wid, data: any)...
send = (x: wid, data: $1) ... #using $ notation means type cannot be any union type
receive = (predicate: (any->bool) -> any)
receive = (predicate: ($1->bool) -> $1)
```
So the rule is, no actual function (a function with body, or impl function), can have union input type.
If I call the function with `int`, the code for `int` will be generated and called.
```
Seq = [T: type -> {
	Type: type = T, 
	ref: ptr, 
	length = (->coreLen(ref)),
	concat = (target: Seq[T] -> out: Seq[T])
	{
		data = alloc(len(ptr)+len(target.ptr))
		...
	},
	create = (data: T... -> Seq[T])
	{
		result = coreAlloc(T, data)
	},
	get = (index: int -> coreGet(ref, T, index))
}
]
#using a sequence
x = Seq[int].create(1,2,3,4)
len = x.length()
new = x.concat(my_int_sequence)
```
Putting functions inside struct will cause confusion. Because fn cannot be generic but a fn inside a generic type, is generic by nature.
```
Seq = [T: type -> {ref: ptr}]

createSequence = (data: any... -> Seq[any])
createSequence = (data: $1... -> Seq[$1]) ...
```
So: Proposal: Do not allow setting values in struct type.
What if I really want to call a function with a union?
e.g. create a sequence of int or string?
```
getHashCode = (data: any -> string)
getHashCode = (data: Customer -> string ) ...
getHashCode = (data: Circle -> string) ...
getHashCode = (data: Square -> string) ...
```
Does it make sense to write getHashCode for int_or_string type? I think it might make sense and as long as we only have one abs function it should be ok.
**Proposal**:
1. Drop generic functions
2. Add `any`
3. Add `$x` notation to write implementations for an abstract functions.
4. No value in struct types
How can we have a sequence of `int_or_string`? Or call function with union?
Union cannot be at the arg level.
e.g. get: `get = (Seq[any], index: int -> any`
what if seq is int or string?
`get = (Seq[$1], index: int -> $1)`
And without generics:
`get = (Seq[int], index: int -> int)`
`get = (Seq[string], index: int -> string)`
We can write:
`get = (Seq[int|string], index: int -> int|string)`
Note that function input is not union. Internal type of an argument is.
You cannot write a body for abstract function.
This concept helps us implement polymorphism.
Can `$x` notation be mixed?
`process = (data: $1|$2 -> $1|$2)`
- The fact is, we don't have abstract functions at all. Just write impl functions normally, and compiler will handle everything.
```
getHashCode = (data: Customer -> string ) ...
getHashCode = (data: Circle -> string) ...
getHashCode = (data: Square -> string) ...

send = (x: wid, data: any)...
send = (x: wid, data: ?) ... 
reverMap = (in: Map[K,V] -> Map[V,K])
```
Generic functions are like polymorphic functions but with inclusion of all types and same implementation.
```
Add[T] = (a: T, b: T -> T) 
{
	...
}
Add[int](10, 19) 
#or
add[?](10,19)
```
Can we unify these? Same notation for both?
```
my_shape = createShape("Circle")
draw[?](my_shape) #means invoke the draw version for ? type, which means you calculate at runtime.
getHashCode[T] = (data: T -> string)
getHashCode = (data: Customer -> string ) ...
getHashCode = (data: Circle -> string) ...
getHashCode = (data: Square -> string) ...
```
So, you can either write an implementation for a generic function (normal generics, like add numbers), or make it abstract.
If you make it abstract, you can write other functions with the same name but appropriate input types.
When calling either of these you can use `func[int]` to direct to a specific code, or `func[?]` to ask compiler to decide what type to use.
And no union input argument in any function.
Huge change, but solves a lot of issues about generics, seq and map, polymorphism, ...
How does it affect lambdas? can I define a generic lambda?
What will be the name of this type of functions? Apparently, we are unifying generics and polymorphism.
How can I have a function pointer to one of impl functions?
So we have a group of functions under the same name. these functions can be the same code (generics) or different codes (polymorphism).
`draw[T] = (obj: T -> int)`
`myDrawCircle = draw[Circle](_)`
`myFunc = draw(_)`. This does not make sense.
`myFunc = draw[?](_)`
`myFunc(my_circle)`
`myFunc(my_square)`
This again gives us a change to get rid of union type extension.
**Proposal**:
You can define a group of functions under the same name. If all group functions have the same code it is generics. If codes change it is polymorphism.
Function dispatch is based on union's runtime type.
Notation is `func[T] = (...)`
If it is generics, you provide body for this function. For polymorphism, you don't add a body here and write other functions for body:
Generics:
```
add[T] = (a: T, b: T -> T ) { :: a+b }
add[int](10,20)
```
Polymorphism:
```
draw[T] = (shape: T -> int)
draw[Circle] = (shape: Circle -> int) { ...}
draw[?](my_shape)
draw[Circle](my_circle)
draw[?](my_circle)
```
You can use `?` notation to use compiler to decide which function to call. This can be either via static or dynamic type.
`getShape = (name:string -> (`
What if output of a function is a group function?
`process[T] = (name:string -> [T](x:int->string))`
This is a change which makes inconsistent results. we should stick to normal naming.
For polymorphism, it is fine. We can easily drop the `[T]` notation and use a union.
```
#Generics:
add[T] = (a: T, b: T -> T ) { :: a+b }
add[int](10,20)

#Polymorphism:
draw = (shape: Shape -> int)
draw = (shape: Circle -> int) { ...}
draw(my_shape)
draw(my_circle)
```
But even for polymorphism, we may have some relations.
`compare = (s1: Shape, s2: Shape -> int)` s1 and s2 must have the same type.
Having abstract function helps user know he should add a draw function when adding a new type to Shape.
We can write generics as functions on any or a union.
The problem is relationship. So the general problem is: we want to have a relationship (checked at compile time), between function inputs and outputs.
This relationship can be equality (s1 and s2 must be same shape) or maybe another generic? `A: type, B: type, x: A[B]` but this is too complicated.
Let's stick to equality.
`process = (s: Shape, t: Shape -> Shape)` we want to say inputs have the same type and output will be the same.
We can say arguments with the same type name, should have the same type.
`draw = (s1: Shape, s2: Shape -> int)` s1 and s2 must have the same type
`Shape2 := Shape`
`draw = (s1: Shape, s2: Shape2 -> int)` s1 and s2 can have different types.
But how can I call draw with a Shape?
Suppose that I have two shapes of type Shape.
When calling `draw` I should write: `draw(my_circle, Shape2(my_square))`?
The point is `A := B` means A is just a label for data of type B. so you can easily convert in any direction.
But when we say `add = (x: int, y: int)` x and y must have the same type which makes sense.
`add = (a: any, b:any -> a+b)`
So will compiler generate code for add for each type we call it?
Let's say the rule is: Functions cannot have union input. If a function does, either developer or compiler should provide concrete implementations for basic types.
So `process(int|string)` is not allowed, unless you write two implementations for int and string.
How can we interpret this correctly and make it intuitive?
For polymorphism, no change is needed. Just write your functions and call them via a union type.
No new notation, no new syntax or interpretation.
For generics: We have two types of functions: normal functions with non-union input types, and generic functions with union input type.
For generic functions, the body of the function will be duplicated for all applicable types (compiler will optimize to only duplicate for types needed, but that is implementation dependant).
Generic functions have union inputs. And type names specify relationship between input and output types.
`process = (x: Shape -> y: Shape)` this means output will have the same type as input.
- Shall we use a special notation for generic functions?
e.g. their name should start with `%`? This can be helpful to make things more explicit and readable. Because these are super-functions.
- What about function with union output type? I think these are not generic.
Also note that we have `_` prefix for private functions.
`push%`, `push$`. Suffix is not beaufitul.
`$push`, `%push`, `$` is better because `%` is confusing with math operators.
`$push`, `[push]`. We have generic types that uses `[]`.
`push[]`, `pop[]` But empty brackets does not make sense. 
`push = (s: Stack[any], x: any -> Stack[any])`
Problem: This is not intuitive that three `any` types are generic types.
Let's just use current status: Type arguments
`push = (T: type, s: Stack[T], x: T -> Stack[T]) { ... }`
About lambda? `fp = push(_, _, _)`?
`fp(int, my_stack, data)` `fp = push(int, _, _)` `fp(my_stack, 10)`
ok. So our proposal only covers for polymorphism:
**Proposal**:
1. No `_` notation in generics
2. If you define multiple functions with the same name and number of arguments, the compiler will handle calling them based on dynamic type of unions.
3. No `_:Type` notation in lambda. You cannot discriminate a group of function with the same name. Just pass appropriate type and the corresponding function will be called.
4. Expression problem: Add new type using dynamic compile-time union, add new function using writing the function normally.

N - We say that argument name is not part of the type but for generics, it is.
You cannot send a generic lambda to another function as it is a compile time construct.
But you can remove the compile time part by specifying types for it.
`sort = (T: type, data: Seq[T] -> Seq[T])`
`sortAndProcess = (T: type, sorter: (T, Seq[T] -> Seq[T]) -> int`
or:
`process(Customer, customer_list, sort(Customer, _))`
`process = (T: type, list: Seq[T], sorter: (Seq[T]->Seq[T]))` You cannot have two levels of generics.
So: When assigning a generic function to a pointer, you must specify types for generic args.

Y - we need a type for wid.
so we can pass it to other functions.
`ref`?
I don't like acronyms like `pid` or `cid`. It is a keyword and should have a meaning.
So it is `thread`, `proc`, `codeid`, `ip`
`x := process()`
basically this is the mailbox. not the process itself.
but maybe later we want to add functions to get age of a process, get stats, ... so better to name it more general.
`pid`?
`actor`?
`process`?
`proc`
`thread`
**`task`**
`fibre`
This is done in 

Y - How can we implement complex logics?
```
if ( x ) return false
if ( y and z ) return false
if ( t and u ) return false
if ( y and r ) f=true
if ( f ) return false
return true
```
becomes:
```
out = ifElse(x, false, out2)?
```
Even if we add if/else keywords, it won't solve early return problem.
we can add this notation: `cond::retval` so if condition holds, we will have early return.
`::ret` to do normal return

N - Can we make `T: type` notation more elegant?
`process = (T: ?, ...`
to make this orth, we should allow it everywhere: even inside functions.

? - Polymorphism and generic:
**Proposal**:
1. No `_` notation in generics
2. If you define multiple functions with the same name and number of arguments, the compiler will handle calling them based on dynamic type of unions.
3. No `_:Type` notation in lambda. You cannot discriminate a group of function with the same name. Just pass appropriate type and the corresponding function will be called.
4. Expression problem: Add new type using dynamic compile-time union, add new function using writing the function normally.
Another idea: we have multiple methods with the same name but cannot call them with a shape.
But write a master method which accepts a shape and redirects. This way the process is less automated
```
draw = (c: Circle ...
draw = (s: Square..
masterDraw = (x: Shape ... ) {
	draw(unwrap(x), ...)
}
```
This will make less hidden parts and give the developer more control.
We can use `*` for unions to mean unwrap.
We want to make this process is flexible as we can but still have extensibility so people can add new types and functions.
```
draw = (c: Circle -> int) {...}
draw = (s: Square -> int) {...}
masterDraw = (x: Shape ... ) {
	draw(*x, ...)
}
```
We can even assign `*x` to a binding. It's type will be one of shape types but we don't know at compile time.
What is the difference between type of `my_shape` and `*my_shape`?
idea: Just like compile time dynamic union, we can have dynamic functions. These functions are all part of a single function.
```
Shape = Shape | Circle #here we extend shape function
drawCircle = (x: Circle -> int) { ... }
draw = draw | drawCircle
```
What if we don't have multiple functions with the same name? So lambda problem will be solved.
But how can I call a function without knowing its name? and without knowing it's exact type?
Idea: When adding a new type to a union, we specify it's identifier which is used to create it's polymorphic functions
```
Shape = Shape | Circle {circle}
drawCircle = (x: Circle -> int) ...
draw(my_shape)
```
```
#all shapes have id
Circle = {... id: "circle"}
Shape = Shape | Circle
drawCircle = (x: Circle -> int) ...
draw#my_shape.id(my_shape)
```
String concat is not very elegant.
what if we say we don't have polymorphism?
what happens?
Rather than adding some new concept (multiple functions with the same name), let's provide essentials to implement a vtable.
```
Circle = {...
	vtable: { draw = drawCircle }
}

Shape = Shape | Circle

process = (s: Shape -> s.vtable.draw)
```
But type of vtable is not the same across all shapes.
Another idea: All shapes keep track of their parent.
```
Circle = { s: Shape, ... }
```
Nope.
Another idea: traits, the function to read a shape, does not return a shape, returns a drawable.
```
ShapeTrait = { draw: (int->string), save: ... }
Circle = { ... draw = ..., save: ... }
getShape = (f: File -> ShapeTrait) {
	if type == "Circle":
		return ShapeTrait(Circle{...})
}
s = getShape(...)
s.draw(...)
s.save(...)
```
So ShapeTrait contains the common functionality of all shapes.
Pro: 
- No need to vtable 
- No need to dynamic union
- Is intuitive
- No new syntax.
- The only change: casting a struct to another struct
Con:
- How can I add a new type? Just implement it with appropriate functions so it can be casted to ShapeTrait
- How can I add a new operation?
we need to modify the shape trait.
`ShapeTrait = {*ShapeTrait, export: (...)}`
and we need to add export to all shape structs.
nope.
defining functions inside structs is nice but will be a huge problem when solving expression problem.
decl should be separate or else they won't be extensible: type decl and function decl
let's say we use trait method but using a notation to find functions of a specific type. This is not good because type is not everything.
How is polymorphism implemented internally? It is using vtable. So let's provide features that can be used to add a vtable.
But vtable is specific to one type. It is attached to an object in OOP.
```
my_shape.draw() #?
draw(my_shape) #?
```
I think the second version is better. To more separated things are, the easier to extend them.
```
draw_vtable.apply(my_shape)
```
What if we allow compile time sequences which can be modified at compile time?
Either we have to use `ptr` or very complex union types or unknown generics.
I think the third option is better.
```
getShape(my_file)(vtable)(name, age, input3)
```
The ideal solution: No change to union types, no functions with the same name
```
Circle = {...}
Square = {...}

drawCircle = (x: Circle, g: Canvas, scale: float -> int) {...}
drawSquare = (x: Square, g: Canvas, scale: float -> int) {...}

VTable = {t: type, handler: ptr, next: nothing|VTable}
DrawFunc = (Canvas, float -> int)

#Define a linked list of handlers for different types.
draw_handlers = VTable{t: Circle, handler: &drawCircle, next: nothing}
draw_handlers = VTable{t: Square, handler: &drawSquare, next: draw_handlers}

getShape = (string: name -> (VTable, FType: type ->FType)) {
	if name is "Circle" {
		c = Circle{...}
		:: (x: VTable, FType: type -> FType)
		{
			func_ptr = findEntry(x, Circle);
			:: coreInjectArg(FType, func_ptr, c)
		}
	}
	if name is "Square" ... 
}

my_canvas = createCanvas()
int_result = getShape(DrawFunc, "Circle")(draw_handlers)(my_canvas, 1.19) #we can keep drawfunc and drawfuncraw types inside vtable
```
I think we should have a notation that says, calling a function with insufficient args will create a lambda for remaining args.
This way, we can return a function with some number of args in the code without caring for each individual arg.
Generics: We have same function for all types
Polymorphism: We have different functions for each type
Idea: We can assign a linked list to a function. compiler will lookup appropriate element to call
```
draw = [drawCircle, drawSquare]
draw = draw & [drawTriangle]
```
But still we will have a problem about keeping track of a shape. How can we do that?
```
Circle = {...}
Square = {...}

drawCircle = (x: Circle, g: Canvas, scale: float -> int) {...}
drawSquare = (x: Square, g: Canvas, scale: float -> int) {...}

VTableRow = {t: type, handler: ptr, next: nothing|VTableRow}

#Define a linked list of handlers for different types.
draw_handlers = VTableRow{t: Circle, handler: &drawCircle, next: nothing}
draw_handlers = VTableRow{t: Square, handler: &drawSquare, next: draw_handlers}

VTable = [T: type -> { FType: T, rows: VTableRow}]
draw_vtable = VTable[(Canvas, float -> int)]{ rows: draw_handlers }

getShape = (string: name -> VFunc) {
	if name is "Circle" {
		c = Circle{...}
		:: stdCreateVFunc(Circle, c)
		:: (x: VTable -> VTable.FType)
		{
			func_ptr = findEntry(x, Circle);
			:: coreInjectArg(x.FType, func_ptr, c)
		}
	}
	if name is "Square" ... 
}

my_canvas = createCanvas()
int_result = getShape("Circle")(draw_handlers)(my_canvas, 1.19) #we can keep drawfunc and drawfuncraw types inside vtable
```
This works but we are relying too much on the developer. Mostly about `FType` being a correct type.
Can we embed FType inside vtable?
Why can't we use a generic type? Because we will still have the problem of storing output of getShape.
Another strategy: inclusion types: we can define a type which means "some type which includes a field with this name and type"
```
getShape = (name: string -> {Shape...})
```
No. too much change.
The good thing about current approach is that we don't need dynamic union.
But the con is that it's a bit far from static type (we store ptr and let developer pass us any type).
Now that we want to ask for compiler's help, why not store everything in one place? Something like a sequence but different?
But what will be it's type? We have to have a type for everything. We can store `ptr` in it. And compiler will handle type matching.
But how are we going to store output of getShape? That is also a question.
```
Circle = {...}
Square = {...}

drawCircle = (x: Circle, g: Canvas, scale: float -> int) {...}
drawSquare = (x: Square, g: Canvas, scale: float -> int) {...}

draw = [&drawCircle, &drawSquare]
```
This is too complex. 
**Proposal**:
1. No `_` notation in generics
2. If you define multiple functions with the same name and number of arguments, the compiler will handle calling them based on dynamic type of unions.
3. No `_:Type` notation in lambda. You cannot discriminate a group of function with the same name. Just pass appropriate type and the corresponding function will be called.
4. Expression problem: Add new type using dynamic compile-time union, add new function using writing the function normally.
Another idea: we have multiple methods with the same name but cannot call them with a shape.
But write a master method which accepts a shape and redirects. This way the process is less automated
```
draw = (c: Circle ...
draw = (s: Square..

draw(my_circle)
draw(my_square)
```
Simple and straight forward.
Only about lambda: When you say `x = draw(_)` if there is ambiguity, you should specify type.
if you want multi-method to be called: `x = (x: Shape -> draw(x))` but this does not work. we said function inputs cannot be union.
we may need sometimes to have a multimethod function pointer. a function that works on a shape.
"You cannot define a function with union input" is an exception which we don't want. Let's allow as much as possible.
Allow everythng and even for multimethod rely on developer defining it.
Of course there cannot be overlap between functions. This will be caught by the compiler.
so `(Shape)` and `(Circle)`? Is this overlap? Not really. If you call `func` with a circle it will call the second one.
If you call it with a Shape, it will call the first one.
In other words, the developer is responsible for redirection. Compiler and runtime will dispatch function calls based on static type (Shape).
How can I do the redirection?
```
xdraw = (x: Circle -> ...)
xdraw = (x: Square -> ...)
...
draw = (T: type, s: Shape -> xdraw(T(s)))
...
my_shape = getShape("Circle")
draw(type(my_shape), my_shape)
```
and `type` function only works on a union. in these cases, we generate all implementations for `draw` for all possible types of `my_shape`.
```
draw = (x: Circle -> ...)
draw = (x: Square -> ...)
...
my_shape = getShape("Circle")
draw(*my_shape)
hashCode = (x:int -> int)
hashCode = (x:string -> int)
hashCode = (x:Circle -> int)
hashCode = (x:Customer -> int)
sort = (T: type, data: Seq[T] -> ...) {
	f = hashCode(data.get(0))
}
```
Can this replace generic functions? Polymorphism is different code for different types. Generic is same code for different types.
```
Stack = [T: type -> ...]

```

? - Again: How do we address a generic function using a lambda?
`serialise = (T: type, data: T -> string)`
If we apply above change, we won't have a generic function.
We don't address it directly. Either call function yourself or provide a type.
Because module level functions are compile-time but lambdas ar runtime (you can pass them around)
So: When assigning a generic function to a pointer, you must specify types for generic args.

? - Use case: How to implement a code which starts a helper thread to load some required data at the beginning
and later asks for that data?

? - Ability to import a module with only some functions or types

? - If we assume polymorphic functions using same name, can it replace generics?
we still have generic data types.
e.g. find something in a linked list.
`find = (ll: LinkedList[T], data: T)...`
`find = (ll: LinkedList[any], data: any)...`
We can use `any` but it won't capture relations.
Maybe we can have relationship with some compile time restrictions.
```
find = (ll: LinkedList[any], data: any -> boolean) type(ll) == type(data)
{
	...
}
reverseMap = (m1: Map[any, any] -> Map[any, any]) {
	...
}
```
Idea: we can tag union types to specify their relationship.
`any$1` tags type with `$1`.
```
find = (ll: LinkedList[any$1], data: any$1 -> boolean)
{
	...
}
reverseMap = (m1: Map[any$1, any$2] -> Map[any$2, any$1]) {
	...
}
```
But what if we really want a union here? `Map[int|string, float]`
What if I call draw with`Circle|Square`? It works on only one. So depending on the runtime type, one draw method will be called.
But in abstract data types like map, we sometimes need to do something e.g. search or sort, on a sequence of unions.
In other words, `any` type arguments will have only one type/
But `any` generic arguments for generic types, can be anything.
This is confusing. because we are re-using the union concept.
```
find = (T: type, ll: LinkedList[T], data: T -> boolean)
{
	...
}
reverseMap = (K: type, V: type, m1: Map[K, V] -> Map[V, K]) {
	...
}
```
Does the union issue exist for polymorphic functions?
e.g. we have a method called serialise which gets a sequence of shapes.
`save = (x: Seq[Shape]...)`
But, `Seq[Shape]` is not a union so it is fine. You can put any compliant binding inside `Seq[Shape]` and it will be fine to use it for save.
we didn't write: `Seq[Shape] | Seq[Drawable]`.
If an argument is of union type then polymorphism says, write separate functions and runtime will find appropriate impl for dynamic type.
So, back to generics, can we use this to solve initial problem?
```
find = (ll: LinkedList[any$1], data: any$1 -> boolean)
{
	...
}
reverseMap = (m1: Map[any$1, any$2] -> Map[any$2, any$1]) {
	...
}
```
any means the type is not important for us. if it is always coming with `$` can we eliminate it?
```
find = (ll: LinkedList[$1], data: $1 -> boolean)
{
	...
}
map = (arr: Seq[$1], pred: ($1->$2) -> Seq[$2]) {
	...
}
groupBy = (arr: Seq[$1], group: ($1->$2) -> Map[$2, Seq[$1]]) {
	...
}
```
Can we make this more limited? For 90% of the cases, only two generic type arguments are enough? `$` and `&`.
But we have a rule: zero, one or unlimited.
Can we do this via one type only? Maybe divide complex functions into multiple functions each with one type?
This notation is more limited that `T: type` notation because you cannot mix types (e.g. `$1[$2]`).
But we cannot re-assign a binding. We have many bindings with the same name `find`.
This is ok for polymorphism because we create a master union type. Can we create a master function for this case too?
We don't need to. Because we don't have a master union type.
```
for all types T:
get = (s: Seq[T], index: int -> T) {
	...
}
```

? - For error handling we can use polymorphism concepts:
```
ErrorItem = A | B
ErrorItem = ErrorItem | MyFileError
Error = {errorItem: ErrorItem, cause: Nothing|Error}
process = (x:int -> nothing|Error)`
```
This way we can have nested and extensible errors.

? - We can use `Shape = Circle |` notation to have a union which for now has only one option.

? - Zig
https://andrewkelley.me/post/zig-programming-language-blurs-line-compile-time-run-time.html
The idea is like me.
Type are first class citizens. Functions can even return types.
```
fn max(comptime T: type, a: T, b: T) -> T {
    if (a > b) a else b
}

max(f32, a, b)
```
comptime means the value must be specified at compile time.
I think we can eliminate that and say types must be specified at compile time.
specialisation:
```
fn max(comptime T: type, a: T, b: T) -> T {
    if (T == bool) {
        return a or b;
    } else if (a > b) {
        return a;
    } else {
        return b;
    }
}
```
Using functions that return a type, we can have generic types.
```
fn List(comptime T: type) -> type {
    struct {
        items: []T,
        len: usize,
    }
}
```
In dot:
```
list = (T: type -> type) {
	:: {item: T, next: list(T)
}
```
So we can have:
`Customer = {name: string, age:int}`
or use a function to create a type.
`Customer = makeCustomerType(string)`
This will make this notation obsolete:
`Customer = [T: type -> {name:T, age: int}]`
And so we will have no application for `[]`.
Maybe we can use it for sequence notation at it's most raw form:
`x = [1,2,3]`
`process = (x: [int]...)`
we can use generic types like this:
`process = (c: makeCustomerType(string) ...)`
or
`process = (c: Customer ...)`
But we need to have a difference between types and values.
Functions that return a type should be PascalCased.
Bindings that store a type, should be PascalCased.
Other functions are camedCased.
Other bindings are under_line_separated.
So we have to kinds of binding: To store a type or to store a value.
type bindings are compile time decidable.
`Customer = MakeCustomerType(string)`
How to define a linked list?
```
LinkedList = (T: type -> type) 
{
	Node = {
		data: T,
		next: Node
	}
	:: Node
}
```

? - anonym types
To keep the language small and uniform, all aggregate types in Zig are anonymous. To give a type a name, we assign it to a constant:
```
Node = struct {
    next: *Node,
    name: []u8,
};
```

? - Let developer use function calls to initialise module level bindings

? - Is it possible to have a generic logger function which accepts any function, logs something and calls the function?

? - If `[]` will only be used for generics, maybe we should stop using it in import.

? - how can someone implement BigInt?

? - Can we implement smart slice without core?
