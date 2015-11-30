############################################################################################################################################
#Script that allows to create a new list in a SharePoint Online Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sCSOMPath: CSOM Assemblies Path.
#  -> $sSiteUrl: SharePoint Online Site Url.
#  -> $sListName: Name of the list we are going to create.
#  -> $sListDescription: List description.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to create a new view in a SharePoint Online list
function Create-NewListSPO
{
    param ($sCSOMPath,$sSiteUrl,$sUserName,$sPassword,$sListName,$sListDescription)
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

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Creating List $sListName in $sSiteUrl !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green        

        $spoWeb=$spoCtx.Web
        $spoListCreationInformation=New-Object Microsoft.SharePoint.Client.ListCreationInformation
        $spoListCreationInformation.Title=$sListName
        #https://msdn.microsoft.com/EN-US/library/office/microsoft.sharepoint.client.listtemplatetype.aspx
        $spoListCreationInformation.TemplateType=[int][Microsoft.SharePoint.Client.ListTemplatetype]::GenericList
        $spoList=$spoWeb.Lists.Add($spoListCreationInformation)
        $spoList.Description=$sListDescription
        $spoCtx.ExecuteQuery()

        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Lsita $sListName created in $sSiteUrl !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green  
        $spoCtx.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl = "https://<O365Domain>.sharepoint.com/<SPO_Site>"
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
$sListName= "<SPO_List_Name>"
$sListDescription="<List Description>"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=ConvertTo-SecureString "<SPO_Password>" -AsPlainText -Force
$sCSOMPath="<SPO_Path>"

Create-NewListSPO -sCSOMPath $sCSOMPath -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sListName $sListName -sListDescription $sListDescription

