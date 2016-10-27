#Notes
- Compiler will need to keep track of offset for members of classes. So `this.x` will have to be resolved to `*(_this_+24)` for example. Compiler needs to know offset for each member of a class.
- Compiler needs to stack/heap address for variables in each scope. 
- When `auto x = Class1 {}` is seen by compiler, it will render instructions to call `Class1.new` and store the result of the call into variable `x`. Also will update symbol table so `x` will point to the correct type. 
- Also need to keep track of a hashtable (key, value) where key is fully-qualified method name (package1.package2.package3.classname.methodname) and value is the interpreted data structure or a pointer to the compiled function in memory.
- Compiler should keep track of processed files so it won't process a file twice. 
- Compiler should be able to resolve a type name to fully-qualified name (e.g. `Class1` to `pack1.pack2.Class1`).
- Everything will be a class (except primitives). so we will have `StaticArray<T>` and `Hash<K, V>` with probabaly compiler-provided functions. There will be normal methods for `[]` operators and compiler will translate `x[1]` to `x.get(1)` call. But this is only supported for these types and not all types. 
- When there is something like `x.method()` in the code, compiler will exactly know which method in which file is going to be called.
- Compiler needs to keep track of a set of native (C written) methods with their singature. This will be a `Hash<String, Pair<Signature, Pointer>>` which given inernal name of a function, will give it's singature and a pointer to the implementation of that function. Then:
`jit_insn_call_native(current_func, "func1", func1_ptr, func1_signature, input_args, arg_count, JIT_CALL_NOTHROW);`
- For example `long currentTime()` method in `Time` class in `core.utils` package will have a full name of: `core.utils.Time.currentTime` and will just call appropriate C STL method.
- Compiler should be able to get heap size needed to create instances of any class, and offset of each of their members.
- Also compiler should know name and index of parameters of all methods. So when call by parameter name is used, it can translate the code to a normal call.
- Rutime system should keep track of type of each reference. Because only at runtime we know to which method should `obj.method1` be resolved (if `obj` is of interface type). 
- All method calls can be mapped at implementations at compile time except empty methods. These are like virtual methods in C++ and will be dispatched at runtime. For example we may have an interface `A` and a method like `int func(A data)` which calls some methods on `data` argument. These method calls cannot be determined at compile time. They will be mapped at runtime. So at runtime we have to maintain a table (per variable) of function name and pointers which determine which method to call.
