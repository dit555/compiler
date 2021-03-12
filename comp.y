%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>	

	#define I 1 // of type int
	#define F 2 //of ype function
	#define A 3//of type array
	
	void yyerror(const char *msg);
	void reset(); //resets msg to avoid any weird stuff
	void temp(); //generaes a char* for temps
	void local(); //generates a char* for locals


	extern int line;
	extern int pos;
	FILE * yyin;

	char msg[254]; //line to be printed, 254 is max mil line size
	char tmp[9]; //stores temp name in a global
	char lcl[10]; //stores local as a global
	int tNum = 0; //number of temproary var
	int lNum = 0; //number of local var
	char tempI[20]; //temporary stroage for Ident name
	char curFunc[20];
	int i = 0; //for the purpose of loops

	char *holdT[10]; //allows storage of temp n
	int hIndexT = 0;

	char *holdL[10]; //holds local
	int hIndexL = 0;

	int holdI[10]; //holds integers
	int hIndexI = 0;

	struct symbol{
		char name[20]; //name of symbol
		int type; //type code as defined above
		char func[20]; //function it belongs to
		char ret[9]; //temp number
		int inUse; //1 if used 0 if avalible but declared before
	};

	struct symbol sTable[100]; //symbol table, 100 is overkill but is a safe number
	int sIndex = 0; //current free index in stable
	
	struct symbol holdS[10];
	int hIndexS = 0;
	
	int checkS(struct symbol* s); //check symbol table for avalibility
	int addToS(struct symbol* s);
	int findS(char *n); //finds the symbol in tble and puts its ret in temp
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

%left PLUS MINUS
%left MULT DIV
%left L_PAREN


%%
Program:
	| Function Program  
	;

Ident:
	  IDENT 
		{
		
		}
	;

IdentF:
	IDENT 
		{
		struct symbol f;
		strcpy(f.name, $1);
		f.type = F;
		strcpy(f.func, $1);
		addToS(&f);
		printf("func %s\n",f.name);
		strcpy(curFunc,f.name);
		}
	;

Function:
	  FUNCTION IdentF SEMICOLON BEGIN_PARAMS Params
	;

Params:
	  Declaration SEMICOLON Params
	| EndP BEGIN_LOCALS Locals
	;

EndP:
	END_PARAMS
	;
	
Locals:
	  Declaration SEMICOLON Locals
	| EndL BEGIN_BODY Body
	;

EndL:
	END_LOCALS
	;
Body:
	  Statement SEMICOLON Body
	| Statement SEMICOLON END_BODY 
		{
		printf("endfunc\n");
		}
	;


Identt:
	IDENT
		{
		struct symbol t;
		strcpy(t.name, $1);
		//printf("name: %s\n", t.name);
		strcpy(t.func, curFunc);
		holdS[hIndexS] = t;
		hIndexS++;
		//printf("hIndex: %d\n", hIndexS);
		}
	;	

Declaration:
	  Identt COMMA Declaration 
	| IDENT COLON Array
		{
		struct symbol t;
		strcpy(t.name, $1);
		strcpy(t.func, curFunc);
		t.type = A;
		temp();
		strcpy(t.ret, tmp);
		t.inUse = 1;
		addToS(&t);
		reset();
		strcat(msg, ".[] ");
		strcat(msg, tmp);
		printf("%s, %d\n", msg, holdI[hIndexI - 1]);
		printf("= %s, $0\n", tmp);
		reset();
		while(i < hIndexS){
			holdS[i].type = A;
			temp();
			strcpy(holdS[i].ret, tmp);
			holdS[i].inUse = 1;
			addToS(&holdS[i]);
			reset();
			strcat(msg, ".[] ");
			strcat(msg, tmp);
			printf("%s, %d\n", msg, holdI[hIndexI - 1]);
			printf("= %s, $0\n", tmp);
			reset();
			i++;
		}
		i = 0;
		hIndexS = 0;
		reset(); 
		}
	| IDENT COLON INTEGER 
		{
		struct symbol t;
		strcpy(t.name, $1);
		strcpy(t.func, curFunc);
		t.type = I;
		temp();
		strcpy(t.ret, tmp);
		t.inUse = 1;
		addToS(&t);
		reset();
		strcat(msg, ". ");
		strcat(msg, tmp);
		printf("%s\n", msg);
		printf("= %s, $0\n", tmp);
		//printf("i :%d,  S: %d, name: %s\n", i, hIndexS, $1);
		while(i < hIndexS){
			holdS[i].type = I;
			temp();
			strcpy(holdS[i].ret, tmp);
			holdS[i].inUse = 1;
			addToS(&holdS[i]);
			reset();
			strcat(msg, ". ");
			strcat(msg, tmp);
			printf("%s\n", msg);
			printf("= %s, $0\n", tmp);
			reset();
			i++;
			//printf("i :%d,  S: %d, name: %s\n", i, hIndexS, holdS[i - 1].name);
		}
		i = 0;
		hIndexS = 0;
		reset(); 
		}
	;

Array:
	  ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF INTEGER
		{
		holdI[hIndexI] = (int)$3;
		hIndexI++;
		} 
	;


Statement:
	  Var ASSIGN Expression 
	| Var EQ Expression {yyerror("did you mean\':=\', assuming \':=\' and continuing");}
	| IF Bool_Expr THEN Then
	| WHILE Bool_Expr BEGINLOOP WLoop
	| DO BEGINLOOP BLoop
	| Read
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
	  READ Var COMMA Read 
		{

		}
	| READ Var 
		{

		}
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
	| R_PAREN Bool_Expr {yyerror("missing \')\', assuming \')\' and continuing");}
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
	| Ident L_SQUARE_BRACKET Expression {yyerror("missing \']\', assuming \']\' and continuing");}
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

void temp(){
	strcpy(tmp,"_temp_");
	if (tNum >= 10){
		int ones = tNum % 10;
		tmp[6] = (char)((tNum - ones) / 10 + 48);
		tmp[7] = (char)(ones + 48);
	}
	else{
		tmp[6] = (char)(tNum + 48);	
	}
	tNum++;


}

void local(){
	strcpy(lcl,"_local_");
	if (tNum >= 10){
		int ones = tNum % 10;
		lcl[7] = (char)((tNum - ones) / 10 + 48);
		lcl[8] = (char)(ones + 48);
	}
	else{
		lcl[7] = (char)(tNum + 48);	
	}
	tNum++;


}

void reset(){
	memset(msg, 0, 254);
}

int checkS(struct symbol* s){
	//place holder
}

int addToS(struct symbol* s){
	if (sIndex > 99) {printf("symbol table at max\n"); return 0;}
	else{
		sTable[sIndex] = *s;
		sIndex++;
		return 1;
	}	
}

int findS(char *n){
	i = 0;
	while (i < sIndex){
		if (strcmp(n, sTable[i].name) == 0){
			strcpy(tmp, sTable[i].name);
			return 1;
		}
		i++;
	}
	return 0;
} 
