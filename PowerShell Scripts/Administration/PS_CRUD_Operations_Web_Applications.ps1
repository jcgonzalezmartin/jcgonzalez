############################################################################################################################################
# Script that allows to do CRUD operations at the Web Application Level
# Required Parameters:
#   ->$sOperationType: Operation Type
#   ->$sWebAppName: Web Application Name
#   ->$sWebAppUrl: Web Application Url
#   ->$iWebAppPort: Web Application Port
#   ->$sWebAppPoolName: Application Pool Name
#   ->$sWebAppAppPoolUserAccount: Application Pool Account
#   ->$sDBServer: Database Server Name
#   ->$sWebAppDBName: Content Database Name
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#We make a good use of PowerShell in terms of Performance
$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to make CRUD operations at the Web Application Level
function WorkWith-WebApps
{
    param ($sOperationType,$sWebAppName,$sWebAppUrl,$iWebAppPort,$sWebAppPoolName,$sWebAppAppPoolUserAccount,$sDBServer,$sWebAppDBName)
    try
    {
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Web Applications in the Farm" -ForegroundColor Green
            Get-SPWebApplication -IncludeCentralAdministration

            }
        "Create"{
            Write-Host "Creating Web Application $sWebAppName..." -ForegroundColor Green
            $spAuthProvider = New-SPAuthenticationProvider -UseWindowsIntegratedAuthentication -DisableKerberos
            $spWebAppPoolAccount=Get-SPManagedAccount $sWebAppAppPoolUserAccount
            New-SPWebApplication -Name $sWebAppName -ApplicationPool $sWebAppPoolName -ApplicationPoolAccount  $spWebAppPoolAccount -Port $iWebAppPort -Url $sWebAppUrl -AuthenticationProvider $spAuthProvider -DatabaseServer $sDBServer -DatabaseName $sWebAppDBName
            Write-Host "Web Application $sWebAppName successfully created!!!" -ForegroundColor Green
            }
        "Update"{
            #Actualización de Aplicación Web
            Write-Host "Updating the following properties of $sWebAppName Web Application : Tamaño de carga, MIME Types, ..." -ForegroundColor Green
            $spWebApp = Get-SPWebApplication -Identity ($sWebAppUrl + ":" + $iWebAppPort)
            $spWebApp.MaximumFileSize = 300
            $spWebApp.AllowedInlineDownloadedMimeTypes.Add("application/x-shockwave-flash") 
            $spWebApp.Update()        
            Get-SPWebApplication -Identity ($sWebAppUrl + ":" + $iWebAppPort) | select DisplayName, Url, UseClaimsAuthentication, MaximumFileSize
            }
        "Delete"{
            Write-Host "Deleting Web Application $sWebAppName  ..." -ForegroundColor Green
            Remove-SPWebApplication -Identity ($sWebAppUrl + ":" + $iWebAppPort) -DeleteIISSite -RemoveContentDatabase -Confirm:$true
            Write-Host "Web Application $sWebAppName successfully removed..." -ForegroundColor Green
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
$sWebAppName = "<Web_App_Name>"
$sWebAppUrl="http://<Web_App_Url>"
$iWebAppPort = 500 
$sWebAppPoolName = "<Application_Pool_Name>" 
$sWebAppPoolUserAccount = "<Application_Pool_Account>"
$sWebAppDBName = "<Content_DB_Name>"
$sDBServer = "<DB_Server>"

Start-SPAssignment –Global
#Read
WorkWith-WebApps -sOperationType "Read"
WorkWith-WebApps -sOperationType "Create" -sWebAppName $sWebAppName -sWebAppUrl $sWebAppUrl -iWebAppPort $iWebAppPort -sWebAppPoolName $sWebAppPoolName -sWebAppPoolUserAccount $sWebAppPoolUserAccount -sDBServer $sDBServer -sWebAppDBName $sWebAppDBName
#WorkWith-WebApps -sOperationType "Update" -sWebAppName $sWebAppName -sWebAppUrl $sWebAppUrl -iWebAppPort $iWebAppPort
#WorkWith-WebApps -sOperationType "Delete" -sWebAppName $sWebAppName -sWebAppUrl $sWebAppUrl -iWebAppPort $iWebAppPort
WorkWith-WebApps -sOperationType "Read"
Stop-SPAssignment –Global

Remove-PSSnapin Microsoft.SharePoint.PowerShell