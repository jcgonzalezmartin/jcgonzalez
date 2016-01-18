############################################################################################################################################
# Script that allows to start/stop the Sandbox Code Service in a SharePoint Farm
# Required Parameters: 
#    ->$sServiceName: Name of the Service to be started / stopped.
#    ->$sOperationType: Operation Type.
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to Start/Stop the Sandbox Code Service in a SharePoint Farm
function StartStop-SandBoxService
{
    param ($sOperationType,$sSandBoxServiceName)
    try
    {    
        #Getting SandBox Code Service Instance running on the server
        $spSandBoxServiceInstance=Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object {$_.TypeName -eq $sSandBoxServiceName}   
        #Operation Type
        switch ($sOperationType) 
        { 
        "Start" {
            Write-Host "Starting $sSandBoxServiceName in the Farm" -ForegroundColor Green
            $spSandBoxServiceInstance=Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object {$_.TypeName -eq $sSandBoxServiceName}
            Start-SPServiceInstance -Identity $spSandBoxServiceInstance.Id -Confirm:$false
            Write-Host "$sSandBoxServiceName started in the Farm" -ForegroundColor Green
            } 
        "Stop" {
            Write-Host "Stopping $sSandBoxServiceName in the Farm" -ForegroundColor Green
            $spSandBoxServiceInstance=Get-SPServiceInstance -Server $env:COMPUTERNAME | Where-Object {$_.TypeName -eq $sSandBoxServiceName}
            Stop-SPServiceInstance -Identity $spSandBoxServiceInstance.Id -Confirm:$false
            Write-Host "$sSandBoxServiceName stopped in the Farm" -ForegroundColor Green     
            }         
        default {
            Write-Host "Requested operation is not valid" -ForegroundColor Green          
            }
        }   	  
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()
    }
}
Start-SPAssignment –Global
#Calling the function
$sSandBoxServiceName=“Microsoft SharePoint Foundation Sandboxed Code Service”
#StartStop-SandBoxService -sSandBoxServiceName $sSandBoxServiceName -sOperationType "Start"
StartStop-SandBoxService -sSandBoxServiceName $sSandBoxServiceName -sOperationType "Stop"
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell