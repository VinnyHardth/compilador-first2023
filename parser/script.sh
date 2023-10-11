#!/bin/bash

# Compilação do analisador léxico
gcc -o analex analisadorLexico.c ../hash/hash.c 

# Execução do analisador léxico com o código fonte de exemplo
# O script executa o analisador léxico (analex) no arquivo codeExample.txt, produzindo um arquivo de saída chamado lexOutput.txt que contém os tokens e lexemas encontrados durante a análise léxica.
./analex codeExample.txt

# Compilação do analisador sintático (YACC)
# O Yacc (bison) compila o arquivo parser.y e gera o arquivo parser.tab.c que contém o código fonte do analisador sintático.
bison parser.y

# Compilação do analisador sintático (C++)
g++ parser.tab.c -std=c++17 -o parser

# Execução do analisador sintático
# O analisador sintático (parser) é executado com base no arquivo de saída do analisador léxico (lexOutput.txt). Isso cria um arquivo parserOutput.txt que contém mensagens indicando se o código fonte fornecido é sintaticamente correto ou se há erros.
./parser lexOutput.txt

# Remoção dos arquivos gerados
rm parser parser.tab.c analex

# Exibição do arquivo de saída do analisador sintático
cat parserOutput.txt