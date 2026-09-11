#!/bin/bash
echo "Container image name: ${CONTAINER_IMAGE}"

# O system.debug da pipeline tambem habilita o modo debug do Maven.
if [ "${SYSTEM_DEBUG,,}" = "true" ]; then
    MAVEN_DEBUG="true"
fi

# Mascara a senha do ALM no log caso o variable group "alm" nao a marque como
# secret. Sem isso ela apareceria no despejo de ambiente do Maven em modo debug.
if [ -n "${ALM_PASSWORD}" ] && [ ${#ALM_PASSWORD} -ge 4 ]; then
    echo "##vso[task.setsecret]${ALM_PASSWORD}"
fi

# ---------------------------------------------------------------------------
# Variaveis extras (parametro extra_env do template)
# ---------------------------------------------------------------------------
# Chegam neste step com o prefixo EXTRA_VAR_ e sao repassadas ao container sem
# o prefixo. Usamos "-e NOME" (sem valor): o Docker herda o valor do ambiente
# deste processo, portanto nenhum secret e escrito em disco nem aparece na
# linha de comando do "docker run" (que e visivel via ps).
#
# Cada valor e registrado com ##vso[task.setsecret] para que o agente o mascare
# no log da pipeline dali em diante - inclusive na saida transmitida pelo
# "docker logs -f" do container.
# ---------------------------------------------------------------------------

EXTRA_ENV_FLAGS=""
EXTRA_ENV_COUNT=0

for var_name in $(compgen -v | grep '^EXTRA_VAR_'); do
    short_name="${var_name#EXTRA_VAR_}"
    var_value="${!var_name}"

    # Chave invalida como nome de variavel de ambiente quebraria o export.
    case "${short_name}" in
        ''|*[!A-Za-z0-9_]*|[0-9]*)
            echo "##vso[task.logissue type=warning]extra_env: a chave '${short_name}' nao e um nome valido de variavel de ambiente (use A-Z, 0-9 e _, sem iniciar com digito) e sera ignorada."
            continue
            ;;
    esac

    # Macro nao resolvida: quando a variavel nao existe na pipeline consumidora
    # o agente nao expande $(NOME) e o literal chega ate aqui.
    if [ "${var_value:0:2}" = '$(' ]; then
        echo "##vso[task.logissue type=warning]extra_env: a variavel '${short_name}' nao foi resolvida. Verifique se ela esta declarada na pipeline e, caso venha de um variable group, se o grupo esta vinculado e autorizado para esta pipeline."
        continue
    fi

    # Valor vazio e repassado assim mesmo, preservando o comportamento anterior
    # (o --env-file tambem escrevia "NOME=" para variaveis vazias). O warning
    # existe apenas para tornar o caso visivel no log.
    if [ -z "${var_value}" ]; then
        echo "##vso[task.logissue type=warning]extra_env: a variavel '${short_name}' chegou vazia."
    fi

    # Valores muito curtos nao sao mascarados para nao poluir o log inteiro.
    if [ ${#var_value} -ge 4 ]; then
        echo "##vso[task.setsecret]${var_value}"
    fi

    export "${short_name}=${var_value}"
    EXTRA_ENV_FLAGS="${EXTRA_ENV_FLAGS} -e ${short_name}"
    EXTRA_ENV_COUNT=$((EXTRA_ENV_COUNT + 1))
done

echo "##[section]extra_env: ${EXTRA_ENV_COUNT} variavel(is) repassada(s) ao container (valores mascarados no log)."

docker_id=$(
    docker run -d --init --rm \
        --user="root:root" \
        --network host \
        --shm-size=2g \
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
        -e MAVEN_DEBUG="${MAVEN_DEBUG}" \
        ${EXTRA_ENV_FLAGS} \
        -v "/proc/meminfo:/agent/meminfo" \
        -v "$(pwd):${DOCKER_WORKDIR}" \
        -v "$(pwd)/../:/build" \
        -v "${HOME}/.m2/repository:/.m2/repository" \
        -v "${SCRIPTS_FOLDER}:/scripts" \
        -v "${AGENT_TMP_DIRECTORY}:/logs" \
        -w "${DOCKER_WORKDIR}" \
        --entrypoint /scripts/exec_tests.sh \
        "${CONTAINER_IMAGE}"
)

trap 'docker stop -t 120 $docker_id;' SIGTERM SIGINT
echo "Container ID: $docker_id"
docker logs -f $docker_id &
wait
