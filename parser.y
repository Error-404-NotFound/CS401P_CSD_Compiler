%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

int yylex(void);
void yyerror(const char* s);
extern FILE* yyin;

/* ---------- three-address & backpatching helpers ---------- */

typedef struct List { int addr; struct List* next; } List;

typedef struct Node {
  char val[128];
  char type[64];
  bool isPostfix;
  List *tlist, *flist, *nlist;
} Node;

static int lbl = 0;
static int code_i = 0;
static char code[20000][128];

static char* newtmp(void){
  static char b[64];
  sprintf(b,"t%d",lbl++);
  return strdup(b);
}

static List* mklist(int a){
  List* x = (List*)malloc(sizeof(List));
  x->addr = a; x->next = NULL;
  return x;
}
static List* merge(List* a, List* b){
  if(!a) return b; if(!b) return a;
  List* t=a; while(t->next) t=t->next; t->next=b; return a;
}
static void backpatch(List* l, int target){
  for(; l; l=l->next){
    int n = strlen(code[l->addr]);
    sprintf(code[l->addr]+n,"%d",target);
  }
}

/* ---------- symbol tables with scope ---------- */

typedef struct Sym {
  char* name;
  char* type;
  int   width;
  int   offset;
  struct Sym* next;
} Sym;

typedef struct Table {
  Sym* head;
  struct Table* next; /* for scope stack */
} Table;

static Table* scope = NULL;
static Table* alltabs[1024];
static int tabc = 0;
static int curr_offset = 0;
static int offstack[1024], offsp=0;

static Table* push_scope(void){
  Table* t = (Table*)calloc(1,sizeof(Table));
  t->next = scope; scope = t;
  alltabs[tabc++] = t;
  offstack[offsp++] = curr_offset; curr_offset = 0;
  return t;
}
static void pop_scope(void){
  if(!scope) return;
  scope = scope->next;
  curr_offset = offstack[--offsp];
}
static Sym* lookup(const char* name){
  for(Table* t=scope; t; t=t->next){
    for(Sym* s=t->head; s; s=s->next)
      if(strcmp(s->name,name)==0) return s;
  }
  return NULL;
}
static Sym* insert(const char* name, const char* type, int width){
  Sym* prev = NULL;
  for(Sym* s=scope->head; s; s=s->next)
    if(strcmp(s->name,name)==0) return NULL; /* redecl in this scope */
  Sym* s = (Sym*)calloc(1,sizeof(Sym));
  s->name=strdup(name); s->type=strdup(type); s->width=width;
  s->offset = curr_offset; curr_offset += width;
  s->next = scope->head; scope->head = s;
  return s;
}

/* ---------- type helpers ---------- */

static int width_of(const char* t){
  if(strcmp(t,"int")==0) return 4;
  if(strcmp(t,"float")==0) return 4;
  if(strcmp(t,"char")==0) return 1;
  /* arrays like array(n,type): width = n*width(type). We keep it simple here. */
  if(strncmp(t,"array(",6)==0){
    int n=0; char base[64]; base[0]=0;
    sscanf(t,"array(%d,%63[^)])",&n,base);
    return n*width_of(base);
  }
  return 4;
}
static char* max_type(const char* a, const char* b){
  if(strcmp(a,"float")==0 || strcmp(b,"float")==0) return "float";
  return "int";
}
static char* widen(const char* v, const char* from, const char* to){
  if(strcmp(from,to)==0) return (char*)v;
  if(strcmp(from,"int")==0 && strcmp(to,"float")==0){
    char* t=newtmp();
    sprintf(code[code_i++], "%s = (float) %s\n", t, v);
    return t;
  }
  return (char*)v; /* others omitted for brevity */
}

/* ---------- temp holders ---------- */

static char decl_type[64]="";
static char collected[256][64];
static int  coln=0;

static void print_tables(void){
  printf("-------------- Symbol Tables --------------\n");
  int k=1;
  for(int i=0;i<tabc;i++){
    Table* t = alltabs[i];
    printf("\nTable %d\n", k++);
    printf("+----------------+----------------+--------+\n");
    printf("| Name           | Type           | Offset |\n");
    printf("+----------------+----------------+--------+\n");
    for(Sym* s=t->head; s; s=s->next)
      printf("| %-14s | %-14s | %6d |\n", s->name, s->type, s->offset);
    printf("+----------------+----------------+--------+\n");
  }
  printf("\n");
}
%}

/* ---------- Bison declarations ---------- */

%union{
  char* s;
  int   i;
  struct Node* n;
  struct List* list;
}

%token <s> INT FLOAT CHAR IF ELSE WHILE T F
%token <s> ID NUM
%token <s> INC DEC PEQ MEQ SEQ DEQ
%token <s> GTE LTE EE NE AND OR NOT GT LT
%token <s> EQ PL MI ST DV MD
%token <s> SC CM LP RP LB RB LS RS

%type  <n> program stmt stmt_list expr assign control term
%type  <s> type asop incdec optsign
%type  <s> arrtail
%type  <i> M N

%left OR
%left AND
%nonassoc EE NE
%left GTE LTE GT LT
%right NOT
%left PL MI
%left ST DV MD
%nonassoc INC DEC
%nonassoc ELSE

%%

program
  : { push_scope(); } stmt_list
    {
      backpatch($2->nlist, code_i);
      print_tables();
      printf("----- Intermediate Code -----\n\n");
      for(int i=0;i<code_i;i++) printf("%3d:\t%s", i, code[i]);
      printf("\n");
    }
  ;

stmt_list
  : stmt_list M stmt
    {
      backpatch($1->nlist, $2);
      Node* r = (Node*)calloc(1,sizeof(Node));
      r->nlist = $3->nlist;
      $$ = r;
    }
  | stmt
    {
      Node* r = (Node*)calloc(1,sizeof(Node));
      r->nlist = $1->nlist;
      $$ = r;
    }
  ;

stmt
  : assign SC       { $$ = $1; }
  | control         { $$ = $1; }
  | type decllist SC
    {
      /* insert collected identifiers with decl_type */
      for(int i=0;i<coln;i++){
        if(!insert(collected[i], decl_type, width_of(decl_type))){
          fprintf(stderr,"Rejected - redeclaration of '%s'\n", collected[i]);
        }
      }
      coln=0; decl_type[0]=0;
      Node* r=(Node*)calloc(1,sizeof(Node)); $$=r;
    }
  | LB { push_scope(); } stmt_list RB
    {
      pop_scope();
      Node* r=(Node*)calloc(1,sizeof(Node));
      r->nlist = $3->nlist; $$=r;
    }
  | SC { Node* r=(Node*)calloc(1,sizeof(Node)); $$=r; }
  ;

type
  : INT    { strcpy(decl_type,"int");   $$=$1; }
  | FLOAT  { strcpy(decl_type,"float"); $$=$1; }
  | CHAR   { strcpy(decl_type,"char");  $$=$1; }
  ;

decllist
  : decllist CM ID arrtail optinit
    { strcpy(collected[coln++], $3); /* arrays handled in optinit */ }
  | ID arrtail optinit
    { strcpy(collected[coln++], $1); }
  ;

arrtail
  : /* empty */     { $$=""; }
  | LS NUM RS arrtail
    {
      /* fold: array(n, decl_type...) */
      static char tmp[64];
      if($4 && $4[0])
        snprintf(tmp,sizeof(tmp),"array(%d,%s)", atoi($2), $4);
      else
        snprintf(tmp,sizeof(tmp),"array(%d,%s)", atoi($2), decl_type);
      strcpy(decl_type, tmp);
      $$ = decl_type;
    }
  ;

optinit
  : /* empty */
  | EQ expr
    {
      /* generate assign after declaration */
      char* t = newtmp();
      if(strcmp(decl_type,$2->type)!=0){
        sprintf(code[code_i++], "%s = (%s) %s\n", t, decl_type, $2->val);
        sprintf(code[code_i++], "%s = %s\n", collected[coln-1], t);
      }else{
        sprintf(code[code_i++], "%s = %s\n", collected[coln-1], $2->val);
      }
    }
  ;

/* -------- control flow ---------- */

control
  : IF LP expr RP M stmt ELSE N M stmt
    {
      backpatch($3->tlist, $5);
      backpatch($3->flist, $9);
      Node* r=(Node*)calloc(1,sizeof(Node));
      r->nlist = merge( merge($6->nlist, mklist($8)), $10->nlist );
      $$=r;
    }
  | IF LP expr RP M stmt
    {
      backpatch($3->tlist, $5);
      Node* r=(Node*)calloc(1,sizeof(Node));
      r->nlist = merge($3->flist, $6->nlist);
      $$=r;
    }
  | WHILE M LP expr RP M stmt
    {
      backpatch($7->nlist, $2);
      backpatch($4->tlist, $6);
      sprintf(code[code_i++], "goto %d\n", $2);
      Node* r=(Node*)calloc(1,sizeof(Node));
      r->nlist = $4->flist; $$=r;
    }
  ;

M : { $$ = code_i; }
  ;

N : { $$ = code_i; sprintf(code[code_i++],"goto "); }
  ;

/* -------- assignments & expressions ---------- */

assign
  : expr asop expr
    {
      /* lvalue check: forbid const on left */
      char* endp=NULL; strtod($1->val,&endp);
      if(endp && *endp=='\0'){
        fprintf(stderr,"Rejected - cannot assign to constant\n");
      }
      char* rhs = $3->val;
      if(strcmp($1->type,$3->type)!=0){
        char* t=newtmp();
        sprintf(code[code_i++], "%s = (%s) %s\n", t, $1->type, $3->val);
        rhs=t;
      }
      if(strlen($2)>1){ /* +=, -=, ... */
        char* t=newtmp();
        sprintf(code[code_i++], "%s = %s %c %s\n", t, $1->val, $2[0], rhs);
        sprintf(code[code_i++], "%s = %s\n", $1->val, t);
      }else{
        sprintf(code[code_i++], "%s = %s\n", $1->val, rhs);
      }
      Node* r=(Node*)calloc(1,sizeof(Node)); $$=r;
    }
  ;

asop
  : EQ  { $$=$1; }
  | PEQ { $$=$1; }
  | MEQ { $$=$1; }
  | SEQ { $$=$1; }
  | DEQ { $$=$1; }
  ;

expr
  : expr PL expr
    {
      char* t=max_type($1->type,$3->type);
      char* a=widen($1->val,$1->type,t);
      char* b=widen($3->val,$3->type,t);
      char* r=newtmp();
      sprintf(code[code_i++], "%s = %s + %s\n", r,a,b);
      Node* n=(Node*)calloc(1,sizeof(Node));
      strcpy(n->val,r); strcpy(n->type,t); $$=n;
    }
  | expr MI expr
    {
      char* t=max_type($1->type,$3->type);
      char* a=widen($1->val,$1->type,t);
      char* b=widen($3->val,$3->type,t);
      char* r=newtmp();
      sprintf(code[code_i++], "%s = %s - %s\n", r,a,b);
      Node* n=(Node*)calloc(1,sizeof(Node));
      strcpy(n->val,r); strcpy(n->type,t); $$=n;
    }
  | expr ST expr
    {
      char* t=max_type($1->type,$3->type);
      char* a=widen($1->val,$1->type,t);
      char* b=widen($3->val,$3->type,t);
      char* r=newtmp();
      sprintf(code[code_i++], "%s = %s * %s\n", r,a,b);
      Node* n=(Node*)calloc(1,sizeof(Node));
      strcpy(n->val,r); strcpy(n->type,t); $$=n;
    }
  | expr DV expr
    {
      char* t=max_type($1->type,$3->type);
      char* a=widen($1->val,$1->type,t);
      char* b=widen($3->val,$3->type,t);
      char* r=newtmp();
      sprintf(code[code_i++], "%s = %s / %s\n", r,a,b);
      Node* n=(Node*)calloc(1,sizeof(Node));
      strcpy(n->val,r); strcpy(n->type,t); $$=n;
    }
  | expr MD expr
    {
      char* t=max_type($1->type,$3->type);
      char* a=widen($1->val,$1->type,t);
      char* b=widen($3->val,$3->type,t);
      char* r=newtmp();
      sprintf(code[code_i++], "%s = %s %% %s\n", r,a,b);
      Node* n=(Node*)calloc(1,sizeof(Node));
      strcpy(n->val,r); strcpy(n->type,t); $$=n;
    }

  /* relational -> boolean lists */
  | expr GTE expr { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s >= %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }
  | expr LTE expr { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s <= %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }
  | expr GT expr  { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s > %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }
  | expr LT expr  { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s < %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }
  | expr EE expr  { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s == %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }
  | expr NE expr  { Node* n=calloc(1,sizeof(Node));
      sprintf(code[code_i++],"if %s != %s goto ", $1->val,$3->val);
      sprintf(code[code_i++],"goto ");
      n->tlist = mklist(code_i-2); n->flist = mklist(code_i-1); $$=n; }

  | expr AND M expr
    {
      backpatch($1->tlist, $3);
      Node* n=calloc(1,sizeof(Node));
      n->tlist = $4->tlist;
      n->flist = merge($1->flist, $4->flist);
      $$=n;
    }
  | expr OR  M expr
    {
      backpatch($1->flist, $3);
      Node* n=calloc(1,sizeof(Node));
      n->tlist = merge($1->tlist, $4->tlist);
      n->flist = $4->flist;
      $$=n;
    }
  | NOT expr
    {
      Node* n=calloc(1,sizeof(Node));
      n->tlist = $2->flist; n->flist = $2->tlist; $$=n;
    }
  | T { Node* n=calloc(1,sizeof(Node)); sprintf(code[code_i++],"goto ");
        n->tlist=mklist(code_i-1); $$=n; }
  | F { Node* n=calloc(1,sizeof(Node)); sprintf(code[code_i++],"goto ");
        n->flist=mklist(code_i-1); $$=n; }

  | LP expr RP { $$=$2; }
  | term       { $$=$1; }
  ;

term
  : optsign ID incdec
    {
      Sym* s = lookup($2);
      if(!s){ fprintf(stderr,"variable '%s' not declared\n",$2); }
      char* t=newtmp();
      if(strlen($1)==0){ /* +id++ / id-- etc handled here as postfix on id */
        sprintf(code[code_i++], "%s = %s\n", t, $2);
        sprintf(code[code_i++], "%s = %s %c 1\n", $2, t, $3[0]);
      }else{
        /* -(id++) : store old value then negate, then apply inc/dec to id */
        char* tt=newtmp();
        sprintf(code[code_i++], "%s = %s\n", tt, $2);
        sprintf(code[code_i++], "%s = %s%s\n", t, $1, tt);
        sprintf(code[code_i++], "%s = %s %c 1\n", $2, tt, $3[0]);
      }
      Node* n=calloc(1,sizeof(Node));
      strcpy(n->val,t); strcpy(n->type,s?s->type:"int"); n->isPostfix=true; $$=n;
    }
  | optsign incdec ID
    {
      Sym* s = lookup($3);
      if(!s){ fprintf(stderr,"variable '%s' not declared\n",$3); }
      char* t=newtmp();
      char* tt=newtmp();
      sprintf(code[code_i++], "%s = %s %c 1\n", tt, $3, $2[0]); /* pre inc/dec */
      sprintf(code[code_i++], "%s = %s\n", $3, tt);
      sprintf(code[code_i++], "%s = %s%s\n", t, $1, tt);
      Node* n=calloc(1,sizeof(Node));
      strcpy(n->val,t); strcpy(n->type,s?s->type:"int"); n->isPostfix=true; $$=n;
    }
  | optsign ID
    {
      Sym* s = lookup($2);
      if(!s){ fprintf(stderr,"variable '%s' not declared\n",$2); }
      char* t=newtmp();
      if(strlen($1)==0){
        Node* n=calloc(1,sizeof(Node));
        strcpy(n->val,$2); strcpy(n->type,s?s->type:"int"); $$=n;
      }else{
        sprintf(code[code_i++], "%s = %s%s\n", t, $1, $2);
        Node* n=calloc(1,sizeof(Node)); strcpy(n->val,t); strcpy(n->type,s?s->type:"int"); $$=n;
      }
    }
  | optsign NUM
    {
      char* t=newtmp();
      if(strlen($1)==0){
        Node* n=calloc(1,sizeof(Node)); strcpy(n->val,$2); strcpy(n->type,"int"); $$=n;
      }else{
        sprintf(code[code_i++], "%s = %s%s\n", t, $1, $2);
        Node* n=calloc(1,sizeof(Node)); strcpy(n->val,t); strcpy(n->type,"int"); $$=n;
      }
    }
  ;

optsign
  : MI   { $$=$1; }
  | /* empty */ { $$=""; }
  ;

incdec
  : INC { $$=$1; }
  | DEC { $$=$1; }
  ;

%%

void yyerror(const char* s){
  fprintf(stderr,"Rejected - %s\n", s);
}

int main(int argc, char** argv){
  if(argc!=2){ fprintf(stderr,"Usage: %s <input>\n", argv[0]); return 1; }
  FILE* f=fopen(argv[1],"r"); if(!f){ perror("open"); return 1; }
  yyin=f;
  push_scope(); /* global scope */
  yyparse();
  fclose(f);
  return 0;
}
