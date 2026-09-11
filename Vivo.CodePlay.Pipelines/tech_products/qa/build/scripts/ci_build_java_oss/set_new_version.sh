#!/bin/bash

echo "##[debug] Source CURRENT_VERSION: '${CURRENT_VERSION}'"
if [ "${BUILD_SOURCEBRANCHNAME}" == 'master' ]; then
  echo "##[debug] Source NEW_VERSION: '${INCREMENT_VERSION}'"
  echo "##vso[task.setvariable variable=NEW_VERSION;isOutput=true]${INCREMENT_VERSION}"
else
  newVersion="${INCREMENT_VERSION}.${BUILD_SOURCEBRANCHNAME}.${SHORT_HASH}"
  echo "##[debug] Source NEW_VERSION: $newVersion"
  echo "##vso[task.setvariable variable=NEW_VERSION;isOutput=true]$newVersion"
fi
echo "##[debug] Build with version: $newVersion"