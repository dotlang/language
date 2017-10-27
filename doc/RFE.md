 
N - Can we simplify conditional return.
```
a := ...
:: 100 #this means return 100
::: 100 #this means return 100 only if the previously assigned binding is true
:cond: 100 #return if cond holds, but then we will have two notations for return :: and :???:
```
And maybe return return keyword?
return = eject
`x := 100 ::`
option 1: Use special variable for return value. but this does not solve early return problem.
`if ( condition ) return 100`
`(condition) return 100`
`(cond):: 100`
`:: 100`
But `()` can be confusing if there is a function call. So we use `{}`.

Y - For chain use `.[]`.
Even if we have single option.
1. `add := (x:int, y:int) -> x+y`, `(10, 20).[add(_,_)]` => `add(10,20)`
2. `({1,2}).[processStruct(_)]` => `processStruct({1,2})`
3. `(6).[addTo(1, _)]` => `addTo(1, 6)`
4. `result := (input, check1(5, _)).[pipe(_,_)].[pipe(_, check3(1,2,_))].[pipe(_,check5(8,_,1))]`
5. `result := error_or_int.[(x:error)->10, (y:int)->20]`
`data.[sequence]`
If the lambda has n inputs and left side has n items:
`(x1).[process(_)]`
`lambda := process(_)`
`(x1,x2,...,xn).[lambda]`

Y - `!` is also used for write only channels. Can we use a better notation for import?
`! "/core/socket"`
`@`
`types and bindings`
`_,_ := "/core/socket"`
What if we only want to import types/bindings? Not very useful.
`_ := @"/core/socket"`
`_ := @["/core/socket", "/core/server"]`
So `_ := @"...."` is a shortcut for a number of definitions (type and binding).
Why not force `[]` just like chain operator?
`_ := @["/core/socket"]`
`_ := @["/core/socket"] { MyType, processData }`
`_ := @["/core/socket"] { MyType, processData := pData }`
`_ := @["/core/socket", "/core/data/{tree, graph}"] { _, MyType, processData := pData }`
What if I write something else on the left side?
Only the items that are mentioned there will be imported
`MyType, processData := @["/core/socket"] { MyType := DDType }`
`ResultItemsOrUnderscore := @[sequence of strings] { rename }`
With this notation we can import one module multiple times:
`SocketStat := @["/core/socket"]`
`openSocket := @["/core/socket"]`

Y - Can we make return notation more intuitive?
`:: 100`
Whats the most intuitive notation to finish execution of current function?
`:: 100`
`{x<0} :: 100`
What if we assume having a magic function?
`ret(100)`
`ret(100,x<10)`
No. its not intuitive.
Maybe we can combine it with chain operator.
So chain operator can accept a special lambda called return.
`x.[return]` means return x from current function.
Its not intuitive.
Anyway this is an exception because it is the only control structure that we have in the language.
option 1: define a magic variable which stores result of the function call.
What if I have access to the variable which is supposed to contain output of current function's call?
`x := process()`
and inside process, I have access to a storage which is supposed to contain result of the function call.
Because of imm rules, I should only assign it once. So as soon as it is assigned, function execution should be finished.
Even if you assign nothing.
Let's call it `*` for now.
`* := 100` means return 100 and exit current function.
But this does not solve conditional part.
I want to assign to `*` if and only if ...
Can we make use of nothing here?
`* := [nothing, 100][condition]`
If we assign nothing to `*` it won't cause return from current function.
So the only way to return nothing will be normal return.
What if I have a function that will return `nothing|int` and there is some situation where I have to return `nothing`?
Just handle it like fp paradigm: rest of the function goes into a lambda which will be only called if we want to return int.
so `* := nothing` wont make sense and is same as `NOP`.
If you want to return nothing, you must do it the hard way:
```
process := (x:int) -> int|nothing 
{
  #if x is negative return nothing
  ...some processing code...
  #if x>100 assign result of lambda1 to output and exit immediately
  temp := [() -> nothing, lambda1][x>100]()
  * := temp
}
```
`* := x`
means assign `x // rest of the function` to the expected output memory location. So we are looking for a shortcut for this:
`* := xyz // rest`
`return xyz // rest`
`:: xyz`

proposal:
`:: := ????`
`{} := 1000` this can also mean empty struct, a bit confusing
`[] := 1000`
`|| := 1000` 
`<> := 1000` ugly
`^ := 1000` 
It's better to be similar/compatible with shortcut notation:
`process := (x:int) -> :: x+1`

N - Can `10` be a function which accepts 10 for every input? Then maybe we can chain to it.
But then it won't have any use.
`int_or_float.[(x:float)->100, 200]` this will always return 200.
`int_or_float.[(x:float)->100, (_:int) -> 200]` this is correct.

N - What if we chain to a function which does not accept that input?
`error_or_int.[(x:error)->10]`?
No. It will be ambiguous what happens if input is error.


? - Shall we make it mandatory to mention return type if there is a body? `{}`
`process := (x:int)->int { return x+1}`
`process := (x:int)-> x+1` if it is a single expression, you dont need to mention type

? - We can use the same operator for loading modules at runtime `@`. but it won't be able to use `_`.
So if load function's input is not compile-time value, it's output must be assigned to some identifiers.

