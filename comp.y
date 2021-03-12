%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>	

	#define i 1 // of type int
	#define f 2 //of ype function

	
	void yyerror(const char *msg);
	void reset(); //resets msg to avoid any weird stuff
	char* temp(); //generaes a char* for temps
	char* local(); //generates a char* for locals


	extern int line;
	extern int pos;
	FILE * yyin;

	char* curFunc; //function we are currently on
	char msg[254]; //line to be printed, 254 is max mil line size

	int tNum = 0; //number of temproary var
	int lNum = 0; //number of local var

	struct symbol{
		char* name; //name of symbol
		int type; //type code as defined above
		char* func; //function it belongs to
	};

	char stable[100]; //symbol table, 100 is overkill but is a safe number

	int checkS(char* name, char func); //check symbol table for avalibility
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
	| Function Program 
	;

Ident:
	  IDENT 

Function:
	  FUNCTION IDENT SEMICOLON BEGIN_PARAMS Params 
		{
			
		}
	;

Params:
	  Declaration SEMICOLON Params
	| END_PARAMS BEGIN_LOCALS Locals
	;
	
Locals:
	  Declaration SEMICOLON Locals
	| END_LOCALS BEGIN_BODY Body
	;
Body:
	  Statement SEMICOLON Body
	| Statement SEMICOLON END_BODY 
	;



Declaration:
	  Ident COMMA Declaration 
	| Ident COLON Array
	| Ident COLON INTEGER 
	;

Array:
	  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER 
	;


Statement:
	  Var ASSIGN Expression 
	| Var EQ Expression {yyerror("did you mean\':=\'");}
	| IF Bool_Expr THEN Then
	| WHILE Bool_Expr BEGINLOOP WLoop
	| DO BEGINLOOP BLoop
	| READ Read
	| WRITE Write
	| BREAK 
	| RETURN Expression 
	;


Then:
	  Statement SEMICOLON End
	;

End:
	  Then
	| ENDIF 
	| ELSE Else
	;

Else:
	  Statement SEMICOLON Else
	| Statement SEMICOLON ENDIF 
	;


WLoop:
	  Statement SEMICOLON WLoop
	| Statement SEMICOLON ENDLOOP 
	;

BLoop:
	  Statement SEMICOLON BLoop
	| Statement SEMICOLON ENDLOOP WHILE Bool_Expr 
	;

Read:
	  Var COMMA Read 
	| Var 
	;

Write:
	  Var COMMA Write
	| Var 
	;



Bool_Expr:
	  Relation_And_Expr OR Bool_Expr 
	| Relation_And_Expr
	;

Relation_And_Expr:
	  Relation_Expr AND Relation_And_Expr 
	| Relation_Expr 
	;

Relation_Expr:
	  NOT Re 
	| Re
	;

Re:
	  Expression Comp Expression 
	| TRUE 
	| FALSE 
	| L_PAREN Bool_Expr R_PAREN 
	| R_PAREN Bool_Expr {yyerror("missing \')\'");}
	;

Comp:
	  EQ 
	| NEQ 
	| LT 
	| GT 
	| LTE 
	| GTE 
	;

Expression:
	  Multiplicative_Expr 
	| Multiplicative_Expr ADD Expression  
	| Multiplicative_Expr SUB Expression 
	;

Multiplicative_Expr:
	  Term 
	| Term MULT Multiplicative_Expr 
	| Term DIV Multiplicative_Expr 
	| Term MOD Multiplicative_Expr 
	;

Term:
	  SUB Num 
	| Num
	| Ident L_PAREN Expression Exp R_PAREN 
	| Ident L_PAREN Expression R_PAREN 
	| Ident L_PAREN R_PAREN 
	;

Num:
	  Var 
	| NUMBER 
	| L_PAREN Expression R_PAREN 
	;

Exp:
	  COMMA Expression Exp
	| COMMA Expression
	;

Var:
	  Ident 
	| Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET 
	| Ident L_SQUARE_BRACKET Expression {yyerror("missing \']\'");}
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

