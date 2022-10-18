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

%token <s> CONTENT
%token <s> CONTENTLN
%token <ival> NUMBER

%token AUTHOR DOCCLASS PACKAGE DATE TITLE BEGDOC ENDDOC SECTION SUBSECTION BEGIMG ENDIMG 
%token BEGITEM ENDITEM BEGENUM ENDENUM ITEM BIBSTYLE BIBIB CAPTION INCLGRAP
%right '['

%%
agente: crencas objetivos planos

lcrencas: '{' nomeCrenca '}'

nomeCrenca: NAME 

lobjetivos: '{' nomeObjetivo ';}'

nomeObjetivo: NAME

lplanos: '{' nomePlano ';}'

nomePlano: NAME tuplaPlano

tuplaPlano: '(' eventoGatilho ';' contexto ';' corpo ')'

eventoGatilho: NAME

contexto: expressaoLogica
contexto: NAME
contexto: ;

expressaoLogica: NAME 'E' NAME
expressaoLogica: NAME 'OU' NAME
expressaoLogica: 'NAO' NAME

corpo: '{'

latex: configuracao identificacao configuracao principal

configuracao: DOCCLASS'{'ignorar'}'configuracao
configuracao: PACKAGE'{'ignorar'}'configuracao
configuracao: PACKAGE'['ignorar']''{'ignorar'}'configuracao
configuracao: ;

identificacao: TITLE {fprintf(file_md,"# **");} '{' texto '}' {fprintf(file_md,"**\n");} identificacao
identificacao: AUTHOR {fprintf(file_md,"### ");} '{' texto '}' {fprintf(file_md,"  \r\n");} identificacao
identificacao: DATE {fprintf(file_md,"##### ");} '{' texto '}' {fprintf(file_md,"  \r\n");} identificacao
identificacao: ;

principal: {fprintf(file_md, "\n\n");} BEGDOC corpoLista ENDDOC

corpoLista: SECTION '{' {fprintf(file_md,"\n## ");} texto '}' {fprintf(file_md,"\n");} corpoLista
corpoLista: SUBSECTION '{' {fprintf(file_md,"\n### ");} texto '}' {fprintf(file_md,"\n");} corpoLista
corpoLista: imagens corpoLista
corpoLista: texto corpoLista
corpoLista: BIBSTYLE '{' ignorar '}'corpoLista
corpoLista: BIBIB '{' ignorar '}'corpoLista
corpoLista: itemize corpoLista
corpoLista: enumerate corpoLista
corpoLista: ;

itemize: BEGITEM {contTab += 1;} corpoItem ENDITEM {contTab -= 1;} {fprintf(file_md, "\n");}
corpoItem: ITEM {fphash(contTab);} texto corpoItem
corpoItem: itemize corpoItem
corpoItem: ;

enumerate: BEGENUM {contenum += 1; contTab+= 1;} corpoEnum ENDENUM {contenum -= 1; contTab -= 1;} {fprintf(file_md, "\n");}
corpoEnum: ITEM {fpenum(contenum, contTab);} texto corpoEnum
corpoEnum: enumerate corpoEnum
corpoEnum: ;

imagens: BEGIMG '['ignorar']' corpoImagem ENDIMG corpoLista
imagens: BEGIMG corpoImagem ENDIMG corpoLista

corpoImagem: includegraphics captions

includegraphics: INCLGRAP {fprintf(file_md,"\n![");} '[' texto ']' {fprintf(file_md,"](");} '{' texto {fprintf(file_md,")\n");} '}'

captions: CAPTION {fprintf(file_md,"*");} '{' texto   {fprintf(file_md,"*  \n");} '}'
captions: ;

texto: NUMBER { fprintf(file_md,"%i",$1); } texto2
texto: CONTENT { fprintf(file_md,"%s",$1); } texto2
texto: CONTENTLN { fprintf(file_md,"%s \n",$1); } texto2
texto2: NUMBER { fprintf(file_md," %i",$1); } texto2
texto2: CONTENT { fprintf(file_md," %s",$1); } texto2
texto2: CONTENTLN { fprintf(file_md," %s \n",$1); } texto2
texto2: ;

ignorar: NUMBER ignorar
ignorar: CONTENT ignorar
ignorar: ;
%%
int main(int argc, char *argv[]){
	// argv[1] LaTeX

    printf("\n");

    FILE *file_latex = NULL;
	file_md = NULL;

	char exts[3][4] = { "xet", "txt", "xel" };	//Extensoes aceitas tex, txt, lex

    int size_f_md = (int) strlen(argv[1]), aux = 1;
    char *name_f_md = (char *) malloc(sizeof(char) * (size_f_md + 4));
    strcpy(name_f_md, argv[1]);

    //Verificando a extensao do Arquivo
    char ext[4];

    for(int i = 1, j=0; i <= 3; i++, j++){
        char aux = *(name_f_md + (size_f_md - i));
        *(ext+j) = aux;
    }

	for(int i=0; i<3; i++){
		if(!(strcmp(ext, exts[i])))
			aux=0;
	}
	if(aux){
        printf("[!] A extensao do arquivo nao e valida!\n");
        exit(1);
    }

    *(name_f_md + (size_f_md - 1)) = 0; // inserindo \n no fim da string
    *(name_f_md + (size_f_md - 2)) = 100;   //inserindo letra d
    *(name_f_md + (size_f_md - 3)) = 109;   //inserindo letra m

    file_latex = fopen(argv[1], "r+");
    file_md = fopen(name_f_md, "w+");

    printf("[*] Abrindo arquivos %s\n", argv[1]);

    if(!(file_latex)){  //Verificando o ponteiro do arquivo latex
        printf("[!] Arquivo Latex não encontrado!\n");
        exit(1);
    }else   printf("[+] Arquivo Latex carregado com sucesso!\n");

    if(!(file_md)){
        printf("[!] Não for possivel criar o arquivo Markdown!\n");
        exit(1);
    }else printf("[+] Arquivo Markdown criado com sucesso!\n");

    
	yyin = file_latex;
	file_md = fopen(name_f_md,"w+");

	return yyparse();
}

int yyerror (char *s){
  return printf("Erro encontrado: %s linha %i\n", s, yylineno);
}

void fphash(int hashcount){
	for(; hashcount > 0; hashcount--){
		fprintf(file_md,"	");
	}
	fprintf(file_md,"* ");
}

void fpenum(int contenum, int contTab){
	for(; contTab > 0; contTab--){
		fprintf(file_md,"	");
	}
	fprintf(file_md,"1. ");
}
