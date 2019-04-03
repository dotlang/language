# Bindings

A binding assigns an identifier to an immutable memory location. A binding's value can be a literal value, an expression or another binding. The literal value can be of any valid type (integer number, function literal, struct literal, ...). Binding names must start with a lowercase letter.

You can define bindings at module-level or inside a function. Module-level bindings can only have literals as their value. Type of a binding can be inferred without ambiguity from right side value, but you also have the option to specify the type (Example 1 and 2).

If the right side is a struct, you can destruct it into it's elements by using comma separated values on the left side of `=` (Example 3). In this process, you can also use underscore to indicate you are not interested in one or more of those elements (Example 4).

You can call built-in dispose function to explicitly free resources allocated for a binding. Any reference to a binding after call to dispose will result in compiler error.

**Syntax**: 

1. `identifier = expression`
2. `identifier : type = expression`

**Examples**

1. `x : int = 12`
2. `g = 19.8 #type is inferred`
3. `a,b = struct(int,int){1, 100}`
4. `a,_ = point`, `a,_ = single_element_struct`
5. `process("A", age:21)`

## Binding name resolution

To resolve a binding name, first bindings in current function will be searched. If not found, search will continue to parent functions, then module-level. At any scope, if there are multiple candidates (with same name) there will be a compiler error.

