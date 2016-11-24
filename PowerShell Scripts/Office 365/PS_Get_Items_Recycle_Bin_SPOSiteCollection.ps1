############################################################################################################################################
# Script that allows to get all the items in the recycle bin of a SPO Site Collection.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteCollectionUrl: SharePoint Online Site.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets all the items in the recycle bin of a SPO Site.
function Get-ItemsSPOSiteCollectionRecycleBin
{
    param ($sSiteCollectionUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Getting all items in the Recycle Bin of a SPO Site Collection" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
     
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"
                     
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath        

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteCollectionUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        #SPO Site Collection
        $spoSite = $spoCtx.Site
        #Recycle Bin Content for the user
        $spoRecycleBinItemCollection = $spoSite.RecycleBin
        $spoCtx.Load($spoRecycleBinItemCollection)
        $spoCtx.ExecuteQuery()
        foreach($spoRecycleBinItem in $spoRecycleBinItemCollection){
            Write-Host "Item:" $spoRecycleBinItem.Title "- Deleted By:" $spoRecycleBinItem.DeletedByName "- Deleted Date:" $spoRecycleBinItem.DeletedDate
        }
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteCollectionUrl = "https://<SPOSite_Collection_Url>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword= ConvertTo-SecureString "<O365Password>" -AsPlainText -Force
$sCSOMPath="<CSOM_Path>"

Get-ItemsSPOSiteCollectionRecycleBin -sSiteCollectionUrl $sSiteCollectionUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath