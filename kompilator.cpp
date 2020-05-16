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

}


int kompilator::insertSymbol(string name,element *ele)
{
if(symbolTable.find(name)==symbolTable.end())
        {
                symbolTable[name]=ele;
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
string kompilator::loadLine(string op,int regno)
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
};

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



