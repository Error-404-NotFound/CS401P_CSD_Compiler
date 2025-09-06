%{
#include<stdio.h>
#include<stdbool.h>
#include<string.h>
#include<stdlib.h>
#include<limits.h>
#include<float.h>

int yylex();
void yyerror(char*);
int yyparse();
extern FILE * yyin;
int eflag = 0;
int tindex=0;
int lindex=0;
int address = 100;
char str[1024];
char* errorBuffer[1024];

int curScope = 0;
int siblingScope = 0;
int offset = 0;
int errorIndex = 0;
int lexdIndex = 0;
char currentVariableType[100];
int currentVariableTypeSize = 0;

struct typeDetails{
char* type;
int size;
};

struct lexemeDetails{
char* type;
char* address;
char* name;
int scope;
int siblingScope;
};

typedef struct Node {
char* key;
struct lexemeDetails value;
struct Node* next;
} Node;

typedef struct HashMap {
Node** keys;
int hashSize;
int size;
} HashMap;

char* genLabel();
char* genBlockLabel();
void generateCode(char* , char* , char*, char*);
void generateAssignCode(char* , char* , char*);
void generateDeclareCode(char* , char* , char*);
void generateNotCode(char* , char*);
int hashFunction(char*, int);
HashMap* createHashMap(int);
void insert(HashMap*, char*, struct lexemeDetails);
struct lexemeDetails get(HashMap*, char*);
bool existsInHashMap(HashMap*, char*);
HashMap* HT;
struct lexemeDetails lexd[100];
char* intToHex(int);

void allocate(struct typeDetails* root, char* type, int size);
void defineIdentifierType(char* arg);
void varExists(char* id);
void varDoesNotExist(char* id);
void conflictingTypes(char* id);
void logerrorBuffer();
void SymbolTable();

int main(int argc, char *argv[]){
if(argc != 2){
        fprintf(stderr, "Usage: %s <input_file>\n", argv[0]);
        return 1;
    }
    yyin = fopen(argv[1], "r");
    if(yyin == NULL){
        fprintf(stderr, "Error opening the input file.\n");
        return 1;
    }
HT = createHashMap(1000);
for(int i = 0; i < 100; i++) {
errorBuffer[i] = (char*)malloc(sizeof(char)*1000);
strcpy(errorBuffer[i], "-1");
}
for(int i = 0; i < 100; i++){
struct lexemeDetails temp;
temp.name = (char*)malloc(sizeof(char)*1000);
strcpy(temp.name, "-1");
lexd[i] = temp;
}
yyparse();
SymbolTable();
fclose(yyin);
    return 0;
}
%}

%name parser

%start HEADER

%token HEAD STDIO STDLIB STRING
%token MAIN
%token RETURN
%token VOID
%token IF ELSE WHILE FOR
%token ADD SUB MUL DIV MOD ASSIGN
%token LT LTE GT GTE EQ NE
%token NOT AND OR
%token INCREMENT DECREMENT
%token LP RP LC RC COLON SEMICOLON COMMA
%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%token <addr> NUMBER
%token <addr> ID
%token <addr> INT
%token <addr> FLOAT
%token <addr> CHAR

%nonassoc LT GT LTE GTE NOT ASSIGN
%nonassoc OR
%nonassoc AND
%left ADD SUB
%left MUL DIV MOD
%right LP RP
%right LC RC
%right ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%nonassoc INCREMENT DECREMENT

%union{
char lexeme[200];
char addr[200];
char* lab;
struct typeDetails* td;
struct lexemeDetails* lxd;
}

%type <addr> HEADER
%type <addr> Program
%type <addr> ProgramBlock
%type <addr> Block
%type <addr> StatementList
%type <addr> Statement
%type <addr> DeclarationStatement
%type <addr> AssignmentStatement
%type <addr> IfStatement
%type <addr> ElseStmt
%type <addr> WhileStatement
%type <addr> ForStatement
%type <addr> L
%type <addr> PREREL
%type <addr> RELEXP
%type <addr> EXPRESSION
%type <addr> TERM
%type <addr> FACTOR
%type <addr> Val
%type <td> Type
%type <lab> dummyLabels

%%
HEADER:
HEAD STDIO Program {  }
| HEAD STDLIB Program {  }
| HEAD STRING Program {  }
;

Program:
INT MAIN LP RP ProgramBlock { }
| INT MAIN LP VOID RP ProgramBlock { }
| { }
;

ProgramBlock:
Block ProgramBlock { }
| { }

Block:
    LC { curScope++; siblingScope++; offset = 0; } StatementList RC { curScope--; }
;

StatementList:
Statement StatementList { }
| { }
;

Statement:
DeclarationStatement SEMICOLON { }
| AssignmentStatement SEMICOLON { }
| Block { }
| IfStatement { }
| WhileStatement { }
| ForStatement { }
;

DeclarationStatement:
Type L { strcpy(currentVariableType, ""); }
;

L:
  ID { defineIdentifierType($1); }
  | ID ASSIGN AssignmentStatement { generateDeclareCode($1, $3, $$); }
;

%%
void allocate(struct typeDetails* root, char* type, int size) {
root = (struct typeDetails*)malloc(sizeof(struct typeDetails));
root->type = (char*)malloc(1000*sizeof(char));
strcpy(root->type, type);
strcpy(currentVariableType, type);
currentVariableTypeSize = size;
root->size = size;
}

void defineIdentifierType(char* arg) {
struct lexemeDetails lexData;
lexData.name = (char*)malloc(1000*sizeof(char));
strcpy(lexData.name, arg);
lexData.type = (char*)malloc(1000*sizeof(char));
strcpy(lexData.type, currentVariableType);
lexData.scope = curScope;
lexData.siblingScope = siblingScope;
lexData.address = (char*)malloc(1000*sizeof(char));
lexData.address = intToHex(offset);
offset += currentVariableTypeSize;
struct lexemeDetails ld = get(HT, arg);
if(existsInHashMap(HT, arg) && ld.scope == curScope && ld.siblingScope == siblingScope) {
if(strcmp(lexData.type, ld.type) != 0) conflictingTypes(arg);
else varExists(arg);
}
else {
insert(HT, arg, lexData);
lexd[lexdIndex++] = lexData;
}
}

void varExists(char* id) {
char* err = (char*)malloc(sizeof(char)*1000);
strcpy(err, "Error: Redeclaration of ");
strcat(err, id);
strcpy(errorBuffer[errorIndex], err);
errorIndex++;
printf("\nError: Redeclaration of %s", id);
}

void varDoesNotExist(char* id) {
char* err = (char*)malloc(sizeof(char)*1000);
strcpy(err, "Error: ");
strcat(err, id);
strcat(err, " is undeclared in this scope");
strcpy(errorBuffer[errorIndex], err);
errorIndex++;
printf("\nError: %s is undeclared in this scope", id);
}

void conflictingTypes(char* id) {
char* err = (char*)malloc(sizeof(char)*1000);
strcpy(err, "Error: Conflicting types for ");
strcat(err, id);
strcpy(errorBuffer[errorIndex], err);
errorIndex++;
printf("\nError: Conflicting types for %s", id);
}

void logerrorBuffer(){
for(int i = 0; i < 100 && strcmp(errorBuffer[i], "-1") != 0; i++)
printf("%s\n", errorBuffer[i]);
}

void SymbolTable(){
printf("\n\nSymbol Table:\n");
int logScope = 1;
for(int i = 0; i < 100 && strcmp(lexd[i].name, "-1") != 0; i++){
if(lexd[i].siblingScope != logScope){
printf("\n");
logScope = lexd[i].siblingScope;
}
printf("%s %s %s", lexd[i].address, lexd[i].name, lexd[i].type);
printf("\n");
}
}

int hashFunction(char* key, int hashSize) {
int hash = 0;
int i;
for (i = 0; key[i] != '\0'; i++) {
hash = (hash * 31 + key[i]) % hashSize;
}
return hash;
}

HashMap* createHashMap(int hashSize) {
HashMap* hashMap = (HashMap*)malloc(sizeof(HashMap));
if (!hashMap) {
return NULL;
}
hashMap->keys = (Node**)malloc(sizeof(Node*) * hashSize);
if (!hashMap->keys) {
free(hashMap);
return NULL;
}
for (int i = 0; i < hashSize; i++) {
hashMap->keys[i] = NULL;
}
hashMap->hashSize = hashSize;
hashMap->size = 0;
return hashMap;
}

void insert(HashMap* hashMap, char* key, struct lexemeDetails value) {
int index = hashFunction(key, hashMap->hashSize);
Node* newNode = (Node*)malloc(sizeof(Node));
newNode->key = strdup(key);
newNode->value = value;
newNode->next = hashMap->keys[index];
hashMap->keys[index] = newNode;
hashMap->size++;
}

struct lexemeDetails get(HashMap* hashMap, char* key) {
int index = hashFunction(key, hashMap->hashSize);
Node* node = (Node*)malloc(sizeof(Node));
node = hashMap->keys[index];
while (node) {
if (strcmp(node->key, key) == 0) {
return node->value;
}
node = node->next;
}
struct lexemeDetails l; l.scope = -1;
return l;
}

bool existsInHashMap(HashMap* hashMap, char* key) {
struct lexemeDetails ld = get(hashMap, key);
if(ld.scope == -1) return false;
return true;
}

char* intToHex(int offset){
char* buf = (char*)malloc(sizeof(char)*1000);
char* hex = (char*)malloc(sizeof(char)*1000);
strcpy(hex, "0x");
sprintf(buf, "%x", offset);
int bufLen = strlen(buf);
for(int i = 1; i <= 4 - bufLen; i++) strcat(hex, "0");
strcat(hex, buf);
return hex;
}
