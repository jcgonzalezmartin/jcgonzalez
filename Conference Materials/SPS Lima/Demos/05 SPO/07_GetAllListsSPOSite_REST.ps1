############################################################################################################################################
# Script that allows to get all the lists in a SharePoint Online site using REST
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sRESTUrl: API REST Url.
#  -> $WebRMehod: WebRequestMethod to use
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"


#Definition of the function that gets all the lists in a SharePoint Online Site using REST
function Get-SPListsUsingRESTAPI
{
    param ($sCSOMPath,$sRESTUrl,$sUserName,$sPassword, $WebRMethod)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting all the list in a SharePoint Online Site using REST" -foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
     
        #Adding the Client OM Assemblies
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"  
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"             
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath

        $spCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)
        $spWebRequest = [System.Net.WebRequest]::Create($sRESTUrl)
        $spWebRequest.Credentials = $spCredentials
        $spWebRequest.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")
        $spWebRequest.Accept = "application/json;odata=verbose"
        $spWebRequest.Method=$WebRMethod
        $spWebResponse = $spWebRequest.GetResponse()
        $spRequestStream = $spWebResponse.GetResponseStream()
        $spReadStream = New-Object System.IO.StreamReader $spRequestStream
        $spData=$spReadStream.ReadToEnd()
        #$spData
        $spResults = $spData | ConvertFrom-Json
        $spLists=$spResults.d.results
        foreach($spList in $spLists)
        {
            Write-Host $spList.Title " - " $spList.Description -ForegroundColor Green
        }                 
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sRESTUrl = "https://<SPO_Site>/_api/web/lists" 
$sUserName = "<SPO_User>" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$WebRMethod=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get
$sCSOMPath="G:\03 Docs\10 MVP\04 Eventos\91 SPS Lima\Demos\05 SPO\DLLs"

Get-SPListsUsingRESTAPI -sCSOMPath $sCSOMPath -sRESTUrl $sRESTUrl  -sUserName $sUserName -sPassword $sPassword -WebRMethod $WebRMethod
