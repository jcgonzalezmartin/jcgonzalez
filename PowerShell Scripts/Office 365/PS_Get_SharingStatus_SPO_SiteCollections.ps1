############################################################################################################################################
# Script that allows to get the sharing status of all the SPO Site Collections in an Office 365 tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSharingCapability: Value of the Sharing Capability we want to check per Site Collection.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the sharing status for all the SPO Site Collections in an Office 365 tenant
function Get-SPOSharingStatus_SPO_Site_Collections
{
    param ($sSPOSharingCapability)
    try
    {   
        Write-Host "Getting al SPO Site Collections with Sharing Status equals to $sSPOSharingCapability" -ForegroundColor Green
        switch ($sSPOSharingCapability) 
        { 
        "Disabled" {
                Get-SPOSite |Where-Object {$_.SharingCapability -eq $sSPOSharingCapability}|select Url,SharingCapability
            }
        "Enabled"{
                Get-SPOSite |Where-Object {$_.SharingCapability -ne "Disabled"}|select Url,SharingCapability
            }
        "ExternalUserSharingOnly"{            
            Get-SPOSite |Where-Object {$_.SharingCapability -eq $sSPOSharingCapability}|select Url,SharingCapability
            }
        "ExternalUserAndGuestSharing"{
            Get-SPOSite |Where-Object {$_.SharingCapability -eq $sSPOSharingCapability}|select Url,SharingCapability
            }
        default{
            Write-Host "Requested operation is not valid" -ForegroundColor Red
            }           
        }    

    }
    catch [System.Exception]
    {
        Write-Host -Foregroundcolor Red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sPassword="<O365Password>"
$sSecurePassword=ConvertTo-SecureString "" -asplaintext -force
$msolcred=New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $sUserName, $sSecurePassword
Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

#Sharing Capability Disabled
$sSPOSharingCapability="Disabled"        
#Get-SPOSharingStatus_SPO_Site_Collections -sSPOSharingCapability $sSPOSharingCapability

#Sharing Capability Enabled -> Two options: Enabled with external users & Enabled with external users + Guest links
$sSPOSharingCapability="Enabled"        
#Get-SPOSharingStatus_SPO_Site_Collections -sSPOSharingCapability $sSPOSharingCapability

#Sharing Capability Enabled -> Enabled with external users
$sSPOSharingCapability="ExternalUserSharingOnly"        
#Get-SPOSharingStatus_SPO_Site_Collections -sSPOSharingCapability $sSPOSharingCapability

#Sharing Capability Enabled -> Enabled with external users and Guest links
$sSPOSharingCapability="ExternalUserAndGuestSharing"        
#Get-SPOSharingStatus_SPO_Site_Collections -sSPOSharingCapability $sSPOSharingCapability