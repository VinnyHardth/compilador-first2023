AMARELO='\033[1;33m'
SEM_COR='\033[0m'

function executar_teste_unico() {
  flex scanner.l && bison -o y.tab.c -d parser.y && gcc y.tab.c lex.yy.c -w
  local nome_arquivo="$1"
  if [ -f "$nome_arquivo" ]; then
    echo "Executando: $nome_arquivo"
    ./a.out "$nome_arquivo"
  else
    echo "Arquivo de caso de teste não encontrado: $nome_arquivo"
  fi
}

if [ "$#" -ne 1 ]; then
  echo "Uso: $0 <arquivo_de_caso_de_teste>"
  exit 1
fi

arquivo_de_caso_de_teste="$1"
executar_teste_unico "$arquivo_de_caso_de_teste"
