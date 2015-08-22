############################################################################################################################################
# This script allows to create a managed path for a Web Application
# Required Parameters: 
#   -> $webApplicationIdentity: Web Application name.
#   -> $managedPath: Managed Path Name.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that creates the managed path
function Create-SPManagedPath
{
    if ($managedPath -ne $null)
    {
        Write-Host "The managed path $managedPathName already exists in the web application" -foregroundcolor Red
        Remove-SPManagedPath -Identity $managedPathName -WebApplication $webApplicationIdentity –confirm:$false 
        Write-Host "The managed path $managedPathName has been removed" -foregroundcolor Red        
    }    
    New-SPManagedPath –RelativeURL $managedPathName -WebApplication $webApplicationIdentity
    Write-Host "Managed path $managedPathName created succesfully" -foregroundcolor Green  
}

Start-SPAssignment –Global

#Required Objects
$webApplicationIdentity="SharePoint - 80"
$webApp=Get-SPWebApplication -Identity $webApplicationIdentity
$managedPathName="projects"
$managedPath=Get-SPManagedPath -WebApplication $webApp -Identity $managedPathName -ErrorAction SilentlyContinue

#Calling the function
Create-SPManagedPath
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell