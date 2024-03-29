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
\+              {return '+';}
\-              {return '-';}
\*              {return '*';}
\/              {return '/';}
\,              {return ',';}
\(              {return '(';}
\)              {return ')';}
\[              {return '[';}
\]              {return ']';}
\=              {return PRZYPISZ;}
\<\=            {return LEQ;}
\;              {return ';';}
0|[1-9][0-9]*   {yylval.ival = atoi(yytext);return LC;}
(0|[1-9][0-9]*)[.][0-9]*        {return LR;}
[A-Za-z_][A-Za-z0-9_]*          {yylval.text=strdup(yytext);return ID;}
\                               {;}
\n                              {yylineno++;}
\<\*                            {return CSTART;}
\*\>                            {return CEND;}
.                               {yyerror("Blad leksykalny\n");}
%%
int yyerror(const char *msg,...)
{
        printf("\n %d: %s\n", yylineno, msg);
        exit(1);
}
