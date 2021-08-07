%{
#include "vlang.tab.h"
#include <string.h>
#include <stdio.h>
void yyerror (char *s);
int yylex();
void copyVecDecleration(char* src, char *dest);
void copySize(char * src, char * dest);
%}


identifier         [a-zA-Z]([a-zA-Z0-9]+)?
digit              [0-9]+
mulAndDivOP        [*/]
plusAndMinOP       [+-]
size               [{][0-9]+[}]
Vector             \[[ ]*-?[ ]*[0-9]+([ ]*,[ ]*-?[ ]*[0-9]+[ ]*)*\]
                   
%%
"scl"                  {return Scl;}
"vec"                  {return Vec;}
"print"                {return Print;}
"if"                   {return If;}
"loop"                 {return While;}
"="                    {sscanf(yytext, "%s",yylval.str); return Equal;}
":"                    {return COLON;}
"("                    {sscanf(yytext, "%s", yylval.str); return Open;}
")"                    {sscanf(yytext, "%s", yylval.str);return Close;}
"{"                    {return Open_2;}
"}"                    {return Close_2;}
","                    {return Comma;}
";"                    {return Semicolon;}
"."                    {return POINT;}
{identifier}		   {sscanf(yytext, "%s", yylval.id);return Identifier;}
{digit}                {sscanf(yytext, "%s", yylval.num); return Digit;}
{mulAndDivOP}          {sscanf(yytext, "%s", yylval.str); return mulAndDivOP;}
{plusAndMinOP}         {sscanf(yytext, "%s", yylval.str); return plusAndMinOP;}
{size}                 {copySize(yytext, yylval.num); return Size;}
{Vector}               {copyVecDecleration(yytext,yylval.exp); return Vector;}
[ \t\n]                {;}
.                      {ECHO; yyerror ("unexpected character");}

%%
int yywrap (void) {return 1;}


//Copy the text that specifies tmp vector creation
void copyVecDecleration(char* src, char* dest) {

    int size = strlen(src);

    for(int i = 0; i < size; i++) 
    {
       dest[i] = src[i]; 
    }    
    dest[size] = '\0';
} 

//Copy the text that specifies the size of array 
void copySize(char* src, char* dest){
    int size = strlen(src);

    for(int i = 1; i < size - 1; i++)
    {
        dest[i - 1]  = src[i];
    }
    dest[size  - 2] = '\0';
}

