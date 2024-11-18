<#
Script to prepare the Azure Pass subscription for multiple participants.

For the number of participants specified, the script will:
1. Create a user account in the Entra ID directory
2. Create a resource group in the Azure subscription
3. Assign the user account as the owner of the resource group
4. Deploy the ARM template to the resource group with default parameters

Use PowerShell version 7+
#>

# Participant count - change this to the number of participants you want to create
$participantCount = 2

# Participant prefix - used for the user account and resource group names
$participantPrefix = "hybrid-"

# Default user password for the user accounts
$userPassword = "HardPass123!"

# Entra ID directory name - need this for the UPN
# $directoryName = "<FILL THIS IN>"

# Azure region to deploy resources
$location = "australiaeast"


# Check that az module is installed, install if not
if (-not (Get-Module -Name Az -ListAvailable)) {
    Write-Host "Az module not found, installing..."
    Install-Module -Name Az -AllowClobber -Force
    Write-Host "Az module installed"
}

# And the same for the Entra ID module
if (-not (Get-Module -Name Microsoft.Graph.Entra -ListAvailable)) {
    Write-Host "Microsoft.Graph.Entra module not found, installing..."
    Install-Module -Name Microsoft.Graph.Entra -Repository PSGallery -AllowPrerelease -AllowClobber -Force
    Write-Host "Microsoft.Graph.Entra module installed"
}

# Sign in to Entra
Connect-Entra -Scopes "User.ReadWrite.All"

# Sign in to Azure
az config set core.allow_broker=true
az login --scope https://graph.microsoft.com//.default

# Set the subscription, can remove this bit for the Azure Pass deployment
# az account set -n "<FILL THIS IN IF YOU GOT MULTIPLE SUBS>"


# Loop through the number of participants, creating user accounts and resource groups, and then the ARM deployment
for ($i = 1; $i -le $participantCount; $i++) {
    $userNumber = "{0:D2}" -f $i
    $participantName = $participantPrefix + $userNumber
    $userPrincipalName = "$participantName@$directoryName"

    # Check if the user account already exists
    $user = Get-EntraUser -UserId $userPrincipalName -ErrorAction SilentlyContinue
    if ($user) {
        Write-Host "User account already exists: $participantName"
    } else {
        Write-Host "Creating user account: $participantName"
        # Create the user account in the Entra ID directory
        $passwordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
        $passwordProfile.Password = $userPassword
        $passwordProfile.ForceChangePasswordNextSignIn = $false
        $userParams = @{
            DisplayName = $participantName
            PasswordProfile = $passwordProfile
            UserPrincipalName = $userPrincipalName
            AccountEnabled = $true
            MailNickName = $participantName
        }
        New-EntraUser @userParams
        Write-Host "User account created: $participantName"
    }

    # Create the resource group in the Azure subscription
    $resourceGroupName = $participantName + "-rg"
    az group create --name $resourceGroupName --location $location
    Write-Host "Resource group created: $resourceGroupName"

    # Get the resource group ID
    $resourceGroupId = az group show --name $resourceGroupName --query id --output tsv

    # Deploy the ARM template to the resource group with default parameters
    Write-Host "Deploying ARM template to resource group: $resourceGroupName. Will probably take around 20 mins or so..."
    az deployment group create --resource-group $resourceGroupName --template-file ./ARM/azuredeploy.json
    Write-Host "Deployment has completed for resource group: $resourceGroupName"

    $user = Get-EntraUser -UserId $userPrincipalName -ErrorAction SilentlyContinue
    if ($user) {
        # Assign the user account as the owner of the resource group
        az role assignment create --role "Owner" --assignee $userPrincipalName --scope $resourceGroupId
    }
    else {
        Write-Host "Unable to find user: $userPrincipalName"
    }
}

# Get the current subscription ID
$subscriptionId = az account show --query id --output tsv

# Create a service principal to be shared with the participants
az ad sp create-for-rbac --name "Arc server onboarding account" --role "Azure Connected Machine Onboarding" --scopes "/subscriptions/$subscriptionId"

Write-Host "All done."