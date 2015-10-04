############################################################################################################################################
# Script that allows to set the quota storage for the ODFB assigned to each user in an Office 365 tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPOODFBHostUrl: SharePoint ODFB Host URL.
#  -> $iODFBQuota: Quota to be set for ODFB.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that sets the quota storage for all the ODFBs in an Office 365 tenant
function Set-OneDriveFBQuotaStorage
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPOODFBHostUrl,$iODFBQuota)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Setting the Quota Storage for all the ODFBs in an Office 365 tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        $msolCred = Get-Credential -UserName $sUserName -Message $sMessage
        Connect-MsolService -Credential $msolCred
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred 
        $spoUsers=Get-MsolUser        
        ForEach ($spoUser in $spoUsers){
            ForEach ($O365Plan in $spoUser.Licenses.ServiceStatus){
                if (($O365Plan.servicePlan.servicename -like 'SharepointEnterprise') -and $O365Plan.ProvisioningStatus -eq 'Success')
                {                           
                    try{                        
                        $sODFBSite=$sSPOODFBHostUrl + $spoUser.UserPrincipalName.Replace(".","_").Replace("@","_")
                        Set-SPOSite –Identity $sODFBSite –StorageQuota $iODFBQuota
                        Write-Host "Storage Quota updated for: $sODFBSite"  -ForegroundColor Green  
               
                    }catch{
                        Write-Host "ODFB site for" + $spoUser.UserPrincipalName + " doesn't exist. Storage Quota not updated" -ForegroundColor Yellow            
                    }
                }
            }
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required parameters
$sUserName="<Office365User>@<Office365Domain>"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<Office365Domain>-admin.sharepoint.com/"
$sSPOODFBHostUrl="https://<Office365Domain>-my.sharepoint.com/personal/"
$iODFBQuota=512000

Set-OneDriveFBQuotaStorage -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOODFBHostUrl $sSPOODFBHostUrl -iODFBQuota $iODFBQuota
