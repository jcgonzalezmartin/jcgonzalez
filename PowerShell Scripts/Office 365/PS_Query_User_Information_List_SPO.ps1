############################################################################################################################################
# Script that allows to query the User Information List ina a SPO Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSPOSiteUrl: SharePoint Online Site Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to query the User Information List ina a SPO Site
function Query-UserInfoList
{
    param ($sSPOSiteUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    {            
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Querying SPO User Information List using CSOM" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
     
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"
                     
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath        

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSPOSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 
        $spoWeb=$spoCtx.Web;
        $spoUserInformationList=$spoWeb.SiteUserInfoList
        $spoCamlQuery=New-Object Microsoft.SharePoint.Client.CamlQuery
        $spoCamlQuery.ViewXml=""
        $spoUsersCollection=$spoCtx.LoadQuery($spoUserInformationList.GetItems($spoCamlQuery))
        $spoCtx.ExecuteQuery()
        foreach($spoUser in $spoUsersCollection){
            Write-Host "    -> User ID:" $spoUser.Id " - User Title:" $spoUser["Title"] " - User E-Mail:" $spoUser["EMail"]             
            }   
        
        $spoCtx.Dispose()
       
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSPOSiteUrl = "https://<SPOSite_Collection_Url>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword= ConvertTo-SecureString "<O365Password>" -AsPlainText -Force
$sCSOMPath="<CSOM_Path>"

Query-UserInfoList -sSPOSiteUrl $sSPOSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath