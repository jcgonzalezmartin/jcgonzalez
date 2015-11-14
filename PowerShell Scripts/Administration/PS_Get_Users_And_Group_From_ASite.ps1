############################################################################################################################################
# Script that allows to get the users and groups in a SharePoint site
# Required parameters:
#   ->$sSiteCollectionUrl: Site Collection Url.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get the users and groups in a SharePoint site
function Get-UsersAndGroups
{  
    param ($sSiteCollectionUrl)
    try
    {   
        $spSite=Get-SPSite -Identity $sSiteCollectionUrl
        $spWeb=$spSite.OpenWeb()
        Write-Host "*******************************************************************" -ForegroundColor Green
        Write-Host "Users & Groups in $sSiteCollectionUrl" -ForegroundColor Green
        Write-Host "*******************************************************************" -ForegroundColor Green
        foreach ($spGroup in $spWeb.Groups)
        {
            Write-Host "Group Name: " $spGroup.Name -ForegroundColor Green
            foreach($spUser in $spGroup.Users)
            {
                Write-Host "  -> User Name: " $spUser.DisplayName " - User Login: " $spUser.LoginName
            }	           
        }
        $spWeb.Dispose()
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
$sSiteCollectionUrl="http://<Site_Collection_Url>"
Get-UsersAndGroups -sSiteCollectionUrl $sSiteCollectionUrl 
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell