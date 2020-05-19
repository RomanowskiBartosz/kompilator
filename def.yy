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
#include <fstream>


#define INFILE_ERROR 1
#define OUTLIFE_ERROR 2
extern "C" int yylex();
extern "C" int yyerror(const char *msg,...);
extern FILE *yyin;
extern FILE *yyout;
using namespace std;

int elseFlag;
kompilator k;
%}
%union
{char *text;
int ival;
float fval;
};
%token PRZYPISZ
%token PRINT READ INT FLOAT
%token IF ELSE WHILE
%token <text> ID
%token <ival> LC
%token <fval> LR
%token <text> COND
%token <text> STRING
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
                                       if(1== k.insertSymbol($2,symbolElement,"0"))
					{
					yyerror("trying to declare an existing variable");
					}
                                       if(-1== k.genCode('=',"sw"))
					{
						yyerror("trying to assign float to an int");
					}
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
					if(-1==k.genCode('=',"sw"))
					{
					yyerror("trying to save float to int");
					}
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
	|IFExpr				{if(elseFlag==0)
                                        {
                                        k.genElse();
                                        }
                                        elseFlag=0;
					}
	|IFELSEexpr			{;}
	|WHILEexpr			{;}
	|PRINTexpr			{;}
	|READexpr			{;}
        ;
READexpr :READ'('ID')'			{k.read($3);}
PRINTexpr :PRINT'('ID')'		{k.printID($3);}
	  |PRINT'('STRING')'		{k.printString($3);}
	;
IFELSEexpr : IFExpr ELSEexpr		{;}
	 ;
ELSEexpr:ELSE blok			{elseFlag=1;k.genElse();}
IFExpr	: ifBegin  blok			{cout<<"endofIF"<<endl;k.genIfLabel();}
   	;
ifBegin : IF '('wyr COND wyr')' 		{k.jumpStatment($4);}
	;	
WHILEexpr : whileBegin blok		{k.genWhileLabel();}
	  ;
whileBegin : WHILE '('wyr COND wyr')'	{k.whileJump($4);}
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
                                type *ID=new idType(1);
                                element e(*ID,$1);
                                k.arguments.push(e);
                                }


        |LC                     {
                                type *INT=new intType(1);
                                element e(*INT,to_string($1));
                                k.arguments.push(e);
                                }
        |'(' wyr ')'            {printf(" ");}
	|LR			{k.makeFloat($1);}
	|ID dimDecl		{type *array=new intArrayType(1);
				element e(*array,$1);
				k.arguments.push(e);
				}
        ;
%%

int main(int argc,char *argv[])
{
elseFlag=0;
if(argc>1)
{
//otwieranie plikow yyout, yyin
yyin = fopen(argv[1], "r");
if(argc>2)
yyout=fopen(argv[2],"w");
}

else
{
// pliki juz sa otwarte
}

yyparse();
cout<<endl;
fprintf(yyout, ".data\n");
for(auto symbol : k.symbolTable)
{	
	string symbolStr=symbol.first+": ";	
	fprintf(yyout,symbolStr.c_str());
        if(symbol.second->elementType.type =="intType")
        {
	string text=" .word "+string(symbol.second->value)+'\n';
	fprintf(yyout,text.c_str());
        }else
        {
        if(symbol.second->elementType.type=="arrayInt")
        {
	 string text=" .space "+to_string(symbol.second->elementType.size*4)+'\n';
	 fprintf(yyout,text.c_str());
        }
	else
        {
	if(symbol.second->elementType.type=="floatType")
	{
	string text=" .float "+string(symbol.second->value)+'\n';
	 fprintf(yyout,text.c_str());
	}
	else
	if(symbol.second->elementType.type=="stringType")
        {
	string text=" .asciiz "+string(symbol.second->value);
	 fprintf(yyout,text.c_str());
        }
	else
        cout<<"other type"<<endl;
        }
        }
	
}
string code=".text\n";
fprintf(yyout,code.c_str());
for(string line :k.code)
{
string formated=line+'\n';
 fprintf(yyout,formated.c_str());
}
//cout<<"Threes.txt:\n";
//cout << k.threesStream.str();



return 0;
}

