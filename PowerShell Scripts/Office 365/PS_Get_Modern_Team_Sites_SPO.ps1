############################################################################################################################################
# Script that allows to get all the modern Team Sites in a SPO Tenant
# Required Parameters:
#    ->$sSPOAdmin: SPO Administrator.
#    ->$sPassword: SPO Administrator Password.
#    ->$sSPOAdministrationUrl: SPO Admin Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get all the modern team sites in a SPO Tenant
function Get-SPOModernTeamSites
{
    param ($sSPOAdmin,$sPassword,$sSPOAdministrationUrl)
    try
    {
        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green
        Write-Host "List of Modern Team Sites in the SPO Tenant." -ForegroundColor Green
        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green

        $SPOCredentials= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sSPOAdmin, $sPassword
        Connect-SPOService -Url $sSPOAdministrationUrl -Credential $SPOCredentials
        Get-SPOSite -Template GROUP#0 -IncludePersonalSite:$false

        }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }  
}

$sSPOAdmin="<SPOUser>@<O365Domain>.onmicrosoft.com"
$sPassword=ConvertTo-SecureString "<User_Password>" -AsPlainText -Force
$sSPOAdministrationUrl="https://<O365Domain>-admin.sharepoint.com"

Get-SPOModernTeamSites -sSPOAdmin $sSPOAdmin -sPassword $sPassword -sSPOAdministrationUrl $sSPOAdministrationUrl
