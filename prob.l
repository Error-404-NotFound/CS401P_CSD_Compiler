%option noyywrap
%{
#include<stdio.h>
#include<stdlib.h>
#include"y.tab.h"
char buffer[2048];
void append(const char*str){
    if(strlen(buffer)+strlen(str)<2048){
        strcat(buffer,str);
    }else{
        fprintf(stderr,"BUFFER OVERFLOW");
        exit(1);
    }
}
%}

bin [01]
ws [ \t\n]
digit [0-9]
letter [A-Za-z]
letter_ [A-Za-z_]
alphanumeric [A-Za-z0-9_]

%%
[ \t\n] ;                   { /* Ignore whitespace and newline */ }
"#include"                  { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return HEAD; }
"<stdio.h>"                 { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return STDIO; }
"<stdlib.h>"                { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return STDLIB; }
"<string.h>"                { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return STRING; }
"main"                      { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return MAIN; }
"if"                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return IF; }
"else"                      { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return ELSE; }
"while"                     { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return WHILE; }
"for"                       { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return FOR; }
"int"                       { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return INT; }
"float"                     { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return FLOAT; }
"char"                      { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return CHAR; }
"void"                      { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return VOID; }
"return 0"                  { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return RETURN; }
\/\/.*                      { /* Ignore comments */ }
"/*"([^*]|\*+[^*/])*\*+"/"  { /* Ignore comments */ }
{digit}+(\.{digit}+)?       { strcpy(yylval.lexeme,yytext);return NUMBER; }
{letter_}{alphanumeric}*    { strcpy(yylval.lexeme,yytext);return ID; }
"++"                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return INCREMENT; }
"--"                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return DECREMENT; }
"+"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return ADD; }
"-"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return SUB; }
"*"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return MUL; }
"/"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return DIV; }
"%"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return MOD; }
">"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return GT; }
"<"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return LT; }
">="                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return GTE; }
"<="                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return LTE; }
"=="                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return EQ; }
"!="                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return NE; }
"&&"                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return AND; }
"||"                        { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return OR; }
"!"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return NOT; }
"("                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return LP; }
")"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return RP; }
"{"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return LC; }
"}"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return RC; }
"="                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return ASSIGN; }
","                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return COMMA; }
":"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return COLON; }
";"                         { /*printf("%s",yytext);yylval.lexeme=strdup(yytext);append(yytext);*/return SEMICOLON; }
.                           { /*printf("%s",yytext);append(yytext);*/return yytext[0]; }
<<EOF>>                     { return 0; }
%%`
