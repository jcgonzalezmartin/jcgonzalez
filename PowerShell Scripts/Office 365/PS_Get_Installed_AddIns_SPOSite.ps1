############################################################################################################################################
# Script that allows to get all the Add-ins installed on a SPO Site.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the items in the recycle bin of a SPO Site.
function Get-InstalledAddInsOnSPOSite
{
    param ($sSiteUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    { 
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Getting all the Add-ins installed on the site $sSiteUrl" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
     
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"
                     
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath        

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 
  
        #Add-ins installed on the site
        $spoInstalledAddins=[Microsoft.SharePoint.Client.AppCatalog]::GetAppInstances($spoCtx,$spoCtx.Web)        
        $spoCtx.Load($spoInstalledAddins)
        $spoCtx.ExecuteQuery()
        foreach($spoInstalledAddin in $spoInstalledAddins){
            Write-Host "Add-in Name:" $spoInstalledAddin.Title "- Add-in Status:" $spoInstalledAddin.Status
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<O365_Domain>.sharepoint.com/sites/<SPOSite>/" 
$sUserName = "<O365User>@<O365_Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword= ConvertTo-SecureString "<User_Password>" -AsPlainText -Force
$sCSOMPath="<CSOM_Path>"

Get-InstalledAddInsOnSPOSite -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath