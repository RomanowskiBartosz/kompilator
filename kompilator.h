#include "types.h"
#include <string>
#include <vector>
#include <map>
#include <sstream>
#include <stack>

using namespace std;

class kompilator
{
public:
	kompilator();
	vector <string> code;
	int floatCounter;
	stringstream threesStream;
	map<string,element*> symbolTable;
	stack <element> arguments;
	vector<element*>sizesTemp;
	int insertSymbol(string name,element *ele,string value);
	void addOp(char);
	void genCode(char,string);
	void insertArray(string,element*);
	void makeFloat(float value);
	string loadLine(element,int);
	string convertTypes(int,element,element);
	void genIfLabel();
	int labelCounter;
	void jumpStatment(string);
	stack<string> ifLabels;
};
