
/*flex file by:
  Dumitru Chiriac
  862126186 */

DIGIT [0-9]
LETTER [a-zA-Z]
NUMBER (\.{DIGIT}+)|({DIGIT}+(\.{DIGIT}*)?([eE][+-]?[0-9]+)?)

%{
	int line = 1;//line
	int pos = 0;//character # in line
%}


%%
" "		{pos++;}
"\n"		{line++; pos = 0;}

"function"	{printf("FUNCTION\n"); pos += yyleng;}
.		{printf("error at line %d, col %d\n", line, pos);}

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
