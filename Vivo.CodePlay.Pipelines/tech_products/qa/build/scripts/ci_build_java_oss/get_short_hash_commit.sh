#!/bin/bash

fullBranchName=$(echo ${BUILD_SOURCEBRANCHNAME} | sed 's#refs/heads/##')
echo "##[debug] Full branch name: $fullBranchName"
lastCommitHash=$(echo ${BUILD_SOURCEVERSION} | head -c6)
echo "##vso[task.setvariable variable=SHORT_HASH]$lastCommitHash"
echo "##debug] Short hash: $lastCommitHash"