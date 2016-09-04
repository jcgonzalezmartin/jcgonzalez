############################################################################################################################################
# Script that allows to work with SPO Data without entering any credentials, just using an App Security Principal registered in the SPO Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site Collection.
#  -> $sPassword: Password for the user.
#  -> $sMessage: Message to be shown when prompting for user credentials.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

# Referencia: http://www.wictorwilen.se/sharepoint-online-app-only-policy-powershell-tasks-with-acs
 
 function Get-ListaDataUsingAppPrincipal
{
    param ($sClientId,$sSecret,$sRedirecturi,$sUrl,$sDomain,$sIdentifier)
    try
    {    
        $realm = ""
        $headers = @{Authorization = "Bearer "} 

        #Retrieve realm (Tenant Id)
        try { 
            $x = Invoke-WebRequest -Uri "$($sUrl)_vti_bin/client.svc" -Headers $headers -Method POST -UseBasicParsing
        }
        catch {
            #401 Error
            $realm = $_.Exception.Response.Headers["WWW-Authenticate"].Substring(7).Split(",")[0].Split("=")[1].Trim("`"")
        }

        # Loading System.Web
        [System.Reflection.Assembly]::LoadWithPartialName("System.Web") | Out-Null
        #Building request to get Access Token
        $body = "grant_type=client_credentials"
        $body += "&client_id=" +[System.Web.HttpUtility]::UrlEncode($sClientId + "@" + $realm)
        $body += "&client_secret=" +[System.Web.HttpUtility]::UrlEncode($sSecret)
        $body += "&redirect_uri=" +[System.Web.HttpUtility]::UrlEncode($sRedirecturi)
        $body += "&resource=" +[System.Web.HttpUtility]::UrlEncode($sIdentifier + "/" + $sDomain + "@" + $realm)
        $or = Invoke-WebRequest -Uri "https://accounts.accesscontrol.windows.net/$realm/tokens/OAuth/2"-Method Post -Body $body -ContentType "application/x-www-form-urlencoded"
        $json = $or.Content | ConvertFrom-Json 

        #Showing Access  Token
        Write-Host "Access Token:" -ForegroundColor Green
        Write-Host
        $json

        #Request to be done using the Access Token
        $headers = @{
            Authorization = "Bearer " + $json.access_token;
            Accept ="application/json"
            }  
    
        #Showing headers
        Write-Host "Headers:" -ForegroundColor Green
        Write-Host
        $headers

        # REST Query
        Write-Host "REST Query Results:" -ForegroundColor Green
        Write-Host
        #Invoke-RestMethod: https://technet.microsoft.com/en-us/library/hh849971.aspx
        $spResults=Invoke-RestMethod -Uri "$($sUrl)_api/lists/GetByTitle('Contactos Curso Office 365')/Items" -Method Get -Headers $headers
        $spResults
        
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }    
}

#Variables
$sClientId = "d0d8db04-d26d-4391-b4b8-39eff19ee9b7"
$sSecret = "CxBL3Cnjop44sxx+ErITd8EgVyp7V8M+MjWFlt/T9oE=";
$sRedirecturi = "https://<SPO_Site_Url>"
$sUrl = "https://<SPO_Site_Url>"
$sDomain = "<SPO_Domain>.sharepoint.com"
$sIdentifier = "00000003-0000-0ff1-ce00-000000000000"

Get-ListaDataUsingAppPrincipal -sClientId $sClientId -sSecret $sSecret -sRedirecturi $sRedirecturi -sUrl $sUrl -sDomain $sDomain -sIdentifier $sIdentifier


