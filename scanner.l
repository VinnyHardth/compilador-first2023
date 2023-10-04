%{
#include<stdio.h>    
#include<stdlib.h>
#include<string.h>
#include<ctype.h>
#include<stdbool.h>
#include"hash.h"
#include"tokens.h"

int getLineNumber(void);
int isRunning(void);
void setIsRunning(int value);
void ignorarComentarioMultiLinha(void);
void grava_token(int token);

int linha_atual = 1;
bool programaEmExecucao = true; // Variável global para controlar o estado de execução

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

void grava_token (int token) {
    // Imprime as informações do token no console
    printf("Token: ");
    
    switch (token) {
    case 33:
        printf("OP_NEG (!)\n");
        break;

    case 37:
        printf("OP_MOD (%%)\n");
        break;

    case 38:
        printf("OP_AND (&)\n");
        break;

    case 40:
        printf("SG_ABREPAR (()\n");
        break;

    case 41:
        printf("SG_FECHAPAR ())\n");
        break;

    case 42:
        printf("OP_MULT (*)\n");
        break;

    case 43:
        printf("OP_SOMA (+)\n");
        break;

    case 44:
        printf("SG_COMMA (,)\n");
        break;

    case 45:
        printf("OP_SUB (-)\n");
        break;

    case 47:
        printf("OP_DIV (/)\n");
        break;

    case 59:
        printf("SG_SEMICOLON (;)\n");
        break;

    case 60:
        printf("OP_MENOR (<)\n");
        break;

    case 61:
        printf("OP_ATRIB (=)\n");
        break;

    case 62:
        printf("OP_MAIOR (>)\n");
        break;

    case 91:
        printf("SG_ABRECOL ([)\n");
        break;

    case 93:
        printf("SG_FECHACOL (])\n");
        break;

    case 123:
        printf("SG_ABRECHV ({)\n");
        break;

    case 124:
        printf("OP_OR (|)\n");
        break;

    case 125:
        printf("SG_FECHACHV (})\n");
        break;

    case 126:
        printf("OP_NOT (~)\n");
        break;

    case KW_CHAR:
        printf("KW_CHAR (char)\n");
        break;

    case KW_INT:
        printf("KW_INT (int)\n");
        break;

    case KW_REAL:
        printf("KW_REAL (real)\n");
        break;

    case KW_BOOL:
        printf("KW_BOOL (bool)\n");
        break;

    case KW_IF:
        printf("KW_IF (if)\n");
        break;

    case KW_THEN:
        printf("KW_THEN (then)\n");
        break;

    case KW_ELSE:
        printf("KW_ELSE (else)\n");
        break;

    case KW_LOOP:
        printf("KW_LOOP (loop)\n");
        break;

    case KW_INPUT:
        printf("KW_INPUT (input)\n");
        break;

    case KW_OUTPUT:
        printf("KW_OUTPUT (output)\n");
        break;

    case KW_RETURN:
        printf("KW_RETURN (return)\n");
        break;

    case OPERATOR_LE:
        printf("OP_LE (<=)\n");
        break;

    case OPERATOR_GE:
        printf("OP_GE (>=)\n");
        break;

    case OPERATOR_EQ:
        printf("OP_EQ (==)\n");
        break;

    case OPERATOR_DIF:
        printf("OP_DIF (!=)\n");
        break;

    case TK_IDENTIFIER:
        printf("TK_IDENTIFIER \n");
        break;

    case LIT_INT:
        printf("LIT_INT \n");
        break;

    case LIT_REAL:
        printf("LIT_REAL \n");
        break;

    case LIT_CHAR:
        printf("LIT_CHAR \n");
        break;

    case LIT_STRING:
        printf("LIT_STRING \n");
        break;

    default:
        printf("TOKEN DESCONHECIDO\n");
        break;
    }
}

int main(int argc, char **argv) {
    yyin = fopen(argv[1], "r");

    if (yyin == NULL) {
        printf("Erro ao abrir o arquivo.\n");
        exit(1);
    }

    while (isRunning()) {
        int token = yylex();

        if (token == 0) {
            setIsRunning(0);
        } else if (token == TOKEN_ERROR) {
            printf("Erro na linha %d\n", getLineNumber());
        } else {
            grava_token(token);
        }
    }

    printf("Número de linhas: %d\n", getLineNumber());


    return 0;
}