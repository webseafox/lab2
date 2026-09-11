#!/bin/bash
set -euo pipefail

umask 0022
export CI=true
export npm_config_loglevel="${npm_config_loglevel:-error}"
export NPM_CONFIG_LOGLEVEL="${NPM_CONFIG_LOGLEVEL:-error}"

# Ensure npm cache is writable when container runs as non-root.
export HOME="${HOME:-/tmp}"
export npm_config_cache="${npm_config_cache:-/tmp/.npm}"
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${npm_config_cache}}"
mkdir -p "${HOME}" "${npm_config_cache}"
chmod -R u+rwX "${HOME}" "${npm_config_cache}" 2>/dev/null || true


PROJECT_DIR="$(pwd)"

restore_workspace_permissions() {
  # Ensure files written inside the container are deletable by the host agent user.
  local target_uid="${HOST_UID:-}"
  local target_gid="${HOST_GID:-}"

  set +e

  if [[ "${target_uid}" =~ ^[0-9]+$ && "${target_gid}" =~ ^[0-9]+$ ]]; then
    echo "🔧 [FIX] Restaurando ownership para ${target_uid}:${target_gid}..."
    chown -R "${target_uid}:${target_gid}" "${PROJECT_DIR}" 2>/dev/null || true
  else
    echo "ℹ️ [INFO] HOST_UID/HOST_GID não informados; pulando ajuste de ownership"
  fi

  chmod -R u+rwX "${PROJECT_DIR}" 2>/dev/null || true
}

trap restore_workspace_permissions EXIT

NODE_RUNNER=()
if [ "$(id -u)" -eq 0 ]; then
  if command -v runuser >/dev/null 2>&1 && id -u node >/dev/null 2>&1; then
    NODE_RUNNER=(runuser -u node --)
  else
    echo "❌ [SECURITY] Container iniciou como root, mas não foi possível reduzir privilégios para o usuário node."
    echo "   Garanta que a imagem contenha o usuário node e o binário runuser."
    exit 1
  fi
fi

export GENERATE_REPORT="${GENERATE_REPORT:-false}"
export GENERATE_PDF="${GENERATE_PDF:-false}"
export TAGS="${TAGS:-}"
export FRAMEWORK="${FRAMEWORK:-cypress}"
export ENVIRONMENT="${ENVIRONMENT:-N/A}"
export BROWSER="${BROWSER:-chrome}"
export ALM_UPDATE_OCTANE="${ALM_UPDATE_OCTANE:-false}"
export ALM_PROJECT="${ALM_PROJECT:-}"
export ALM_SUITE_RUN="${ALM_SUITE_RUN:-}"
export ALM_RELEASE="${ALM_RELEASE:-}"
export UPLOAD_PDF="${UPLOAD_PDF:-false}"
export ORACLE_DB_USER="${ORACLE_DB_USER:-}"
export ORACLE_DB_PASSWORD="${ORACLE_DB_PASSWORD:-}"
export ORACLE_DB_CONNECT_STRING="${ORACLE_DB_CONNECT_STRING:-}"


# ==================================================
# Sanitiza variáveis 
# ==================================================
sanitize_var() {
  local val="${1:-}"
  if [[ "$val" =~ ^\$\(.+\)$ ]]; then
    echo ""
  else
    echo "$val"
  fi
}

ALM_PROJECT=$(sanitize_var "${ALM_PROJECT}")
ALM_SUITE_RUN=$(sanitize_var "${ALM_SUITE_RUN}")
ALM_RELEASE=$(sanitize_var "${ALM_RELEASE}")
UPLOAD_PDF=$(sanitize_var "${UPLOAD_PDF}")
ORACLE_DB_USER=$(sanitize_var "${ORACLE_DB_USER}")
ORACLE_DB_PASSWORD=$(sanitize_var "${ORACLE_DB_PASSWORD}")
ORACLE_DB_CONNECT_STRING=$(sanitize_var "${ORACLE_DB_CONNECT_STRING}")

if [ -z "${UPLOAD_PDF}" ]; then
  UPLOAD_PDF="false"
fi

GENERATE_PDF_NORMALIZED="$(echo "${GENERATE_PDF:-false}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')"
UPLOAD_PDF_NORMALIZED="$(echo "${UPLOAD_PDF}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')"

# ==================================================
# Validação e ajuste de dependência entre flags
# ==================================================
if [[ "${GENERATE_PDF,,}" == "true" && "${GENERATE_REPORT,,}" != "true" ]]; then
  echo "##vso[task.logissue type=warning]Inconsistência: PDF requer HTML. Ativando automaticamente."

  echo "⚠️ [WARN] Inconsistência detectada nas flags"
  echo "📄 GENERATE_PDF=true requer GENERATE_REPORT=true"
  echo "🔧 Ativando geração de HTML automaticamente para viabilizar o PDF..."

  GENERATE_REPORT="true"
fi

# ==================================================
# Header cypress 
# ==================================================
echo ""
echo "=================================================="
echo "📦 [START] Execução de Testes Cypress"

printf "%-18s : %s\n" "🧪 Octane Project" "${ALM_PROJECT:-N/A}"
printf "%-18s : %s\n" "📦 Suite"          "${ALM_SUITE_RUN:-N/A}"
printf "%-18s : %s\n" "🚀 Framework"      "${FRAMEWORK:-cypress}"
printf "%-18s : %s\n" "🌍 Environment"    "${ENVIRONMENT:-N/A}"
printf "%-18s : %s\n" "📄 Generate PDF"   "${GENERATE_PDF_NORMALIZED:-false}"
printf "%-18s : %s\n" "📤 Upload PDF"     "${UPLOAD_PDF_NORMALIZED:-false}"

if [ -n "${TAGS}" ]; then
  printf "%-18s : %s\n" "🎯 Execution" "Tags"
  printf "%-17s  : %s\n" "🏷️ Tags"     "${TAGS}"
else
  printf "%-18s : %s\n" "🎯 Execution" "Todos"
fi

echo "=================================================="
echo ""

# ==================================================
# Oracle Client instalação runtime
# ==================================================
echo "🔐 [STEP] Avaliando configuração Oracle..."

ORACLE_USER_SET=false
ORACLE_PASSWORD_SET=false
ORACLE_CONNECT_SET=false

[ -n "${ORACLE_DB_USER:-}" ] && ORACLE_USER_SET=true
[ -n "${ORACLE_DB_PASSWORD:-}" ] && ORACLE_PASSWORD_SET=true
[ -n "${ORACLE_DB_CONNECT_STRING:-}" ] && ORACLE_CONNECT_SET=true

ensure_oracle_runtime_ready() {
  if [ ! -d "/opt/oracle/instantclient_23_8" ]; then
    echo "❌ [ERROR] Oracle Instant Client não encontrado na imagem."
    echo "   A imagem ${CONTAINER_IMAGE:-atual} deve fornecer /opt/oracle/instantclient_23_8 pré-instalado."
    return 1
  fi

  if [ -e "/usr/lib/x86_64-linux-gnu/libaio.so.1" ]; then
    return 0
  fi

  if [ -e "/usr/lib/x86_64-linux-gnu/libaio.so.1t64" ]; then
    local compat_dir="/tmp/oracle-compat"
    mkdir -p "${compat_dir}"
    ln -sf /usr/lib/x86_64-linux-gnu/libaio.so.1t64 "${compat_dir}/libaio.so.1"
    export LD_LIBRARY_PATH="${compat_dir}:${LD_LIBRARY_PATH:-}"
    echo "✅ [OK] Compatibilidade libaio aplicada via symlink em ${compat_dir}"
    return 0
  fi

  if [ -e "/lib/x86_64-linux-gnu/libaio.so.1t64" ]; then
    local compat_dir="/tmp/oracle-compat"
    mkdir -p "${compat_dir}"
    ln -sf /lib/x86_64-linux-gnu/libaio.so.1t64 "${compat_dir}/libaio.so.1"
    export LD_LIBRARY_PATH="${compat_dir}:${LD_LIBRARY_PATH:-}"
    echo "✅ [OK] Compatibilidade libaio aplicada via symlink em ${compat_dir}"
    return 0
  fi

  if [ ! -e "/usr/lib/x86_64-linux-gnu/libaio.so.1" ]; then
    echo "❌ [ERROR] libaio.so.1 não encontrado na imagem."
    echo "   Ajuste a imagem base Oracle/Cypress para incluir libaio.so.1 ou libaio.so.1t64."
    return 1
  fi
}

if ${ORACLE_USER_SET} && ${ORACLE_PASSWORD_SET} && ${ORACLE_CONNECT_SET}; then
  ensure_oracle_runtime_ready

  export LD_LIBRARY_PATH="/opt/oracle/instantclient_23_8:${LD_LIBRARY_PATH:-}"
  export PATH="${PATH:-}:/opt/oracle/instantclient_23_8"
  echo "✅ [OK] Oracle client pré-instalado detectado em /opt/oracle/instantclient_23_8"

  echo "✅ Oracle configurado"
elif ${ORACLE_USER_SET} || ${ORACLE_PASSWORD_SET} || ${ORACLE_CONNECT_SET}; then
  echo "⚠️ [WARN] Oracle parcialmente configurado"
  [ -z "${ORACLE_DB_USER:-}" ] && echo "- USER ausente"
  [ -z "${ORACLE_DB_PASSWORD:-}" ] && echo "- PASSWORD ausente"
  [ -z "${ORACLE_DB_CONNECT_STRING:-}" ] && echo "- CONNECT_STRING ausente"

  echo "ℹ️ [INFO] Prosseguindo sem testes que dependem de Oracle"
else
  echo "ℹ️ [INFO] Oracle não configurado (opcional). Prosseguindo sem testes de banco"
fi

echo ""

cd "${PROJECT_DIR}"

# ==================================================
# Prepare run_results structure
# ==================================================
echo "📂 [STEP] Preparando Run Results..."

RUN_RESULTS_DIR="/app/RunResults"

mkdir -p "${RUN_RESULTS_DIR}/logs"
mkdir -p "${RUN_RESULTS_DIR}/screenshots"


echo "✅ [OK] Estrutura Run Results criada"
echo ""

# ==================================================
# Proxy and node modules cleanup
# ==================================================
echo "🧹 [STEP] Limpando variáveis de proxy..."
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
echo "✅ [OK] Proxies removidos"
echo ""

# ==================================================
# Install dependencies
# ==================================================

if [ -f package-lock.json ]; then
  echo "🔒 Usando npm ci (modo CI)"

  if ! npm ci --no-audit --no-fund --loglevel=error; then
    echo "⚠️ [WARN] npm ci falhou (lock fora de sync)"
    echo "🔁 Executando npm install como fallback..."

    npm install --no-audit --no-fund --loglevel=error || {
      echo "❌ npm install também falhou"
      exit 1
    }
  fi
else
  echo "ℹ️ package-lock.json não encontrado, usando npm install"

  npm install --no-audit --no-fund --loglevel=error || {
    echo "❌ npm install falhou"
    exit 1
  }
fi

echo "✅ [OK] Dependências instaladas"
echo ""



# ==================================================
# Install Cypress binary
# ==================================================
echo "🧪 [STEP] Instalando binário do Cypress..."

# Usa cache fora de /root para evitar EACCES ao executar como usuário node.
export HOME=/tmp
export CYPRESS_CACHE_FOLDER=/tmp/.cache/Cypress
mkdir -p "${CYPRESS_CACHE_FOLDER}"
chown -R node:node /tmp/.cache 2>/dev/null || true

"${NODE_RUNNER[@]}" env \
  HOME="${HOME}" \
  CYPRESS_CACHE_FOLDER="${CYPRESS_CACHE_FOLDER}" \
  npx cypress install
echo "✅ [OK] Binário do Cypress instalado"
echo ""


# ==================================================
# Tags filter (Cucumber)
# ==================================================
CYPRESS_TAGS_ARG=""

if [ -n "${TAGS}" ]; then
  echo "🏷️ Aplicando filtro por TAG: ${TAGS}"

  # Validação da existência da tag
  echo "🔎 Validando existência da tag nos cenários..."
if [ -d "cypress/features" ]; then
  if ! grep -R -F -- "${TAGS}" cypress/features >/dev/null 2>&1; then
    echo "❌ Nenhum cenário encontrado com a tag ${TAGS}"
    exit 1
  fi
else
  echo "⚠️ Pasta cypress/features não encontrada - ignorando validação de TAG"
fi
  echo "✅ Tag encontrada"

  CYPRESS_TAGS_ARG="--env tags=${TAGS}"

else
  echo "ℹ️ Nenhuma TAG informada - executando todos os cenários"
fi

echo ""

# ==================================================
# Browser selection 
# ==================================================
BROWSER="${BROWSER:-chrome}"

case "${BROWSER}" in
  chrome|edge|firefox)
    echo "🧪 Browser selecionado: ${BROWSER}"
    ;;
  *)
    echo "⚠️ Browser inválido (${BROWSER}), usando chrome como fallback"
    BROWSER="chrome"
    ;;
esac

echo ""

# ==================================================
# Run Cypress 
# ==================================================

export HOME=/tmp
export CYPRESS_CACHE_FOLDER=/tmp/.cache/Cypress
mkdir -p /tmp "${CYPRESS_CACHE_FOLDER}"
chown -R node:node /tmp/.cache 2>/dev/null || true
# FIX CHROME ROOT
echo "🔧 [FIX] Configurando Chrome para ambiente root..."

export CHROME_BIN=/usr/bin/google-chrome


# RUN CYPRESS
# Prefer ownership fix over world-writable permissions.
chown -R node:node /app 2>/dev/null || true
echo "▶️  [STEP] Executando Cypress..."

unset DISPLAY

export CYPRESS_BROWSER_ARGS="--no-sandbox --disable-dev-shm-usage --disable-gpu --disable-features=UseDBus"

set +e
set +o pipefail

"${NODE_RUNNER[@]}" env \
  HOME="${HOME}" \
  CYPRESS_CACHE_FOLDER="${CYPRESS_CACHE_FOLDER}" \
  npx cypress run \
  ${CYPRESS_TAGS_ARG} \
  --browser "${BROWSER}" \
  --headless \
  --reporter mochawesome \
  --reporter-options "reportDir=cypress/reports/json,overwrite=false,json=true,html=false" \
  2>&1 | tee "${RUN_RESULTS_DIR}/logs/cypress.log"


CYPRESS_EXIT_CODE=${PIPESTATUS[0]}

set -o pipefail
set -e


echo ""
echo "✅ [INFO] Cypress finalizou com exit code: ${CYPRESS_EXIT_CODE}"
echo ""

if [ "${CYPRESS_EXIT_CODE}" -ne 0 ]; then
  echo "ℹ️ [INFO] Falha detectada. Consulte os artefatos em ${RUN_RESULTS_DIR}/logs e ${RUN_RESULTS_DIR}/reports para detalhes."
  echo ""
fi

# ==================================================
# Copy screenshots 
# ==================================================
set -euo pipefail

POSSIBLE_DIRS=(
  "/app/cypress/screenshots"
  "/app/RunResults/screenshots"
)

DEST="${RUN_RESULTS_DIR}/screenshots"

echo "🔍 [INFO] Buscando screenshots..."

FOUND_SRC=""

for dir in "${POSSIBLE_DIRS[@]}"; do
  if [ -d "$dir" ] && find "$dir" -type f -print -quit 2>/dev/null | grep -q .; then
    FOUND_SRC="$dir"
    break
  fi
done

if [ -n "$FOUND_SRC" ]; then
  echo "📦 [STEP] Screenshots encontrados em: $FOUND_SRC"

  mkdir -p "$DEST"

  # Só copia se for diferente
  if [ "$FOUND_SRC" != "$DEST" ]; then
    cp -a "$FOUND_SRC"/. "$DEST"/
    echo "✅ [OK] Screenshots copiados para $DEST"
  else
    echo "✅ [OK] Screenshots já estão no destino final"
  fi
else
  echo "ℹ️ [INFO] Nenhum screenshot encontrado em nenhum diretório esperado"
fi

# ==================================================
# Gerar relatório HTML 
# ==================================================
if [[ "${GENERATE_REPORT,,}" == "true" ]]; then
  echo "📊 [STEP] Gerando relatório HTML (cy:report)..."

  if npm run cy:report; then
    echo "✅ [OK] Relatório HTML gerado"
  else
    REPORT_EXIT_CODE=$?
    echo "⚠️ [WARN] Falha ao gerar relatório HTML"
    echo "EXIT CODE REPORT: ${REPORT_EXIT_CODE}"
  fi
  echo ""
else
  echo "ℹ️ [INFO] Geração de relatório desabilitada"
  echo ""
fi

# ==================================================
# Preparação puppeteer (somente se PDF ativo)
# ==================================================
if [[ "$(echo "${GENERATE_PDF:-false}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')" == "true" ]]; then

  echo "🌐 [STEP] Preparando Chrome para geração de PDF..."

  export PUPPETEER_EXECUTABLE_PATH=$(which google-chrome || which chromium || echo "")

  export PUPPETEER_ARGS="--no-sandbox \
  --disable-setuid-sandbox \
  --disable-dev-shm-usage \
  --disable-gpu \
  --no-zygote \
  --single-process"

  if [ -z "$PUPPETEER_EXECUTABLE_PATH" ]; then
    echo "⚠️ Chrome não encontrado, instalando via Puppeteer..."
    npx puppeteer browsers install chrome

    export PUPPETEER_EXECUTABLE_PATH=$(which google-chrome || which chromium || echo "")

    if [ -z "$PUPPETEER_EXECUTABLE_PATH" ]; then
      echo "❌ [ERROR] Não foi possível localizar Chrome"
      exit 1
    fi
  else
    echo "✅ Chrome encontrado em: $PUPPETEER_EXECUTABLE_PATH"
  fi

  echo ""

  echo "📄 [STEP] Gerando PDF de evidências..."

  mkdir -p cypress/reports/pdf
  mkdir -p .tmp/features

  # convert:pdf can run as node user; guarantee writable output/temp folders.
  if id -u node >/dev/null 2>&1; then
    chown -R node:node .tmp cypress/reports 2>/dev/null || true
  fi
  chmod -R u+rwX .tmp cypress/reports 2>/dev/null || true

set +e
  "${NODE_RUNNER[@]}" env \
    PUPPETEER_EXECUTABLE_PATH="$PUPPETEER_EXECUTABLE_PATH" \
    PUPPETEER_ARGS="$PUPPETEER_ARGS" \
    npm run convert:pdf

  PDF_EXIT_CODE=$?
set -e

  if [ "$PDF_EXIT_CODE" -eq 0 ]; then
    echo "✅ [OK] PDF gerado com sucesso"
  else
    echo "⚠️ [WARN] Falha ao gerar PDF"
    echo "EXIT CODE PDF: ${PDF_EXIT_CODE}"
  fi

  echo ""

fi

# ==================================================
# Publicar resultados no ALM Octane 
# ==================================================
if [[ "$(echo "${ALM_UPDATE_OCTANE:-false}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]')" == "true" ]]; then
  echo "🚀 [STEP] Enviando resultados para ALM Octane..."

  # Validação obrigatória
  REQUIRED_OCTANE_VARS=(
    ALM_USERNAME
    ALM_PASSWORD
    ALM_HOST
    ALM_DOMAIN
    ALM_PROJECT
    ALM_SUITE_RUN
    ALM_RELEASE
    ALM_ENVIRONMENT
    UPLOAD_PDF
  )

  MISSING_OCTANE_VARS=()
  for var_name in "${REQUIRED_OCTANE_VARS[@]}"; do
    if [ -z "${!var_name:-}" ]; then
      MISSING_OCTANE_VARS+=("${var_name}")
    fi
  done

  if [ "${#MISSING_OCTANE_VARS[@]}" -gt 0 ]; then
    echo "❌ [ERROR] Variáveis obrigatórias do Octane ausentes"
    printf ' - %s\n' "${MISSING_OCTANE_VARS[@]}"
    exit 1
  fi

  # Extrair ID da suíte (ex: 6202)
  ALM_SUITE_ID=$(echo "${ALM_SUITE_RUN}" | cut -d' ' -f1)

  # Export
  export ALM_PROJECT
  export ALM_SUITE_RUN
  export ALM_SUITE_ID
  export ALM_RELEASE


# Execução
echo "🚀 Executando publicação Octane..."

set +e
PUBLISH_OUTPUT=$(npm run publish:results 2>&1)
PUBLISH_EXIT_CODE=$?
set -e

echo "$PUBLISH_OUTPUT"


if echo "$PUBLISH_OUTPUT" | grep -q "Nenhum cenário encontrado"; then
  echo "⚠️ [WARN] Envio abortado"
  OCTANE_EXIT_CODE=1


# erro técnico
elif [ "$PUBLISH_EXIT_CODE" -ne 0 ]; then
  echo "❌ [ERROR] Falha ao enviar resultados para Octane"
  OCTANE_EXIT_CODE=$PUBLISH_EXIT_CODE


# sucesso real
else
  echo "✅ [OK] Envio para Octane realizado com sucesso"
fi

echo ""
fi
# ==================================================
# Consolidate evidences 

# ==================================================
echo "📷 Screenshots disponíveis em ${RUN_RESULTS_DIR}/screenshots"

# HTML report (cy:report)
if [ -d "cypress/reports/html" ]; then
  echo "📄 Movendo relatório HTML para RunResults..."

  mkdir -p "${RUN_RESULTS_DIR}/reports/html"

  if compgen -G "cypress/reports/html/*" > /dev/null; then
    mv cypress/reports/html/* "${RUN_RESULTS_DIR}/reports/html/"
    echo "✅ [OK] HTML report movido"
  else
    echo "⚠️ [WARN] Pasta HTML existe mas está vazia"
  fi
else
  echo "ℹ️ [INFO] Pasta cypress/reports/html não encontrada"
fi

# PDF report (convert:pdf)
if [ -d "cypress/reports/pdf" ]; then
  echo "📄 Movendo PDF para RunResults..."

  mkdir -p "${RUN_RESULTS_DIR}/reports/pdf"

  if compgen -G "cypress/reports/pdf/*.pdf" > /dev/null; then
    mv cypress/reports/pdf/* "${RUN_RESULTS_DIR}/reports/pdf/"
    echo "✅ [OK] PDF movido para ${RUN_RESULTS_DIR}/reports/pdf"
  else
    echo "⚠️ [WARN] Pasta PDF existe mas está vazia"
  fi
else
  echo "ℹ️ [INFO] Pasta cypress/reports/pdf não encontrada"
fi

echo "✅ [OK] Evidências consolidadas"
echo ""

# ==================================================
# Gera metadata de execução
# ==================================================
echo "🧾 [STEP] Gerando metadata da execução..."

export npm_config_loglevel=error

{
  echo "Framework       : ${FRAMEWORK:-cypress}" 
  echo "Environment     : ${ENVIRONMENT:-N/A}"

  # Execução
  if [ -n "${TAGS}" ]; then
    echo "Execution       : Tags"
    echo "Tags            : ${TAGS}"
  else
    echo "Execution       : Todos"
  fi

  echo ""

  echo "Octane:"
  echo "Project         : ${ALM_PROJECT:-N/A}"
  echo "Suite           : ${ALM_SUITE_RUN:-N/A}"

  if [ -n "${ALM_SUITE_RUN:-}" ]; then
    ALM_SUITE_ID=$(echo "${ALM_SUITE_RUN}" | cut -d' ' -f1)
    echo "Suite ID        : ${ALM_SUITE_ID}"
  fi

  echo ""

  # Execução técnica
  echo "Execution Date  : $(date)"
  echo "Node Version    : $(node -v)"
  echo "NPM Version     : $(npm -v)"
  echo "Cypress Version : $(npx cypress version | head -n 1)"
  echo "Exit Code       : ${CYPRESS_EXIT_CODE}"

} > "${RUN_RESULTS_DIR}/logs/execution.log"

echo "✅ [OK] Metadata registrada"
echo ""

# ==================================================
# Cleanup 
# ==================================================
echo "🧹 [STEP] Limpando artefatos temporários..."
rm -rf cypress/downloads || true
echo "✅ [OK] Limpeza concluída"
echo ""
# ==================================================
# Fix permission and ownership for the agent
# ==================================================

chmod -R a+rX,u+w "${RUN_RESULTS_DIR}" || true

# ==================================================
# Final message
# ==================================================
if [ "${CYPRESS_EXIT_CODE}" -ne 0 ]; then
  echo "❌=================================================="
  echo "❌ [FAILED] Execução de testes Cypress com falhas"
  echo "❌ Evidências disponíveis em ${RUN_RESULTS_DIR}"
  echo "❌=================================================="
  echo ""
else
  echo "🎉=================================================="
  echo "🎉 [SUCCESS] Execução de testes Cypress concluída"
  echo "🎉 Evidências disponíveis em ${RUN_RESULTS_DIR}"
  echo "🎉=================================================="
  echo ""
fi
exit ${CYPRESS_EXIT_CODE}