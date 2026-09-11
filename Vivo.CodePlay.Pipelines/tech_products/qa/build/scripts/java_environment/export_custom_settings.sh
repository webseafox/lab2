#!/bin/bash

file_content=$(base64 -w 0 $(settings_variables.MAVEN_SETTINGS_LOCATION))
echo "##vso[task.setvariable variable=MAVEN_CUSTOM_SETTINGS_CONTENT;isreadonly=true;isOutput=true]$file_content"
