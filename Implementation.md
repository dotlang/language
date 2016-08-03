#Notes
- Compiler will need to keep track of offset for members of classes. So `this.x` will have to be resolved to `*(_this_+24)` for example. Compiler needs to know offset for each member of a class.
- Compiler needs to stack/heap address for variables in each scope. 
- When `auto x = Class1 {}` is seen by compiler, it will render instructions to call `Class1.new` and store the result of the call into variable `x`. Also will update symbol table so `x` will point to the correct type. 
- Also need to keep track of a hashtable (key, value) where key is fully-qualified method name (package1.package2.package3.classname.methodname) and value is the interpreted data structure or a pointer to the compiled function in memory.
- Compiler should keep track of processed files so it won't process a file twice. 
- Compiler should be able to resolve a type name to fully-qualified name (e.g. `Class1` to `pack1.pack2.Class1`).
