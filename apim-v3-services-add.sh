#!/usr/bin/bash
# author:  rkiessli, TIBCO Software (SC_DACH)
# changed: 2022-06-29

# Parameters 1 is the APIM (Mashery) service as JSON file
if [[ -z "${1}" ]]; then
  echo "[WARN] No Mashery service specification file provided."
  exit 2
fi
API_SPECIFICATION_FILE="${1}"

# Get APIM Cluster Parameters <- don't use it here in favour of the spec file parameter
#if [ -n "${1}" ]; then
#  ADMAPI_CONFIG="${1}"
#else
  ADMAPI_CONFIG="./apim-v3-config.sh"
#fi

if [ ! -r ${ADMAPI_CONFIG} ]; then
  echo "[ERROR] configuration file ${ADMAPI_CONFIG} not found or not accessible."
  exit 1
fi
source ${ADMAPI_CONFIG}


# Acquire a TIBCO APIM LE API v3 access token
if [ ! -x ./apim-v3-authenticate.sh ]; then
  echo "[ERROR] authentication procedure file ./apim-v3-authenticate.sh not found."
  exit 1
fi
source ./apim-v3-authenticate.sh


# Push services into APIM
http_response=$(\
curl --silent --insecure \
--request POST \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/services" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--header "Content-Type: application/json" \
--data @${API_SPECIFICATION_FILE} \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null \
)
if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    cat ${TMP_JSON_FILE}
    exit 1
else
    echo "API Response:"
    jq -r "." ${TMP_JSON_FILE}
fi

