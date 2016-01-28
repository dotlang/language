echo ">>>>>>>>>>>>>>>>>>>>>>>BUILD>>>>";
make
echo ">>>>>>>>>>>>>>>>>>>>>>>INPUT>>>>";
cat ./examples/ex$1.c
echo ">>>>>>>>>>>>>>>>>>>>>>>OUTPUT>>>>";
./out/newlang.out ./examples/ex$1.c


