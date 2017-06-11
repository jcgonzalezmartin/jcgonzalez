############################################################################################################################################
# Script that allows to set a secondary administrator for a specific user's ODFB.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPOODFBHostUrl: SharePoint ODFB Host URL.
#  -> $sSPODFBRelativePath: ODFB Relative Path.
#  -> $sSecondaryODFBdmin: Login of the secondary administrator to be added to the user's OneDrive.
############################################################################################################################################



$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that sets a secondary administrator for an specific ODFB
function Set-OneDriveFBSecondaryAdministrator
{
    param ($sUserName,$sMessage,$sSPOAdminCenterUrl,$sSPOODFBHostUrl,$sSPODFBRelativePath,$sSecondaryODFBAdmin)
    try
    {    
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Setting secondary ODFB Admin for $sUserName ODFB" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        $msolCred = Get-Credential -UserName $sUserName -Message $sMessage        
        Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolCred
        $sODFBSite=$sSPOODFBHostUrl + $sSPODFBRelativePath        

        #Set-SPOSite –Identity $sODFBSite -Owner $sSecondaryODFBAdmin 
        Set-SPOUser -Site $sODFBSite -LoginName $sSecondaryODFBAdmin -IsSiteCollectionAdmin $true       
        
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Secondary ODFB Admin successfully added to $sUserName ODFB" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"

$sMessage="Introduce your SPO Credentials"

$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"

$sSPOODFBHostUrl="https://<O365Domain>-my.sharepoint.com/personal/"

$sSPODFBRelativePath="<O365User>_<O365Domain>_onmicrosoft_com"

$sSecondaryODFBAdmin="<O365User>@<O365Domain>.onmicrosoft.com"

Set-OneDriveFBSecondaryAdministrator -sUserName $sUserName -sMessage $sMessage -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOODFBHostUrl $sSPOODFBHostUrl -sSPODFBRelativePath $sSPODFBRelativePath -sSecondaryODFBAdmin $sSecondaryODFBAdmin