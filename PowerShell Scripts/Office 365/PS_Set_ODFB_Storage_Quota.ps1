############################################################################################################################################
# Script that allows to set the quota storage for a specific user ODFB.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPOODFBHostUrl: SharePoint ODFB Host URL.
#  -> $sSPODFBRelativePath: ODFB Relative Path.
#  -> $iODFBQuota: Quota to be set for ODFB.
############################################################################################################################################



$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the storage space being used in ODFB for everyuser in an Office 365 tenant
function Set-OneDriveFBQuotaStorage
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPOODFBHostUrl,$sSPODFBRelativePath,$iODFBQuota)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Setting the Quota Storage for $sUserName ODFB" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        $msolCred = Get-Credential -UserName $sUserName -Message $sMessage        
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred
        $sODFBSite=$sSPOODFBHostUrl + $sSPODFBRelativePath        
        Set-SPOSite –Identity $sODFBSite –StorageQuota $iODFBQuota         
        
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Storage Quota sucessfully update for $sUserName ODFB" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
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
$sSPOODFBHostUrl="https://<O365Domain>-my.sharepoint.com/personal/"
$sSPODFBRelativePath="<O365User>_<O365Domain>_onmicrosoft_com"
$iODFBQuota=512000

Set-OneDriveFBQuotaStorage -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOODFBHostUrl $sSPOODFBHostUrl -sSPODFBRelativePath $sSPODFBRelativePath -iODFBQuota $iODFBQuota