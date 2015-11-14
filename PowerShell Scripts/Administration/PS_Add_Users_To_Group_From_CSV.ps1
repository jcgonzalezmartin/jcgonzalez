############################################################################################################################################
# Script that allows to load users to SharePoint Groups in a SharePoint site reding the information from a CSV File
# Required Parameters:
#   ->$sSiteCollectionUrl: Site Collection Url
#   ->$sInputFile: File with the data to be loaded
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to load users to SharePoint Groups in a SharePoint site reding the information from a CSV File
function Load-UsersFromCSV
{
    param ($sInputFile, $sSiteCollectionUrl) 
    try
    {
        # Checking the file exists
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            Write-Host "Loading $sInputFile file for processing..." -ForegroundColor Green
            $tblDatos = Import-CSV $sInputFile            
        } else { 
            Write-Host "¡File $sInputFile not found. Stopping the import process!" -ForegroundColor Red
            exit 
        }
        
        $spSite = Get-SPSite -Identity $sSiteCollectionUrl
        $spWeb = $spSite.OpenWeb()        
        foreach ($row in $tblData){      
            $spGroup=$spWeb.SiteGroups[$row.Group.ToString()]
            $spUser=$spWeb.EnsureUser($row.UserAccount)
            $spGroup.AddUser($spUser)
            write-Host "User $spUser successfully added to $spGroup Group" -ForegroundColor Green            
        } 
        $spSite.Dispose()
        $spWeb.Dispose() 
    }
    catch [System.Exception]
    {
        write-host -ForegroundColor Red $_.Exception.ToString()
    }
}

#Variables necesarias
$sSiteCollectionUrl = “http://<Site_Colecction_Url>”
#Archivo con los Usuarios
$sScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$sScriptDir+ "\Users.csv"
Start-SPAssignment –Global
Load-UsersFromCSV -sInputFile $sInputFile  -sSiteCollectionUrl $sSiteCollectionUrl
Stop-SPAssignment –Global
Remove-PsSnapin Microsoft.SharePoint.PowerShell