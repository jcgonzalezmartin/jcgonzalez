############################################################################################################################################
# This script recursively deletes all the sites inside a site collection. The site collection itself is not deleted.
# Required parameters
#   ->$sSiteCollectionUrl: Site Collection Url.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good use of PowerShell in terms of Performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to delete all the sites in a Site Collection
function Delete-Sites
{   
    param ($spWeb,$sSiteCollectionUrl)
    try
    { 
	#Getting all the sites under the current site        
        $spSubWebs = $spWeb.Webs

    	#We delete each site in the site collecion
        foreach($spSubWeb in $spSubWebs)
        {
            Delete-Sites -spWeb $spSubWeb -sSiteCollectionUrl $sSiteCollectionUrl       
            $spSubWeb.Dispose()
        }        
        #We check we are not dealing with the Sire Collection Root Site
        if($spWeb.Url -ne $sSiteCollectionUrl)        
        {
            Write-Host -ForegroundColor Green "Deleting Site $($spWeb.Url) ..." 
            Remove-SPWeb $spWeb -Confirm:$false
            Write-Host -ForegroundColor Green "Site $($spWeb.Url) deleted..." 
        }else
        {
            Write-Host -ForegroundColor Green "Root Site detected, it won't be deleted..."
        }
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}
#Main function to perform the recursive deletion
function Delete-AllSites
{
    param ($sSiteCollectionUrl)
    try
    {
        $spSite = Get-SPSite -Identity $sSiteCollectionUrl
        $spWeb = $spSite.OpenWeb()
        #Calling the function that deletes all the sites in the Site Collection
        if($spWeb -ne $null)
        {
            Delete-Sites -spWeb $spWeb -sSiteCollectionUrl $sSiteCollectionUrl
            $spWeb.Dispose()
        }
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }  
}


Start-SPAssignment –Global
$sSiteCollectionUrl="http://<Site_Collection_Url>"
Delete-AllSites -sSiteCollectionUrl $sSiteCollectionUrl
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell
