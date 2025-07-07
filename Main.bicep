param object_id_keyvault string //add a admin account to have access 
module keyvault 'Keyvault/Keyvault.bicep' = {
  name: 'keyvaultforsecrets'
   params: {
    object_id: object_id_keyvault
    TenantID: ''//add tenantID
  }
}
module automation_renew_secrets 'Logic App automated rotation/deploy_autorate_secrets.bicep' = {
  name: 'automation_renew_secrets'
}
module automation_delete_secrets 'Logic app delete old secrets/deploy_delete_secrets.bicep' = {
  name: 'automation_delete_old_secrets'
}
