#!/bin/bash
echo "Container image name: ${CONTAINER_IMAGE}"

docker_id=$(
    docker run -d --init --rm \
        --user="root:root" \
        --network host \
        --log-opt max-size=10m \
        --log-opt max-file=3 \
        --stop-timeout 120 \
        -e HTTPS_PROXY="${HTTPS_QA_PROXY}" \
        -e HTTP_PROXY="${HTTP_QA_PROXY}" \
        -e NO_PROXY="${NO_PROXY}" \
        -e JAVA_OPTS_MEMORY_MAX="${DEFAULT_MAX_MEMORY_BUILD}" \
        -e TZ="America/Sao_Paulo" \
        -e SYSTEM_ACCESSTOKEN="${SYSTEM_ACCESSTOKEN}" \
        -e NEXUS_DEPS_USR="${NEXUS_DEPS_USR}" \
        -e NEXUS_DEPS_PSW="${NEXUS_DEPS_PSW}" \
        -e ENVIRONMENT="${ENVIRONMENT}" \
        -e SCENARIOS="${SCENARIOS}" \
        -e OPTIONALS="${OPTIONALS}" \
        -e FRAMEWORK="${FRAMEWORK}" \
        -e PROJECT_ID="${PROJECT_ID}" \
        -e ALM_USER="${ALM_USER}" \
        -e ALM_PASSWORD="${ALM_PASSWORD}" \
        -e DOCKER_IMAGE="${DOCKER_IMAGE}" \
        -e ENABLE_COLLECT_METRIC="${ENABLE_COLLECT_METRIC}" \
        -v "/proc/meminfo:/agent/meminfo" \
        -e COMPONENT_ID="${COMPONENT_ID}" \
        -v "$(pwd):${DOCKER_WORKDIR}" \
        -v "$(pwd)/../:/build" \
        -v "${HOME}/.m2/repository:/.m2/repository" \
        -v "${SCRIPTS_FOLDER}:/scripts" \
        -v "${AGENT_TMP_DIRECTORY}:/logs" \
        -w "${DOCKER_WORKDIR}" \
        -v "${AGENT_TMP_DIRECTORY}:/tmp" \
        --entrypoint /scripts/test_execution.sh \
        "${CONTAINER_IMAGE}"
)

trap 'docker stop -t 120 $docker_id;' SIGTERM SIGINT
echo "Container ID: $docker_id"
docker logs -f $docker_id &
wait