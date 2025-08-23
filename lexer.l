%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "parser.tab.h"

extern char *yytext;
%}

%%
[ \t\r\n]+                 /* skip whitespace */

"int"                      { yylval.s = strdup(yytext); return INT; }
"float"                    { yylval.s = strdup(yytext); return FLOAT; }
"char"                     { yylval.s = strdup(yytext); return CHAR; }
"if"                       { yylval.s = strdup(yytext); return IF; }
"else"                     { yylval.s = strdup(yytext); return ELSE; }
"while"                    { yylval.s = strdup(yytext); return WHILE; }
"true"                     { yylval.s = strdup(yytext); return T; }
"false"                    { yylval.s = strdup(yytext); return F; }

"++"                       { yylval.s = strdup(yytext); return INC; }
"--"                       { yylval.s = strdup(yytext); return DEC; }
"+="                       { yylval.s = strdup(yytext); return PEQ; }
"-="                       { yylval.s = strdup(yytext); return MEQ; }
"*="                       { yylval.s = strdup(yytext); return SEQ; }
"/="                       { yylval.s = strdup(yytext); return DEQ; }

">="                       { yylval.s = strdup(yytext); return GTE; }
"<="                       { yylval.s = strdup(yytext); return LTE; }
"=="                       { yylval.s = strdup(yytext); return EE; }
"!="                       { yylval.s = strdup(yytext); return NE; }
"&&"                       { yylval.s = strdup(yytext); return AND; }
"||"                       { yylval.s = strdup(yytext); return OR; }
"!"                        { yylval.s = strdup(yytext); return NOT; }

">"                        { yylval.s = strdup(yytext); return GT; }
"<"                        { yylval.s = strdup(yytext); return LT; }
"="                        { yylval.s = strdup(yytext); return EQ; }
"+"                        { yylval.s = strdup(yytext); return PL; }
"-"                        { yylval.s = strdup(yytext); return MI; }
"*"                        { yylval.s = strdup(yytext); return ST; }
"/"                        { yylval.s = strdup(yytext); return DV; }
"%"                        { yylval.s = strdup(yytext); return MD; }

";"                        { yylval.s = strdup(yytext); return SC; }
","                        { yylval.s = strdup(yytext); return CM; }
"("                        { yylval.s = strdup(yytext); return LP; }
")"                        { yylval.s = strdup(yytext); return RP; }
"{"                        { yylval.s = strdup(yytext); return LB; }
"}"                        { yylval.s = strdup(yytext); return RB; }
"["                        { yylval.s = strdup(yytext); return LS; }
"]"                        { yylval.s = strdup(yytext); return RS; }

[0-9]+(\.[0-9]+)?          { yylval.s = strdup(yytext); return NUM; }
[a-zA-Z_][a-zA-Z0-9_]*     { yylval.s = strdup(yytext); return ID; }

.                          { return yytext[0]; }
%%

int yywrap(void){ return 1; }
