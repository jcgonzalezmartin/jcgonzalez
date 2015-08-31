############################################################################################################################################
#Script that allows to get the site collections in a SPO Tenant using CSOM
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Administration Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the list of site collections in the tenant using CSOM
function Set-SPOSiteCollectionReadOnlyMode
{
    param ($sTenantUrl,$sSiteUrl,$sUserName,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the Tenant Site Collections" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.Online.SharePoint.Client.Tenant.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sTenantUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials
        $spoTenant= New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($spoCtx)
        $spoSiteCollectionProperties=$spoTenant.GetSitePropertiesByUrl($sSiteUrl,$true)
        $spoCtx.Load($spoSiteCollectionProperties)
        $spoCtx.ExecuteQuery()
        $spoSiteCollectionProperties.LockState="RedOnly"
        $spoSiteCollectionProperties.Update()
        $spoCtx.ExecuteQuery()
        #We need to iterate through the $spoTenantSiteCollections object to get the information of each individual Site Collection
<#
using (var clientContext = new ClientContext(tenantUrl)) {
    clientContext.Credentials = spoCredentials;
    var tenant = new Tenant(clientContext);
    var siteProperties = tenant.GetSitePropertiesByUrl(siteUrl, true);
    clientContext.Load(siteProperties);
    clientContext.ExecuteQuery();

    Console.WriteLine("LockState: {0}", siteProperties.LockState);

    siteProperties.LockState = "Unlock";
    siteProperties.Update();
    clientContext.ExecuteQuery();
}#>
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://nuberosnet.sharepoint.com/sites/SPSaturdayCol" 
$sTenantUrl = "https://nuberosnet-admin.sharepoint.com/" 
$sUserName = "jcgonzalez@nuberosnet.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "6805&DDT" -asplaintext -force

Set-SPOSiteCollectionReadOnlyMode -sTenantUrl $sTenantUrl -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword