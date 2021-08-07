%{
void yyerror (char *s);
int yylex();
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void build_C_File_Template(FILE * dest);
void declareVector(char* name , char* size);
void declareScalar(char* name);
void Init();
void printLoopExp(char* exp);
void printBlockTemplate();
void printClose2();
void vector(char *vec, char *size);
void negHandler(char* op, char* exp, char* dest);
void extractVal(char* token, char* val);
void printAssignment(char* left, char* right); 
void PrintCommand(char* name);
void printArrayTemp(char* term, char* exp, char* dest);
void operatorHandler(char* expl, char* op , char* expr, char* dest);
void printVec(char* vec, char *dest);
void printFreeVectors();
void Open1And2Handler(char* exp, char* dest);
void PrintWithComma(char* FirstExp, char* SecExp, char* dest);
void printPointCalc(char* left, char* right, char *dest);
int  CheckVectorExist(char * vec);

 
extern FILE* yyin;
extern FILE* yyout;
int  VectorCount = 0;
int count = 0;
int CounterTemp = 0;
char buff[1000];
int existingVectors[2] = {0,0}; 
char vectorSymbol[256][256];
char vectorSize[256][256];
%}

%start Line
%token Scl Vec Vector 
%token Identifier Digit Equal Operator Size POINT COLON
%token Semicolon Open_2 Close_2 Open Close Comma 
%token While Print If

%type <id>  Identifier
%type <num> Digit Size
%type <exp> Exp Vector Term
%type <exp> Declare
%type <exp> Statement

%right <str> Equal
%left  <str> Comma
%left  <str> plusAndMinOP  
%left  <str> mulAndDivOP 
%left  <str> COLON POINT
%left  <str> Open Close

%union {
	char type[3];
	char id[12]; 
	char num[11];
	char str[1];
	char exp[100];
	}         
%%

/* descriptions of expected inputs     corresponding actions (in C) */

Line    		: Statement Semicolon						{Init();}
				| Assignment Semicolon						{Init();}
				| Line Statement Semicolon					{Init();}
				| Line Assignment Semicolon					{Init();}
				| BlockStatement Block	 					{Init();}
				| Line BlockStatement Block 				{Init();} 
				;

BlockStatement 	: If Exp									{fprintf(yyout, "\tif(%s)\n\t{\n\t", $2);}
			   	| While Exp					    			{printLoopExp($2);}
			   	;	

Block 		  	: Open_2 Line Close_2				        {printClose2();}
				;


Statement 	  	: Print Exp								 	{PrintCommand($2);}
		  		| Declare 							 		{;}
		  		| Exp						     			{;}
		  		;

Assignment	  	: Term Equal Block			 	 	  		{;}
				| Term Equal Exp 					  		{printAssignment($1,$3);}
		    	;

Declare 		: Scl Identifier					 	 	{declareScalar($2);}
				| Vec Identifier Size	 		 	 	    {declareVector($2, $3);}
				;

Exp 			: Term 									 	{;}
				| Exp plusAndMinOP Exp 					 	{operatorHandler($1,$2,$3, $$);}
				| Exp mulAndDivOP Exp						{operatorHandler($1,$2,$3, $$);}
				| Exp POINT Exp						 		{printPointCalc($1,$3, $$);}
				| Open Exp Close	  						{Open1And2Handler($2, $$);
															buff[0] = '\n';
														  	count = 0;}
				| Exp Comma Exp								{PrintWithComma($1,$3,$$);}
				| plusAndMinOP Exp 							{negHandler($1,$2,$$);}
				;

Term 			: Identifier 								{;}
				| Vector									{printVec($1, $$);}
	 			| Digit									    {;}
				| Vector COLON Exp 		 				    {printVec($1, $$);
															printArrayTemp($$, $3, $$);
															strcpy($$, buff);
															buff[0] = '\0';
															count = 0;}
	 			| Identifier COLON Exp    					{printArrayTemp($1, $3, $$);
															strcpy($$, buff);
															buff[0] = '\0';
															count = 0;} 
     			;

%%                     
void build_C_File_Template(FILE * dest)
{
	fprintf(dest, "#include <stdio.h>\n");
	fprintf(dest, "#include <stdlib.h>\n");
    
	fprintf(dest,"//implementations for helped functions");

	fprintf(dest,"\nint pointCalc(int* vec1, int* vec2, int size, int scl)");
    fprintf(dest,"\n{\n");
	fprintf(dest,"\tint result = 0;");
    fprintf(dest,"\n\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t{\n");
	fprintf(dest, "\t\tif(scl == -1)\n");
    fprintf(dest,"\t\t{\n");
    fprintf(dest,"\t\t\tresult += vec1[i] * vec2[i];");
    fprintf(dest,"\n\t\t}");
    fprintf(dest,"\n\t\telse");
    fprintf(dest,"\n\t\t{");
    fprintf(dest,"\n\t\t\tresult += vec1[i] * scl;\n");
    fprintf(dest,"\t\t}\n");
    fprintf(dest,"\t}\n");
    fprintf(dest,"\treturn result;");
    fprintf(dest,"\n}\n");

    fprintf(dest, "int* AllocMemoryVec(int* firstVec, int* SecVec, int size)\n{\n");
	fprintf(dest, "\tint* tempArr = malloc(sizeof(int)*size);//alocate_memory\n");
	fprintf(dest, "\t\tfor(int i=0; i< size; i++)\n\t\t{\n");
	fprintf(dest , "\t\t\ttempArr[i] = firstVec[SecVec[i]];\n\t\t}\n");
	fprintf(dest , "\treturn tempArr;\n}\n");

	fprintf(dest, "\nvoid printArray(int* vec, int size)\n{\n");
	fprintf(dest, "\tprintf(\"[\");\n");
	fprintf(dest , "\tfor(int i=0; i< size-1; i++)\n\t{\n\t\tprintf(\"%%d,\" ,vec[i]);//print every cell in array\n\t}\n");
	fprintf(dest, "\tprintf(\"%%d]\\n\", vec[size -1]);\n}\n\n");

	fprintf(dest, "\nvoid assignScalarVector(int* vec, int size, int scl)\n");
	fprintf(dest , "{\n\tfor(int i = 0; i < size; i++)");
	fprintf(dest , "\n\t{\n\t\tvec[i] = scl;//assigment the scalar for every cell in the arry\n\t}\t\n}\n\n");

	fprintf(dest, "\nvoid AssignVectorVector(int* dst, int* src, int size)\n");
	fprintf(dest , "{\n\tfor(int i=0; i< size; i++)\n\t");
	fprintf(dest , "{\n\t\t");
	fprintf(dest , "dst[i] = src[i];//assigment for evrey cell from src array to dst array \n\t}");
	fprintf(dest , "\n}\n");

	fprintf(dest,"\nint* vectorVectorOp(int* vec1, char op, int* vec2, int size)\n{");
	fprintf(dest,"\n\tint *temp = malloc(sizeof(int) * size);//alocate_memory for the answer");
    fprintf(dest,"\n\tswitch (op)");
	fprintf(dest,"\n\t{");
    fprintf(dest,"\n\t\tcase '+':// '+' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec1[i] + vec2[i];");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
	fprintf(dest,"\n\t\tcase '-':// '-' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec1[i] - vec2[i];");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
    fprintf(dest,"\n\t\tcase '*':// '*' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec1[i] * vec2[i];");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
	fprintf(dest,"\n\t\tcase '/':// '/' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec1[i] / vec2[i];");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
    fprintf(dest,"\t}\n\treturn temp;\n}\n");

	fprintf(dest,"\nint* vectorScalarOp(int* vec, char op, int scl, int size)\n{");
	fprintf(dest,"\n\tint *temp = malloc(sizeof(int) * size);//alocate_memory for the answer");
    fprintf(dest,"\n\tswitch (op)");
	fprintf(dest,"\n\t{");
    fprintf(dest,"\n\t\tcase '+':// '+' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec[i] + scl;");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
    fprintf(dest,"\n\t\tcase '-':// '-' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec[i] - scl;");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
    fprintf(dest,"\n\t\tcase '*':// '*' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec[i] * scl;");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
	fprintf(dest,"\n\t\tcase '/':// '/' case");
    fprintf(dest,"\n\t\t\tfor (int i = 0; i < size; i++)");
    fprintf(dest,"\n\t\t\t{");
    fprintf(dest,"\n\t\t\t\ttemp[i] = vec[i] / scl;");
    fprintf(dest,"\n\t\t\t}");
    fprintf(dest,"\n\t\t\tbreak;\n");
    fprintf(dest,"\t}\n\treturn temp;\n}\n");
} 

void printClose2()
{
	fprintf(yyout,"\t}\n");
}

void Open1And2Handler(char* exp, char* dest)
{
	int vec = CheckVectorExist(exp);
	if(vec == -1)
	{
		extractVal("(", buff);
		extractVal(exp, buff);
		extractVal(")", buff);
		strcpy(dest, buff);
	}
	else
	{
			strcpy(dest, exp);
	}
}

void operatorHandler(char* expl, char* op, char* expr, char* dest)
{
	int expLValue = CheckVectorExist(expl);
	int expRValue = CheckVectorExist(expr);

	if(expLValue != -1 || expRValue != -1)
	{
		int counter = 0;
		char num[15];
		itoa(CounterTemp++,num, 14);
		strcpy(dest, "tempDaynamicArr");
		strcat(dest,num);
		num[0] = '\0';
		if(expLValue >= 0 && expRValue >= 0)
		{
			fprintf(yyout,"\n\tint* %s = vectorVectorOp(%s, \'%s\', %s, %s);\n", dest ,expl, op , expr, vectorSize[expLValue]);
			counter = atoi(vectorSize[expLValue]);
			itoa(counter, num , 8);
		}
		else if(expLValue >= 0 && expRValue <= 0)
		{
			fprintf(yyout,"\n\tint* %s = vectorScalarOp(%s,\'%s\', %s, %s);\n", dest, expl, op, expr,vectorSize[expLValue]);
			counter = atoi(vectorSize[expLValue]);
			itoa(counter, num , 8);
		}
		else if(expLValue <= 0 && expRValue >= 0)
		{
			fprintf(yyout,"\n\tint* %s = vectorScalarOp(%s,\'%s\', %s, %s);\n", dest, expr ,op, expl,vectorSize[expLValue]);
			counter = atoi(vectorSize[expRValue]);
			itoa(counter, num , 10);
		}
		vector(dest,num);
	}
	else
	{
		extractVal(expl, buff);
		extractVal(op, buff);
		extractVal(expr, buff);
		strcpy(dest,buff);
		buff[0] = '\0';
		count = 0;
	}

}


void printVec(char* vec, char* dest )
{
	int size = strlen(vec);
	char* temp = malloc(size*sizeof(char));
	int counter = 1;
	for(int i = 0; i < size; i++)
	{
		temp[i] = ' ';
	}
	temp[size-2] = '\0'; 
	for(int i=1; i < size - 1; i++)
	{
		temp[i-1] = vec[i];
		if(vec[i] == ',')
		{
			counter++;
		}
	}
	char num[9];
	itoa(CounterTemp++,num, 8);
	strcpy(dest, "tempArr");
	strcat(dest,num);
	num[0] = '\0';
	fprintf(yyout, "\tint %s[] = {%s};\n",dest, temp);
	itoa(counter, num , 8);
	vector(dest,num);
}

void printArrayTemp(char* term, char* exp, char* dest)
{
	int termVal = CheckVectorExist(term);
	int expVal = CheckVectorExist(exp);
	
	if(expVal == -1 && existingVectors[0] == 0)
	{
		extractVal(term, buff);
		extractVal("[", buff);
		extractVal(exp, buff);
		extractVal("]", buff);
	}
	else if(expVal != -1 || existingVectors[0] == 1)
	{
		char* temp = "AllocMemoryVec(";
		extractVal(temp, buff);
		extractVal(term, buff);
		extractVal(",", buff);
		extractVal(exp, buff);
		extractVal(",", buff);
		extractVal(vectorSize[termVal], buff);
		extractVal(")", buff);
		existingVectors[0] = 1;
		existingVectors[1] = atoi(vectorSize[termVal]);		
	}
}

void printAssignment(char* term, char* exp) 
{
	int termVal = CheckVectorExist(term);
	int expVal = CheckVectorExist(exp);
	if(termVal != -1)
	{
		if(existingVectors[0])
		{
			fprintf(yyout, "\n\ttemp = %s;", exp);
			fprintf(yyout, "\n\tAssignVectorVector(%s, temp , %d);\n", term, existingVectors[1]);
			fprintf(yyout, "\n\tfree(temp);\n");

			//nullify tmp vector array bytes
			existingVectors[0] = 0;
			existingVectors[1] = 0;
		}
		else if(expVal == -1)
		{
			fprintf(yyout, "\n\tassignScalarVector(%s, %s, %s);\n", term, vectorSize[termVal], exp);
		}
		else
		{
			fprintf(yyout, "\n\tAssignVectorVector(%s, %s, %s);\n", term, exp,vectorSize[termVal]);
		}
	}
	else
	{
		fprintf(yyout,"\t%s = %s;\n", term,exp);
	}
}

void PrintCommand(char* name)
{
	int type = CheckVectorExist(name);

	if(existingVectors[0])
	{
		fprintf(yyout, "\t\ttemp = %s;", name);
		fprintf(yyout, "\t\tprintArray(temp, %d);\n", existingVectors[1]);
		fprintf(yyout, "\t\tfree(temp);\n");		
		existingVectors[0] = 0;
		existingVectors[1] = 0;
	}
	else if(type == -1)
    {
		fprintf(yyout, "\tprintf(\"%%d\\n\", %s );\n", name);
	}
	else
    {
		fprintf(yyout, "\tprintArray(%s, %s);\n", name, vectorSize[type]);
    }

}

void extractVal(char* token, char* val)
{
	int size = strlen(token);
	int change = count;
	for(int i = 0; i < size; i++)
	{
		val[i + change] = token[i];
		count++;
	}
	val[count] = '\0';	
}

void vector(char* vector, char* size)
{
	strcpy(vectorSymbol[VectorCount], vector);
	strcpy(vectorSize[VectorCount], size);
	(VectorCount)++;
}

int CheckVectorExist(char * name)
{
	int ans  = -1;
	for(int i=0; i < VectorCount; i++)
	{
		int temp =  strcmp(name, vectorSymbol[i]);
		if(!temp)
        {
			ans = i;
		}
	}
	return ans;
}

void Init()
{
	buff[0] = '\0';
	count = 0;
	existingVectors[0] = 0;
	existingVectors[1] = 0;
}

void printPointCalc(char* firstExp, char* seconedExp, char* dest)
{
	int FirstVal = CheckVectorExist(firstExp);
	int SecVal = CheckVectorExist(seconedExp);
	if(FirstVal != -1 && SecVal != -1)
	{
		extractVal("pointCalc(", buff);
		extractVal(seconedExp, buff);
		extractVal("," , buff);
		extractVal(firstExp, buff);
		extractVal(",", buff);
		extractVal(vectorSize[SecVal], buff);
		extractVal(",-1)", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		count = 0;
	}
	else if(SecVal == -1)
	{		
		extractVal("pointCalc(", buff);
		extractVal(firstExp, buff);
		extractVal("," , buff);
		extractVal("NULL", buff);
		extractVal(",", buff);
		extractVal(vectorSize[FirstVal], buff);
		extractVal(",", buff);
		extractVal(seconedExp, buff);
		extractVal(")", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		count = 0;
	}
	else if(FirstVal == -1)
	{		
		extractVal("pointCalc(", buff);
		extractVal(seconedExp, buff);
		extractVal("," , buff);
		extractVal("NULL", buff);
		extractVal(",", buff);
		extractVal(vectorSize[SecVal], buff);
		extractVal(",", buff);
		extractVal(firstExp, buff);
		extractVal(")", buff);
		strcpy(dest, buff);
		buff[0] =  '\0';
		count = 0;
	}
}

void PrintWithComma(char* FirstExp, char* SecExp, char* dest)
{
	PrintCommand(FirstExp);
	strcpy(dest, SecExp);
}

void negHandler(char* op, char* exp, char* dest)
{
	if(strcmp("-",op)!=0)
	{
		return;
	}
	int vec = CheckVectorExist(exp);
	if(vec == -1)
	{
		strcpy(dest,"-");
		strcpy(dest,exp);
		return;
	}
	else
	{
		operatorHandler(exp, "*", "-1", dest);
	}
}

void declareVector(char* name , char* size)
{
	fprintf(yyout,"\tint %s[%s];\n", name, size); 
	vector(name, size);
}

void declareScalar(char* name)
{
	fprintf(yyout,"\tint %s;\n", name);
}

void printLoopExp(char* num)
{
    fprintf(yyout, "\tfor(int temp_index = 0; temp_index < %s; temp_index++)\n\t{\n", num);
}

void printBlockTemplate()
{
    fprintf(yyout,"\n\t}\n");
}

void printFreeVectors()
{
	for(int i = 0; i < 256; i++)
	{
		if(strncmp(vectorSymbol[i],"tempDaynamicArr",15) == 0)
		{
			fprintf(yyout, "\n\tfree(%s);", vectorSymbol[i]);
		}
	}
}

int main (int argc,char **argv) 
{
   	yyin = fopen("input.txt", "r");
   	yyout = fopen("output.c", "w");
	build_C_File_Template(yyout);
	fprintf(yyout , "\nint main(void)\n{\n\tint* temp;\n");
	yyparse ( );
	printFreeVectors();
	fprintf(yyout, "\n\treturn 0;");
	fprintf(yyout,"\n}");
	return 0;
}

void yyerror (char *s) 
{
	fprintf (stderr, "%s\n", s);
} 
