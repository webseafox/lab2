FROM vcr-docker.nexus.telefonica.com.br/corp/java/11/builder/corp-jdk11

ENV JAVA_OPTS_MEMORY_MIN="128m"
ENV JAVA_OPTS_MEMORY_MAX="256m"

ENV JAVA_OPTS_METASPACE_MIN="64m"
ENV JAVA_OPTS_METASPACE_MAX="64m"

ENV JAVA_OPTS_MEMORY='-Xms$JAVA_OPTS_MEMORY_MIN -Xmx$JAVA_OPTS_MEMORY_MAX -XX:MetaspaceSize=$JAVA_OPTS_METASPACE_MIN -XX:MaxMetaspaceSize=$JAVA_OPTS_METASPACE_MAX'

ENV JAVA_OPTS="$JAVA_OPTS_MEMORY  -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:+ShowCodeDetailsInExceptionMessages $JAVA_OPTS_CONFIG -Djava.security.egd=file:/dev/./urandom"