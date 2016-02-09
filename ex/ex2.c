//** EXIT CODE = 10 (exit code)
package ex2 {
    int main() {
        int x = 12;
        string s = "Hello world!";
        string t = s;
        t = t + "A";
        return x;
    }
}

//expected output
ENTR .ex2.main
PROC .ex2.main
SALC 4, %0          //allocate 4 bytes from stack and let %0 point to that memory
STON 4, %0, 12      //store 4 byte integer `12` into %0
SALC 13, %1
STRX %1, "Hello world!"  //store immediate string
SALC 13, %2
COPY 13, %2, %1  //duplicate string
SALC 14, %3         //allocate a new string
COPY 13, %3, %2
STRA %3, "A"


RETN 4, %0
