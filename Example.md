```
//Comparer.e
import core.std;
import core.data => data;

type i32 := uint;
type point := (int x,int y);

int dataItem;
int x := 7;
int y := x;
MyClass mc;
i32 t;

bool doCompare(int x, int y=0);
bool add(int x, int y) = this.mc.method1;
Comparer new() return {};

===================
//Handler.e

Comparer __c := Comparer.new();
int g = 11;

void _()
{
    this.dataItem = 10;
}

int _init() return this._internal++;

int test(int arg)
{
    arg ??= 10;
    Comparer fp = (x, y) -> x+y;
    bool bb = fp(1, 2) > 6; 
    
    auto fq = Comparer
    {
        doCompare(int x, int? y)
        {
            y ??= 6;
            return x>y;
        }
    };
    
    int z := fp.doCompare(1, 9);
    defer fp = nil;
    
    MyClass t = MyClass.new();
    MyClass t2 = MyClass.new(x:1, y:9);
    
    if ( error != nil ) return -1;
    
    switch ( t2.getData() )
    {
        1: return 0;
        2,3: return 9;
        else: z++;
    }
    
    //type of h is hash<string, int>
    int[string] h = { 'A':1, 'B':2 };
    auto g = h['A'];  //h.get('A')
    
    //type of matrix is Array2 class
    int[,] matrix = int[2,2] {{1, 2}, {3, 4}};
    int t = matrix[0,0];
    
    uint64 bigData = @uint64(t);
    
    for(string s, int k: h)
    {
        t += k;
    }
    
    int g = 2+t;
    assert g != 0;
    assert g != 1 : 'error in value of g';  //set error and return, for exit, it can be done via std
    
    return 0;
}

```
