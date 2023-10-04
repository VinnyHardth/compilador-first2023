#
#  - Compiladores  - Etapa analisador Léxico
#
# Makefile for single compiler call
# All source files must be included from code embedded in scanner.l
# In our case, you probably need #include "hash.c" at the beginning
# and #include "main.c" in the last part of the scanner.l
#

etapa1: lex.yy.c
	gcc -o etapa1 lex.yy.c tokens.c -lfl
lex.yy.c: scanner.l
	flex scanner.l

clean:
	rm lex.yy.c etapa1
