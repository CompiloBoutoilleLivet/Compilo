
LEX = lex
YACC = yacc
CC = gcc

all: y.tab.c lex.yy.c
	mkdir -p bin
	$(CC) -o bin/compilo y.tab.c lex.yy.c -lfl -ly

lex.yy.c: source.lex y.tab.h
	$(LEX) source.lex

y.tab.c: source.yacc
	$(YACC) -d source.yacc


clean:
	rm -rf lex.yy.c
	rm -rf y.tab.*
	rm -rf bin/*
