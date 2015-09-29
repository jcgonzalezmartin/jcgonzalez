If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Variables auxiliares
$sSiteCollectionURL="http://c7370309033:300/sites/PowerShellSite"
$sPlantillaSitio="STS#1"
#Leemos el archivo XML
[xml]$s = Get-Content SitesStructure.xml

#Hacemos un buen uso de PowerShell par ano penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"


Start-SPAssignment –Global

foreach ($e in $s.Setup.Sites){
    $v = $e.TopSiteName
    $b = $e.SubSiteName
    New-SPWeb $sSiteCollectionURL/$v -Template $sPlantillaSitio -AddToTopNav -UseParentTopNav -Name $v
    if($b.Length -gt 0) {
        foreach ($b in $b){
            New-SPWeb $sSiteCollectionURL/$v/$b -Template $sPlantillaSitio -Name $b -AddToQuickLaunch -UseParentTopNav
        }
    }
}


Stop-SPAssignment –Global 