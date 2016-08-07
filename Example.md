An example source code, shows multiple code files:

```
//Comparer.e - interface
import core.std;
import core.data => data;

struct
{
    ParentIntr;
}

bool doCompare(int x, int y);

===================
//Handler.e - class

struct
{
    int _internal;
    int external;
}

{
    this.external = 19;
}

int _init() return this._internal++;

int test(int arg=9)
{
    Comparer fp = (x, y) -> x+y;
    auto fq = Comparer
    {
        doCompare(int x, int y)
        {
            return x>y;
        }
    };
    
    int z = fp.doCompare(1, 9);
    defer fp = null;
    
    MyClass t = MyClass {};
    MyClass t2 = MyClass {x:1, y:9};
    
    if ( Error.isSet() ) return -1;
    
    switch ( t2.getData() )
    {
        1: return 0;
        2,3: return 9;
        *: z++;
    }
    
    int g = iif (z>0, 1, 2);
    assert g != 0;
    
    return 0;
}



```
