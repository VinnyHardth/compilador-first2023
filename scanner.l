%{
#include<stdio.h>    
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include<stdbool.h>
#include"hash.h"
#include"tokens.h"


// declaração de funções auxiliares para o analisador léxico
int getLineNumber(void);
int isRunning(void);
void setIsRunning(int value);
void ignorarComentarioMultiLinha(void);


// Variáveis globais para o analisador léxico
int linha_atual = 1;
bool programaEmExecucao = true; // controle do estado de execução

%}

%option noyywrap

digito [0-9]
inteiro {digito}+
decimal {inteiro}*\.{inteiro}+

string \"[^\n]*\"
char \'[^\n]\'

id [a-zA-Z]([a-zA-Z_.])*

separador [ \t]
nova_linha [\n]

comentario "\\\\"[^\n]*
multi_comentario "\\\\\\"([^\n])?

%%

{separador}+ { /* ignora */ }
{nova_linha} { linha_atual++; }

{multi_comentario} { ignorarComentarioMultiLinha(); }
{comentario} { /* ignora */ }

{decimal} { return LIT_REAL; }
{inteiro} { return LIT_INT; }
{string} { return LIT_STRING; }
{char} { return LIT_CHAR; }

char { return KW_CHAR; }
int { return KW_INT; }
real { return KW_REAL; }
bool { return KW_BOOL; }

if { return KW_IF; }
then { return KW_THEN; }
else { return KW_ELSE; }
while { return KW_LOOP; }

input { return KW_INPUT; }
output { return KW_OUTPUT; }
return { return KW_RETURN; }

{id} { return TK_IDENTIFIER; }

"<=" { return OPERATOR_LE; }
">=" { return OPERATOR_GE; }
"==" { return OPERATOR_EQ; }
"!=" { return OPERATOR_DIF; }

[,\(\)\[\]\{\}+\-*\/%<>&|~=;] { return (int) yytext[0]; }

. { return TOKEN_ERROR; }
%%

int getLineNumber(void) {
    return linha_atual;
}

int isRunning(void) {
    return programaEmExecucao;
}

void setIsRunning(int value) {
    programaEmExecucao = value;
}

void ignorarComentarioMultiLinha(void) {
    int c;
    while ((c = input()) != EOF) {
        if (c == '\n') {
            linha_atual++;
        } else if (c == '/') {
            c = input();
            if (c == '/') {
                c = input();
                if (c == '/') {
                    return;
                }
            }
        }
    }
}

int main(int argc, char **argv) {
    yyin = fopen(argv[1], "r");
    int aux = linha_atual;

    if (yyin == NULL) {
        printf("Erro ao abrir o arquivo.\n");
        exit(1);
    }

    while (isRunning()) {
        int tag = yylex();

        if (tag == TOKEN_ERROR) {
            printf("Erro na linha %d: %s\n", getLineNumber(), yytext);
            setIsRunning(0);
        } else if (tag == 0) {
            setIsRunning(0);
        } else {
            T_token *t = cria_token();

            switch (tag){
                case LIT_REAL: 
                    set_token(t, tag, strtod(yytext, NULL), NULL);
                    break;
                case LIT_INT:
                    set_token(t, tag, atoi(yytext), NULL);
                    break;
                case LIT_STRING:
                    set_token(t, tag, 0, yytext);
                    break;
                case LIT_CHAR:
                    set_token(t, tag, 0, yytext);
                    break;
                case TK_IDENTIFIER:
                    set_token(t, tag, 0, yytext);
                    break;
                default:
                    set_token(t, tag, 0, NULL);
                    break;
            }


            if (linha_atual != aux) {
                printf("----> Linha %d: \n", linha_atual);
                aux = linha_atual;
            }
            grava_token(t, getLineNumber());
            
        }
    }

    //printf("Número de linhas: %d\n", getLineNumber());


    return 0;
}