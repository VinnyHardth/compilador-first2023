#ifndef HASH_H
#define HASH_H

// Definição de estruturas
typedef struct hash_item{
    char *lexema;             // também é a chave
    char *id;                 // identificador do lexema
    struct hash_item *prox;   // aponta para o proximo item em caso de colisão
} hash_item;

typedef struct hash_table{
    struct hash_item **items; // array de ponteiros para hash_item
    int size;                 // tamanho da tabela
} hash_table;


// Protótipos de funções

// Função para criar um item da tabela hash
hash_item *create_item(char *lexema, int n);

// Função para criar uma tabela hash
hash_table *create_table(int size);

// Função para gerar o índice da tabela hash
unsigned int hash_index(const char *key, int size);

// Função para inserir um item na tabela hash
void insert_hash(hash_table *table, char *lexema, int *n);

#endif
