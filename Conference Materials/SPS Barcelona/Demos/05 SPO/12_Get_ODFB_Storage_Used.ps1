############################################################################################################################################
# Script that allows to get the storage space being used in ODFB for everyuser in an Office 365 tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url
#  -> $sSPOODFBHostUrl: SharePoint ODFB Host URL
############################################################################################################################################



$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the storage space being used in ODFB for everyuser in an Office 365 tenant
function Get-OneDriveFBUsedSpace
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPOODFBHostUrl)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all storage space being used by end users in ODFB in an Office 365 tenant" -foregroundcolor Green
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
                        $spoODFBUrl=$sSPOODFBHostUrl + $spoUser.UserPrincipalName.Replace(".","_").Replace("@","_")
                        $spoODFB=Get-SPOSite -Identity $spoODFBUrl
                        $spoODFBUsedSpace=$spoODFB.StorageUsageCurrent
                        Write-Host "ODFB Site: " $spoUser.UserPrincipalName " - Storage (MB): " $spoODFBUsedSpace " MB"    
               
                    }catch{
                        [string]::Format("{0},N/A",$spoUser.UserPrincipalName)
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

#Connection to Office 365
$sUserName="<SPOUser>@<O365Domain>.es"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sSPOODFBHostUrl="https://<O365Domain>-my.sharepoint.com/personal/"

Get-OneDriveFBUsedSpace -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOODFBHostUrl $sSPOODFBHostUrl
