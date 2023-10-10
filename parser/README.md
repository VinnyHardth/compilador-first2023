# C-- Compiler Repository

This is a project for the compiler course. The project involves the implementation of a compiler for the C-- language, which obeys the following grammar:

- Letters: ab ... zAB ... Z
- Digits: 0123456789
- Special Symbols: , ; ( ) = < > + - \* / % [ ] “ ‘ \_ $ { } ? : ! . etc
- Separators: space, enter, tab

The project generates corresponding tokens from the C-- source code.

## Lexical Directory

In the `lexical` directory, you will find the following files:

1. `analisadorLexico.c`: This is the C source code for the lexical analyzer. It reads input from a text file, identifies the tokens, and classifies them according to the symbol table.

2. `docLex.txt`: This file is one of the outputs of the lexical analyzer, containing a list of tokens and their respective lexemes.

3. `Tabela_de_simbolos.txt`: This text file contains the symbol table that the lexical analyzer uses to classify the tokens.

4. `teste.txt`: This text file contains examples of C-- code to test the lexical analyzer.

## Parser Directory

In the `parser` directory, you will find the following files:

1. `analisadorLexico.c`: This is the C source code for the lexical analyzer, which is also used in the parsing phase.

2. `code.txt`: This text file contains examples of C-- code to test the syntax analyzer (parser).

3. `parser.y`: This is the grammar definition file for the syntax analyzer (parser). It is used to define the grammar rules of the C-- language.

4. `script.sh`: This is a shell script to automate the execution of the lexical analyzer and syntax analyzer.

## How to Execute

To execute the parser, simply run the `sh script.sh` code

## Contact

For any questions or comments, feel free to send an email to jose.cordova@icomp.ufam.edu.br.
