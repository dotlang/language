? - Add to pattern section: Stack, Tree, loop

? - Allowing functions in a struct is just like defining a function to create instances of the struct.
And initialising those lambda fields inside that function and calling it to create a new struct.
It is a useful simplification. No new concept is added. Everything is the same: Closure, function, ...

? - Can we import a module inside a struct definition?
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


? - How can I import a sequence of modules? Because now, sequence is not built-in.
