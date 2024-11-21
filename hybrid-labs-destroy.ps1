# Assumes you created the environment using the hybrid-labs-prep.ps1 script.

# Participant count - change this to the number of participants you want to create
$participantCount = 1

# Participant prefix - used for the user account and resource group names
$participantPrefix = "hybrid-"

# Entra ID directory name - need this for the UPN
# $directoryName = "<FILL THIS IN>"
$directoryName = "danzig.live"

# Check that az module is installed, install if not
if (-not (Get-Module -Name Az -ListAvailable)) {
    Write-Host "Az module not found, installing..."
    Install-Module -Name Az -AllowClobber -Force
    Write-Host "Az module installed"
}

# Sign in to Azure
az config set core.allow_broker=true
az login --scope https://graph.microsoft.com//.default

# Set the subscription, can remove this bit for the Azure Pass deployment
# az account set -n "<FILL THIS IN IF YOU GOT MULTIPLE SUBS>"

# Get the current subscription ID
#$subscriptionId = az account show --query id --output tsv

# Loop through the number of participants, creating user accounts and resource groups, and then the ARM deployment
for ($i = 1; $i -le $participantCount; $i++) {
    $userNumber = "{0:D2}" -f $i
    $participantName = $participantPrefix + $userNumber
    $userPrincipalName = "$participantName@$directoryName"
    $resourceGroupName = $participantName + "-rg"

    # Delete the resource group
    az group delete --name $resourceGroupName --yes --no-wait

    # Delete the user account
    az ad user delete --upn-or-object-id $userPrincipalName
}