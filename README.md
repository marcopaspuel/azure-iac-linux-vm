## Deploy a Linux VM in Azure using Terraform
This project contains a Terraform template to deploy a customizable linux vm in Azure.

### Prerequisites
- [Azure Account](https://portal.azure.com) 
- [Azure Command Line Interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)

### Project Dependencies
- [Terraform](https://www.terraform.io/downloads.html)

### Getting Started

1. Fork and clone this repository in your local environment
2. Open the project on your favorite text editor or IDE
3. Log into the [Azure Portal](https://portal.azure.com)

### Installation & Configuration
Note: To create a service principal (step 1), and the storage account(step 2) you need special permissions, and it needs to be done only once.
If you don't have the required permissions please ask the sysadmin.
#### 1. Create a Service Principal for Terraform
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
Create an `terraform.tfvars` file inside the terraform directory and copy the content of the `terraform.tfvars.template` to the newly created file.
Change the parameters based on the output of the previous command. These values map to the variables like so:

    appId is the client_id
    password is the client_secret
    tenant is the tenant_id

#### 2. Configure the storage account and state backend
To [configure the storage account and state backend](https://docs.microsoft.com/en-us/azure/developer/terraform/store-state-in-azure-storage)
run the bash script [config_storage_account.sh](scripts/config_storage_account.sh) providing
a resource group name, and a desired location. 
``` bash
cd scripts
./config_storage_account.sh -g "RESOURCE_GROUP_NAME" -l "LOCATION"
```

### Deploy Virtual Machine
#### 1. Create an SSH key for authentication to a Linux VM in Azure
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

#### 4. Create a tfvars file to configure Terraform Variables
Create a `terraform.tfvars` file inside the [staging](terraform/environments/staging) directory and copy the content of the [terraform.tfvars.template](terraform/environments/staging/terraform.tfvars.template)
to the newly created file. Change the values based on the outputs of the previous steps.

- The `subscription_id`, `client_id`, `client_secret`, and `tenant_id` can be found in the `.azure_envs.sh` file. 
- Set your desired `location` and `resource_group` for the infrastructure.
- Ensure that the public key name `vm_public_key` is the same as the one created in step 3. of this guide.

#### 5. Deploy the infrastructure from your local environment with Terraform
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

### Connect to the Virtual Machine
First, find the public IP of the newly created Linux VM. The public IP can be found in the Azure Portal under
`Home > Resource groups > "RESOURCE_GROUP_NAME" > "Virtual machine"`

Then, use the ssh key created in step 3 of this guide to connect to the VM with the following command.
``` bash
ssh -o "IdentitiesOnly=yes" -i ~/.ssh/az_linux_vm_id_rsa marco@PublicIP
```

### Clean Up
To delete all the resources created by terraform you can use the following command:
``` bash
cd terraform
terraform destroy
```
To delete the resource group created in step 2 run the following command:
``` bash
az group delete --no-wait --name "RESOURCE_GROUP_NAME"
```
To delete the Service Principal Created in step 1 run the following command:
``` bash
az ad sp delete --id 00000000-0000-0000-0000-000000000000
```
