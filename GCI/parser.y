%{
	#include <stdio.h>
	#include <string.h>
	#include <stdlib.h>
	
	/* Declaração de funções e variáveis utilizadas no analisador */
	void yyerror(char* s);
	int yylex();
	void ins();
	void insV();
	int flag=0;

	/* Definição de cores ANSI para formatação de texto no terminal */
	#define ANSI_COLOR_RED		"\x1b[31m"
	#define ANSI_COLOR_GREEN	"\x1b[32m"
	#define ANSI_COLOR_CYAN		"\x1b[36m"
	#define ANSI_COLOR_RESET	"\x1b[0m"

	/* Variáveis externas utilizadas para armazenar informações sobre identificadores e tipos */
	extern char curid[20];
	extern char curtype[20];
	extern char curval[20];
	extern int currnest;

	/* Declaração de funções para manipulação da tabela de símbolos e verificação de escopo */
	void deletedata (int );
	int checkscope(char*);
	int check_id_is_func(char *);
	void insertST(char*, char*);
	void insertSTnest(char*, int);
	void insertSTparamscount(char*, int);
	int getSTparamscount(char*);
	int check_duplicate(char*);
	int check_declaration(char*, char *);
	int check_params(char*);
	int duplicate(char *s);
	int checkarray(char*);

	/* Variáveis para armazenar informações sobre funções e chamadas de funções */
	char currfunctype[100];
	char currfunc[100];
	char currfunccall[100];

	/* Mais declarações de funções para geração de código e manipulação de pilha */
	void insertSTF(char*);
	char gettype(char*,int);
	char getfirst(char*);
	void push(char *s);
	void codegen();
	void codeassign();
	char* itoa(int num, char* str, int base);
	void reverse(char str[], int length); 
	void swap(char*,char*);
	void label1();
	void label2();
	void label3();
	void label4();
	void label5();
	void label6();
	void genunary();
	void codegencon();
	void funcgen();
	void funcgenend();
	void arggen();
	void callgen();

	/* Variáveis para controle de parâmetros, chamadas de funções e controle de pilha */
	int params_count=0;
	int call_params_count=0;
	int top = 0,count=0,ltop=0,lno=0;
	char temp[3] = "t";
%}

/* Definições de tokens e operadores para o analisador sintático */
%nonassoc IF
%token INT CHAR REAL DOUBLE LONG SHORT SIGNED UNSIGNED STRUCT
%token RETURN MAIN
%token VOID
%token WHILE FOR DO 
%token BREAK
%token ENDIF
%expect 1

%token identifier array_identifier func_identifier
%token integer_constant string_constant real_constant character_constant

/* Definição de precedência de operadores */
%nonassoc ELSE
%right leftshift_assignment_operator rightshift_assignment_operator
%right XOR_assignment_operator OR_assignment_operator
%right AND_assignment_operator modulo_assignment_operator
%right multiplication_assignment_operator division_assignment_operator
%right addition_assignment_operator subtraction_assignment_operator
%right assignment_operator
%left OR_operator
%left AND_operator
%left pipe_operator
%left caret_operator
%left amp_operator
%left equality_operator inequality_operator
%left lessthan_assignment_operator lessthan_operator greaterthan_assignment_operator greaterthan_operator
%left leftshift_operator rightshift_operator 
%left add_operator subtract_operator
%left multiplication_operator division_operator modulo_operator
%right SIZEOF
%right tilde_operator exclamation_operator
%left increment_operator decrement_operator 


%start program

%%
/* Definição da gramática */
program
			: declaration_list;

declaration_list
			: declaration D 

D
			: declaration_list
			| ;

declaration
			: variable_declaration 
			| function_declaration

variable_declaration
			: type_specifier variable_declaration_list ';' 

variable_declaration_list
			: variable_declaration_list ',' variable_declaration_identifier | variable_declaration_identifier;

variable_declaration_identifier 
			: identifier {if(duplicate(curid)){printf("Duplicado\n");exit(0);}insertSTnest(curid,currnest); ins();  } vdi   
			  | array_identifier {if(duplicate(curid)){printf("Duplicado\n");exit(0);}insertSTnest(curid,currnest); ins();  } vdi;
			
			

vdi : identifier_array_type | assignment_operator simple_expression  ; 

identifier_array_type
			: '[' initilization_params
			| ;

initilization_params
			: integer_constant ']' initilization {if($$ < 1) {printf("Tamanho de vetor errado\n"); exit(0);} }
			| ']' string_initilization;

initilization
			: string_initilization
			| array_initialization
			| ;

type_specifier 
			: INT | CHAR | REAL | DOUBLE  
			| LONG long_grammar 
			| SHORT short_grammar
			| UNSIGNED unsigned_grammar 
			| SIGNED signed_grammar
			| VOID  ;

unsigned_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

signed_grammar 
			: INT | LONG long_grammar | SHORT short_grammar | ;

long_grammar 
			: INT  | ;

short_grammar 
			: INT | ;

function_declaration
			: function_declaration_type function_declaration_param_statement;

function_declaration_type
			: type_specifier identifier '('  { strcpy(currfunctype, curtype); strcpy(currfunc, curid); check_duplicate(curid); insertSTF(curid); ins(); };

function_declaration_param_statement
			: {params_count=0;}params ')' {funcgen();} statement {funcgenend();};

params 
			: parameters_list { insertSTparamscount(currfunc, params_count); }| { insertSTparamscount(currfunc, params_count); };

parameters_list 
			: type_specifier { check_params(curtype);} parameters_identifier_list ;

parameters_identifier_list 
			: param_identifier parameters_identifier_list_breakup;

parameters_identifier_list_breakup
			: ',' parameters_list 
			| ;

param_identifier 
			: identifier { ins();insertSTnest(curid,1); params_count++; } param_identifier_breakup;

param_identifier_breakup
			: '[' ']'
			| ;

statement 
			: expression_statment | compound_statement 
			| conditional_statements | iterative_statements 
			| return_statement | break_statement 
			| variable_declaration;

compound_statement 
			: {currnest++;} '{'  statment_list  '}' {deletedata(currnest);currnest--;}  ;

statment_list 
			: statement statment_list 
			| ;

expression_statment 
			: expression ';' 
			| ';' ;

conditional_statements 
			: IF '(' simple_expression ')' {label1();if($3!=1){printf("A condição de verificação não é do tipo int\n");exit(0);}} statement {label2();}  conditional_statements_breakup;

conditional_statements_breakup
			: ELSE statement {label3();}
			| {label3();};

iterative_statements 
			: WHILE '(' {label4();} simple_expression ')' {label1();if($4!=1){printf("A condição de verificação não é do tipo int\n");exit(0);}} statement {label5();} 
			| FOR '(' expression ';' {label4();} simple_expression ';' {label1();if($6!=1){printf("A condição de verificação não é do tipo int\n");exit(0);}} expression ')'statement {label5();} 
			| {label4();}DO statement WHILE '(' simple_expression ')'{label1();label5();if($6!=1){printf("A condição de verificação não é do tipo int\n");exit(0);}} ';';
return_statement 
			: RETURN ';' {if(strcmp(currfunctype,"void")) {printf("Retornando void de uma função não-void\n"); exit(0);}}
			| RETURN expression ';' { 	if(!strcmp(currfunctype, "void"))
										{ 
											yyerror("Function is void");
										}

										if((currfunctype[0]=='i' || currfunctype[0]=='c') && $2!=1)
										{
											printf("A expressão não corresponde ao tipo de retorno da função\n"); exit(0);
										}

									};

break_statement 
			: BREAK ';' ;

string_initilization
			: assignment_operator string_constant {insV();} ;

array_initialization
			: assignment_operator '{' array_int_declarations '}';

array_int_declarations
			: integer_constant array_int_declarations_breakup;

array_int_declarations_breakup
			: ',' array_int_declarations 
			| ;

expression 
			: mutable assignment_operator {push("=");} expression   {   
																	  if($1==1 && $4==1) 
																	  {
			                                                          $$=1;
			                                                          } 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable addition_assignment_operator {push("+=");}expression {  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable subtraction_assignment_operator {push("-=");} expression  {	  
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);} 
			                                                          codeassign();
			                                                       }
			| mutable multiplication_assignment_operator {push("*=");} expression {
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);}
			                                                          codeassign(); 
			                                                       }
			| mutable division_assignment_operator {push("/=");}expression 		{ 
																	  if($1==1 && $4==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);} 
			                                                       }
			| mutable modulo_assignment_operator {push("%=");}expression 		{ 
																	  if($1==1 && $3==1) 
			                                                          $$=1; 
			                                                          else 
			                                                          {$$=-1; printf("Desconformidade de tipos\n"); exit(0);} 
			                                                          codeassign();
																	}
			| mutable increment_operator 							{ push("++");if($1 == 1) $$=1; else $$=-1; genunary();}
			| mutable decrement_operator  							{push("--");if($1 == 1) $$=1; else $$=-1;}
			| simple_expression {if($1 == 1) $$=1; else $$=-1;} ;


simple_expression 
			: simple_expression OR_operator and_expression {push("||");} {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| and_expression {if($1 == 1) $$=1; else $$=-1;};

and_expression 
			: and_expression AND_operator {push("&&");} unary_relation_expression  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  |unary_relation_expression {if($1 == 1) $$=1; else $$=-1;} ;


unary_relation_expression 
			: exclamation_operator {push("!");} unary_relation_expression {if($2==1) $$=1; else $$=-1; codegen();} 
			| regular_expression {if($1 == 1) $$=1; else $$=-1;} ;

regular_expression 
			: regular_expression relational_operators sum_expression {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			  | sum_expression {if($1 == 1) $$=1; else $$=-1;} ;
			
relational_operators 
			: greaterthan_assignment_operator {push(">=");} | lessthan_assignment_operator {push("<=");} | greaterthan_operator {push(">");}| lessthan_operator {push("<");}| equality_operator {push("==");}| inequality_operator {push("!=");} ;

sum_expression 
			: sum_expression sum_operators term  {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| term {if($1 == 1) $$=1; else $$=-1;};

sum_operators 
			: add_operator {push("+");}
			| subtract_operator {push("-");} ;

term
			: term MULOP factor {if($1 == 1 && $3==1) $$=1; else $$=-1; codegen();}
			| factor {if($1 == 1) $$=1; else $$=-1;} ;

MULOP 
			: multiplication_operator {push("*");}| division_operator {push("/");} | modulo_operator {push("%");} ;

factor 
			: immutable {if($1 == 1) $$=1; else $$=-1;} 
			| mutable {if($1 == 1) $$=1; else $$=-1;} ;

mutable 
			: identifier {
						  push(curid);
						  if(check_id_is_func(curid))
						  {printf("Erro: Nome da função usado como identificador\n"); exit(8);}
			              if(!checkscope(curid))
			              {printf("%s\n",curid);printf("\nErro: Variável não declarada\n");exit(0);} 
			              if(!checkarray(curid))
			              {printf("%s\n",curid);printf("Erro: O identificador de array não possui subscrito\n");exit(0);}
			              if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
			              $$ = 1;
			              else
			              $$ = -1;
			              }
			| array_identifier {if(!checkscope(curid)){printf("%s\n",curid);printf("\nErro: Variável não declarada\n");exit(0);}} '[' expression ']' 
			                   {if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
			              		$$ = 1;
			              		else
			              		$$ = -1;
			              		};

immutable 
			: '(' expression ')' {if($2==1) $$=1; else $$=-1;}
			| call {if($1==-1) $$=-1; else $$=1;}
			| constant {if($1==1) $$=1; else $$=-1;};

call
			: identifier '('{

			             if(!check_declaration(curid, "Function"))
			             { printf("Erro: Função não declarada"); exit(0);} 
			             insertSTF(curid); 
						 strcpy(currfunccall,curid);
						 if(gettype(curid,0)=='i' || gettype(curid,1)== 'c')
						 {
			             $$ = 1;
			             }
			             else
			             $$ = -1;
                         call_params_count=0;
			             } 
			             arguments ')' 
						 { if(strcmp(currfunccall,"output"))
							{ 
								if(getSTparamscount(currfunccall)!=call_params_count)
								{	
									yyerror("Number of arguments in function call doesn't match number of parameters");
									exit(8);
								}
							}
							callgen();
						 };

arguments 
			: arguments_list | ;

arguments_list 
			: arguments_list ',' exp { call_params_count++; }  
			| exp { call_params_count++; };

exp : identifier {arggen(1);} | integer_constant {arggen(2);} | string_constant {arggen(3);} | real_constant {arggen(4);} | character_constant {arggen(5);} ;

constant 
			: integer_constant 	{  insV(); codegencon(); $$=1; } 
			| string_constant	{  insV(); codegencon();$$=-1;} 
			| real_constant	{  insV(); codegencon();} 
			| character_constant{  insV(); codegencon();$$=1; };

%%

/* Código C adicional para suporte ao analisador, incluindo funções auxiliares e a função main */
extern FILE *yyin;
extern int yylineno;
extern char *yytext;

/* Funções para manipulação da tabela de símbolos e tabela de constantes */
void insertSTtype(char *,char *);
void insertSTvalue(char *, char *);
void incertCT(char *, char *);
void printST();
void printCT();

/* Estrutura de dados para pilha e funções para manipulação da pilha */
struct stack
{
	char value[100];
	int labelvalue;
}s[100],label[100];

/* Funções para manipulação da pilha, geração de código e controle de fluxo */

// Empilha uma string na pilha 's' e incrementa o topo da pilha.
void push(char *x)
{
	strcpy(s[++top].value,x);
}

// Função para trocar os valores de duas variáveis.
void swap(char *x, char *y)
{
	char temp = *x;
	*x = *y;
	*y = temp;
}

// Função para reverter uma string.
void reverse(char str[], int length) 
{ 
    int start = 0; 
    int end = length -1; 
    while (start < end) 
    { 
        swap((str+start), (str+end)); 
        start++; 
        end--; 
    } 
} 

// Função para converter um número inteiro em uma string, de acordo com a base especificada.
char* itoa(int num, char* str, int base) 
{ 
    int i = 0; 
    int isNegative = 0; 
  
   
    if (num == 0) 
    { 
        str[i++] = '0'; 
        str[i] = '\0'; 
        return str; 
    } 
  
    if (num < 0 && base == 10) 
    { 
        isNegative = 1; 
        num = -num; 
    } 
  
   
    while (num != 0) 
    { 
        int rem = num % base; 
        str[i++] = (rem > 9)? (rem-10) + 'a' : rem + '0'; 
        num = num/base; 
    } 
  
    if (isNegative) 
        str[i++] = '-'; 
  
    str[i] = '\0'; 
  
   
    reverse(str, i); 
  
    return str; 
} 

// Função para gerar código intermediário para operações binárias.
void codegen()
{
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s %s %s\n",temp,s[top-2].value,s[top-1].value,s[top].value);
	top = top - 2;
	strcpy(s[top].value,temp);
	count++; 
}

// Função para gerar código intermediário para constantes.
void codegencon()
{
	strcpy(temp,"t");
	char buffer[100];
	itoa(count,buffer,10);
	strcat(temp,buffer);
	printf("%s = %s\n",temp,curval);
	push(temp);
	count++;
	
}

// Função para verificar se uma operação é unária.
int isunary(char *s)
{
	if(strcmp(s, "--")==0 || strcmp(s, "++")==0)
	{
		return 1;
	}
	return 0;
}

// Função para gerar código intermediário para operações unárias.
void genunary()
{
	char temp1[100], temp2[100], temp3[100];
	strcpy(temp1, s[top].value);
	strcpy(temp2, s[top-1].value);

	if(isunary(temp1))
	{
		strcpy(temp3, temp1);
		strcpy(temp1, temp2);
		strcpy(temp2, temp3);
	}
	strcpy(temp, "t");
	char buffer[100];
	itoa(count, buffer, 10);
	strcat(temp, buffer);
	count++;

	if(strcmp(temp2,"--")==0)
	{
		printf("%s = %s - 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	if(strcmp(temp2,"++")==0)
	{
		printf("%s = %s + 1\n", temp, temp1);
		printf("%s = %s\n", temp1, temp);
	}

	top = top -2;
}

// Função para gerar código intermediário para atribuições.
void codeassign()
{
	printf("%s = %s\n",s[top-2].value,s[top].value);
	top = top - 2;
}

// Função para gerar rótulos e código intermediário para estruturas de controle (IF).
void label1()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("IF not %s GoTo %s\n",s[top].value,temp);
	label[++ltop].labelvalue = lno++;
}

// Função para gerar rótulos e código intermediário para estruturas de controle (GOTO).
void label2()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("GoTo %s\n",temp);
	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop--;
	label[++ltop].labelvalue=lno++;
}

// Função para gerar rótulos para o final de estruturas de controle.
void label3()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop--;
	
}

// Função para gerar rótulos para o início de estruturas de controle.
void label4()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(lno,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	label[++ltop].labelvalue = lno++;
}

// Função para gerar rótulos e código intermediário para loops.
void label5()
{
	strcpy(temp,"L");
	char buffer[100];
	itoa(label[ltop-1].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("GoTo %s:\n",temp);
	strcpy(temp,"L");
	itoa(label[ltop].labelvalue,buffer,10);
	strcat(temp,buffer);
	printf("%s:\n",temp);
	ltop = ltop - 2;
    
   
}

// Função para iniciar a geração de código de uma função.
void funcgen()
{
	printf("func begin %s\n",currfunc);
}

// Função para finalizar a geração de código de uma função.
void funcgenend()
{
	printf("func end\n\n");
}

void arggen(int i)
{
    if(i==1)
    {
	printf("refparam %s\n", curid);
	}
	else
	{
	printf("refparam %s\n", curval);
	}
}

// Função para gerar código intermediário para argumentos de funções.
void callgen()
{
	printf("refparam result\n");
	push("result");
	printf("call %s, %d\n",currfunccall,call_params_count);
}



// Inicia a análise sintática do arquivo de entrada e imprime as tabelas de símbolos e constantes.
int main(int argc , char **argv)
{
    yyin = fopen(argv[1], "r"); // Abre o arquivo de entrada para leitura.
	printf("\n%30s" ANSI_COLOR_CYAN "CÓDIGO INTERMEDIÁRIO" ANSI_COLOR_RESET "\n", " ");
	printf("%29s %s\n", " ", "--------------------");
    yyparse(); // Inicia a análise sintática.

    // Se a análise foi bem-sucedida, imprime as tabelas de símbolos e constantes.
    if(flag == 0)
    {
        printf(ANSI_COLOR_GREEN "Status: Parsing Completo - Válido" ANSI_COLOR_RESET "\n\n");
        printf("%30s" ANSI_COLOR_CYAN "TABELA DE SÍMBOLOS" ANSI_COLOR_RESET "\n", " ");
		printf("%29s %s\n", " ", "------------------");
        printST(); // Imprime a tabela de símbolos.

        printf("\n\n%30s" ANSI_COLOR_CYAN "TABELA DE CONSTANTES" ANSI_COLOR_RESET "\n", " ");
        printf("%29s %s\n", " ", "---------------------");
        printCT(); // Imprime a tabela de constantes.
    }
}

// Função chamada quando um erro de análise é encontrado.
void yyerror(char *s)
{
    printf(ANSI_COLOR_RED "%d %s %s\n", yylineno, s, yytext); // Imprime a mensagem de erro.
    flag = 1; // Seta a flag de erro.
    printf(ANSI_COLOR_RED "Status: Parsing Falhou - Inválido\n" ANSI_COLOR_RESET);
    exit(7); // Encerra o programa com código de erro.
}

// Função para inserir o tipo de um identificador na tabela de símbolos.
void ins()
{
    insertSTtype(curid,curtype);
}

// Função para inserir o valor de um identificador na tabela de símbolos.
void insV()
{
    insertSTvalue(curid,curval); 
}

// Função chamada no final da análise sintática.
int yywrap()
{
    return 1;
}
