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


# Retrieve all registered users
#http_response=$(\
#curl --silent --insecure \
#--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/members" \
#--header "Host: ${ADMAPI_DOMAIN}" \
#--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
#--output ${TMP_JSON_FILE} \
#--write-out "%{http_code}\nURL: %{url_effective}" \
#2>/dev/null \
#)

# sample on how to list wanted return values:
# KB: https://support.tibco.com/s/article/Return-all-endpoint-fields-in-Fetch-Service-V3-call
http_response=$(\
curl --silent --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/members?fields=id,username,displayName,roles.name,roles.description" \
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

echo
echo "---------------"
echo

sleep 1.0

# Whitelisting a domain called: "mytestapi.example.com"
for i in {1..0}
do
  http_response=$(\
curl --insecure --location --request POST \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/domains" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--header "Content-Type: application/json" \
--data '{"domain": "mytestapi'"-$i"'.example.com", "status":"active"}' \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null )

  if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
  else
    echo "Server returned:"
    jq -r "." ${TMP_JSON_FILE}
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1
  fi

  sleep 0.5
done


# List of registered domains
http_response=$(\
curl --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/domains" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null )

if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
else
    echo "Registered Domains:"
    jq -r "." ${TMP_JSON_FILE}
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1
fi


# Transform service spec from SWAGGER 2.0
http_response=$(\
curl --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/transform?sourceFormat=swagger2&targetFormat=masheryapi&publicDomain=api.apidemo.spdns.org" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--header "Content-Type: application/json" \
--data @misbehaving-simple-service-TCI.json \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null )

if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
else
    echo "Converted Service Spec:"
    jq -r ".document" ${TMP_JSON_FILE}
    echo "Validation Errors:"
    jq ".validationErrors" ${TMP_JSON_FILE}
    echo "Other Errors:"
    jq ".feasibilityErrors" ${TMP_JSON_FILE}
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1
fi



curl --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/transform?sourceFormat=swagger2&targetFormat=swagger2&publicDomain=api.apidemo.spdns.org" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--header "Content-Type: application/json" \
--data @misbehaving-simple-service-TCI.json \


