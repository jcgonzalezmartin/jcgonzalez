############################################################################################################################################
# Script that allows to do CRUD operations at the Site Level
# Required Parameters:
#   ->$sOperationType: CRUD Operation to be done.
#   ->$sSiteCollectionUrl: Site Collection Url.
#   ->$sSiteUrl: Site Url.
#   ->$sSiteName: Site Name.
#   ->$iLanguage: Culture code to be used to create the site.
#   ->$sSiteTemplate: Site template.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good use of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to do CRUD operations at the Site level
function WorkWith-Sites
{
    param ($sOperationType,$sSiteCollectionUrl,$sSiteUrl,$sSiteName,$iLanguage,$sSiteTemplate)
    try
    {
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Sites under $sSiteCollectionUrl Site Collection" -ForegroundColor Green
            Get-SPWeb -Site $sSiteCollectionUrl
            }
        "Create"{
            Write-Host "Creating site $sSiteUrl ..." -ForegroundColor Green            
            New-SPWeb -Url $sSiteUrl -Name $sSiteName -Language $iLanguage -Template $sSiteTemplate -AddToTopNav:$true -UseParentTopNav:$true
            Write-Host "Site $sSiteUrl successfully created!!!" -ForegroundColor Green
            }
        "Update"{            
            Write-Host "Updating $sSiteUrl site" -ForegroundColor Green
            Set-SPWeb -Identity $sSiteUrl -Description "Site Description Updated"
            }
        "Delete"{
            Write-Host "Deleting $sSiteUrl site ..." -ForegroundColor Green
            Remove-SPWeb -Identity $sSiteUrl -Confirm:$false
            Write-Host "Site $sSiteUrl successfully deleted  ..." -ForegroundColor Green
            }
        default{
            Write-Host "Requested operation is not valid" -ForegroundColor Red
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
$sSiteUrl="http://<Site_Url>"
$sSiteName="<Site_Name>"
$iLanguage=1033
$sSiteTemplate="STS#0"
Start-SPAssignment –Global
#Read
WorkWith-Sites -sOperationType "Read" -sSiteCollectionUrl $sSiteCollectionUrl
#Create
WorkWith-Sites -sOperationType "Create" -sSiteCollectionUrl $sSiteCollectionUrl -sSiteUrl $sSiteUrl -sSiteName $sSiteName -iLanguage $iLanguage -sSiteTemplate $sSiteTemplate
#Update
WorkWith-Sites -sOperationType "Update" -sSiteUrl $sSiteUrl
#Delete
WorkWith-Sites -sOperationType "Delete" -sSiteUrl $sSiteUrl
#Read
WorkWith-Sites -sOperationType "Read" -sSiteCollectionUrl $sSiteCollectionUrl

Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell