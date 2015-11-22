############################################################################################################################################
# Script that allows to configure a Document Library in a SharePoint Site
# Required Parameters:
#   ->$siteUrl: Site Url.
#   ->$sDocLibraryName: Document Library Name.
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to configure a Document Library in a SharePoint Site
function Configure-DocLibrary
{
    param ($sSiteUrl,$sDocLibrary)   
    try
    {
        $spSite = Get-SPSite -Identity $sSiteUrl
        $spWeb = $spSite.OpenWeb()        
        #Comprobamos que la Biblioteca existe
        $spDocLibrary=$spWeb.Lists.TryGetList($sDocLibrary)
        If (($spDocLibrary)) 
        {               
            Write-Host "Configuring Document Library $sDocLibrary" -ForegroundColor Green            
            $spDocLibrary.EnableModeration=$true
            $spDocLibrary.EnableVersioning=$true
            $spDocLibrary.EnableMinorVersions=$true
            $spDocLibrary.MajorVersionLimit=10
            $spDocLibrary.MajorWithMinorVersionsLimit=10
            $spDocLibrary.DraftVersionVisibility = 1
            $spDocLibrary.ForceCheckout = $true
            $spDocLibrary.Update()
        }else
        {
            Write-Host "Document Library $sDocLibrary doesn't exist ..." -ForegroundColor Red
            exit
        }        
        #Disposado de objetos
        $spWeb.Dispose()
        $spSite.Dispose()        
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
# Required Parameters
$sSiteUrl = “http://<Site_Url>/"
$sDocLibrary="<Document_Library_Name>"
Configure-DocLibrary -sSiteUrl $sSiteUrl -sDocLibrary $sDocLibrary
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell