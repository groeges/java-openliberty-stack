#!/bin/bash

echo "ODO_STACK_DIR='$ODO_STACK_DIR'"
echo "CHE_PROJECTS_ROOT='$CHE_PROJECTS_ROOT'"

if [ $UID -eq 0 ]; then
  
  groupadd --gid 1000 java_group
  useradd --uid 1000 --gid java_group --shell /bin/bash --create-home java_user
  mkdir -p /mvn/repository
  chown -R java_user:java_group /mvn
  mkdir -p /opt/ol
  chown -R java_user:java_group /opt
  chown -R java_user:java_group ${ODO_STACK_DIR}/project

  exec su "java_user" "$0" -- "$@"
  # nothing will be executed beyond that line,
  # because exec replaces running process with the new one
fi

${ODO_STACK_DIR}/project/util/check_version build

cd ${ODO_STACK_DIR}/project

mkdir -p /mvn/repository
mvn -B -Dmaven.repo.local=/mvn/repository -N io.takari:maven:wrapper -Dmaven=$(mvn help:evaluate -Dexpression=maven.version -q -DforceStdout)
mvn -B -Pstack-image-package -Dmaven.repo.local=/mvn/repository liberty:install-server install dependency:go-offline
chmod -R 777 /opt/ol 

cd ${CHE_PROJECTS_ROOT}