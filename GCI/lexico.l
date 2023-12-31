%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	#include "y.tab.h"

	#define ANSI_COLOR_RED		"\x1b[31m"
	#define ANSI_COLOR_GREEN	"\x1b[32m"
	#define ANSI_COLOR_YELLOW	"\x1b[33m"
	#define ANSI_COLOR_BLUE		"\x1b[34m"
	#define ANSI_COLOR_MAGENTA	"\x1b[35m"
	#define ANSI_COLOR_CYAN		"\x1b[36m"
	#define ANSI_COLOR_RESET	"\x1b[0m"

	// Definição da estrutura para a tabela de símbolos
	struct symboltable
	{
		char name[100];
		char class[100];
		char type[100];
		char value[100];
		int nestval;
		int lineno;
		int length;
		int params_count;
	}ST[1001];

	// Definição da estrutura para a tabela de constantes
	struct constanttable
	{
		char name[100];
		char type[100];
		int length;
	}CT[1001];

	int currnest = 0;
	extern int yylval;

	// Atualiza o tipo de um símbolo na tabela de símbolos (ST).
// A função busca o símbolo 'str1' na tabela e atualiza seu tipo para 'str2'.
void insertSTtype(char *str1, char *str2)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,str1)==0)
        {
            strcpy(ST[i].type,str2);
        }
    }
}

// Insere um novo símbolo na tabela de símbolos (ST) com o nome 'str1' e a classe 'str2'.
// Se o símbolo já existir como um identificador e for tentado inserir como um identificador de array, um erro é exibido.
// Se o símbolo não existir, ele é inserido na tabela.
void addToSymbolTable(char *str1, char *str2)
{
    if(lookupST(str1))
    {
        if(strcmp(ST[lookupST(str1)].class,"Identifier")==0 && strcmp(str2,"Array Identifier")==0)
        {
            printf("Erro na utilização de vetor\n");
            exit(0);
        }   
        return;
    }
    else
    {
        int value = hash(str1);
        if(ST[value].length == 0)
        {
            strcpy(ST[value].name,str1);
            strcpy(ST[value].class,str2);
            ST[value].length = strlen(str1);
            ST[value].nestval = 9999;
            ST[value].params_count = -1;
            insertSTline(str1,yylineno);
            return;
        }

        int pos = 0;

        for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
        {
            if(ST[i].length == 0)
            {
                pos = i;
                break;
            }
        }

        strcpy(ST[pos].name,str1);
        strcpy(ST[pos].class,str2);
        ST[pos].length = strlen(str1);
        ST[pos].nestval = 9999;
        ST[pos].params_count = -1;
    }
}

// Atualiza o número da linha de um símbolo na tabela de símbolos (ST).
// A função busca o símbolo 'str1' na tabela e atualiza seu número da linha para 'line'.
void insertSTline(char *str1, int line)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,str1)==0)
        {
            ST[i].lineno = line;
        }
    }
}

// Procura por uma constante na tabela de constantes (CT) usando a string 'str' como chave.
// Retorna 1 se a constante for encontrada, ou 0 se não for encontrada.
int lookupCT(char *str)
{
    int value = hash(str);
    if(CT[value].length == 0)
        return 0;
    else if(strcmp(CT[value].name,str)==0)
        return 1;
    else
    {
        for(int i = value + 1 ; i!=value ; i = (i+1)%1001)
        {
            if(strcmp(CT[i].name,str)==0)
            {
                return 1;
            }
        }
        return 0;
    }
}

// Procura por um símbolo na tabela de símbolos (ST) usando a string 'str' como chave.
// Retorna o índice na tabela de símbolos onde o símbolo foi encontrado, ou 0 se não for encontrado.
int lookupST(char *str)
{
    int value = hash(str);
    if(ST[value].length == 0)
    {
        return 0;
    }
    else if(strcmp(ST[value].name,str)==0)
    {
        
        return value;
    }
    else
    {
        for(int i = value + 1 ; i!=value ; i = (i+1)%1001)
        {
            if(strcmp(ST[i].name,str)==0)
            {
                
                return i;
            }
        }
        return 0;
    }
}

// Função para calcular o hash
int hash(char *str)
{
    int value = 0;
    for(int i = 0 ; i < strlen(str) ; i++)
    {
        value = 10*value + (str[i] - 'A');
        value = value % 1001;
        while(value < 0)
            value = value + 1001;
    }
    return value;
}

// Insere um novo símbolo na tabela de constantes (CT) com o nome 'str1' e o tipo 'str2'.
// Se o símbolo já existir, a função retorna sem fazer alterações.
// Se não, o símbolo é inserido na tabela.
void insertCT(char *str1, char *str2)
{
    if(lookupCT(str1))
        return;
    else
    {
        int value = hash(str1);
        if(CT[value].length == 0)
        {
            strcpy(CT[value].name,str1);
            strcpy(CT[value].type,str2);
            CT[value].length = strlen(str1);
            return;
        }

        int pos = 0;

        for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
        {
            if(CT[i].length == 0)
            {
                pos = i;
                break;
            }
        }

        strcpy(CT[pos].name,str1);
        strcpy(CT[pos].type,str2);
        CT[pos].length = strlen(str1);
    }
}

// Atualiza a classe de um símbolo na tabela de símbolos (ST) para "Function".
// A função busca o símbolo 's' na tabela e, se encontrado, atualiza sua classe para "Function".
void addToFunctionSymbolTable(char *s)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,s)==0 )
        {
            strcpy(ST[i].class,"Function");
            return;
        }
    }
}

// Retorna a contagem de parâmetros de um símbolo na tabela de símbolos (ST).
// A função busca o símbolo 's' na tabela e retorna sua contagem de parâmetros.
// Se o símbolo não for encontrado, retorna -1.
int getParamsCountFromSymbolTable(char *s)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,s)==0 )
        {
            return ST[i].params_count;
        }
    }
    return -1;
}

// Atualiza a contagem de parâmetros de um símbolo na tabela de símbolos (ST).
// A função busca o símbolo 's' na tabela e atualiza sua contagem de parâmetros para 'count1'.
void addParamsCountToSymbolTable(char *s, int count1)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,s)==0 )
        {
            ST[i].params_count = count1;
        }
    }
}

// Insere ou atualiza o nível de aninhamento de um símbolo na tabela de símbolos (ST).
// Se o símbolo já existir com um nível de aninhamento diferente de 9999, ele é inserido novamente com o novo nível de aninhamento 'nest'.
// Caso contrário, o nível de aninhamento do símbolo existente é atualizado.
void addToSymbolTableWithNest(char *s, int nest)
{
    if(lookupST(s) && ST[lookupST(s)].nestval != 9999)
    {
         int pos = 0;
         int value = hash(s);
        for (int i = value + 1 ; i!=value ; i = (i+1)%1001)
        {
            if(ST[i].length == 0)
            {
                pos = i;
                break;
            }
        }

        strcpy(ST[pos].name,s);
        strcpy(ST[pos].class,"Identifier");
        ST[pos].length = strlen(s);
        ST[pos].nestval = nest;
        ST[pos].params_count = -1;
        ST[pos].lineno = yylineno;
    }
    else
    {
        for(int i = 0 ; i < 1001 ; i++)
        {
            if(strcmp(ST[i].name,s)==0 )
            {
                ST[i].nestval = nest;
            }
        }
    }
}

// Atualiza o valor de um símbolo na tabela de símbolos (ST) se ele estiver no nível de aninhamento atual (currnest).
// A função busca o símbolo 'str1' na tabela e, se estiver no nível de aninhamento correto, atualiza seu valor para 'str2'.
void insertSTvalue(char *str1, char *str2)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(strcmp(ST[i].name,str1)==0 && ST[i].nestval == currnest)
        {
            strcpy(ST[i].value,str2);
        }
    }
}

// Variáveis globais para armazenar o identificador atual, tipo e valor, respectivamente.
char curid[20];
char curtype[20];
char curval[20];

// Imprime a tabela de constantes (CT) formatada, mostrando nome e tipo.
void printCT()
{
    printf("%15s | %15s\n","NOME", "TIPO");
    for(int i=0;i<81;i++) {
        printf("-");
    }
    printf("\n");
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(CT[i].length == 0)
            continue;

        printf("%15s | %15s\n",CT[i].name, CT[i].type);
    }
}

// Imprime a tabela de símbolos (ST) formatada, mostrando símbolo, classe, tipo, valor, número da linha, nível de aninhamento e contagem de parâmetros.
void printST()
{
    printf("%11s | %15s | %10s | %10s | %10s |\n","SÍMBOLO", "CLASSE", "TIPO","VALOR", "NUM LINHA");
    for(int i=0;i<81;i++) {
        printf("-");
    }
    printf("\n");
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(ST[i].length == 0)
        {
            continue;
        }
        printf("%10s | %15s | %10s | %10s | %10d |\n",ST[i].name, ST[i].class, ST[i].type, ST[i].value, ST[i].lineno);
    }
}

// Retorna o primeiro caractere do tipo do símbolo 's' na tabela de símbolos (ST).
// Se o símbolo não for encontrado, o comportamento é indefinido.
char getType(char *s, int flag)
{
    for(int i = 0 ; i < 1001 ; i++ )
    {
        if(strcmp(ST[i].name,s)==0)
        {
            return ST[i].type[0];
        }
    }
}

// Verifica se o especificador de tipo 'type_specifier' é "void".
// Se for, exibe uma mensagem de erro e encerra o programa, indicando que parâmetros não podem ser do tipo void.
int verifyParameters(char* type_specifier)
{
    if(!strcmp(type_specifier, "void"))
    {
        printf("Parâmetros não podem ser do tipo void\n");
        exit(0);
    }
    return 0;
}

// Verifica se um símbolo 'str' foi declarado como uma função na tabela de símbolos (ST) ou se é igual a "output".
// Retorna 1 se a condição for verdadeira, e 0 caso contrário.
int verifyDeclaration(char* str, char *check_type)
{
    for(int i=0; i<1001; i++)
    {
        if(strcmp(ST[i].name, str) == 0 && strcmp(ST[i].class, "Function") == 0 || strcmp(ST[i].name,"output")==0 )
        {
            return 1;
        }
    }
    return 0;
}

// Verifica se uma função com o nome 'str' já foi declarada na tabela de símbolos (ST).
// Se uma duplicata for encontrada, exibe uma mensagem de erro e encerra o programa.
int verifyDuplicate(char* str)
{
    for(int i=0; i<1001; i++)
    {
        if(strcmp(ST[i].name, str) == 0 && strcmp(ST[i].class, "Function") == 0)
        {
            printf("Redeclaração de função não permitida\n");
            exit(0);
        }
    }
}

// Verifica se um símbolo 's' já existe na tabela de símbolos (ST) no escopo atual (currnest).
// Retorna 1 se um duplicado for encontrado no mesmo escopo, e 0 caso contrário.
int isDuplicate(char *s)
{
    for(int i = 0 ; i < 1000 ; i++)
    {
        if(strcmp(ST[i].name,s)==0)
        {               
            if(ST[i].nestval == currnest)
            {
                return 1;
            }
        }
    }
    
    return 0;
}

// Verifica se um identificador 's' na tabela de símbolos (ST) é um identificador de array.
// Retorna 0 se for um identificador de array, e 1 caso contrário.
int isArray(char *s)
{
    for(int i = 0 ; i < 1000 ; i++)
    {
        if(strcmp(ST[i].name,s)==0)
        {
            if(strcmp(ST[i].class,"Array Identifier")==0)
            {
                return 0;
            }
        }
    }
    return 1;
}

// Verifica se um identificador 's' na tabela de símbolos (ST) é uma função.
// Retorna 1 se for uma função, e 0 caso contrário.
int isIdentifierFunction(char *s)
{
    for(int i = 0 ; i < 1000 ; i++)
    {
        if(strcmp(ST[i].name,s)==0)
        {
            if(strcmp(ST[i].class,"Function")==0)
                return 1;
        }
    }
    return 0;
}

// Verifica se um símbolo 's' está no escopo atual ou em um escopo mais interno.
// Retorna 1 se o símbolo estiver no escopo atual ou em um escopo mais externo, e 0 se estiver em um escopo mais interno.
int verifyScope(char *s)
{
    int flag = 0;
    for(int i = 0 ; i < 1000 ; i++)
    {
        if(strcmp(ST[i].name,s)==0)
        {
            if(ST[i].nestval > currnest)
            {
                flag = 1;
            }
            else
            {
                flag = 0;
                break;
            }
        }
    }
    if(!flag)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

// Marca todos os símbolos na tabela de símbolos (ST) com um determinado nível de aninhamento 'nesting' como deletados, 
// atualizando seu nível de aninhamento para um valor alto (99999).
void deleteSymbolData (int nesting)
{
    for(int i = 0 ; i < 1001 ; i++)
    {
        if(ST[i].nestval == nesting)
        {
            ST[i].nestval = 99999;
        }
    }
}

%}

/* Regras para o analisador léxico */

%%
\n 	{yylineno++;}
\/\/(.*)																		{ }
\/\*([^*]|[\r\n]|(\*+([^*/]|[\r\n])))*\*+\/										{ }
[ \n\t] ;
";"				{ return(';'); }
","				{ return(','); }
("{")			{ return('{'); }
("}")			{ return('}'); }
"("				{ return('('); }
")"				{ return(')'); }
("["|"<:")		{ return('['); }
("]"|":>") 		{ return(']'); }
":"				{ return(':'); }
"."				{ return('.'); }

"char"			{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword");return CHAR;}
"double"		{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return DOUBLE;}
"else"			{ addToSymbolTable(yytext, "Keyword"); return ELSE;}
"real"			{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return REAL;}
"while"			{ addToSymbolTable(yytext, "Keyword"); return WHILE;}
"do"			{ addToSymbolTable(yytext, "Keyword"); return DO;}
"for"			{ addToSymbolTable(yytext, "Keyword"); return FOR;}
"if"			{ addToSymbolTable(yytext, "Keyword"); return IF;}
"int"			{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return INT;}
"long"			{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return LONG;}
"return"		{ addToSymbolTable(yytext, "Keyword"); return RETURN;}
"short"			{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return SHORT;}
"signed"		{ strcpy(curtype,yytext); addToSymbolTable(yytext, "Keyword"); return SIGNED;}
"sizeof" 		{ addToSymbolTable(yytext, "Keyword"); return SIZEOF;}
"struct"		{ strcpy(curtype,yytext);   addToSymbolTable(yytext, "Keyword");  return STRUCT;}
"unsigned"		{ addToSymbolTable(yytext, "Keyword");   return UNSIGNED;}
"void"			{ strcpy(curtype,yytext);   addToSymbolTable(yytext, "Keyword");  return VOID;}
"break"			{ addToSymbolTable(yytext, "Keyword");  return BREAK;}



"++"			{ return increment_operator; }
"--"			{ return decrement_operator; }
"<<"			{ return leftshift_operator; }
">>"			{ return rightshift_operator; }
"<="			{ return lessthan_assignment_operator; }
"<"				{ return lessthan_operator; }
">="			{ return greaterthan_assignment_operator; }
">"				{ return greaterthan_operator; }
"=="			{ return equality_operator; }
"!="			{ return inequality_operator; }
"&&"			{ return AND_operator; }
"||"			{ return OR_operator; }
"^"				{ return caret_operator; }
"*="			{ return multiplication_assignment_operator; }
"/="			{ return division_assignment_operator; }
"%="			{ return modulo_assignment_operator; }
"+="			{ return addition_assignment_operator; }
"-="			{ return subtraction_assignment_operator; }
"<<="			{ return leftshift_assignment_operator; }
">>="			{ return rightshift_assignment_operator; }
"&="			{ return AND_assignment_operator; }
"^="			{ return XOR_assignment_operator; }
"|="			{ return OR_assignment_operator; }
"&"				{ return amp_operator; }
"!"				{ return exclamation_operator; }
"~"				{ return tilde_operator; }
"-"				{ return subtract_operator; }
"+"				{ return add_operator; }
"*"				{ return multiplication_operator; }
"/"				{ return division_operator; }
"%"				{ return modulo_operator; }
"|"				{ return pipe_operator; }
\=				{ return assignment_operator;}

\"[^\n]*\"/[;|,|\)] 			{strcpy(curval,yytext); insertCT(yytext,"String Constant"); return string_constant;}
\'[A-Z|a-z]\'/[;|,|\)|:] 		{strcpy(curval,yytext); insertCT(yytext,"Character Constant"); return character_constant;}
[a-z|A-Z]([a-z|A-Z]|[0-9])*/\[ 	{strcpy(curid,yytext); addToSymbolTable(yytext, "Array Identifier");  return array_identifier;}
[1-9][0-9]*|0/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\]|\}|:|\n|\t|\^] 	{strcpy(curval,yytext); insertCT(yytext, "Number Constant"); yylval = atoi(yytext); return integer_constant;}
([0-9]*)\.([0-9]+)/[;|,|" "|\)|<|>|=|\!|\||&|\+|\-|\*|\/|\%|~|\n|\t|\^] 	{strcpy(curval,yytext); insertCT(yytext, "real Constant"); return real_constant;}
[A-Za-z_][A-Za-z_0-9]* {strcpy(curid,yytext); addToSymbolTable(curid,"Identifier"); return identifier;}

(.?) {
	if(yytext[0]=='"')
    {
        printf("ERR_STRING_INCOMPLETA na linha número %d\n", yylineno);
    }
    else
    {
        printf("ERRO na linha número %d\n", yylineno);
    }
    printf("%s\n", yytext);
    return 0;
}

%%
