#!/bin/bash

if [ -z "$1" ]; then
    echo "Usage: x.sh cn | xn | n"
    echo "    Where n is a test number"
    echo "    cn will show the test file"
    echo "    xn will run all tests up to n"
    exit
fi

cd "$(dirname "$0")"

if [[ ${1:0:1} = c* ]]; then
    target=${1:1}
    cat tests/ex$target.c
    echo
    exit
fi

make clean > /dev/null
make > /dev/null

if [[ ${1:0:1} = x* ]]; then
    target=${1:1}
    for i in `seq 1 $target`;
    do
        ./out/electron ./tests/ex$i.c &> /dev/null
        actual=$?
        expected=$(head -n 1 tests/ex$i.c | cut -c5-)
        echo -n "$i >> ";
        if [ "$actual" = "$expected" ]; then echo "SUCCESS!"; else echo "FAIL! Got $actual but $expected was expected."; fi
    done
    echo
    exit
fi

echo "**************************** Building...";
echo

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

