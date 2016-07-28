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
//> EXIT_CODE 22

//opcodes:
ENTR .ex3.main
PROC .ex3.main
DEFN INT4, %0
LOAD %0, 12
DEFN INT4, %1
LOAD %1, 10
DEFN INT4, %3
ADD
SALC 4, %0
STON 4, %0, 12
SALC 4, %1
STON 4, %2, 10
SALC 4, %2
ADDN 4, %2, %0, %1
RETN 4, %2
