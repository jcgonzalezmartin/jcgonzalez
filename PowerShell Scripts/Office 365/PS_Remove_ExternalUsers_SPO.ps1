############################################################################################################################################
# Script that allows to remove all the external users in a SharePoint Online Tenant.
# Required Parameters:
#  -> $iBatchSize: Value for the PageSize parameter in Remove-SPOExternalUsers.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"
if ((Get-Module Microsoft.Online.SharePoint.PowerShell).Count -eq 0) {
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    }

#Definition of the function that remove external users in a SharePoint Online Tenant.
function Remove-SPOExternalUsers
{
    param ($iBatchSize)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the external users in a SharePoint Online Tenant" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        $spoExternalUsers=Get-SPOExternalUser -Position 0 -PageSize $iBatchSize
        if($spoExternalUsers.Count -gt 0)
        {
            Write-Host "Deleting " $spoExternalUsers.Count " external users" -ForegroundColor Green
            foreach($spoExternalUser in $spoExternalUsers)
            {
                
                Write-Host "Deleting external user:" $spoExternalUser.DisplayName  "-" $spoExternalUser.Email                
                Remove-SPOExternalUser -UniqueIDs $spoExternalUser.UniqueId -Confirm:$false
            }
            
        }else{
            Write-Host "There are not external users to delete" -ForegroundColor Green
            exit
        }
        #Calling the function again
        Remove-SPOExternalUsers -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -iBatchSize $iBatchSize
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<spo_user>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
#Connecting to SPO
$msolcred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred 

$iBatchSize=50

Remove-SPOExternalUsers -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -iBatchSize $iBatchSize
