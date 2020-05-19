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
stack<string> ifLabels;
stack<string> whileBegin;
stack<string> elseLabels;
labelCounter=0;
whileCounter=0;
printCounter=0;
}
void kompilator::read(string ID)
{
 element *e=symbolTable[ID];
        if(e->elementType.type=="intType")
        {
        code.push_back("li $v0 , 5");
	code.push_back("syscall");
        code.push_back("sw $v0 , "+ID);
        }
        if(e->elementType.type=="floatType")
        {
        code.push_back("li $v0 , 6");
	code.push_back("syscall");
        code.push_back("s.s $f0 , "+ID);
        
        }

}
void kompilator::printString(string str)
{
type *text=new stringType(1);
element *e=new element(*text,"str"+to_string(printCounter));

insertSymbol(e->value,e,str);

code.push_back("li $v0 , 4");
string line="la $a0 ,str"+to_string(printCounter);
code.push_back(line);
code.push_back("syscall");
printCounter++;
}
void kompilator::printID(string ID)
{
	element *e=symbolTable[ID];
	if(e->elementType.type=="intType")
	{
	code.push_back("li $v0 , 1");
	code.push_back("lw $a0 , "+ID);
	code.push_back("syscall");
	}
	if(e->elementType.type=="floatType")
	{
	code.push_back("li $v0 , 2");
        code.push_back("l.s $f12 , "+ID);
        code.push_back("syscall");
	}
}
void kompilator::genWhileLabel()
{
string label=ifLabels.top();
ifLabels.pop();

string beginLabel=whileBegin.top();
whileBegin.pop();
string line="b "+beginLabel;
code.push_back(line);
code.push_back(label+':');
}
void kompilator::genElse()
{
string	label=elseLabels.top();
elseLabels.pop();
 label=label+':';
code.push_back(label);
}

void kompilator::genIfLabel()
{
string label=ifLabels.top();
ifLabels.pop();

string elseJump=" b "+elseLabels.top();


code.push_back(elseJump);

code.push_back(label+':');
}
void kompilator::whileJump(string cond)
{
string label="WHEND"+to_string(whileCounter);
ifLabels.push(label);
string labelBegin="WHBEG"+to_string(whileCounter);

whileBegin.push(labelBegin);


element e2=arguments.top();
arguments.pop();
element e1=arguments.top();
arguments.pop();

string line1=loadLine(e1,2);
string line2=loadLine(e2,3);
string regno1="$t2";
string regno2="$t3";
string line3=cond+" "+regno1+", "+regno2+", "+label;
code.push_back("WHBEG"+to_string(whileCounter)+':');
code.push_back(line1);
code.push_back(line2);
code.push_back(line3);
whileCounter++;
}
void kompilator::jumpStatment(string cond)
{
labelCounter++;
string label="IFLB"+to_string(labelCounter);
ifLabels.push(label);
string elseLabel="ELEND"+to_string(labelCounter);
elseLabels.push(elseLabel);
element e2=arguments.top();
arguments.pop();
element e1=arguments.top();
arguments.pop();

string line1=loadLine(e1,2);
string line2=loadLine(e2,3);
// zmienic by wczytywalo z dobrych rejestrow
string regno1="$t2";
string regno2="$t3";
string line3=cond+" "+regno1+", "+regno2+", "+label;
code.push_back(line1);
code.push_back(line2);
code.push_back(line3);
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
	if(e.elementType.type=="intType")
        {
        s<< "w ";
        }
	else
	{
	s<<".s ";
	regName="$f";
	}
	 if(e.elementType.type=="arrayInt")
        {
        s<< "w ";
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
if(e.elementType.type=="arrayInt")
{
        s<< "w ";
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
	s<< "mtc1 $t"<<regno<<", "<<"$f"<<regno<<endl;
	s<<"cvt.s.w $f"<<regno<<", "<<"$f"<<regno;
	return s.str();

}

void kompilator::calculateTableAddress(string ele)
{
	stringstream arrayValue;
	arrayValue<<"la $t4 ,"<<ele<<endl;
	element* my=symbolTable[ele];

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
}
int kompilator::genCode(char op,string mnemoOp)
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
cout<<"e2"<<e2.value<<endl;
if(symbolTable[e2.value]->elementType.type=="intType")
{
	if(e1.elementType.type=="idType")
	{
		
	 if(symbolTable[e1.value]->elementType.type=="floatType")
 	  {
              return -1;
       	  }
	}
	 if(e1.elementType.type=="floatType")
        {
		return -1;
        }
}
element *s =new element(e2.elementType,e2.value);
insertSymbol(e2.value,s,"0");
string line1=loadLine(e1,0);
type last=symbolTable[e2.value]->elementType;
	string line4= "sw $t0 , " +e2.value;

if(last.type=="intArrayType")
{
calculateTableAddress(e2.value);
}
if(last.type=="floatType")
{
line4="s.s $f0, "+e2.value;
}	
code.push_back(line1);
code.push_back(line4);
threesStream<<e2.value <<op <<e1.value << endl;
}
else
if(op=='a')
{
	calculateTableAddress(e2.value);
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
type *finalType=new intType(1);

if(e1.elementType.type=="floatType"||e2.elementType.type=="floatType")
{
	finalType=new floatType(1);
}
if(e1.elementType.type=="idType")
{
if(symbolTable[e1.value]->elementType.type=="floatType")
	        finalType=new floatType(1);

}

if(e2.elementType.type=="idType")
{
if(symbolTable[e2.value]->elementType.type=="floatType")
                finalType=new floatType(1);

}

string line0='#'+s.str();
string line1=loadLine(e1,0);
// konwersjs typow
string line2=loadLine(e2,1);
//konwersja typow
string line3= mnemoOp +" $t0,$t0,$t1";
string line4 = "sw $t0," +temp;

if(finalType->type=="floatType")
{
 line3= mnemoOp+".s " +"$f0,$f0,$f1";
 line4 = "s.s $f0," +temp;
}
code.push_back(line0);
code.push_back(line1);
code.push_back(convertTypes(0,e2,e1));
code.push_back(line2);
code.push_back(convertTypes(1,e1,e2));
code.push_back(line3);
code.push_back(line4);

element *e=new element(*finalType,temp);
insertSymbol(temp,e,"0");
type *argType=new idType(1);
element *arg=new element(*argType,temp);
arguments.push(*arg);
}
counter++;
return 0;
};



