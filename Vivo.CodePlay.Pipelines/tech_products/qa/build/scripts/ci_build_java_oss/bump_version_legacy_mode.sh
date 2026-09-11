#!/bin/bash

echo "##[debug] Bumping version on legacy mode..."

# Função para rodar comandos Docker
run_docker() {
  docker run --rm \
    --log-driver none \
    --entrypoint xq \
    -v "$(pwd)/$1":"$(pwd)/$1" \
    -w "$(pwd)" vcr-group.nexus.telefonica.com.br/linuxserver/yq \
    -x "$2" \
    "$1" > pom_temp.xml
}

echo "##[debug] Build with version: ${NEW_VERSION}"

# Verificar se o arquivo pom.xml existe
if [ ! -f "pom.xml" ]; then
  echo "##[error] pom.xml file not found in $(pwd)"
  exit 1
fi

# Extrair módulos
modules=$(eval "${DOCKER_CMD_EXTRACT_POM_XML_MODULE}")
exit_code=$?
echo "##[debug] DOCKER_CMD_EXTRACT_POM_XML_MODULE exit code: $exit_code"
echo "##[debug] Modules extracted: $modules"

if [ $exit_code -ne 0 ] || [ -z "$modules" ]; then
  echo "##[warning] No modules found or is not an array, switching to string..."
  modules=$(eval "${DOCKER_CMD_EXTRACT_POM_XML_MODULES}")
  exit_code=$?
  echo "##[debug] DOCKER_CMD_EXTRACT_POM_XML_MODULES exit code: $exit_code"
  echo "##[debug] Modules extracted (string): $modules"
  if [ $exit_code -ne 0 ] || [ -z "$modules" ]; then
    echo "##[warning] No modules found, proceeding to pom parent..."
  fi
  dependenciesExpression=".project.dependencies.dependency"
else
  dependenciesExpression=".project.dependencies.dependency[]"
fi

echo "##[debug] Final modules: $modules"
echo "##[debug] Dependencies expression: $dependenciesExpression"

for module in $modules; do
  echo "##[debug] Bumping version for module: $module"
  if [ -f "$module/pom.xml" ]; then
    for dependency in $modules; do
      run_docker "$module/pom.xml" "(try \"$dependenciesExpression\" | select(.artifactId==\"$dependency\")).version=\"$NEW_VERSION\""
      if [ -f "pom_temp.xml" ]; then
        mv pom_temp.xml "$(pwd)/$module/pom.xml"
      fi
    done
    run_docker "$module/pom.xml" "(try .project.parent | select(.artifactId==\"${ARTIFACT_ID}\")).version=\"$NEW_VERSION\""
    mv pom_temp.xml "$(pwd)/$module/pom.xml"
    run_docker "$module/pom.xml" ".project.version=\"$NEW_VERSION\""
    mv pom_temp.xml "$(pwd)/$module/pom.xml"
    echo "##[group] /$module/pom.xml"
    cat "$(pwd)/$module/pom.xml"
    echo "##[endgroup]"
  else
    echo "##[warning] No pom.xml file found for module: $module"
  fi
done

echo "##[debug] Bumping version for pom parent"
run_docker "pom.xml" ".project.version=\"$NEW_VERSION\""
mv pom_temp.xml "$(pwd)/pom.xml"
echo "##[group] pom.xml"
cat "$(pwd)/pom.xml"
echo "##[endgroup]"
