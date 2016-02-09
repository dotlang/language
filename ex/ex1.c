//** EXIT CODE = 10 (exit code)
//ignore comments
//plan: scan the file using flex and bison
//  input: this file
//  output: a binary file containing required opcodes
//write another application in C, called `runner`:
//  input: binary output of the previous step
//  output: execution
package ex1 { 
    int main() {
        return 10;
    }
}
//here is the formay way to define what we expect so future tests can be automated
//** EXIT CODE = 10 (exit code)
//** OUTPUT ~ (standard output must contain this string), we can have multiple of this
//** OUTPUT = (standard output must be this)

//expected output opcodes:
//first opcode is ENTR
ENTR .ex1.main //define starting point of this bytecode file, if doen't exist, its not executable
PROC .ex1.main  //define .ex1.main method and its output type
RETN 4, 10  //return 4 byte number integer, value is 10

