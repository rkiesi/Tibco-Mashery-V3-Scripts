#!/usr/bin/bash
# author:  rkiessli, TIBCO Software (SC_DACH)
# changed: 2022-07-01

# Parameters 1 is the swagger file to convert
if [[ -z "${1}" ]]; then
  echo "[WARN] No Swagger specification file provided."
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


# Aquire a TIBCO APIM LE API v3 access token
if [ ! -x ./apim-v3-authenticate.sh ]; then
  echo "[ERROR] authentication procedure file ./apim-v3-authenticate.sh not found."
  exit 1
fi
source ./apim-v3-authenticate.sh


# -------------------------------------------------------
# Transform service spec from SWAGGER 2.0 to SWAGGER 2.0
# -------------------------------------------------------
http_response=$(\
curl --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/transform?sourceFormat=swagger2&targetFormat=swagger2&publicDomain=api.apidemo.spdns.org" \
--header "Host: ${ADMAPI_DOMAIN}" \
--header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
--header "Content-Type: application/json" \
--data @${API_SPECIFICATION_FILE} \
--output ${TMP_JSON_FILE} \
--write-out "%{http_code}\nURL: %{url_effective}" \
2>/dev/null )

if [ $(echo "${http_response}" | head -1) != "200" ]; then
    echo "[ERROR]: API call failed with status code ${http_response}"
    exit 1
    
else
    echo "[INFO] Convert from Swagger 2.0 to Mashery API format:"
    echo "Converted Service Spec:"
    jq -r ".document" ${TMP_JSON_FILE}
    echo "Validation Errors:"
    jq ".validationErrors" ${TMP_JSON_FILE}
    echo "Other Errors:"
    jq ".feasibilityErrors" ${TMP_JSON_FILE}
    
    # if no validation errors prepare suitable Swagger for Interactive APIs
    if [[ $(jq -r '.validationErrors | length' ${TMP_JSON_FILE}) > 0 ]]; then
      echo "[WARNING] Errors during transformation. Interactivce doc will not be created!"
      exit 1
    fi
    # extract converted swagger spec AND remove all security details
    # adopt the base path to match endpoint settings
    service_name="MisbehavingSampleService"
    endpoint_basepath="/samples/misbehaving"
    jq -r ".document" ${TMP_JSON_FILE} | \
    jq "del(.securityDefinitions,.security) | .basePath=\"${endpoint_basepath}\" | .info.title=\"${service_name}\"" > ${API_SPECIFICATION_FILE}_transformed
#    jq "del(.securityDefinitions,.security) | .basePath = \'${endpoint_basepath}\'" > ${API_SPECIFICATION_FILE}_transformed
    # add new security details from template
    jq -s ".[0] * .[1]" ${API_SPECIFICATION_FILE}_transformed template_security_swagger-apikey.json > ${API_SPECIFICATION_FILE}_apim
    echo "[INFO] API specification for Interactive Docs:"
    jq "." ${API_SPECIFICATION_FILE}_apim
    
    rm -f ${TMP_JSON_FILE} ${API_SPECIFICATION_FILE}_transformed >/dev/null 2>&1
fi

