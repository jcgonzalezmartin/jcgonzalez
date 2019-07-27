############################################################################################################################################
# Script that allows to update the Storage Quota Warning Level to all the sites joined to a specific Hub Sute
# Required Parameters:
#  -> $sSPOAdminCenterUrl: SharePoint Admin Center Url.
#  -> $sHubSiteId: SHub Site Id.
#  -> $iQuotaPercentaje: New Storage Quota Warning Percentaje.
############################################################################################################################################

#Definition of the function that updates the Quota Warning Level for all the sites joined to a specific Hub
function Update-QuotaWarningLevelHubJoinedSites
{
    param ($sSPOAdminCenterUrl,$sHubSiteId,$iQuotaPercentaje)
    try
    {   
        #Connect-SPOService -Url $sSPOAdminCenterUrl
        $SPOHubSite=Get-SPOHubSite -Identity $sHubSiteId
        $sSPOHubSiteUrl=$SPOHubSite.SiteUrl
        Write-Host "-------------------------------------------------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Updating the Storage Quota Warning Level for the sites joined to the Hub $sHubSiteId - $sSPOHubSiteUrl" -ForegroundColor Green
        Write-Host "-------------------------------------------------------------------------------------------------------------------"  -ForegroundColor Green
        
        $SPOSites = Get-SPOSite -Limit ALL 
        foreach ($SPOSite in $SPOSites) {
            $SPOSiteDetailed = Get-SPOSite -Detailed $SPOSite.Url
            #We check if the Site is joined to the Hub Site
            if($SPOSiteDetailed.HubSiteId -eq $sHubSiteId){
            	$SPOSite.Url + " - Storage Quota: " + $SPOSite.StorageQuota + " New Storage Quota warning Level: " + $SPOSite.StorageQuota*$iQuotaPercentaje
		        $SPOStorageQuotaWarningLevel=$SPOSite.StorageQuota*$iQuotaPercentaje
		        Set-SPOSite -Identity $SPOSite -StorageQuotaWarningLevel $SPOStorageQuotaWarningLevel	
            }
        } 
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$sHubSiteId="Hub Site Id"
$iQuotaPercentaje=0.85

Update-QuotaWarningLevelHubJoinedSites -sSPOAdminCenterUrl $sSPOAdminCenterUrl -sHubSiteId $sHubSiteId -iQuotaPercentaje $iQuotaPercentaje
