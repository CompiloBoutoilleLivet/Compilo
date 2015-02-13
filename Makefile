
LEX = lex
YACC = yacc
CC = gcc

all: lex.yy.c
	mkdir -p bin
	$(CC) -o bin/compilo lex.yy.c -lfl

lex.yy.c:
	$(LEX) source.lex

clean:
	rm -rf lex.yy.c
	rm -rf bin/*
