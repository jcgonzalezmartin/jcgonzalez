############################################################################################################################################
# Script that allows to deploy a new theme to a SharePoint Online tenant
# Required Parameters:
#  -> $sThemeToDeploy: Theme to be deployed in the tenant.
#  -> $sSPOThemeName: Theme Name.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"
if ((Get-Module Microsoft.Online.SharePoint.PowerShell).Count -eq 0) {
    Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
    }

#Definition of the function that remove external users in a SharePoint Online Tenant.
function Deploy-SPOTheme
{
    param ($sThemeToDeploy,$sSPOThemeName)
    try
    {  
        Add-SPOTheme -Name $sSPOThemeName -Palette $sThemeToDeploy -IsInverted $false -Overwrite

        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Theme Deploying. Getting the list of Themes in the SPO Tenant" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Get-SPOTheme
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor red $_.Exception.ToString()   
    }    
}

#Connection to Office 365
$sUserName="<spo_user>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your SPO Credentials"
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sThemeToDeploy=@{
"themePrimary" = "#6a9e8b";
"themeLighterAlt" = "#070b0a";
"themeLighter" = "#131d19";
"themeLight" = "#2d463d";
"themeTertiary" = "#4e7869";
"themeSecondary" = "#639985";
"themeDarkAlt" = "#79a897";
"themeDark" = "#a0c1b5";
"themeDarker" = "#adcabf";
"neutralLighterAlt" = "#3f3b3a";
"neutralLighter" = "#474341";
"neutralLight" = "#544f4e";
"neutralQuaternaryAlt" = "#5d5755";
"neutralQuaternary" = "#635d5b";
"neutralTertiaryAlt" = "#807875";
"neutralTertiary" = "#631a0a";
"neutralSecondary" = "#aa2d11";
"neutralPrimaryAlt" = "#d93916";
"neutralPrimary" = "#e43c17";
"neutralDark" = "#f08168";
"black" = "#f2927d";
"white" = "#353231";
"primaryBackground" = "#353231";
"primaryText" = "#e43c17";
"bodyBackground" = "#353231";
"bodyText" = "#e43c17";
"disabledBackground" = "#474341";
"disabledText" = "#807875";
}
$sSPOThemeName="New Corporate SPO Theme (2)"

#Connecting to SPO
$Office365Cred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $Office365Cred 

Deploy-SPOTheme -sSPOThemeName $sSPOThemeName -sThemeToDeploy $sThemeToDeploy