.DEFAULT_GOAL := electron

clean:
	@rm -f out/electron
	@rm -f tmp/*
	@mkdir -p out
	@mkdir -p tmp 

init:
	@cd src && cp *.c ../tmp
	@cd src && cp *.h ../tmp


parser.tab.c parser.tab.h: grammar/parser.y
	@cd tmp && bison -d ../grammar/parser.y

lex.yy.c: grammar/lexer.l parser.tab.h
	@cd tmp && flex ../grammar/lexer.l

SRC=$(wildcard tmp/*.c)

GCC_OPT_STATIC_ALL = -static
GCC_OPT_DEBUG = -v -da -Q -g -O0
GCC_OPT_OPTIMIZE = -O3
GCC_OPT_STD = -Wall -lpthread -lm -ldl -std=c11 #-std=gnu99

GCC_OPT = $(GCC_OPT_STD)

electron: lex.yy.c init
	gcc $(SRC) libjit/lib/libjit.a $(GCC_OPT) -I libjit/include -o ./out/electron
