#!/bin/bash

#BUILDER_IMAGE_NAME="builder/java"

# Construir a imagem Docker
#docker build -t $BUILDER_IMAGE_NAME -f .azuredevops/builder.Dockerfile .

# Função para executar comandos dentro do container Docker
run_docker() {
  docker run --rm \
    --user="$(eval echo ${DOCKER_CMD_USERNAME}):$(eval echo ${DOCKER_CMD_GROUP})" \
    --network host \
    --log-driver none \
    -e JAVA_OPTS_MEMORY_MAX="${DEFAULT_MAX_MEMORY_BUILD}" \
    -e TZ="America/Sao_Paulo" \
    -e SYSTEM_ACCESSTOKEN="${SYSTEM_ACCESSTOKEN}" \
    -e NEXUS_DEPS_USR="${NEXUS_DEPS_USR}" \
    -e NEXUS_DEPS_PSW="${NEXUS_DEPS_PSW}" \
    -e JAVA_OPTS_MEMORY_MIN="128m" \
    -e JAVA_OPTS_MEMORY_MAX="256m" \
    -e JAVA_OPTS_METASPACE_MIN="64m" \
    -e JAVA_OPTS_METASPACE_MAX="64m" \
    -e JAVA_OPTS_MEMORY="-Xms128m -Xmx256m -XX:MetaspaceSize=64m -XX:MaxMetaspaceSize=64m" \
    -e JAVA_OPTS='${JAVA_OPTS_MEMORY}  -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:+ShowCodeDetailsInExceptionMessages $JAVA_OPTS_CONFIG -Djava.security.egd=file:/dev/./urandom' \
    -v $(pwd):/app \
    -v ${HOME}/.m2:/.m2/ \
    -v /config \
    -w ${DOCKER_WORKDIR} \
    acrsharedservices01.azurecr.io/corp/java/17/builder/corp-jdk17 sh -c "$1"
}

# Verificar se a versão deve ser incrementada
if [[ ("${BUMP_VERSION_ENABLED}" == 'true') && !( "${LEGACY_MODE}" == 'true') ]]; then
  # Executar o comando de definição de versão do Maven dentro do container Docker
  run_docker "mvn -e -X -U $(eval echo ${MAVEN_OPTS}) versions:set -DnewVersion=${NEW_VERSION} -s /app/settings.xml -Dmaven.repo.local=/.m2/repository"
fi

# Exibir informações de depuração
echo "##[debug] Build with version: ${NEW_VERSION}"
echo "##[debug] JAVA_CMD_BUILD: ${JAVA_CMD_BUILD}"
echo "##[debug] JAVA_CMD_BUILD_TEST: ${JAVA_CMD_BUILD_TEST}"
echo "##[debug] JAVA_CMD_OPTIONAL: ${JAVA_CMD_OPTIONAL}"

# Executar o comando de build do Maven dentro do container Docker
run_docker "$(eval echo ${JAVA_CMD_BUILD}) $(eval echo ${JAVA_CMD_BUILD_TEST}) $(eval echo ${JAVA_CMD_OPTIONAL}) -Dmaven.test.failure.ignore=false -s /app/settings.xml -Dmaven.repo.local=/.m2/repository"
