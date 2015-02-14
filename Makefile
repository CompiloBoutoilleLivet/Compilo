
LEX = lex
YACC = yacc
YACCFLAGS = -d --debug
CC = gcc
CFLAGS = -lfl -ly

all: y.tab.c lex.yy.c
	mkdir -p bin
	$(CC) -o bin/compilo y.tab.c lex.yy.c $(CFLAGS)

lex.yy.c: source.lex y.tab.h
	$(LEX) source.lex

y.tab.c: source.yacc
	$(YACC) $(YACCFLAGS) source.yacc

clean:
	rm -rf lex.yy.c
	rm -rf y.tab.*
	rm -rf bin/*
