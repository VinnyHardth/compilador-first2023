# Repositório do Compilador First2023

Este é um projeto para o curso de compiladores. O projeto envolve a implementação de um compilador para a linguagem First2023, que segue a seguinte gramática:

- Letras: ab ... zAB ... Z
- Dígitos: 0123456789
- Símbolos Especiais: , ; ( ) = < > + - \* / % [ ] “ ‘ \_ $ { } ? : ! . etc
- Separadores: espaço, quebra de linha, tabulação

O projeto gera tokens correspondentes a partir do código-fonte em First2023.

## Diretório de Análise Sintática

No diretório `parser`, você encontrará os seguintes arquivos:

1. `analisadorLexico.c`: Este é o código-fonte em C para o analisador léxico. Ele lê a entrada de um arquivo de texto, identifica os tokens e os classifica de acordo com a tabela de símbolos. Ele também gera um arquivo de saída com os tokens classificados, que é usado pelo analisador de sintaxe.

2. `code.txt`: Este arquivo de texto contém exemplos de código em First2023 para testar o analisador de sintaxe (parser).

3. `parser.y`: Este é o arquivo de definição de gramática para o analisador de sintaxe (parser). Ele é usado para definir as regras de gramática da linguagem First2023.

4. `script.sh`: Este é um script shell para automatizar a execução do analisador léxico e do analisador de sintaxe.

## Como Executar

Para executar o analisador de sintaxe, basta rodar o código `sh script.sh`.

## Contato

Para perguntas ou comentários, sinta-se à vontade para enviar um e-mail para:

- [vinicius.fonseca@icomp.ufam.edu.br]
- [matheus.silva@icomp.ufam.edu.br]
