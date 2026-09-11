#!/bin/bash

BRed='\033[1;31m'
Green='\033[0;32m'
TESTS_FILE="$BUILD_SOURCESDIRECTORY/failed_tests.txt"
RUNRESULTS_DIR="$BUILD_SOURCESDIRECTORY/RunResults"

# Check if the RunResults directory exists and is not empty:
if [[ ! -d "$RUNRESULTS_DIR" ]] || [[ -z "$(ls -A "$RUNRESULTS_DIR" 2>/dev/null)" ]]
then
  echo -e "\n ${BRed}[ERROR] Os testes não foram executados. O diretório RunResults está vazio ou ausente."
  echo -e "${BRed}Verifique os logs do test_execution.sh para erros de configuração."
  exit 1
fi

# Continue with failure check:
if [[ $FAIL_PIPELINE ]] && [[ -f $TESTS_FILE ]]
then
    FAILED_LINES=$(grep -w "FAILED" "$TESTS_FILE")
    rm -f "$TESTS_FILE"
    if [[ -n "$FAILED_LINES" ]]; then
      echo "$FAILED_LINES"
      echo -e "\n ${BRed}Um ou mais cenários de testes falharam, abortando a pipeline"
      exit 1
    fi
else
    echo -e "${Green}Os testes retornaram sucesso"
    exit 0
fi