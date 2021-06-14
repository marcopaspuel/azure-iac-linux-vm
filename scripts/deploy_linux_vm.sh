# Get Remote State Storage Account details
tfstateRg='azure-iac-linux-vm-rg'
tfstateAccount=$(az storage account list --resource-group ${tfstateRg} | jq .[0])
tfstateAccountName=$(echo $tfstateAccount | jq .name -r)
tfstateAccountKey=$(az storage account keys list --resource-group ${tfstateRg} --account-name ${tfstateAccountName} | jq .[0].value -r)
tfstateContainer='tstate'
tfstateKeyName='key=terraform.tfstate'


### Deploy Linux VM
# Initialise solution
terraform init \
    -backend-config="storage_account_name=${tfstateAccountName}" \
    -backend-config="container_name=${tfstateContainer}" \
    -backend-config="access_key=${tfstateAccountKey}" \
    -backend-config="${tfstateKeyName}"

# Validate solution
terraform validate

# Plan solution deployment
planName='linux-vm.plan'
terraform plan -out=${planName}

# Deploy solution
terraform apply -auto-approve ${planName}

# Get public IP address
linuxVmRg='azure-iac-linux-vm-resources'
vmName='azure-iac-linux-vm'
az vm show --resource-group $linuxVmRg --name $vmName -d --query [publicIps] -o tsv
