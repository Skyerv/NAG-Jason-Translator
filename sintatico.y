%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yylineno;
extern int yylex();
extern int yyparse();
extern int yyerror();

int contTab = -1;
int contenum = 0;
FILE *yyin;
FILE *file_md;
void fphash(int hashcount);
void fpenum(int contenum, int contTab);
%}

%union {
	char* s;
	int ival;
}

%token <s> NAME
%token <ival> NUMBER

%token 
%token 
%right '['

%%
agente: crencas objetivos planos

/* INITIAL BELIEFS */
crencas: '{' nomeCrenca '}'

nomeCrenca: NAME {fprintf(file_jason," %s", $1);}

/* GOALS */
objetivos: '{' nomeObjetivo ';}'

nomeObjetivo: NAME {fprintf(file_jason," %s", $1);}

/* PLANS */
planos: {fprintf(file_jason,"@");} '{' nomePlano ';}' {fprintf(file_md,"  \r\n");}

nomePlano: NAME tuplaPlano

tuplaPlano: {fprintf(file_jason,"+!");} '(' eventoGatilho ';'
    {fprintf(file_jason,"\n     : ");} contexto ';' 
    {fprintf(file_jason,"\n     <- ");} corpo ')' {fprintf(file_jason,".\n     ");}

eventoGatilho: NAME {fprintf(file_jason," %s", $1);}

contexto: expressaoLogica
contexto: NAME
contexto: ;

expressaoLogica: NAME 'E' NAME {fprintf(file_jason,"%s & %s", $1, $3);}
expressaoLogica: NAME 'OU' NAME {fprintf(file_jason,"%s | %s", $1, $3);}
expressaoLogica: 'NAO' NAME {fprintf(file_jason,"not %s", $2);}

corpo: '{' formulasCorpo ';}'

formulasCorpo: NAME {fprintf(file_jason," %s", $1);}

%%
int main(int argc, char *argv[]){
	// argv[1] LaTeX

    printf("\n");

    FILE *file_nag = NULL;
	file_jason = NULL;

	char exts[3][4] = { "asl" };	// aceita a extensão .asl

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
    *(name_f_jason + (size_f_jason - 2)) = 100;   //inserindo letra d
    *(name_f_jason + (size_f_jason - 3)) = 109;   //inserindo letra m

    file_nag = fopen(argv[1], "r+");
    file_jason = fopen(name_f_jason, "w+");

    printf("[*] Abrindo arquivos %s\n", argv[1]);

    if(!(file_nag)){  //Verificando o ponteiro do arquivo nag
        printf("[!] Arquivo nag não encontrado!\n");
        exit(1);
    }else   printf("[+] Arquivo nag carregado com sucesso!\n");

    if(!(file_jason)){
        printf("[!] Não for possivel criar o arquivo Markdown!\n");
        exit(1);
    }else printf("[+] Arquivo Markdown criado com sucesso!\n");

    
	yyin = file_nag;
	file_jason = fopen(name_f_jason,"w+");

	return yyparse();
}

int yyerror (char *s){
  return printf("Erro encontrado: %s linha %i\n", s, yylineno);
}

void fphash(int hashcount){
	for(; hashcount > 0; hashcount--){
		fprintf(file_jason,"	");
	}
	fprintf(file_jason,"* ");
}

void ftranslatefunction(char *s){
    int i = 0;
    char *name, *param, *converted;

    while(!isUpper(s[i])){
        i++;
    }

    name = strtok(s, s[i]);
    param = strtok(NULL, " ");
    converted = strcat(name, param);

    fprintf(file_jason,"%s(%s)", name, param);
}