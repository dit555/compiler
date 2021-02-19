%{
	#include <stdio.h>
	#include <stdlib.h>
	void yyerror(const char *msg);
	extern int line;
	extern int pos;
	FILE * yyin;
%}

%union{
	int ival;
	char *idnt;
}

%error-verbose
%start Program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP BREAK READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ NEW LT GT LTE GTE
%token IDENT NUMBER
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN



%%
Program:
	Function
	;



Function:
	FUNCTION IDENT SEMICOLON BEGIN_PARAMS Params {printf("ident -> IDENT main\n");}
	;

Params:
	;

%%

int main(int argc, char **argv) {
   if (argc > 1) {
      yyin = fopen(argv[1], "r");
      if (yyin == NULL){
         printf("syntax: %s filename\n", argv[0]);
      }//end if
   }//end if
   yyparse(); // Calls yylex() for tokens.
   return 0;
}

void yyerror(const char *msg) {
   printf("** Line %d, position %d: %s\n", line, pos, msg);
}

