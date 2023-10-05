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
  echo "[ERROR] Configuration file ${ADMAPI_CONFIG} not found or not accessible."
  exit 1
fi
source ${ADMAPI_CONFIG}

ACCESSTOKEN_FILE="./.api_access_token"
# check for access token within cache file
if [[ -r ${ACCESSTOKEN_FILE} ]]; then
  echo "[INFO] Reading access token from file"
  source ${ACCESSTOKEN_FILE}
fi 

# if there is no token OR token lifetime - 10 sec contingency, go get a new one
if [[ -z "${ADMAPI_ACCESSTOKEN}" || ${ADMAPI_ACCESSTOKEN_EPOCH} < $(( $(date +%s) - 10 )) ]]; then

  echo "[INFO] Acquiring new API v3 access token for user ${ADMAPI_USERNAME}"

#  echo "\
#  curl --insecure --location --request POST \
#  --url \"https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/token\" \
#  --header \"Host: ${ADMAPI_DOMAIN}\" \
#  --user \"${ADMAPI_CREDENTIAL}\" \
#  --header \"Content-Type: application/x-www-form-urlencoded\" \
#  --data-urlencode \"grant_type=password\" \
#  --data-urlencode \"scope=${ADMAPI_AREA}\" \
#  --data-urlencode \"username=${ADMAPI_USERNAME}\" \
#  --data-urlencode \"password=${ADMAPI_PASSWORD}\""

  http_response=$(\
  curl --insecure --location --request POST \
  --url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/token" \
  --header "Host: ${ADMAPI_DOMAIN}" \
  --user "${ADMAPI_CREDENTIAL}" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "grant_type=password" \
  --data-urlencode "scope=${ADMAPI_AREA}" \
  --data-urlencode "username=${ADMAPI_USERNAME}" \
  --data-urlencode "password=${ADMAPI_PASSWORD}" \
  --output ${TMP_JSON_FILE} \
  --write-out "%{http_code}\nURL: %{url_effective}" \
  2>/dev/null )

  if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
  else
    rm -f ${ACCESSTOKEN_FILE} 2>/dev/null
    echo "ADMAPI_ACCESSTOKEN=$(jq -r ".access_token" ${TMP_JSON_FILE})" > ${ACCESSTOKEN_FILE}
    echo "ADMAPI_ACCESSTOKEN_EPOCH=$(( $(date +%s) + $( jq -r ".expires_in" ${TMP_JSON_FILE}) ))" >> ${ACCESSTOKEN_FILE}
  fi

  chmod 700 ${ACCESSTOKEN_FILE}
  rm -f ${TMP_JSON_FILE}

fi

source ${ACCESSTOKEN_FILE}
echo "[INFO] ACCESS-TOKEN = ${ADMAPI_ACCESSTOKEN}"
echo "[INFO] TOKEN VALID UNTIL: $(date -d @${ADMAPI_ACCESSTOKEN_EPOCH}) (epoch: ${ADMAPI_ACCESSTOKEN_EPOCH})"
echo

