
/*flex file by:
  Dumitru Chiriac
  862126186 */

DIGIT [0-9]
LETTER [a-zA-Z]

%{
	int line = 1;//line
	int pos = 0;//character # in line
%}


%%

"function"	{printf("FUNCTION\n"); }
.		{printf("error\n");}

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
