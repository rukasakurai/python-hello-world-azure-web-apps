@description('The location into which all resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the App Service Plan.')
param appServicePlanName string = 'plan-${uniqueString(resourceGroup().id)}'

@description('The name of the Web App.')
param webAppName string = 'app-${uniqueString(resourceGroup().id)}'

@description('The SKU of the App Service Plan.')
param skuName string = 'S1'

// Import public module for App Service Plan
module appServicePlanModule 'br/public:avm/res/web/serverfarm:0.2.4' = {
  name: 'appServicePlanModule'
  params: {
    name: appServicePlanName
    location: location
    kind: 'Linux'
    skuName: skuName
  }
}

// Import public module for Web App
module webAppModule 'br/public:avm/res/web/site:0.9.0' = {
  name: 'webAppModule'
  params: {
    tags: { 'azd-service-name': 'web' }
    kind: 'app,linux'
    name: webAppName
    serverFarmResourceId: appServicePlanModule.outputs.resourceId
    location: location
    siteConfig: {
      linuxFxVersion: 'PYTHON|3.11'
    }
    appSettingsKeyValuePairs: {
      ENABLE_ORYX_BUILD: 'False'  // Disable automatic Oryx build process during deployment to improve speed
      SCM_DO_BUILD_DURING_DEPLOYMENT: 'False' // Disable build during deployment to improve speed
    }
  }
}

output webAppUrl string = 'https://${webAppName}.azurewebsites.net'
