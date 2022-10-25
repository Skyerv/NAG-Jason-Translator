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

void ftranslatefunction (char *s);

void printfGoals (char *s);
void printfBeliefs (char *s);
void printTeste(char *s);
void printfEventoGatilho (char *s);
void printfFormulasCorpo (char *s);

void replaceWithDot();

FILE *yyin;
FILE *file_jason;
%}

%union {
	char* s;
	int ival;
}



%type <s> listaCrenca nomeCrenca listaObjetivo nomeObjetivo listaPlano nomePlano contexto corpo

%token <s> NAME CRENCAS OBJETIVOS PLANOS
%token <ival> NUMBER

%token E OU NAO

%%




agente: NAME CRENCAS crencas OBJETIVOS objetivos PLANOS planos
/* INITIAL BELIEFS */
crencas             : '{' listaCrenca '}'    {fprintf(file_jason, "\n");}

listaCrenca         : 
                    | nomeCrenca ';' listaCrenca  { printfBeliefs($1); }
                    ;

nomeCrenca          : NAME                  { $$ = $1 }
                    ;

/* GOALS */
objetivos           : '{' listaObjetivo '}' {fprintf(file_jason, "\n");}

listaObjetivo       : 
                    | nomeObjetivo ';' listaObjetivo  { printfGoals($1); }
                    ;

nomeObjetivo        : NAME                  { $$ = $1 }
                    ;

/* PLANS */
planos              : '{' listaPlano '}' 

listaPlano          : 
                    | nomePlano ';' listaPlano  
                    ;

nomePlano           : NAME {fprintf(file_jason, "@%s\n", $1); } tuplaPlano 
                    ;        

 tuplaPlano  :       '(' eventoGatilho ';'  contexto {fprintf(file_jason, " <-\n");} ';' corpo ')' 
                    ;

eventoGatilho: NAME {printfEventoGatilho($1);}

contexto            : expressaoLogica       
                    | NAME                  { $$ = $1 }
                    ;

expressaoLogica     : NAME E NAME   { ftranslatefunction($1); fprintf(file_jason," & "); ftranslatefunction($3); }
                    | NAME OU NAME  { ftranslatefunction($1); fprintf(file_jason," | "); ftranslatefunction($3); }
                    | NAO NAME      { fprintf(file_jason,"~"); } { ftranslatefunction($2); } 
                    ;

corpo               : '{' formulasCorpo {replaceWithDot()} '}' 

formulasCorpo       :
                    | NAME { printfFormulasCorpo($1); } ';' formulasCorpo 
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
  while (!isupper (s[i]) && i < strlen(s))
    {
      fprintf(file_jason, "%c", s[i]);
      i++;
    }
    if(i != strlen(s)){
      param = &s[i];
      fprintf(file_jason, "(%s)", param);
    }
}

void printfEventoGatilho (char *s){
  fprintf(file_jason, "+!");
  ftranslatefunction(s);
  fprintf(file_jason, " : ");
}

void printfFormulasCorpo (char *s){
  fprintf(file_jason, "   ");
  ftranslatefunction(s);
  fprintf(file_jason, ";\n");
}

void printfBeliefs (char *s){
  ftranslatefunction(s);
  fprintf(file_jason, ".\n");
}

void printfGoals (char *s){
  fprintf(file_jason, "!");
  ftranslatefunction(s);
  fprintf(file_jason, ".\n");
}

void replaceWithDot(){
  fseek(file_jason, -3, SEEK_END);
  fputs(".\n\n", file_jason);
}