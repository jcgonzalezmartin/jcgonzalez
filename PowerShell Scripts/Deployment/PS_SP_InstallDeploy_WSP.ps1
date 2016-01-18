############################################################################################################################################
# Script para hacer el deploy del WSP de laUI de la solución de gestión de averías.
# Parámetros necesarios:
#   ->$sSolutionName: Nombre de la solución.
#   ->$sWebAppUrl: Url de la Aplicación Web dónde se va a desplegar la solución
#   ->$sFeatureName: Nombre de la feature a activar
#   ->$sSiteCollecionUrl: Url de la colección de sitios 
############################################################################################################################################

If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell par ano penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"

#Función que permite esperar a la ejecución del Timer Job
function WaitForJobToFinish([string]$sSolutionName)
{ 
    $JobName = "*solution-deployment*$sSolutionName*"
    $job = Get-SPTimerJob | ?{ $_.Name -like $JobName }
    if ($job -eq $null) 
    {
        Write-Host 'Timer job no encontrado'
    }
    else
    {
        $JobFullName = $job.Name
        Write-Host -NoNewLine "Esperando a que finalice el Timer Job $JobFullName"
        
        while ((Get-SPTimerJob $JobFullName) -ne $null) 
        {
            Write-Host -NoNewLine .
            Start-Sleep -Seconds 2
        }
        Write-Host  "Finalizada la espera para el Timer Job.."
    }
}

#Función que comprueba si la solución existe
function CheckSolutionExist([string] $sSolutionName)
{
    $spFarm = Get-SPFarm
    $spSolutions = $spFarm.Solutions
    $bExists = $false
 
    foreach ($spSolution in $spSolutions)
    {
        if ($spSolution.Name -eq $sSolutionName)
        {
            $bExists = $true
            return $bExists
            break
        }
    }
    return $bExists
}

#Función que desinstala la solución
function UninstallRemoveSolution([string] $sSolutionName, [string] $sWebAppUrl)
{
    $sSolution=Get-SPSolution $sSolutionName
    Write-Host 'Desinstalando la solución $sSolutionName'
    if ( $sSolution.ContainsWebApplicationResource ) {
        Uninstall-SPSolution -Identity $sSolutionName -Confirm:$false -Webapplication $sWebAppUrl        
    }
    else {
        Uninstall-SPSolution -Identity $sSolutionName -Confirm:$false
    }
    Write-Host 'Esperando a que finalice el Timer Job'
    WaitForJobToFinish 
    
    Write-Host 'Eliminando la solución $solutionName'

    Remove-SPSolution -identity $sSolutionName -confirm:$false

}

#Función que instala la solución
function AddInstallSolution([string] $sSolutionName, [string] $sSolutionPath, [string] $sWebAppUrl)
{
    Write-Host 'Añadiendo la solución $sSolutionName'
    $sSolution=Add-SPSolution $sSolutionPath
    
    if ( $sSolution.ContainsWebApplicationResource ) {
        Install-SPSolution –identity $sSolutionName –GACDeployment -WebApplication $sWebAppUrl     
    }
    else {
        Install-SPSolution –identity $sSolutionName –GACDeployment -Force
    }
    Write-Host 'Esperando a que finalice el Timer Job' 
    WaitForJobToFinish 

}

#Definición de la función que permite activar/desactivar una feature -> Site Collection Level
#Activar/Desactivar la característica según corrresponda
function EnableDisableFeature
{
    param ($sSiteCollectionUrl,$sFeatureName)
    try
    {
       $spSite=Get-SPSite -Identity $sSiteCollectionUrl
	   $spFeature=Get-SPFeature -Site $spSite | Where-object {$_.DisplayName -eq $sFeatureName}
       #Comprobamos si la feature existe
	   if($spFeature -ne $null)
	   {
            Write-host "La feature $sFeatureName ya está activada en el sitio $sSiteCollectionUrl .Deesactivando la feature ..." -f blue
            Disable-SPFeature –identity $sFeatureName -Url $sSiteCollectionUrl -Confirm:$false
            Write-host "Activando la feature $sFeatureName en el sitio $sSiteCollectionUrl ..." -f green
            Enable-SPFeature –identity $sFeatureName -Url $sSiteCollectionUrl		
	   }
	   else
	   {
            Write-host "La feature $sFeatureName no está activada en el sitio $sSiteCollectionUrl .Activando la feature ..." -f blue
            Enable-SPFeature –identity $sFeatureName -Url $sSiteCollectionUrl
	   }            
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    } 	
}

#..............................................................................
#Proceso para instalar la solución
#..............................................................................

#Variables Comunes
$sCurrentDir=Split-Path -parent $MyInvocation.MyCommand.Path
$sWebAppUrl="http://<Url_Aplicacion_Web/"
$sSiteCollectionUrl="http://<Url_Coleccion_Sitios>/"


#WebParts para gestión de Expedientes y Siniestros
$sSolutionName="<NombreSolucion>.wsp"
$sFeatureName="<Nombre_Feature>"
$sSolutionPath=$sCurrentDir + "\"+$sSolutionName 

$bSolutionFound=CheckSolutionExist -sSolutionName $sSolutionName

if($bSolutionFound)
{
    Write-Host "La solución $sSolutionName existe en la granja"
    UninstallRemoveSolution -sSolutionName $sSolutionName -sWebAppUrl $sWebAppUrl
}

#Instalación de la solución
AddInstallSolution -sSolutionName $sSolutionName -sSolutionPath $sSolutionPath -sWebAppUrl $sWebAppUrl
#Activar Feature
EnableDisableFeature -sSiteCollectionUrl $sSiteCollectionUrl -sFeatureName $sFeatureName

Remove-PSSnapin Microsoft.SharePoint.PowerShell

