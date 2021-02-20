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
	| Function Program {printf("Program -> Function\n");}
	;

Ident:
	  IDENT {printf("ident -> IDENT %s\n",$1);}

Function:
	  FUNCTION Ident SEMICOLON BEGIN_PARAMS Params
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
	| Statement SEMICOLON END_BODY {printf("Function -> FUNCTION IDENT SEMICOLON BEGINPARAMS Declaration ENDPARAM BEGINLOCALS Declaration ENDLOCALS BEGINBODY Statement ENDBODY\n");}
	;



Declaration:
	  Ident COMMA Declaration {printf("Declaration -> IDENT COMMA Declaration\n");}
	| Ident COLON Array
	| Ident COLON INTEGER {printf("Declaration -> IDENT COLON INTEGER\n");}
	;

Array:
	  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER {printf("Declaration -> IDENT COLON ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER\n");} 
	;


Statement:
	  Var ASSIGN Expression {printf("Statement -> Var ASSIGN Expression\n");}
	| Var EQ Expression {yyerror("did you mean\':=\'");}
	| IF Bool_Expr THEN Then
	| WHILE Bool_Expr BEGINLOOP WLoop
	| DO BEGINLOOP BLoop
	| READ Read
	| WRITE Write
	| BREAK {printf("Statement -> BREAK\n");}
	| RETURN Expression {printf("Statement -> RETURN Expression\n");}
	;


Then:
	  Statement SEMICOLON End
	;

End:
	  Then
	| ENDIF {printf("Statement -> IF Bool_Expr THEN Statement SEMICOLON ENDIF\n");}
	| ELSE Else
	;

Else:
	  Statement SEMICOLON Else
	| Statement SEMICOLON ENDIF {printf("Statement -> IF Bool_Expr THEN Statement SEMICOLON ELSE Statement SEMICOLON ENDIF\n");}
	;


WLoop:
	  Statement SEMICOLON WLoop
	| Statement SEMICOLON ENDLOOP {printf("Statement -> WHILE Bool_Expr BEGINLOOP Statement SEMICOLON ENDLOOP\n");}
	;

BLoop:
	  Statement SEMICOLON BLoop
	| Statement SEMICOLON ENDLOOP WHILE Bool_Expr {printf("Statement -> DO BEGINLOOP Statement SEMICOLON ENDLOOP WHILE Bool-Expr\n");}
	;

Read:
	  Var COMMA Read 
	| Var {printf("Statement -> READ VAR\n");}
	;

Write:
	  Var COMMA Write
	| Var {printf("Statement -> WRITE VAR\n");}
	;



Bool_Expr:
	  Relation_And_Expr OR Bool_Expr {printf("Bool_Expr -> Relation_and_Expr OR Bool_Expr\n");}
	| Relation_And_Expr {printf("Bool_Expr -> Relation_And_Expr\n");}
	;

Relation_And_Expr:
	  Relation_Expr AND Relation_And_Expr {printf("Relation_And_Expr -> Relation->Expr AND Relation_And_Expr\n");}
	| Relation_Expr {printf("Relation_And_Expr -> Relation_Expr\n");}
	;

Relation_Expr:
	  NOT Re {printf("Relation_Expr -> Not\n");}
	| Re
	;

Re:
	  Expression Comp Expression {printf("Relation_Expr -> Expression Comp Expression\n");}
	| TRUE {printf("Relation_Expr -> TRUE\n");}
	| FALSE {printf("Relation_Expr -> FALSE\n");}
	| L_PAREN Bool_Expr R_PAREN {printf("Relation_Expr -> L_PAREN Bool-Expr R_PAREN\n");}
	| R_PAREN Bool_Expr {yyerror("missing \')\'");}
	;

Comp:
	  EQ {printf("Comp -> EQ\n");}
	| NEQ {printf("Comp -> NEQ\n");}
	| LT {printf("Comp -> LT\n");}
	| GT {printf("Comp -> GT\n");}
	| LTE {printf("Comp -> LTE\n");}
	| GTE {printf("Comp -> GTE\n");}
	;

Expression:
	  Multiplicative_Expr {printf("Expression -> Mulitplicative_Expr\n");}
	| Multiplicative_Expr ADD Expression  {printf("Expression -> Multiplicative_Expr ADD Expression\n");}
	| Multiplicative_Expr SUB Expression {printf("Expression -> Mulitplicative_Expr SUB Expression\n");}
	;

Multiplicative_Expr:
	  Term {printf("Mulitplicative_Expr -> Term\n");}
	| Term MULT Multiplicative_Expr {printf("Multiplicative_Expr -> Term MULT Multiplicative_Expr\n");}
	| Term DIV Multiplicative_Expr {printf("Multiplicative_Expr -> Term DIV Mulitplicative_Expr\n");}
	| Term MOD Multiplicative_Expr {printf("Multiplicative_Expr -> Term MOD Multiplicative_Expr\n");}
	;

Term:
	  SUB Num {printf("Term -> SUB\n");}
	| Num
	| Ident L_PAREN Expression Exp R_PAREN {printf("Term -> IDENT L_PAREN Expression COMMA Expression R_PAREN\n");}
	| Ident L_PAREN Expression R_PAREN {printf("Term -> IDENT L_PAREN Expression R_PAREN\n");}
	| Ident L_PAREN R_PAREN {printf("Term -> IDENT L_PAREN R_PAREN\n");}
	;

Num:
	  Var {printf("Term -> Var\n");}
	| NUMBER {printf("Term -> NUMBER\n");}
	| L_PAREN Expression R_PAREN {printf("Term ->  L_PAREN R_PAREN\n");} 
	;

Exp:
	  COMMA Expression Exp
	| COMMA Expression
	;

Var:
	  Ident {printf("Var -> IDENT\n");}
	| Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET {printf("Var -> IDENT L_SQUARE_BRACKET Expression R_SQUARE_BRACKET\n");}
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

