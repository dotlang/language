.DEFAULT_GOAL := newlang


parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lexer.l parser.tab.h
	flex lexer.l

newlang: lex.yy.c parser.tab.c parser.tab.h
	g++ parser.tab.c lex.yy.c -o newlang
