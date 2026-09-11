#!/bin/bash

BRed='\033[1;31m'
Green='\033[0;32m'
TESTS_FILE="$BUILD_SOURCESDIRECTORY/failed_tests.txt"

if [[ $FAIL_PIPELINE ]] && [[ -f $TESTS_FILE ]]
then
    cat $TESTS_FILE | grep -w "FAILED" && echo -e "\n ${BRed}Um ou mais cenários de testes falharam, abortando a pipeline" && exit 1
    rm -f $(Build.SourcesDirectory)/failed_tests.txt
else
    echo -e "${Green}Os testes retornaram sucesso"
    exit 0
fi