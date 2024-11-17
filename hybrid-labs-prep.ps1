<#

Script to prepare the Azure Pass subscription for multiple participants.

For the number of participants specified, the script will:
1. Create a user account in the Entra ID directory
2. Create a resource group in the Azure subscription
3. Assign the user account as the owner of the resource group
4. Deploy the ARM template to the resource group with default parameters

Use PowerShell version 7+

#>

# Variable for the participant count
$participantCount = 3

# Variable for the participant prefix
$participantPrefix = "hybrid-"

# Variable for the default user password
$userPassword = "Password123!"

# Variable for the Entra ID directory name
$directoryName = "danzig.live"

# Variable for the Azure region to deploy resources
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
az account set -n "MSFT Demo Time"


# Loop through the number of participants, using double digits for the user number
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
    Write-Host "Resource group ID: $resourceGroupId"

    # Assign the user account as the owner of the resource group
    az role assignment create --role "Owner" --assignee $userPrincipalName --scope $resourceGroupId

}

Write-Host "All done."