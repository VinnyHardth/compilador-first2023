#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

typedef struct hash_item{
    char *lexema;             // também é a chave
    char *id;                 // identificador do lexema
    struct hash_item *prox;   // aponta para o proximo item em caso de colisão
} hash_item;

typedef struct hash_table{
    struct hash_item **items; // array de ponteiros para hash_item
    int size;                 // tamanho da tabela
} hash_table;

hash_item* create_item(char *lexema, int n){
    char id[5];
    sprintf(id, "id%d", n);

    hash_item* item = (hash_item*) malloc(sizeof(hash_item));
    item->lexema = (char*) malloc(strlen(lexema) + 1);
    item->id = (char*) malloc(strlen(id) + 1);
    strcpy(item->lexema, lexema);
    strcpy(item->id, id);
    item->prox = NULL;

    return item;
}

hash_table* create_table(int size){

    hash_table* table = (hash_table*) malloc(sizeof(hash_table));
    table->size = size;
    table->items = (hash_item**) calloc(size, sizeof(hash_item));

    for(int i = 0; i < size; i++){
        table->items[i] = NULL;
    }

    return table;
}

unsigned int hash_index(const char *key, int size)
{
    unsigned int hash = 5381;
    int c;

    while ((c = *key++))        
    {
        if (isupper(c))
        {
            c = c + 32;
        }

        hash = ((hash << 5) + hash) + c; 
    }

    return hash % size;
}

void insert_hash(hash_table* table, char* lexema, int *n){

    hash_item* new_item = create_item(lexema, *n);
    *n+=1;
    int index = hash_index(lexema, table->size);
    hash_item* current_item = table->items[index];

    if(current_item == NULL){ 
        table->items[index] = new_item; //key não existe;
    }
    else{
        while(current_item->prox != NULL && strcmp(new_item->lexema, current_item->lexema) != 0){
            current_item = current_item->prox;
        }
        if(strcmp(new_item->lexema, current_item->lexema) != 0){
            current_item->prox = new_item;
        }
        else{
            *n-=1;
        }
    }
}