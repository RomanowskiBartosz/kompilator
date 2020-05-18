%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "def.tab.hh"

extern int yylineno;
int yyerror(const char *,...);
%}

%%
"int"           {return INT;}
"float"         {return FLOAT;}
"print"		{return PRINT;}
"read"		{return READ;}
\"[A-Za-z0-9_]*\" {yylval.text=strdup(yytext);return STRING;}
\+              {return '+';}
\-              {return '-';}
\*              {return '*';}
\/              {return '/';}
\,              {return ',';}
\(              {return '(';}
\)              {return ')';}
\[              {return '[';}
\]              {return ']';}
\=\=		{yylval.text="bne";return COND; }
\=              {return PRZYPISZ;}
\<\=            {yylval.text = "bgt";return COND;}
\>\=		{yylval.text="blt";return COND;}
\<		{yylval.text = "bge";return COND;}
\>		{yylval.text="ble";return COND;}
\!\=		{yylval.text ="beq";return COND;}
\;              {return ';';}
"if"		{return IF;}
"else"		{return ELSE;}
"while"		{return WHILE;}
\{		{;}
\}		{;}
0|[1-9][0-9]*   {yylval.ival = atoi(yytext);return LC;}
(0|[1-9][0-9]*)[.][0-9]*        {yylval.fval =atof(yytext);return LR;}
[A-Za-z_][A-Za-z0-9_]*          {yylval.text=strdup(yytext);return ID;}
\                               {;}
\n                              {yylineno++;}
.                               {yyerror("Blad leksykalny\n");}
%%
int yyerror(const char *msg,...)
{
        printf("\n %d: %s\n", yylineno, msg);
        exit(1);
}
