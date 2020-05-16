CC=gcc
LEX=flex
BIS=bison
CPP=g++
LD=g++

all: leks

leks: def.tab.o lex.yy.o
	$(CPP) -g lex.yy.o def.tab.o -o leks -ll

lex.yy.o:       lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: tokeny.l
	$(LEX) tokeny.l

def.tab.o: def.tab.cc
	$(CPP) -std=c++11 -c def.tab.cc

def.tab.cc: def.yy
	$(BIS) -d def.yy

clean:
	rm *.o leks def.tab.cc  lex.yy.c
