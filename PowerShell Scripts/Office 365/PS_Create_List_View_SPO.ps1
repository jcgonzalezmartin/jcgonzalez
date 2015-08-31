############################################################################################################################################
#Script that allows to create a new view in a SharePoint Online List
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site Url.
#  -> $sListName: Name of the list where the new view is going to be added.
#  -> $sViewName: Name of the view to be added.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a new view in a SharePoint Online list
function Create-NewListViewSPO
{
    param ($sSiteUrl,$sUserName,$sPassword,$sListName,$sViewName)
    try
    {    
        #Adding the Client OM Assemblies        
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.dll"
        Add-Type -Path "<CSOM_Path>\Microsoft.SharePoint.Client.Runtime.dll"

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl)
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials      

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding the View $sViewName to the List $sListName !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green        

        #Getting the list to be updated with a new view        
        $spoList=$spoCtx.Web.Lists.GetByTitle($sListName)
        $spoCtx.Load($spoList)

        #Defining the new List View
        $spoViewCreationInformation=New-Object Microsoft.SharePoint.Client.ViewCreationInformation
        $spoViewCreationInformation.Title=$sViewName
        $spoViewCreationInformation.ViewTypeKind= [Microsoft.SharePoint.Client.ViewType]::None        
        $spoViewCreationInformation.RowLimit=30
        $spoViewCreationInformation.SetAsDefaultView=$true        
        $spoViewCreationInformation.ViewFields=@("Title","Created","Modified")        

        #Getting the collection of views of the List
        $spoListViews=$spoList.Views
        $spoCtx.Load($spoListViews)             
        $spoCtx.ExecuteQuery()                
        $spListViewToAdd=$spoListViews.Add($spoViewCreationInformation)

        #Adding the view to the List
        $spoCtx.Load($spListViewToAdd)                
        $spoCtx.ExecuteQuery()
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "View $sViewName added to the List $sListName !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green  
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<O365Domain>.sharepoint.com/<SPO_Site>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
$sListName= "<SPO_List_Name>"
$sViewName="<SPO_View_Name>"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=convertto-securestring "<SPO_Password>" -asplaintext -force

Create-NewListViewSPO -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sListName $sListName -sViewName $sViewName

