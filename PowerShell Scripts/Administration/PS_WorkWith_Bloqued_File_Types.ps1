############################################################################################################################################
# Script that allows to work with Blocked Files extensions for a SharePoint Web Application
# Required parameteres:
#   ->$sWebAppUrl: Web Application Url.
#   ->$sOperatitonType: Operation Type.
#   ->$sFileExtension: File extension to block / unblock.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }


#We make a good usage of PowerShell in terms of Performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to work with Blocked Files in SharePoint
function WorkWith-BlockedFileTypes
{
    param ($sOperationType,$sWebAppUrl,$sFileExtension)
    try
    {
        #Getting blocked extensions
        $spWebApplication=Get-SPWebApplication -Identity $sWebAppUrl
        $spBlockedFileExtensions=$spWebApplication.BlockedFileExtensions
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Blocked File Types in $sWebAppUrl" -ForegroundColor Green
            Write-Host "The number of Blocked File Typesin $sWebAppUrl is " $spBlockedFileExtensions.Count -ForegroundColor Green
            $iFileExtensionCounter=1
            foreach($spBlockedFileExtension in $spBlockedFileExtensions){
                Write-Host "Extensión # $iFileExtensionCounter :" $spBlockedFileExtension
                $iFileExtensionCounter+=1
                }
            }
        "Add"{
            Write-Host "Adding $sFileExtension file type as a blocked file type for $sWebAppUrl..." -ForegroundColor Green
            $spBlockedFileExtensions.Add($sFileExtension)
            $spWebApplication.Update()
            Write-Host "$sFileExtension file type has been added as a blocked file type for $sWebAppUrl..." -ForegroundColor Green
            WorkWith-BlockedFileTypes -sOperationType "Read" -sWebAppUrl $sWebAppUrl
            }
        "Remove"{            
            Write-Host "Removing $sFileExtension file type as a blocked file type for $sWebAppUrl..." -ForegroundColor Green
            $spExtensionRemoved=$spBlockedFileExtensions.Remove($sFileExtension)
            $spWebApplication.Update()
            Write-Host "$sFileExtension file type has been removed from the list of blocked file types for $sWebAppUrl..." -ForegroundColor Green
            WorkWith-BlockedFileTypes -sOperationType "Read" -sWebAppUrl $sWebAppUrl
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

# Required variables
$sWebAppUrl="http://<Url_Aplicacion_Web>"
$sFileExtension = "cs"

Start-SPAssignment –Global
#Read
WorkWith-BlockedFileTypes -sOperationType "Read" -sWebAppUrl $sWebAppUrl
#Add
WorkWith-BlockedFileTypes -sOperationType "Add" -sWebAppUrl $sWebAppUrl -sFileExtension $sFileExtension
#Remove
WorkWith-BlockedFileTypes -sOperationType "Remove" -sWebAppUrl $sWebAppUrl -sFileExtension $sFileExtension
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell