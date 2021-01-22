
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

{DIGIT}+	{printf("NUMBER %s\n", yytext); pos += yyleng;}
"function"	{printf("FUNCTION\n"); pos += yyleng;}

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
