Param (
    [Parameter(Mandatory = $false)]
    [int] $ThresholdPercentage=50
)

# Import the Azure Consumption API:
Import-Module AzureRM.Consumption

# This is your Azure Run-As connection
$RunAsConnection = Get-AutomationConnection -Name "AzureRunAsConnection"         

# Logging in..
Add-AzureRmAccount `
    -ServicePrincipal `
    -TenantId $RunAsConnection.TenantId `
    -ApplicationId $RunAsConnection.ApplicationId `
    -CertificateThumbprint $RunAsConnection.CertificateThumbprint 

# ... and selecting the subscription that the automation connection belongs to:
Select-AzureRmSubscription -SubscriptionId $RunAsConnection.SubscriptionID  | Write-Verbose 

# What's our consumption this billing period?
$detail = Get-AzureRmConsumptionUsageDetail

# .. and the overall total consumption so far:
$aggregate=$detail | Measure-Object -Property PreTaxCost -Sum
# .. and the total consumption per *instance* (i.e. over all dates)
$serviceTotals = $detail | Group-Object -Property InstanceName

# This script is only relevant if the total consumption is 10 currency units or greater,
# to avoid false positives because of rounding errors.
if ($aggregate.Sum -gt 10) {

    # Loop through each service instance:
    foreach ($service in $serviceTotals) { `

        # Does this instance alone consume more than $ThresholdPercentage % of everything in
        # the subscription?
        if (($service.Group | Measure-Object -Property PreTaxCost -Sum).Sum -gt (0.01*$ThresholdPercentage*$aggregate.Sum)) {

            # Then post something funny on Slack about it.
            $data = @{
                "username"="Cost guard"
                "channel"="azure"
                "text"=":warning: The instance " + $service.Name + " has accumulated a cost of " + [int]($service.Group | Measure-Object -Property PreTaxCost -Sum).Sum
            } | ConvertTo-Json
            $output = Invoke-RestMethod -URI "https://hooks.slack.com/services/xxxxxxxxx/xxxxxxxxx/xxxxxxxxxxxxxxxxxxxxxxxx" -Method Post -Body $data -ContentType "application/json"

        }
    }
}
