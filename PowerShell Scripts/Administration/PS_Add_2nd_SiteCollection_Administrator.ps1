############################################################################################################################################
# Script that allows to add a 2º Site Collection Administrator in a Site Collecion
# Required Parametes:
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sSecondaryAdministrator: 2º Site Collection Administrator
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performances
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add a 2º Site Collection Administrator in a Site Collecion
function Add-SecondarySCAdministrator
{  
    param ($sSiteCollectionUrl,$sSecondarySCAdministrator)
    try
    {   
        Write-Host "Adding $sSecondarySCAdministrator as 2nd Site Collection Administrator in $sSiteCollectionUrl"
        Set-SPSite -Identity $sSiteCollectionUrl -SecondaryOwnerAlias $sSecondarySCAdministrator 
        $spSiteCollection=Get-SPSite -Identity $sSiteCollectionUrl
        Write-Host "Site Collection Administrator in $sSiteCollectionUrl " $spSiteCollection.Owner -ForegroundColor Green        
        Write-Host "2nd Site Collection Administrator in $sSiteCollectionUrl " $spSiteCollection.SecondaryContact -ForegroundColor Green
        $spSiteCollection.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sSiteCollectionUrl="http://<Url_Coleccion_Sitios>"
$sSecondarySCAdministrator="<2_Administrador>"
Add-SecondarySCAdministrator -sSiteCollectionUrl $sSiteCollectionUrl -sSecondarySCAdministrator $sSecondarySCAdministrator
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell