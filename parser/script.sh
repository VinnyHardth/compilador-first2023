#!/bin/bash

gcc -o analex analisadorLexico.c ../hash/hash.c 

./analex codeExample.txt

bison parser.y

g++ parser.tab.c -std=c++17 -o parser

./parser lexOutput.txt

rm parser parser.tab.c analex

# clear
cat parserOutput.txt