%{
#include <string>
#include <stdio.h>
#include <iostream>
#include <stack>
#include <vector>
#include <map>
#include <sstream>
#include <algorithm>

#define INFILE_ERROR 1
#define OUTLIFE_ERROR 2
extern "C" int yylex();
extern "C" int yyerror(const char *msg,...);
using namespace std;

class type
{
public:
string type;
int size;
vector<int> sizes;
vector<int> dims;
};
class arrayIndexType:public type
{
public:
      arrayIndexType(int size)
	{
	type="indexType";
	this->size=size;
	}
};
class floatType :public type
{
public:
      floatType(int size)
	{
	type="floatType";
	this->size=size;
	}
};
class intType:public type
{
public:
intType(int size)
{
type="intType";
this->size=size;
}
};
class idType:public type
{
public:
idType(int size)
{
type="ID";
this->size=size;
}
};

class intArrayType:public type
{
public:
intArrayType(int size)
{
type="arrayInt";
this->size=size;
}
};

class element
{
        public:
        string value;
        type elementType;
        element(type t,string value)
        {
        elementType=t;
        this->value=value;
        }
};
stack <element> arguments;
map<string,element*> symbolTable;
string loadLine(string,int);
void addOp(char);
void genCode(char,string);
vector<string> code;
vector<element*> sizesTemp;
vector<int> valuesTemp;
stringstream threesStream;


int insertSymbol(string,element*);
void insertArray(string,element*);
%}

%union
{char *text;
int ival;
};
%token LT GT CSTART CEND PRZYPISZ
%token LEQ GEQ EQ
%token FOR INT FLOAT
%token <text> ID
%token <ival> LC
%token <ival> LR

%%
blok : linia                    {;}
     | blok linia               {;}
     ;

linia : wyrprz                  {;}
      ;
linia : wyrprz ';'              {printf(" ;\n ");}
      ;

wyrprz : INT ID PRZYPISZ wyr            {printf("%s =",$2);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$2);
                                        arguments.push(*e);
					type *INT=new intType(1);
					element *symbolElement=new element(*INT,$2);
                                        insertSymbol($2,symbolElement);
                                        genCode('=',"sw");
                                        }

	|FLOAT ID PRZYPISZ wyr  	{
					printf("%s =",$2);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$2);
                                        arguments.push(*e);
                                        type *FLOAT=new floatType(1);
                                        element *symbolElement=new element(*FLOAT,$2);
                                       if(1== insertSymbol($2,symbolElement))
						{yyerror("trying to declare an existing variable\n");
						}
                                        genCode('=',"sw");

					}
	|ID PRZYPISZ wyr		{
					printf("%s =",$1);
                                        type *ID=new idType(1);
                                        element *e=new element(*ID,$1);
                                        arguments.push(*e);
                                        type *INT=new intType(1);
                                        element *symbolElement=new element(*INT,$1);
                                      	 if(0 ==insertSymbol($1,symbolElement))
					{	
						yyerror("this variable has not been declared\n");
					}else
					{
					genCode('=',"sw");
					arguments.push(*e);
					}

                                        
					}
	;
						
        |ID dimDecl PRZYPISZ wyr       {type *ID=new idType(4);
                   	                 element e(*ID,$1);
                                        arguments.push(e);
                                        genCode('a',"sw");
					sizesTemp.clear();
                                        }
        |INT ID dimDecl                 {type *INT=new intArrayType(1);
                                        element *e=new element(*INT,$2);
                                        insertArray($2,e);
					sizesTemp.clear();
					}
        ;

dimDecl : '[' sizeConst ']'             {;}
        ;

sizeConst: sizeConst ',' sizeValue      {;}
         | sizeValue                    {;}
         ;

sizeValue: LC 	{	
	 	type *index=new arrayIndexType(1);
	 	element *e=new element(*index,to_string($1));
	 	sizesTemp.push_back(e);}
	 |ID	{
		type *INT=new intType(1);
		element *e=new element(*INT,$1);
		sizesTemp.push_back(e);
		}
         ;

wyr

        :wyr '+' part           {printf(" + " );genCode('+',"add ");}
        |wyr '-' part           {printf(" - ");genCode('-',"sub ");}
        |part                   {printf(" ");}
        ;

part
        :part '*' czynnik       {printf(" * ");genCode('*',"mul ");}
        |part '/' czynnik       {printf(" / ");genCode('/',"div ");}
        |czynnik                {printf(" ");}
        ;

czynnik
        :ID                     {
                                printf(" %s zmienna ",$1);
                                type *ID=new idType(1);
                                element e(*ID,$1);
                                arguments.push(e);
                                }


        |LC                     {
                                printf( " %d ",$1);
                                cout<<"string value of LC"<<to_string($1)<<endl;
                                type *INT=new intType(16);
                                element e(*INT,to_string($1));
                                arguments.push(e);
                                }
        |'(' wyr ')'            {printf(" ");}
        ;
%%
int insertSymbol(string name,element *ele)
{
if(symbolTable.find(name)==symbolTable.end())
        {
                symbolTable[name]=ele;
return 0;
        }
return 1;
}

void insertArray(string s,element *e)
{
        if(symbolTable.find(s) == symbolTable.end())
        {
                int sizeAll=1;
        for(auto size : sizesTemp)
        {
                sizeAll*=stoi(size->value);
                e->elementType.sizes.push_back(stoi(size->value));
        }
        reverse(sizesTemp.begin(),sizesTemp.end());
        int dimSize=1;
        for(auto size : sizesTemp)
        {
                e->elementType.dims.push_back(dimSize);
                dimSize*=stoi(size->value);
        }
        e->elementType.size=sizeAll;
        symbolTable[s]=e;
        }

}
string loadLine(string op,int regno)
{
stringstream s;
s<< "l";
if(isdigit(op[0]))
        {
        s<< "i ";
        }
else
        {
        s<<"w ";
        }
// ADD REGNO TO IT ALL
s<<"$t"<<regno<<", "<<op;
return s.str();
}


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

cout<< "symbols\n"<<endl;
for(auto symbol : symbolTable)
{
        cout<< symbol.first<<": ";
        if(symbol.second->elementType.type =="intType")
        {
        cout << " .word 0"<<endl;
        }else
        {
        if(symbol.second->elementType.type=="arrayInt")
        {
        cout << " .space " <<(symbol.second->elementType.size*4)<<endl;
        }else
        {
        cout<<"other type"<<endl;
        }
        }
}
cout << "CODE\n"<<endl;
for(string line :code)
{
cout << line<<endl;
}
cout<<"Threes.txt:\n";
cout << threesStream.str();



return 0;
}


void genCode(char op,string mnemoOp)
{
element e2=arguments.top();
arguments.pop();
element e1=arguments.top();
arguments.pop();
string temp="result";
static int counter=1;
temp+=to_string(counter);
threesStream<<temp<<" <= ";
if(op == '=')
{
//tu bedzie werdydikacja zgodnosci jak ja napiszesz idioto
element *s =new element(e2.elementType,e2.value);

insertSymbol(e2.value,s);
string line1=loadLine(e1.value,0);
string line4= "sw $t0 , " +e2.value;
code.push_back(line1);
code.push_back(line4);
threesStream<<e2.value <<op <<e1.value << endl;
}
else
if(op=='a')
{
//element e3=arguments.top();
//arguments.pop();

stringstream arrayValue;
arrayValue<<"la $t4 ,"<<e2.value<<endl;
element *my=symbolTable[e2.value];
for(int i=0;i<sizesTemp.size();i++)
{
	if(sizesTemp[i]->elementType.type=="indexType")
	{
	arrayValue<<"li $t6 ,"<<sizesTemp[i]->value <<endl;		
	}
	else
	{
	if(sizesTemp[i]->elementType.type=="intType")
	{arrayValue<<"lw $t6,"<<sizesTemp[i]->value<<endl;
	}
}
	arrayValue<<"li $t7,"<<my->elementType.dims[i]<<endl<<"mul $t6,$t6,$t7"<<endl<<"mul $t6,$t6,4"<<endl<<"add $t4,$t4,$t6"<<endl;
}
code.push_back(arrayValue.str());
string line1=loadLine(e1.value,0);
string line2="sw $t0, ($t4)";
code.push_back(line1);
code.push_back(line2);
}
else
{
//matma na incie
stringstream s;
s<< e1.value << op << e2.value << endl;
threesStream <<s.str();

type *t=new intType(1);
element *result=new element(*t,temp);
arguments.push(*result);
insertSymbol(temp,result);

string line0='#'+s.str();
string line1=loadLine(e1.value,0);
string line2=loadLine(e2.value,1);
string line3= mnemoOp +"$t0,$t0,$t1";
string line4 = "sw $t0," +temp;
code.push_back(line0);
code.push_back(line1);
code.push_back(line2);
code.push_back(line3);
code.push_back(line4);
}
type *ID=new idType(16);

element e(*ID,temp);
//arguments.push(e);
counter++;

};





