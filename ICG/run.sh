#!/bin/bash

YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

function run_single_test() {
  flex scanner.l && bison -o y.tab.c -d parser.y && gcc y.tab.c lex.yy.c -w
  local filename="$1"
  if [ -f "$filename" ]; then
    echo "Running: $filename"
    ./a.out "$filename"
  else
    echo "Test case file not found: $filename"
  fi
}

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <test_case_file>"
  exit 1
fi

test_case_file="$1"
run_single_test "$test_case_file"
