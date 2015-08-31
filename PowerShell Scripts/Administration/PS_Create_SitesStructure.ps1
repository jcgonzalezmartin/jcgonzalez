############################################################################################################################################
# This script allows to create a site structure using a XML file that contains all the site structure to be created.
# Required Parameters: 
# -> $sSiteCollectionURL: Site Collection URL
# -> $sSiteTemplate: Site Template
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"# Se crea la aplicación del portal

#Function that creates the XML file containing the sites structure to be created
function CreateXMLFileWithSiteStructure
{    
    try
    {
        Write-Host "Creating XML File Definition with the Sites Structure" -ForegroundColor Green    
        "<Setup>
            <Sites>
                <TopSiteName>Sitio1</TopSiteName>
            </Sites>
            <Sites>
                <TopSiteName>Sitio2</TopSiteName>
                    <SubSiteName>Subsitio2a</SubSiteName>
                    <SubSiteName>Subsitio2b</SubSiteName>
            </Sites>
            <Sites>
                <TopSiteName>Sitio3</TopSiteName>
                    <SubSiteName>Subsitio3a</SubSiteName>
                    <SubSiteName>Subsitio3b</SubSiteName>
                    <SubSiteName>Subsitio3c</SubSiteName>
            </Sites>
        </Setup>" | out-file SitesStructure.xml 

    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}

#Function that creates the sites structure reading all the structure definition from a XML file
function CreateSiteStructure
{
    param ($sSiteCollectionURL,$sSiteTemplate)    
    try
    {
        Write-Host "Creating the Sites Structure" -ForegroundColor Green    
        #Leemos el archivo XML
        [xml]$xSiteStructure = Get-Content sample.xml

        foreach ($sTopSite in $xSiteStructure.Setup.Sites){
            $sTopSiteToCreate = $sTopSite.TopSiteName
            Write-Host "Creating site $sTopSiteToCreate" -ForegroundColor Green
            $sSubSitesToCreate = $sTopSite.SubSiteName
            New-SPWeb $sSiteCollectionURL/$sTopSiteToCreate -Template $sSiteTemplate -AddToTopNav -UseParentTopNav -Name $sTopSiteToCreate
            if($sSubSitesToCreate.Length -gt 0) {
                foreach ($sSubSiteToCreate in $sSubSitesToCreate){
                    Write-Host "Creating Subsite $sSubSiteToCreate"
                    New-SPWeb $sSiteCollectionURL/$sTopSiteToCreate/$sSubSiteToCreate -Template $sSiteTemplate -Name $sSubSiteToCreate -AddToQuickLaunch -UseParentTopNav
                }
            }
        }
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor red $_.Exception.ToString()
    }
}


Start-SPAssignment –Global
#
#Calling the functions
#

CreateXMLFileWithSiteStructure

#Required Parameteres
$sSiteCollectionURL="http://<SharePoint_Site_Collection_Url>"
$sSiteTemplate="STS#1"
CreateSiteStructure -sSiteCollectionURL $sSiteCollectionURL -sSiteTemplate $sSiteTemplate

Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell  
