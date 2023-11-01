%{
#include <iostream>
#include <cctype>
#include <stdlib.h>
#include <string.h>

using namespace std;

ASTNode *astRoot; // Raiz da AST

typedef enum {
    NODE_TYPE_VAR_DECL,
    NODE_TYPE_FUNC_DECL,
    NODE_TYPE_BIN_EXPR,
    NODE_TYPE_UNARY_EXPR,
    NODE_TYPE_ASSIGN_EXPR,
    NODE_TYPE_COMPARISON,
    NODE_TYPE_LOGICAL,
    NODE_TYPE_CONTROL_FLOW,
    NODE_TYPE_RETURN,
    NODE_TYPE_BREAK_CONTINUE,
    NODE_TYPE_LITERAL_NUM,
    NODE_TYPE_LITERAL_BOOL,
    NODE_TYPE_LITERAL_CHAR,
    NODE_TYPE_LITERAL_STRING,
    NODE_TYPE_IDENTIFIER,
    NODE_TYPE_FUNC_CALL,
    NODE_TYPE_ARRAY_ACCESS
} NodeType;

typedef struct ASTNode ASTNode;

struct ASTNode {
    NodeType type;

    union {
        // Para declaração de variáveis e funções
        struct {
            char *typeSpecifier;  // Tipo da variável ou retorno da função
            char *identifier;     // Nome da variável ou função
            ASTNode *next;        // Próximo nó (para listas de declarações)
            ASTNode *params;      // Parâmetros da função (apenas para funções)
            ASTNode *body;        // Corpo da função (apenas para funções)
        } decl;

        // Para expressões binárias e unárias
        struct {
            ASTNode *left;        // Operando esquerdo (também usado para unário)
            ASTNode *right;       // Operando direito (não usado para unário)
            char *op;             // Operador
        } expr;

        // Para comandos de controle de fluxo
        struct {
            ASTNode *condition;   // Condição
            ASTNode *thenBranch;  // Ramo 'then' (para 'if')
            ASTNode *elseBranch;  // Ramo 'else' (opcional, para 'if')
            ASTNode *body;        // Corpo do loop (para 'while', 'for', 'do-while')
        } flowControl;

        // Para comandos de retorno, break e continue
        struct {
            ASTNode *returnValue; // Valor de retorno (opcional, para 'return')
        } stmt;

        // Para literais e identificadores
        struct {
            char *value;          // Valor do literal ou nome do identificador
        } literal;

        // Para chamada de função
        struct {
            char *identifier;     // Nome da função
            ASTNode *args;        // Argumentos da função
        } funcCall;

        // Para acesso a array
        struct {
            char *identifier;     // Nome do array
            ASTNode *index;       // Índice do array
        } arrayAccess;
    } data;
};

// Função genérica para criar um novo nó AST
ASTNode *newASTNode(NodeType type) {
    ASTNode *node = (ASTNode *)malloc(sizeof(ASTNode));
    node->type = type;
    return node;
}

// Função para criar um nó de declaração de variável ou função
ASTNode *newVarFuncDeclNode(char *typeSpecifier, char *identifier, ASTNode *next, ASTNode *params, ASTNode *body) {
    ASTNode *node = newASTNode(identifier ? NODE_TYPE_FUNC_DECL : NODE_TYPE_VAR_DECL);
    node->data.decl.typeSpecifier = strdup(typeSpecifier);
    node->data.decl.identifier = identifier ? strdup(identifier) : NULL;
    node->data.decl.next = next;
    node->data.decl.params = params;
    node->data.decl.body = body;
    return node;
}

// Função para criar um nó de expressão binária ou unária
ASTNode *newExprNode(NodeType type, ASTNode *left, ASTNode *right, char *op) {
    ASTNode *node = newASTNode(type);
    node->data.expr.left = left;
    node->data.expr.right = right;
    node->data.expr.op = strdup(op);
    return node;
}

// Função para criar um nó de controle de fluxo (if, while, etc.)
ASTNode *newFlowControlNode(NodeType type, ASTNode *condition, ASTNode *thenBranch, ASTNode *elseBranch, ASTNode *body) {
    ASTNode *node = newASTNode(type);
    node->data.flowControl.condition = condition;
    node->data.flowControl.thenBranch = thenBranch;
    node->data.flowControl.elseBranch = elseBranch;
    node->data.flowControl.body = body;
    return node;
}

// Função para criar um nó de retorno, break ou continue
ASTNode *newStmtNode(NodeType type, ASTNode *returnValue) {
    ASTNode *node = newASTNode(type);
    node->data.stmt.returnValue = returnValue;
    return node;
}

// Função para criar um nó de literal ou identificador
ASTNode *newLiteralNode(NodeType type, char *value) {
    ASTNode *node = newASTNode(type);
    node->data.literal.value = strdup(value);
    return node;
}

// Função para criar um nó de chamada de função
ASTNode *newFuncCallNode(char *identifier, ASTNode *args) {
    ASTNode *node = newASTNode(NODE_TYPE_FUNC_CALL);
    node->data.funcCall.identifier = strdup(identifier);
    node->data.funcCall.args = args;
    return node;
}

// Função para criar um nó de acesso a array
ASTNode *newArrayAccessNode(char *identifier, ASTNode *index) {
    ASTNode *node = newASTNode(NODE_TYPE_ARRAY_ACCESS);
    node->data.arrayAccess.identifier = strdup(identifier);
    node->data.arrayAccess.index = index;
    return node;
}

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
    ASTNode *ast; // Adicionando o tipo ASTNode
}

//tokens

%token <ast> KW_VOID 
%token <ast> KW_INT
%token <ast> KW_REAL
%token <ast> KW_CHAR 
%token <ast> KW_BOOL
%token <ast> KW_IF
%token <ast> KW_ELSE
%token <ast> KW_FOR
%token <ast> KW_WHILE
%token <ast> KW_DO
%token <ast> KW_RETURN
%token <ast> KW_BREAK
%token <ast> KW_CONTINUE
%token <ast> KW_GOTO
%token <ast> KW_TRUE
%token <ast> KW_FALSE
%token <ast> TK_ID
%token <ast> CHAR // Agora retorna um ASTNode *
%token <ast> NUM_INT // Agora retorna um ASTNode *
%token <ast> NUM_REAL // Agora retorna um ASTNode *
%token <ast> STRING // Agora retorna um ASTNode *
%token <ast> OP_DIV
%token <ast> OP_DIV_REC
%token <ast> OP_INC
%token <ast> OP_SOMA
%token <ast> OP_SOMA_REC
%token <ast> OP_SUB
%token <ast> OP_DEC
%token <ast> OP_SUB_REC
%token <ast> SETA
%token <ast> OP_MULT_REC
%token <ast> OP_MULT
%token <ast> OP_MOD
%token <ast> OP_MOD_REC
%token <ast> OP_EQ
%token <ast> OP_ATRIB
%token <ast> OP_DIF
%token <ast> OP_NOT
%token <ast> OP_GE
%token <ast> OP_MAIOR
%token <ast> OP_MENOR
%token <ast> OP_LE
%token <ast> OP_OR
%token <ast> OP_AND
%token <ast> ENDERECO
%token <ast> SG_COMMA
%token <ast> SG_SEMICOLON
%token <ast> PONTO
%token <ast> SG_ABREPAR
%token <ast> SG_FECHAPAR
%token <ast> SG_FECHACOL
%token <ast> SG_ABRECOL
%token <ast> SG_ABRECHV
%token <ast> SG_FECHACHV
%token <ast> OP_KW_DOIS_PONTOS
%token <ast> OP_SELEC

%%
//gramática

////// produções//////

programa
    : lista-decl { astRoot = $1; } //1
    ;

lista-decl
    : lista-decl decl { $$ = newVarFuncDeclNode(NULL, NULL, $1, NULL, $2); } //2
    | decl { $$ = $1; }
    ;

decl
    : decl-var { $$ = $1; } //3
    | decl-func { $$ = $1; }
    ;

decl-var
    : espec-tipo var SG_SEMICOLON { $$ = newVarFuncDeclNode($1, $2, NULL, NULL, NULL); } //4
    ;

espec-tipo
    : KW_INT { $$ = strdup("int"); } //5
    | KW_VOID { $$ = strdup("void"); }
    | KW_REAL { $$ = strdup("real"); }
    ;

decl-func
    : espec-tipo TK_ID SG_ABREPAR params SG_FECHAPAR com-comp { $$ = newVarFuncDeclNode($1, $2, NULL, $4, $6); } //6
    ;

params
    : lista-param { $$ = $1; } //7
    | KW_VOID { $$ = NULL; } // Representa a ausência de parâmetros
    | /* vazio */ { $$ = NULL; }
    ;

lista-param
    : lista-param SG_COMMA param { $$ = newParamListNode($1, $3); } //8
    | param { $$ = newParamNode($1); }
    ;

param
    : espec-tipo var { $$ = newVarDeclNode($1, $2); } //9
    ;

decl-locais
    : decl-locais decl-var { $$ = newLocalDeclNode($1, $2); } //10
    | /* vazio */ { $$ = NULL; }
    ;

lista-com
    : comando lista-com { $$ = newCommandListNode($1, $2); } //11
    | /* vazio */ { $$ = NULL; }
    ;

comando
    : com-exp { $$ = $1; } //12
    | com-atrib { $$ = $1; }
    | com-comp { $$ = $1; }
    | com-selecao { $$ = $1; }
    | com-repeticao { $$ = $1; }
    | com-retorno { $$ = $1; }
    ;

com-exp
    : exp SG_SEMICOLON { $$ = $1; } //13
    | SG_SEMICOLON { $$ = NULL; } // Comando vazio
    ;

com-atrib
    : var OP_ATRIB exp SG_SEMICOLON { $$ = newAssignNode($1, $3); } //14
    ;

com-comp
    : SG_ABRECHV decl-locais lista-com SG_FECHACHV { $$ = newCompoundCommandNode($2, $3); } //15
    ;

com-selecao
    : KW_IF SG_ABREPAR exp SG_FECHAPAR comando { $$ = newIfNode($3, $5, NULL); } //16
    | KW_IF SG_ABREPAR exp SG_FECHAPAR com-comp KW_ELSE comando { $$ = newIfNode($3, $5, $7); }
    ;

com-repeticao
    : KW_WHILE SG_ABREPAR exp SG_FECHAPAR comando { $$ = newWhileNode($3, $5); } //18
    | KW_DO comando KW_WHILE SG_ABREPAR exp SG_FECHAPAR SG_SEMICOLON { $$ = newDoWhileNode($5, $2); }
    ;

com-retorno
    : KW_RETURN SG_SEMICOLON { $$ = newReturnNode(NULL); } //19
    | KW_RETURN exp SG_SEMICOLON { $$ = newReturnNode($2); }
    ;

exp
    : exp-soma op-relac exp-soma { $$ = newBinaryExprNode($1, $3, $2); } //19
    | exp-soma { $$ = $1; }
    ;

op-relac
    : OP_LE { $$ = strdup("<="); } //20
    | OP_MENOR { $$ = strdup("<"); }
    | OP_MAIOR { $$ = strdup(">"); }
    | OP_GE { $$ = strdup(">="); }
    | OP_EQ { $$ = strdup("=="); }
    | OP_DIF { $$ = strdup("!="); }
    ;

exp-soma
    : exp-soma op-soma exp-mult { $$ = newBinaryExprNode($1, $3, $2); } //21
    | exp-mult { $$ = $1; }
    ;

op-soma
    : OP_SOMA { $$ = strdup("+"); } //22
    | OP_SUB { $$ = strdup("-"); }
    ;

exp-mult
    : exp-mult op-mult exp-simples { $$ = newBinaryExprNode($1, $3, $2); } //23
    | exp-simples { $$ = $1; }
    ;

op-mult
    : OP_MULT { $$ = strdup("*"); } //24
    | OP_DIV { $$ = strdup("/"); }
    | OP_MOD { $$ = strdup("%"); }
    ;

exp-simples
    : SG_ABREPAR exp SG_FECHAPAR { $$ = $2; } //25
    | var { $$ = $1; }
    | chama-func { $$ = $1; }
    | literais { $$ = $1; }
    ;

literais
    : NUM_INT { $$ = newLiteralNode(NODE_TYPE_LITERAL_NUM, $1); } //26
    | NUM_REAL { $$ = newLiteralNode(NODE_TYPE_LITERAL_NUM, $1); }
    ;

chama-func
    : TK_ID SG_ABREPAR args SG_FECHAPAR { $$ = newFuncCallNode($1, $3); } //27
    ;

var
    : TK_ID { $$ = newVarNode($1); } //28
    | TK_ID SG_ABRECOL NUM_INT SG_FECHACOL { $$ = newArrayAccessNode($1, $3); }
    ;

args
    : lista-arg { $$ = $1; } //29
    | /* vazio */ { $$ = NULL; }
    ;

lista-arg
    : lista-arg SG_COMMA exp { $$ = newArgListNode($1, $3); } //30
    | exp { $$ = newArgNode($1); }
    ;

%%

//função principal
int yylex() {
	char linha[100];
    char *token;
	char *lexema;
	size_t len;
	if(flag == 1){
		fwrite("\n",sizeof(char),1,output);
	}
	
	flag = 1;

	if(feof(file)) {
		return 0;
	}

    fgets(linha, 100, file);

	token = (char*)strtok(linha, "  ");

	lexema = (char*)strtok(NULL, "  ");

	len = strlen(lexema);

	if(len >1) lexema[len-1] = '\0';

	if(strlen(token) <= 7){
		fwrite(token,sizeof(char),strlen(token),output);
		fwrite("\t\t\t\t",4,1,output);
	}else{
		fwrite(token,sizeof(char),strlen(token),output);
		fwrite("\t\t\t",3,1,output);
	}
	fwrite(lexema,sizeof(char),strlen(lexema),output);

	yylval.str = new_mystring(lexema, len);

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
	else if(strcmp(token, "NUM_REAL") == 0){return NUM_REAL;}
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

//função de erro
void yyerror(const char * s){
	char buffer[50] = "\n--> Houve um erro Sintático!\n";
    cout << buffer;
	fwrite(buffer,sizeof(char),strlen(buffer),output);
   	exit(0);
}

int tempCount = 0;

string newTemp() {
    return "t" + to_string(tempCount++);
}

string generateTAC(ASTNode *node) {
    if (node == NULL) return "";

    switch (node->type) {
        case NODE_TYPE_VAR_DECL:
            // Tratamento para declaração de variáveis
            break;
        case NODE_TYPE_BIN_EXPR: {
            // Tratamento para expressões binárias
            string left = generateTAC(node->data.expr.left);
            string right = generateTAC(node->data.expr.right);
            string temp = newTemp();
            return left + right + temp + " = " + node->data.expr.left->data.literal.value + " " + node->data.expr.op + " " + node->data.expr.right->data.literal.value + "\n";
        }
        // Outros casos (NODE_TYPE_FUNC_DECL, NODE_TYPE_UNARY_EXPR, etc.)
        // ...
    }
    return "";
}

int main(int argc, char ** argv){
	
    if (argc > 1){
		file = fopen(argv[1], "r");
		if (file == NULL){
			cout << "Arquivo " << argv[1] << " não encontrado\n";
			exit(1);
		}
	}
	output = fopen("parserOutput.txt","wb");
	printf("\n--> Iniciando Análise Sintática...\n");
	yyparse();
	printf("\n--> Fim da Análise Sintática...\n\n--> Código sem erros Léxicos ou Sintáticos!\n\n");
	fclose(output);
	fclose(file);

	 printf("\n--> Iniciando Geração de Código Intermediário...\n");
    string tacCode = generateTAC(astRoot);  // Supondo que 'root' é o nó raiz da AST
    cout << tacCode;
    printf("\n--> Fim da Geração de Código Intermediário...\n");
}