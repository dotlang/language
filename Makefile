.DEFAULT_GOAL := electron

clean:
	@rm -f out/electron
	@rm -f tmp/*

init:
	@cd src && cp *.c ../tmp
	@cd src && cp *.h ../tmp


parser.tab.c parser.tab.h: grammar/parser.y
	@cd tmp && bison -d ../grammar/parser.y

lex.yy.c: grammar/lexer.l parser.tab.h
	@cd tmp && flex ../grammar/lexer.l

SRC=$(wildcard tmp/*.c)

electron: lex.yy.c init
	gcc $(SRC) -o ./out/electron
