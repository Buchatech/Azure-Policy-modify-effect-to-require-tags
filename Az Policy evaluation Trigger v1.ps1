<# 
****Note:
It is recommended to run from Azure Cloud Shell.
If not running from Cloud Shell be sure to log into Azure with Connect-AzAccount.
#>

# Azure Login:
$account = Get-AzContext
if ($null -eq $account.Account) {
    Write-Output(" Azure account context not found, please login")
    Connect-AzAccount
}

<# 
****Note:
If running from Azure Cloud Shell run everything after this comment.
#>

# Get your Azure Subscriptions and set in variable
$subscriptions = Get-AzSubscription
$subscriptionids = $subscriptions.Id

# Set Azure subscriptions
foreach($subscriptionids in $subscriptionids){
    Set-AzContext -Subscription $subscriptionids

$azContext = Get-AzContext
$azProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object -TypeName Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient -ArgumentList ($azProfile)
$token = $profileClient.AcquireAccessToken($azContext.Subscription.TenantId)
$authHeader = @{
    'Content-Type'='application/json'
    'Authorization'='Bearer ' + $token.AccessToken
}

# Define the REST API to communicate with
# Use double quotes for $restUri as some endpoints take strings passed in single quotes

# Use to target All Subscriptions you use:
$restUri = "https://management.azure.com/subscriptions/$subscriptionids/providers/Microsoft.PolicyInsights/policyStates/latest/summarize?api-version=2018-04-04"

# Use to target a resource group:
# Prompt for Resource Group Name
# $ResourceGroup = Read-host 'Input the name of the resource group to evaluate.'

# $restUri = "https://management.azure.com/subscriptions/$SubscriptionIds/resourceGroups/$ResourceGroup/providers/Microsoft.PolicyInsights/policyStates/latest/triggerEvaluation?api-version=2018-07-01-preview"
 

# Invoke the REST API
$response = Invoke-RestMethod -Uri $restUri -Method POST -Headers $authHeader

# View the response object (as JSON)
$response
}