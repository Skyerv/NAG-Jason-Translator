%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

extern int yylineno;
extern int yylex();
extern int yyparse();
extern int yyerror();

FILE *yyin;
FILE *file_nag;
%}

%union {
	char* s;
	int ival;
}

%token <s> NAME
%token <ival> NUMBER

%token E OU NAO
%right '['

%%
agente: crencas objetivos planos

/* INITIAL BELIEFS */
crencas: '{' nomeCrenca {ftranslatefunction(nomeCrenca);} '}'

nomeCrenca: NAME

/* GOALS */
objetivos: '{' nomeObjetivo {ftranslatefunction(nomeObjetivo);} ';}'

nomeObjetivo: NAME

/* PLANS */
planos: {fprintf(file_jason,"@");} '{' nomePlano ';}' {ftranslatefunction(nomePlano);} {fprintf(file_md,"  \r\n");}

nomePlano: NAME tuplaPlano

tuplaPlano: {fprintf(file_jason,"+!");} '(' eventoGatilho ';'
    {fprintf(file_jason,"\n     : ");} contexto ';' 
    {fprintf(file_jason,"\n     <- ");} corpo ')' {fprintf(file_jason,".\n     ");}

eventoGatilho: NAME {ftranslatefunction(NAME);}

contexto: expressaoLogica
contexto: NAME 
contexto: ;

expressaoLogica: NAME E NAME {ftranslatefunction(NAME);} {fprintf(file_jason," & ");} {ftranslatefunction(NAME);} 
expressaoLogica: NAME OU NAME {ftranslatefunction(NAME);} {fprintf(file_jason," | ");} {ftranslatefunction(NAME);} 
expressaoLogica: NAO NAME {fprintf(file_jason,"NAO ");} {ftranslatefunction(NAME);} 

corpo: '{' formulasCorpo ';}'

formulasCorpo: NAME {ftranslatefunction(NAME);}

%%
int main(int argc, char *argv[]){
	// argv[1] LaTeX

    printf("\n");

    FILE *file_nag = NULL;
	file_jason = NULL;

	char exts[3][4] = { "txt" };	// aceita a extensão .asl

    int size_f_jason = (int) strlen(argv[1]), aux = 1;
    char *name_f_jason = (char *) malloc(sizeof(char) * (size_f_jason + 4));
    strcpy(name_f_jason, argv[1]);

    //Verificando a extensao do Arquivo
    char ext[4];

    for(int i = 1, j=0; i <= 3; i++, j++){
        char aux = *(name_f_jason + (size_f_jason - i));
        *(ext+j) = aux;
    }

	for(int i=0; i<3; i++){
		if(!(strcmp(ext, exts[i])))
			aux=0;
	}
	if(aux){
        printf("[!] Extensao invalida \n");
        exit(1);
    }

    *(name_f_jason + (size_f_jason - 1)) = 0; // inserindo \n no fim da string
    *(name_f_jason + (size_f_jason - 2)) = 97;   //inserindo letra a
    *(name_f_jason + (size_f_jason - 3)) = 115;   //inserindo letra s
    *(name_f_jason + (size_f_jason - 4)) = 108;   //inserindo letra l

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
      printf ("%c", s[i]);
      i++;
    }
    
    param = &s[i];
    printf("(%s)\n", param);
}