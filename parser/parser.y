%{
#include <iostream>
#include <cctype>
using namespace std;

#include <stdlib.h>
#include <string.h>

FILE *file;
FILE *output;
char flag=0;

typedef struct {
  char *str;
  size_t len;
} mystring;

mystring *new_mystring(char *str, size_t len) {
  mystring *s = (mystring*) malloc(sizeof(mystring));
  s->str = str;
  s->len = len;
  return s;
}

int yylex(void);
int yyparse(void);
void yyerror(const char *);
%}

%union {
  mystring *str;
}


%token <str> KW_VOID 
%token <str> KW_INT
%token <str> KW_REAL
%token <str> KW_CHAR 
%token <str> KW_BOOL
%token <str> KW_IF
%token <str> KW_ELSE
%token <str> KW_FOR
%token <str> KW_WHILE
%token <str> KW_DO
%token <str> KW_RETURN
%token <str> KW_BREAK
%token <str> KW_CONTINUE
%token <str> KW_GOTO
%token <str> KW_TRUE
%token <str> KW_FALSE
%token <str> TK_ID
%token <str> CHAR //Elemento
%token <str> NUM_INT
%token <str> NUM_KW_REAL
%token <str> STRING
%token <str> OP_DIV
%token <str> OP_DIV_REC
%token <str> OP_INC
%token <str> OP_SOMA
%token <str> OP_SOMA_REC
%token <str> OP_SUB
%token <str> OP_DEC
%token <str> OP_SUB_REC
%token <str> SETA
%token <str> OP_MULT_REC
%token <str> OP_MULT
%token <str> OP_RESTO
%token <str> OP_RESTO_REC
%token <str> COMP_IGUAL
%token <str> OP_ATRIB
%token <str> COMP_DIF
%token <str> OP_NOT
%token <str> MAIOR_IGUAL
%token <str> MAIOR
%token <str> MENOR
%token <str> MENOR_IGUAL
%token <str> OU
%token <str> E
%token <str> ENDERECO
%token <str> VIRG
%token <str> SG_SEMICOLON
%token <str> PONTO
%token <str> ABRE_PAREN
%token <str> FECHA_PAREN
%token <str> FECHA_COLC
%token <str> ABRE_COLC
%token <str> ABRE_CHAV
%token <str> FECHA_CHAV
%token <str> OP_KW_DOIS_PONTOS
%token <str> OP_SELEC

%%
//grammar

////// declarações//////

programa: lista-decl //1 
		;

lista-decl: lista-decl decl //2
		  | decl
		  ;

decl: decl-var //3
	| decl-func
	;

decl-var: espec-tipo var SG_SEMICOLON //4
		;

espec-tipo: KW_INT //5
		 | KW_VOID
		 |KW_REAL
		 ;

decl-func: espec-tipo TK_ID ABRE_PAREN params FECHA_PAREN com-comp //6
		 ;

params: lista-param //7
	  | KW_VOID
	  | /* vazio */
	  ;

lista-param: lista-param VIRG param //8
		   | param
		   ;

param: espec-tipo var //9
	 ;

decl-locais: decl-locais decl-var //10
		   | /* vazio */
	  	   ;

//////comandos//////
lista-com: comando lista-com //11
		 |/* vazio */
	  	 ;

comando: com-exp //12
	   | com-atrib
	   | com-comp
	   | com-selecao
	   | com-repeticao
	   | com-retorno
	   ;

com-exp: exp SG_SEMICOLON //13
		| SG_SEMICOLON
		;

com-atrib: var OP_ATRIB exp SG_SEMICOLON //14
		;

com-comp: ABRE_CHAV decl-locais lista-com FECHA_CHAV //15
		;

com-selecao: KW_IF ABRE_PAREN exp FECHA_PAREN comando  //16
		   | KW_IF ABRE_PAREN exp FECHA_PAREN com-comp KW_ELSE comando
		   ;

com-repeticao: KW_WHILE ABRE_PAREN exp FECHA_PAREN comando //18
			 | KW_DO comando KW_WHILE ABRE_PAREN exp FECHA_PAREN SG_SEMICOLON
			 ;

com-retorno: KW_RETURN SG_SEMICOLON //19
		   | KW_RETURN exp SG_SEMICOLON
		   ;

//////expressões//////
exp: exp-soma op-relac exp-soma //19
   | exp-soma
   ;

op-relac: MENOR_IGUAL //20
		| MENOR
		| MAIOR
		| MAIOR_IGUAL
		| COMP_IGUAL
		| COMP_DIF
		;

exp-soma: exp-soma op-soma exp-mult //21
		| exp-mult
		;

op-soma: OP_SOMA //22
	   | OP_SUB
	   ;

exp-mult: exp-mult op-mult exp-simples //23
		| exp-simples
		;

op-mult: OP_MULT //24
	   | OP_DIV
	   | OP_RESTO
	   ;

exp-simples: ABRE_PAREN exp FECHA_PAREN //25
		   | var
		   | chama-func
		   | literais
		   ;

literais: NUM_INT //26
		| NUM_KW_REAL
		;

chama-func: TK_ID ABRE_PAREN args FECHA_PAREN //27

var: TK_ID //28
   | TK_ID ABRE_COLC NUM_INT FECHA_COLC
   ;

args: lista-arg //29
	| /* vazio */
	;

lista-arg: lista-arg VIRG exp //30
		 | exp
		 ;

%%

int yylex() {
	char linha[100];
    char *token;
	char *lexema;
	size_t len;
	if(flag == 1){
		/* printf("OK\n"); */
		fwrite("OK\n",sizeof(char),3,output);
	}
	
	flag = 1;

	if(feof(file)) {
		return 0;
	}

    fgets(linha, 100, file);

	token = (char*)strtok(linha, "  ");
	/* printf("Pegando o token: %s\n", token); */

	lexema = (char*)strtok(NULL, "  ");
	/* printf("Pegando o lexema: %s\n", lexema); */

	len = strlen(lexema);

	if(len >1) lexema[len-1] = '\0';

	/* printf("%s %s ", token,lexema); */
	fwrite(token,sizeof(char),strlen(token),output);
	fwrite(" ",sizeof(char),1,output);
	fwrite(lexema,sizeof(char),strlen(lexema),output);
	fwrite(" ",sizeof(char),1,output);

	yylval.str = new_mystring(lexema, len);
	/* printf("yylval: %s\n", yylval.str->str); */

	if(strcmp(token, "KW_VOID") == 0){return KW_VOID;}
	else if(strcmp(token, "KW_INT") == 0){return KW_INT;}
	else if(strcmp(token, "KW_REAL")== 0){return KW_REAL;}
	else if(strcmp(token, "KW_CHAR") == 0){return KW_CHAR;}
	else if(strcmp(token, "KW_BOOL") == 0){return KW_BOOL;}
	else if(strcmp(token, "KW_IF") == 0){return KW_IF;}
	else if(strcmp(token, "KW_ELSE") == 0){return KW_ELSE;}
	else if(strcmp(token, "KW_FOR") == 0){return KW_FOR;}
	else if(strcmp(token, "KW_WHILE") == 0){return KW_WHILE;}
	else if(strcmp(token, "KW_DO") == 0){return KW_DO;}
	else if(strcmp(token, "KW_RETURN") == 0){return KW_RETURN;}
	else if(strcmp(token, "KW_BREAK") == 0){return KW_BREAK;}
	else if(strcmp(token, "KW_CONTINUE") == 0){return KW_CONTINUE;}
	else if(strcmp(token, "KW_GOTO") == 0){return KW_GOTO;}
	else if(strcmp(token, "True") == 0){return KW_TRUE;}
	else if(strcmp(token, "False") == 0){return KW_FALSE;}
	else if(strcmp(token, "TK_ID") == 0){return TK_ID;}
	else if(strcmp(token, "CHAR") == 0){return CHAR;}
	else if(strcmp(token, "NUM_INT") == 0){return NUM_INT;}
	else if(strcmp(token, "NUM_KW_REAL") == 0){return NUM_KW_REAL;}
	else if(strcmp(token, "KW_INT") == 0){return KW_INT;}
	else if(strcmp(token, "STRING") == 0){return STRING;}
	else if(strcmp(token, "OP_DIV") == 0){return OP_DIV;}
	else if(strcmp(token, "OP_DIV_REC") == 0){return OP_DIV_REC;}
	else if(strcmp(token, "OP_INC") == 0){return OP_INC;}
	else if(strcmp(token, "OP_SOMA") == 0){return OP_SOMA;}
	else if(strcmp(token, "OP_SOMA_REC") == 0){return OP_SOMA_REC;}
	else if(strcmp(token, "OP_SUB") == 0){return OP_SUB;}
	else if(strcmp(token, "OP_DEC") == 0){return KW_INT;}
	else if(strcmp(token, "OP_SUB_REC") == 0){return OP_SUB_REC;}
	else if(strcmp(token, "SETA") == 0){return SETA;}
	else if(strcmp(token, "OP_MULT_REC") == 0){return OP_MULT_REC;}
	else if(strcmp(token, "OP_MULT") == 0){return OP_MULT;}
	else if(strcmp(token, "OP_RESTO") == 0){return OP_RESTO;}
	else if(strcmp(token, "OP_RESTO_REC") == 0){return OP_RESTO_REC;}
	else if(strcmp(token, "COMP_IGUAL") == 0){return COMP_IGUAL;}
	else if(strcmp(token, "OP_ATRIB") == 0){return OP_ATRIB;}
	else if(strcmp(token, "COMP_DIF") == 0){return COMP_DIF;}
	else if(strcmp(token, "OP_NOT") == 0){return OP_NOT;}
	else if(strcmp(token, "MAIOR") == 0){return MAIOR;}
	else if(strcmp(token, "MENOR") == 0){return MENOR;}
	else if(strcmp(token, "MAIOR_IGUAL") == 0){return MAIOR_IGUAL;}
	else if(strcmp(token, "MENOR_IGUAL") == 0){return MENOR_IGUAL;}
	else if(strcmp(token, "OU") == 0){return OU;}
	else if(strcmp(token, "E") == 0){return E;}
	else if(strcmp(token, "ENDERECO") == 0){return ENDERECO;}
	else if(strcmp(token, "VIRG") == 0){return VIRG;}
	else if(strcmp(token, "SG_SEMICOLON") == 0){return SG_SEMICOLON;}
	else if(strcmp(token, "PONTO") == 0){return PONTO;}
	else if(strcmp(token, "ABRE_PAREN") == 0){return ABRE_PAREN;}
	else if(strcmp(token, "FECHA_PAREN") == 0){return FECHA_PAREN;}
	else if(strcmp(token, "FECHA_COLC") == 0){return FECHA_COLC;}
	else if(strcmp(token, "ABRE_COLC") == 0){return ABRE_COLC;}
	else if(strcmp(token, "ABRE_CHAV") == 0){return ABRE_CHAV;}
	else if(strcmp(token, "FECHA_CHAV") == 0){return FECHA_CHAV;}
	else if(strcmp(token, "OP_KW_DOIS_PONTOS") == 0){return OP_KW_DOIS_PONTOS;}
	else if(strcmp(token, "OP_SELEC") == 0){return OP_SELEC;}
	else{return 0;}
}

void yyerror(const char * s){
	char buffer[50] = "Erro Sintático!\n";
    cout << buffer;
	fwrite(buffer,sizeof(char),strlen(buffer),output);
   	exit(0);
}

int main(int argc, char ** argv){
	
    if (argc > 1){
		file = fopen(argv[1], "r");
		if (file == NULL){
			cout << "Arquivo " << argv[1] << " não encontrado\n";
			exit(1);
		}
		
		/* entrada ajustada para ler do arquivo */
	}
	output = fopen("docParser.txt","wb");
	printf("\nInicio da Análise sintática!\n\n");
	yyparse();
	printf("\nFim da Análise!\nCódigo sem erros léxicos ou sintáticos!\n");
	fclose(output);
	fclose(file);
}