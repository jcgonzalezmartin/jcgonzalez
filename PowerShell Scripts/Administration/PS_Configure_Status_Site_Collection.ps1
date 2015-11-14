############################################################################################################################################
# Script that allows to read and configure ReadOnly, WriteLocked y ManteinanceMode properties for a Site Collection
# Required Parameters: 
#    ->$sSiteCollectionUrl: Site Collection Url.
#    ->$sOperationType: Operation Type.
#    ->$sReadOnlyMode: Value for the ReadOnly property.
#    ->$sWriteLocked: Value for the WriteLocked property.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to modify read and configure ReadOnly, WriteLocked y ManteinanceMode properties
function ReadModify-SPSiteProperties
{
    param ($sSiteCollectionUrl,$sOperationType,$sReadOnlyMode,$sWriteLocked)
    try
    {
        $spSite=Get-SPSite -Identity $sSiteCollectionUrl        
        #Operation Type
        switch ($sOperationType) 
        { 
        "ReadProperties" {
            Write-Host "Values for ReadOnly, ManteinanceMode and WriteLocked properties for $sSiteCollectionUrl" -ForegroundColor Green
            Write-Host "Value for ReadOnly Property: " $spSite.ReadOnly -ForegroundColor Green
            Write-Host "Value for MaintenanceMode Property: " $spSite.MaintenanceMode -ForegroundColor Green
            Write-Host "Value for WriteLocked Property: " $spSite.WriteLocked -ForegroundColor Green
            } 
        "ReadOnly" {
            Write-Host "Modifying ReadOnly property for $sSiteCollectionUrl to $sReadOnlyMode" -ForegroundColor Green
            $spSite.ReadOnly=$sReadOnlyMode            
            Write-Host "Value for ReadOnly Property: " $spSite.ReadOnly -ForegroundColor Green  
            ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "ReadProperties"       
            }         
        "WriteLocked" {
            Write-Host "Modifying WriteLocked property for $sSiteCollectionUrl to $sWriteLocked" -ForegroundColor Green
            $spSite.WriteLocked=$sWriteLocked
            Write-Host "Value for WriteLocked Property: " $spSite.WriteLocked -ForegroundColor Green  
            ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "ReadProperties"                     
            }  
        default {
            Write-Host "Requested operation is not valid" -ForegroundColor Green          
            }
        }   	
        $spSite.Dispose()
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}
Start-SPAssignment –Global
#Calling the function
$sSiteCollectionUrl="http://c7370309033:300/sites/CompartiMOSSBooks"
ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "ReadProperties"
ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "ReadOnly" -sReadOnlyMode $true
ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "ReadOnly" -sReadOnlyMode $false
ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "WriteLocked" -sWriteLocked $true
ReadModify-SPSiteProperties -sSiteCollection $sSiteCollectionUrl -sOperationType "WriteLocked" -sWriteLocked $false
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell