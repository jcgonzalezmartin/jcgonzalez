############################################################################################################################################
# Script that allows to  get the storage space being used in Office 365 Video Channel
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPOO365VideoChannelUrl: Office 365 Video Channel Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the storage space being used in Office 365 Video Channel
function Get-Office365VideoChannelUsedSpace
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPOO365VideoChannelUrl)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the storage space being used by an Office 365 Video Channel" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        $msolCred = Get-Credential -UserName $sUserName -Message $sMessage        
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred 
        $spoO365VideoChannel=Get-SPOSite -Identity $sSPOO365VideoChannelUrl
        $spoO365VideoChannelUsedSpace=$spoO365VideoChannel.StorageUsageCurrent
        Write-Host "Office 365 Video Channel Site: " $sSPOO365VideoChannelUrl " - Storage being used (MB): " $spoO365VideoChannelUsedSpace " MB"     

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
$sSPOO365VideoChannelUrl="https://<O365Domain>.sharepoint.com/portals/<O365Video_Channel>"

Get-Office365VideoChannelUsedSpace -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOO365VideoChannelUrl $sSPOO365VideoChannelUrl
