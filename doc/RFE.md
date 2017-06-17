 
Y - Note that `val` can only appear on the left side of `=` when it is being declared. What comes on the right side of `=` must be either another val or made val using `@val` or a literal. This notation will duplicate it's input if needed.
There is no need to force clone a val with `@val(@t))` notation. because cloning is used when we want to detach left side of assignment from right side. but for val, there is no attachment.

Y - Slice should keep a pointer to parent array + index number.
Because to make things safe, we should let pointer operations only on binary.
So it cannot have a pointer variable.

N - can result of an expression be val?
`x=y+z` can y+z be val?

Y - `=>` should be same as `>=` and also `<=` ~ `=<`

N - Can developer write his own "byte" data type?

N - `x=literal` will copy-value because litearl is not reference type.

Y - force single space between func and function name.

Y - Shall we have pointer data type?
`var t: ptr[int]`
`t=10`?
`*t=10`
`t=&y`
`t=addr(y)` `t=&y`
`set(t, 10)` `*t=10`
`t() = 10` will cal opCall which returns a `var int`.
it will be very confusing. because we already have references. working on non-binary data with pointer makes things confusing.

Y - What does `==` compare now that everything is a ref?
`x==y` The easy way is to say it will do data comparison.
if you want to see if they are same references,
`x =? y`
`ref(x) == ref(y)`

N - Can we make use of binary to increase performance? 
Like having unboxed (non-ref) data?
suppose we want to do fast math operations. but compiler will optimize for this.
Do not make language more complex for the sake of something which compiler can do.

Y - What should be initial value of variables?
`var x: Point` `process(x)` what should happen?
variables are initialized upon declaration. for val you must assign value, for var, compiler will set default value (everything zero, empty, ...)
`var x: array[int]` will create an empty array

Y - Can we define label for union types better?
more formal.
`type MaybeInt := int | Nothing`
Labels define a new type which has only one value with the same notation (or use them).
`type UnionType := Type1 | Type2 | Type3 | ...`
`type Nothing` - defines a type which has only one valid value: Nothing

Y - write methods with inline assembly.
And methods that can force compiler to be inlined, so they don't have pushall/popall statements.
Like by using `=`
`func process(x: int) -> int = x+1` for force inline. But problem is inline must be done by compiler.
Method resolution which happens at runtime may call this. so it cannot be inlines upon each call.
This can help me write parts of the language in itself. Only need to provide basic compiler. then others can be written in assembly.
compiler may not be able to enforce val/var for these methods.
```
func process(x:int) -> int 
{|
  mov ax, 10
  mov bx, 20
  add ax, bx
|}
```
`{| ... |}` for assembly
`{|| ... ||}` for inline assembly

Y - inlining will be done by compiler. What about methods with assembly code?
Maybe some methods must be inlined. Can compiler deduce this?
Convention: Methods that start with double underscore must be inlined. But we want methods that can be easily called.

Y - We should provide some syntax in assembly to write cross-OS and cross-hw code.
```
func process(x:int) -> int 
{|
   (OS == WIN)
   {
     mov ax, 10
     mov bx, 20
     add ax, bx
   }
   (CPU != Intel)
   {
      mov ax, 12
   }
|}
```

N - Why not have everything value and compiler converts them to references when it needs to? Won't it make things simpler for the developer?
Because we will loose flexibility of pointer operations.

Y - Let `=` and `==` act as if data is data and not a reference.
Currencylt `==` acts this way. Compares real data, not references. But there are functions to compare ref.
`x=y` should copy data of y into x. So if rvalue is a temp variable (e.g. `x=1+y`), it will be a ref-assign handled by the compiler. if you want x to reference to place where y is pointing to, you must use another notation.
`x << y`
`var x: point = y` will copy all the data inside y to x
`var x: point => y` x will point to the same location as y.
`var x: point = ref(y)` but this is not intuitive.
`var x: point = @ptr[point](y)`
when we write `x=y` we expect x and y be the same thing. if x points to y we have achieved this, but then x and y will be bound together.
for a newbie this might be confusing:
```
var x: Point = {a=10, b=20}
var y: Point = x
y.a++
print x.a ;will print 11!
```
OTOH, if we say `=` will copy data, above code will print 10 which is what we put into x initially.
in copy semantics: there might be cases where a `=` will be expensive (large data)
in ref-assign semantics: there might be cases where a `=` will be confusing (non-primitive data).
which case is more common? using large data or using non-primitives? I think non-primitives are used much more. so we should focus on those cases: we should prevent confusing behavior in ref-assign semantics. So we should use copy semantics. And in rare cases where a very large data variable is being used, the developer is responsible to ref-assign.
But we do our best not to involve developer into reference vs. data confusion. In eyes of the developer everything should be what it seems to be. `int` is an integer number not a reference number, although compiler/runtime will handle it as a reference to make other language features (e.g. var) work.
So when he writes `x=y` it expects y be copied into x.
to do ref-assign we should use either a special notation or a core function. using `=` will cause confusion.
`var x:BigBuffer = y` this is expensive! we should prevent it.
`var x: BigBuffer = &y` like C but it is confusing. left side is BigBuffer and then what is type of right side? How do you define `&y`?
`var x: BigBuffer := y` this is intuitive and makes sense but might be confused with type declaration.
Anyway, it is more consistent with type declaration concept. If we write `type MyInt := int` it will be some kind of assignment as a reference. MyInt is a reference to int type.
`x := y` will make x point to the same thing as y. 
`val x = otherVal` copy (or ref-assign due to optimization)
`var x = otherVar` copy
`val x = otherVar` copy (or ref-assign due to optimization)
`var x = otherVal` copy 
`= = = = = = = = = = =`
`val x := otherVal` ref-assign
`var x := otherVar` ref-assign
`val x := otherVar` ref-assign
`var x := otherVal` invalid. You cannot have a var pointer to a val memory area.
`= = = = = = = = = = =`
`val x = @val(otherVal)`  copy 
`var x = @var(otherVar)`  copy
`val x = @val(otherVar)`  copy
`var x = @var(otherVal)`  copy
`= = = = = = = = = = =`
`val x := @val(otherVal)` ref-assign
`var x := @var(otherVar)` ref-assign
`val x := @val(otherVar)` ref-assign
`var x := @var(otherVal)` ref-assign to copy of otherVal
I think this model makes more sense and is more intuitive. `=` copies right side into left side.
`:=` makes left side reference to the place right side is referncing. Of course both left and right must be consistent (var-var or val-val).
Now, do we still need cloning notation? `x=@y` -> `x=y`. no.
this will affect: `@val/var`, parameter passing and return, cloning, slice, array, binary.
I think we still need `@var/@val` notation. Especially in shortcut functions.
1. missing input qualifier = val.
2. missing output qualifier: val.
`func process(x: int) -> x+1` - return is var
`func process(val x:int) -> x` return is val
`func process(var x:int) -> x` return is a val
parameter passing: if val is expected, you can pass either var or val.
3. no more clone operator.
slice means a pointer and a length.
```
func get[V,T where vax: var|val](vax arr: array[T], index: int) -> vax T {
    vax T result := arr.data + index*sizeof[T]
    return result ;we cannot shortcut this by writing something like "return *(arr.data + index*a)"
}
```
`a:=b` means a should point to the memory cell which stored result of the right side.
`a:=b+1` means calculate b+1, store result somewhere and make a point to that location.
`a:=b+c+d+8` add right side values, store result somewhere and make a point to that location.
if you want a point to location of next cell after b, you must use core functions:
`a:=getOffset(b, 1)`
`var p1: int := getOffset(buffer, 8)` 
-what comes on the right side of `:=` is an address, but `a:=b+c+7` this doesn't make sense.
- We no longer need ptr type, everything is a pointer.
- `type slice[T] = (length: int, start: T)`
- `type array[N: int, T] = (size:int, data: binary[N])`
`var x : int := otherVar`
`a=b` means copy value of b into value of a
`a:=b` means copy b into a
`a:=b` is same as `a = &b` in C++.
`a:=a+1`
- We also don't need `@var/val`?
what if function wants to return a val? don't specify anything and result is val.
what if function shortcut wants to reurn a var? 
`func process(val x:int) -> var int x+1`

Y - Clarify:
can we have a read-only view of a read-write memory cell?
C++ can do this: The only thing special about a pointer-to-const is that you cannot change the pointed-to object through this particular pointer. It's entirely possible to change the object in some other way (https://stackoverflow.com/questions/27139496/pointer-to-a-constant-pointing-to-normal-variable).
So basically, `val x = var1` is ok and possible.

Y - Clarify single space in type definition and protocol too.

Y - The `:=` is a very powerful operator. But in what cases do we need it?
`x := y`. 
- When I want to have a val view on a var. But if function has val, I can simply send var to it.
- For internals of array and slice. (we can use native and implement in compiler or use core functions to get address and get/set operations, we can even use ptr type).
- When output of a function is a large data structure: `var x = getLargeBuffer()` will duplicate the buffer which is expensive.

? - function chaining: `=>` and `<=`.
Advantage: less paren.
`finalize_operation(1,9,4, $_) <= get_customers <= (1,9)`
`calculate(data) => print => save`
`data => calculate => print => save`
`data => calculate(_) => print(_) => save(_)`
`string => contains(':')`

? - Better encapsulation.
So if I change something, I may need to update 100s of places.
