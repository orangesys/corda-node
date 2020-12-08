#!/usr/bin/env bash
#
#   Copyright 2018, Cordite Foundation.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.
#
# runs corda.jar --initial-registration
set -e
if [ ! -f ${CONFIG_FOLDER}/node.conf ]; then
    echo "/etc/corda/node.conf not found, creating using cordite-config-generator"
    cordite-config-generator
else
    echo "/etc/corda/node.conf exists:"
    cat ${CONFIG_FOLDER}/node.conf
fi

# Persist a copy of node.conf 
cp ${CONFIG_FOLDER}/node.conf ${CERTIFICATES_FOLDER}/registration-node.conf

TRUST_STORE_NAME=${TRUST_STORE_NAME:-truststore.jks}
NETWORK_TRUST_PASSWORD=${NETWORK_TRUST_PASSWORD:-trustpass}

if [[ ! -f ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} ]]; then
    echo "Network Trust Root file not found at ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME}"
    exit 1
fi

# List certs in truststore
echo "Network Trust Root file found at ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME}"
keytool -list -keystore ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} -storepass ${NETWORK_TRUST_PASSWORD}

echo "Attempting to register with doorman using ${TRUST_STORE_NAME}"
java -Djava.security.egd=file:/dev/./urandom -Dcapsule.jvm.args="${JVM_ARGS}" -jar /opt/corda/bin/corda.jar \
        --initial-registration \
        --config-file ${CONFIG_FOLDER}/node.conf \
        --network-root-truststore-password=${NETWORK_TRUST_PASSWORD} \
        --network-root-truststore=${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} \
        ${CORDA_ARGS}
echo "Succesfully registered with doorman using ${TRUST_STORE_NAME}"