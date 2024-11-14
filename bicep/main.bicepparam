using 'main.bicep'

//param tenantId = ''

param windowsAdminUsername = 'arc-admin'

param windowsAdminPassword = 'HardPass123!'

param logAnalyticsWorkspaceName = 'arc-law'

param flavor = 'ITPro'

param deployBastion = true

param vmAutologon = true

param resourceTags = {
  Solution: 'jumpstart_arcbox'
} // Add tags as needed

//param namingPrefix = '' This looks to break things...
