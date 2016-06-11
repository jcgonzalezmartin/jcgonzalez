############################################################################################################################################
#Script that allows to add a new Site Collection Administrator to an existing Site Collection. It is possible to add an individual user,
#a security group or an Office 365 Group as Site Collection Administrator
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sCSOMPath: CSOM Assemblies Path.
#  -> $sSiteUrl: SharePoint Online Site Url.
#  -> $sNewSiteCollectionAdministrator: New Site Collection Administrator to be added to the Site Collection.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add a new Site Collection Administrator to a SPO Site Collection
function Set-SPOSiteCollectionAdministrator
{
    param ($sCSOMPath,$sSiteUrl,$sUserName,$sPassword,$sNewSiteCollectionAdministrator)
    try
    {   
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath       

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "------------------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Addding $sNewSiteCollectionAdministrator as Site Collection Administartor in $sSiteUrl !!" -ForegroundColor Green
        Write-Host "------------------------------------------------------------------------------------------"  -foregroundcolor Green        

        $spoUser=$spoCtx.Web.EnsureUser($sNewSiteCollectionAdministrator)
        $spoUser.IsSiteAdmin=$true
        $spoUser.Update()
        $spoCtx.Load($spoUser)
        $spoCtx.ExecuteQuery()


        Write-Host "------------------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "$sNewSiteCollectionAdministrator added as Site Collection Administartor in $sSiteUrl !!" -ForegroundColor Green
        Write-Host "------------------------------------------------------------------------------------------"  -foregroundcolor Green    
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<O365Domain>.sharepoint.com/<SPO_Site>"
$sUserName = "<UserName><O365Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=ConvertTo-SecureString "<UserPassword>" -AsPlainText -Force
$sCSOMPath="<SPO_Path>"
$sNewSiteCollectionAdministrator="<UserLogin/SecurityGroupName/Office365GroupName"

Set-SPOSiteCollectionAdministrator -sCSOMPath $sCSOMPath -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sNewSiteCollectionAdministrator $sNewSiteCollectionAdministrator

