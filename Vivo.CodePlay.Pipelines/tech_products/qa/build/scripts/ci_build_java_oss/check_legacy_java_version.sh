#!/bin/bash

javaVersion=$(eval "${DOCKER_CMD_EXTRACT_POM_XML_JAVA_VERSION}")
if [ $? -gt 0 ]; then
  echo "##[warning] No java version found..."
else
  if [[ $javaVersion+0 < 1.8 ]]; then
    echo "##[debug] Java version: $javaVersion"
    echo "##[debug] Java version is less than 1.8 (JDK8), bump version as legacy mode."
    # Necessary to duplicate variable due to Azure DevOps issues.
    # In task-condition, output variable do not work within the same stage.
    echo "##vso[task.setvariable variable=LEGACY_MODE]true"
    echo "##vso[task.setvariable variable=LEGACY_MODE;isOutput=true]true"
  else
    echo "##[debug] Java version: $javaVersion"
    echo "##[debug] Java version is greater or equal than 1.8 (JDK8), bump version with mvn versions:set."
  fi
fi