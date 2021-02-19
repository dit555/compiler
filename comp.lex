
/*flex file by:
  Dumitru Chiriac
  862126186 */

DIGIT 		[0-9]
LETTER 		[a-zA-Z]
IDENT 		{LETTER}
IDENTMID	({LETTER}|{DIGIT}|[_])
IDENTEND	({LETTER}|{DIGIT})  

%{
	#include "y.tab.h"
	int line = 1;//line
	int pos = 0;//character # in line
%}


%%
("##")(.)+("\n") 	{line++; pos = 0;}

" "		{pos++;}
"\t"		{pos++;}
"\n"		{line++; pos = 0;}

"function"	{ pos += yyleng; return FUNCTION; }
"beginparams"	{ pos += yyleng; return BEGIN_PARAMS;}
"endparams"	{ pos += yyleng; return END_PARAMS;}
"beginlocals"	{ pos += yyleng; return BEGIN_LOCALS;}
"endlocals"	{ pos += yyleng; return END_LOCALS;}
"beginbody"	{ pos += yyleng; return BEGIN_BODY;}
"endbody"	{ pos += yyleng; return END_BODY;}
"integer"	{ pos += yyleng; return INTEGER;}
"array"		{ pos += yyleng; return ARRAY;}
"of"		{ pos += yyleng; return OF;}
"if"		{ pos += yyleng; return IF;}
"then"		{ pos += yyleng; return THEN;}
"endif"		{ pos += yyleng; return ENDIF;}
"else"		{ pos += yyleng; return ELSE;}
"while"		{ pos += yyleng; return WHILE;}
"do"		{ pos += yyleng; return DO;}
"beginloop"	{ pos += yyleng; return BEGINLOOP;}
"endloop"	{ pos += yyleng;return ENDLOOP;}
"break"		{ pos += yyleng; return BREAK;}
"read"		{ pos += yyleng; return READ;}
"write"		{ pos += yyleng; return WRITE;}
"and"		{ pos += yyleng; return AND;}
"or"		{ pos += yyleng; return OR;}
"not"		{ pos += yyleng; return NOT;}
"true"		{ pos += yyleng; return TRUE;}
"false"		{ pos += yyleng; return FALSE;}
"return"	{ pos += yyleng; return RETURN;}

"-"		{ pos += yyleng; return SUB;}
"+"		{ pos += yyleng; return ADD;}
"*"		{ pos += yyleng; return MULT;}
"/"		{ pos += yyleng; return DIV;}
"%"		{ pos += yyleng; return MOD;}

"=="		{ pos += yyleng; return EQ;}
"<>"		{ pos += yyleng; return NEQ;}
"<"		{ pos += yyleng; return LT;}
">"		{ pos += yyleng; return GT;}
"<="		{ pos += yyleng; return LTE;}
">="		{ pos += yyleng; return GTE;}

";"		{ pos += yyleng; return SEMICOLON;}
":"		{ pos += yyleng; return COLON;}
","		{ pos += yyleng; return COMMA;}
"("		{ pos += yyleng; return L_PAREN;}
")"		{ pos += yyleng; return R_PAREN;}
"["		{ pos += yyleng; return L_SQUARE_BRACKET;}
"]"		{ pos += yyleng; return R_SQUARE_BRACKET;}
":="		{ pos += yyleng; return ASSIGN;}

({IDENT}{IDENTMID}+[_]+)|({IDENT}+[_]+)			{printf("error at line %d, col %d, identifier \"%s\" cannot end in an underscore\n", line, pos, yytext); exit(0);}
({DIGIT}+{IDENTMID}+{IDENTEND})|({DIGIT}+{IDENTMID}+)		{printf("error at line %d, col %d, identifier \"%s\" must begin with a letter\n", line, pos, yytext); exit(0);}


{IDENT}{IDENTMID}+{IDENTEND}		{printf("IDENT %s\n", yytext); pos += yyleng;}
{IDENT}					{printf("IDENT %s\n", yytext); pos += yyleng;}

{DIGIT}+	{pos += yyleng; yylval.ival = atoi(yytext); return NUMBER;}

.		{printf("error at line %d, col %d: unrecongized symbol \"%s\"\n", line, pos, yytext); exit(0);}

%%
