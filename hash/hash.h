#ifndef HASH_H
#define HASH_H

// Define the hash_item structure
typedef struct hash_item {
    char *lexema;           // The lexeme (also the key)
    char *id;               // Identifier for the lexeme
    struct hash_item *prox; // Points to the next item in case of collision
} hash_item;

// Define the hash_table structure
typedef struct hash_table {
    struct hash_item **items;
    int size; // Size of the table
} hash_table;

// Function prototypes
hash_item *create_item(char *lexema, int n);
hash_table *create_table(int size);
unsigned int hash_index(const char *key, int size);
void insert_hash(hash_table *table, char *lexema, int *n);

#endif
