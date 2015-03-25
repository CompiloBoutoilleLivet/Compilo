
LEX = lex
LEXFLAGS = --header-file=lex.yy.h
YACC = yacc
YACCFLAGS = -d --debug --verbose
CC = gcc
CFLAGS = -Wall
LDFLAGS = -lfl -ly

SRC = lex.yy.c y.tab.c $(wildcard *.c) $(wildcard instructionmanager/*.c)
OBJ = $(SRC:.c=.o)
AOUT = bin/compilo

all: $(OBJ)
	$(CC) -o $(AOUT) $^ $(LDFLAGS)

lex.yy.c: source.lex y.tab.c
	$(LEX) $(LEXFLAGS) source.lex

y.tab.c: source.yacc
	$(YACC) $(YACCFLAGS) source.yacc

%.o: %.c
	$(CC) $(CFLAGS) -o $@ -c $<

clean:
	rm -rf lex.yy.*
	rm -rf y.tab.*
	rm -rf $(OBJ)
	rm -rf bin/*
