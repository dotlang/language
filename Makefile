.DEFAULT_GOAL := electron

clean:
	rm out/newlang.out
	rm tmp/parser.tab.h
	rm tmp/parser.tab.c
	rm tmp/lex.yy.c

parser.tab.c parser.tab.h: parser.y
	cd tmp && bison -d ../grammar/parser.y

lex.yy.c: lexer.l parser.tab.h
	cd tmp && flex ../grammar/lexer.l

electron: lex.yy.c parser.tab.c parser.tab.h
	gcc src/hash.c tmp/parser.tab.c autogen/lex.yy.c -o ./out/newlang.out
