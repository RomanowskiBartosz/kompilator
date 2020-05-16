CC=gcc
LEX=flex
BIS=bison
CPP=g++
LD=g++

all: leks

leks: def.tab.o lex.yy.o types.o kompilator.o
	$(CPP) -g lex.yy.o def.tab.o types.o kompilator.o -o leks -ll

lex.yy.o:       lex.yy.c
	$(CC) -c lex.yy.c

lex.yy.c: tokeny.l
	$(LEX) tokeny.l

def.tab.o: def.tab.cc types.h types.cpp 
	$(CPP) -std=c++11 -c def.tab.cc types.h types.cpp
kompilator.o: kompilator.h kompilator.cpp
	$(CPP) -std=c++11 -c kompilator.h kompilator.cpp
def.tab.cc: def.yy
	$(BIS) -d def.yy

clean:
	rm *.o leks def.tab.cc  lex.yy.c
