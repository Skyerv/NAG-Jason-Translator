conversor: sintatico.y lexico.l
	clear
	bison -d sintatico.y
	flex lexico.l
	gcc -o conversor lex.yy.c sintatico.tab.c
	./conversor nag_1.txt
	rm conversor lex.yy.c sintatico.tab.c sintatico.tab.h
