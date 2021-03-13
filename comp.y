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

	char msg[10000]; //line to be printed, 254 is max mil line size
	char tmp[9]; //stores temp name in a global
	char tmp2[20]; //stores names of idents
	char *tmp3;
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
		int index; //max index of array
	};

	struct symbol sTable[100]; //symbol table, 100 is overkill but is a safe number
	int sIndex = 0; //current free index in stable
	
	struct symbol holdS[10];
	int hIndexS = 0;
	
	int checkS(struct symbol* s); //check symbol table for avalibility
	int addToS(struct symbol* s);
	struct symbol* findS(char *n); //finds the symbol in tble and puts its ret in temp
%}

%union{
	int ival;
	char* idnt;
	char* ret;
	char* name;
	struct {
		char* ret;
		int typ;
		int i;
	} S;
}

%error-verbose
%start Program
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY INTEGER ARRAY OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP BREAK READ WRITE AND OR NOT TRUE FALSE RETURN
%token SUB ADD MULT DIV MOD
%token EQ NEQ NEW LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET ASSIGN

%token <ival> NUMBER
%token <idnt> IDENT

%type<S> Ident Var Expression Multiplicative_Expr Term Exp Num Bool_Expr Relation_And_Expr Relation_Expr Re Then fudge fudge1 fudge2 fudge3
%left PLUS MINUS
%left MULT DIV
%left L_PAREN
%left IDENT
%left IF
%%
Program:
	| Function Program  
	;

Ident:
	  IDENT 
		{
		tmp3 = strdup($1);
		struct symbol t;
		
		t = *findS(tmp3);
		$$.ret = strdup(t.ret);
		$$.typ = t.type;
		//printf("%s is %s\n",tmp, tmp3);
		}
	;

IdentF:
	IDENT 
		{
		struct symbol f;
		tmp3 = strdup($1);
		strcpy(f.name, tmp3);
		f.type = F;
		strcpy(f.func, tmp3);
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
IdentD:
	IDENT
	{
	
	strcpy(tmp2, $1);
	//printf("temp2 is: %s\n", tmp2);
	}
	;

Declaration:
	  Identt COMMA Declaration 
	| IdentD COLON Array
		{
		struct symbol t;
		strcpy(t.name, tmp2);
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
			reset();
			i++;
		}
		i = 0;
		hIndexS = 0;
		reset(); 
		}
	| IdentD COLON INTEGER 
		{
		struct symbol t;
		strcpy(t.name, tmp2);
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
		{
		struct symbol t,t2;
		strcpy(t.ret ,$1.ret);
		t.type = $1.typ;
		strcpy(t2.ret, $3.ret);
		t2.type = $3.typ;
		if (t.type == A && t2.type == A){
			t.index = $1.i;
			t2.index = $3.i;
			reset();
			temp();
			printf(". %s\n", tmp);
			printf("=[] %s, %s, %d\n", tmp, t2.ret, t2.index);
			printf("[]= %s, %d, %s\n", t.ret, t.index , tmp);	

		}
		else if(t.type == A){
			t.index = $1.i;
			printf("[]= %s, %d, %s\n", t.ret, t.index, t2.ret);
		}
		else if( t2.type == A){
			t2.index = $3.i;
			reset();
			temp();
			printf(". %s\n", tmp);
			printf("=[] %s, %s, %d\n", tmp, t2.ret, t2.index);
			printf("= %s, %s\n", t.ret, tmp);
		}
		else
			printf("= %s, %s\n", t.ret, t2.ret);
		} 
	| Var EQ Expression {yyerror("did you mean\':=\', assuming \':=\' and continuing");}
	| IF Bool_Expr THEN fudge
		{
		char l1[10];
		char l2[10];
		local();
		strcpy(l1 ,lcl);
		local();
		strcpy(l2 ,lcl);
		struct symbol t1;
		strcpy(t1.ret, $2.ret);
		printf(". %s\n", t1.ret);
		printf("?:= %s, %s\n", l1, t1.ret);
		printf(":= %s\n", l2);
		printf(": %s\n", l1);
		char t[10];
		strcpy(t, $4.ret);
		printf(": %s\n", l2);
		}
	| WHILE Bool_Expr BEGINLOOP WLoop
	| DO BEGINLOOP BLoop
	| Read
	| Write
	| BREAK 
	| RETURN Expression 
	;

fudge:
	fudge1 {$$ = $1;}
	;
fudge1:
	fudge2  {$$ = $1;}
	;

fudge2:
	fudge3  {$$ = $1;}
	;

fudge3:
	Then  {$$ = $1;}
	;


Then:
	  Statement SEMICOLON End  {strcpy($$.ret, "69696");}
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
		reset();
		struct symbol t;
		strcpy(t.ret, $2.ret);
		t.type = $2.typ;
		if(t.type == A){
			t.index = $2.i;			
			printf(".[]< %s, %d\n", t.ret, t.index);
		}
		else
			printf(".< %s \n", t.ret);
		} 
	| READ Var
		{
		reset();
		struct symbol t;
		strcpy(t.ret, $2.ret);
		t.type = $2.typ;
		if(t.type == A){
			t.index = $2.i;
			printf(".[]< %s, %d\n", t.ret, t.index);
		}
		else
			printf(".< %s \n", t.ret);
		} 
	;

Write:
	  WRITE Var COMMA Write
		{
		struct symbol t;
		strcpy(t.ret, $2.ret);
		t.type = $2.typ;	
		if(t.type == A){
			t.index = $2.i;
			printf(".[]> %s, %d\n", t.ret, t.index);
		}
		else
			printf(".> %s \n", t.ret);
		} 
	| WRITE Var
		{
		struct symbol t;
		strcpy(t.ret, $2.ret);
		t.type = $2.typ;
		if(t.type == A){
			t.index = $2.i;
			printf(".[]> %s, %d\n", t.ret, t.index);
		}
		else
			printf(".> %s \n", t.ret);
		} 
	;



Bool_Expr:
	  Relation_And_Expr OR Bool_Expr 
		{
		struct symbol t1,t2;
		strcpy(t1.ret ,$1.ret);
		strcpy(t2.ret ,$3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("|| %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);		
		}
	| Relation_And_Expr
		{$$ = $1;}
	;

Relation_And_Expr:
	  Relation_Expr AND Relation_And_Expr 
		{
		struct symbol t1,t2;
		strcpy(t1.ret ,$1.ret);
		strcpy(t2.ret ,$3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("&& %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);		
		}
	| Relation_Expr 
		{ $$ = $1;}
	;

Relation_Expr:
	  NOT Re 
		{
		reset();
		temp();
		char *t = strdup(tmp);
		char *t2 = strdup($2.ret);
		printf(". %s\n", t);
		printf("! %s, %s\n", t, t2);
		strcpy($$.ret, t);
		}
	| Re  	
		{$$ = $1;}
	;

Re:
	  Expression EQ Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("== %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| Expression NEQ Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("!= %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| Expression LT Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("< %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| Expression GT Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("> %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| Expression LTE Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("<= %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| Expression GTE Expression
		{
		struct symbol t1,t2;
		strcpy(t1.ret, $1.ret);
		strcpy(t2.ret, $3.ret);
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf(">= %s, %s, %s\n", t, t1.ret, t2.ret);
		strcpy($$.ret, t);
		} 
	| TRUE 
		{
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("= %s, %d\n", t, 1);
		$$.ret = strdup(t);
		}	
	| FALSE 
		{
		reset();
		temp();
		char *t = strdup(tmp);
		printf(". %s\n", t);
		printf("= %s, %d\n", t, 0);
		$$.ret = strdup(t);
		}
	| L_PAREN Bool_Expr R_PAREN {$$ = $2;} 
	| R_PAREN Bool_Expr {yyerror("missing \')\', assuming \')\' and continuing");}
	;


Expression:
	  Multiplicative_Expr {$$ = $1;} 
	| Multiplicative_Expr ADD Expression
		{
			reset();
			char *t1, *t2;
			t1 = strdup($1.ret);
			t2 = strdup($3.ret);
			temp();
			strcpy($$.ret, tmp);
			printf(". %s\n", tmp);
			printf("+ %s, %s, %s\n", tmp, t1, t2); 
		}  
	| Multiplicative_Expr SUB Expression 
		{
			reset();
			char *t1, *t2;
			t1 = strdup($1.ret);
			t2 = strdup($3.ret);
			temp();
			strcpy($$.ret, tmp);
			printf(". %s\n", tmp);
			printf("- %s, %s, %s\n", tmp, t1, t2); 
		}
	;

Multiplicative_Expr:
	  Term {$$ = $1;}
	| Term MULT Multiplicative_Expr 
		{
			reset();
			char *t1, *t2;
			t1 = strdup($1.ret);
			t2 = strdup($3.ret);
			temp();
			strcpy($$.ret, tmp);
			printf(". %s\n", tmp);
			printf("* %s, %s, %s\n", tmp, t1, t2); 
		}
	| Term DIV Multiplicative_Expr 
		{
			reset();
			char *t1, *t2;
			t1 = strdup($1.ret);
			t2 = strdup($3.ret);
			temp();
			strcpy($$.ret, tmp);
			printf(". %s\n", tmp);
			printf("/ %s, %s, %s\n", tmp, t1, t2); 
		}
	| Term MOD Multiplicative_Expr 
		{
			reset();
			char *t1, *t2;
			t1 = strdup($1.ret);
			t2 = strdup($3.ret);
			temp();
			strcpy($$.ret, tmp);
			printf(". %s\n", tmp);
			printf("%% %s, %s, %s\n", tmp, t1, t2); 
		}
	;

Term:
	  Num {$$ = $1;}
	| SUB Num
		{
		reset();
		char *t = strdup($2.ret);
		temp();
		printf(". %s\n", tmp);
		printf("= %s, %d\n", tmp, 0);
		printf("- %s, %s, %s\n", tmp, tmp, t);
		strcpy($$.ret, tmp);
		}
	| Ident L_PAREN Expression Exp R_PAREN 
	| Ident L_PAREN Expression R_PAREN 
	| Ident L_PAREN R_PAREN 
	;

Num:
	  Var {$$ = $1;}
	| NUMBER 
		{
		reset();
		temp();
		$$.ret = strdup(tmp);
		$$.typ = I;
		printf(". %s\n", tmp);
		int t = $1;
		printf("= %s, %d\n", tmp, t);
		
		} 
	| L_PAREN Expression R_PAREN {$$ = $2;}
	;

Exp:
	  COMMA Expression Exp
	| COMMA Expression
	;

Var:
	  Ident {$$ = $1;}
	| Ident L_SQUARE_BRACKET Expression R_SQUARE_BRACKET {$$.i = $3.i; $$.ret = $1.ret;}
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

struct symbol* findS(char *n){
	i = 0;
	while (i < sIndex){
		if (strcmp(n, sTable[i].name) == 0){
			return &sTable[i];
		}
		i++;
	}
	return 0;
} 
