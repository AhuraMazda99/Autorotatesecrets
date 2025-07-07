# AutoSecretVault

This project demonstrates an automated approach for managing Azure service principal secrets. The Bicep templates deploy a Key Vault and Logic Apps that rotate and purge secrets on a schedule. After deployment, secrets are stored in the vault so that release pipelines can retrieve them when required.

## Prerequisites

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) with Bicep support (`az bicep install`)
- Permission to deploy resources in your Azure subscription
- A service principal or user object ID to grant initial Key Vault access

## Customization

The JSON definitions used by the Logic Apps contain default schedules and filters. You can modify `Automation_rotate_secret.json` and `Automation_delete_secret.json` to adjust the rotation frequency or define which applications are targeted.

Alternatively, make changes directly in the Logic App Designer after deployment.

---

## Logic App: `Automation_rotate_secret`

**Step: HTTP Get Token**  
Add a `client_id` and `client_secret` from an app registration that has these permissions:

- Application.ReadWrite.All  
- Directory.ReadWrite.All  
- User-PasswordProfile.ReadWrite.All  
- User.ReadWrite.All

**Step: HTTP 1 Get Application ID**  
Filter which service principals to rotate. Example:

```
https://graph.microsoft.com/v1.0/applications?$filter=startswith(displayName,'production') or startswith(displayName,'test') or startswith(displayName,'hotfix')&$select=id,displayName,appId

!! in logic apps Whitespaces must be encoded for URIs so the above needs to look like this https://graph.microsoft.com/v1.0/applications?$filter=startswith(displayName,%27production%27)%20or%20startswith(displayName,%27test%27)%20or%20startswith(displayName,%27hotfix%27)&$select=id,displayName,appId

```

Customize it to fit your naming convention. Start with a test service principal first.

**Step: HTTP Create New Secret**  
Set the `displayName` to define the secret name in the app registration.

**Step: HTTP Post Password to Key Vault**  
Use a managed identity (system or user-assigned) and make sure it has write access to the Key Vault.

**Slack Notifications (Optional)**  
You can replace or remove Slack steps that are at the end. Use email, Teams, or another alert method.

---

## Logic App: `Automation_delete_secret`

This works similarly to the rotation app:

- Use the same service principal and permissions for token retrieval.
- Match the application name filter to your rotation app.
- Add a failure alert at the end (email, Teams, or Slack).

---

## How It Works

1. **Key Vault Deployment**  
   `Keyvault.bicep` creates the vault. You grant initial access using an object ID. Then grant access to the Logic App’s managed identity.

2. **Logic Apps**  
   - `deploy_autorate_secrets.bicep`: Rotates secrets on a schedule  
   - `deploy_delete_secrets.bicep`: Deletes old secrets

3. **Secret Storage**  
   Add matching service principal names or prefixes as Key Vault secrets. Logic Apps handle the rotation and storage.

4. **Secret Retrieval**  
   Pipelines and applications retrieve secrets using the Key Vault URL and proper identity access.

---

## Deployment Steps

1. Deploy with:
   az deployment sub create \
     --location westeurope \
     --template-file Main.bicep \
     --parameters object_id_keyvault= <your-object-id-for-admin>

2. Add service principal prefixes to the Key Vault as secrets.

3. Assign a managed identity to the Logic App. Add it to the Key Vault access policy.

4. Provide the Key Vault URL to the rotation Logic App.

---

## Retrieve a Secret

```
az keyvault secret show --name <secret-name> --vault-name <vault-name>
```

Use the name that corresponds to the target service principal client_id.

---

## Future Improvement

Replace the service principal used for Microsoft Graph authentication with a managed identity to simplify the setup.
