#!/bin/bash

echo "##[group] Variables to DOWNLOAD dependencies from NEXUS"
echo "##[debug] NEXUS-DEPS-USR: ${NEXUS-DEPS-USR}. Use as >> NEXUS_DEPS_USR."
echo "##vso[task.setvariable variable=NEXUS_DEPS_USR;isOutput=true;isSecret=true]${NEXUS-DEPS-USR}"
echo "##[debug] NEXUS-DEPS-PSW: ${NEXUS-DEPS-PSW}. Use as >> NEXUS_DEPS_PSW"          
echo "##vso[task.setvariable variable=NEXUS_DEPS_PSW;isOutput=true;isSecret=true]${NEXUS-DEPS-PSW}"
echo "##[endgroup]"

echo "##[group] Variables to PUBLISH artifacts to NEXUS"          
echo "##[debug] NEXUS-DEFAULT-USR: ${NEXUS-DEFAULT-USR}. Use as >> NEXUS_DEFAULT_USR"          
echo "##vso[task.setvariable variable=NEXUS_DEFAULT_USR;isOutput=true;isSecret=true]${NEXUS-DEFAULT-USR}"
echo "##[debug] NEXUS-DEFAULT-PSW: ${NEXUS-DEFAULT-PSW}. Use as >> NEXUS_DEFAULT_PSW"          
echo "##vso[task.setvariable variable=NEXUS_DEFAULT_PSW;isOutput=true;isSecret=true]${NEXUS-DEFAULT-PSW}"
echo "##[endgroup]"

echo "##[debug] To open and check the information above, click the arrows on the left."
# echo "##[debug] Secure File Path: $(settings.secureFilePath)"