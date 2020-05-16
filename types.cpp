#include <string>
#include <vector>
#include "types.h"
using namespace std;


element:: element(type t,string value)
{
elementType=t;
this->value=value;
};

intArrayType::intArrayType(int size)
{
type="arrayInt";
this->size=size;
};

idType::idType(int size)
{
type="idType";
this->size=size;
};

intType::intType(int size)
{
type="intType";
this->size=size;
};

arrayIndexType::arrayIndexType(int size)
{
type="indexType";
this->size=size;
};

floatType::floatType(int size)
{
type="floatType";
this->size=size;
};

