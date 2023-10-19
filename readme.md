# What is an API and how to secure it?

Here is a nice, condensed summary of the topic: [REST API Security Essentials](https://dzone.com/refcardz/rest-api-security-1?utm_campaign=APISecurity%20newsletter&utm_medium=email&_hsmi=209205925&_hsenc=p2ANqtz-8YY0znOLBVIaYFIFRQ54YBKVsKyuAx_WpZdDb1laM8C69eTFLiHVPvM-ukYU0zhPQu4uZKECjdCQmnC4rVoGhBo4LS7Q&utm_content=209185698&utm_source=hs_email).

# TIBCO Cloud API-Management - Masher v3 Admin API

*TIBCO Cloud API-Management* and *TIBCO Cloud API-Management Local Edition* (formerly known as Mashery) provides an administrative API to register service, users and client applications and managing platform infrastructure parameters. It can be used to automate platform management activities, to synchronize settings or registered services between different systems. Examples might be exposing newly hosted REST services from a CD process. To accomplish this, I started to create some Linux CLI (bash) scripts.

These scripts were originally created for repeatable demo sessions with prospects as well as samples for existing customers. At the current state its not a full set of tools for all needs, but they should give enough inspiration and exsamples to create other features in a similar way as needed.

The used API-Management administrative APIs are documented and described in detail at [Mashery Developer Portal](https://developer.mashery.com/). The orginal Mashery Developer Portal is the user interaction point for managing TIBCO CLoud API-Management SaaS. In case of a TIBCO Cloud API-Managment Local Edition (aka Mashery Local) the API Portal is hosted part of the hosted API-Management Cluster and has its own URL.

> :exclamation: The scripts are a sample or template for how the Mashery v3 API functions can be used for automating things using the CLI. They are by no means complete and ready to use. Please feel free to copy and extend the samples.

For details on how to register an TIBCO Cloud API-Management (Mashery) managed API manually via the Web-UI you can find a short how-to guide at [How to create an API in TIBCO Mashery](https://rsdigitech.com/posts/how-to-create-an-api-in-tibco-mashery). For more details please consult the product documentation and use the online product training or TIBCO's Youtube ressources.

There are also examples available to use the Mashery v3 API from TIBCO's lightweight integration tooling Flogo. Especially the token handling in Flogo context needs some know how. A GoLang implementation of a suitable Flogo Plugin is freely available at [Flogo Mash Token](https://github.com/project-flogo/tibco-contrib/tree/master/activity/mashtoken).

## Prerequisites

All scripts are built for Linux systems. At least WSL2 (Ubuntu) or plain Linux system is needed. A headless server system is sufficient (no GUI applications).
Additional tools needed are:
* [curl](https://curl.se/) - to communicate via HTTPS with TIBCO API-Management
* [jq](https://jqlang.github.io/jq/) - to read, validate and transform JSON documents (Mashery v3 API replies)

## apim-v3-config.sh

That shell script just defines some environment variables needed by other scripts. Those settings are the target API-Management system to talk to as well as the required credentials to get an access token for calling the needed APIs.

> Please copy the provided template and save your personal config as `apim-v3-config.sh`. The scripts are looking for that file by default.

## apim-v3-authentication.sh

As the TIBCO Cloud API-Management (aka Mashery) is hosting **one central V3 API** service for all hosted APIM Areas (customer clusters) one needs a user on the Mashery cloud management system. Typically that is a user registered via an API Developer Portal on one of the hosted domains (in my case https://scdach.mashery.com). The user must be configured to be a "Service Account"

After login to [Mashery Developer Portal](https://developer.mashery.com/) the next step is the registration of an Mashery V3 API client at [https://developer.mashery.com/apps/register](https://developer.mashery.com/apps/register).

Now we have two sets of credentials:
* API Developer (interactive) User Account (username + password)
* Mashery v3 API Key (Id + secret)

A short notice how to get a service account is available here [Steps to access Mashery V2/V3 APIs for TIBCO cloud accounts](https://support.tibco.com/s/article/Steps-to-access-Mashery-V2-V3-APIs-for-TIBCO-cloud-accounts).

With all that details configured in file *apim-v3-config.sh* one can start the authentication procedure: `./apim-v-authenticate.sh` As result a new file will be created which hold the OAuth2 access token along with its validity period. Depending if the validity period of an available token is already met, the output should be similar to:

```
[INFO] Reading access token from file
[INFO] Acquiring new API v3 access token for user rekies
[INFO] ACCESS-TOKEN = nn2wcefku79pkezbr942kfsg
[INFO] TOKEN VALID UNTIL: Thu Oct  5 16:03:03 CEST 2023 (epoch: 1696514583)
```

> :exclamation: Testing of Mashery V3 API can also be done via the Swagger-UI of the TIBCO Cloud API-Management **Developer Portal** - [Interactive Docs](https://developer.mashery.com/io-docs) OR by using the public **Postman collection** available at [TIBCO Mashery's Public Workspace](https://www.postman.com/tibcomashery/workspace/tibco-mashery-s-public-workspace/overview). The Potsman collection could also be donwloaded and used with a local Postman instance for personal developer tests.

## apim-v3-members.sh

Sample API call to retrieve all configured members (users of the area). - With *jq* one could extract IDs for subsequent calls...

## apim-v3-roles.sh

Sample API call to retrieve all configured roles.

## apim-v3-services.sh

Sample API call to retrieve all configured API services.

## apim-v3-services-add.sh

Template for registering a new API service from a JSON file (Mashery API description).

## apim-v3-transform-interactive-oas-doc.sh

Mashery v3 API to convert a Sagger API specification into a Mashery proprietary IODocs specification. Idea was to use that to register new API services...

## apim-v3-transform-swagger.sh

Mashery v3 API to change endpoint information of an API specification file (Swagger 2.0). Transformed API specifications could be the base of an API Documentation. Only any added endpoint security must be added via the API documentation editor.


# The Misbehaving API

For my demo purposes I also need an API service that can be hosted somewhere and can be called from a simulated client application through TIBCO API-Management (SaaS or Local Edition). In my test setup I just uploaded the API specification to *TIBCO Cloud Integration* API Creation and Mockup services and started a simple Mockup service from it.

Idea of the Misbehaving API is to have an API service that can be instructed to *misbehave* according to parameters of an API call. Using this one can get the capability to test any protections configured on the API-Management layer (for API gateways). An example: backend timeout - max. time for a downstream API service to reply to a client. The API gateway can enforce a maximum wait time and reply with an error if the downstream service becomes to slow.

A similar things can be achieved by using services like [https://github.com/postmanlabs/httpbin](https://github.com/postmanlabs/httpbin), but I wanted to have something that I can use without Internet access as well. Another test service collection could be [https://reqbin.com/](https://reqbin.com/).
