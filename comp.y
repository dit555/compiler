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
	  VarTemp
	| IfTemp
	| WhileTemp
	| DoTemp
	| ReadTemp
	| WriteTemp
	| BreakTemp
	| ReturnTemp
	;

VarTemp:
	  Var ASSIGN Expression
	;

IfTemp:
	  IF Bool_Exp THEN Then
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

WhileTemp:
	  WHILE Bool-Expr BEGIN_LOOP WLoop
	;

WLoop:
	  Statement SEMICOLON WLoop
	| Statement SEMICOLON END_LOOP
	;

DoTemp:
	  DO BEGIN_LOOP BLoop
	;

BLoop:
	  Statement SEMICOLON BLoop
	| Statement SEMICOLON END_LOOP WHILE Bool_Expr
	;

ReadTemp:
	  READ Read
	;

Read:
	  Var COMMA Read | Var
	;

BreakTemp:
	  BREAK
	;

ReturnTemp:
	  RETURN Expression
	;


Bool_Expr:
	  Relation_And_Expr OR Relation_And_Expr
	| Relation_And_Expr
	;

Relation_And_Expr:
	  Relation_Expr AND Relation_Expr
	| Relation_Expr 
	;

Relation_Expr:
	  NOT Re
	| Re
	;

Re:
	  Expresion Comp Expression
	| TRUE
	| FALSE
	| L_PAREN Bool_expr R_PAREN
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
	  Multiplicative_Expr Me
	:

Me:
	  ADD Multiplicative_Expr Me
	| SUB Multiplicative_Expr Me
	| ADD Multiplicative_Expr
	| SUB Multiplicative_Expr
	;

Multiplicative_Expr:
	  Term T
	;

T:
	  MULT Term T
	| DIV Term T
	| MOD Term T
	| MULT Term
	| DIV Term
	| MOD Term 
	;

Term:
	  Neg
	| Id
	;

Neg:
	  -Num
	| Num
	:

Num:
	  Var
	| NUMBER
	| L_PAREN Expression R_PAREN
	;

Id:
	  Ident L_PAREN Exp
	;

Exp:
	  Expression COMMA Exp
	| Expression R_PAREN
	| R_PAREN
	;

Var:
	  Ident
	| Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET
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

