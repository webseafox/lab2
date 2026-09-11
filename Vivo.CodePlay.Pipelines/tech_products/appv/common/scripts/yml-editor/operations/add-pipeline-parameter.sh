#!/bin/bash
# add-pipeline-parameter.sh
# Purpose: Execute add-pipeline-parameter operation (add parameter to .parameters array)
# Inputs: REPO_NAME, WORK_DIR, PARAM_NAME, TARGET_FILE_PATH, COUNTER_FILE, TEMP_FILE (env vars)
# Exit: 0 = success, 1 = skip (logged)

set -e

# Pre-check: Does parameter already exist?
PARAM_NAME="${PARAM_NAME}"
EXISTING_PARAM=$(yq eval ".parameters[] | select(.name == \"${PARAM_NAME}\") | .name" "${TEMP_FILE}" 2>&1 || echo "")

if [ "${EXISTING_PARAM}" == "${PARAM_NAME}" ]; then
  echo "##[warning]Parameter ${PARAM_NAME} already exists in ${TARGET_FILE_PATH}. Skipping..."
  read TOTAL_SUCCESS TOTAL_FAIL TOTAL_SKIP < "$COUNTER_FILE"
  TOTAL_SKIP=$((TOTAL_SKIP + 1))
  echo "$TOTAL_SUCCESS $TOTAL_FAIL $TOTAL_SKIP" > "$COUNTER_FILE"
  jq --arg repo "${REPO_NAME}" --arg status "skipped" --arg reason "Parameter already exists" \
    '. += [{repo: $repo, status: $status, reason: $reason}]' \
    "${WORK_DIR}/results.json" > "${WORK_DIR}/results.tmp" && \
    mv "${WORK_DIR}/results.tmp" "${WORK_DIR}/results.json"
  exit 1
fi

# Pre-process: Remove trailing whitespace to prevent yq from corrupting multi-line literals
echo "##[debug]Removing trailing whitespace from ${TARGET_FILE_PATH}"
sed -i 's/[[:space:]]*$//' "${TEMP_FILE}"

# Execute: Add parameter
echo "##[debug]Adding parameter to ${TARGET_FILE_PATH}"
yq eval -i ".parameters += [load(\"${WORK_DIR}/param_to_add.yml\")]" "${TEMP_FILE}"

# Execute: Auto-sync extends section
EXTENDS_CHECK=$(yq eval '.extends.parameters' "${TEMP_FILE}" 2>&1 || echo "null")
if [ "${EXTENDS_CHECK}" != "null" ]; then
  echo "##[debug]Syncing extends section"
  PARAM_REF=$(printf '\044{{parameters.%s}}' "${PARAM_NAME}")
  yq eval -i ".extends.parameters.${PARAM_NAME} = \"${PARAM_REF}\"" "${TEMP_FILE}"
fi

# Post-process: Preserve blank lines and limit consecutive blanks to max 1 (compressed AWK)
echo "##[debug]Preserving blank lines and limiting consecutive blanks"
awk 'BEGIN{p=0;f=1;b=0;l=""}/^$/{b++;if(b<=1)print;next}{b=0}/^parameters:/{p=1;f=1;if(l!="")print "";print;l=$0;next}/^[a-z][a-zA-Z]*:/ && !/^  /{p=0;if(l!="")print "";print;l=$0;next}p && /^  - name:/{if(f)f=0;else print "";print;l=$0;next}{print;l=$0}' "${TEMP_FILE}" > "${TEMP_FILE}.tmp"
mv "${TEMP_FILE}.tmp" "${TEMP_FILE}"

exit 0
