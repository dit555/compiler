
/*flex file by:
  Dumitru Chiriac
  862126186 */

DIGIT 		[0-9]
LETTER 		[a-zA-Z]
IDENT 		{LETTER}
IDENTMID	({LETTER}|{DIGIT}|[_])
IDENTEND	({LETTER}|{DIGIT})  

%{
	int line = 1;//line
	int pos = 0;//character # in line
%}


%%
" "		{pos++;}
"\n"		{line++; pos = 0;}

"function"	{printf("FUNCTION\n"); pos += yyleng;}
"beginparams"	{printf("BEGIN_PARAMS\n"); pos += yyleng;}
"endparams"	{printf("END_PARAMS\n"); pos += yyleng;}
"beginlocals"	{printf("BEGIN_LOCALS\n"); pos += yyleng;}
"endlocals"	{printf("END_LOCALS\n"); pos += yyleng;}
"beginbody"	{printf("BEGIN_BODY\n"); pos += yyleng;}
"endbody"	{printf("END_BODY\n"); pos += yyleng;}
"integer"	{printf("INTEGER\n"); pos += yyleng;}
"array"		{printf("ARRAY\n"); pos += yyleng;}
"of"		{printf("OF\n"); pos += yyleng;}
"if"		{printf("IF\n"); pos += yyleng;}
"then"		{printf("THEN\n"); pos += yyleng;}
"endif"		{printf("ENDIF\n"); pos += yyleng;}
"else"		{printf("ELSE\n"); pos += yyleng;}
"while"		{printf("WHILE\n"); pos += yyleng;}
"do"		{printf("DO\n"); pos += yyleng;}
"beginloop"	{printf("BEGINELOOP\n"); pos += yyleng;}
"endloop"	{printf("ENDLOOP\n"); pos += yyleng;}
"break"		{printf("BREAK\n"); pos += yyleng;}
"read"		{printf("READ\n"); pos += yyleng;}
"write"		{printf("WRITE\n"); pos += yyleng;}
"and"		{printf("AND\n"); pos += yyleng;}
"or"		{printf("OR\n"); pos += yyleng;}
"not"		{printf("NOT\n"); pos += yyleng;}
"true"		{printf("TRUE\n"); pos += yyleng;}
"false"		{printf("FALSE\n"); pos += yyleng;}
"return"	{printf("RETURN\n"); pos += yyleng;}




{DIGIT}+	{printf("NUMBER %s\n", yytext); pos += yyleng;}
{IDENT}{IDENTMID}+{IDENTEND}		{printf("IDENT %s\n", yytext); pos += yyleng;}

{IDENT}{IDENTMID}+[_]			{printf("error at line %d, col %d, identifier cannot end with \"_\"\n", line, pos); exit(0);}
{DIGIT}{IDENTMID}+{IDENTEND}		{printf("error at line %d, col %d, identifier cannot begin with a number\n", line, pos); exit(0);}

.		{printf("error at line %d, col %d\n", line, pos); exit(0);}

%%

int main(int argc, char ** argv){
	if(argc >= 2){
      		yyin = fopen(argv[1], "r");
      		if(yyin == NULL){
			printf("input: ");
			yyin = stdin;
      		}
   	}
   	else{
    		printf("input: ");
      		yyin = stdin;
   	}

   	yylex();
}
