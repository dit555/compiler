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
	char* idnt;
}

%error-verbose
%start Program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP BREAK READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ NEW LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN

%token <ival> NUMBER
%token <idnt> IDENT

%%
Program:
	  Function
	;

Ident:
	  IDENT {printf("ident -> IDENT %S\n",$1);}

Function:
	  FUNCTION Ident SEMICOLON BEGIN_PARAMS Params
	;

Params:
	  Declaration SEMICOLON Params
	| Declaration SEMICOLON END_PARAMS BEGIN_LOCALS Locals
	| END_PARAMS BEGIN_LOCALS Locals {printf("declarations -> epsilon\n");}
	;
	
Locals:
	  Declaration SEMICOLON Locals
	| Declaration SEMICOLON END_LOCALS BEGIN_BODY Body
	| END_LOCALS BEGIN_BODY Body {printf("locals -> epsilon\n");}

Body:
	  Statement SEMICOLON Body
	| Statement SEMICOLON END_BODY
	;



Declaration:
	  Ident COMMA Declaration
	| Ident SEMICOLON Array

Array:
	  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF NUMBER
	| NUMBER
	;


Statement:
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

