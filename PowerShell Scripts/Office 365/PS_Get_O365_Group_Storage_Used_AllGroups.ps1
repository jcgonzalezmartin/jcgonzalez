############################################################################################################################################
# Script that allows to  get the storage space being used by all the Office 365 Groups in an Office 365 tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $smsolCred: Office 365 Credentials.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the storage space being used by all the Office 365 Groups in an Office 365 tenant
function Get-AllOffice365GroupsUsedSpace
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$msolCred)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Getting the storage space being used by all the Office 365 Groups in an Office 365 tenant" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green             
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred
        $spoO365GroupSites=Get-UnifiedGroup
        ForEach ($spoO365GroupSite in $spoO365GroupSites){
            If($spoO365GroupSite.SharePointSiteUrl -ne $null)
            {
                $spoO365GroupFilesSite=Get-SPOSite -Identity $spoO365GroupSite.SharePointSiteUrl
                $spoO365GroupFilesUsedSpace=$spoO365GroupFilesSite.StorageUsageCurrent
                Write-Host "Office 365 Group Files Url: " $spoO365GroupSite.SharePointSiteUrl " - Storage being used (MB): " $spoO365GroupFilesUsedSpace " MB"                   
            }     
        }
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Office 365 Groups cmdlets
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage
$msolSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $msolCred -Authentication Basic -AllowRedirection
Import-PSSession $msolSession
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"

Get-AllOffice365GroupsUsedSpace -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -msolCred $msolCred