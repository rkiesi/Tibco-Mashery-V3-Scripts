# TIBCO Cloud API-Management - Masher v3 Admin API

*TIBCO Cloud API-Management* and *TIBCO Cloud API-Management Local Edition* (formerly known as Mashery) provide an administrative API to register service, users and client applications and managing platform infrastructure parameters. To be able to automate those platform managments to synchronize settings or registered services between different systems, e.g. to expose newly hosted REST services, I strated to create some Linux CLI (bash) scripts.

These scripts were originally created for repeatable demo sessions with prospects as well as samples for existing customers. At the current state its not a full set of tools for all needs, but they should give enoough inspiration and sample to create other features in a similar way.

The used API-Managament administrative APIs are documented and described in detail at [Mashery Developer Portal](https://developer.mashery.com/). This Developer Portal is the user interaction point

## Prerequisites

All scripts are built for Linux systems. At least WSL2 (Ubuntu) or plain Linux system is needed. A headless server system is sufficient (no GUI applications).
Additional tools needed are:
* curl - to communitate via HTTPS with TIBCO API-Management
* jq - to read, validate and transform JSON documents

## apim-v3-config.sh

That shell script just defines some envionment variables needed by other scripts. Those settings are the arget API-Managment system to talk to as well as the required credentials to get an access token for calling the needed APIs.

## apim-v3-authentication.sh

As the TIBCO Cloud API-Managment (aka Mashery) is hosting **one central V3 API** service for all hosted APIM Areas (customer clusters) one needs a user on the Mashery cloud management system. Typically that is a user registered via an API Developer Portal on one of the hosted domains (in my case https://scdach.mashery.com). The user must be configured to be a "Service Account"

After login to [Mashery Developer Portal](https://developer.mashery.com/) the next step is the registration of an Mashery V3 API Cliente at [https://developer.mashery.com/apps/register](https://developer.mashery.com/apps/register).

Now we have two sets of credentials:
* API Developer (interactive) User Account (username + password)
* Mashery v3 API Key (Id + secret)

A short notice how to get a service account is available here [Steps to access Mashery V2/V3 APIs for TIBCO cloud accounts](https://support.tibco.com/s/article/Steps-to-access-Mashery-V2-V3-APIs-for-TIBCO-cloud-accounts).

With all that details configured in file *apim-v3-config.sh* one can start the authentication procedure: `./apim-v-authenticate.sh` As result a new file will be created which hold the OAuth2 access token along with its validity periode. Depending if the validity periode of an available token is already met, the output should be similar to:

```
[INFO] Reading access token from file
[INFO] Acquiring new API v3 access token for user rekies
[INFO] ACCESS-TOKEN = nn2wcefku79pkezbr942kfsg
[INFO] TOKEN VALID UNTIL: Thu Oct  5 16:03:03 CEST 2023 (epoch: 1696514583)
```

## apim-v3-members.sh

This is 

## apim-v3-members.sh

