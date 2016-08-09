#!/bin/bash
cd "$(dirname "$0")"

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

