#!/usr/bin/bash
# author:  rkiessli, TIBCO Software (SC_DACH)
# changed: 2022-06-29

# Get APIM Cluster Parameters
if [ -n "${1}" ]; then
  ADMAPI_CONFIG="${1}"
else
  ADMAPI_CONFIG="./apim-v3-config.sh"
fi

if [ ! -r ${ADMAPI_CONFIG} ]; then
  echo "[ERROR] configuration file ${ADMAPI_CONFIG} not found or not accessible."
  exit 1
fi
source ${ADMAPI_CONFIG}


# Aquire a TIBCO APIM LE API v3 access token
if [ ! -x ./apim-v3-authenticate.sh ]; then
  echo "[ERROR] authentication procedure file ./apim-v3-authenticate.sh not found."
  exit 1
fi
source ./apim-v3-authenticate.sh


# retrieve all available roles
http_response=$(\
curl --silent --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/roles" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null \
)
if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
else
    echo "Server returned:"
    jq -r "." ${TMP_JSON_FILE}
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1
fi

