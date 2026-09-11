#!/bin/bash
set -e

echo "🚀 Starting test execution"
echo "Container image: ${CONTAINER_IMAGE}"
echo "Framework: ${FRAMEWORK}"

: "${CONTAINER_IMAGE:?CONTAINER_IMAGE not defined}"
: "${DOCKER_WORKDIR:?DOCKER_WORKDIR not defined}"

HOST_UID="$(id -u)"
HOST_GID="$(id -g)"
RUNTIME_UID="${HOST_UID}"
RUNTIME_GID="${HOST_GID}"

if [ "${HOST_UID}" -eq 0 ]; then
  # Keep pipeline running while still enforcing non-root execution inside container.
  RUNTIME_UID="${CONTAINER_UID:-1000}"
  RUNTIME_GID="${CONTAINER_GID:-1000}"
  echo "⚠️ [SECURITY] Host UID=0 detectado; forçando container não-root ${RUNTIME_UID}:${RUNTIME_GID}."
fi

CONTAINER_USER="${RUNTIME_UID}:${RUNTIME_GID}"

normalize_browser() {
  local browser_name="${1:-}"
  echo "${browser_name}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]'
}

BROWSER_VALUE="$(normalize_browser "${BROWSER:-chromium}")"

reconcile_workspace_permissions() {
  echo "🔧 [STEP] Reconciliando permissões do workspace para ${RUNTIME_UID}:${RUNTIME_GID}..."

  chmod -R u+rwX "${BUILD_SOURCESDIRECTORY}" 2>/dev/null || true

  if [ "$(id -u)" -eq 0 ]; then
    chown -R "${RUNTIME_UID}:${RUNTIME_GID}" "${BUILD_SOURCESDIRECTORY}" 2>/dev/null || true
  fi
}

# ==================================================
# Arquivos temporários + cleanup garantido no EXIT
# ==================================================
TEMP_DIR="${AGENT_TEMPDIRECTORY:-${PIPELINE_WORKSPACE:-$(pwd)}}"
mkdir -p "${TEMP_DIR}"

TEMP_ENVFILE=$(mktemp "${TEMP_DIR}/rbqa_env.XXXXXX")
TEMP_NPMRC=""

chmod 600 "${TEMP_ENVFILE}"

cleanup() {
  reconcile_workspace_permissions
  rm -f "${TEMP_ENVFILE}" "${TEMP_NPMRC}" 2>/dev/null || true
}
trap cleanup EXIT

# ==================================================
# Criação do env file seguro
# ==================================================
echo "🔐 [STEP] Criando arquivo de ambiente seguro..."

UPLOAD_PDF_EFFECTIVE="${UPLOAD_PDF:-${GENERATE_PDF:-false}}"

cat <<EOF > "${TEMP_ENVFILE}"
ENVIRONMENT=${ENVIRONMENT}
TAGS=${TAGS}
OPTIONALS=${OPTIONALS}
FRAMEWORK=${FRAMEWORK}
BROWSER=${BROWSER}
HEADLESS=${HEADLESS}
RETRY_COUNT=${RETRY_COUNT}
PARALLEL_WORKERS=${PARALLEL_WORKERS}
PLAYWRIGHT_INSTALL_BROWSERS=${PLAYWRIGHT_INSTALL_BROWSERS}
CUCUMBER_PROFILE=${CUCUMBER_PROFILE}
TEST_TAGS=${TEST_TAGS}

# Oracle
ORACLE_DB_USER=${ORACLE_DB_USER}
ORACLE_DB_PASSWORD=${ORACLE_DB_PASSWORD}
ORACLE_DB_CONNECT_STRING=${ORACLE_DB_CONNECT_STRING}

# ALM
ALM_USERNAME=${ALM_USERNAME}
ALM_PASSWORD=${ALM_PASSWORD}
ALM_HOST=${ALM_HOST}
ALM_DOMAIN=${ALM_DOMAIN}
ALM_PROJECT=${ALM_PROJECT}
ALM_SUITE_RUN=${ALM_SUITE_RUN}
ALM_UPDATE_OCTANE=${ALM_UPDATE_OCTANE}
ALM_RELEASE=${ALM_RELEASE}
ALM_ENVIRONMENT=${ALM_ENVIRONMENT}

# Reports
GENERATE_REPORT=${GENERATE_REPORT}
GENERATE_PDF=${GENERATE_PDF}
UPLOAD_PDF=${UPLOAD_PDF_EFFECTIVE}

EOF

# ==================================================
# Optional .npmrc injection
# ==================================================
echo "🔐 [STEP] Validando .npmrc do projeto..."

if [ -f "${BUILD_SOURCESDIRECTORY}/.npmrc" ]; then
  if [ -z "${SYSTEM_ACCESSTOKEN:-}" ]; then
    echo "❌ [ERROR] SYSTEM_ACCESSTOKEN está vazio."
    echo "   Habilite 'Allow scripts to access the OAuth token' no pipeline/job."
    exit 1
  fi

  TEMP_NPMRC=$(mktemp)
  chmod 600 "${TEMP_NPMRC}"
  envsubst < "${BUILD_SOURCESDIRECTORY}/.npmrc" > "${TEMP_NPMRC}"

  if ! grep -q '\${SYSTEM_ACCESSTOKEN}' "${BUILD_SOURCESDIRECTORY}/.npmrc"; then
    echo "⚠️ [WARN] Placeholder \${SYSTEM_ACCESSTOKEN} não encontrado no .npmrc de origem."
    echo "   Verifique se o arquivo usa o placeholder esperado para autenticação no feed."
  fi

  if grep -q '\${SYSTEM_ACCESSTOKEN}' "${TEMP_NPMRC}"; then
    echo "❌ [ERROR] SYSTEM_ACCESSTOKEN NÃO foi substituído no .npmrc!"
    echo "   Variável provavelmente ausente no ambiente. Verifique SYSTEM_ACCESSTOKEN na task."
    exit 1
  fi

  if grep -q '_authToken=$' "${TEMP_NPMRC}"; then
    echo "❌ [ERROR] _authToken vazio após envsubst no .npmrc."
    echo "   Verifique permissões do OAuth token e acesso ao feed Azure Artifacts."
    exit 1
  fi

  echo "✅ [OK] .npmrc do projeto encontrado e autenticado"
else
  echo "ℹ️ [INFO] .npmrc não encontrado; seguindo sem montagem de feed privado"
fi

# ==================================================
# Run container
# ==================================================

if [ -n "${TEMP_NPMRC}" ] && [ -f "${TEMP_NPMRC}" ]; then
  docker_id=$(
    docker run -d --init \
      --user="${CONTAINER_USER}" \
      --security-opt no-new-privileges:true \
      --cap-drop ALL \
      --log-opt max-size=10m \
      --log-opt max-file=3 \
      --stop-timeout 120 \
      --label ci_pipeline=true \
      --env-file "${TEMP_ENVFILE}" \
      -e PUPPETEER_SKIP_DOWNLOAD=true \
      -e HTTPS_PROXY="${HTTPS_QA_PROXY}" \
      -e HTTP_PROXY="${HTTP_QA_PROXY}" \
      -e NO_PROXY="${NO_PROXY}" \
      -e TZ="America/Sao_Paulo" \
      -e HOST_UID="${RUNTIME_UID}" \
      -e HOST_GID="${RUNTIME_GID}" \
      -v "${BUILD_SOURCESDIRECTORY}:${DOCKER_WORKDIR}" \
      -v "${TEMP_NPMRC}:${DOCKER_WORKDIR}/.npmrc:ro" \
      -v "${INITIALIZE_FOLDER}:/initialize" \
      -v "${SCRIPTS_FOLDER}:/scripts" \
      -v "${AGENT_TMP_DIRECTORY}:/logs" \
      -w "${DOCKER_WORKDIR}" \
      --entrypoint /scripts/exec_test.sh \
      "${CONTAINER_IMAGE}"
  )
else
  docker_id=$(
    docker run -d --init \
      --user="${CONTAINER_USER}" \
      --security-opt no-new-privileges:true \
      --cap-drop ALL \
      --log-opt max-size=10m \
      --log-opt max-file=3 \
      --stop-timeout 120 \
      --label ci_pipeline=true \
      --env-file "${TEMP_ENVFILE}" \
      -e PUPPETEER_SKIP_DOWNLOAD=true \
      -e HTTPS_PROXY="${HTTPS_QA_PROXY}" \
      -e HTTP_PROXY="${HTTP_QA_PROXY}" \
      -e NO_PROXY="${NO_PROXY}" \
      -e TZ="America/Sao_Paulo" \
      -e HOST_UID="${RUNTIME_UID}" \
      -e HOST_GID="${RUNTIME_GID}" \
      -v "${BUILD_SOURCESDIRECTORY}:${DOCKER_WORKDIR}" \
      -v "${INITIALIZE_FOLDER}:/initialize" \
      -v "${SCRIPTS_FOLDER}:/scripts" \
      -v "${AGENT_TMP_DIRECTORY}:/logs" \
      -w "${DOCKER_WORKDIR}" \
      --entrypoint /scripts/exec_test.sh \
      "${CONTAINER_IMAGE}"
  )
fi

trap 'docker stop -t 120 "$docker_id" || true' SIGTERM SIGINT

echo "Container ID: $docker_id"

docker logs -f "$docker_id" &
LOGS_PID=$!

EXIT_CODE="$(docker wait "$docker_id")"

wait "$LOGS_PID" || true

docker rm -f "$docker_id" || true

exit "$EXIT_CODE"
