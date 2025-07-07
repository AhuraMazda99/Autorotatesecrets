var location = 'westeurope'
param object_id string 
param TenantID string

resource Keyvaultstoresecrets 'Microsoft.KeyVault/vaults@2024-12-01-preview' = {
  name: 'keyvaultsecretautomation' //change to name the keyvault something diffrent
  location: location
  properties: {
    sku: {
      name:  'standard'
      family: 'A'
    }
    tenantId: TenantID
    accessPolicies: [
       {
        objectId: object_id
        permissions: {
          secrets: [
             'all'
          ]
        }
        tenantId: TenantID
       }
    ]
  }
}

