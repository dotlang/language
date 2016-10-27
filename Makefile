.DEFAULT_GOAL := electron

clean:
	@rm -f out/electron
	@mkdir -p out

SRC=$(wildcard src/*.c)

GCC_OPT_STATIC_ALL = -static
GCC_OPT_DEBUG = -v -da -Q -g -O0
GCC_OPT_OPTIMIZE = -O3
GCC_OPT_STD = -Wno-unused-function -Wall -lpthread -lm -ldl -std=gnu99

GCC_OPT = $(GCC_OPT_STD)

electron:
	gcc $(SRC) $(GCC_OPT) -I include -o ./out/electron
