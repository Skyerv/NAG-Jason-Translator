%option noyywrap yylineno
%{
	#include <string.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include "sintatico.tab.h"
%}

minusculas			[a-z]
maiusculas			[A-Z]
numbers				[0-9]
marks				(\.|\,|\!|\?|\:|\;|"'"|\/|\(|\))
palavra				({maiusculas} | {numbers} | {minusculas} | {marks})+
%%

"{"				        { return yytext[0]; }
"}"			        	{ return yytext[0]; }
"E"				        { return E; }
"OU"			        { return OU; }
"NAO"			        { return NAO; }
{palavra}			    { yylval.s = strdup(yytext); return NAME; }
"//".*					/* Ignora comentarios */
"/*".*"*/" 				/* Ignora comentarios */
[ \t] 					/* ignora espaco em branco */
\\n
\n
.				        ;
%%


