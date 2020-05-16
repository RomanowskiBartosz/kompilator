#include "kompilator.h"
#include <string>
#include <stdio.h>
#include <iostream>
#include <stack>
#include <vector>
#include <map>
#include <sstream>
#include <algorithm>
#include "types.h"

using namespace std;
kompilator::kompilator()
{
vector<string> code;
vector<element*> sizesTemp;
vector<int> valuesTemp;
stringstream threesStream;
floatCounter=0;
}


int kompilator::insertSymbol(string name,element *ele,string value)
{
if(symbolTable.find(name)==symbolTable.end())
        {	
		
                symbolTable[name]=ele;
		symbolTable[name]->value=value;
return 0;
        }
return 1;
}
void kompilator::insertArray(string s,element *e)
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
};

void kompilator::makeFloat(float value)
{
string name="tmpFloat" + to_string(floatCounter);
type *FLOAT=new floatType(1);
element *e=new element(*FLOAT,name);
arguments.push(*e);
insertSymbol(name,e,to_string(value));
floatCounter++;
}

string kompilator::loadLine(element e,int regno)
{
stringstream s;
s<< "l";
string regName="$t";
string valueName=e.value;
if(e.elementType.type=="idType")
{	
	e=*symbolTable[e.value];
	cout<<"e is ID"<<endl;
	cout<<"e type now is "<<e.elementType.type;
	if(e.elementType.type=="intType")
        {
        s<< "w ";
        }
	else
	{
	s<<".s ";
	regName="$f";
	}
}else
{
if(e.elementType.type=="intType")
{
	s<<"i ";
}

if(e.elementType.type=="floatType")
{
        s<<".s ";
        regName="$f";
}
}
s<<regName<<regno<<", "<<valueName;
return s.str();
};


string kompilator::convertTypes(int regno,element e1,element e2)
{	string e1Name="";
	string e2Name="";
	if(e1.elementType.type=="idType")
	{
		e1Name=e1.value;
		e1=*symbolTable[e1Name];
	}
	if(e2.elementType.type=="idType")
        {
                e2Name=e2.value;
                e2=*symbolTable[e2Name];
        }
	
	if(!(e1.elementType.type=="floatType"&&e2.elementType.type=="intType"))
	{
		return "";
	}
	stringstream s;
	s<< "mtc1 $t"<<regno<<", "<<"$f"<<regno<<"\n";
	s<<"cvt.s.w $f"<<regno<<", "<<"$f"<<regno;
	return s.str();

}
void kompilator::genCode(char op,string mnemoOp)
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
insertSymbol(e2.value,s,"0");
string line1=loadLine(e1,0);
cout<<"czy to ta linia?   "<<line1<<endl;
cout<<"typ elementu"<<s->elementType.type<<endl;

string line4= "sw $t0 , " +e2.value;
code.push_back(line1);
code.push_back(line4);
threesStream<<e2.value <<op <<e1.value << endl;
}
else
if(op=='a')
{

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
string line1=loadLine(e1,0);
string line2="sw $t0, ($t4)";
code.push_back(line1);
code.push_back(line2);
}
else
{
stringstream s;
s<< e1.value << op << e2.value << endl;
threesStream <<s.str();
//
type *t=new intType(1);
element *result=new element(*t,temp);
arguments.push(*result);
insertSymbol(temp,result,"0");
//
type *finalType=new intType(1);
if(e1.elementType.type=="floatType"||e2.elementType.type=="floatType")
{
	finalType=new floatType(1);
}
string line0='#'+s.str();
string line1=loadLine(e1,0);
// konwersjs typow
string line2=loadLine(e2,1);
//konwersja typow
string line3= mnemoOp +"$t0,$t0,$t1";
string line4 = "sw $t0," +temp;
code.push_back(line0);
code.push_back(line1);
code.push_back(convertTypes(0,e1,e2));
code.push_back(line2);
code.push_back(convertTypes(1,e2,e1));
code.push_back(line3);
code.push_back(line4);

element *e=new element(*finalType,temp);
insertSymbol(temp,e,"0");
type *argType=new idType(1);
element *arg=new element(*argType,temp);
arguments.push(*arg);
}
counter++;

};



