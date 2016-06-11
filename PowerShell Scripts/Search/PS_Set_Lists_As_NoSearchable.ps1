############################################################################################################################################
# Script that allows  to configure several lists as not searchable. Lists to be configured are read from a CSV file.
# Required Parameters:
#   ->$sSiteUrl: Site Url.
#   ->$sInputFile: CSV Input File.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good usage of PowerShell in terms of performacne
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to configure several lists as not searchable
function Set-SiteListsAsNoSearchable
{
    param ($sSiteUrl,$sInputFile)
    try
    {
        $spWeb=Get-SPWeb -Identity $sSiteUrl                  
        # Verifying if the CSV file exists
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile file for data processing..." 
            $tblData = Import-CSV $sInputFile            
        }else{ 
            Write-Host "$sInputFile file not found.Stopping the loading process!" -ForegroundColor Red
            exit 
        } 
        #Processing the file
        foreach ($row in $tblData) 
        { 
            $splList = $spWeb.Lists.TryGetList($row.ListName)
            If(($splList))
            {
                Write-Host "Set" $row.ListName "as not searchable" -ForegroundColor Green
                $splList.NoCrawl = $True
                $splList.Update()
            }
            else{
                Write-Host "List" $row.ListName "doesn't exist ..." -ForegroundColor Red
            }            
        }
        $spWeb.Dispose()         
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}
#
# Required Parameters
#
$sSiteUrl="http://<Site_Url>"
#Current Path
$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\Lists_To_Configure_As_No_Searchable.csv"

Start-SPAssignment –Global
Set-SiteListsAsNoSearchable -sSiteUrl $sSiteUrl -sListName $sListName -sInputFile $sInputFile
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell