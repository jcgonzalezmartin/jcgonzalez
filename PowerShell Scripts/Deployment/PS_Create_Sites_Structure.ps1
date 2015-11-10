############################################################################################################################################
# Script that allows to create a sites structure reading all the data from a XML File
# Parameters:
#   ->$sSiteCollectionUrl: Site Collection URL.
#   ->$sSitesStructureFileName: XML Definition File.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Function that creates the XML Definition File with the Sites Structure
function Create-SiteStructureDefinition
{
    param ($sSitesStructureFileName)    
    try
    {
        Write-Host "Creating Sites Structure definition file" -ForegroundColor Green    
        "<Setup>
            <Sites>
                <TopSiteName>Site1</TopSiteName>
            </Sites>
            <Sites>
                <TopSiteName>Site2</TopSiteName>
                <SubSiteName>Subsite2a</SubSiteName>
                <SubSiteName>Subsite2b</SubSiteName>
            </Sites>
            <Sites>
                <TopSiteName>Site3</TopSiteName>
                <SubSiteName>Subsite3a</SubSiteName>
                <SubSiteName>Subsite3b</SubSiteName>
                <SubSiteName>Subsite3c</SubSiteName>
            </Sites>
        </Setup>" | Out-File $sSitesStructureFileName
        Write-Host "Sites Structure definition created successfully!!!" -ForegroundColor Green
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

#Definition of the function that creates the site structure reading the required information from a XML file
function Create-SitesStructure
{  
    param ($sSiteCollectionUrl,$sSiteTemplate,$sSitesStructureFileName)
    try
    {    
        [xml]$sSitesStructure = Get-Content $sSitesStructureFileName
        foreach ($sSite in $sSitesStructure.Setup.Sites){
            $sTopSite = $sSite.TopSiteName            
            $sSubSites = $sSite.SubSiteName            
            Write-Host "Creating Top Site $sTopSite" -ForegroundColor Green        
            New-SPWeb -Url $sSiteCollectionUrl/$sTopSite -Template $sSiteTemplate -AddToTopNav -UseParentTopNav -Name $sTopSite
            Write-Host "Top Site $sTopSite created" -ForegroundColor Green
            #We check if we have subsites to create under the top site
            if($sSubSites.Length -gt 0) {
                foreach ($sSubSite in $sSubSites){
                    Write-Host "Creating subsite $sSubSite" -ForegroundColor Green
                    New-SPWeb $sSiteCollectionUrl/$sTopSite/$sSubSite  -Template $sSiteTemplate -Name $sSubSite  -AddToQuickLaunch -UseParentTopNav
                    Write-Host "Subsite $sSubSite created succesfully" -ForegroundColor Green
                }        
            }
        }        
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Creating Sites Structure definition file
$sSitesStructureFileName="<File_Name>.xml"
Create-SiteStructureDefinition -sSitesStructureFileName $sSitesStructureFileName
#Creating Sites Structure
$sSiteCollectionUrl="http://<Site_Collection_Url>"
$sSiteTemplate="<Site_Template>"
Create-SitesStructure -sSiteCollectionUrl $sSiteCollectionUrl -sSiteTemplate $sSiteTemplate -sSitesStructureFileName $sSitesStructureFileName
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell