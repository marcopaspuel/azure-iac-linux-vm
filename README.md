# azure-iac-linux-vm
This project contains a Terraform template to deploy a customizable linux vm in Azure.

### Installation & Configuration
#### 1. Terraform in Azure
##### 1.1. Create a Service Principal for Terraform
Log into your Azure account
``` bash
az login 
```
``` bash 
az account set --subscription="SUBSCRIPTION_ID"
```
Create Service Principle
``` bash
az ad sp create-for-rbac --name ensuring-quality-releases-sp --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```
This command will output 5 values:
``` json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-cli-2017-06-05-10-41-15",
  "name": "http://azure-cli-2017-06-05-10-41-15",
  "password": "0000-0000-0000-0000-000000000000",
  "tenant": "00000000-0000-0000-0000-000000000000"
}
``` 
Create an `.azure_envs.sh` file inside the project directory and copy the content of the `.azure_envs.sh.template` to the newly created file.
Change the parameters based on the output of the previous command. These values map to the `.azure_envs.sh` variables like so:

    appId is the ARM_CLIENT_ID
    password is the ARM_CLIENT_SECRET
    tenant is the ARM_TENANT_ID

##### 1.2. Configure the storage account and state backend
To [configure the storage account and state backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)
run the bash script [config_storage_account.sh](terraform/config_storage_account.sh) providing
a resource group name, and a desired location. 
``` bash 
./terraform/config_storage_account.sh -g "RESOURCE_GROUP_NAME" -l "LOCATION"
```
This script will output 3 values:
``` bash 
storage_account_name: tstate$RANDOM
container_name: tstate
access_key: 0000-0000-0000-0000-000000000000
```
Replace the `RESOURCE_GROUP_NAME` and `storage_account_name` in the [terraform/environments/test/main.tf](terraform/environments/test/main.tf)
file and the `access_key` in the `.azure_envs.sh` script.
```
terraform {
    backend "azurerm" {
        resource_group_name  = "RESOURCE_GROUP_NAME"
        storage_account_name = "tstate$RANDOM"
        container_name       = "tstate"
        key                  = "terraform.tfstate"
    }
}
```
```
export ARM_ACCESS_KEY="access_key"
```
You will also need to replace this values in the [azure-pipelines.yaml](.devops/pipelines/azure-pipelines.yaml) file.
```
backendAzureRmResourceGroupName: "RESOURCE_GROUP_NAME"
backendAzureRmStorageAccountName: 'tstate$RANDOM'
backendAzureRmContainerName: 'tstate'
backendAzureRmKey: 'terraform.tfstate'
```
To source this values in your local environment run the following command:
```
source .azure_envs.sh
```
NOTE: The values set in `.azure_envs.sh` are required to run terraform commands from your local environment.
There is no need to run this script if terraform runs in Azure Pipelines.

