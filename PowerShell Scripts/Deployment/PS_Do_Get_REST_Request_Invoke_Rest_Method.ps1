############################################################################################################################################
# Script that allows to get the items in a SharePoint Contact List using REST API and Invoke-RestMethod cmdlet
# Required Parameters:
#  -> $sUserName: User that is going to make the REST request.
#  -> $sPassword: User password.
#  -> $sRESTUrl: REST Url.
#  -> $WebRMehod: WebRequestMethod method to be used.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that makes the REST request
function Get-SPListsItemsUsingRESTAPI
{
    param ($sRESTUrl,$sUserName,$sPassword,$WebRMethod,$sListName,$hHeaders)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Getting all the list elements of $sListName using REST" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        $sSecPassword=ConvertTo-SecureString $sPassword -AsPlainText -Force        
        $spCredentials = New-Object System.Management.Automation.PSCredential($sUserName, $sSecPassword)
        $spRESTResults=Invoke-RestMethod -Uri $sRESTUrl -Credential $spCredentials -Method $WebRMethod -Headers $hHeaders
        $spRESTResultsCorrected = $spRESTResults  -creplace '"Id":','"Fake-Id":'
        $spResults = $spRESTResultsCorrected | ConvertFrom-Json
        $spListItems=$spResults.d.results
        Write-Host "Consultando los datos de la lista $sListName" -ForegroundColor Green
        foreach($spListItem in $spListItems){
            Write-Host "Name: " $spListItem.FirstName " " $spListItem.Title " - Company: " $spListItem.Company " - E-Mail: " $spListItem.Email -ForegroundColor Green
        }        
               
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sUserName = "<Dominio>\<Usuario>" 
$sPassword ="<Password>"
$WebRMethod=[Microsoft.PowerShell.Commands.WebRequestMethod]::Get
$sListName="Autores"
$hHeaders= @{
            "accept" = "application/json;odata=verbose"
            }
$sSiteUrl="http://<Url_Sitio>"
$sRESTUrl=$sSiteUrl + "/_api/lists/GetByTitle('" + $sListName + "')/items?$select=Title,FirstName,Company,Email"
#Calling the function
Get-SPListsItemsUsingRESTAPI -sRESTUrl $sRESTUrl -sListName $sListName -sUserName $sUserName -sPassword $sPassword -WebRMethod $WebRMethod -hHeaders $hHeader