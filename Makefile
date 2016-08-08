.DEFAULT_GOAL := electron

clean:
	@rm -f out/electron
	@rm -f tmp/*
	@mkdir out
	@mkdir tmp

init:
	@cd src && cp *.c ../tmp
	@cd src && cp *.h ../tmp


parser.tab.c parser.tab.h: grammar/parser.y
	@cd tmp && bison -d ../grammar/parser.y

lex.yy.c: grammar/lexer.l parser.tab.h
	@cd tmp && flex ../grammar/lexer.l

SRC=$(wildcard tmp/*.c)

electron: lex.yy.c init
	gcc $(SRC) libjit/lib/libjit.a -lpthread -lm -ldl -I libjit/include  -std=gnu99 -o ./out/electron
