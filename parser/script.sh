#!/bin/bash

gcc -o analex analisadorLexico.c

./analex code.txt

bison parser.y

g++ parser.tab.c -std=c++17 -o parser

./parser docLex.txt

rm parser parser.tab.c analex


clear
cat docParser.txt