############################################################################################################################################
# This script allows to re-start all the SharePoint Timer Service instances in a SharePoint Farm
# Required Parameters: N/A
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#
#Definition of the function that allows to re-start all the SharePoint Timer Service instances in a SharePoint Farm
function Re-StartSPTimerService
{
    try
    {
        $spFarm=Get-SPFarm
        $spfTimerServcicesInstances=$spFarm.TimerService.Instances        
        foreach ($spfTimerServiceInstance in  $spfTimerServcicesInstances)
        {
            Write-Host "Re-starting the instance " $spfTimerServiceInstance.TypeName
            $spfTimerServiceInstance.Stop()
            $spfTimerServiceInstance.Start()
            Write-Host "SharePoint Timer Service Instance" $spfTimerServiceInstance.TypeName "Re-Started"
        }
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
#Calling the function
Re-StartSPTimerService
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell