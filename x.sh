#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>> Building...";
make > /dev/null

echo ">>>>>>>>>>>>>>>>>>>>>>> Input file:";
cat ./examples/ex$1.c

echo ">>>>>>>>>>>>>>>>>>>>>>> Output:";
./out/newlang.out ./examples/ex$1.c


