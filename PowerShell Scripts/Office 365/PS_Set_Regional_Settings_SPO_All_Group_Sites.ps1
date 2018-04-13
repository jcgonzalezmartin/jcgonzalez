############################################################################################################################################
# Script that allows to change regional settings for all the Office 365 Groups sites in a tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSiteUrl: SharePoint Online Site.
#  -> $sTimezoneValue: Time Zone.
#  -> $ilocaleid: Locale ID.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to change regional settings on SPO Site
function Change-RegionalSettings
{
    param ($sSiteUrl,$sUserName,$sPassword,$sCSOMPath,$sTimezoneValue,$ilocaleid)
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

        $spoTimeZones = $spoCtx.Web.RegionalSettings.TimeZones       
        $spoCtx.Load($spoTimeZones)
        $spoCtx.ExecuteQuery()
        $spoTimeZone = $spoTimeZones | Where {$_.Description -eq $sTimezoneValue}
        $spoRegionalSettings = $spoCtx.Web.RegionalSettings      
        $spoCtx.Load($spoRegionalSettings)
        $spoCtx.ExecuteQuery()        
        If ($spoRegionalSettings.LocaleId -ne $ilocaleid) {
            $spoRegionalSettingsValue=$spoRegionalSettings.LocaleId.ToString()
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            Write-Host "Updating Regional Settings from $spoRegionalSettingsValue to $ilocaleid" -ForegroundColor Green
            Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
            $spoRegionalSettings.TimeZone = $spoTimeZone
            $spoRegionalSettings.Localeid = $ilocaleid
            $spoCtx.Web.Update()
            $spoCtx.ExecuteQuery()
        }

    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Definition of the function that get the Groups Sites which local settings have to be updated
function Get-Office365GroupSites
{
   param ($Office365Credentials,$sUserName,$sPassword,$sCSOMPath,$sTimezoneValue,$ilocaleid)
    try
    {  
    $EXOSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell -Credential $Office365Credentials  -Authentication Basic -AllowRedirection 
    Import-PSSession $EXOSession
    $O365Groups = (Get-UnifiedGroup | ? {$_.SharePointSiteUrl -ne $Null} | Select SharePointSiteUrl, DisplayName, Alias)
    ForEach ($O365Group in $O365Groups) {  
         Write-Host "Processing" $O365Group.DisplayName "site" $O365Group.SharePointSite
             Change-RegionalSettings -sSiteUrl $O365Group.SharePointSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath -sTimeZoneValue $sTimezoneValue -iLocaleID $ilocaleid
         }
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

$sTimezoneValue= "(UTC+01:00) Brussels, Copenhagen, Madrid, Paris"
$ilocaleid = 1033 
$sCSOMPath="F:\03 Docs\07 MVP\03 MVP Work\11 PS Scripts\Office 365\SPO CSOM\Dec 2016"
$sUserName = "<Office365_User>"
$sMessage="Introduce your SPO Credentials"
$Office365Credentials = Get-Credential -UserName $sUserName -Message $sMessage
$sPassword= $Office365Credentials.GetNetworkCredential().Password | ConvertTo-SecureString -AsPlainText -Force 

Get-Office365GroupSites -Office365Credentials $Office365Credentials -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath -sTimezoneValue $sTimezoneValue -ilocaleid $ilocaleid


