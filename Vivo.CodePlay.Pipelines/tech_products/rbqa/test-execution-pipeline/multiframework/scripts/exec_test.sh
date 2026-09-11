#!/bin/bash

set -euo pipefail

normalize_value() {
  local value="${1:-}"
  echo "${value}" | tr -d '\r' | xargs | tr '[:upper:]' '[:lower:]'
}

FRAMEWORK_VALUE="$(normalize_value "${FRAMEWORK:-cypress}")"

TARGET_SCRIPT=""

case "${FRAMEWORK_VALUE}" in
  cypress)
    TARGET_SCRIPT="/scripts/exec_test_cypress.sh"
    ;;
  playwright|playwright-pure|playwright_pure|pure|native)
    TARGET_SCRIPT="/scripts/exec_test_playwright.sh"
    ;;
  playwright-bdd|playwright_bdd|bdd|cucumber)
    TARGET_SCRIPT="/scripts/exec_test_playwright_bdd.sh"
    ;;
  *)
    echo "##vso[task.logissue type=error]Framework não suportado: ${FRAMEWORK_VALUE}"
    echo "❌ Framework não suportado: ${FRAMEWORK_VALUE}"
    echo "ℹ️ Valores aceitos: cypress, playwright, playwright-bdd, playwright-pure"
    exit 1
    ;;
esac

echo "🚀 Framework selecionado: ${FRAMEWORK_VALUE}"
if [[ "${FRAMEWORK_VALUE}" == playwright* || "${FRAMEWORK_VALUE}" == bdd || "${FRAMEWORK_VALUE}" == cucumber ]]; then
  case "${TARGET_SCRIPT}" in
    /scripts/exec_test_playwright_bdd.sh)
      echo "🎛️ Modo Playwright      : bdd"
      ;;
    /scripts/exec_test_playwright.sh)
      echo "🎛️ Modo Playwright      : pure"
      ;;
  esac
fi
echo "📂 Script: ${TARGET_SCRIPT}"

exec "${TARGET_SCRIPT}" "$@"