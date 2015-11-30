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
function Load-ItemsSPOListFromCSV
{
    param ($sCSOMPath,$sSiteUrl,$sUserName,$sPassword,$sListName,$sInputFile)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblItems = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -foregroundcolor Red
            exit 
        }
        
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
        Write-Host "Adding items to List $sListName from CSV File $sInputFile !!" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green        

        $spoList = $spoCtx.Web.Lists.GetByTitle($sListName)
        $spoCtx.Load($spoList)
        foreach ($sItem in $tblItems) 
        {
            Write-Host "Adding " $sItem.SPOListItem " to $sListName"
            $spoListItemCreationInformation = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
            $spoListItem=$spoList.AddItem($spoListItemCreationInformation)
            $spoListItem["Title"]=$sItem.SPOListItem.ToString()
            $spoListItem.Update()
            $spoCtx.ExecuteQuery()            
        } 
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
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\<CSV_File_Name>.csv"

Load-ItemsSPOListFromCSV -sCSOMPath $sCSOMPath -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sListName $sListName -sInputFile $sInputFile

