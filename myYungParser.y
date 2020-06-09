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
%token <str> LOWER_THAN_ELSE
%nonassoc LOWER_THAN_ELSE
%nonassoc KEYWORD_ELSE

%type <str> expr
%type <str> var
%type <str> data_types
%type <str> const
%type <str> instruction
%type <str> assign_instr
%type <str> complex_instr
%type <str> func_input
%type <str> funcs
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

%start input

%left OR_OP
%left AND_OP
%left EQUAL_OP NOTEQUAL_OP '<' LESSEQUAL_OP
%left '-' '+'
%left '*' '/' '%'
%right POWER_OP
%right SIGN_OP
%right NOT_OP

%%
 input: body
   {
      if (yyerror_count == 0) {
         //h math xrhsimopoihtai gia thn pow() kai thn fmod() kai xreiazetai thn entolh gcc -std=c99 -Wall -lm
         puts("#include <math.h>\n");
         puts(c_prologue);
         printf("%s\n", $1); 
      }
 };

 var:
     KEYWORD_VAR identifiers  ':'  data_types ';'  {$$ = template("%s %s;\n", $4, $2);}
    |KEYWORD_VAR IDENTIFIER'['INTEGER']' ':' data_types ';'  {$$ = template("%s %s[%s];\n", $7, $2, $4);}
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
    KEYWORD_CONST assigned_identifiers ':' data_types ';' {$$ = template("const %s %s;\n", $4, $2);}
    ;

 data_types:
     KEYWORD_BOOLEAN {$$ = template("int");}
    |KEYWORD_NUMBER  {$$ = template("double");}
    |KEYWORD_STRING  {$$ = template("char*");}
    |KEYWORD_VOID    {$$ = template("void");}
    ;

 funcs:
     KEYWORD_FUNCTION IDENTIFIER '('params')' ':' data_types '{' func_body '}' ';'          {$$ = template("%s %s (%s) {\n%s};\n", $7, $2, $4, $9);}
    |KEYWORD_FUNCTION IDENTIFIER '('params')' ':' '[' ']' data_types '{' func_body '}' ';'  {$$ = template("%s* %s (%s) {\n%s};\n", $9, $2, $4, $11);}
    |KEYWORD_FUNCTION IDENTIFIER '('params')' '{' func_body '}' ';'                         {$$ = template("void %s (%s) {\n%s};\n", $2, $4, $7);}
    ;

 params:
     IDENTIFIER ':' data_types                   {$$ = template("%s %s", $3, $1);}
    |IDENTIFIER '['']' ':' data_types            {$$ = template("%s* %s", $5, $1);}
    |IDENTIFIER ':' data_types ',' params        {$$ = template("%s %s, %s", $3, $1, $5);}
    |IDENTIFIER '['']' ':' data_types ',' params {$$ = template("%s* %s, %s", $5, $1, $7);}
    ;

 func_body:
     var func_body                {$$ = template("%s%s", $1, $2);}
    |const func_body              {$$ = template("%s%s", $1, $2);}
    |instruction func_body        {$$ = template("%s%s", $1, $2);}
    |%empty                       {$$ = template("");}             
    ;

 expr:
     NOT_OP expr                 {$$ = template("NOT %s", $2);}
    |'+' expr %prec SIGN_OP      {$$ = template("+%s", $2);}
    |'-' expr %prec SIGN_OP      {$$ = template("-%s", $2);}
    |expr POWER_OP expr          {$$ = template("pow(%s, %s)", $1, $3);}
    |expr '*' expr               {$$ = template("%s * %s", $1, $3);}
    |expr '/' expr               {$$ = template("%s / %s", $1, $3);}
    |expr '%' expr               {$$ = template("fmod(%s, %s)", $1, $3);}
    |expr '+' expr               {$$ = template("%s + %s", $1, $3);}
    |expr '-' expr               {$$ = template("%s - %s", $1, $3);}
    |expr EQUAL_OP expr          {$$ = template("%s == %s", $1, $3);}
    |expr NOTEQUAL_OP expr       {$$ = template("%s != %s", $1, $3);}
    |expr '<' expr               {$$ = template("%s < %s", $1, $3);}
    |expr LESSEQUAL_OP expr      {$$ = template("%s <= %s", $1, $3);}
    |expr AND_OP expr            {$$ = template("%s && %s", $1, $3);}
    |expr OR_OP expr             {$$ = template("%s | %s", $1, $3);}
    |'('expr')'                  {$$ = template("(%s)", $2);} 
    |func_call                   {$$ = $1;}
    |literals                    {$$ = $1;}
    |IDENTIFIER                  {$$ = $1;}
    |IDENTIFIER'['INTEGER']'     {$$ = template("%s[%s]", $1, $3);}
    ;

 literals:
     STRING       {$$ = $1;}
    |INTEGER      {$$ = $1;}
    |NUMBER       {$$ = $1;}
    |BOOL_FALSE   {$$ = template("0");}
    |BOOL_TRUE    {$$ = template("1");}
    |KEYWORD_NULL {$$ = template("null");}
    ;

//Den evala erwthmatiko sthn if kai sthn for giati akolouthhsa tous kanones miniScript opws perigrafontai sto pdf kai pou antistoixoun sthn C99.
//Ta paradeigmata px prime.ms exoun erwthmatiko opote den pernane kai einai logiko opws anaferw apo panw kai sto paradoteo prime.ms den exei erwthmatiko.
//Sthn while to exw afhsei gia na deiksw oti den exei megalh diafora alla sthn C99 den exei.
 instruction:
     assign_instr ';'                                                    {$$ = template("%s;\n", $1);}
    |KEYWORD_IF '('expr')' stmt %prec LOWER_THAN_ELSE                    {$$ = template("if (%s) %s\n", $3, $5);}
    |KEYWORD_IF '('expr')' stmt KEYWORD_ELSE  stmt                       {$$ = template("if (%s) %s else %s\n", $3, $5, $7);}
    |KEYWORD_FOR '('assign_instr ';' assign_instr ')' stmt               {$$ = template("for (%s ; %s ; %s) %s\n", $3, $5, $7);}
    |KEYWORD_FOR '('assign_instr ';' expr ';' assign_instr ')' stmt      {$$ = template("for (%s ; %s ; %s) %s\n", $3, $5, $7, $9);}
    |KEYWORD_WHILE '(' expr ')' stmt ';'                                 {$$ = template("while ( %s ) %s\n", $3, $5);}
    |KEYWORD_BREAK ';'                                                   {$$ = template("break;\n");}
    |KEYWORD_CONTINUE ';'                                                {$$ = template("continue;\n");}
    |KEYWORD_RETURN ';'                                                  {$$ = template("return;\n");}
    |KEYWORD_RETURN expr ';'                                             {$$ = template("return %s;\n", $2);}
    |func_call ';'                                                       {$$ = template("%s;\n", $1);}
    ;

 instr_list:
     instruction               {$$ = $1;}
    |instruction instr_list    {$$ = template("%s %s", $1, $2);}
    ;

 complex_instr:
    '{' instr_list '}'  {$$ = template("{\n%s\n}", $2);}
    ;
    
 assign_instr:
    IDENTIFIER '=' expr  {$$ = template("%s = %s", $1, $3);}
    ;

 func_call:
    IDENTIFIER'('func_input ')' {$$ = template("%s(%s)", $1, $3);}
    ;

 func_input:
    %empty                {$$ = template("");}
    |expr ',' func_input  {$$ = template("%s , %s", $1, $3);}
    |expr                 {$$ = $1;}
    ;

 stmt:
    instruction   {$$ = template("{\n%s\n}", $1);}
   |complex_instr {$$ = $1;}
   ;

 func_start:
   //C99  warning: return type of ‘main’ is not ‘int’ [-Wmain]
    KEYWORD_FUNCTION KEYWORD_START '(' ')' ':' KEYWORD_VOID '{' func_body '}' {$$ = template("int main() {\n%s}\n", $8);}
    ;

 body:
   %empty             {$$ = template("\n");}
   |body const        {$$ = template("%s%s", $1, $2);}
   |body var          {$$ = template("%s%s", $1, $2);}
   |body funcs        {$$ = template("%s%s", $1, $2);}
   |body func_start   {$$ = template("%s%s", $1, $2);}
   ;

%%
int main(){
    if (yyparse() == 0)
        printf("//Grammatically Accepted!\n");
    else{
        printf("//Grammatically Rejected!\n");
    }
}