#!/bin/bash

echo "$(pwd)"
echo "$(ls -lah)"
echo "##[debug] The project is multi-module?"
modules=$(eval "${DOCKER_CMD_EXTRACT_POM_XML_MODULES}")
if [ $? -gt 0 ]; then
  echo "##[warning] Project is not multi-module, continue..."
fi
lastModule=$(echo $modules | tr -d '[]' | awk -F ',' '{print $NF}' | tr -d '""')
if [[ -n $lastModule ]]; then
  echo "##[debug] Project is multi-module"
  echo "##[debug] Looking for ear..."
  artifact=$(find "${BUILD_ARTIFACTSTAGINGDIRECTORY}" -type f -name "*.ear" -print -quit)
  if [[ -z $artifact ]]; then
    echo "##[debug] No ear file found. Looking for war..."
    artifact=$(find "${BUILD_ARTIFACTSTAGINGDIRECTORY}" -type f -name "*.war" -print -quit)
    if [[ -z $artifact ]]; then
      echo "##[debug] No war file found. Getting the jar for last module on pom.xml."
      artifact=$(find "${BUILD_ARTIFACTSTAGINGDIRECTORY}" -type f -name "*$lastModule*.jar" -print -quit)
    fi
  fi
else
  targetDirectory=$(echo "${BUILD_ARTIFACTSTAGINGDIRECTORY}/target")
  echo "##[debug] Target Directory '$targetDirectory'"
  echo "$(ls -lah $targetDirectory)"
  artifact=$(echo $targetDirectory/$(ls "$targetDirectory" | grep -E "\.jar$|\.war$|\.ear$" | head -n 1))
fi
if [[ $artifact != *"${NEW_VERSION}"* ]]; then
  echo "##[error] The artifact was not generated with the correct name."
  echo "##[error] Possible causes may include:"
  echo "##[error] - A variable forcing the name in the pom.xml, e.g: <finalName> attribute inside the pom.xml"
  exit 1
fi
artifactName=$(basename $artifact | sed 's/\.[^.]*$//')
echo "##[debug] Artifact Name: $artifactName"
artifactFile=$(basename $artifact)
echo "##[debug] Artifact File: $artifactFile"
artifactPath=$(echo $artifact | sed "s|^${BUILD_ARTIFACTSTAGINGDIRECTORY}/||" | sed "s|$artifactFile||")
echo "##[debug] Artifact Path: $artifactPath"
echo "##vso[task.setvariable variable=ARTIFACT_PATH;isOutput=true]$artifactPath"
echo "##vso[task.setvariable variable=ARTIFACT_FILE;isOutput=true]$artifactFile"
echo "##vso[task.setvariable variable=ARTIFACT_NAME;isOutput=true]$artifactName"