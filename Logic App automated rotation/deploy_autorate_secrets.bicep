var location = 'westeurope'


resource Rotate_secrets 'Microsoft.Logic/workflows@2019-05-01' = {
  name: 'automationrenewsecrets' //change to name the logic app something diffrent
  tags: {
    placeholder: 'test'
  }
  location: location
  properties: loadJsonContent('Automation_rotate_secret.json')
}
