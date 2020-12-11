#!/usr/bin/env bash
set -e

# validate node.conf exist
if [ ! -f ${CONFIG_FOLDER}/node.conf ]; then echo "node.conf inexistence"; exit 1; fi

# validate certs exist
if [ ! -f ${CERTIFICATES_FOLDER}/nodekeystore.jks ]; then echo "nodekeystore.jks inexistence"; exit 1; fi
if [ ! -f ${CERTIFICATES_FOLDER}/sslkeystore.jks ]; then echo "sslkeystore.jks inexistence"; exit 1; fi
if [ ! -f ${CERTIFICATES_FOLDER}/truststore.jks ]; then echo "truststore.jks inexistence"; exit 1; fi


: ${JVM_ARGS='-XX:+UseG1GC'}

JVM_ARGS="-XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap "${JVM_ARGS}

# base-directory and config-file cannot be specified together in Corda 3.3, removing base-directory param until Corda 4 upgrade
java -Djava.security.egd=file:/dev/./urandom -Dcapsule.jvm.args="${JVM_ARGS}" -jar /opt/corda/bin/corda.jar --config-file ${CONFIG_FOLDER}/node.conf ${CORDA_ARGS}
