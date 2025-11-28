%{
#include<stdio.h>
#include<stdbool.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<limits.h>
#include<float.h>
#include<math.h>
#include<iostream>
#include<vector>
#include<stack>
#include<queue>
#include<set>
#include<string>
#include<algorithm>
#include<unordered_map>
#include<map>
#include<list>
#include<fstream>
#include<cctype>

#define add_tac($$, $1, $2, $3) {strcpy($$.type, $1.type);\
    sprintf($$.lexeme, get_temp().c_str());\
    string lt=string($1.type);\
    string rt=string($3.type);\
    if((lt == "CHAR" && rt == "INT") || (rt == "CHAR" && lt == "INT")){\
        strcpy($$.type, "INT");\
    }\
    else if((lt == "FLOAT" && rt == "INT") || (rt == "FLOAT" && lt == "INT")){\
        strcpy($$.type, "FLOAT");\
    }\
    else if((lt == "FLOAT" && rt == "FLOAT") || (lt == "INT" && rt == "INT") || (lt == "CHAR" && rt == "CHAR")){\
        strcpy($$.type, $1.type);\
    }\
    else{\
        errorBuffer.push_back("Error: Cannot convert between CHAR and FLOAT in line : " + to_string(countn+1));\
    }}
using namespace std;

void yyerror(const char* s);
int yylex();
int yyparse();
int yywrap();
int yytext();
extern FILE * yyin;

bool check_declaration(string variable);
bool check_scope(string variable);
bool multiple_declaration(string variable);
bool is_reserved_word(string id);
bool function_check(string variable, int flag);
bool type_check(string type1, string type2);
bool check_type(string l, string r);
string get_temp();
void init_library_registry();
void load_library_function(string lib_name, string func_name);

queue<string> free_temp;
set<string> const_temps;
void PrintStack(stack<int> s);

struct variableDetails {
    string dataTypes;
    int scope;
    int size;   // for arrays
    int isArray;
    int lineNumber; 
};

vector<string> tac;
map<string, string> temp_map;
vector<string> errorBuffer;
int variableCount = 0;
int labelCount = 0;
int temp_index;
int temp_label;

stack<int> loop_continue, loop_break;
stack<pair<string, vector<string>>> func_call_id;
stack<int> scope_history;
int scope_counter = 0;

// for array DeclarationStatement with initialization
string curr_array;
int arr_index=0;

extern int countn;

vector<string> reserved = {
    "int", "float", "char", "string", "void", 
    "if", "elif", "else", "for", "while", "break", "continue", 
    "main", "return", "switch", "case", "input", "result"
};

struct functionDetails{
    string return_type;
    int num_params;
    vector<string> param_types;
    unordered_map<string, struct variableDetails> symbol_table;
};

int has_return_stmt;

unordered_map<string, struct functionDetails> func_table;
string curr_func_name;
vector<string> curr_func_param_type;

struct classDetails{
    unordered_map<string, struct variableDetails> fields;
    unordered_map<string, struct functionDetails> methods;
    vector<string> field_order;
    int lineNumber;
};

unordered_map<string, struct classDetails> class_table;
string curr_class_name;
bool in_class = false;

set<string> imported_libraries;
map<string, set<string>> library_functions;

struct LibraryFunction {
    string library_name;
    string func_name;
    string return_type;
    vector<string> param_types;
    bool is_loaded;  // Whether 3AC is already generated
    string temp_name; // temp used to represent a call emitted at load time
    bool call_emitted; // whether a @call line was emitted when loading
};

map<string, LibraryFunction> available_lib_functions;

%}

%name parser

%union{
    struct node { 
        char lexeme[100];
        int lineNumber;
        char type[100];
        char if_body[5];
        char elif_body[5];
		char else_body[5];
        char loop_body[5];
        char parentNext[5];
        char case_body[5];
        char id[5];
        char temp[5];
        int nParams;
    } node;
}

%token <node> INT FLOAT CHAR STRING 
%token <node> VOID REPLY 
%token <node> IF ELIF ELSE WHILE FOR BREAK CONTINUE SWITCH CASE DEFAULT
%token <node> RESULT INPUT 
%token <node> INT_LITERAL FLOAT_LITERAL ID
%token <node> LE GE EQ NE GT LT AND OR NOT
%token <node> ASSIGN ADD SUB MUL DIV MOD
%token <node> BITAND BITOR BITXOR BITNOT LSHIFT RSHIFT
%token <node> SEMICOLON COMMA COLON LBRACE RBRACE LPAR RPAR LBRACK RBRACK
%token <node> STRING_LITERAL CHAR_LITERAL
%token <node> FUNC ARROW
%token <node> LOOP FROM TO STEP UNTIL
%token <node> MATCH UNDERSCORE FATARROW
%token <node> CLASS PUBLIC PRIVATE RECORD DOT
%token <node> MAKE DISCARD HANDLE
%token <node> IMPORT GLOBAL

%type <node> Program Func FuncPrefix ParamList Param
%type <node> StatementList Statement
%type <node> DeclarationStatement
%type <node> ReplyStatement
%type <node> ArrValues
%type <node> DataTypeG FuncDataType
%type <node> EXPRESSION PrimaryExpression UnaryExpression UnaryOperator
%type <node> Literal
%type <node> AssignmentStatement
%type <node> IFStatement ELSEIFStatement ELSEStatement
%type <node> SWITCHStatement CASEStatement CASEStatementList
%type <node> WHILEStatement FORStatement
%type <node> BREAKStatement CONTINUEStatement
%type <node> INPUTStatement RESULTStatement
%type <node> PostfixExpression
%type <node> FuncCall ArgList Arg
%type <node> LOOPWHILEStatement LOOPUNTILStatement LOOPFROMStatement StepClause
%type <node> MatchStatement PatternArmList PatternArm Pattern
%type <node> ClassDecl CLASSBody ClassMemberList ClassMember Visibility FieldDecl MethodDecl

%right ASSIGN
%left OR
%left AND
%left BITOR
%left BITXOR
%left BITAND
%left EQ NE
%left LE GE LT GT
%left LSHIFT RSHIFT
%left ADD SUB
%left MUL DIV MOD
%left BITNOT

%%

// Program:   
//     FuncList {  }
//     ;
 
// FuncList:   
//     FuncList Func {  }
//     | /* epsilon */ {  }
//     ;

Program:
    DeclList {  }
    ;

DeclList:
    DeclList TopDecl {  }
    | /* epsilon */ {  }
    ;

TopDecl:
    Func {  }
    | ClassDecl {  }
    | RecordDecl {  }
    | ImportStatement {  }
    ;

ImportStatement:
    IMPORT ID SEMICOLON {
        string lib_name = string($2.lexeme);
        
        if(library_functions.find(lib_name) == library_functions.end()) {
            errorBuffer.push_back("Error: Library '" + lib_name + "' not found");
        } else {
            imported_libraries.insert(lib_name);
            tac.push_back("# Imported library: " + lib_name);
            
            // Optionally parse the .rcblib file here and generate 3AC
            // For now, we'll do lazy loading on first function call
        }
    }
    | FROM ID IMPORT ID SEMICOLON {
        string lib_name = string($2.lexeme);
        string func_name = string($4.lexeme);
        
        if(library_functions.find(lib_name) == library_functions.end()) {
            errorBuffer.push_back("Error: Library '" + lib_name + "' not found");
        } else if(library_functions[lib_name].find(func_name) == library_functions[lib_name].end()) {
            errorBuffer.push_back("Error: Function '" + func_name + "' not in library '" + lib_name + "'");
        } else {
            imported_libraries.insert(lib_name);
            tac.push_back("# Imported " + func_name + " from " + lib_name);
        }
    }
    ;

ClassDecl:
    CLASS ID {
        if(class_table.find(string($2.lexeme)) != class_table.end()){
            errorBuffer.push_back("Error: Duplicate class name - " + string($2.lexeme));
        }
        curr_class_name = string($2.lexeme);
        in_class = true;
        tac.push_back("class " + curr_class_name);
    } LBRACE CLASSBody RBRACE {
        tac.push_back("endclass " + curr_class_name);
        curr_class_name = "";
        in_class = false;
    }
    ;

CLASSBody:
    ClassMemberList {  }
    ;

ClassMemberList:
    ClassMemberList ClassMember {  }
    | /* epsilon */ {  }
    ;

ClassMember:
    Visibility FieldDecl {  }
    | Visibility MethodDecl {  }
    | FieldDecl {  }  // default private
    | MethodDecl {  }  // default private
    ;

Visibility:
    PUBLIC { strcpy($$.lexeme, "public"); }
    | PRIVATE { strcpy($$.lexeme, "private"); }
    ;

FieldDecl:
    ID COLON DataTypeG SEMICOLON {
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word");
        }
        
        variableDetails vd;
        vd.dataTypes = string($3.type);
        vd.scope = 0; // class scope
        vd.size = 0;
        vd.isArray = 0;
        vd.lineNumber = countn+1;
        
        class_table[curr_class_name].fields[string($1.lexeme)] = vd;
        class_table[curr_class_name].field_order.push_back(string($1.lexeme));
        
        tac.push_back("- field " + string($3.type) + " " + string($1.lexeme));
    }
    | ID COLON DataTypeG LBRACK INT_LITERAL RBRACK SEMICOLON { // NEW: RCBScript array syntax
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word");
        }
        
        variableDetails vd;
        vd.dataTypes = string($3.type);
        vd.scope = 0; // class scope
        vd.size = stoi(string($5.lexeme));
        vd.isArray = 1;
        vd.lineNumber = countn+1;
        
        class_table[curr_class_name].fields[string($1.lexeme)] = vd;
        class_table[curr_class_name].field_order.push_back(string($1.lexeme));
        
        tac.push_back("- field " + string($3.type) + " " + string($1.lexeme) + " [ " + string($5.lexeme) + " ] ");
    }
    ;

MethodDecl:
    FUNC ID {
        string method_name = curr_class_name + "::" + string($2.lexeme);
        if(class_table[curr_class_name].methods.find(string($2.lexeme)) != 
           class_table[curr_class_name].methods.end()){
            errorBuffer.push_back("Error: Duplicate method name - " + string($2.lexeme));
        }
        tac.push_back(method_name + ":"); 
        curr_func_name = method_name;
    } LPAR ParamList RPAR {
        class_table[curr_class_name].methods[string($2.lexeme)].num_params = $5.nParams;
    } ARROW FuncDataType LBRACE {
        has_return_stmt = 0;
        scope_history.push(++scope_counter);
        class_table[curr_class_name].methods[string($2.lexeme)].return_type = string($8.type);
    } StatementList RBRACE {
        if(string($8.type) != "void" && has_return_stmt == 0){
            errorBuffer.push_back("Return Statement not there for method: " + string($2.lexeme));
        }
        scope_history.pop();
        --scope_counter;
        tac.push_back("end " + curr_func_name);
        has_return_stmt = 0;
    }
    ;

RecordDecl:
    RECORD ID {
        if(class_table.find(string($2.lexeme)) != class_table.end()){
            errorBuffer.push_back("Error: Duplicate record name - " + string($2.lexeme));
        }
        curr_class_name = string($2.lexeme);
        tac.push_back("record " + curr_class_name);
    } LBRACE RecordFieldList RBRACE {
        tac.push_back("endrecord " + curr_class_name);
        curr_class_name = "";
    }
    ;

RecordFieldList:
    RecordFieldList RecordField {  }
    | RecordField {  }
    ;

RecordField:
    ID COLON DataTypeG SEMICOLON {
        variableDetails vd;
        vd.dataTypes = string($3.type);
        vd.scope = 0;
        vd.size = 0;
        vd.isArray = 0;
        vd.lineNumber = countn+1;
        
        class_table[curr_class_name].fields[string($1.lexeme)] = vd;
        class_table[curr_class_name].field_order.push_back(string($1.lexeme));
        
        tac.push_back("- field " + string($3.type) + " " + string($1.lexeme));
    }
    ;

Func:   
    FuncPrefix LBRACE {
        has_return_stmt = 0;
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        if(func_table[curr_func_name].return_type != "void" && has_return_stmt == 0){
            errorBuffer.push_back("Return Statement not there for function: " + curr_func_name);
        }
        scope_history.pop();
        --scope_counter;
        tac.push_back("end:\n");
        has_return_stmt = 0;
    }
    ;
 
FuncPrefix:
    FUNC ID {   
        if(func_table.find(string($2.lexeme)) != func_table.end()){
            errorBuffer.push_back("Error: Duplicate function name - " + string($2.lexeme));
        }
        // func_table[curr_func_name] = {string($1.type), 0, {}, {} , countn};
        tac.push_back(string($2.lexeme) + ": " + string($1.type)); 
        curr_func_name = string($2.lexeme);
    } LPAR ParamList RPAR {
        func_table[curr_func_name].return_type = string($1.type);
        func_table[curr_func_name].num_params = $5.nParams;
        // curr_func_param_type.clear();
    } ARROW FuncDataType
    ;

FuncDataType:
    DataTypeG { strcpy($$.type, $1.type); }
    | VOID { sprintf($$.type, "void"); }
    ;
 
ParamList:
    Param {
        func_table[curr_func_name].param_types.push_back(string($1.type));
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($1.type), scope_counter+1, 0, 0, countn+1 };
        tac.push_back("- Arg " + string($1.type) + " " + string($1.lexeme));                       
    } COMMA ParamList {
        $$.nParams = $4.nParams + 1;
    }
    | Param {
        $$.nParams = 1;
        func_table[curr_func_name].param_types.push_back(string($1.type));
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($1.type), scope_counter+1, 0, 0, countn+1 };
        tac.push_back("- Arg " + string($1.type) + " " + string($1.lexeme));
    }
    | /* epsilon */ { $$.nParams = 0; }
    ;
 
Param:
    DataTypeG ID {
        $$.nParams = 1;
        strcpy($$.type, $1.type);
        strcpy($$.lexeme, $2.lexeme);                    
    }
    ;
 
StatementList:
    Statement StatementList {  }
    | /* epsilon */ {  }
    ;
 
Statement:   
    DeclarationStatement {  }
    | AssignmentStatement SEMICOLON {  }
    | EXPRESSION SEMICOLON {  }
    | ReplyStatement SEMICOLON {  } 
    | IFStatement {  }
    | WHILEStatement {  }
    | FORStatement {  }
    | LOOPWHILEStatement {  }
    | LOOPFROMStatement {  }
    | LOOPUNTILStatement {  }
    | MatchStatement {  }
    | BREAKStatement {  }
    | CONTINUEStatement {  }    
    | SWITCHStatement {  }
    | INPUTStatement {  }
    | RESULTStatement {  }
    | DISCARDStatement {  }
    | HANDLEStatement {  }
    ;

DeclarationStatement:
    ID COLON DataTypeG SEMICOLON { 
        // is_reserved_word(string($1.lexeme));
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        // if(multiple_declaration(string($2.lexeme))){
        //     check_scope(string($2.lexeme));
        // };
        tac.push_back("- " + string($3.type) + " " + string($1.lexeme));
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($3.type), scope_counter, 0, 0, countn+1 };
    }
    | ID COLON STRING ASSIGN STRING_LITERAL SEMICOLON {
        // is_reserved_word(string($1.lexeme));
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        multiple_declaration(string($1.lexeme));
        tac.push_back("- STR " + string($1.lexeme));
        tac.push_back(string($1.lexeme) + " = " + string($5.lexeme) + " STRL");
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { "STR", scope_counter, string($5.lexeme).length(), 0, countn+1 };
    }
    | ID COLON DataTypeG ASSIGN EXPRESSION SEMICOLON {
        // is_reserved_word(string($1.lexeme));
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        //multiple_declaration(string($2.lexeme));
        check_type(string($3.type), string($5.type));
        tac.push_back("- " + string($3.type) + " " + string($1.lexeme));
        tac.push_back(string($1.lexeme) + " = " + string($5.lexeme) + " " + string($3.type));
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($3.type), scope_counter, 0, 0, countn+1 };

        if(const_temps.find(string($5.lexeme)) == const_temps.end() && $5.lexeme[0] == '@') free_temp.push(string($5.lexeme));
    }
    /* | DataTypeG ID LBRACK INT_LITERAL RBRACK SEMICOLON {
        // is_reserved_word(string($2.lexeme));
        if(is_reserved_word(string($2.lexeme))){
            errorBuffer.push_back("Error: '" + string($2.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        multiple_declaration(string($2.lexeme));
        tac.push_back("- " + string($1.type) + " " + string($2.lexeme) + " [ " + string($4.lexeme) + " ] ");
        func_table[curr_func_name].symbol_table[string($2.lexeme)] = { string($1.type), scope_counter, stoi(string($4.lexeme)), 1, countn+1 };
    }
    | DataTypeG ID LBRACK INT_LITERAL RBRACK ASSIGN {
        // is_reserved_word(string($2.lexeme));
        if(is_reserved_word(string($2.lexeme))){
            errorBuffer.push_back("Error: '" + string($2.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        multiple_declaration(string($2.lexeme));
        tac.push_back("- " + string($1.type) + " " + string($2.lexeme) + " [ " + string($4.lexeme) + " ] ");
        func_table[curr_func_name].symbol_table[string($2.lexeme)] = { string($1.type), scope_counter, stoi(string($4.lexeme)), 1, countn+1 };
        curr_array = string($2.lexeme);
    } LBRACE ArrValues RBRACE SEMICOLON // array size must be a positive integer  */
    | ID COLON DataTypeG LBRACK INT_LITERAL RBRACK SEMICOLON { // NEW: RCBScript array syntax
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        multiple_declaration(string($1.lexeme));
        tac.push_back("- " + string($3.type) + " " + string($1.lexeme) + " [ " + string($5.lexeme) + " ] ");
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($3.type), scope_counter, stoi(string($5.lexeme)), 1, countn+1 };
    }
    | ID COLON DataTypeG LBRACK INT_LITERAL RBRACK ASSIGN {    // NEW: RCBScript array with init
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word and cannot be used as an identifier in line : " + to_string(countn+1));
        }
        multiple_declaration(string($1.lexeme));
        tac.push_back("- " + string($3.type) + " " + string($1.lexeme) + " [ " + string($5.lexeme) + " ] ");
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = { string($3.type), scope_counter, stoi(string($5.lexeme)), 1, countn+1 };
        curr_array = string($1.lexeme);
    } LBRACE ArrValues RBRACE SEMICOLON
    | ID COLON ID ASSIGN MAKE ID SEMICOLON {
        // Object creation: obj:ClassName = make ClassName;
        if(class_table.find(string($6.lexeme)) == class_table.end()){
            errorBuffer.push_back("Error: Class '" + string($6.lexeme) + "' not declared");
        }
        if(string($3.lexeme) != string($6.lexeme)){
            errorBuffer.push_back("Error: Type mismatch in object creation");
        }
        
        tac.push_back("- " + string($3.lexeme) + " " + string($1.lexeme));
        tac.push_back(string($1.lexeme) + " = make " + string($6.lexeme));
        
        variableDetails vd;
        vd.dataTypes = string($3.lexeme);
        vd.scope = scope_counter;
        vd.size = 0;
        vd.isArray = 0;
        vd.lineNumber = countn+1;
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = vd;
    }
    ;

DISCARDStatement:
    DISCARD ID SEMICOLON {
        if(check_declaration(string($2.lexeme))){
            string var_type = func_table[curr_func_name].symbol_table[string($2.lexeme)].dataTypes;
            // Check if it's a handle or object type
            if(var_type.find("HANDLE") != string::npos || class_table.find(var_type) != class_table.end()){
                tac.push_back("discard " + string($2.lexeme) + " " + var_type);
            } else {
                errorBuffer.push_back("Error: discard can only be used on handles or objects at line " + to_string(countn+1));
            }
        }
    }
    ;

HANDLEStatement:
    ID COLON HANDLE LT DataTypeG GT SEMICOLON {
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word");
        }
        char temp_type[100];
        sprintf(temp_type, "HANDLE[%s]", $5.type);
        tac.push_back("- " + string(temp_type) + " " + string($1.lexeme));
        
        variableDetails vd;
        vd.dataTypes = string(temp_type);
        vd.scope = scope_counter;
        vd.size = 0;
        vd.isArray = 0;
        vd.lineNumber = countn+1;
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = vd;
    }
    | ID COLON HANDLE LT DataTypeG GT ASSIGN MAKE HANDLE LT DataTypeG GT SEMICOLON {
        if(is_reserved_word(string($1.lexeme))){
            errorBuffer.push_back("Error: '" + string($1.lexeme) + "' is a reserved word");
        }
        char temp_type[100];
        sprintf(temp_type, "HANDLE[%s]", $5.type);
        tac.push_back("- " + string(temp_type) + " " + string($1.lexeme));
        tac.push_back(string($1.lexeme) + " = make " + string(temp_type));
        
        variableDetails vd;
        vd.dataTypes = string(temp_type);
        vd.scope = scope_counter;
        vd.size = 0;
        vd.isArray = 0;
        vd.lineNumber = countn+1;
        func_table[curr_func_name].symbol_table[string($1.lexeme)] = vd;
    }
    ;

ArrValues:   
    Literal {
        check_type(func_table[curr_func_name].symbol_table[curr_array].dataTypes, string($1.type));
        tac.push_back(curr_array + " [ " + to_string(arr_index++) + " ] = " + string($1.lexeme) + " " + func_table[curr_func_name].symbol_table[curr_array].dataTypes);
        if(arr_index > func_table[curr_func_name].symbol_table[curr_array].size){
            errorBuffer.push_back("Line no: " + to_string(func_table[curr_func_name].symbol_table[curr_array].lineNumber) + "error: too many initializers for ‘array [" + to_string(func_table[curr_func_name].symbol_table[curr_array].size) + "]’");
        }
    } COMMA ArrValues
    | Literal {
        check_type(func_table[curr_func_name].symbol_table[curr_array].dataTypes, string($1.type));
        tac.push_back(curr_array + " [ " + to_string(arr_index++) + " ] = " + string($1.lexeme) + " " + func_table[curr_func_name].symbol_table[curr_array].dataTypes);
        if(arr_index > func_table[curr_func_name].symbol_table[curr_array].size){
            errorBuffer.push_back("Line no: " + to_string(func_table[curr_func_name].symbol_table[curr_array].lineNumber) + "error: too many initializers for ‘array [" + to_string(func_table[curr_func_name].symbol_table[curr_array].size) + "]’");
        }
        arr_index=0;
    }
    ;
                   
ReplyStatement:
    REPLY EXPRESSION {
        check_type(func_table[curr_func_name].return_type, string($2.type));
        tac.push_back("return " + string($2.lexeme) + " " + func_table[curr_func_name].return_type);
        has_return_stmt = 1;
        if(const_temps.find(string($2.lexeme)) == const_temps.end() && $2.lexeme[0] == '@') free_temp.push(string($2.lexeme));
    }  
    ;

DataTypeG:   
    INT { strcpy($$.type, "INT"); }
    | FLOAT { strcpy($$.type, "FLOAT"); }
    | CHAR { strcpy($$.type, "CHAR"); }
    ;

EXPRESSION:
    EXPRESSION ADD EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION SUB EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION MUL EXPRESSION {
        add_tac($$, $1, $2, $3)
        string t0=get_temp();
        string t1=get_temp();
        string t2=get_temp();
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string c = string($3.lexeme);
        string dtype = string($$.type);
        
        tac.push_back(a + " = 0 " + dtype);
        tac.push_back(t0 + " = 0 " + dtype);
        tac.push_back(t2 + " = 1 " + dtype);
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t1 + " = " + t0 + " < " + c +  "  " + dtype);
        tac.push_back("if " + t1 + " GOTO " + "#L" + to_string(labelCount+1) + " else GOTO " + "#L" + to_string(labelCount+2));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(a + " = " + a + " + " + b +  "  " + dtype);
        tac.push_back(t0 + " = " + t0 + " + " + t2 +  "  " + dtype);
        tac.push_back("GOTO #L" + to_string(labelCount-1));
        tac.push_back("#L" + to_string(++labelCount) + ":");

        free_temp.push(t0);
        free_temp.push(t1);
        free_temp.push(t2);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION DIV EXPRESSION {
        add_tac($$, $1, $2, $3)
        string t0=get_temp();
        string t1=get_temp();
        string t2=get_temp();
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string c = string($3.lexeme);
        string dtype = string($$.type);
        
        tac.push_back(a + " = 0 " + dtype);
        tac.push_back(t0 + " = " + b + " " + dtype);
        tac.push_back(t2 + " = 1 " + dtype);
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t1 + " = " + t0 + " >= " + c +  "  " + dtype);
        tac.push_back("if " + t1 + " GOTO " + "#L" + to_string(labelCount+1) + " else GOTO " + "#L" + to_string(labelCount+2));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(a + " = " + a + " + " + t2 +  "  " + dtype);
        tac.push_back(t0 + " = " + t0 + " - " + c +  "  " + dtype);
        tac.push_back("GOTO #L" + to_string(labelCount-1));
        tac.push_back("#L" + to_string(++labelCount) + ":");

        free_temp.push(t0);
        free_temp.push(t1);
        free_temp.push(t2);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION LE EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION GE EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION LT EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION GT EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION EQ EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION NE EXPRESSION {
        add_tac($$, $1, $2, $3)
        string temp = get_temp();
        tac.push_back(temp + " = " + string($1.lexeme) + " == " + string($3.lexeme) + " " + string($$.type));
        tac.push_back(string($$.lexeme) + " = ~ " + temp + " " + string($$.type)); 

        free_temp.push(temp);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION AND EXPRESSION {
        add_tac($$, $1, $2, $3)
        string l0 = "#L" + to_string(++labelCount);
        string l1 = "#L" + to_string(++labelCount);
        string l2 = "#L" + to_string(++labelCount);
        string l3 = "#L" + to_string(++labelCount);
        string dtype = string($$.type);

        tac.push_back("if " + string($1.lexeme) + " GOTO " + l3 + " else GOTO " + l1);
        tac.push_back(l3 + ":");
        tac.push_back("if " + string($3.lexeme) + " GOTO " + l0 + " else GOTO " + l1);
        tac.push_back(l0 + ":");
        tac.push_back(string($$.lexeme) + " = 1 " + dtype);
        tac.push_back("GOTO " + l2);
        tac.push_back(l1 + ":");
        tac.push_back(string($$.lexeme) + " = 0 " + dtype);
        tac.push_back(l2 + ":");

        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION OR EXPRESSION {
        add_tac($$, $1, $2, $3)
        string l0 = "#L" + to_string(++labelCount);
        string l1 = "#L" + to_string(++labelCount);
        string l2 = "#L" + to_string(++labelCount);
        string l3 = "#L" + to_string(++labelCount);
        string dtype = string($$.type);

        tac.push_back("if " + string($1.lexeme) + " GOTO " + l0 + " else GOTO " + l3);
        tac.push_back(l3 + ":");
        tac.push_back("if " + string($3.lexeme) + " GOTO " + l0 + " else GOTO " + l1);
        tac.push_back(l0 + ":");
        tac.push_back(string($$.lexeme) + " = 1 " + dtype);
        tac.push_back("GOTO " + l2);
        tac.push_back(l1 + ":");
        tac.push_back(string($$.lexeme) + " = 0 " + dtype);
        tac.push_back(l2 + ":");

        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION MOD EXPRESSION {
        add_tac($$, $1, $2, $3)
        string t0=get_temp();
        string t1=get_temp();
        string t2=get_temp();
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string c = string($3.lexeme);
        string dtype = string($$.type);
        
        tac.push_back(a + " = 0 " + dtype);
        tac.push_back(t0 + " = " + b + " " + dtype);
        tac.push_back(t2 + " = 1 " + dtype);
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t1 + " = " + t0 + " >= " + c +  "  " + dtype);
        tac.push_back("if " + t1 + " GOTO " + "#L" + to_string(labelCount+1) + " else GOTO " + "#L" + to_string(labelCount+2));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t0 + " = " + t0 + " - " + c +  "  " + dtype);
        tac.push_back("GOTO #L" + to_string(labelCount-1));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(a + " = " + t0 +  "  " + dtype);

        free_temp.push(t0);
        free_temp.push(t1);
        free_temp.push(t2);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION BITAND EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION BITOR EXPRESSION {
        add_tac($$, $1, $2, $3)
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($3.lexeme) + " " + string($$.type));
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | EXPRESSION BITXOR EXPRESSION {
        add_tac($$, $1, $2, $3)
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string b_= get_temp();
        string c = string($3.lexeme);
        string c_= get_temp();

        tac.push_back(b_ + " = ~ " + b + " " + string($1.type));
        tac.push_back(c_ + " = ~ " + c + " " + string($3.type));
        string t1=get_temp();
        string t2=get_temp();
        tac.push_back(t1 + " = " + b + " & " + c_ + " " + string($$.type));
        tac.push_back(t2 + " = " + b_ + " & " + c + " " + string($$.type));
        tac.push_back(a + " = " + t1 + " | " + t2 + " " + string($$.type));

        free_temp.push(b_);
        free_temp.push(c_);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION LSHIFT EXPRESSION {
        add_tac($$, $1, $2, $3)
        string d = string($3.lexeme);
        string t3 = get_temp();
        string t4 = get_temp();
        string l0 = "#L" + to_string(++labelCount);
        string l1 = "#L" + to_string(++labelCount);
        string l2 = "#L" + to_string(++labelCount);

        string t0= get_temp();
        string t1= get_temp();
        string t2= get_temp();
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string c = get_temp();
        tac.push_back(c + " = 2 INT");
        string dtype = string($$.type);
        
        tac.push_back(t3 + " = 0 INT");
        tac.push_back(l2 + ":");
        tac.push_back(t4 + " = " + t3 + " < " + d + " INT");
        tac.push_back("\nif " + t4 + " GOTO " + l0 + " else GOTO " + l1);
        tac.push_back(l0 + ":");
        tac.push_back(a + " = 0 " + dtype);
        tac.push_back(t0 + " = 0 " + dtype);
        tac.push_back(t2 + " = 1 " + dtype);
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t1 + " = " + t0 + " < " + c +  "  " + dtype);
        tac.push_back("if " + t1 + " GOTO " + "#L" + to_string(labelCount+1) + " else GOTO " + "#L" + to_string(labelCount+2));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(a + " = " + a + " + " + b +  "  " + dtype);
        tac.push_back(t0 + " = " + t0 + " + " + t2 +  "  " + dtype);
        tac.push_back("GOTO #L" + to_string(labelCount-1));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back("GOTO " + l2);
        tac.push_back(l1 + ":");

        free_temp.push(t0);
        free_temp.push(t1);
        free_temp.push(t2);
        free_temp.push(t3);
        free_temp.push(t4);
        free_temp.push(c);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | EXPRESSION RSHIFT EXPRESSION {
        add_tac($$, $1, $2, $3)
        string d = string($3.lexeme);
        string t3 = get_temp();
        string t4 = get_temp();
        string l0 = "#L" + to_string(++labelCount);
        string l1 = "#L" + to_string(++labelCount);
        string l2 = "#L" + to_string(++labelCount);

        string t0=get_temp();
        string t1=get_temp();
        string t2=get_temp();
        string a = string($$.lexeme);
        string b = string($1.lexeme);
        string c = get_temp();
        tac.push_back(c + " = 2 INT");
        string dtype = string($$.type);
        
        tac.push_back(t3 + " = 0 INT");
        tac.push_back(l2 + ":");
        tac.push_back(t4 + " = " + t3 + " < " + d + " INT");
        tac.push_back("\nif " + t4 + " GOTO " + l0 + " else GOTO " + l1);
        tac.push_back(l0 + ":");
        tac.push_back(a + " = 0 " + dtype);
        tac.push_back(t0 + " = " + b + " " + dtype);
        tac.push_back(t2 + " = 1 " + dtype);
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(t1 + " = " + t0 + " >= " + c +  "  " + dtype);
        tac.push_back("if " + t1 + " GOTO " + "#L" + to_string(labelCount+1) + " else GOTO " + "#L" + to_string(labelCount+2));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back(a + " = " + a + " + " + t2 +  "  " + dtype);
        tac.push_back(t0 + " = " + t0 + " - " + c +  "  " + dtype);
        tac.push_back("GOTO #L" + to_string(labelCount-1));
        tac.push_back("#L" + to_string(++labelCount) + ":");
        tac.push_back("GOTO " + l2);
        tac.push_back(l1 + ":");

        free_temp.push(t0);
        free_temp.push(t1);
        free_temp.push(t2);
        free_temp.push(t3);
        free_temp.push(t4);
        free_temp.push(c);
        if(const_temps.find(string($1.lexeme)) == const_temps.end() && $1.lexeme[0] == '@') free_temp.push(string($1.lexeme));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));

        labelCount++;
    }
    | UnaryExpression {
        strcpy($$.type, $1.type);
        strcpy($$.type, $1.type);
        sprintf($$.lexeme, "%s", $1.lexeme);
    }
    | PrimaryExpression {
        strcpy($$.type, $1.type);
        strcpy($$.type, $1.type);
        strcpy($$.lexeme, $1.lexeme);
    }
    | PostfixExpression {
        strcpy($$.type, $1.type);
        sprintf($$.lexeme, "%s", $1.lexeme);
    }

PostfixExpression:
    FuncCall {
        strcpy($$.type, $1.type);
        sprintf($$.lexeme, "%s", $1.lexeme);
    }
    | ID DOT ID LPAR ArgList RPAR {
        // Method call: obj.method(args)
        check_declaration(string($1.lexeme));
        string obj_type = func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes;
        
        if(class_table.find(obj_type) == class_table.end()){
            errorBuffer.push_back("Error: '" + obj_type + "' is not a class type");
        }
        else if(class_table[obj_type].methods.find(string($3.lexeme)) == class_table[obj_type].methods.end()){
            errorBuffer.push_back("Error: Method '" + string($3.lexeme) + "' not found in class '" + obj_type + "'");
        }
        
        strcpy($$.type, class_table[obj_type].methods[string($3.lexeme)].return_type.c_str());
        sprintf($$.lexeme, get_temp().c_str());
        tac.push_back(string($$.lexeme) + " = @call " + string($1.lexeme) + "." + string($3.lexeme) + " " + string($$.type));
    }
    | ID LBRACK EXPRESSION RBRACK {
        if(check_declaration(string($1.lexeme)) && func_table[curr_func_name].symbol_table[string($1.lexeme)].isArray == 0) { 
            errorBuffer.push_back("Variable is not an array"); 
        }
        check_scope(string($1.lexeme));
        strcpy($$.type, func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes.c_str());
        sprintf($$.lexeme, get_temp().c_str());
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " [ " + string($3.lexeme) + " ] " + string($$.type));
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    ;
 
UnaryExpression:   
    UnaryOperator PrimaryExpression {
        strcpy($$.type, $2.type);
        sprintf($$.lexeme, get_temp().c_str());
        if(string($1.lexeme) == "~" || string($1.lexeme) == "-"){
            tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($2.lexeme) + " " + string($$.type));
        }
        else if(string($1.lexeme) == "+"){
            tac.push_back(string($$.lexeme) + " = " + string($2.lexeme) + " " + string($$.type));
        }
        else{
            tac.push_back(string($$.lexeme) + " = ~ " + string($2.lexeme) + " " + string($$.type));
        }
        if(const_temps.find(string($2.lexeme)) == const_temps.end() && $2.lexeme[0] == '@') free_temp.push(string($2.lexeme));
    }
    ;
 
PrimaryExpression:
    ID {
        // cout << "a";
        check_declaration(string($1.lexeme));
        // check_scope(string($1.lexeme));
        strcpy($$.type, func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes.c_str());
        strcpy($$.lexeme, $1.lexeme);
    }
    | ID DOT ID {
        // Member access: obj.field or obj.method
        check_declaration(string($1.lexeme));
        string obj_type = func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes;
        
        if(class_table.find(obj_type) == class_table.end()){
            errorBuffer.push_back("Error: '" + obj_type + "' is not a class/record type");
        }
        else if(class_table[obj_type].fields.find(string($3.lexeme)) == class_table[obj_type].fields.end()){
            errorBuffer.push_back("Error: Field '" + string($3.lexeme) + "' not found in class '" + obj_type + "'");
        }
        
        strcpy($$.type, class_table[obj_type].fields[string($3.lexeme)].dataTypes.c_str());
        sprintf($$.lexeme, get_temp().c_str());
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + "." + string($3.lexeme) + " " + string($$.type));
    }
    | Literal {
        strcpy($$.type, $1.type);
        string t=get_temp();
        sprintf($$.lexeme, t.c_str());
        tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($$.type)); 
        temp_map[string($1.lexeme)] = string($$.lexeme);
        const_temps.insert(t);
        // if(temp_map[string($1.lexeme)] == ""){
        //     string t=get_temp();
        //     sprintf($$.lexeme, t.c_str());
        //     tac.push_back(string($$.lexeme) + " = " + string($1.lexeme) + " " + string($$.type)); 
        //     temp_map[string($1.lexeme)] = string($$.lexeme);

        //     const_temps.insert(t);
        // }
        // else{
        //     //tac.push_back(temp_map[string($1.lexeme)] + " = " + string($1.lexeme) + " " + string($$.type)); 
        //     strcpy($$.lexeme, temp_map[string($1.lexeme)].c_str());
        // }
    }
    | LPAR EXPRESSION RPAR {
        strcpy($$.type, $2.type);
        strcpy($$.lexeme, $2.lexeme);
    }
    ;
 
UnaryOperator:
    ADD {  }
    | SUB {  }
    | NOT {  }
    | BITNOT {  }
    ;
 
Literal:
    INT_LITERAL {
        strcpy($$.type, "INT");
        strcpy($$.lexeme, $1.lexeme);
    }
    | FLOAT_LITERAL {
        strcpy($$.type, "FLOAT");
        strcpy($$.lexeme, $1.lexeme);
    }
    | CHAR_LITERAL {
        strcpy($$.type, "CHAR");
        strcpy($$.lexeme, $1.lexeme);
    }
    ;
                   
AssignmentStatement:
    ID ASSIGN EXPRESSION {
        check_type(func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes, string($3.type));
        check_declaration(string($1.lexeme));
        check_scope(string($1.lexeme));
        tac.push_back(string($1.lexeme) + " = " + string($3.lexeme) + " " + func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes);
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') free_temp.push(string($3.lexeme));
    }
    | ID DOT ID ASSIGN EXPRESSION {
        // Member field assignment: obj.field = value;
        check_declaration(string($1.lexeme));
        string obj_type = func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes;
        
        if(class_table.find(obj_type) == class_table.end()){
            errorBuffer.push_back("Error: '" + obj_type + "' is not a class/record type");
        }
        else {
            check_type(class_table[obj_type].fields[string($3.lexeme)].dataTypes, string($5.type));
            tac.push_back(string($1.lexeme) + "." + string($3.lexeme) + " = " + string($5.lexeme) + " " + class_table[obj_type].fields[string($3.lexeme)].dataTypes);
        }
        
        if(const_temps.find(string($5.lexeme)) == const_temps.end() && $5.lexeme[0] == '@') free_temp.push(string($5.lexeme));
    }
    | ID LBRACK EXPRESSION RBRACK ASSIGN EXPRESSION {
        check_type(func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes, string($6.type));
        if(check_declaration(string($1.lexeme)) && func_table[curr_func_name].symbol_table[string($1.lexeme)].isArray == 0) { 
            errorBuffer.push_back("Line no " + to_string(countn+1) + " : Variable is not an array"); 
        }
        check_scope(string($1.lexeme));
        tac.push_back(string($1.lexeme) + " [ " + string($3.lexeme) + " ] = " + string($6.lexeme) + " " + func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes);
        if(const_temps.find(string($6.lexeme)) == const_temps.end() && $6.lexeme[0] == '@') free_temp.push(string($6.lexeme));
    }
    ;

IFStatement:
    IF  {
        sprintf($1.parentNext, "#L%d", labelCount++);
    } LPAR EXPRESSION RPAR { 
        tac.push_back("if " + string($4.lexeme) + " GOTO #L" + to_string(labelCount) + " else GOTO #L" + to_string(labelCount+1));
        sprintf($4.if_body, "#L%d", labelCount++);
        sprintf($4.else_body, "#L%d", labelCount++); 
        tac.push_back(string($4.if_body) + ":");

        if(const_temps.find(string($4.lexeme)) == const_temps.end() && $4.lexeme[0] == '@') free_temp.push(string($4.lexeme));
    } LBRACE {
        scope_history.push(++scope_counter);  
    } StatementList RBRACE {  
        scope_history.pop(); 
        --scope_counter;
        tac.push_back("GOTO " + string($1.parentNext));
        tac.push_back(string($4.else_body) + ":");
    } ELSEIFStatement ELSEStatement {   
        tac.push_back(string($1.parentNext) + ":");
    }
    ;        

ELSEIFStatement:
    ELIF {
        string str = tac[tac.size()-2].substr(5);
        char* hold = const_cast<char*>(str.c_str());
        sprintf($1.parentNext, "%s", hold);
    } LPAR EXPRESSION RPAR {
        tac.push_back("if " + string($4.lexeme) + " GOTO #L" + to_string(labelCount) + " else GOTO #L" + to_string(labelCount+1));
        sprintf($4.if_body, "#L%d", labelCount++);
        sprintf($4.else_body, "#L%d", labelCount++); 
        tac.push_back(string($4.if_body) + ":");

        if(const_temps.find(string($4.lexeme)) == const_temps.end() && $4.lexeme[0] == '@') free_temp.push(string($4.lexeme));
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($1.parentNext));
        tac.push_back(string($4.else_body) + ":");
    } ELSEIFStatement  
    | {  }
    ;

ELSEStatement:
    ELSE LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE{
        scope_history.pop(); 
        --scope_counter;
    }
    | {  }
    ;       

SWITCHStatement:
    SWITCH {
        int temp_label = labelCount;
        loop_break.push(temp_label);
        sprintf($1.parentNext, "#L%d", labelCount++);
    } LPAR ID {
        temp_index = variableCount;
        tac.push_back("@t" + to_string(variableCount++) + " = " + string($4.lexeme) + " " + func_table[curr_func_name].symbol_table[string($4.lexeme)].dataTypes);
    } RPAR LBRACE CASEStatementList {
        // strcpy($8.id, $4.lexeme);
        // strcpy($8.parentNext, $1.parentNext);
    }
    DefaultStatement RBRACE {
        tac.push_back(string($1.parentNext) + ":");
        loop_break.pop();
    }
    ;

CASEStatementList:
    CASEStatement CASEStatementList {
        strcpy($1.id, $$.id);
        strcpy($1.parentNext, $$.parentNext);
    }
    | {  }
    ;

CASEStatement:
    CASE {
        // tac.push_back(string($4.if_body) + ":");
    } LPAR Literal {
        char* hold = const_cast<char*>(to_string(variableCount).c_str());
        sprintf($4.temp, "%s", hold);
        tac.push_back("@t" + to_string(variableCount++) + " = " + string($4.lexeme) + " " + string($4.type));
        tac.push_back("@t" + to_string(variableCount++) + " = " + "@t" + to_string(temp_index) + " == " + "@t" + string($4.temp) + " INT");
        tac.push_back("if @t" + to_string(variableCount-1) + " GOTO #L" + to_string(labelCount) + " else GOTO #L" + to_string(labelCount+1));
        tac.push_back("#L" + to_string(labelCount) + ":");
        sprintf($4.case_body, "#L%d", labelCount++);
        sprintf($4.parentNext, "#L%d", labelCount++);
    } RPAR COLON StatementList {
        tac.push_back(string($4.parentNext) + ":");
    }
    ;

DefaultStatement:
    DEFAULT COLON StatementList {  }
    | {  }
    ;                       

WHILEStatement:
    WHILE {
        sprintf($1.loop_body, "#L%d", labelCount); 
        loop_continue.push(labelCount++);
        tac.push_back("\n" + string($1.loop_body) + ":");
    } LPAR EXPRESSION RPAR {
        sprintf($4.if_body, "#L%d", labelCount++); 

        loop_break.push(labelCount);
        sprintf($4.else_body, "#L%d", labelCount++); 

        tac.push_back("\nif " + string($4.lexeme) + " GOTO " + string($4.if_body) + " else GOTO " + string($4.else_body));
        tac.push_back("\n" + string($4.if_body) + ":");

        if(const_temps.find(string($4.lexeme)) == const_temps.end() && $4.lexeme[0] == '@') free_temp.push(string($4.lexeme));
        
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($1.loop_body));
        tac.push_back("\n" + string($4.else_body) + ":");
        loop_continue.pop();
        loop_break.pop();
    }
    ;

LOOPWHILEStatement:
    LOOP WHILE {
        sprintf($2.loop_body, "#L%d", labelCount); 
        loop_continue.push(labelCount++);
        tac.push_back("\n" + string($2.loop_body) + ":");
    } EXPRESSION {
        sprintf($4.if_body, "#L%d", labelCount++); 

        loop_break.push(labelCount);
        sprintf($4.else_body, "#L%d", labelCount++); 

        tac.push_back("\nif " + string($4.lexeme) + " GOTO " + string($4.if_body) + " else GOTO " + string($4.else_body));
        tac.push_back("\n" + string($4.if_body) + ":");

        if(const_temps.find(string($4.lexeme)) == const_temps.end() && $4.lexeme[0] == '@') free_temp.push(string($4.lexeme));
        
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($2.loop_body));
        tac.push_back("\n" + string($4.else_body) + ":");
        loop_continue.pop();
        loop_break.pop();
    }
    ;

LOOPUNTILStatement:
    LOOP UNTIL {
        sprintf($2.loop_body, "#L%d", labelCount); 
        loop_continue.push(labelCount++);
        tac.push_back("\n" + string($2.loop_body) + ":");
    } EXPRESSION {
        sprintf($4.if_body, "#L%d", labelCount++); 

        loop_break.push(labelCount);
        sprintf($4.else_body, "#L%d", labelCount++); 

        tac.push_back("\nif " + string($4.lexeme) + " GOTO " + string($4.if_body) + " else GOTO " + string($4.else_body));
        tac.push_back("\n" + string($4.if_body) + ":");

        if(const_temps.find(string($4.lexeme)) == const_temps.end() && $4.lexeme[0] == '@') free_temp.push(string($4.lexeme));
        
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($2.loop_body));
        tac.push_back("\n" + string($4.else_body) + ":");
        loop_continue.pop();
        loop_break.pop();
    }
    ;

FORStatement:
    FOR LPAR AssignmentStatement SEMICOLON {
        sprintf($1.loop_body, "#L%d", labelCount++); 
        tac.push_back("\n" + string($1.loop_body) + ":");
    } EXPRESSION SEMICOLON {  
        sprintf($6.if_body, "#L%d", labelCount++); 
        loop_break.push(labelCount);
        sprintf($6.else_body, "#L%d", labelCount++); 
        tac.push_back("\nif " + string($6.lexeme) + " GOTO " + string($6.if_body) + " else GOTO " + string($6.else_body));
        sprintf($6.loop_body, "#L%d", labelCount); 
        loop_continue.push(labelCount++);
        tac.push_back("\n" + string($6.loop_body) + ":");
        if(const_temps.find(string($6.lexeme)) == const_temps.end() && $6.lexeme[0] == '@') free_temp.push(string($6.lexeme));
    } AssignmentStatement RPAR {
        tac.push_back("GOTO " + string($1.loop_body));
        tac.push_back("\n" + string($6.if_body) + ":");
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($6.loop_body));
        tac.push_back("\n" + string($6.else_body) + ":");
        loop_continue.pop();
        loop_break.pop();
    }
    ;

LOOPFROMStatement:
    LOOP FROM ID ASSIGN EXPRESSION TO {
        // Variable declaration
        tac.push_back("- INT " + string($3.lexeme));
        tac.push_back(string($3.lexeme) + " = " + string($5.lexeme) + " INT");
        sprintf($1.loop_body, "#L%d", labelCount++); 
        tac.push_back("\n" + string($1.loop_body) + ":");
        if(const_temps.find(string($5.lexeme)) == const_temps.end() && $5.lexeme[0] == '@') free_temp.push(string($5.lexeme));
    } EXPRESSION StepClause {
        sprintf($8.if_body, "#L%d", labelCount++); 
        loop_break.push(labelCount);
        sprintf($8.else_body, "#L%d", labelCount++); 
        
        string temp = get_temp();
        tac.push_back(temp + " = " + string($3.lexeme) + " <= " + string($8.lexeme) + " INT");
        tac.push_back("\nif " + temp + " GOTO " + string($8.if_body) + " else GOTO " + string($8.else_body));
        free_temp.push(temp);
        
        sprintf($8.loop_body, "#L%d", labelCount); 
        loop_continue.push(labelCount++);
        tac.push_back("\n" + string($8.loop_body) + ":");
        
        // Increment logic
        if(strlen($9.lexeme) > 0) {
            tac.push_back(string($3.lexeme) + " = " + string($3.lexeme) + " + " + string($9.lexeme) + " INT");
            if(const_temps.find(string($9.lexeme)) == const_temps.end() && $9.lexeme[0] == '@') free_temp.push(string($9.lexeme));
        } else {
            tac.push_back(string($3.lexeme) + " = " + string($3.lexeme) + " + 1 INT");
        }
        
        tac.push_back("GOTO " + string($1.loop_body));
        tac.push_back("\n" + string($8.if_body) + ":");
        if(const_temps.find(string($8.lexeme)) == const_temps.end() && $8.lexeme[0] == '@') free_temp.push(string($8.lexeme));
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        tac.push_back("GOTO " + string($8.loop_body));
        tac.push_back("\n" + string($8.else_body) + ":");
        loop_continue.pop();
        loop_break.pop();
    }
    ;


StepClause:
    STEP EXPRESSION {
        strcpy($$.lexeme, $2.lexeme);
    }
    | /* epsilon */ {
        strcpy($$.lexeme, "");
    }
    ;

BREAKStatement:
    BREAK SEMICOLON {
        if(!loop_break.empty()){
            tac.push_back("GOTO #L" + to_string(loop_break.top()));
        }
    }
    ;

CONTINUEStatement:
    CONTINUE SEMICOLON {
        if(!loop_continue.empty()){
            tac.push_back("GOTO #L" + to_string(loop_continue.top()));
        }
    }
    ;

INPUTStatement:
    INPUT LPAR ID RPAR SEMICOLON  {
        check_declaration($3.lexeme);
        tac.push_back("input " + string($3.lexeme) + " " + func_table[curr_func_name].symbol_table[string($3.lexeme)].dataTypes);
        // check_scope(string($3.lexeme));
    }
    | INPUT LPAR ID LBRACK EXPRESSION RBRACK RPAR SEMICOLON {
        check_declaration($3.lexeme);
        string temp = get_temp();
        tac.push_back("input " + temp + " " + func_table[curr_func_name].symbol_table[string($3.lexeme)].dataTypes);
        tac.push_back(string($3.lexeme) + " [ " + string($5.lexeme) + " ] = " + temp + " " + func_table[curr_func_name].symbol_table[string($3.lexeme)].dataTypes);
        free_temp.push(temp);
        // check_scope(string($3.lexeme));
    }
    ;

RESULTStatement:
    RESULT LPAR EXPRESSION RPAR SEMICOLON {
        tac.push_back("print " + string($3.lexeme) + " " + string($3.type));
    }
    | RESULT LPAR STRING_LITERAL RPAR SEMICOLON {
        tac.push_back("print " + string($3.lexeme) + " STR");
    }
    ;

FuncCall:
    ID {
        string func_name = string($1.lexeme);
        
        // Check if it's a library function
        bool is_lib_func = false;
        string lib_name = "";
        
        for(auto& [lib, funcs] : library_functions) {
            if(funcs.find(func_name) != funcs.end()) {
                is_lib_func = true;
                lib_name = lib;
                break;
            }
        }
        
        if(is_lib_func) {
            // Check if library is imported
            if(imported_libraries.find(lib_name) == imported_libraries.end()) {
                errorBuffer.push_back("Error: Function '" + func_name + 
                    "' from library '" + lib_name + "' used without importing. Add: import " + lib_name);
            } else {
                // Lazy load: parse library function and generate 3AC if not done
                string key = lib_name + "." + func_name;
                if(!available_lib_functions[key].is_loaded) {
                    load_library_function(lib_name, func_name);  // NEW FUNCTION
                    available_lib_functions[key].is_loaded = true;
                }
            }
        }
        func_call_id.push({string($1.lexeme), func_table[string($1.lexeme)].param_types});
    } LPAR ArgList RPAR {
        string func_name = string($1.lexeme);
        // recompute if this is a library function
        bool is_lib_func = false;
        string lib_name = "";
        for(auto& [lib, funcs] : library_functions) {
            if(funcs.find(func_name) != funcs.end()) {
                is_lib_func = true;
                lib_name = lib;
                break;
            }
        }

        strcpy($$.type, func_table[func_name].return_type.c_str());
        func_call_id.pop();

        // If the library loader already emitted a @call and recorded its temp, reuse it here
        if(is_lib_func) {
            string key = lib_name + "." + func_name;
            if(available_lib_functions[key].call_emitted && available_lib_functions[key].temp_name.size() > 0) {
                sprintf($$.lexeme, available_lib_functions[key].temp_name.c_str());
            } else {
                sprintf($$.lexeme, get_temp().c_str());
                tac.push_back(string($$.lexeme) + " = @call " + func_name + " " + func_table[func_name].return_type + " " + to_string(func_table[func_name].num_params));
            }
        } else {
            sprintf($$.lexeme, get_temp().c_str());
            tac.push_back(string($$.lexeme) + " = @call " + func_name + " " + func_table[func_name].return_type + " " + to_string(func_table[func_name].num_params));
        }
    }
    ;

ArgList:
    Arg COMMA ArgList {
        int sz = func_call_id.top().second.size();
        string type = func_call_id.top().second[sz-1];
        func_call_id.top().second.pop_back();
        if(type_check(string($1.type), type)) {
            errorBuffer.push_back("datatype for argument not matched in line " + to_string(countn+1));
        }
    }
    | Arg {
        int sz = func_call_id.top().second.size();
        string type = func_call_id.top().second[sz-1];
        func_call_id.top().second.pop_back();
        if(type_check(string($1.type), type)) {
            errorBuffer.push_back("datatype for argument not matched in line " + to_string(countn+1));
        }
    }
    | /* epsilon */ {  }
    ;

Arg:
    EXPRESSION {
        tac.push_back("Param " + string($1.lexeme) + " " + string($1.type));
    }
    ;

MatchStatement:
    MATCH LPAR EXPRESSION RPAR {
        sprintf($1.parentNext, "#L%d", labelCount++);
        strcpy($1.temp, get_temp().c_str());
        strcpy($1.type, $3.type);
        
        // Store match expression in temp
        tac.push_back(string($1.temp) + " = " + string($3.lexeme) + " " + string($3.type));
        
        if(const_temps.find(string($3.lexeme)) == const_temps.end() && $3.lexeme[0] == '@') 
            free_temp.push(string($3.lexeme));
    } LBRACE PatternArmList RBRACE {
        // End of match - add final label
        tac.push_back(string($1.parentNext) + ":");
        if(const_temps.find(string($1.temp)) == const_temps.end() && $1.temp[0] == '@') 
            free_temp.push(string($1.temp));
    }
    ;

PatternArmList:
    PatternArm PatternArmList {
        strcpy($$.temp, $1.temp);
        strcpy($$.type, $1.type);
        strcpy($$.parentNext, $1.parentNext);
        strcpy($2.temp, $1.temp);
        strcpy($2.type, $1.type);
        strcpy($2.parentNext, $1.parentNext);
    }
    | PatternArm {
        strcpy($$.temp, $1.temp);
        strcpy($$.type, $1.type);
        strcpy($$.parentNext, $1.parentNext);
    }
    ;

PatternArm:
    Pattern FATARROW {
        // Get match temp and type from parent
        strcpy($1.temp, $<node>0.temp);
        strcpy($1.type, $<node>0.type);
        strcpy($1.parentNext, $<node>0.parentNext);
        
        string comp_temp = get_temp();
        
        if(string($1.lexeme) == "_") {
            // Wildcard - always matches (default case)
            sprintf($2.case_body, "#L%d", labelCount++);
            tac.push_back(string($2.case_body) + ":");
            strcpy($2.else_body, "");
        } else {
            // Pattern matching comparison
            sprintf($2.case_body, "#L%d", labelCount++);
            sprintf($2.else_body, "#L%d", labelCount++);
            
            tac.push_back(comp_temp + " = " + string($1.temp) + " == " + string($1.lexeme) + " " + string($1.type));
            tac.push_back("if " + comp_temp + " GOTO " + string($2.case_body) + " else GOTO " + string($2.else_body));
            tac.push_back(string($2.case_body) + ":");
            
            free_temp.push(comp_temp);
        }
        
        strcpy($2.temp, $1.temp);
        strcpy($2.type, $1.type);
        strcpy($2.parentNext, $1.parentNext);
    } LBRACE {
        scope_history.push(++scope_counter);
    } StatementList RBRACE {
        scope_history.pop();
        --scope_counter;
        
        // Jump to end of match after executing this arm
        tac.push_back("GOTO " + string($2.parentNext));
        
        // Add else label (for next pattern to check)
        if(strlen($2.else_body) > 0) {
            tac.push_back(string($2.else_body) + ":");
        }
        
        strcpy($$.temp, $2.temp);
        strcpy($$.type, $2.type);
        strcpy($$.parentNext, $2.parentNext);
    }
    ;

Pattern:
    INT_LITERAL {
        strcpy($$.lexeme, $1.lexeme);
        strcpy($$.type, "INT");
    }
    | FLOAT_LITERAL {
        strcpy($$.lexeme, $1.lexeme);
        strcpy($$.type, "FLOAT");
    }
    | CHAR_LITERAL {
        strcpy($$.lexeme, $1.lexeme);
        strcpy($$.type, "CHAR");
    }
    | ID {
        check_declaration(string($1.lexeme));
        strcpy($$.lexeme, $1.lexeme);
        strcpy($$.type, func_table[curr_func_name].symbol_table[string($1.lexeme)].dataTypes.c_str());
    }
    | UNDERSCORE {
        strcpy($$.lexeme, "_");
        strcpy($$.type, "WILDCARD");
    }
    ;
%%

bool check_declaration(string variable){
    if(func_table[curr_func_name].symbol_table.find(variable) == func_table[curr_func_name].symbol_table.end()){
        errorBuffer.push_back("Variable not declared in line " + to_string(countn+1) + " before usage.");
        return false;
    }
    return true;
}

bool check_scope(string variable){
    int var_scope = func_table[curr_func_name].symbol_table[variable].scope;
    // int curr_scope = scope_counter;
    stack<int> temp_stack(scope_history);
    // cout << "variable: " << variable << endl;
    // cout << "var_scope: " << var_scope << endl;
    // PrintStack(temp_stack);
    // cout << endl;
    while(!temp_stack.empty()){
        if(temp_stack.top() == var_scope){
            return true;
        }
        temp_stack.pop();
    }
    errorBuffer.push_back("Scope of variable '" + variable +"' not matching in line " + to_string(countn+1) + ".");
    return true;
}

bool multiple_declaration(string variable){
    if(!(func_table[curr_func_name].symbol_table.find(variable) == func_table[curr_func_name].symbol_table.end())){
        errorBuffer.push_back("redeclaration of '" + variable + "' in line " + to_string(countn+1));
        return true;
    }
    return false;
}

bool check_type(string l, string r){
    if(r == "FLOAT" && l == "CHAR"){
        errorBuffer.push_back("Cannot convert type FLOAT to CHAR in line " + to_string(countn+1));
        return false;
    }
    if(l == "FLOAT" && r == "CHAR"){
        errorBuffer.push_back("Cannot convert typr CHAR to FLOAT in line " + to_string(countn+1));
        return false;
    }
    return true;
}

bool is_reserved_word(string id){
    for(auto &item: id){
        item = tolower(item);
    }
    auto iterator = find(reserved.begin(), reserved.end(), id);
    if(iterator != reserved.end()){
        errorBuffer.push_back("usage of reserved keyword '" + id + "' in line " + to_string(countn+1));
        return true;
    }
    return false;
}

bool type_check(string type1, string type2) {
    if((type1 == "FLOAT" and type2 == "CHAR") or (type1 == "CHAR" and type2 == "FLOAT")) {
        return true;
    }
    return false;
}

void yyerror(const char* msg) {
    errorBuffer.push_back("syntax error in line " + to_string(countn+1));
    for(auto item: errorBuffer)
        cout << item << endl;
    fprintf(stderr, "%s\n", msg);
    exit(1);
}

string get_temp(){
    if(free_temp.empty()){
        return "@t" + to_string(variableCount++);
    }
    string t=free_temp.front();
    free_temp.pop(); 
    return t; 
}

void PrintStack(stack<int> s) {
    if(s.empty())
        return;
    int x = s.top();
    s.pop();
    cout << x << ' ';
    PrintStack(s);
    s.push(x);
}

// In main() or before yyparse()
void init_library_registry() {
    // math.rcblib
    library_functions["math"] = {"abs", "max", "min", "pow", "sqrt", "sin", "cos", "tan", "rand", "randint", "srand"};
    // strings.rcblib
    library_functions["strings"] = {"len", "upper", "lower", "split", "join", "replace", "find", "trim", "reverse"};
    // io.rcblib
    // library_functions["io"] = {"args", "input", "result"};
    // term.rcblib
    library_functions["term"] = {"curs_set", "clear", "move_cursor", "get_size", "refresh", "raw", "noecho", "echo", "keypad", "get_wch"};
    // files.rcblib
    library_functions["files"] = {"exists", "readlines", "writelines"};
    // Mark all as not loaded initially
    for(auto& [lib, funcs] : library_functions) {
        for(auto& fn : funcs) {
            available_lib_functions[lib + "." + fn] = {lib, fn, "", {}, false, "", false};
        }
    }
}


/* void init_library_registry() {
    // math.rcblib
    library_functions["math"] = {"abs", "max", "min", "pow", "sqrt", "sin", "cos", "tan", "rand", "randint", "srand"};
    // strings.rcblib
    library_functions["strings"] = {"len", "upper", "lower", "split", "join", "replace", "find", "trim", "reverse"};
    // io.rcblib
    library_functions["io"] = {"args", "input", "result"};
    // term.rcblib
    library_functions["term"] = {"curs_set", "clear", "move_cursor", "get_size", "refresh", "raw", "noecho", "echo", "keypad", "get_wch"};
    // files.rcblib
    library_functions["files"] = {"exists", "readlines", "writelines"};
} */

void load_library_function(string lib_name, string func_name) {
    // DUMMY IMPLEMENTATION - just register function signatures
    string key = lib_name + "." + func_name;

    if(lib_name == "math") {
        if(func_name == "abs") {
            func_table["abs"] = {"INT", 1, {"INT"}, {}};
            /* tac.push_back("# Library function: math.abs loaded (stub)"); */
            // Emit a representative @call line at load-time and record its temp
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call abs INT 1");
        } else if(func_name == "sqrt") {
            func_table["sqrt"] = {"FLOAT", 1, {"FLOAT"}, {}};
            /* tac.push_back("# Library function: math.sqrt loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call sqrt FLOAT 1");
        } else if(func_name == "pow") {
            func_table["pow"] = {"INT", 2, {"INT", "INT"}, {}};
            /* tac.push_back("# Library function: math.pow loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call pow INT 2");
        } else if(func_name == "max") {
            func_table["max"] = {"INT", 2, {"INT", "INT"}, {}};
            /* tac.push_back("# Library function: math.max loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call max INT 2");
        } else if(func_name == "min") {
            func_table["min"] = {"INT", 2, {"INT", "INT"}, {}};
            /* tac.push_back("# Library function: math.min loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call min INT 2");
        }
    } else if(lib_name == "strings") {
        if(func_name == "len") {
            func_table["len"] = {"INT", 1, {"STRING"}, {}};
            /* tac.push_back("# Library function: strings.len loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call len INT 1");
        } else if(func_name == "upper") {
            func_table["upper"] = {"STRING", 1, {"STRING"}, {}};
            /* tac.push_back("# Library function: strings.upper loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call upper STRING 1");
        } else if(func_name == "lower") {
            func_table["lower"] = {"STRING", 1, {"STRING"}, {}};
            /* tac.push_back("# Library function: strings.lower loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call lower STRING 1");
        }
    } 
    // else if(lib_name == "io") {
    //     if(func_name == "result") {
    //         func_table["result"] = {"void", 1, {"STRING"}, {}};
    //         /* tac.push_back("# Library function: io.result loaded (stub)"); */
    //         string t = get_temp();
    //         available_lib_functions[key].temp_name = t;
    //         available_lib_functions[key].call_emitted = true;
    //         tac.push_back(t + " = @call result void 1");
    //     } else if(func_name == "input") {
    //         func_table["input"] = {"STRING", 1, {"STRING"}, {}};
    //         /* tac.push_back("# Library function: io.input loaded (stub)"); */
    //         string t = get_temp();
    //         available_lib_functions[key].temp_name = t;
    //         available_lib_functions[key].call_emitted = true;
    //         tac.push_back(t + " = @call input STRING 1");
    //     }
    // } 
    else if(lib_name == "term") {
        if(func_name == "clear") {
            func_table["clear"] = {"void", 0, {}, {}};
            /* tac.push_back("# Library function: term.clear loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call clear void 0");
        } else if(func_name == "move_cursor") {
            func_table["move_cursor"] = {"void", 2, {"INT", "INT"}, {}};
            /* tac.push_back("# Library function: term.move_cursor loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call move_cursor void 2");
        }
    } else if(lib_name == "files") {
        if(func_name == "exists") {
            func_table["exists"] = {"INT", 1, {"STRING"}, {}};
            /* tac.push_back("# Library function: files.exists loaded (stub)"); */
            string t = get_temp();
            available_lib_functions[key].temp_name = t;
            available_lib_functions[key].call_emitted = true;
            tac.push_back(t + " = @call exists INT 1");
        }
    }
}


int main(int argc, char *argv[]) {
    /* yydebug = 1; */
    init_library_registry();
    yyparse();
    for(auto item: errorBuffer){
        cout << item << endl;
    }
    if(errorBuffer.size() > 0)
        exit(0);
    for(auto x: tac)
        cout << x << endl;
    return 0;
}