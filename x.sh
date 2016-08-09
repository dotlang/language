#!/bin/sh

cd "$(dirname "$0")"

echo "**************************** Building...";
echo

make clean > /dev/null
make > /dev/null

echo
echo "**************************** Input file:";
echo

cat -n ./tests/ex$1.c

echo
echo "**************************** Output:";
echo

./out/electron ./tests/ex$1.c
actual=$?
expected=$(head -n 1 tests/ex$1.c | cut -c5-)

echo
echo "**************************** Result:";
echo
echo
if [ "$actual" = "$expected" ]; then echo "SUCCESS!"; else echo "FAIL! Got $actual but $expected was expected."; fi
