#!/bin/bash

echo "##[debug] Loading custom settings: ${MAVEN_CUSTOM_SETTINGS_CONTENT}"
echo "##[debug] Location: ${MAVEN_SETTINGS_LOCATION}"
base64 -d <<< "${MAVEN_CUSTOM_SETTINGS_CONTENT}" > ${MAVEN_SETTINGS_LOCATION}