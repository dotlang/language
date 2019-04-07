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

```rust
ifElse = fn(cond: bool, true_case: T, false_case:T, T: type -> T) 
{
	[true: true_case, false: false_case][cond]
}
```

Another example:

```rust
process = fn(x:int -> string)
{
	temp = [x>0 : fn{ saveLargeFileToDB("SDSDASDA") }, 
		    x<=0: fn{ innerProcess(x) }  
            ]

	temp[true]()
}
```

Above sample implemented using ifElse function:

```rust
process = fn(x:int -> string)
{
    ifElse(x>0, fn{
        saveLargeFileToDB("SDSDASDA") 
    }, fn{
        innerProcess(x)
    })()
}
```

Above is translation of below C code:

```c
string process(int x) {
    char* result;
    
    if ( x > 0 ) {
        result = saveLargeFileToDB("SDSDASDA");
    } else {
        result = innerProcess(x);
    }
    
    return result;
}
```

## Dependency management

It is advised to put all import paths in one module like `refs` and import it to specify import paths.

```rust
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

```rust
main = fn( -> int ) { 0 }
```

This is a function, called `main` which has no input and always returns `0` (very similar to C/C++ except `main` function has no input).

You can shorten `main` to below:

`main = fn{ 0 }`

## Hello world

```rust
main = fn( -> int) 
{
	print("Hello world!")
	0
}
```

## Expression parser

We want to write a function which accepts a string like `"2+4-3"` and returns the result (`3`).

```rust
NormalExpression = struct (op: char, left: Expression, right: Expression)
Expression = int|NormalExpression

eval = fn(input: string -> float) 
{
  exp = parse(input) #assume we already have this
  innerEval(exp)
}

innerEval = fn(exp: Expression -> float) 
{
	int_val, normal_exp = exp
    int_val // fn{
        #now we are sure that exp is of type NormalExpression
        y = unwrap(normal_exp)

        ['+' : fn{innerEval(y.left) + innerEval(y.right)},
         '-' : fn{innerEval(y.left) - innerEval(y.right)},
         '*' : fn{innerEval(y.left) * innerEval(y.right)},
         '/' : fn{innerEval(y.left) / innerEval(y.right)}][y.op]()
    }()
}
```

## Quick sort

```rust
quickSort = fn(list:[int], low: int, high: int -> [int])
{
    ifElse(high<low, list, fn{	
        mid_index = (high+low)/2
        pivot = list[mid_index]

        #filter is a built-in function
        small_list = filter(list, fn(x:int -> bool) {x < pivot}))
        big_list   = filter(list, fn(x:int -> bool) {x > pivot}))

        quickSort(small_list) + [pivot] + quickSort(big_list)
    })
}
```

## Sequence sum

A function which accepts a list of numbers and returns sum of numbers.

```rust
sum = (data: [int] -> int)
{
  calc = (index: int, sum: int -> int)
  {
    iElse(index >= length(data), fn{sum}
        fn{calc(index+1, sum + data[index]})()
  }
  
  calc(0,0)
}
```

## Digit extractor

A function which accepts a number and returns it's digits in a sequence of characters.
Generally for this purpose, using a linked-list is better because it will provide better performance.

```rust
extractor = (n: number, result: string -> string)
{
  ifElse(n < 10, fn{result + char(48+n)}, fn{
        digit = n % 10
        extractor(n/10, result + char(48+digit)
     })
}
```

## Max sum

A function which accepts two sequences of numbers and returns the maximum of sum of any any two numbers chosen from each of them.
This can be done by finding maximum element in each of the arrays but we want to do it with a nested loop.

```rust
maxSum = (a: [int], b: [int] -> int)
{
	calc = (idx1: int, idx2: int, current_max: int -> int)
	{
		ifElse(idx2 >= length(b), fn{current_max}, fn{
		    sum = a[idx1] + b[idx2]
		    next1 = (idx1+1) % length(a)
		    next2 = idx2 + int((idx1+1)/length(a))
		    calc(next1, next2, max(current_max, sum))
        })
	}
	
	calc(0, 0, 0)
}
```

## Fibonacci

```rust
fib = (n: int, cache: [int|nothing] -> int)
{
	ifElse(cache[n] != nothing, unwrap(cache[n], int),
		fn{
	        seq_final1 = set(seq, n-1, fib(n-1, cache))
	        seq_final2 = set(seq_final1, n-2, fib(n-2, seq_final1))

	        seq_final2[n-1] + seq_final2[n-2]
        })
}
```

## Cache

A cache can be implemented using a parallel task. Everytime cache is updated, it will call itself with the new state.

```rust
CacheState = [string: int]
cache = (cs: CacheState->)
{
    request = pick(CacheStoreMessage)
    new_cache_state = update(cs, request)
    query = receive(CacheQueryMessage)
    result = lookup(new_cache_state, query)
    send(Message(my_wid, query.sender_wid, result))
    cache(new_cache_state)
}
```

### Guessing game

```rust
std = import("/http/github.com/dotLang/std")
stdin = std..stdin
stdout = std..stdout
rand = std..random

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
		guess = unwrap(guessRaw)
		actions = [guess<secret: fn{ stdout.write("Too small!") },
				   guess>secret: fn{ stdout.write("Too large!") },
				   guess==secret: fn{ stdout.write("Well done!") }
				  ][true]()
	})
}
```

