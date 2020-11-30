############################################################################################################################################
# Script that allows to enable / disable syncrhonization option in a SharePoint Document Library
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site.
#  -> $sDocLibraryName: Name of the Document Library.
#  -> $sOperationType: Operation to be done (Enable / Disable).
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to enable/disable syncrhonization option in a SharePoint Document Library
function EnableDisable-SyncSPODocLibrary
{
    param ($sSiteUrl,$sUserName,$sPassword,$sCSOMPath,$sDocLibraryName,$sOperationType)
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
  
        $spoList = $spoCtx.Web.Lists.GetByTitle($sDocLibraryName)
        $spoCtx.Load($spoList)
        $spoCtx.ExecuteQuery()

        #Operation Type
        switch ($sOperationType) 
        { 
        "Enable" {
            Write-Host "Enabling syncrhonization for document library $sDocLibraryName" -ForegroundColor Green
            $spoList.ExcludeFromOfflineClient=$false
            }
        "Disable"{
            Write-Host "Disabling syncrhonization for document library $sDocLibraryName" -ForegroundColor Green
            $spoList.ExcludeFromOfflineClient=$true
            }
        default{
            Write-Host "Requested operation is not valid" -ForegroundColor Red
            }           
        }        
        $spoList.Update()
        $spoCtx.ExecuteQuery()
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
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
#$sPassword= ConvertTo-SecureString "<User_Password>" -AsPlainText -Force
$sCSOMPath="<CSOM_Path>"
$sDocLibraryName="<Doc_Library_Name>"
$sOperationType="Enable"
EnableDisable-SyncSPODocLibrary -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath -sDocLibraryName $sDocLibraryName -sOperationType $sOperationType