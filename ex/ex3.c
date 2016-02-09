//** EXIT CODE = 22
package ex3 {
    int main() {
        int x = 12;
        int y = 10;

        return x+y;
        //return x-y;
        //return x + ( 3* y);
        //return 10 / (x+y);
    }
}

//opcodes:
ENTR .ex3.main
PROC .ex3.main
SALC 4, %0
STON 4, %0, 12
SALC 4, %1
STON 4, %2, 10
SALC 4, %2
ADDN 4, %2, %0, %1
RETN 4, %2
