.DEFAULT_GOAL := newlang

clean:
	rm out/newlang.out
	rm autogen/parser.tab.h
	rm autogen/parser.tab.c
	rm autogen/lex.yy.c

parser.tab.c parser.tab.h: parser.y
	cd autogen && bison -d ../parser.y

lex.yy.c: lexer.l parser.tab.h
	cd autogen && flex ../lexer.l

newlang: lex.yy.c parser.tab.c parser.tab.h
	gcc src/hash.c autogen/parser.tab.c autogen/lex.yy.c -o ./out/newlang.out
