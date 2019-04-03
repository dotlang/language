Perfection is finally attained not when there is no longer anything to add, but when there is no longer anything to take away. (Antoine de Saint-Exupéry, translated by Lewis Galantière.)

dotLang is a general-purpose programming language which is built upon a small set of rules and minimum number of exceptions and a consistent set of specifications.

# Why dotLang?

Because it is:

1. **Simple**: There are a few key concepts and features that you need to learn. With a very smooth learning curve, you will not need to keep in mind an endless array of exceptions and criteria.
2. **Powerful**: The fact that dotLang is simple, combined with orthogonality of the tools that the language gives you, makes it an immersely powerful tool. You can mix and match different concepts easily and all the way, compiler is with you to do as much as possible.
3. **Fast**: dotLang is a compiled language. Because of its simplicity, compiler is able to quickly compile a large source code set and also by using LLVM, the binary output will have a high performance.

dotLang is very similar to C but with some significant improvements:
1. Module system
2. Generics
3. Full immutability
4. No reference, no pointer, no manual memory management
5. Powerful concurrency model

# Documentation

This is the main document for the language. It is not a formal specification, but explains all the features of the language with examples: [dotLang: Language Manual](manual.md)

# Contribute

Currently, the manual document is being finalised. Please contact me if you are interested in helping either with the documentation or implementation.

# Contact

[GitHub](https://github.com/mahdix)


```java
package org.apache.cassandra.cache;

import java.util.Objects;

import org.apache.cassandra.schema.TableId;
import org.apache.cassandra.schema.TableMetadata;

public abstract class CacheKey implements IMeasurableMemory
{
    public final TableId tableId;
    public final String indexName;

    protected CacheKey(TableId tableId, String indexName)
    {
        this.tableId = tableId;
        this.indexName = indexName;
    }

    public CacheKey(TableMetadata metadata)
    {
        this(metadata.id, metadata.indexName().orElse(null));
    }

    public boolean sameTable(TableMetadata tableMetadata)
    {
        return tableId.equals(tableMetadata.id)
               && Objects.equals(indexName, tableMetadata.indexName().orElse(null));
    }
}
```
```c
#although T type can be at any position in x's original type, but inside hasType T is the first type so a will be corresponding to type T
hasType = fn(x: T|U, T: type, U: type -> bool) {
	a,_ = x
	a!=nothing
}
```
