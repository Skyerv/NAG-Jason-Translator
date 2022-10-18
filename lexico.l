%option noyywrap yylineno
%{
	//#include "codigoC.h"
	#include <string.h>
	#include <stdio.h>
	#include <stdlib.h>
	#include "sintatico.tab.h"
%}

letter				[a-zA-Z]
numbers				[0-9]
marks				(\.|\,|\!|\?|\:|\;|"'"|\/|\(|\))
word				({marks}|{numbers}|{letter})+
%%
"{"				        { return yytext[0]; }
"}"			        	{ return yytext[0]; }
"crencas"			    { return CRENCAS; }
"objetivos"		        { return OBJETIVOS; }
"\\usepackage"			{ return PACKAGE; }
"\\title"			    { return TITLE; }
"\\date"			    { return DATE; }
"\\begin{document}"		{ return BEGDOC; }
"\\end{document}"		{ return ENDDOC; }
"\\section"				{ return SECTION; }
"\\subsection"			{ return SUBSECTION; }
"\\begin{figure}"		{ return BEGIMG; }
"\\end{figure}"		 	{ return ENDIMG; }
"\\begin{itemize}"		{ return BEGITEM; }
"\\end{itemize}"		{ return ENDITEM; }
"\\begin{enumerate}"	{ return BEGENUM; }
"\\end{enumerate}"		{ return ENDENUM; }
"\\item"			    { return ITEM; }
"\\bibliographystyle"   { return BIBSTYLE; }
"\\bibliography"  		{ return BIBIB; }
"\\caption"		 	    { return CAPTION; }
"\\includegraphics"		{ return INCLGRAP; }
"\\maketitle"			;
"\\label"			    ;
{word}			    	{ yylval.s = strdup(yytext); return CONTENT; }
{word}[\n]?				{ yytext[strlen(yytext) - 1] = ' '; yylval.s = strdup(yytext); return CONTENTLN; }
"//".*
[ \t] /* ignora espaco em branco*/
\\n
\n
.				        ;
%%


