#!/usr/bin/bash
# author:  rkiessli, TIBCO Software (SC_DACH)
# changed: 2023-10-05

# TIBCO APIM or LE (untethered) - Parameters

#export ADMAPI_APIHOST="developer.apidemo.spdns.org:7443"
export ADMAPI_APIHOST="api.mashery.com:443"
export ADMAPI_BASEPATH="/v3"

# details from zone config file tml_papi_properties.json
# parameters: sp_config_environment_domain_suffix = "mashery.com"
export ADMAPI_DOMAIN="api.mashery.com"

# parameter: your_api_key_for_v3_api / your_secret_for_v3_api
# Mashery cloud is hosting one central V3 API service for all hosted APIM Areas (customer clusters).
export ADMAPI_CREDENTIAL="<V3-CLIENT-ID>:<C3-CLIENT-SECRET"
export ADMAPI_AREA="<AREA-UUID>"

# Interactive user to use for call execution
# (user of API-M which was configured to be a "Service Account")
export ADMAPI_USERNAME="rekies"
export ADMAPI_PASSWORD="ToSave4me!"

# target API service fateway domain
export ADMAPI_SERVICE_DOMAIN="scdach.api.mashery.com"

unset ADMAPI_ACCESSTOKEN

export TMP_JSON_FILE=./reply.tmp
rm -f ${TMP_JSON_FILE}
