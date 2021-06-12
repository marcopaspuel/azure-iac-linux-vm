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
az ad sp create-for-rbac --name azure-iac-linux-vm-sp --role="Contributor" --scopes="/subscriptions/SUBSCRIPTION_ID"
```
This command will output 5 values:
``` json
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "azure-iac-linux-vm-sp",
  "name": "http://azure-iac-linux-vm-sp",
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
run the bash script [config_storage_account.sh](config_storage_account.sh) providing
a resource group name, and a desired location. 
``` bash 
./config_storage_account.sh -g "RESOURCE_GROUP_NAME" -l "LOCATION"
```
This script will output 3 values:
``` bash 
storage_account_name: tstate$RANDOM
container_name: tstate
access_key: 0000-0000-0000-0000-000000000000
```
Replace the `RESOURCE_GROUP_NAME` and `storage_account_name` in the [terraform/environments/staging/main.tf](terraform/environments/staging/main.tf)
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
You will also need to add the access key in the `.azure_envs.sh` file.
```
export ARM_ACCESS_KEY="access_key"
```
Source this values in your local environment by running the following command:
```
source .azure_envs.sh
```

##### 1.3. Create an SSH key for authentication to a Linux VM in Azure
To generate a public private key pair run the following commands (passphrase is optional):
``` bash
cd ~/.ssh/
ssh-keygen -t rsa -b 4096 -f az_linux_vm_id_rsa
```
Ensure that the keys were created:
``` bash
ls -ll | grep az_linux_vm_id_rsa
```
For additional information of how to create and use SSH keys, click on the links bellow:
- [Create and manage SSH keys for authentication to a Linux VM in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Creating and Using SSH Keys](https://serversforhackers.com/c/creating-and-using-ssh-keys)

##### 1.4. Create a tfvars file to configure Terraform Variables
Create a `terraform.tfvars` file inside the [staging](terraform/environments/staging) directory and copy the content of the [terraform.tfvars.template](terraform/environments/staging/terraform.tfvars.template)
to the newly created file. Change the values based on the outputs of the previous steps.

- The `subscription_id`, `client_id`, `client_secret`, and `tenant_id` can be found in the `.azure_envs.sh` file. 
- Set your desired `location` and `resource_group` for the infrastructure.
- Ensure that the public key name `vm_public_key` is the same as the one created in step 2.1 of this guide.

##### 1.5. Deploy the infrastructure from your local environment with Terraform
Run Terraform plan 
``` bash
cd terraform/environments/staging
```
``` bash
terraform init
```
``` bash
terraform plan -out solution.plan
```
After running the plan you should be able to see all the resources that will be created.

Run Terraform apply to deploy the infrastructure.
``` bash
terraform apply "solution.plan"
```

If everything runs correctly you should be able to see the resources been created. You can also check the creation of 
the resources in the [Azure Portal](https://portal.azure.com/#blade/HubsExtension/BrowseResourceGroups) under <br/>
`Home > Resource groups > "RESOURCE_GROUP_NAME"`
