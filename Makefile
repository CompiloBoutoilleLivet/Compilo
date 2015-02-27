
LEX = lex
YACC = yacc
YACCFLAGS = -d --debug
CC = gcc
CFLAGS = 
LDFLAGS = -lfl -ly

SRC = $(wildcard *.c) y.tab.c lex.yy.c
OBJ = $(SRC:.c=.o)
AOUT = bin/compilo

all: $(OBJ)
	mkdir -p bin
	$(CC) -o $(AOUT) $^ $(LDFLAGS)

lex.yy.c: source.lex y.tab.h
	$(LEX) source.lex

y.tab.c: source.yacc
	$(YACC) $(YACCFLAGS) source.yacc

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf lex.yy.c
	rm -rf y.tab.*
	rm -rf $(OBJ)
	rm -rf bin/*
