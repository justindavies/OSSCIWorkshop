# Introduction
This is a bit of an introduction to how to work with Azure.  

## Accounts and subscription
A company will have an administrator account, or an Enterprise Agreement to use Azure services.  You may have an account within this agreement which is your identifier within the Azure interface.

Within an account, or number of accounts you will have a subscription.  This is where you work within and may have quotas and constraints (policies) attached to it. 

### The quota, policy and subscription paradigm
Your administrator will very likely have placed policies and quotas on what you as a user can do within Azure.  This may include the maximum number of cores, or machine types you can instantiate.

A Policy may also exist to restrict you to spin up infrastructure and services within a specific region.

## The portal
Most people's first interaction with Azure is through the [portal](http://portal.azure.com).

This is a web interface to all Azure services.  Everything that can be achieved within the portal ends up as a REST API call to the Azure API service (not to be confused by the Azure API Management service)

## The CLI
If the command line is more of your thing, you can install the cross platform [command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).

The CLI provides access to all Azure services from the command line, and allows you to script interaction with Azure.  Most of this workshop will utilise the command line interface.

## Cloud Shell
If you don't want to install the cli locally, or you have restricted access outside of your organisation, you can use the cloud shell.

Login to the portal or goto [http://shell.azure.com](http://shell.azure.com).  This will open up a Linux machine that will be pre-authenticated to the azure API for you to start work.

# Create a Linux VM (Portal)
Goto the [Portal](http://portal.azure.com) and create a Linux virtual machine.

# Create a Linux VM (CLI/Cloud Shell)

