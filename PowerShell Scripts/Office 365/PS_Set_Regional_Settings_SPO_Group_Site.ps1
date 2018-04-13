############################################################################################################################################
# Script that allows to change regional settings on SPO Site
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site.
#  -> $sTimezoneValue: Time Zone.
#  -> $ilocaleid: Locale ID.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to change regional settings on a SPO Site
function Change-RegionalSettings
{
    param ($sSiteUrl,$sUserName,$sPassword,$sCSOMPath,$sTimezoneValue,$ilocaleid)
    try
    {   

        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Updating Regional Settings for $sSiteUrl" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
     
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"
                     
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath        

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 

        $spoTimeZones = $spoCtx.Web.RegionalSettings.TimeZones       
        $spoCtx.Load($spoTimeZones)
        $spoCtx.ExecuteQuery()
        $spoTimeZone = $spoTimeZones | Where {$_.Description -eq $sTimezoneValue}
        $spoRegionalSettings = $spoCtx.Web.RegionalSettings
        $spoRegionalSettings.TimeZone = $spoTimeZone
        $spoRegionalSettings.Localeid = $ilocaleid
        $spoCtx.Web.Update()
        $spoCtx.ExecuteQuery()

    }
    catch [System.Exception]
    {
        Write-Hoste -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSiteUrl="https://<Your_SPO_Site>"
$sUserName = "<Office365_User>" 
$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString 
$sTimezoneValue= "(UTC+01:00) Brussels, Copenhagen, Madrid, Paris"
$ilocaleid = 1033 
$sCSOMPath="F:\03 Docs\07 MVP\03 MVP Work\11 PS Scripts\Office 365\SPO CSOM\Dec 2016"

Change-RegionalSettings -sSiteUrl $sSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath -sTimeZoneValue $sTimezoneValue -iLocaleID $ilocaleid