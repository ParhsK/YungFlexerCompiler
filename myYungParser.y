%{
    #include <stdio.h>
    #include "cgen.h"
   
    extern int yylex(void);
    extern int lineNum;
%}

%union{
    char* str;
}

%define parse.error verbose
%token <str> IDENTIFIER
%token <str> NUMBER
%token <str> STRING
%token <str> INTEGER

%token <str> KEYWORD_NUMBER
%token <str> KEYWORD_FOR
%token <str> KEYWORD_START
%token <str> KEYWORD_BOOLEAN
%token <str> KEYWORD_VAR
%token <str> KEYWORD_WHILE
%token <str> KEYWORD_STRING
%token <str> KEYWORD_CONST
%token <str> KEYWORD_FUNCTION
%token <str> KEYWORD_VOID
%token <str> KEYWORD_IF
%token <str> KEYWORD_BREAK
%token <str> KEYWORD_RETURN
%token <str> BOOL_TRUE
%token <str> BOOL_FALSE
%token <str> KEYWORD_CONTINUE
%token <str> KEYWORD_NULL
%token <str> KEYWORD_ELSE
%token <str> AND_OP
%token <str> OR_OP
%token <str> NOT_OP
%token <str> POWER_OP
%token <str> EQUAL_OP
%token <str> NOTEQUAL_OP
%token <str> LESSEQUAL_OP
%token <str> LESS_OP
%token <str> LCB
%token <str> RCB

%type <str> input
%start input
%type <str> expr
%type <str> var
%type <str> data_types
%type <str> const
%type <str> instruction
%type <str> assign_instr
%type <str> complex_instr
%type <str> func_input
%type <str> funcs
%type <str> array
%type <str> identifiers
%type <str> literals
%type <str> assigned_identifiers
%type <str> params
%type <str> func_body
%type <str> func_call
%type <str> instr_list
%type <str> func_start
%type <str> body
%type <str> stmt

%left OR_OP
%left AND_OP
%left EQUAL_OP NOTEQUAL_OP LESS_OP LESSEQUAL_OP
%left '-' '+'
%left '*' '/' '%'
%right POWER_OP
%right SIGN_OP
%right NOT_OP

%%
input: body {
   if (yyerror_count == 0) {
    // puts(c_prologue);
    printf("Expression: %s\n", $1); 
   }
 };

 var:
    KEYWORD_VAR identifiers  ':'  data_types ';'         {$$ = template("var %s : %s;", $2, $4);}
    ;

 identifiers:
     IDENTIFIER                   {$$ = $1;}
    |IDENTIFIER '=' expr          {$$ = template("%s = %s", $1, $3);}
    |IDENTIFIER ',' identifiers   {$$ = template("%s , %s", $1, $3);}
    |IDENTIFIER '=' expr ',' identifiers   {$$ = template("%s = %s , %s", $1, $3, $5);}
    ;

 assigned_identifiers:
     IDENTIFIER '=' expr      {$$ = template("%s = %s", $1, $3);}
    |IDENTIFIER '=' expr ',' assigned_identifiers   {$$ = template("%s = %s , %s", $1, $3, $5);}
    ;

 const:
    KEYWORD_CONST assigned_identifiers ':' data_types ';' {$$ = template("const %s : %s;", $2, $4);}
    ;

 data_types:
     KEYWORD_BOOLEAN {$$ = template("boolean");}
    |KEYWORD_NUMBER  {$$ = template("double");}
    |KEYWORD_STRING  {$$ = template("string");}
    |KEYWORD_VOID    {$$ = template("void");}
    ;

 array:
    KEYWORD_VAR IDENTIFIER'['INTEGER']' ':' data_types    {$$ = template("var %s[%s] : %s", $2, $4, $7);}
    ;

 funcs:
     KEYWORD_FUNCTION IDENTIFIER '('params')' ':' data_types LCB func_body RCB           {$$ = template("function %s (%s) : %s { %s };", $2, $4, $7, $9);}
    |KEYWORD_FUNCTION IDENTIFIER '('params')' ':' '[' ']' data_types LCB func_body RCB   {$$ = template("function %s (%s) : [] %s { %s };", $2, $4, $9, $11);}
    |KEYWORD_FUNCTION IDENTIFIER '('params')' LCB func_body RCB                          {$$ = template("function %s (%s) { %s };", $1, $2, $4, $7);}
    ;

 params:
     IDENTIFIER ':' data_types                   {$$ = template("%s : %s;", $1, $3);}
    |IDENTIFIER '['']' ':' data_types            {$$ = template("%s[] : %s;", $1, $5);}
    |IDENTIFIER ':' data_types ',' params        {$$ = template("%s : %s , %s;", $1, $3, $5);}
    |IDENTIFIER '['']' ':' data_types ',' params {$$ = template("%s[] : %s , %s;", $1, $5, $7);}
    ;

 func_body:
     var func_body                {$$ = template("%s %s", $1, $2);}
    |const func_body              {$$ = template("%s %s", $1, $2);}
    |instruction func_body        {$$ = template("%s %s", $1, $2);}
    |%empty                       {$$ = template("");}             
    ;

 expr:
     NOT_OP expr                 {$$ = template("NOT %s", $2);}
    |'+' expr %prec SIGN_OP      {$$ = template("+%s", $2);}
    |'-' expr %prec SIGN_OP      {$$ = template("-%s", $2);}
    |expr POWER_OP expr          {$$ = template("%s ** %s", $1, $3);}
    |expr '*' expr               {$$ = template("%s * %s", $1, $3);}
    |expr '/' expr               {$$ = template("%s / %s", $1, $3);}
    |expr '%' expr               {$$ = template("%s % %s", $1, $3);}
    |expr '+' expr               {$$ = template("%s + %s", $1, $3);}
    |expr '-' expr               {$$ = template("%s - %s", $1, $3);}
    |expr EQUAL_OP expr          {$$ = template("%s == %s", $1, $3);}
    |expr NOTEQUAL_OP expr       {$$ = template("%s != %s", $1, $3);}
    |expr LESS_OP expr           {$$ = template("%s < %s", $1, $3);}
    |expr LESSEQUAL_OP expr      {$$ = template("%s <= %s", $1, $3);}
    |expr AND_OP expr            {$$ = template("%s && %s", $1, $3);}
    |expr OR_OP expr             {$$ = template("%s | %s", $1, $3);}
    |'('expr')'                  {$$ = template("(%s)", $2);} 
    |func_call                   {$$ = $1;}
    |literals                    {$$ = $1;}
    |IDENTIFIER                  {$$ = $1;}
    |array                       {$$ = $1;}
    ;

 literals:
     STRING       {$$ = $1;}
    |INTEGER      {$$ = $1;}
    |NUMBER       {$$ = $1;}
    |BOOL_FALSE   {$$ = $1;}
    |BOOL_TRUE    {$$ = $1;}
    |KEYWORD_NULL {$$ = $1;}
    ;

 instruction:
     assign_instr                                                        {$$ = $1;}
    //|KEYWORD_IF '('expr')' instruction KEYWORD_ELSE instruction          {$$ = template("if ( %s ) %s %s %s", $3, $5, $6, $7);}
    //|KEYWORD_IF '('expr')' instruction KEYWORD_ELSE complex_instr        {$$ = template("if ( %s ) %s %s %s", $3, $5, $6, $7);}
    //|KEYWORD_IF '('expr')' complex_instr KEYWORD_ELSE instruction        {$$ = template("if ( %s ) %s %s %s", $3, $5, $6, $7);}
    //|KEYWORD_IF '('expr')' complex_instr KEYWORD_ELSE complex_instr      {$$ = template("if ( %s ) %s %s %s", $3, $5, $6, $7);}
    |KEYWORD_IF '('expr')' stmt KEYWORD_ELSE stmt                        {$$ = template("if ( %s ) %s %s %s", $3, $5, $6, $7);} 
    |KEYWORD_IF '('expr')' stmt                                          {$$ = template("if ( %s ) %s", $3, $5);}
    |KEYWORD_FOR '('assign_instr ';' assign_instr ')' stmt               {$$ = template("for (%s ; %s ; %s) %s", $3, $5, $7);}
    |KEYWORD_FOR '('assign_instr ';' expr ';' assign_instr ')' stmt      {$$ = template("for (%s ; %s ; %s) %s", $3, $5, $7, $9);}
    |KEYWORD_WHILE '(' expr ')' stmt                                     {$$ = template("while ( %s ) %s", $3, $5);}
    |KEYWORD_BREAK ';'                                                   {$$ = template("break;");}
    |KEYWORD_CONTINUE ';'                                                {$$ = template("continue;");}
    |KEYWORD_RETURN ';'                                                  {$$ = template("return;");}
    |KEYWORD_RETURN expr ';'                                             {$$ = template("return %s;", $2);}
    |func_call ';'                                                       {$$ = template("%s;", $1);}
    ;
 
 instr_list:
     instruction               {$$ = $1;}
    |instruction instr_list    {$$ = template("%s %s", $1, $2);}
    ;

 complex_instr:
    LCB instr_list RCB {$$ = template("{ %s }", $2);}
    ;
    
 assign_instr:
    IDENTIFIER '=' expr ';'  {$$ = template("%s = %s;", $1, $3);}
    ;

 func_call:
    IDENTIFIER'('func_input ')' {$$ = template("%s ( %s )", $1, $3);}
    ;

 func_input:
    %empty                       {$$ = template("");}
    |expr ',' func_input  {$$ = template("%s , %s", $1, $3);}
    |expr                        {$$ = $1;}
    ;

 stmt:
    instruction   {$$ = $1;}
   |complex_instr {$$ = $1;}
   ;

 func_start:
    KEYWORD_FUNCTION KEYWORD_START '(' ')' ':' KEYWORD_VOID complex_instr {$$ = template("%s %s() : %s %s", $1, $2, $6, $7);}
    ;

 body:
   %empty             {$$ = template("");}
   |const input       {$$ = template("%s %s", $1, $2);}
   |var input         {$$ = template("%s %s", $1, $2);}
   |funcs input       {$$ = template("%s %s", $1, $2);}
   |func_start input  {$$ = template("%s %s", $1, $2);}
   |';' input         {$$ = template("; %s", $2);}
   ;

%%
int main(){
    if (yyparse() == 0)
        printf("Grammatically Accepted!\n");
    else
        printf("Grammatically Rejected!\n");
}