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
%token <str> OP_MOD
%token <str> OP_MOD_REC
%token <str> OP_EQ
%token <str> OP_ATRIB
%token <str> OP_DIF
%token <str> OP_NOT
%token <str> OP_GE
%token <str> OP_MAIOR
%token <str> OP_MENOR
%token <str> OP_LE
%token <str> OP_OR
%token <str> OP_AND
%token <str> ENDERECO
%token <str> SG_COMMA
%token <str> SG_SEMICOLON
%token <str> PONTO
%token <str> SG_ABREPAR
%token <str> SG_FECHAPAR
%token <str> SG_FECHACOL
%token <str> SG_ABRECOL
%token <str> SG_ABRECHV
%token <str> SG_FECHACHV
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

decl-func: espec-tipo TK_ID SG_ABREPAR params SG_FECHAPAR com-comp //6
		 ;

params: lista-param //7
	  | KW_VOID
	  | /* vazio */
	  ;

lista-param: lista-param SG_COMMA param //8
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

op-relac: OP_LE //20
		| OP_MENOR
		| OP_MAIOR
		| OP_GE
		| OP_EQ
		| OP_DIF
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
	   | OP_MOD
	   ;

exp-simples: SG_ABREPAR exp SG_FECHAPAR //25
		   | var
		   | chama-func
		   | literais
		   ;

literais: NUM_INT //26
		| NUM_KW_REAL
		;

chama-func: TK_ID SG_ABREPAR args SG_FECHAPAR //27

var: TK_ID //28
   | TK_ID ABRE_COLC NUM_INT FECHA_COLC
   ;

args: lista-arg //29
	| /* vazio */
	;

lista-arg: lista-arg SG_COMMA exp //30
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
		fwrite("\n",sizeof(char),3,output);
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

	/* printf("%s %s", token,lexema); */
	if(strlen(token) <= 7){
		fwrite(token,sizeof(char),strlen(token),output);
		fwrite("\t\t\t\t",4,1,output);
	}else{
		fwrite(token,sizeof(char),strlen(token),output);
		fwrite("\t\t\t",3,1,output);
	}
	fwrite(lexema,sizeof(char),strlen(lexema),output);

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
	else if(strcmp(token, "OP_MOD") == 0){return OP_MOD;}
	else if(strcmp(token, "OP_MOD_REC") == 0){return OP_MOD_REC;}
	else if(strcmp(token, "OP_EQ") == 0){return OP_EQ;}
	else if(strcmp(token, "OP_ATRIB") == 0){return OP_ATRIB;}
	else if(strcmp(token, "OP_DIF") == 0){return OP_DIF;}
	else if(strcmp(token, "OP_NOT") == 0){return OP_NOT;}
	else if(strcmp(token, "OP_MAIOR") == 0){return OP_MAIOR;}
	else if(strcmp(token, "OP_MENOR") == 0){return OP_MENOR;}
	else if(strcmp(token, "OP_GE") == 0){return OP_GE;}
	else if(strcmp(token, "OP_LE") == 0){return OP_LE;}
	else if(strcmp(token, "OP_OR") == 0){return OP_OR;}
	else if(strcmp(token, "OP_AND") == 0){return OP_AND;}
	else if(strcmp(token, "ENDERECO") == 0){return ENDERECO;}
	else if(strcmp(token, "SG_COMMA") == 0){return SG_COMMA;}
	else if(strcmp(token, "SG_SEMICOLON") == 0){return SG_SEMICOLON;}
	else if(strcmp(token, "PONTO") == 0){return PONTO;}
	else if(strcmp(token, "SG_ABREPAR") == 0){return SG_ABREPAR;}
	else if(strcmp(token, "SG_FECHAPAR") == 0){return SG_FECHAPAR;}
	else if(strcmp(token, "SG_FECHACOL") == 0){return SG_FECHACOL;}
	else if(strcmp(token, "SG_ABRECOL") == 0){return SG_ABRECOL;}
	else if(strcmp(token, "SG_ABRECHV") == 0){return SG_ABRECHV;}
	else if(strcmp(token, "SG_FECHACHV") == 0){return SG_FECHACHV;}
	else if(strcmp(token, "OP_KW_DOIS_PONTOS") == 0){return OP_KW_DOIS_PONTOS;}
	else if(strcmp(token, "OP_SELEC") == 0){return OP_SELEC;}
	else{return 0;}
}

void yyerror(const char * s){
	char buffer[50] = "\n--> Houve um erro Sintático!\n";
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
	printf("\n--> Iniciando Análise Sintática...\n");
	yyparse();
	printf("\n--> Fim da Análise Sintática...\n\n--> Código sem erros Léxicos ou Sintáticos!\n\n");
	fclose(output);
	fclose(file);
}