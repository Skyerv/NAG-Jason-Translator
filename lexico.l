%option noyywrap yylineno
%{
	#include <string.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include "sintatico.tab.h"
%}

letter				[a-zA-Z]
numbers				[0-9]
word				({numbers}|{letter})+
nomeCrenca			({word})
nomeObjetivo		({word})
nomePlano			({word})
%%

"{"				        { return yytext[0]; }
"}"			        	{ return yytext[0]; }
"E"				        { return E; }
"OU"			        { return OU; }
"NAO"			        { return NAO; }
{word}			    	{ yylval.s = strdup(yytext); return NAME; }
"crencas:"				{ return CRENCAS; }
"objetivos:"			{ return OBJETIVOS; }
"planos:"				{ return PLANOS; }

"//".*					/* Ignora comentarios */
"/*".*"*/" 				/* Ignora comentarios */
[ \t] 					/* ignora espaco em branco */
\\n
\n
.				        ;
%%


