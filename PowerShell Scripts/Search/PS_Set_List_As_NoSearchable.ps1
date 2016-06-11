############################################################################################################################################
# Script that allows  to configure a list as not searchable
# Required Parameters:
#   ->$sSiteUrl: Site Url.
#   ->$sListName: List Name.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performacne
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to configure a list as not searchable
function Set-SiteListAsNoSearchable
{
    param ($sSiteUrl,$sListName)
    try
    {
        $spWeb=Get-SPWeb -Identity $sSiteUrl        
        $splList = $spWeb.Lists.TryGetList($sListName)
        If(($splList))
        {
            Write-Host "Set $sListName as not searchable" -ForegroundColor Green
            $splList.NoCrawl = $True
            $splList.Update()
        }
        else{
            Write-Host "List $sListName doesn't exist ..." -ForegroundColor Red
        }
        $spWeb.Dispose()        
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

# Required Parameters
$sSiteUrl="http://<Site_Url>/"
$sListName="<List_Name>"
Start-SPAssignment –Global
Set-SiteListAsNoSearchable -sSiteUrl $sSiteUrl -sListName $sListName
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell