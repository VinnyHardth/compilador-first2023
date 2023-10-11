#define _GNU_SOURCE 
#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include<ctype.h>
#include<stdbool.h>
#include "../hash/hash.h"

int linha_atual = 0; // variável global para percorrer a linha
FILE *docLex, *file; // ponteiro para o arquivo de saída e para o arquivo de entrada
char linha[2000];    // buffer arbitrário
bool firstSaved;     // variável para verificar se é o primeiro token a ser salvo
int count_id = 0;    // contador de id's

// Função para gravar a tabela de símbolos em um arquivo
void grava_tabela(hash_table *table){

    FILE *arq = fopen("symbolTable.txt", "wt");
    if (arq == NULL) {
        printf("Problemas na CRIACAO do arquivo\n");
        return;
    }

    fprintf(arq, "IDENTIFICADOR\t|\tLEXEMA\n\n");

    for (int i = 0; i < table->size; i++) {
        hash_item *aux = table->items[i];
        while (aux) {
            fprintf(arq, "%s\t\t\t\t\t%s\n", aux->id, aux->lexema);
            aux = aux->prox;
        }
    }

    printf("--> Tabela de símbolos gerada...\n");
    fclose(arq);
}

// Função para gravar os tokens em um arquivo
void gravar_token(char *token, char *lexema) {
    char buffer[strlen(token)+strlen(lexema)+2];
    
    if (!firstSaved) {
        strcpy(buffer, "");
        firstSaved = true;
    } else {
        strcpy(buffer, "\n");
    }
    
    strcat(buffer, token);
    strcat(buffer, " ");
    strcat(buffer, lexema);
    
    FILE *docLex = fopen("lexOutput.txt", "ab");
    fwrite(buffer, sizeof(char), strlen(buffer), docLex);
    fclose(docLex);
}

// Função para obter o próximo caractere do arquivo
char prox_char() {
    if (strlen(linha) == 0) {
        if (fgets(linha, sizeof(linha), file) == NULL) {
            return '\0'; // Retorna nulo se chegou ao final do arquivo
        }
    }

    char c = linha[linha_atual];
    if (c != '\0') {
        linha_atual++;
    } else if (linha[linha_atual - 1] == '\n') {
        // Se o caractere atual é '\0' e o caractere anterior era '\n',
        // isso significa que estamos no final da linha, então avance para a próxima linha.
        strcpy(linha, ""); // Limpa a linha atual
        linha_atual = 0;   // Reinicia o índice da linha
        c = prox_char();    // Chama recursivamente para obter o próximo caractere da próxima linha
    } else {
        linha_atual = 0;
        strcpy(linha, "");
    }

    return c;
}

// Função para salvar o lexema
void salvaLexema(int *j, char *lexema, char *c) {
    lexema[*j] = *c;
    (*j)++;
    lexema[*j] = '\0';
}

// Função para avançar o caractere
void avanca(int *j, char *lexema, char *c) {
    salvaLexema(j, lexema, c);
    *c = prox_char();
}

// Função para verificar o estado atual
int estado0(char c) {
    int estado;

    if (isalpha(c) || c == '$' || c == '_') { estado = 1; }
    else if (isdigit(c)) { estado = 3; }
    else if (c == '"') { estado = 8; }
    else if (c == '\'') { estado = 10; }
    else if (c == '/') { estado = 13; }
    else if (c == '+') { estado = 20; }
    else if (c == '-') { estado = 24; }
    else if (c == '*') { estado = 29; }
    else if (c == '%') { estado = 32; }
    else if (c == '=') { estado = 35; }
    else if (c == '!') { estado = 38; }
    else if (c == '>') { estado = 41; }
    else if (c == '<') { estado = 44; }
    else if (c == '|') { estado = 47; }
    else if (c == '&') { estado = 49; }
    else if (c == ',') { estado = 52; }
    else if (c == ';') { estado = 53; }
    else if (c == '.') { estado = 54; }
    else if (c == '(') { estado = 55; }
    else if (c == ')') { estado = 56; }
    else if (c == ']') { estado = 57; }
    else if (c == '[') { estado = 58; }
    else if (c == '{') { estado = 59; }
    else if (c == '}') { estado = 60; }
    else if (c == ':') { estado = 61; }
    else if (c == '?') { estado = 62; }
    else if (c == '\n' || c == ' ' || c == '\t') { estado = 0; }
    else if (c == '\0' && feof(file)) { estado = 99; }
    else if (c == '\0') { estado = 0; }
    else {
        char erro[2];
        erro[0] = c;
        erro[1] = '\0';
        gravar_token("ERRO símbolo desconhecido", erro);
        exit(0);
    }

    return estado;
}

// Função para verificar se é uma palavra reservada ou um ID
char* palavraReservada(char *lexema){
    if(strcmp("void", lexema) == 0){
        return "KW_VOID";
    }
    else if(strcmp("int", lexema) == 0){
        return "KW_INT";
    }
    else if(strcmp("real", lexema) == 0){
        return "KW_REAL";
    }
    else if(strcmp("char", lexema) == 0){
        return "KW_CHAR";
    }
    else if(strcmp("bool", lexema) == 0){
        return "KW_BOOL";
    }
    else if(strcmp("if", lexema) == 0){
        return "KW_IF";
    }
    else if(strcmp("else", lexema) == 0){
        return "KW_ELSE";
    }
    else if(strcmp("for", lexema) == 0){
        return "KW_FOR";
    }
    else if(strcmp("while", lexema) == 0){
        return "KW_WHILE";
    }
    else if(strcmp("do", lexema) == 0){
        return "KW_DO";
    }
    else if(strcmp("return", lexema) == 0){
        return "KW_RETURN";
    }
    else if(strcmp("break", lexema) == 0){
        return "KW_BREAK";
    }
    else if(strcmp("continue", lexema) == 0){
        return "KW_CONTINUE";
    }
    else if(strcmp("goto", lexema) == 0){
        return "KW_GOTO";
    }
    else if(strcmp("true", lexema) == 0){
        return "KW_TRUE";
    }
    else if(strcmp("false", lexema) == 0){
        return "KW_FALSE";
    }
    else{
        return "TK_ID";
    }
}

// Função para analisar o lexema
bool analex(char *token, char *lexema, hash_table *table) {
    char c = prox_char();
    int estado = 0;
    int j = 0;
    while (1) {
        switch (estado) {
            case 0:
                estado = estado0(c);
                if (estado == 0) {
                    c = prox_char();
                } else {
                    avanca(&j, lexema, &c);
                }
                break;
            case 1:
                if (isdigit(c) || isalpha(c) || c == '$' || c == '_') {
                    avanca(&j, lexema, &c);
                } else if (!(isdigit(c) || isalpha(c) || c == '$' || c == '_')) {
                    estado = 2;
                }
                break;
            case 2: // Estado Final de ID ou palavra reservada
                strcpy(token, palavraReservada(lexema));
                if (strcmp(token, "TK_ID") == 0) {
                    insert_hash(table, lexema, &count_id);
                }
                linha_atual--;
                return true;
                break;
            case 3:
                if (isdigit(c)) {
                    avanca(&j, lexema, &c);
                } else if (isalpha(c)) {
                    printf("ERRO no número\n");
                    gravar_token("ERRO no numero", lexema);
                    exit(0);
                } else if (c == '.') {
                    estado = 5;
                    avanca(&j, lexema, &c);
                } else {
                    estado = 4;
                }
                break;
            case 4: // Estado Final de NUM_INT
                strcpy(token, "NUM_INT");
                linha_atual--;
                return true;
                break;
            case 5:
                if (isdigit(c)) {
                    estado = 6;
                    avanca(&j, lexema, &c);
                } else {
                    printf("ERRO numero real incompleto\n");
                    gravar_token("ERRO numero real incompleto", lexema);
                    exit(0);
                }
                break;
            case 6:
                if (isdigit(c)) {
                    avanca(&j, lexema, &c);
                } else if (isalpha(c)) {
                    printf("ERRO no numero real\n");
                    gravar_token("ERRO no numero real", lexema);
                    exit(0);
                } else {
                    estado = 7;
                }
                break;
            case 7: // Estado Final de NUM_REAL
                strcpy(token, "NUM_REAL");
                linha_atual--;
                return true;
                break;
            case 8:
                if (c == '"') {
                    estado = 9;
                } else if (c == '\0') {
                    printf("ERRO na String\n");
                    gravar_token("ERRO na String", lexema);
                    exit(0);
                } else {
                    ;
                }
                avanca(&j, lexema, &c);
                break;
            case 9: // Estado Final de STRING
                strcpy(token, "STRING");
                linha_atual--;
                return true;
                break;
            case 10:
                if (c == '\'') {
                    estado = 12;
                } else if (c == '\\') {
                    estado = 63;
                } else if (c == '\0') {
                    printf("ERRO no char \n");
                    gravar_token("ERRO no char", lexema);
                    exit(0);
                } else {
                    estado = 11;
                }
                avanca(&j, lexema, &c);
                break;
            case 63:
                if (c == 't' || c == 'n' || c == '0' || c == '\\' || c == '\'') {
                    estado = 11;
                    avanca(&j, lexema, &c);
                } else {
                    gravar_token("ERRO no char", lexema);
                    exit(0);
                }
            case 11:
                if (c == '\'') {
                    estado = 12;
                } else {
                    printf("ERRO no char \n");
                    gravar_token("ERRO no char", lexema);
                    exit(0);
                }
                avanca(&j, lexema, &c);
                break;
            case 12: // Estado Final de CHAR
                strcpy(token, "CHAR");
                linha_atual--;
                return true;
                break;
            case 13:
                if (c == '/') {
                    estado = 14;
                } else if (c == '=') {
                    estado = 19;
                } else if (c == '*') {
                    estado = 16;
                } else {
                    estado = 18;
                }
                break;
            case 14:
                avanca(&j, lexema, &c);
                if (c == '\n' || c == '\0') {
                    strcpy(lexema, "");
                    return true;
                } else if (feof(file)) {
                    strcpy(token, "FIM_DO_ARQUIVO");
                } else {
                    avanca(&j, lexema, &c);
                }
                break;
            case 16:
                avanca(&j, lexema, &c);
                if (c == '*') {
                    estado = 17;
                } else {
                    ;
                }
                break;
            case 17:
                avanca(&j, lexema, &c);
                if (c == '/') {
                    return true;
                } else {
                    printf("ERRO no comentário\n");
                    gravar_token("ERRO no comentário", lexema);
                    exit(0);
                }
            case 18: // Estado Final de OP_DIV
                strcpy(token, "OP_DIV");
                linha_atual--;
                return true;
                break;
            case 19: // Estado Final de OP_DIV_REC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_DIV_REC");
                return true;
                break;
            case 20:
                if (c == '+') {
                    estado = 21;
                } else if (c == '=') {
                    estado = 23;
                } else {
                    estado = 22;
                }
                break;
            case 21: // Estado Final de OP_INC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_INC");
                return true;
                break;
            case 22: //// Estado Final de OP_SOMA
                strcpy(token, "OP_SOMA");
                linha_atual--;
                return true;
                break;
            case 23: // Estado Final de OP_SOMA_REC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_SOMA_REC");
                return true;
                break;
            case 24:
                if (c == '-') {
                    estado = 26;
                } else if (c == '=') {
                    estado = 27;
                } else if (c == '>') {
                    estado = 28;
                } else {
                    estado = 25;
                }
                break;
            case 25: // Estado Final de OP_SUB
                strcpy(token, "OP_SUB");
                linha_atual--;
                return true;
                break;
            case 26: // Estado Final de OP_DEC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_DEC");
                return true;
                break;
            case 27: // Estado Final de OP_SUB_DEC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_SUB_REC");
                return true;
                break;
            case 28: // Estado Final de SETA
                salvaLexema(&j, lexema, &c);
                strcpy(token, "SETA");
                return true;
                break;
            case 29:
                if (c == '=') {
                    estado = 30;
                } else {
                    estado = 31;
                }
                break;
            case 30: // Estado Final de OP_MULT_REC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_MULT_REC");
                return true;
                break;
            case 31: // Estado Final de OP_MULT
                strcpy(token, "OP_MULT");
                linha_atual--;
                return true;
                break;
            case 32:
                if (c == '=') {
                    estado = 34;
                } else {
                    estado = 33;
                }
                break;
            case 33: // Estado Final de OP_MOD
                strcpy(token, "OP_MOD");
                linha_atual--;
                return true;
                break;
            case 34: // Estado Final de OP_RESTO_REC
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_RESTO_REC");
                return true;
                break;
            case 35:
                if (c == '=') {
                    estado = 36;
                } else {
                    estado = 37;
                }
                break;
            case 36: // Estado Final de COMP_IGUAL
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_EQ");
                return true;
                break;
            case 37: // Estado Final de OP_ATRIB
                strcpy(token, "OP_ATRIB");
                linha_atual--;
                return true;
                break;
            case 38:
                if (c == '=') {
                    estado = 39;
                } else {
                    estado = 40;
                }
                break;
            case 39: // Estado Final de OP_DIF
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_DIF");
                return true;
                break;
            case 40: // Estado Final de OP_NOT
                strcpy(token, "OP_NOT");
                linha_atual--;
                return true;
                break;
            case 41:
                if (c == '=') {
                    estado = 42;
                } else {
                    estado = 43;
                }
                break;
            case 42: // Estado Final de MAIOR_IGUAL
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_GE");
                return true;
                break;
            case 43: // Estado Final de MAIOR
                strcpy(token, "OP_MAIOR");
                linha_atual--;
                return true;
                break;
            case 44:
                if (c == '=') {
                    estado = 46;
                } else {
                    estado = 45;
                }
                break;
            case 45: // Estado Final de MENOR
                strcpy(token, "OP_MENOR");
                linha_atual--;
                return true;
                break;
            case 46: // Estado Final de MENOR_IGUAL
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_LE");
                return true;
                break;
            case 47:
                if (c == '|') {
                    estado = 48;
                } else {
                    printf("ERRO de símbolo incompleto \n");
                    gravar_token("ERRO de simbolo incompleto", lexema);
                    exit(0);
                }
                break;
            case 48: // Estado Final de OU
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_OR");
                return true;
                break;
            case 49:
                if (c == '&') {
                    estado = 50;
                } else {
                    estado = 51;
                }
                break;
            case 50: // Estado Final de E
                salvaLexema(&j, lexema, &c);
                strcpy(token, "OP_AND");
                return true;
                break;
            case 51:// Estado Final de ENDERECO
                strcpy(token, "ENDERECO");
                linha_atual--;
                return true;
                break;
            case 52: // Estado Final de VIRGULA
                strcpy(token, "SG_COMMA");
                linha_atual--;
                return true;
                break;
            case 53: // Estado Final de PONTO_VIRGULA
                strcpy(token, "SG_SEMICOLON");
                linha_atual--;
                return true;
                break;
            case 54: // Estado Final de PONTO
                strcpy(token, "PONTO");
                linha_atual--;
                return true;
                break;
            case 55: // Estado Final de ABRE_PAREN
                strcpy(token, "SG_ABREPAR");
                linha_atual--;
                return true;
                break;
            case 56: // Estado Final de FECHA_PAREN
                strcpy(token, "SG_FECHAPAR");
                linha_atual--;
                return true;
                break;
            case 57: // Estado Final de FECHA_COLC
                strcpy(token, "SG_FECHACOL");
                linha_atual--;
                return true;
                break;
            case 58: // Estado Final de ABRE_COLC
                strcpy(token, "SG_ABRECOL");
                linha_atual--;
                return true;
                break;
            case 59: // Estado Final de ABRE_CHAV
                strcpy(token, "SG_ABRECHV");
                linha_atual--;
                return true;
                break;
            case 60: // Estado Final de FECHA_CHAV
                strcpy(token, "SG_FECHACHV");
                linha_atual--;
                return true;
                break;
            case 61: // Estado Final de OP_DOIS_PONTOS
                strcpy(token, "OP_DOIS_PONTOS");
                linha_atual--;
                return true;
                break;
            case 62: // Estado Final de OP_SELEC
                strcpy(token, "OP_SELEC");
                linha_atual--;
                return true;
                break;
            case 99: // Fim do arquivo
                strcpy(token, "FIM_DO_ARQUIVO");
                return true;
                break;
        }
    }
}


int main(int argc, char *argv[]) {


    file = fopen("codeExample.txt", "r"); // Abertura do arquivo de entrada
    if (file == NULL) {
        printf("Erro ao abrir o arquivo de entrada.\n");
        return 1;
    }
    
    docLex = fopen("lexOutput.txt", "w"); // Abertura do arquivo de saída
    if (docLex == NULL) {
        printf("Erro ao criar o arquivo de saída.\n");
        fclose(file);
        return 1;
    }

    strcpy(linha, "");
    firstSaved = false;
    char token[15];
    char *lexema = malloc(100000 * sizeof(char));
    hash_table *table = create_table(200); // Cria tabela hash para IDs

    printf("--> Iniciando Análise Léxica...\n");
    while (1) {
        strcpy(token, "");
        strcpy(lexema, "");
        analex(token, lexema, table);
        if (!strcmp(token, "FIM_DO_ARQUIVO")) {
            printf("\n--> Fim da Análise Léxica...\n\n");
            break;
        } else if (strcmp(token, "")) {
            gravar_token(token, lexema);
        }
    }

    // Grava a tabela de símbolos em um arquivo
    grava_tabela(table);

    // Libera memória alocada e fecha arquivos
    free(lexema);
    fclose(file);
    fclose(docLex);
    free(table);
    return 0;
}

