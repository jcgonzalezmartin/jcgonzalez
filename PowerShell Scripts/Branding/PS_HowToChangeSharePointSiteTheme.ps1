############################################################################################################################################
# Script that allows to change the theme of a SharePoint Site
# Parameters:
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sSiteUrl: Site Url
#   ->$sTheme: Theme to be applied.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We do a well usage of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Function that changes the theme of a SharePoint Site
function Change-SiteTheme
{  
    param ($sSiteCollectionUrl,$sSiteUrl,$sTheme)
    try
    {    
        $spSiteCollection=Get-SPSite -Identity $sSiteCollectionUrl        
        $spDesignCatalog=$spSiteCollection.GetCatalog("Design")        
        Write-Host "Themes available in the $sSiteCollectionUrl Site Collection" -ForegroundColor Green
        $spDesignCatalog.Items | Format-Table Name
        $spTheme = $spDesignCatalog.Items | Where {$_.Name -eq $sTheme}
        Write-Host "Applying $sTheme theme to site $sSiteUrl" -ForegroundColor Green
        $spSite=Get-SPWeb -Identity $sSiteUrl
        $spSite.ApplyTheme($spTheme[“ThemeUrl”].Split(‘,’)[1].Trim(), $null, $null, $true) 
        Write-Host "$sTheme theme succcessfully applied to the site $sSiteUrl" -ForegroundColor Green
        $spSite.Dispose()
        $spSiteCollection.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sSiteCollectionUrl="http://<Site_Collection_Url>"
$sSiteUrl="http://<Site_Url>"
$sTheme="<Theme_Name>"
Change-SiteTheme -sSiteCollectionUrl $sSiteCollectionUrl -sSiteUrl $sSiteUrl -sTheme $sTheme
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell