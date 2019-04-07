# Patterns

Because a lot of non-essential features are removed from the language and core, the user has freedom to implement them however they want. In this section we provide some of possible solutions for these types of challenges.

## Polymorphism

Polymorphism can be achieved using cloure and lambdas. 

```rust
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

Shape = struct ( draw: fn(Canvas, float -> int) )
getShape = fn(name: String -> Shape) 
{
    ["Circle": fn{
		c = Circle{...}
		Shape( draw : drawCircle(c, _, _) )
     }, "Square": ...][name]()
}

f = getShape("Circle")
f.draw(my_canvas, 1.12)
```

If you want to add a new shape (e.g. Triangle), you should add appropriate functions (And the map in `getShape` needs to be modified).
If you want to add a new operation (e.g. print), you will need to add a new function to `Shape` and assign to it in `gtShape`.

Note that above `Shape` is very similar to "trait".

Another approach to implement polymorphism is by using a minified VTable:

```rust
drawCircle = fn(s: Circle, c: Canvas, f: float -> int) {...}
drawSquare = fn(s: Square, c: Canvas, f: float -> int) {...}

getDraw = fn(x: T, T: type -> fn(Canvas, float -> int)) 
{
    vtable = [Circle : drawCircle, Square: drawSquare]
    cast(fn(T, Canvas, float), vtable[T])(x, _, _)
}

f = getDraw(my_circle)(my_canvas, 1.52)
```

## Exception handling

There is no explicit support for exceptions. You can return a specific `exception` type instead (or use `nothing` type to indicate exception).

If a really unrecoverable error happens, you should exit the application by calling `exit` function from core. 

In special cases like a plugin system, where you must control exceptions, you can use built-in functions to call plugin. It will return an error result if the function which it calls exits unexpectedly.

Example: `process = fn(nothing -> int|exception) { ... return exception{...} }`

## Conditionals

If and Else constructs can be implemented using the fact that booleans converted to integer will result to `0` or `1` (for `false` and `true`).

```
ifElse = fn(cond: bool, true_case: T, false_case:T, T: type -> T) 
{
	[true: true_case, false: false_case][cond]
}
```

Another example:

```
process = fn(x:int -> string)
{
	temp = [x>0 : fn{ saveLargeFileToDB("SDSDASDA") }, 
		    x<=0: fn{ innerProcess(x) }  
            ]

	temp[true]()
}
```

## Dependency management

It is advised to put all import paths in one module like `refs` and import it to specify import paths.

```
#refs
std_map = "/http/github.com/dotLang/std/v1.9.5/MapHelper"
```
and then use above:
```
#File1
refs = import("/src/main")
MapHelper = import(refs..std_map)
```

# Examples

## Empty application

```
main = fn( -> int ) { 0 }
```

This is a function, called `main` which has no input and always returns `0` (very similar to C/C++ except `main` function has no input).

You can shorten `main` to below:

`main = fn{ 0 }`

## Hello world

```
main = fn( -> int) 
{
	print("Hello world!")
	0
}
```

## Expression parser

We want to write a function which accepts a string like `"2+4-3"` and returns the result (`3`).

```
NormalExpression = {op: char, left: Expression, right: Expression}
Expression = int|NormalExpression

eval = fn(input: string -> float) 
{
  exp = parse(input) #assume we already have this
  innerEval(exp)
}

innerEval = fn(exp: Expression -> float) 
{
  hasType(int, exp) :: int(exp).0
  
  #now we are sure that exp is an expression
  y,_ = *NormalExpression{exp}
  
  y.op == '+' :: innerEval(y.left) + innerEval(y.right)
  y.op == '-' :: innerEval(y.left) - innerEval(y.right)
  y.op == '*' :: innerEval(y.left) * innerEval(y.right)
  y.op == '/' :: innerEval(y.left) / innerEval(y.right)
  
  #no exception handling for now
  :: 0
}
```

## Quick sort

```
quickSort = fn(list:[int], low: int, high: int -> [int])
{
  high<low :: list
  
  mid_index = (high+low)/2
  pivot = list[mid_index]
  
  #filter is a built-in function
  small_list = list.filter(fn(x -> x < pivot))
  big_list   = list.filter(fn(x -> x > pivot))
  
  :: quickSort(small_list) + [pivot] + quickSort(big_list)
}
```

## Sequence sum

A function which accepts a list of numbers and returns sum of numbers.

```
filteredSum = (data: [int] -> int)
{
  calc = (index: int, sum: int -> int)
  {
    index >= length(data) :: sum
    :: calc(index+1, sum+data[index])
  }
  
  :: calc(0,0)
}
```

## Digit extractor

A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.

```
extractor = (n: number, result: string -> string)
{
  n < 10 :: result + char(48+n)
  digit = n % 10
  :: extractor(n/10, result + char(48+digit)
}
```

## Max sum

A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.

```
maxSum = (a: [int], b: [int] -> int)
{
	calc = (idx1: int, idx2: int, current_max: int -> int)
	{
		idx2 >= length(b) :: current_max
		sum = a[idx1] + b[idx2]
		next1 = (idx1+1) % length(a)
		next2 = idx2 + int((idx1+1)/length(a))
		:: calc(next1, next2, max(current_max, sum))
	}
	
	:: calc(0, 0, 0)
}
```

## Fibonacci

```
fib = (n: int, cache: [int|nothing] -> int)
{
	cache[n] != nothing :: int(cache[n]).0
	seq_final1 = set(seq, n-1, fib(n-1, cache))
	seq_final2 = set(seq_final1, n-2, fib(n-2, seq_final1))

	:: seq_final2[n-1] + seq_final2[n-2]
}
```

## Cache

A cache can be implemented using a parallel task. Everytime cache is updated, it will call itself with the new state.

```
CacheState = [string: int]
cache = (cs: CacheState->)
{
    request = pick(Message[CacheStore])
    new_cache_state = update(cs, request)
    query = receive(Message[CacheQuery])
    result = lookup(new_cache_state, query)
    send(Message{my_wid, query.sender_wid, result})
    cache(new_cache_state)
}
```

### Guessing game

```
stdin = import("/http/github.com/dotLang/std/stdin"){}
stdout = import("/http/github.com/dotLang/std/stdout"){}
rand = import("/http/github.com/dotLang/std/random"){}

main = fn
{
	secret = rand(1,100)
	stdout.write("Please enter a number: ");
	guessRaw: int|nothing = tryParseString(int, stdin.readLine())
		
	ifElse(guessRaw == nothing, 
	fn{
		stdout.write("Invalid number")
	},
	fn {
		guess = cast(int, guessRaw)
		actions = [guess<secret: fn{ stdout.write("Too small!") },
				   guess>secret: fn{ stdout.write("Too large!") },
				   guess==secret: fn{ stdout.write("Well done!") }
				  ][true]()
	})
}
```

