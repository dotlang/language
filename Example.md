//Comparer.e
import core.std;
import data := core.data;

struct
{
    exposed parent_interface parent;
    int dataItem;
    const int x;
}

bool doCompare(int x, int y=0);

===================
//Handler.e

struct
{
    int _internal;
    int external;
}

void _()
{
    this.external = 19;
}

int _init() return this._internal++;

int test(int arg=9)
{
    Comparer fp = (x, y) -> x+y;
    bool bb = fp(1, 2); 
    
    auto fq = Comparer
    {
        doCompare(int x, int y)
        {
            return x>y;
        }
    };
    
    int z = fp.doCompare(1, 9);
    defer fp = nil;
    
    MyClass t = MyClass.new();
    MyClass t2 = MyClass.new(x:1, y:9);
    
    if ( error != nil ) return -1;
    
    switch ( t2.getData() )
    {
        1: return 0;
        2,3: return 9;
        : z++;
    }
    
    //type of h is hash<string, int>
    int[string] h = { 'A':1, 'B':2 };
    auto g = h['A'];  //h.get('A')
    
    //type of matrix is Array2 class
    int[,] matrix = int[2,2] {{1, 2}, {3, 4}};
    int t = matrix[0,0];
    
    uint64 bigData = (uint64)t;
    
    for(string s, int k: h)
    {
        t += k;
    }
    
    int g = iif (z>0, 1, 2);
    assert g != 0;
    assert g != 1 : 'error in value of g';  //set error and return, for exit, it can be done via std
    
    return 0;
}



