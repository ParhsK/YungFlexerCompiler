%{

#include <stdio.h>
#include <string.h>
#include <math.h>
#include "cgen.h"
#include "myYungParser.tab.h"

 
int line_num = 1;

%}

ID         [a-zA-Z_][0-9a-zA-Z_]*
DIGIT      [0-9]
DIGIT_POS  [1-9]
INTEGER    {DIGIT_POS}{DIGIT}*|{DIGIT}
DECIMAL    [+-]?{INTEGER}("."{INTEGER})?
NUMBER     {DECIMAL}([eE][+-]?{INTEGER})?
CHARACTER  [a-zA-Z0-9\-+\*\/:_$!#@&~^()., ]|[\\n]|[\\t]|[\\r]|[\\\\]|[\\\']|[\\\"]
STRING     \"{CHARACTER}*\"|\'{CHARACTER}*\'


%x comment

%%

number       return KEYWORD_NUMBER;
for          return KEYWORD_FOR;
start        return KEYWORD_START;
boolean      return KEYWORD_BOOLEAN;
var          return KEYWORD_VAR;
while        return KEYWORD_WHILE;
string       return KEYWORD_STRING;
const        return KEYWORD_CONST;
function     return KEYWORD_FUNCTION;
void         return KEYWORD_VOID;
if           return KEYWORD_IF;
break        return KEYWORD_BREAK;
return       return KEYWORD_RETURN;
true         return BOOL_TRUE;
false        return BOOL_FALSE;
continue     return KEYWORD_CONTINUE;
null         return KEYWORD_NULL;
else         return KEYWORD_ELSE;  

and          return AND_OP;
or           return OR_OP;
not          return NOT_OP;

{ID}        { yylval.str = strdup(yytext);   return IDENTIFIER; }     
{INTEGER}   { yylval.str = strdup(yytext);   return INTEGER; }
{NUMBER}    { yylval.str = strdup(yytext);   return NUMBER; }
{STRING}    { yylval.str = strdup(yytext);   return STRING; }

"+"          return '+';
"-"          return '-';
"*"          return '*';
"/"          return '/';
"%"          return '%';
"**"         return POWER_OP;
"=="         return EQUAL_OP;
"!="         return NOTEQUAL_OP;
"<="         return LESSEQUAL_OP;
"<"          return '<';
"="          return '=';

";"          return ';';
"("		     return '(';
")"			 return ')';
","          return ',';
"["          return '[';
"]"          return ']';
"{"          return '{';
"}"          return '}';
":"          return ':';

[ \r\t]+		        /* ignore whitespace */

"/*"				    BEGIN(comment);
<comment>[^*\n]*        /* ignore anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* ignore '*'s not followed by '/'s */
<comment>\n             ++line_num;
<comment>"*"+"/"        BEGIN(INITIAL);
"//"[^\n]*              /* line comments */

\n      ++line_num;

<<EOF>> return EOF;
.       {yyerror("Lexical error: unrecognized literal '%s in line %d'\n", yytext, line_num);}
 
%%
