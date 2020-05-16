#pragma once
#include <string>
#include <vector>

class type
{
public:
	std::string type;
int size;
std::vector<int> sizes;
std::vector<int> dims;
};


class arrayIndexType :public type
{
	public : arrayIndexType(int);
};
class floatType :public type
{
        public : floatType(int);
};
class intType :public type
{                     
        public : intType(int);
};    

class idType :public type
{                     
        public : idType(int);
};    
class intArrayType :public type
{
	public: intArrayType(int);
};

class element
{
        public:
	std:: string value;
        type elementType;
        element(type t,std::string value);
};

