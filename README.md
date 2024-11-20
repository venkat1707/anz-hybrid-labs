# ANZ Modern Hybrid Management and Governance Hands-On Labs [Nov - Dec 2024]
Welcome!

## Instructions for lab participants
Your lab instructor will share login credentials to be used to access the lab environment via the Azure portal.

Please follow the instrucitons here to complete the lab modules:
[Guide](Guide/_index.md)


## Information for lab instructors
To setup an Azure Pass subscription for use with multiple lab participants, run the [hybrid-labs-prep.ps1](./hybrid-labs-prep.ps1) script. For the number of participants specified, the script will:
1. Create a user account in the Entra ID directory
2. Create a resource group in the Azure subscription
3. Assign the user account as the owner of the resource group
4. Deploy the ARM template to the resource group with default parameters

The script will also regsiter the required resource providers, and create a service principal to be used for module 1 (Arc-enabled server onboarding). The service principal sceret will be written to a file called `arc-server-onboarding-spn.json`. Please take note of this and share the service principal secret with lab participants for use in module 1.


> This is a modified version of the following repo:
https://github.com/Azure/arc_jumpstart_levelup/tree/main
