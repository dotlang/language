//** EXIT CODE = 10 (exit code)
package ex2 
{
    int main() 
    {
        int x = 12;
        return x;
    }
}

//expected opcodes for this file
ENTR .ex2.main
PROC .ex2.main
DEFN INT4, %0
LOAD %0, 12
RETN %0
