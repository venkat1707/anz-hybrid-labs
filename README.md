Welcome!

This is a modified clone of the following repo:
https://github.com/Azure/arc_jumpstart_levelup/tree/main

Instructions are here:
[Guide](Guide/_index.md)

To setup an Azure Pass subscription for use with multiple lab participants, run the [hybrid-labs-prep.ps1](./hybrid-labs-prep.ps1) script. For the number of participants specified, the script will:
1. Create a user account in the Entra ID directory
2. Create a resource group in the Azure subscription
3. Assign the user account as the owner of the resource group
4. Deploy the ARM template to the resource group with default parameters
