############################################################################################################################################
#Script that allows to get the site collections in a SPO Tenant using CSOM
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Administration Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the list of site collections in the tenant using CSOM
function Get-SPOTenantSiteCollections
{
    param ($sSiteUrl,$sUserName,$sPassword)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the Tenant Site Collections" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies        
        Add-Type -Path "C:\Users\JuanCarlos\Desktop\89 SPS Barcelona\Demos\05 SPO\DLLs\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "C:\Users\JuanCarlos\Desktop\89 SPS Barcelona\Demos\05 SPO\DLLs\Microsoft.SharePoint.Client.Runtime.dll"
        Add-Type -Path "C:\Users\JuanCarlos\Desktop\89 SPS Barcelona\Demos\05 SPO\DLLs\Microsoft.Online.SharePoint.Client.Tenant.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUsername, $sPassword)  
        $spoCtx.Credentials = $spoCredentials
        $spoTenant= New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($spoCtx)
        $spoTenantSiteCollections=$spoTenant.GetSiteProperties(0,$true)
        $spoCtx.Load($spoTenantSiteCollections)
        $spoCtx.ExecuteQuery()
        
        #We need to iterate through the $spoTenantSiteCollections object to get the information of each individual Site Collection
        foreach($spoSiteCollection in $spoTenantSiteCollections){
            
            Write-Host "Url: " $spoSiteCollection.Url " - Template: " $spoSiteCollection.Template " - Owner: "  $spoSiteCollection.Owner
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://nuberosnet-admin.sharepoint.com/" 
$sUserName = "jcgonzalez@nuberosnet.onmicrosoft.com" 
#Required Parameters
#$sSiteUrl = "https://fiveshareit-admin.sharepoint.com/" 
#$sUserName = "juancarlos.gonzalez@fiveshareit.es" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
#$sPassword=convertto-securestring "<User_Password>" -asplaintext -force

Get-SPOTenantSiteCollections -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword