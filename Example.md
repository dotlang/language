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
    
    if ( error != null ) return -1;
    
    switch ( t2.getData() )
    {
        1: return 0;
        2,3: return 9;
        default: z++;
    }
    
    int[string] h = { 'A':1, 'B':2 };
    int g = h['A'];
    
    int[,] matrix = int[2,2] {{1, 2}, {3, 4}};
    int t = matrix[0,0];
    
    uint64 bigData = (uint64)t;
    
    for(string s, int k: h)
    {
        t += k;
    }
    
    int g = iif (z>0, 1, 2);
    assert g != 0;
    assert g != 1 : 'error in value of g';  //set error and return
    assert 
    
    
    return 0;
}



```
