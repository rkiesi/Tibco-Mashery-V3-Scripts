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


# Acquire a TIBCO APIM LE API v3 access token
if [ ! -x ./apim-v3-authenticate.sh ]; then
  echo "[ERROR] authentication procedure file ./apim-v3-authenticate.sh not found."
  exit 1
fi
source ./apim-v3-authenticate.sh


# Retrieve list of all services
http_response=$(\
curl --silent --insecure \
--url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/services" \
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
    echo "Service list:"
    jq -r "." ${TMP_JSON_FILE}
fi


# Get complete service details per available service
# see KB article https://support.tibco.com/s/article/Return-all-endpoint-fields-in-Fetch-Service-V3-call
#FULL_SERVICE_DETAILS="fields=id,name,created,updated,editorHandle,revisionNumber,robotsPolicy,crossdomainPolicy,description,errorSets,errorSets.name,errorSets.type,errorSets.jsonp,errorSets.jsonpType,errorSets.errorMessages,qpsLimitOverall,rfc3986Encode,securityProfile,version,cache,roles,roles.id,roles.created,roles.updates,roles.name,roles.action,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCallid,name,created,updated,editorHandle,revisionNumber,robotsPolicy,crossdomainPolicy,description,errorSets,errorSets.name,errorSets.type,errorSets.jsonp,errorSets.jsonpType,errorSets.errorMessages,qpsLimitOverall,rfc3986Encode,securityProfile,version,cache,roles,roles.id,roles.created,roles.updates,roles.name,roles.action,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCall,endpoints.gzipPassthroughSupportEnabled,endpoints.headersToExcludeFromIncomingCall,endpoints.highSecurity,endpoints.hostPassthroughIncludedInBackendCallHeader,endpoints.inboundSslRequired,endpoints.jsonpCallbackParameter,endpoints.jsonpCallbackParameterValue,endpoints.scheduledMaintenanceEvent,endpoints.forwardedHeaders,endpoints.returnedHeaders,endpoints.methods,endpoints.methods.name,endpoints.methods.sampleJsonResponse,endpoints.methods.sampleXmlResponse,endpoints.methods.responseFilters,endpoints.methods.responseFilters.id,endpoints.methods.responseFilters.name,endpoints.methods.responseFilters.created,endpoints.methods.responseFilters.updated,endpoints.methods.responseFilters.notes,endpoints.methods.responseFilters.xmlFilterFields,endpoints.methods.responseFilters.jsonFilterFields,endpoints.name,endpoints.numberOfHttpRedirectsToFollow,endpoints.outboundRequestTargetPath,endpoints.outboundRequestTargetQueryParameters,endpoints.outboundTransportProtocol,endpoints.processor,endpoints.publicDomains,endpoints.requestAuthenticationType,endpoints.scheduledMaintenanceEvent,endpoints.scheduledMaintenanceEvent.id,endpoints.scheduledMaintenanceEvent.name,endpoints.scheduledMaintenanceEvent.startDateTime,endpoints.scheduledMaintenanceEvent.endDateTime,endpoints.scheduledMaintenanceEvent.endpoints,endpoints.requestPathAlias,endpoints.requestProtocol,endpoints.oauthGrantTypes,endpoints.stringsToTrimFromApiKey,endpoints.supportedHttpMethods,endpoints.systemDomainAuthentication,endpoints.systemDomainAuthentication.type,endpoints.systemDomainAuthentication.username,endpoints.systemDomainAuthentication.certificate,endpoints.systemDomainAuthentication.password,endpoints.systemDomains,endpoints.trafficManagerDomain,endpoints.useSystemDomainCredentials,endpoints.systemDomainCredentialKey,endpoints.systemDomainCredentialSecret"

FULL_SERVICE_DETAILS="fields=id,name,created,updated,editorHandle,revisionNumber,robotsPolicy,crossdomainPolicy,description,qpsLimitOverall,rfc3986Encode,securityProfile,version,cache,roles,roles.id,roles.created,roles.updates,roles.name,roles.action,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCallid,name,created,updated,editorHandle,revisionNumber,robotsPolicy,crossdomainPolicy,description,qpsLimitOverall,rfc3986Encode,securityProfile,version,cache,roles,roles.id,roles.created,roles.updates,roles.name,roles.action,endpoints.allowMissingApiKey,endpoints.apiKeyValueLocationKey,endpoints.apiKeyValueLocations,endpoints.apiMethodDetectionKey,endpoints.apiMethodDetectionLocations,endpoints.cache.clientSurrogateControlEnabled,endpoints.cache.contentCacheKeyHeaders,endpoints.connectionTimeoutForSystemDomainRequest,endpoints.connectionTimeoutForSystemDomainResponse,endpoints.cookiesDuringHttpRedirectsEnabled,endpoints.cors,endpoints.cors.allDomainsEnabled,endpoints.cors.maxAge,endpoints.customRequestAuthenticationAdapter,endpoints.dropApiKeyFromIncomingCall,endpoints.forceGzipOfBackendCall,endpoints.gzipPassthroughSupportEnabled,endpoints.headersToExcludeFromIncomingCall,endpoints.highSecurity,endpoints.hostPassthroughIncludedInBackendCallHeader,endpoints.inboundSslRequired,endpoints.jsonpCallbackParameter,endpoints.jsonpCallbackParameterValue,endpoints.scheduledMaintenanceEvent,endpoints.forwardedHeaders,endpoints.returnedHeaders,endpoints.methods,endpoints.methods.name,endpoints.methods.sampleJsonResponse,endpoints.methods.sampleXmlResponse,endpoints.methods.responseFilters,endpoints.methods.responseFilters.id,endpoints.methods.responseFilters.name,endpoints.methods.responseFilters.created,endpoints.methods.responseFilters.updated,endpoints.methods.responseFilters.notes,endpoints.methods.responseFilters.xmlFilterFields,endpoints.methods.responseFilters.jsonFilterFields,endpoints.name,endpoints.numberOfHttpRedirectsToFollow,endpoints.outboundRequestTargetPath,endpoints.outboundRequestTargetQueryParameters,endpoints.outboundTransportProtocol,endpoints.processor,endpoints.publicDomains,endpoints.requestAuthenticationType,endpoints.scheduledMaintenanceEvent,endpoints.scheduledMaintenanceEvent.id,endpoints.scheduledMaintenanceEvent.name,endpoints.scheduledMaintenanceEvent.startDateTime,endpoints.scheduledMaintenanceEvent.endDateTime,endpoints.scheduledMaintenanceEvent.endpoints,endpoints.requestPathAlias,endpoints.requestProtocol,endpoints.oauthGrantTypes,endpoints.stringsToTrimFromApiKey,endpoints.supportedHttpMethods,endpoints.systemDomainAuthentication,endpoints.systemDomainAuthentication.type,endpoints.systemDomainAuthentication.username,endpoints.systemDomainAuthentication.certificate,endpoints.systemDomainAuthentication.password,endpoints.systemDomains,endpoints.trafficManagerDomain,endpoints.useSystemDomainCredentials,endpoints.systemDomainCredentialKey,endpoints.systemDomainCredentialSecret"

if [[ $(jq -r 'length' ${TMP_JSON_FILE}) > 0 ]]; then

  for sid in $(jq -r ".[].id" ${TMP_JSON_FILE}); do
    # service spec as mashery properties
    http_response=$(\
    curl --silent --insecure \
    --url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/services/${sid}?${FULL_SERVICE_DETAILS}" \
    --header "Host: ${ADMAPI_DOMAIN}" \
    --header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
    --output ${TMP_JSON_FILE} \
    --write-out "%{http_code}\nURL: %{url_effective}" \
    2>/dev/null )

    if [ $(echo "${http_response}" | head -1) != "200" ]; then
      echo "[ERROR]: API call failed with status code ${http_response}"
      exit 1
    else
      echo "Service deatils:"
      jq -r "." ${TMP_JSON_FILE}
    fi
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1

    # service io-docs
    http_response=$(\
    curl --silent --insecure \
    --url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/iodocs/services/${sid}" \
    --header "Host: ${ADMAPI_DOMAIN}" \
    --header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
    --output ${TMP_JSON_FILE} \
    --write-out "%{http_code}\nURL: %{url_effective}" \
    2>/dev/null )

    if [ $(echo "${http_response}" | head -1) != "200" ]; then
      echo "[ERROR]: I/O-Doc API call failed with status code ${http_response}"
    else
      echo "I/O Doc for service:"
      jq -r "." ${TMP_JSON_FILE}
    fi
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1

    # service swagger
    http_response=$(\
    curl --silent --insecure \
    --url "https://${ADMAPI_APIHOST}${ADMAPI_BASEPATH}/rest/iodocs/services/docs/${sid}" \
    --header "Host: ${ADMAPI_DOMAIN}" \
    --header "Authorization: Bearer ${ADMAPI_ACCESSTOKEN}" \
    --output ${TMP_JSON_FILE} \
    --write-out "%{http_code}\nURL: %{url_effective}" \
    2>/dev/null )

    if [ $(echo "${http_response}" | head -1) != "200" ]; then
      echo "[ERROR]: OAS API call failed with status code ${http_response}"
    else
      echo "OAS for service:"
      jq -r "." ${TMP_JSON_FILE}
    fi
    rm -f ${TMP_JSON_FILE} >/dev/null 2>&1

  done

else
  echo "[WARN] No registerd services available"
fi

