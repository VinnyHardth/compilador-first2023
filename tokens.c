#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include "tokens.h"

typedef struct Token T_token;

struct Token {
    int tag;   
    double value;
    char *name;
};

void grava_token(T_token *tk, int linha_atual){
    char text[255];
    
    //printf("----> Linha %d: \n", linha_atual);

    switch (tk->tag) {
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
        printf("TK_IDENTIFIER %s\n", tk->name);
        break;

    case LIT_INT:
        printf("LIT_INT %d\n", (int) tk->value);
        break;

    case LIT_REAL:
        printf("LIT_REAL %.5lf\n", tk->value);
        break;

    case LIT_CHAR:
        printf("LIT_CHAR %s\n", tk->name);
        break;

    case LIT_STRING:
        printf("LIT_STRING %s\n", tk->name);
        break;

    default:
        printf("TOKEN DESCONHECIDO\n");
        break;
    }
}

void set_token(T_token *tk, int tag, double value, char *name) {
    tk->tag = tag;
    tk->value = value;
    tk->name = name;
}

T_token *cria_token(void) {
    T_token *tk = malloc(sizeof(T_token));
    return tk;
}

void libera_token(T_token *tk) {
    free(tk);
}