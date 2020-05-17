%{;
#include <string>
#include <stdio.h>
#include <iostream>
#include <stack>
#include <vector>
#include <map>
#include <sstream>
#include <algorithm>
#include "types.h"
#include "kompilator.h"

#define INFILE_ERROR 1
#define OUTLIFE_ERROR 2
extern "C" int yylex();
extern "C" int yyerror(const char *msg,...);
using namespace std;


kompilator k;
%}
%union
{char *text;
int ival;
float fval;
};

%token LT GT CSTART CEND PRZYPISZ
%token LEQ GEQ EQ
%token FOR INT FLOAT
%token IF
%token <text> ID
%token <ival> LC
%token <fval> LR
%token <text> COND
%%
blok : linia                    {;}
     | blok linia               {;}
     ;

linia : wyrprz ';'              {printf(" ;\n ");}
      ;

wyrprz : INT ID PRZYPISZ wyr            {printf("%s =",$2);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$2);
                                        k.arguments.push(*e);
					type *INT=new intType(1);
					element *symbolElement=new element(*INT,$2);
                                        k.insertSymbol($2,symbolElement,"0");
                                        k.genCode('=',"sw");
                                        }

	|FLOAT ID PRZYPISZ wyr  	{
					printf("%s =",$2);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$2);
                                        k.arguments.push(*e);
                                        type *FLOAT=new floatType(1);
                                        element *symbolElement=new element(*FLOAT,$2);
                                       if(1== k.insertSymbol($2,symbolElement,"0"))
						{yyerror("trying to declare an existing variable\n");
						}
                                        k.genCode('=',"sw");

					}
	|ID PRZYPISZ wyr		{
					printf("%s =",$1);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$1);
                                       	k.arguments.push(*e);
                                        type *INT=new intType(1);
                                        element *symbolElement=new element(*INT,$1);
                                      	 if(0 ==k.insertSymbol($1,symbolElement,"0"))
					{	
						yyerror("this variable has not been declared\n");
					}else
					{
					k.genCode('=',"sw");
					k.arguments.push(*e);
					}

                                        
					}
	
						
        |ID dimDecl PRZYPISZ wyr       {type *ID=new idType(4);
                   	                 element e(*ID,$1);
                                        k.arguments.push(e);
                                        k.genCode('a',"sw");
					k.sizesTemp.clear();
                                        }
        |INT ID dimDecl                 {type *INT=new intArrayType(1);
                                        element *e=new element(*INT,$2);
                                        k.insertArray($2,e);
					k.sizesTemp.clear();
					}
	|IFExpr				{;}
        ;
	;
IFExpr	: ifBegin  blok			{cout<<"end of if"<<endl;k.genIfLabel();}
   	;
ifBegin : IF '('wyr COND wyr')' 		{k.jumpStatment($4);}
	;	
dimDecl : '[' sizeConst ']'             {;}
        ;

sizeConst: sizeConst ',' sizeValue      {;}
         | sizeValue                    {;}
         ;

sizeValue: LC 	{	
	 	type *index=new arrayIndexType(1);
	 	element *e=new element(*index,to_string($1));
	 	k.sizesTemp.push_back(e);}
	 |ID	{
		type *INT=new intType(1);
		element *e=new element(*INT,$1);
		k.sizesTemp.push_back(e);
		}
         ;

wyr

        :wyr '+' part           {printf(" + " );k.genCode('+',"add");}
        |wyr '-' part           {printf(" - ");k.genCode('-',"sub");}
        |part                   {printf(" ");}
        ;

part
        :part '*' czynnik       {printf(" * ");k.genCode('*',"mul");}
        |part '/' czynnik       {printf(" / ");k.genCode('/',"div");}
        |czynnik                {printf(" ");}
        ;

czynnik
        :ID                     {
                                printf(" %s zmienna ",$1);
                                type *ID=new idType(1);
                                element e(*ID,$1);
                                k.arguments.push(e);
                                }


        |LC                     {
                                printf( " %d ",$1);
                                //cout<<"string value of LC"<<to_string($1)<<endl;
                                type *INT=new intType(1);
                                element e(*INT,to_string($1));
                                k.arguments.push(e);
                                }
        |'(' wyr ')'            {printf(" ");}
	|LR			{k.makeFloat($1);}
        ;
%%

int main(int argc,char *argv[])
{

if(argc>1)
{
//otwieranie plikow yyout, yyin
}
else
{
// pliki juz sa otwarte
}

yyparse();
cout<<endl;

cout<< ".data\n"<<endl;
for(auto symbol : k.symbolTable)
{
        cout<< symbol.first<<": ";
        if(symbol.second->elementType.type =="intType")
        {
        cout << " .word "<<symbol.second->value<<endl;
        }else
        {
        if(symbol.second->elementType.type=="arrayInt")
        {
        cout << " .space " <<(symbol.second->elementType.size*4)<<endl;
        }
	else
        {
	if(symbol.second->elementType.type=="floatType")
	{
	cout<<" .float "<<symbol.second->value<<endl;
	}
	else
        cout<<"other type"<<endl;
        }
        }
}
cout << ".text\n"<<endl;
for(string line :k.code)
{
cout << line<<endl;
}
cout<<"Threes.txt:\n";
cout << k.threesStream.str();



return 0;
}

