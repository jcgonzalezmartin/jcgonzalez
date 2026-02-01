############################################################################################################################################
# Script that retrieves an inventory of all the Power Automate Flows in a Microsoft 365 tenant and exports the results to a CSV file.
# Required Parameters:
#  -> $sOutputFileName: Name of the CSV file to be generated with the flows inventory
# 
# Prerequisites:
#  -> Install the Power Platform PowerShell module: Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
#  -> Install the Power Platform PowerShell for Power Automate: Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that retrieves all Power Automate Flows from all environments in the tenant
function Get-PowerAutomateFlowsInventory
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$sOutputFileName
    )
    
    Try
    {
        Write-Host "Starting Power Automate Flows inventory..." -ForegroundColor Green
        
        # Initialize array to store all flows
        [array]$allFlows = @()
        
        # Get all environments in the tenant
        Write-Host "Retrieving all environments in the tenant..." -ForegroundColor Yellow
        $environments = Get-AdminPowerAppEnvironment
        
        if (@($environments).Count -eq 0)
        {
            Write-Host "No environments found in the tenant." -ForegroundColor Red
            return
        }
        
        Write-Host "Found $(@($environments).Count) environment(s). Processing flows..." -ForegroundColor Yellow
        
        # Loop through each environment
        foreach ($environment in $environments)
        {
            Write-Host "Processing environment: $($environment.DisplayName) ($($environment.EnvironmentName))" -ForegroundColor Cyan
            
            # Get all flows in the current environment
            $flows = Get-AdminFlow -EnvironmentName $environment.EnvironmentName
            
            if (@($flows).Count -eq 0)
            {
                Write-Host "  No flows found in this environment." -ForegroundColor Gray
                continue
            }
            
            Write-Host "  Found $(@($flows).Count) flow(s) in this environment." -ForegroundColor Green
            
            # Process each flow
            foreach ($flow in $flows)
            {
                $flowInfo = New-Object PSObject
                $flowInfo | Add-Member NoteProperty -Name "Flow Name" -Value $flow.FlowName
                $flowInfo | Add-Member NoteProperty -Name "Display Name" -Value $flow.DisplayName
                $flowInfo | Add-Member NoteProperty -Name "Environment Name" -Value $environment.DisplayName
                $flowInfo | Add-Member NoteProperty -Name "Environment ID" -Value $environment.EnvironmentName
                $flowInfo | Add-Member NoteProperty -Name "Enabled" -Value $flow.Enabled
                $flowInfo | Add-Member NoteProperty -Name "State" -Value $flow.Internal.properties.state
                $flowInfo | Add-Member NoteProperty -Name "Created Time" -Value $flow.CreatedTime
                $flowInfo | Add-Member NoteProperty -Name "Last Modified Time" -Value $flow.LastModifiedTime
                $flowInfo | Add-Member NoteProperty -Name "Creator" -Value $flow.CreatedBy.displayName
                $flowInfo | Add-Member NoteProperty -Name "Creator Email" -Value $flow.CreatedBy.email
                $flowInfo | Add-Member NoteProperty -Name "Trigger" -Value ($flow.Internal.properties.definitionSummary.triggers | Select-Object -First 1).type
                $flowInfo | Add-Member NoteProperty -Name "Flow Type" -Value $flow.Internal.properties.flowType
                
                $allFlows += $flowInfo
            }
        }
        
        # Export results to CSV
        if ($allFlows.Count -gt 0)
        {
            Write-Host "`nExporting $($allFlows.Count) flow(s) to CSV file: $sOutputFileName" -ForegroundColor Green
            $allFlows | Export-Csv -Path $sOutputFileName -NoTypeInformation -Encoding UTF8
            Write-Host "Inventory export completed successfully!" -ForegroundColor Green
            Write-Host "File saved at: $sOutputFileName" -ForegroundColor Green
        }
        else
        {
            Write-Host "No flows found in any environment." -ForegroundColor Yellow
        }
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red "Error occurred: $($_.Exception.Message)"
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

# Main script execution
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "Power Automate Flows Inventory Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Connection parameters
$sOutputFileName = "PowerAutomateFlowsInventory.csv"

# Connect to Power Platform
Write-Host "`nConnecting to Power Platform..." -ForegroundColor Yellow
Write-Host "Please provide your administrator credentials when prompted." -ForegroundColor Yellow

try
{
    # Add Power Platform account
    Add-PowerAppsAccount
    
    Write-Host "Connection established successfully!" -ForegroundColor Green
    
    # Get the flows inventory
    Get-PowerAutomateFlowsInventory -sOutputFileName $sOutputFileName
}
catch [System.Exception]
{
    Write-Host -ForegroundColor Red "Failed to connect to Power Platform: $($_.Exception.Message)"
    Write-Host -ForegroundColor Red "Please ensure you have the required PowerShell modules installed:"
    Write-Host -ForegroundColor Yellow "  Install-Module -Name Microsoft.PowerApps.Administration.PowerShell"
    Write-Host -ForegroundColor Yellow "  Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber"
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host "Script execution completed" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
