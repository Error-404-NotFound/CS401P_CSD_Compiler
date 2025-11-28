%option noyywrap
%{
#include<stdio.h>
#include<stdlib.h>
#include<string.h>
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
int countn=0;
%}

%option yylineno

bin [01]
ws [ \t\n]
digit [0-9]
letter [A-Za-z]
letter_ [A-Za-z_]
alphanumeric [A-Za-z0-9_]

%%

"int"                       { strcpy(yylval.node.lexeme, yytext); return INT; }
"float"                     { strcpy(yylval.node.lexeme, yytext); return FLOAT; }
"char"                      { strcpy(yylval.node.lexeme, yytext); return CHAR; }
"string"                    { strcpy(yylval.node.lexeme, yytext); return STRING; }
"void"                      { strcpy(yylval.node.lexeme, yytext); return VOID; }
"reply"                     { strcpy(yylval.node.lexeme, yytext); return REPLY; }
"if"                        { strcpy(yylval.node.lexeme, yytext); return IF; }
"elif"                      { strcpy(yylval.node.lexeme, yytext); return ELIF; }
"else"                      { strcpy(yylval.node.lexeme, yytext); return ELSE; }
"while"                     { strcpy(yylval.node.lexeme, yytext); return WHILE; }
"for"                       { strcpy(yylval.node.lexeme, yytext); return FOR; }
"break"                     { strcpy(yylval.node.lexeme, yytext); return BREAK; }
"continue"                  { strcpy(yylval.node.lexeme, yytext); return CONTINUE; }
"switch"                    { strcpy(yylval.node.lexeme, yytext); return SWITCH; }
"case"                      { strcpy(yylval.node.lexeme, yytext); return CASE; }
"default"                   { strcpy(yylval.node.lexeme, yytext); return DEFAULT; }

"func"                      { strcpy(yylval.node.lexeme, yytext); return FUNC; }
"->"                        { strcpy(yylval.node.lexeme, yytext); return ARROW; }
"loop"                      { strcpy(yylval.node.lexeme, yytext); return LOOP; }
"from"                      { strcpy(yylval.node.lexeme, yytext); return FROM; }
"to"                        { strcpy(yylval.node.lexeme, yytext); return TO; }
"step"                      { strcpy(yylval.node.lexeme, yytext); return STEP; }
"until"                     { strcpy(yylval.node.lexeme, yytext); return UNTIL; }
"match"                     { strcpy(yylval.node.lexeme, yytext); return MATCH; }
"_"                         { strcpy(yylval.node.lexeme, yytext); return UNDERSCORE; }
"=>"                        { strcpy(yylval.node.lexeme, yytext); return FATARROW; }
"class"                     { strcpy(yylval.node.lexeme, yytext); return CLASS; }
"public"                    { strcpy(yylval.node.lexeme, yytext); return PUBLIC; }
"private"                   { strcpy(yylval.node.lexeme, yytext); return PRIVATE; }
"record"                    { strcpy(yylval.node.lexeme, yytext); return RECORD; }
"."                         { strcpy(yylval.node.lexeme, yytext); return DOT; }
"make"                      { strcpy(yylval.node.lexeme, yytext); return MAKE; }
"discard"                   { strcpy(yylval.node.lexeme, yytext); return DISCARD; }
"handle"                    { strcpy(yylval.node.lexeme, yytext); return HANDLE; }
"and"	                    { strcpy(yylval.node.lexeme, yytext); return AND; }
"or"	                    { strcpy(yylval.node.lexeme, yytext); return OR; }
"not"	                    { strcpy(yylval.node.lexeme, yytext); return NOT;}
"import"                    { strcpy(yylval.node.lexeme, yytext); return IMPORT; }
"global"                    { strcpy(yylval.node.lexeme, yytext); return GLOBAL; }

"input"                     { strcpy(yylval.node.lexeme, yytext); return INPUT; }
"result"                    { strcpy(yylval.node.lexeme, yytext); return RESULT; }


{digit}+                    { strcpy(yylval.node.lexeme, yytext); return INT_LITERAL; }
{digit}*\.{digit}+          { strcpy(yylval.node.lexeme, yytext); return FLOAT_LITERAL; }
{letter_}{alphanumeric}*    { strcpy(yylval.node.lexeme, yytext); return ID; }

"<="                        { strcpy(yylval.node.lexeme, yytext); return LE; }
">="                        { strcpy(yylval.node.lexeme, yytext); return GE; }
"=="                        { strcpy(yylval.node.lexeme, yytext); return EQ; }
"!="                        { strcpy(yylval.node.lexeme, yytext); return NE; }
">"	                        { strcpy(yylval.node.lexeme, yytext); return GT; }
"<"	                        { strcpy(yylval.node.lexeme, yytext); return LT; }

"="                         { strcpy(yylval.node.lexeme, yytext); return ASSIGN; }
"+"                         { strcpy(yylval.node.lexeme, yytext); return ADD; }
"-"                         { strcpy(yylval.node.lexeme, yytext); return SUB; }
"*"                         { strcpy(yylval.node.lexeme, yytext); return MUL; }
"/"                         { strcpy(yylval.node.lexeme, yytext); return DIV; }
"%"                         { strcpy(yylval.node.lexeme, yytext); return MOD;}


"&"			                { strcpy(yylval.node.lexeme, yytext); return BITAND; }
"|"			                { strcpy(yylval.node.lexeme, yytext); return BITOR; }
"^"			                { strcpy(yylval.node.lexeme, yytext); return BITXOR; }
"~"			                { strcpy(yylval.node.lexeme, yytext); return BITNOT; }
"<<"			            { strcpy(yylval.node.lexeme, yytext); return LSHIFT; }
">>"			            { strcpy(yylval.node.lexeme, yytext); return RSHIFT; }

";"                         { strcpy(yylval.node.lexeme, yytext); return SEMICOLON;}
","                         { strcpy(yylval.node.lexeme, yytext); return COMMA;}
":"                         { strcpy(yylval.node.lexeme, yytext); return COLON;}
"{"                         { strcpy(yylval.node.lexeme, yytext); return LBRACE;}
"}"                         { strcpy(yylval.node.lexeme, yytext); return RBRACE;}
"("                         { strcpy(yylval.node.lexeme, yytext); return LPAR;}
")"                         { strcpy(yylval.node.lexeme, yytext); return RPAR;}
"["                         { strcpy(yylval.node.lexeme, yytext); return LBRACK;}
"]"                         { strcpy(yylval.node.lexeme, yytext); return RBRACK;}


\#\#\#.*\#\#\#              { /* Ignore special comments */ ; }
\/\/.*                      { /* Ignore comments */ ; }
[ \t\r]*                    { /* Ignore whitespace */ ; }
[\n]                        { /* Ignore newlines */ countn++; }

["].*["]                    { strcpy(yylval.node.lexeme, yytext); return STRING_LITERAL; }
['].[']                     { strcpy(yylval.node.lexeme, yytext); return CHAR_LITERAL; }

.                           { /*printf("%s",yytext);append(yytext);*/ ; }
<<EOF>>                     { return 0; }

%%

// int yywrap() {
//     return 1;
// }

// int main() {
//     yylex(); // start lexical analysis
//     printf("\nTotal number of lines = %d\n", countn);
//     return 0;
// }
