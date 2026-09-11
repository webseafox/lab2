#!/bin/bash

# Execute the command stored in DOCKER_CMD_EXTRACT_ARTIFACT_ID and assign its output to artifactId
artifactId=$(eval "${DOCKER_CMD_EXTRACT_ARTIFACT_ID}")
echo "##[debug] Source ARTIFACT_ID: $artifactId"
echo "##vso[task.setvariable variable=ARTIFACT_ID;isOutput=true]$artifactId"

# Execute the command stored in DOCKER_CMD_EXTRACT_GROUP_ID and assign its output to groupId
groupId=$(eval "${DOCKER_CMD_EXTRACT_GROUP_ID}")
echo "##[debug] Source GROUP_ID: $groupId"
echo "##vso[task.setvariable variable=GROUP_ID;isOutput=true]$groupId"