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

# Creates Cordite config
set -e

echo "Creating Cordite config"

# NETWORK
# CORDITE_COMPATIBILITY_ZONE_URL deprecated. Used to set NETWORKMAP_URL and DOORMAN_URL if set. Defaults to Cordite Test
CORDITE_COMPATIBILITY_ZONE_URL=${CORDITE_COMPATIBILITY_ZONE_URL:-https://nms-test.cordite.foundation}
NETWORK_MAP_URL=${NETWORK_MAP_URL:-$CORDITE_COMPATIBILITY_ZONE_URL}
DOORMAN_URL=${DOORMAN_URL:-$NETWORK_MAP_URL}
CORDITE_NMS=${CORDITE_NMS:-false}

TRUST_STORE_NAME="truststore.jks"
NETWORK_TRUST_PASSWORD="trustpass"

# CORDITE NMS
if [[ "${CORDITE_NMS}" == "true" ]]; then
  DOORMAN_URL=${NETWORK_MAP_URL}
  unset TLS_CERT_CRL_DIST_POINT
  unset TLS_CERT_CERL_ISSUER
  CORDITE_DEV_MODE=false
fi

# CORDA NETWORK UAT
if [ "${NETWORK_MAP_URL}" == "https://uat-sub1-netmap-01.uat.corda.network/SUB1CEP8-32UX-6ZXK-9C82-1FLR6268D75Z" ]; then
  echo "using corda uat net map"
  DOORMAN_URL="https://doorman.uat.corda.network/3FCF6CEB-20BD-4B4F-9C72-1EFE7689D85B"
  TLS_CERT_CRL_DIST_POINT="http://crl.uat.corda.network/nodetls.crl"
  TLS_CERT_CERL_ISSUER="CN=Corda TLS CRL Authority,OU=Corda UAT,O=R3 HoldCo LLC,L=New York,C=US"
  CORDITE_DEV_MODE=false
fi

# CORDA NETWORK (MAINNET)     
if [ "${NETWORK_MAP_URL}" == "https://prod-sub0-netmap-01.corda.network/SUB0CHKQ-8GCO-HS3S-KLZC-BINKKAGIMDRS" ]; then
  echo "using corda prod net map"
  DOORMAN_URL="https://prod-doorman2-01.corda.network/ED5D077E-F970-428B-8091-F7FCBDA06F8C"
  TLS_CERT_CRL_DIST_POINT="http://crl.corda.network/nodetls.crl"
  TLS_CERT_CERL_ISSUER="CN=Corda TLS CRL Authority,OU=Corda Network,O=R3 HoldCo LLC,L=New York,C=US"
  CORDITE_DEV_MODE=false
fi

# Corda official environment variables. If set will be used instead of defaults
MY_LEGAL_NAME=${MY_LEGAL_NAME:-O=Cordite-${RANDOM}, OU=Cordite, L=London, C=GB}
MY_PUBLIC_ADDRESS=${MY_PUBLIC_ADDRESS:-localhost}
# MY_P2P_PORT=10200 <- default set in corda dockerfile
# MY_RPC_PORT=10201 <- default set in corda dockerfile
echo "MY_P2P_PORT: ${MY_P2P_PORT}"
echo "MY_RPC_PORT: ${MY_RPC_PORT}"
MY_ADMIN_PORT=${MY_ADMIN_PORT:-$(expr ${MY_RPC_PORT} + 1)}

TRUST_STORE_NAME=${TRUST_STORE_NAME:-truststore.jks}
NETWORK_TRUST_PASSWORD=${NETWORK_TRUST_PASSWORD:-trustpass}
MY_EMAIL_ADDRESS=${MY_EMAIL_ADDRESS:-noreply@cordite.foundation}
# RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1) <- not used
# MY_RPC_PORT=10201 <- default set in corda dockerfile.
# MY_RPC_ADMIN_PORT=10202 <- default set in corda dockerfile.
# TLS_CERT_CRL_DIST_POINT=${TLS_CERT_CRL_DIST_POINT:-null}
# TLS_CERT_CERL_ISSUER=${TLS_CERT_CERL_ISSUER:-null}

# Cordite environment variables. Will override Corda official environment variables if passed.
CORDITE_LEGAL_NAME=${CORDITE_LEGAL_NAME:-$MY_LEGAL_NAME}
CORDITE_P2P_ADDRESS=${CORDITE_P2P_ADDRESS:-$MY_PUBLIC_ADDRESS:$MY_P2P_PORT}
CORDITE_KEY_STORE_PASSWORD=${CORDITE_KEY_STORE_PASSWORD:-cordacadevpass}
CORDITE_TRUST_STORE_PASSWORD=${CORDITE_TRUST_STORE_PASSWORD:-$NETWORK_TRUST_PASSWORD}
CORDITE_DB_USER=${CORDITE_DB_USER:-sa}
CORDITE_DB_PASS=${CORDITE_DB_PASS:-dbpass}
CORDITE_DB_DRIVER=${CORDITE_DB_DRIVER:-org.h2.jdbcx.JdbcDataSource}
CORDITE_DB_DIR=${CORDITE_DB_DIR:-$PERSISTENCE_FOLDER}
CORDITE_DB_MAX_POOL_SIZE=${CORDITE_DB_MAX_POOL_SIZE:-10}
CORDITE_BRAID_PORT=${CORDITE_BRAID_PORT:-8080}
CORDITE_DEV_MODE=${CORDITE_DEV_MODE:-true}
CORDITE_DETECT_IP=${CORDITE_DETECT_IP:-false}
CORDITE_CACHE_NODEINFO=${CORDITE_CACHE_NODEINFO:-false}
CORDITE_LOG_MODE=${CORDITE_LOG_MODE:-normal}
CORDITE_JVM_MX=${CORDITE_JVM_MX:-1536m}
CORDITE_JVM_MS=${CORDITE_JVM_MS:-512m}
CORDITE_H2_PORT=${CORDITE_H2_PORT:-9090}

#set CORDITE_DB_URL
h2_db_url="jdbc:h2:file:${CORDITE_DB_DIR};DB_CLOSE_ON_EXIT=FALSE;LOCK_TIMEOUT=10000;WRITE_DELAY=100;AUTO_SERVER_PORT=${CORDITE_H2_PORT}"
CORDITE_DB_URL=${CORDITE_DB_URL:-$h2_db_url}

# CORDITE_LOG_CONFIG_FILE:
if [ "${CORDITE_LOG_MODE}" == "json" ]; then
    CORDITE_LOG_CONFIG_FILE=cordite-log4j2-json.xml
else
    CORDITE_LOG_CONFIG_FILE=cordite-log4j2.xml
fi

# Create node.conf and default if variables not set
echo
echo
printenv
echo
echo
basedir=\"\${baseDirectory}\"
braidhost=${CORDITE_LEGAL_NAME#*O=} && braidhost=${braidhost%%,*} && braidhost=$(echo $braidhost | sed 's/ //g')
cat > ${CONFIG_FOLDER}/node.conf <<EOL
myLegalName : "${CORDITE_LEGAL_NAME}"
p2pAddress : "${CORDITE_P2P_ADDRESS}"

networkServices {
    doormanURL : "${DOORMAN_URL}"
    networkMapURL : "${NETWORK_MAP_URL}"
}



dataSourceProperties {
    dataSourceClassName="${CORDITE_DB_DRIVER}"
    dataSource {
        url="${CORDITE_DB_URL}"
        user="${CORDITE_DB_USER}"
        password="${CORDITE_DB_PASS}"
    }
    maximumPoolSize="${CORDITE_DB_MAX_POOL_SIZE}"
}

keyStorePassword : "${CORDITE_KEY_STORE_PASSWORD}"
trustStorePassword : "${CORDITE_TRUST_STORE_PASSWORD}"
detectPublicIp : ${CORDITE_DETECT_IP}
devMode : ${CORDITE_DEV_MODE}
custom {
    jvmArgs=[
        "-Dbraid.${braidhost}.port=${CORDITE_BRAID_PORT}",
        "-Xms${CORDITE_JVM_MS}", "-Xmx${CORDITE_JVM_MX}", 
        "-Dlog4j.configurationFile=${CORDITE_LOG_CONFIG_FILE}",
        "-Dlog4j2.debug"
    ]
}
rpcSettings {
    address="0.0.0.0:${MY_RPC_PORT}"
    adminAddress="0.0.0.0:${MY_ADMIN_PORT}"
}

jarDirs=[
    "/opt/corda/libs"
]
emailAddress : "${MY_EMAIL_ADDRESS}"
EOL

if [ ! -z "${TLS_CERT_CRL_DIST_POINT}" ]; then
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
tlsCertCrlDistPoint="${TLS_CERT_CRL_DIST_POINT}"
tlsCertCrlIssuer="${TLS_CERT_CERL_ISSUER}"
EOL
fi

# Configure notaries
# for the moment we're dealing with two systems - later we can do this in a slightly different way
if [ "$CORDITE_NOTARY" == "true" ] || [ "$CORDITE_NOTARY" == "validating" ] || [ "$CORDITE_NOTARY" == "non-validating" ] ; then
    NOTARY_VAL=false
    if [ "$CORDITE_NOTARY" == "true" ] || [ "$CORDITE_NOTARY" == "validating" ]; then
    NOTARY_VAL=true
    fi
    echo "CORDITE_NOTARY set to ${CORDITE_NOTARY}. Configuring node to be a notary with validating ${NOTARY_VAL}"
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
notary {
    validating=${NOTARY_VAL}
}
EOL
fi

if [ "${CORDITE_DEV_MODE}" == "true" ]; then
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
devModeOptions {
    allowCompatibilityZone: true
}
EOL
else
# WE MUST COME BACK AND REMOVE THIS WHEN WE START SIGNING
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
cordappSignerKeyFingerprintBlacklist = []
EOL
fi

# do we want to turn on jolokia for monitoring?
if [ ! -z "$CORDITE_EXPORT_JMX" ]; then
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
exportJMXTo: "${CORDITE_EXPORT_JMX}"
EOL
fi

# do we want to enable ssh and rpc use
if [ ! -z "$CORDITE_SSH_PORT" ] || [ ! -z "$CORDITE_RPC_USERNAME" ] || [ ! -z "$CORDITE_RPC_PASSWORD" ] || [ ! -z "$CORDITE_RPC_PERMISSIONS" ] ; then
cat >> ${CONFIG_FOLDER}/node.conf <<EOL
sshd {
    port = ${CORDITE_SSH_PORT}
}
rpcUsers = [
    { username=${CORDITE_RPC_USERNAME}, password=${CORDITE_RPC_PASSWORD}, permissions=[ ${CORDITE_RPC_PERMISSIONS} ] }
]
EOL
fi

echo "${CONFIG_FOLDER}/node.conf created:"
cat ${CONFIG_FOLDER}/node.conf

if [ ! -z "$CORDITE_METERING_CONFIG" ] ; then
   echo "CORDITE_METERING_CONFIG set to ${CORDITE_METERING_CONFIG}. Creating metering-service-config.json"
   echo $CORDITE_METERING_CONFIG > metering-service-config.json
fi

if [ ! -z "$CORDITE_FEE_DISPERSAL_CONFIG" ] ; then
   echo "CORDITE_FEE_DISPERSAL_CONFIG set to ${CORDITE_FEE_DISPERSAL_CONFIG}. Creating fee-dispersal-service-config.json"
   echo $CORDITE_FEE_DISPERSAL_CONFIG > fee-dispersal-service-config.json
fi
