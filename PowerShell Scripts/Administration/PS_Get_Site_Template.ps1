############################################################################################################################################
# Script that allows to get the template of an existing SharePoint Site
# Required parameters: 
#   -> $sSiteCollectionUrl: Site Collection Url.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that gets the template for an existing site
function Get-SiteTemplate
{  
    param ($sSiteCollectionUrl)
    try
    {
        Write-Host "Getting the template used by $sSiteCollectionUrl"
	    $spsSite =  Get-SPSite -Identity $sSiteCollectionUrl
	    $spwWeb=$spsSite.OpenWeb()
	    Write-Host "Site Template: "  $spwWeb.WebTemplate  " - Site Template ID: " $spwWeb.WebTemplateId -ForegroundColor Green
	    $spwWeb.Dispose()
	    $spsSite.Dispose()

    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sSiteCollectionUrl="http://sp2016es2/"
Get-SiteTemplate -sSiteCollectionUrl $sSiteCollectionUrl
Stop-SPAssignment –Global

Remove-PsSnapin Microsoft.SharePoint.PowerShell