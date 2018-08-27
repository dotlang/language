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





==========


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
receive(Message, {predicate:(m: Message -> m.sender = 12), predicate:(m: Message -> processNormal(m))}, 
                 {predicate:(m: Message -> m.sender = 14), predicate:(m: Message -> processImp(m))})
```
Seems that predicate with lambda is the most practical solution. 
We can add a compiler warning if this predicate is not a simple expression.
1. No channel notation, no channel send or receive
2. `:=` will return a worker id (wid) which can be used to send and receive data
3. `was_sent_bool = send(my_data, receiver_wid1)`. 
4. `receive(int, handlers)`
5. Send is not blocking, but if you need ack, you can receive and wait for "ack" response from recipient wid.
We don't need a handler for receive. we just provide predicate.
```
Predicate = [T: type -> (T->bool)]
receive = (T: type, handlers: predicate[T]...)
...
received_message = receive(Message, (m: Message -> m.sender == 13))
```







? - Can we have cache with message passing?
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

? - Can we convert union to case class like in scala?
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

? - We can say, union type when used as type of binding specifies range of possible values it can hold.
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
**Proposal**:
1. When a union type is used for a binding, that binding may have value for any of it's types.
2. When a union type is used for a type specifier, it represents valid types for that type and that type can be used to specify type of other arguments.
3. `||` is a union type of all possible types.
4. 

? - Review examples section

? - Can we make union with constant values more explicit?
`Shape = Circle | Square`
`DayOfWeek = SAT | SUN ...`
