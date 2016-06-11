############################################################################################################################################
# Script that allows  to configure a Site as not searchable
# Required Parameters:
#   ->$sSiteUrl: Site Url.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performacne
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to configure a Site as not searchable
function Set-SiteAsNoSearchable
{
    param ($sSiteUrl)
    try
    {
        $spWeb=Get-SPWeb -Identity $sSiteUrl        
        Write-Host "Set $sSiteUrl as not searchable" -ForegroundColor Green
        $spWeb.NoCrawl=$True
        $spWeb.Update()
        $spWeb.Dispose()        
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

# Required Parameters
$sSiteUrl="http://sp2013wsp1/sites/Reports/"
Start-SPAssignment –Global
Set-SiteAsNoSearchable -sSiteUrl $sSiteUrl -sListName $sListName
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell