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
	stringstream threesStream;
	map<string,element*> symbolTable;
	stack <element> arguments;
	vector<element*>sizesTemp;
	int insertSymbol(string name,element *ele);
	void addOp(char);
	void genCode(char,string);
	void insertArray(string,element*);
	string loadLine(string,int);

};
