#!/bin/bash

umask 000
export CI=true

Color_Off='\033[0m'
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Purple='\033[0;35m'
Cyan='\033[0;36m'

root_dir="src/main/java"
declare -A PIDS

function handle_exit() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')][WARNING] Pipeline cancelada. Finalizando execuções..."
  restante=("${!PIDS[@]}" "${CENARIOS_RESTANTES[@]}")
  if [[ ${#restante[@]} -gt 0 ]]; then
    echo "[WARNING] Cenário(s) $(echo "${restante[@]}" | tr ' ' ',') não executado(s)!"
  fi
  exit 0
}

trap "handle_exit; exit 0" SIGINT SIGTERM

echo $ENABLE_COLLECT_METRIC

ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

if [[ ${DOCKER_IMAGE} == "selenium" ]] || [[ ${DOCKER_IMAGE} == "selenium-xfcb-chrome" ]] || [[ ${DOCKER_IMAGE} == "selenium-xfcb-edge" ]] || [[ ${DOCKER_IMAGE} == "selenium-xfcb-firefox" ]]; then
  unset DISPLAY
  echo 127.0.0.1 ${HOSTNAME} >>/etc/hosts
elif [[ ${DOCKER_IMAGE} == "uftdeveloper" ]]; then
  echo 127.0.0.1 ${HOSTNAME} >>/etc/hosts
  export LFT_LIC_ID="10594"
  export LFT_LIC_SERVER="10.41.8.131"
  echo "LFT_LIC_ID: "${LFT_LIC_ID}""
  echo "LFT_LIC_SERVER: "${LFT_LIC_SERVER}""
  /opt/leanft/Tools/license-installer concurrent ${LFT_LIC_ID} 1 ${LFT_LIC_SERVER} /force
  /opt/leanft/Tools/license-installer status
fi

function generate_hosts_args() {
  grep -v '^\s*#' /initialize/hosts | grep -v '^\s*$' | sudo tee -a /etc/hosts >/dev/null
}

function sanitize_variable() {
  echo $1 | tr -d '\t\n\r' | xargs
}

function unset_array() {
  local -n array=$1
  local element=$2
  local new_array=()
  for item in "${array[@]}"; do
    if [[ $item != $element ]]; then
      new_array+=("$item")
    fi
  done
  echo "${new_array[@]}"
}

function read_projectid() {
  local projectid=$1
  local project_ids=()
  IFS='|' read -ra project_ids <<<"$projectid"
  for item in "${project_ids[@]}"; do
    sanitize_variable $item
  done
}

function get_qandalf_version() {
  if [[ $(grep "<artifactId>qandalf</artifactId>" pom.xml) ]]; then
    echo 3
  else
    echo 2
  fi
}

function find_scenario() {
  local CENARIO=$1
  arquivo=$(find $root_dir -type f -iname "${CENARIO%.*}*.java" | head -n 1)
  if [[ -z $arquivo ]]; then
    echo "$CENARIO"
    return 1
  fi
  echo $(basename "$arquivo" .${arquivo##*.})
}

function execution_echo() {
  echo -e "\n|==================================================================================================|"
  echo -e "                          EXECUTANDO FRAMEWORK $1 EM BACKGROUND:                              "
  echo "|--------------------------------------------------------------------------------------------------|"
  echo " $2: ${CENARIO}                                                                         "
  echo " PARAMS: ${OPTIONAL}"
  echo " PROJECT ID: ${PROJECT_ID}                                                                               "
  echo -e "|==================================================================================================| \n"
}

function get_framework_param() {
  local framework=$1
  case $framework in
  "Cucumber")
    echo $([[ ${QANDALF_VERSION} -eq 3 ]] && echo "-Dcucumber.filter.tags=@${CENARIO}" || echo "-Dcucumber.options=\"--tags'@${CENARIO}'\"")
    ;;
  "JUnit")
    echo "-Dtest=${CENARIO}"
    ;;
  esac
}

function maven_command() {
  local CENARIO=$1
  local ACTION=$2
  local OPTIONAL=$3
  local PROJECT_ID=$4
  local FRAMEWORK_PARAM=$(get_framework_param "${FRAMEWORK}")
  local LOG_FILE_NAME=$(echo "${CENARIO}" | cut -c -15)

  cp -r /app /tmp/"${CENARIO}"
  export RUN_CMD="mvn $ACTION install -U -X \
        -f /tmp/"${CENARIO}"/pom.xml \
        -s /tmp/"${CENARIO}"/settings.xml \
        "${AMBIENTE}" \
        -Dalm_user="${ALM_USER}" \
        -Dalm_password="${ALM_PASSWORD}" \
        -Dalm-username="${ALM_USER}" \
        -Dalm-password="${ALM_PASSWORD}" \
        "$FRAMEWORK_PARAM" $OPTIONAL \
        -Dignore.test.failure=false \
        -Dmaven.repo.local=/.m2/repository \
        -Dorg.slf4j.simpleLogger.showDateTime=true \
        -Dorg.slf4j.simplelogger.dateTimeFormat=\"yyyy-MM-dd-HH:mm:ss\" \
        -Dstyle.color=never"
  echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] MAVEN COMMAND: ${RUN_CMD}" | sed "s/-Dalm-password=${ALM_PASSWORD}/-Dalm-password=******/" | sed "s/-Dalm_password=${ALM_PASSWORD}/-Dalm_password=******/" ##| tee -a /logs/"${LOG_FILE_NAME}"_"UNFINISHED".log

  if [[ ${DOCKER_IMAGE} == "uftdeveloper" ]]; then
    export CHROME_ARGS="--disable-dev-shm-usage --disable-setuid-sandbox --no-sandbox --load-extension=/opt/leanft/Installations/Chrome/v3/Extension --enable-logging --v=1 --disable-save-password-bubble --disable-background-networking --disable-client-side-phishing-detection --disable-component-update --ignore-certificate-errors --allow-running-insecure-content --disable-default-apps --disable-sync --disable-web-resources --no-default-browser-check --no-first-run --window-size=1920,1080 about:blank"
    export RUN_MODE="custom"
    /opt/leanft/executor/leanft-start.sh
  else
    eval "$RUN_CMD"
  fi
  EXIT_CODE=$?
  mv /tmp/"${CENARIO}"/RunResults /app/RunResults/"${LOG_FILE_NAME}"_RunResults
  if [[ $EXIT_CODE -ne 0 ]]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][ERROR] O Cenário ${CENARIO} falhou"
    mv /logs/"${LOG_FILE_NAME}"_"UNFINISHED".log /logs/"${LOG_FILE_NAME}"_"FAILED".log >/dev/null 2>&1
    echo "$CENARIO FAILED" >>/app/failed_tests.txt
    if [[ ${FRAMEWORK} == "JUnit" && ${ENABLE_COLLECT_METRIC,,} == "true" ]]; then
      collect_metrics "${CENARIO}" "${PROJECT_ID}"
    else
      echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Coleta de metricas desabilitada! Framework: ${FRAMEWORK} Flag: ${ENABLE_COLLECT_METRIC,,}"
    fi
  fi
  return $EXIT_CODE
}

function collect_metrics() {
  local CENARIO=$1
  local PROJECT_ID=$2
  local LOG_FILE_NAME=$3
  local CMD="mvn clean test -U \
        -f /build/checkout_env/testes.metrics-framework/pom.xml \
        -s /tmp/"${CENARIO}"/settings.xml \
        -Dtest=App \
        -Dproject-id=${PROJECT_ID} \
        -Dscenario=${CENARIO} \
        -Dtype=scenario \
        -Dproject-version=${VERSION} \
        -Dproject-artifactId=${ARTIFACT_ID} \
        -Duser.timezone=GMT \
        -Dmaven.repo.local=/.m2/repository \
        -Dstyle.color=never"
  echo "------------------------------------------------------------------------------------" >>/logs/"${LOG_FILE_NAME}"_"SUCCESS".log
  echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO]  Coletando métricas para o Cenário: ${CENARIO} e Project ID: ${PROJECT_ID}" | tee -a /logs/"${LOG_FILE_NAME}"_"SUCCESS".log
  echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO]  MAVEN COMMAND: ${CMD}" ##| tee -a /logs/"${LOG_FILE_NAME}"_"SUCCESS".log
  eval "$CMD >> /logs/"${LOG_FILE_NAME}"_"SUCCESS".log 2>&1"
}

function get_memTotal() {
  cat /agent/meminfo | grep MemTotal | awk '{printf "%.2f", $2/1048576}'
}

function get_memAvailable() {
  cat /agent/meminfo | grep MemAvailable | awk '{printf "%.2f", $2/1048576}'
}

function get_memUsed() {
  usage_in_bytes=$(cat /sys/fs/cgroup/memory/memory.usage_in_bytes)
  echo $(awk "BEGIN {printf \"%.2f\", $usage_in_bytes/1024/1024/1024}")
}

function get_memByPID() {
  local PID=$1
  total_memory_kb=0
  get_memory() {
    local pid=$1
    mem_kb=$(grep VmRSS /proc/"$pid"/status 2>/dev/null | awk '{print $2}')
    if [ -n "$mem_kb" ]; then
      total_memory_kb=$((total_memory_kb + mem_kb))
    fi
  }
  get_children_memory() {
    local parent_pid=$1
    get_memory "$parent_pid"
    local children_pids=$(pgrep -P "$parent_pid")
    for child_pid in $children_pids; do
      get_children_memory "$child_pid"
    done
  }
  get_children_memory "$PID"
  echo $total_memory_kb | awk '{printf "%.2f", $0/1048576}'
}

function check_and_remove_finished_pids() {
  local CENARIO_PID
  for CENARIO_PID in "${!PIDS[@]}"; do
    pid=${PIDS[$CENARIO_PID]}
    if ! kill -0 "$pid" 2>/dev/null; then
      unset PIDS[$CENARIO_PID]
    fi
  done
}

function monitor() {
  for CENARIO_PID in "${!PIDS[@]}"; do
    pid=${PIDS[$CENARIO_PID]}
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][INFO] Memoria usada pid $pid[$CENARIO_PID]: $(get_memByPID $pid) GB" | tee -a /logs/hwmonitor.log
  done
}

generate_hosts_args
mapfile -t PROJECT_IDS <<<$(read_projectid "${PROJECT_ID}")

QANDALF_VERSION=$(get_qandalf_version)
echo -e "\nQANDALF_VERSION: ${QANDALF_VERSION}"
echo -e "\n${Purple}TASKS: *****************************************************************************************************"

GROUP_ID=$(grep groupId pom.xml | sed -n '0,/<groupId>/{s/.*<groupId>\(.*\)<\/groupId>.*/\1/p}')
ARTIFACT_ID=$(grep artifactId pom.xml | sed -n '0,/<artifactId>/{s/.*<artifactId>\(.*\)<\/artifactId>.*/\1/p}')
VERSION=$(grep version pom.xml | sed -n '0,/<version>/{s/.*<version>\(.*\)<\/version>.*/\1/p}')
AMBIENTE=$([[ ${QANDALF_VERSION} -eq 3 ]] && echo "-Denvironment=${ENVIRONMENT}" || echo "-Dambiente=${ENVIRONMENT}")

echo -e "\nCENARIO: ${SCENARIO}"

CENARIO=$(find_scenario "${SCENARIO}")
OPTIONAL=${OPTIONAL}

echo -e "\nCENARIO: ${CENARIO}"
echo -e "\nOPTIONAL: ${OPTIONAL}"

# Create RunResults folder
mkdir /app/RunResults

if [[ ${FRAMEWORK} == "Cucumber" ]]; then
  execution_echo "${Green}CUCUMBER${Color_Off}" "TAG"
elif [[ ${FRAMEWORK} == "JUnit" ]]; then
  CENARIO=$(find_scenario "${CENARIO}")
  if [[ $? -ne 0 ]]; then
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')][ERROR] O cenário $CENARIO não foi encontrado."
    continue
  fi
    execution_echo "${Green}J${Red}UNIT${Color_Off}" "CENARIO"
    ACTION="clean"
  else
    echo -e "[$(date '+%Y-%m-%d %H:%M:%S')][ERROR] O Framework selecionado não é válido"
    exit 1
fi

maven_command "${CENARIO}" "${ACTION}" "${OPTIONAL}" "${PROJECT_ID}" &
PIDS[$CENARIO]=$!

while [[ ${#PIDS[@]} -gt 0 ]]; do
  check_and_remove_finished_pids
  monitor
  sleep 10
done
chmod 777 -R /app/RunResults
chmod 777 -R /logs

echo -e "\n${Purple}=================================================================================================="
echo -e "${Purple}                               EXECUÇÕES DE CENÁRIOS FINALIZADAS!                                 "
echo -e "${Purple}--------------------------------------------------------------------------------------------------"

echo -e "${Purple}=================================================================================================="
echo -e "\n${Yellow}AVISO: *****************************************************************************************************"
echo -e "${Yellow}Os logs da execução de cada processo maven e também os Run Results de cada teste estão disponíveis nos
${Yellow}artefatos da pipeline. \n"
sleep 5
