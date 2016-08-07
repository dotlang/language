#!/bin/sh

echo ">>>>>>>>>>>>>>>>>>>>>>> Building...";
make clean > /dev/null
make > /dev/null

echo ">>>>>>>>>>>>>>>>>>>>>>> Input file:";
cat -n ./tests/ex$1.c

echo ">>>>>>>>>>>>>>>>>>>>>>> Output:";
./out/electron ./tests/ex$1.c
actual=$?
expected=$(head -n 1 tests/ex$1.c | cut -c5-)

echo
echo
if [ "$actual" = "$expected" ]; then echo "SUCCESS!"; else echo "FAIL! Got $actual but $expected was expected."; fi
