############################################################################################################################################
# This Script allows to do CRUD operations at the Site Collection level
# Required Parameters:
#   ->$sOperationType: Operation Type.
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sSiteCollectionName: Site Collection Name.
#   ->$sOwner: Site Collection Owner.
#   ->$iLanguage: Site Collection Primary Language.
#   ->$sSiteTemplate: Site Collection Template (applied when creating a Site Collection).
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good use of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to do CRUD operations at the Site Collection Level
function WorkWith-SiteCollections
{
    param ($sOperationType,$sSiteCollectionUrl,$sSiteCollectionName,$sOwner,$iLanguage,$sSiteTemplate)
    try
    {
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Site Collections in the Farm" -ForegroundColor Green
            Get-SPSite -Limit All

            }
        "Create"{
            Write-Host "Creating $sSiteCollectionUrl Site Collection..." -ForegroundColor Green            
            New-SPSite -Url $sSiteCollectionUrl -Name $sSiteCollectionName -OwnerAlias $sOwner -Language $iLanguage -Template $sSiteTemplate
            Write-Host "Site Collection $sSitecollectionUrl successfully created!!!" -ForegroundColor Green
            }
        "Update"{            
            Write-Host "Updating $sSiteCollectionUrl Site Collection" -ForegroundColor Green
            $spSiteCollection = Get-SPSite -Identity $sSiteCollectionUrl
            $spSecondSiteCollectionAdministrator=$spSiteCollection.RootWeb.EnsureUser("<Secondary_Site_Collection_Administrator>")
            $spSiteCollection.SecondaryContact=$spSecondSiteCollectionAdministrator
            $spSiteCollection.Dispose()
            }
        "Delete"{
            Write-Host "Deleting $sSiteCollectionUrl  Site Collection..." -ForegroundColor Green
            Remove-SPSite -Identity $sSiteCollectionUrl -Confirm:$false
            Write-Host "Site Collection $sSiteCollectionUrl succcessfully removed from the Farm..." -ForegroundColor Green
            }
        default{
            Write-Host "Requested Operation is not Valid" -ForegroundColor Red
            }           
        }   
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}

# Required Parameters
$sSiteCollectionUrl="http://<Site_Collection_Url>"
$sSiteCollectionName="<Site_Collection_Name>"
$sOwner="<Site_Collection_Owner>"
$iLanguage=3082
$sSiteTemplate="STS#0"

Start-SPAssignment –Global
#Read
WorkWith-SiteCollections -sOperationType "Read"
#Create
WorkWith-SiteCollections -sOperationType "Create" -sSiteCollectionUrl $sSiteCollectionUrl -sSiteCollectionName $sSiteCollectionName -sOwner $sOwner -iLanguage $iLanguage -sSiteTemplate $sSiteTemplate
#Update
WorkWith-SiteCollections -sOperationType "Update" -sSiteCollectionUrl $sSiteCollectionUrl
#Delete
WorkWith-SiteCollections -sOperationType "Delete" -sSiteCollectionUrl $sSiteCollectionUrl
#Read
WorkWith-SiteCollections -sOperationType "Read"

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell