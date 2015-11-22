############################################################################################################################################
# Script that allows to  get the storage space being used by an Office 365 Group
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPO365GroupFilesUrl: Office 365 Group Files Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the storage space being used by an Office 365 Group
function Get-Office365GroupUsedSpace
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPO365GroupFilesUrl)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the storage space being used by an Office 365 Group" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        $msolCred = Get-Credential -UserName $sUserName -Message $sMessage        
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred 
        $spoO365GroupFilesUrl=Get-SPOSite -Identity $sSPO365GroupFilesUrl
        $spoO365GroupFilesUsedSpace=$spoO365GroupFilesUrl.StorageUsageCurrent
        Write-Host "Office 365 Group Files Url: " $sSPO365GroupFilesUrl " - Storage being used (MB): " $spoO365GroupFilesUsedSpace " MB"     

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sSPO365GroupFilesUrl="https://<O365Domain>.sharepoint.com/sites/minioms"

Get-Office365GroupUsedSpace -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPO365GroupFilesUrl $sSPO365GroupFilesUrl
