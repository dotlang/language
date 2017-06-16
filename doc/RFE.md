 
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
