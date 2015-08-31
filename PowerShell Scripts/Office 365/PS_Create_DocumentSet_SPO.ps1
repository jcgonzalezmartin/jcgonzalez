############################################################################################################################################
#Script that creates a document set in SharePoint Online
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url
#  -> $sDocumentLibrary: Name of the document library where the Document Set is going to be created.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a Document Set in SharePoint Online
function Create-DocumentSetInSPO
{
    param ($sSiteUrl,$sUserName,$sPassword,$sDocLibraryName,$sDocumentSetName)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.Runtime.dll"
        Add-Type -Path "G:\03 Docs\10 MVP\03 MVP Work\11 PS Scripts\Office 365\Microsoft.SharePoint.Client.DocumentManagement.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Creating a Document Set in $sDocLibraryName !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green        
        
        $spoDocLibrary=$spoCtx.Web.Lists.GetByTitle($sDocLibraryName)
        $sRootFolder=$spoDocLibrary.RootFolder
        #Getting the Document Set Content Type by ID -> In this case we are using the default one in SPO
        $sDocSetContentType=$spoCtx.Site.RootWeb.ContentTypes.GetById("0x0120D520")        
        $spoCtx.Load($sDocSetContentType)                
        $spoCtx.ExecuteQuery()
        #Creating the Document Set in the target Doc. Library
        $spoDocumentSet=[Microsoft.SharePoint.Client.DocumentSet.DocumentSet]        
        $spoDocumentSet::Create($spoCtx,$sRootFolder,$sDocumentSetName,$sDocSetContentType.Id)        
        $spoCtx.ExecuteQuery()
        $spoCtx.Dispose()

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<O365Domain>.sharepoint.com/<Site_Relative_Path>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
$sDocLibraryName= "<DocLibraryName>"
$sDocumentSetName="<DocumentSetName>"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=ConvertTo-SecureString "<O365Password>" -asplaintext -force

Create-DocumentSetInSPO -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sDocLibraryName $sDocLibraryName -sDocumentSetName $sDocumentSetName

