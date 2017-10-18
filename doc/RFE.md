 
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

