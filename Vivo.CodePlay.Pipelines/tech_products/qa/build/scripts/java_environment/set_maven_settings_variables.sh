#!/bin/bash

# if [[ -f $(settings.secureFilePath) ]]; then
#   echo "##vso[task.setvariable variable=MAVEN_SETTINGS_LOCATION;isreadonly=true;isOutput=true]$(settings.secureFilePath)"
#   echo "##[debug] Pipeline will use custom settings.xml file."
#   echo "##[debug] Pipeline will use the MAVEN_SETTINGS_LOCATION = $(settings.secureFilePath) ."
# # else
  default_maven=$(eval echo "${DEFAULT_MAVEN_SETTINGS}")
  echo "##[debug] Default settings: $default_maven"      
  echo "##vso[task.setvariable variable=MAVEN_SETTINGS_LOCATION;isreadonly=true;isOutput=true]$default_maven"
  echo "##[debug] Pipeline will use the default settings.xml file."
  echo "##[debug] Pipeline will use the MAVEN_SETTINGS_LOCATION = $default_maven ."
# fi
