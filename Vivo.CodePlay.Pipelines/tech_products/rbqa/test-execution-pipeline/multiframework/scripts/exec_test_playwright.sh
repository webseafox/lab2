#!/bin/bash

set -euo pipefail

umask 0022

export CI=true
export npm_config_loglevel="${npm_config_loglevel:-error}"
export NPM_CONFIG_LOGLEVEL="${NPM_CONFIG_LOGLEVEL:-error}"

# Garantir que o cache do npm seja gravável quando o container não roda como root.
export HOME="${HOME:-/tmp}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-/tmp/.cache}"
export npm_config_cache="${npm_config_cache:-/tmp/.npm}"
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-${npm_config_cache}}"
# Garante cache gravável antes de instalar dependências ou iniciar o navegador.
mkdir -p "${HOME}" "${XDG_CACHE_HOME}" "${npm_config_cache}"
chmod -R u+rwX "${HOME}" "${XDG_CACHE_HOME}" "${npm_config_cache}" 2>/dev/null || true

PROJECT_DIR="$(pwd)"
RUN_RESULTS_DIR="${RUN_RESULTS_DIR:-/app/RunResults}"
LOG_DIR="${RUN_RESULTS_DIR}/logs"
REPORTS_DIR="${REPORTS_DIR:-playwright-report}"

mkdir -p "${RUN_RESULTS_DIR}" "${LOG_DIR}" "${RUN_RESULTS_DIR}/reports" "${RUN_RESULTS_DIR}/logs/test-results"

restore_workspace_permissions() {
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

log_step() {
  echo ""
  echo "=================================================="
  echo "${1}"
  echo "=================================================="
}

warn() {
  echo "##vso[task.logissue type=warning]${1}"
  echo "⚠️  [WARN] ${1}"
}

die() {
  echo "##vso[task.logissue type=error]${1}"
  echo "❌ [ERROR] ${1}"
  exit 1
}

normalize_bool() {
  local value="${1:-false}"
  echo "${value}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]'
}

trim_value() {
  local value="${1:-}"
  echo "${value}" | tr -d '\r' | xargs
}

require_command() {
  local command_name="${1:-}"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    die "Dependência obrigatória não encontrada: ${command_name}"
  fi
}

validate_playwright_browser() {
  local browser_name="$(trim_value "${1:-}")"
  browser_name="$(echo "${browser_name}" | tr '[:upper:]' '[:lower:]')"

  case "${browser_name}" in
    chromium|webkit)
      echo "${browser_name}"
      ;;
    *)
      die "Browser '${browser_name}' não suportado. Navegadores permitidos: chromium, webkit."
      ;;
  esac
}

should_publish_playwright_report() {
  local report_dir="${1:-playwright-report}"
  local index_file="${report_dir}/index.html"

  if [ ! -d "${report_dir}" ] || [ ! -f "${index_file}" ]; then
    return 1
  fi

  if grep -q -i "No tests found" "${index_file}" 2>/dev/null; then
    return 1
  fi

  return 0
}

is_positive_int() {
  [[ "${1:-}" =~ ^[1-9][0-9]*$ ]]
}

ENVIRONMENT="$(trim_value "${ENVIRONMENT:-dev}")"
ENVIRONMENT="$(echo "${ENVIRONMENT}" | tr '[:upper:]' '[:lower:]')"
HEADLESS="$(normalize_bool "${HEADLESS:-true}")"
CI="true"
TAGS="$(trim_value "${TAGS:-${TEST_TAGS:-}}")"
BROWSER="$(trim_value "${BROWSER:-chromium}")"
PLAYWRIGHT_INSTALL_BROWSERS="$(normalize_bool "${PLAYWRIGHT_INSTALL_BROWSERS:-false}")"
RETRY_COUNT="$(trim_value "${RETRY_COUNT:-0}")"
PLAYWRIGHT_PROJECT="$(trim_value "${PLAYWRIGHT_PROJECT:-}")"
PLAYWRIGHT_CONFIG="$(trim_value "${PLAYWRIGHT_CONFIG:-}")"

PLAYWRIGHT_BROWSER_SELECTION="config/project"

if [ -z "${PLAYWRIGHT_CONFIG}" ] && [ -z "${PLAYWRIGHT_PROJECT}" ]; then
  PLAYWRIGHT_BROWSER_SELECTION="cli"
fi

export ENVIRONMENT HEADLESS CI TAGS BROWSER RETRY_COUNT PLAYWRIGHT_PROJECT PLAYWRIGHT_CONFIG

if [ ! -f package.json ]; then
  die "package.json nao encontrado no diretorio atual (${PROJECT_DIR})"
fi

PLAYWRIGHT_CONFIG_FOUND=false
for candidate in \
  playwright.config.ts \
  playwright.config.js \
  playwright.config.mjs \
  playwright.config.cjs; do
  if [ -f "${candidate}" ]; then
    PLAYWRIGHT_CONFIG_FOUND=true
    break
  fi
done

if [ "${PLAYWRIGHT_CONFIG_FOUND}" = "false" ] && [ -z "${PLAYWRIGHT_CONFIG}" ]; then
  warn "Nenhum playwright.config.* encontrado. O projeto precisa fornecer config via pacote ou ajustar PLAYWRIGHT_CONFIG."
fi

require_command node
require_command npm
require_command npx
# ==================================================
# Cabeçalho da execução
# ==================================================
log_step "📦 [START] Execução de Testes Playwright"

echo "🔎 Contexto da execução"
echo "📁 Projeto           : ${PROJECT_DIR}"
echo "🖥️ Headless          : ${HEADLESS}"
echo "🌐 Browser           : ${BROWSER}"
echo "🎛️ Browser Selection : ${PLAYWRIGHT_BROWSER_SELECTION}"
echo "📋 Project           : ${PLAYWRIGHT_PROJECT:-<none>}"
echo "🏷️ Grep Pattern      : ${TAGS:-<none>}"
echo "📦 Run Results       : ${RUN_RESULTS_DIR}"
echo "🗂️ Reports           : ${REPORTS_DIR}"

# ==================================================
# Proxy e instalação das dependências
# ==================================================

echo ""
echo "🧹 [STEP] Limpando variáveis de proxy..."
unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY NO_PROXY
echo "✅ [OK] Proxies removidos"


echo "📦 [STEP] Instalando dependências..."

if [ -f package-lock.json ]; then
  echo "🔒 Usando npm ci (modo CI)"

  if ! "${NODE_RUNNER[@]}" npm ci --no-audit --no-fund --loglevel=error; then
    warn "npm ci falhou; tentando npm install"
    "${NODE_RUNNER[@]}" npm install --no-audit --no-fund --loglevel=error
  fi
else
  echo "ℹ️ package-lock.json não encontrado, usando npm install"
  "${NODE_RUNNER[@]}" npm install --no-audit --no-fund --loglevel=error
fi

echo "✅ [OK] Dependências instaladas"

echo ""
echo "📊 [STEP] Coletando diagnósticos de runtime..."
NODE_VERSION="$(${NODE_RUNNER[@]} node -v)"
NPM_VERSION="$(${NODE_RUNNER[@]} npm -v)"
PLAYWRIGHT_VERSION="$(${NODE_RUNNER[@]} npx playwright --version)"

echo "Node Version       : ${NODE_VERSION}"
echo "NPM Version        : ${NPM_VERSION}"
echo "Playwright Version : ${PLAYWRIGHT_VERSION}"

echo ""

PLAYWRIGHT_BROWSER_MAPPED="$(validate_playwright_browser "${BROWSER}")"
PLAYWRIGHT_INSTALL_TARGETS=("${PLAYWRIGHT_BROWSER_MAPPED}")

if [ "${PLAYWRIGHT_INSTALL_BROWSERS}" = "true" ]; then
  echo ""
  echo "🧪 [STEP] Instalando browser do Playwright..."
  # Instala apenas o browser derivado do input do pipeline.
  if [ "${#PLAYWRIGHT_INSTALL_TARGETS[@]}" -gt 0 ]; then
    "${NODE_RUNNER[@]}" npx playwright install --with-deps "${PLAYWRIGHT_INSTALL_TARGETS[@]}"
  else
    "${NODE_RUNNER[@]}" npx playwright install --with-deps
  fi
  echo "✅ [OK] Browsers do Playwright prontos"
else
  echo ""
  echo "ℹ️ [INFO] Instalação de browsers do Playwright desabilitada"
fi

# ==================================================
# Validações de runtime
# ==================================================

PLAYWRIGHT_ARGS=()

if [ -n "${PLAYWRIGHT_CONFIG}" ]; then
  if [ ! -f "${PLAYWRIGHT_CONFIG}" ]; then
    die "PLAYWRIGHT_CONFIG informado, mas o arquivo nao existe: ${PLAYWRIGHT_CONFIG}"
  fi

  PLAYWRIGHT_ARGS+=("--config" "${PLAYWRIGHT_CONFIG}")
fi

if [ -n "${PLAYWRIGHT_PROJECT}" ]; then
  PLAYWRIGHT_ARGS+=("--project" "${PLAYWRIGHT_PROJECT}")
fi

if [ -n "${TAGS}" ]; then
  PLAYWRIGHT_ARGS+=("--grep" "${TAGS}")
fi

# Only force --browser when the run is not already scoped by an explicit Playwright config/project.
# Config-driven project selection should keep working without CLI browser overrides.
if [ "${PLAYWRIGHT_BROWSER_SELECTION}" = "cli" ] && [ -n "${PLAYWRIGHT_BROWSER_MAPPED}" ]; then
  PLAYWRIGHT_ARGS+=("--browser" "${PLAYWRIGHT_BROWSER_MAPPED}")
fi

if [ "${HEADLESS}" = "false" ]; then
  PLAYWRIGHT_ARGS+=("--headed")
fi

if is_positive_int "${RETRY_COUNT:-0}"; then
  PLAYWRIGHT_ARGS+=("--retries" "${RETRY_COUNT}")
fi

# ==================================================
# Execução dos testes
# ==================================================
echo ""
echo "▶️ [STEP] Executando testes..."
echo "▶️ Comando final: playwright test ${PLAYWRIGHT_ARGS[*]:-}"

set +e

"${NODE_RUNNER[@]}" npx playwright test "${PLAYWRIGHT_ARGS[@]}" 2>&1 | tee "${LOG_DIR}/playwright.log"

PLAYWRIGHT_EXIT_CODE=${PIPESTATUS[0]}

set -e

# ==================================================
# Consolidação de evidências
# ==================================================

echo ""
echo "🧾 [STEP] Consolidando artefatos..."

if [ -d "${REPORTS_DIR}" ]; then
  # Aceita diretórios de relatório definidos pelo próprio projeto.
  if should_publish_playwright_report "${REPORTS_DIR}"; then
    cp -a "${REPORTS_DIR}"/. "${RUN_RESULTS_DIR}/reports"/ 2>/dev/null || true
  else
    echo "ℹ️ [INFO] Playwright report vazio; publicação ignorada"
  fi
fi

if [ "${REPORTS_DIR}" != "playwright-report" ] && [ -d "playwright-report" ]; then
  # Copia o relatório padrão do Playwright para a área de evidências.
  if should_publish_playwright_report "playwright-report"; then
    cp -a playwright-report/. "${RUN_RESULTS_DIR}/reports"/ 2>/dev/null || true
  else
    echo "ℹ️ [INFO] Playwright report vazio; publicação ignorada"
  fi
fi

if [ -d "reports" ]; then
  # Aceita projetos que publiquem a saída em reports/.
  cp -a reports/. "${RUN_RESULTS_DIR}/reports"/ 2>/dev/null || true
fi

if [ -d "test-results" ]; then
  # Preserva traces e saídas auxiliares para investigação de falhas.
  cp -a test-results/. "${RUN_RESULTS_DIR}/logs/test-results"/ 2>/dev/null || true
fi

if [ -f "${LOG_DIR}/playwright.log" ]; then
  cp -a "${LOG_DIR}/playwright.log" "${RUN_RESULTS_DIR}/logs/" 2>/dev/null || true
fi

if [ -d "${REPORTS_DIR}" ] || [ -d "playwright-report" ] || [ -d "reports" ]; then
  echo "✅ [OK] Relatorios encontrados"
else
  warn "Nenhum diretorio de relatorio padrão encontrado"
fi

# Mantém o mesmo padrão do Cypress para evitar problema de permissão no host.
chmod -R a+rX,u+w "${RUN_RESULTS_DIR}" 2>/dev/null || true

# ==================================================
# Metadata e finalização
# ==================================================
echo ""
echo "✅ Playwright finalizado com código: ${PLAYWRIGHT_EXIT_CODE}"
echo "📦 Evidências em: ${RUN_RESULTS_DIR}"

# ==================================================
# Mensagem final
# ==================================================
if [ "${PLAYWRIGHT_EXIT_CODE}" -ne 0 ]; then
  echo "❌=================================================="
  echo "❌ [FAILED] Execução de testes Playwright com falhas"
  echo "❌ Evidências disponíveis em ${RUN_RESULTS_DIR}"
  echo "❌=================================================="
  echo ""
else
  echo "🎉=================================================="
  echo "🎉 [SUCCESS] Execução de testes Playwright concluída"
  echo "🎉 Evidências disponíveis em ${RUN_RESULTS_DIR}"
  echo "🎉=================================================="
  echo ""
fi

exit ${PLAYWRIGHT_EXIT_CODE}