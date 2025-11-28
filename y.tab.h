#ifndef YY_parser_h_included
#define YY_parser_h_included
/*#define YY_USE_CLASS 
*/
#line 1 "/usr/share/bison++/bison.h"
/* before anything */
#ifdef c_plusplus
 #ifndef __cplusplus
  #define __cplusplus
 #endif
#endif


 #line 8 "/usr/share/bison++/bison.h"

#line 139 "parser.y"
typedef union{
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
} yy_parser_stype;
#define YY_parser_STYPE yy_parser_stype
#ifndef YY_USE_CLASS
#define YYSTYPE yy_parser_stype
#endif

#line 21 "/usr/share/bison++/bison.h"
 /* %{ and %header{ and %union, during decl */
#ifndef YY_parser_COMPATIBILITY
 #ifndef YY_USE_CLASS
  #define  YY_parser_COMPATIBILITY 1
 #else
  #define  YY_parser_COMPATIBILITY 0
 #endif
#endif

#if YY_parser_COMPATIBILITY != 0
/* backward compatibility */
 #ifdef YYLTYPE
  #ifndef YY_parser_LTYPE
   #define YY_parser_LTYPE YYLTYPE
/* WARNING obsolete !!! user defined YYLTYPE not reported into generated header */
/* use %define LTYPE */
  #endif
 #endif
/*#ifdef YYSTYPE*/
  #ifndef YY_parser_STYPE
   #define YY_parser_STYPE YYSTYPE
  /* WARNING obsolete !!! user defined YYSTYPE not reported into generated header */
   /* use %define STYPE */
  #endif
/*#endif*/
 #ifdef YYDEBUG
  #ifndef YY_parser_DEBUG
   #define  YY_parser_DEBUG YYDEBUG
   /* WARNING obsolete !!! user defined YYDEBUG not reported into generated header */
   /* use %define DEBUG */
  #endif
 #endif 
 /* use goto to be compatible */
 #ifndef YY_parser_USE_GOTO
  #define YY_parser_USE_GOTO 1
 #endif
#endif

/* use no goto to be clean in C++ */
#ifndef YY_parser_USE_GOTO
 #define YY_parser_USE_GOTO 0
#endif

#ifndef YY_parser_PURE

 #line 65 "/usr/share/bison++/bison.h"

#line 65 "/usr/share/bison++/bison.h"
/* YY_parser_PURE */
#endif


 #line 68 "/usr/share/bison++/bison.h"

#line 68 "/usr/share/bison++/bison.h"
/* prefix */

#ifndef YY_parser_DEBUG

 #line 71 "/usr/share/bison++/bison.h"
#define YY_parser_DEBUG 1

#line 71 "/usr/share/bison++/bison.h"
/* YY_parser_DEBUG */
#endif

#ifndef YY_parser_LSP_NEEDED

 #line 75 "/usr/share/bison++/bison.h"

#line 75 "/usr/share/bison++/bison.h"
 /* YY_parser_LSP_NEEDED*/
#endif

/* DEFAULT LTYPE*/
#ifdef YY_parser_LSP_NEEDED
 #ifndef YY_parser_LTYPE
  #ifndef BISON_YYLTYPE_ISDECLARED
   #define BISON_YYLTYPE_ISDECLARED
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;
  #endif

  #define YY_parser_LTYPE yyltype
 #endif
#endif

/* DEFAULT STYPE*/
#ifndef YY_parser_STYPE
 #define YY_parser_STYPE int
#endif

/* DEFAULT MISCELANEOUS */
#ifndef YY_parser_PARSE
 #define YY_parser_PARSE yyparse
#endif

#ifndef YY_parser_LEX
 #define YY_parser_LEX yylex
#endif

#ifndef YY_parser_LVAL
 #define YY_parser_LVAL yylval
#endif

#ifndef YY_parser_LLOC
 #define YY_parser_LLOC yylloc
#endif

#ifndef YY_parser_CHAR
 #define YY_parser_CHAR yychar
#endif

#ifndef YY_parser_NERRS
 #define YY_parser_NERRS yynerrs
#endif

#ifndef YY_parser_DEBUG_FLAG
 #define YY_parser_DEBUG_FLAG yydebug
#endif

#ifndef YY_parser_ERROR
 #define YY_parser_ERROR yyerror
#endif

#ifndef YY_parser_PARSE_PARAM
 #ifndef __STDC__
  #ifndef __cplusplus
   #ifndef YY_USE_CLASS
    #define YY_parser_PARSE_PARAM
    #ifndef YY_parser_PARSE_PARAM_DEF
     #define YY_parser_PARSE_PARAM_DEF
    #endif
   #endif
  #endif
 #endif
 #ifndef YY_parser_PARSE_PARAM
  #define YY_parser_PARSE_PARAM void
 #endif
#endif

/* TOKEN C */
#ifndef YY_USE_CLASS

 #ifndef YY_parser_PURE
  #ifndef yylval
   extern YY_parser_STYPE YY_parser_LVAL;
  #else
   #if yylval != YY_parser_LVAL
    extern YY_parser_STYPE YY_parser_LVAL;
   #else
    #warning "Namespace conflict, disabling some functionality (bison++ only)"
   #endif
  #endif
 #endif


 #line 169 "/usr/share/bison++/bison.h"
#define	INT	258
#define	FLOAT	259
#define	CHAR	260
#define	STRING	261
#define	VOID	262
#define	REPLY	263
#define	IF	264
#define	ELIF	265
#define	ELSE	266
#define	WHILE	267
#define	FOR	268
#define	BREAK	269
#define	CONTINUE	270
#define	SWITCH	271
#define	CASE	272
#define	DEFAULT	273
#define	RESULT	274
#define	INPUT	275
#define	INT_LITERAL	276
#define	FLOAT_LITERAL	277
#define	ID	278
#define	LE	279
#define	GE	280
#define	EQ	281
#define	NE	282
#define	GT	283
#define	LT	284
#define	AND	285
#define	OR	286
#define	NOT	287
#define	ASSIGN	288
#define	ADD	289
#define	SUB	290
#define	MUL	291
#define	DIV	292
#define	MOD	293
#define	BITAND	294
#define	BITOR	295
#define	BITXOR	296
#define	BITNOT	297
#define	LSHIFT	298
#define	RSHIFT	299
#define	SEMICOLON	300
#define	COMMA	301
#define	COLON	302
#define	LBRACE	303
#define	RBRACE	304
#define	LPAR	305
#define	RPAR	306
#define	LBRACK	307
#define	RBRACK	308
#define	STRING_LITERAL	309
#define	CHAR_LITERAL	310
#define	FUNC	311
#define	ARROW	312
#define	LOOP	313
#define	FROM	314
#define	TO	315
#define	STEP	316
#define	UNTIL	317
#define	MATCH	318
#define	UNDERSCORE	319
#define	FATARROW	320
#define	CLASS	321
#define	PUBLIC	322
#define	PRIVATE	323
#define	RECORD	324
#define	DOT	325
#define	MAKE	326
#define	DISCARD	327
#define	HANDLE	328
#define	IMPORT	329
#define	GLOBAL	330


#line 169 "/usr/share/bison++/bison.h"
 /* #defines token */
/* after #define tokens, before const tokens S5*/
#else
 #ifndef YY_parser_CLASS
  #define YY_parser_CLASS parser
 #endif

 #ifndef YY_parser_INHERIT
  #define YY_parser_INHERIT
 #endif

 #ifndef YY_parser_MEMBERS
  #define YY_parser_MEMBERS 
 #endif

 #ifndef YY_parser_LEX_BODY
  #define YY_parser_LEX_BODY  
 #endif

 #ifndef YY_parser_ERROR_BODY
  #define YY_parser_ERROR_BODY  
 #endif

 #ifndef YY_parser_CONSTRUCTOR_PARAM
  #define YY_parser_CONSTRUCTOR_PARAM
 #endif
 /* choose between enum and const */
 #ifndef YY_parser_USE_CONST_TOKEN
  #define YY_parser_USE_CONST_TOKEN 0
  /* yes enum is more compatible with flex,  */
  /* so by default we use it */ 
 #endif
 #if YY_parser_USE_CONST_TOKEN != 0
  #ifndef YY_parser_ENUM_TOKEN
   #define YY_parser_ENUM_TOKEN yy_parser_enum_token
  #endif
 #endif

class YY_parser_CLASS YY_parser_INHERIT
{
public: 
 #if YY_parser_USE_CONST_TOKEN != 0
  /* static const int token ... */
  
 #line 212 "/usr/share/bison++/bison.h"
static const int INT;
static const int FLOAT;
static const int CHAR;
static const int STRING;
static const int VOID;
static const int REPLY;
static const int IF;
static const int ELIF;
static const int ELSE;
static const int WHILE;
static const int FOR;
static const int BREAK;
static const int CONTINUE;
static const int SWITCH;
static const int CASE;
static const int DEFAULT;
static const int RESULT;
static const int INPUT;
static const int INT_LITERAL;
static const int FLOAT_LITERAL;
static const int ID;
static const int LE;
static const int GE;
static const int EQ;
static const int NE;
static const int GT;
static const int LT;
static const int AND;
static const int OR;
static const int NOT;
static const int ASSIGN;
static const int ADD;
static const int SUB;
static const int MUL;
static const int DIV;
static const int MOD;
static const int BITAND;
static const int BITOR;
static const int BITXOR;
static const int BITNOT;
static const int LSHIFT;
static const int RSHIFT;
static const int SEMICOLON;
static const int COMMA;
static const int COLON;
static const int LBRACE;
static const int RBRACE;
static const int LPAR;
static const int RPAR;
static const int LBRACK;
static const int RBRACK;
static const int STRING_LITERAL;
static const int CHAR_LITERAL;
static const int FUNC;
static const int ARROW;
static const int LOOP;
static const int FROM;
static const int TO;
static const int STEP;
static const int UNTIL;
static const int MATCH;
static const int UNDERSCORE;
static const int FATARROW;
static const int CLASS;
static const int PUBLIC;
static const int PRIVATE;
static const int RECORD;
static const int DOT;
static const int MAKE;
static const int DISCARD;
static const int HANDLE;
static const int IMPORT;
static const int GLOBAL;


#line 212 "/usr/share/bison++/bison.h"
 /* decl const */
 #else
  enum YY_parser_ENUM_TOKEN { YY_parser_NULL_TOKEN=0
  
 #line 215 "/usr/share/bison++/bison.h"
	,INT=258
	,FLOAT=259
	,CHAR=260
	,STRING=261
	,VOID=262
	,REPLY=263
	,IF=264
	,ELIF=265
	,ELSE=266
	,WHILE=267
	,FOR=268
	,BREAK=269
	,CONTINUE=270
	,SWITCH=271
	,CASE=272
	,DEFAULT=273
	,RESULT=274
	,INPUT=275
	,INT_LITERAL=276
	,FLOAT_LITERAL=277
	,ID=278
	,LE=279
	,GE=280
	,EQ=281
	,NE=282
	,GT=283
	,LT=284
	,AND=285
	,OR=286
	,NOT=287
	,ASSIGN=288
	,ADD=289
	,SUB=290
	,MUL=291
	,DIV=292
	,MOD=293
	,BITAND=294
	,BITOR=295
	,BITXOR=296
	,BITNOT=297
	,LSHIFT=298
	,RSHIFT=299
	,SEMICOLON=300
	,COMMA=301
	,COLON=302
	,LBRACE=303
	,RBRACE=304
	,LPAR=305
	,RPAR=306
	,LBRACK=307
	,RBRACK=308
	,STRING_LITERAL=309
	,CHAR_LITERAL=310
	,FUNC=311
	,ARROW=312
	,LOOP=313
	,FROM=314
	,TO=315
	,STEP=316
	,UNTIL=317
	,MATCH=318
	,UNDERSCORE=319
	,FATARROW=320
	,CLASS=321
	,PUBLIC=322
	,PRIVATE=323
	,RECORD=324
	,DOT=325
	,MAKE=326
	,DISCARD=327
	,HANDLE=328
	,IMPORT=329
	,GLOBAL=330


#line 215 "/usr/share/bison++/bison.h"
 /* enum token */
     }; /* end of enum declaration */
 #endif
public:
 int YY_parser_PARSE(YY_parser_PARSE_PARAM);
 virtual void YY_parser_ERROR(char *msg) YY_parser_ERROR_BODY;
 #ifdef YY_parser_PURE
  #ifdef YY_parser_LSP_NEEDED
   virtual int  YY_parser_LEX(YY_parser_STYPE *YY_parser_LVAL,YY_parser_LTYPE *YY_parser_LLOC) YY_parser_LEX_BODY;
  #else
   virtual int  YY_parser_LEX(YY_parser_STYPE *YY_parser_LVAL) YY_parser_LEX_BODY;
  #endif
 #else
  virtual int YY_parser_LEX() YY_parser_LEX_BODY;
  YY_parser_STYPE YY_parser_LVAL;
  #ifdef YY_parser_LSP_NEEDED
   YY_parser_LTYPE YY_parser_LLOC;
  #endif
  int YY_parser_NERRS;
  int YY_parser_CHAR;
 #endif
 #if YY_parser_DEBUG != 0
  public:
   int YY_parser_DEBUG_FLAG;	/*  nonzero means print parse trace	*/
 #endif
public:
 YY_parser_CLASS(YY_parser_CONSTRUCTOR_PARAM);
public:
 YY_parser_MEMBERS 
};
/* other declare folow */
#endif


#if YY_parser_COMPATIBILITY != 0
 /* backward compatibility */
 /* Removed due to bison problems
 /#ifndef YYSTYPE
 / #define YYSTYPE YY_parser_STYPE
 /#endif*/

 #ifndef YYLTYPE
  #define YYLTYPE YY_parser_LTYPE
 #endif
 #ifndef YYDEBUG
  #ifdef YY_parser_DEBUG 
   #define YYDEBUG YY_parser_DEBUG
  #endif
 #endif

#endif
/* END */

 #line 267 "/usr/share/bison++/bison.h"
#endif
