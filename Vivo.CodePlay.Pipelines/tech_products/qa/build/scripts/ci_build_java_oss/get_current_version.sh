#!/bin/bash

# Execute the command stored in DOCKER_CMD_EXTRACT_POM_XML_VERSION and assign its output to currentVersion
currentVersion=$(eval "${DOCKER_CMD_EXTRACT_POM_XML_VERSION}")

echo "##[debug] Source CURRENT_VERSION: '$currentVersion'"
echo "##vso[task.setvariable variable=CURRENT_VERSION;]$currentVersion"
incrementVersion=$(echo $currentVersion | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
if [[ -n "$incrementVersion" ]]; then
  echo "##vso[task.setvariable variable=INCREMENT_VERSION;]$incrementVersion"
else
  echo "##[error] Version in the pom.xml is not following semantic versioning."
  echo "##[error] Verify if the version contains the pattern: <major>.<minor>.<patch>; e.g: 0.0.1, 1.0.0-branch, 1.1.0-branch+hash, 0.0.1-SNAPSHOT;"
  exit 1
fi