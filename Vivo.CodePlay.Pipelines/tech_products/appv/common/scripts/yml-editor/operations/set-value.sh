#!/bin/bash
# set-value.sh
# Purpose: Execute set-value operation (set value at YAML path)
# Inputs: REPO_NAME, WORK_DIR, TARGET_PROP, TARGET_FILE_PATH, COUNTER_FILE, TEMP_FILE (env vars)
# Exit: 0 = success, 1 = skip (logged)

set -e

# Pre-check: Does target path exist?
PATH_CHECK=$(yq eval "${TARGET_PROP}" "${TEMP_FILE}" 2>&1)
if [ "$PATH_CHECK" == "null" ] || echo "$PATH_CHECK" | grep -q "Error"; then
  echo "##[warning]Path ${TARGET_PROP} does not exist. Skipping..."
  read TOTAL_SUCCESS TOTAL_FAIL TOTAL_SKIP < "$COUNTER_FILE"
  TOTAL_SKIP=$((TOTAL_SKIP + 1))
  echo "$TOTAL_SUCCESS $TOTAL_FAIL $TOTAL_SKIP" > "$COUNTER_FILE"
  jq --arg repo "${REPO_NAME}" --arg status "skipped" --arg reason "Path does not exist" \
    '. += [{repo: $repo, status: $status, reason: $reason}]' \
    "${WORK_DIR}/results.json" > "${WORK_DIR}/results.tmp" && \
    mv "${WORK_DIR}/results.tmp" "${WORK_DIR}/results.json"
  exit 1
fi

# Pre-process: Remove trailing whitespace to prevent yq from corrupting multi-line literals
echo "##[debug]Removing trailing whitespace from ${TARGET_FILE_PATH}"
sed -i 's/[[:space:]]*$//' "${TEMP_FILE}"

# Execute: Set value at target property
echo "##[debug]Setting ${TARGET_PROP} in ${TARGET_FILE_PATH}"
VALUE_JSON=$(cat "${WORK_DIR}/value_to_set.json")

# Determine if value is scalar or complex
if echo "$VALUE_JSON" | jq -e 'type | . == "object" or . == "array"' > /dev/null 2>&1; then
  echo "$VALUE_JSON" | yq eval -P '.' > "${WORK_DIR}/value_to_set.yml"
  yq eval -i "${TARGET_PROP} = load(\"${WORK_DIR}/value_to_set.yml\")" "${TEMP_FILE}"
else
  yq eval -i "${TARGET_PROP} = ${VALUE_JSON}" "${TEMP_FILE}"
fi

# Post-process: Restore blank lines and limit consecutive blanks to max 1 (compressed AWK)
echo "##[debug]Restoring blank line formatting and limiting consecutive blanks"
awk 'BEGIN{p=0;n=0;b=0}{n++}/^$/{b++;if(b<=1)print;next}{b=0}/^[a-z][a-zA-Z0-9]*:/ && !/^  /{if(p&&n>1)print "";print;p=1;next}{print;if(!/^  /)p=0}' "${TEMP_FILE}" > "${TEMP_FILE}.tmp"
mv "${TEMP_FILE}.tmp" "${TEMP_FILE}"

exit 0
