############################################################################################################################################
# Script that allows to get all the items in the recycle bin of a SPO Site.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the items in the recycle bin of a SPO Site.
function Get-ItemsSPOSiteRecycleBin
{
    param ($sSiteUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Getting all items in the Recycle Bin of a SPO Site" -ForegroundColor Green
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

        #SPO Site
        $spoWeb = $spoCtx.Web
        #Recycle Bin Content for the user
        $spoRecycleBinItemCollection = $spoWeb.RecycleBin
        $spoCtx.Load($spoRecycleBinItemCollection)
        $spoCtx.ExecuteQuery()
        foreach($spoRecycleBinItem in $spoRecycleBinItemCollection){
            Write-Host "Item:" $spoRecycleBinItem.Title "- Deleted By:" $spoRecycleBinItem.DeletedByName "- Deleted Date:" $spoRecycleBinItem.DeletedDate
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://nuberosnet.sharepoint.com/sites/SPS%20Lima/" 
$sUserName = "agonzalez@nuberos.es" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
#$sPassword= ConvertTo-SecureString "<O365Password>" -AsPlainText -Force
$sCSOMPath="D:\03 Docs\07 MVP\03 MVP Work\11 PS Scripts\Office 365"

Get-ItemsSPOSiteRecycleBin -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath