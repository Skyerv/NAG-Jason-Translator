%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "sintatico.tab.h"

extern int yylineno;
extern int yylex();
extern int yyparse();
extern int yyerror();

void ftranslatefunction(char *s);

FILE *yyin;
FILE *file_jason;
%}

%union {
	char* s;
	int ival;
}

%type <s> nomeCrenca objetivos planos nomeObjetivo nomePlano eventoGatilho contexto corpo expressaoLogica formulasCorpo listaCrenca listaObjetivo listaPlano

%token <s> NAME CRENCAS OBJETIVOS PLANOS
%token <ival> NUMBER

%token E OU NAO
%right '['

%%
agente: NAME CRENCAS crencas OBJETIVOS objetivos PLANOS planos { fprintf(file_jason, $1); }

/* INITIAL BELIEFS */
crencas         : '{' listaCrenca '}'    { ftranslatefunction($2); }

listaCrenca     : nomeCrenca ';' listaCrenca
                ;

nomeCrenca      : NAME                  { $$ = $1 }

/* GOALS */
objetivos       : '{' listaObjetivo '}' { ftranslatefunction($2); }

listaObjetivo   : nomeObjetivo ';' listaObjetivo
                ;

nomeObjetivo: NAME                  { $$ = $1 }

/* PLANS */
planos      : { fprintf(file_jason,"@"); } '{' listaPlano '}'  { fprintf(file_jason,"  \r\n"); }

listaPlano  : nomePlano ';' listaPlano  { ftranslatefunction($1); }
            ;

nomePlano   : NAME tuplaPlano        { $$ = $1 }

tuplaPlano  : { fprintf(file_jason,"+!"); } '(' eventoGatilho ';'
            | { fprintf(file_jason,"\n     : "); } contexto ';' 
            | { fprintf(file_jason,"\n     <- "); } corpo ')' { fprintf(file_jason,".\n     ");}
            ;

eventoGatilho: NAME {ftranslatefunction($1);}

contexto    : expressaoLogica       { $$ = $1 }
            | NAME                  { $$ = $1 }
            ;

expressaoLogica     : NAME E NAME { ftranslatefunction(NAME); } { fprintf(file_jason," & "); } { ftranslatefunction(NAME); } 
                    | NAME OU NAME { ftranslatefunction(NAME); } { fprintf(file_jason," | "); } { ftranslatefunction(NAME); } 
                    | NAO NAME { fprintf(file_jason,"NAO "); } { ftranslatefunction(NAME); } 
                    ;

corpo               : '{' formulasCorpo '}'       { $$ = $2 }

formulasCorpo       : NAME ';' formulasCorpo { ftranslatefunction($1); }
                    ;

%%
int main(int argc, char *argv[]){
    FILE *file_nag = NULL;
	file_jason = NULL;

    int is_accepted_file = 1;
	
    char accepted_ext[4] = "txt";	// aceita a extensão .txt
    char input_ext[4];

    int size_f_jason = (int) strlen("bob.txt");
    char *name_f_jason = (char *) malloc(sizeof(char) * (size_f_jason + 4));
    strcpy(name_f_jason, "bob.txt");

    for(int i = 1, j=0; i <= 3; i++, j++){
        char aux = *(name_f_jason + (size_f_jason - i));
        *(input_ext+j) = aux;
    }

	if(!(strcmp(input_ext, accepted_ext))) {
		is_accepted_file = 0;
    }
    
	if(!is_accepted_file){
        printf("[!] Extensao invalida \n");
        exit(1);
    }

    *(name_f_jason + (size_f_jason - 0)) = 0; // inserindo \n no fim da string
    *(name_f_jason + (size_f_jason - 1)) = 108;   //inserindo letra l
    *(name_f_jason + (size_f_jason - 2)) = 115;   //inserindo letra s
    *(name_f_jason + (size_f_jason - 3)) = 97;   //inserindo letra a

    file_nag = fopen(argv[1], "r+");
    file_jason = fopen(name_f_jason, "w+");

    printf("[*] Abrindo arquivos %s\n", argv[1]);

    if(!(file_nag)){  //Verificando o ponteiro do arquivo nag
        printf("[!] Arquivo nag não encontrado\n");
        exit(1);
    }else   printf("[+] Arquivo nag carregado com sucesso\n");

    if(!(file_jason)){
        printf("[!] Não for possivel criar o arquivo Jason\n");
        exit(1);
    }else printf("[+] Arquivo Jason criado com sucesso\n");
    
	yyin = file_nag;
	file_jason = fopen(name_f_jason,"w+");

	return yyparse();
}

int yyerror (char *s){
  return printf("Erro encontrado: %s linha %i\n", s, yylineno);
}

void ftranslatefunction (char *s) {
  int i = 0;
  char *param;

  while (!isupper (s[i]))
    {
      fprintf(file_jason, "%s", s[i]);
      i++;
    }
    
    param = &s[i];
    fprintf(file_jason, "%s", param);
}