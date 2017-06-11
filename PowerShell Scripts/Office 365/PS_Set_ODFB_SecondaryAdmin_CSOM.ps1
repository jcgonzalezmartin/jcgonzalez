############################################################################################################################################
# Script that allows to set a secondary administrator for a specific user's ODFB.
# Required Parameters:
#  -> $sCSOMPath: CSOM Path.
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sPassword: User's password.
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sSPOODFBHostUrl: SharePoint ODFB Host URL.
#  -> $sSPODFBRelativePath: ODFB Relative Path.
#  -> $sSecondaryODFBdmin: Login of the secondary administrator to be added to the user's OneDrive.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that sets a secondary administrator for an specific ODFB using CSOM
function Set-OneDriveFBSecondaryAdministrator_CSOM
{
    param ($sCSOMPath,$sUserName,$sPassword,$sSPOAdminCenterUrl,$sSPOODFBHostUrl,$sSPODFBRelativePath,$sSecondaryODFBAdmin)
    try
    {   
    
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath       

        $sODFBSite=$sSPOODFBHostUrl + $sSPODFBRelativePath 

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sODFBSite)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials     
         
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Setting secondary ODFB Admin for $sUserName ODFB" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        
        $spoUser=$spoCtx.Web.EnsureUser($sSecondaryODFBAdmin)
        $spoUser.IsSiteAdmin=$true
        $spoUser.Update()
        $spoCtx.Load($spoUser)
        $spoCtx.ExecuteQuery()
        
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Secondary ODFB Admin successfully added to $sUserName ODFB" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------------"  -ForegroundColor Green
        
        $spoCtx.Dispose()

    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

$sCSOMPath="<SPO_Path>"

$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"

$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  

$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"

$sSPOODFBHostUrl="https://<O365Domain>-my.sharepoint.com/personal/"

$sSPODFBRelativePath="<O365User>_<O365Domain>_onmicrosoft_com"

$sSecondaryODFBAdmin="<O365User>@<O365Domain>.onmicrosoft.com"


Set-OneDriveFBSecondaryAdministrator_CSOM -sCSOMPath $sCSOMPath -sUserName $sUserName -sPassword $sPassword -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sSPOODFBHostUrl $sSPOODFBHostUrl -sSPODFBRelativePath $sSPODFBRelativePath -sSecondaryODFBAdmin $sSecondaryODFBAdmin