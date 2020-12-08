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

# NETWORK
# CORDITE_COMPATIBILITY_ZONE_URL deprecated. Used to set NETWORKMAP_URL and DOORMAN_URL if set. Defaults to Cordite Test
CORDITE_COMPATIBILITY_ZONE_URL=${CORDITE_COMPATIBILITY_ZONE_URL:-https://nms-test.cordite.foundation}
NETWORK_MAP_URL=${NETWORK_MAP_URL:-$CORDITE_COMPATIBILITY_ZONE_URL}
DOORMAN_URL=${DOORMAN_URL:-$NETWORK_MAP_URL}
CORDITE_NMS=${CORDITE_NMS:-false}

TRUST_STORE_NAME="truststore.jks"

# CORDITE NMS
if [[ "${CORDITE_NMS}" == "true" ]]; then
  echo "we are using a cordite NMS - downloading the truststore from ${NETWORK_MAP_URL}"
  DOORMAN_URL=${NETWORK_MAP_URL}
  curl ${NETWORK_MAP_URL}/network-map/truststore --output ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} --silent
fi

# CORDA NETWORK UAT
if [ "${NETWORK_MAP_URL}" == "https://uat-sub1-netmap-01.uat.corda.network/SUB1CEP8-32UX-6ZXK-9C82-1FLR6268D75Z" ]; then
  echo "using corda uat net map"
  if [ ! -f ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} ]; then 
    echo "downloading truststore"
    curl https://cordite.foundation/public-root-truststores/corda-uat-network-root-truststore.jks --output ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME}
  else 
    echo "truststore exists - not re-downloading"
  fi
fi

# CORDA NETWORK (MAINNET)     
if [ "${NETWORK_MAP_URL}" == "https://prod-sub0-netmap-01.corda.network/SUB0CHKQ-8GCO-HS3S-KLZC-BINKKAGIMDRS" ]; then
  echo "using corda prod net map"
  if [ ! -f ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME} ]; then 
    echo "downloading truststore"
    curl https://cordite.foundation/public-root-truststores/corda-prod-network-root-truststore.jks --output ${CERTIFICATES_FOLDER}/${TRUST_STORE_NAME}
  else 
    echo "truststore exists - not re-downloading"
  fi
fi