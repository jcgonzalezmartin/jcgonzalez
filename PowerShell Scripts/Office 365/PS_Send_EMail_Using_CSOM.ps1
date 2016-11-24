############################################################################################################################################
# Script that allows to send an e-mail using Client Side Object Model
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Online Site.
#  -> $sPassword: Password for the user.
#  -> $sSPOSiteUrl: SharePoint Online Site Url.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that sends an e-mail using Client Side Object Model
function Send-EMailUsingCSOM
{
    param ($sSPOSiteUrl,$sUserName,$sPassword,$sCSOMPath)
    try
    {            
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "Sending an E-Mail from a PowerShell Script using CSOM" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
     
        #Adding the Client OM Assemblies        
        $sCSOMRuntimePath=$sCSOMPath +  "\Microsoft.SharePoint.Client.Runtime.dll"        
        $sCSOMPath=$sCSOMPath +  "\Microsoft.SharePoint.Client.dll"
                     
        Add-Type -Path $sCSOMPath         
        Add-Type -Path $sCSOMRuntimePath        

        #SPO Client Object Model Context
        $spoCtx = New-Object Microsoft.SharePoint.Client.ClientContext($sSPOSiteUrl) 
        $spoCredentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($sUserName, $sPassword)  
        $spoCtx.Credentials = $spoCredentials 
        $spoEMailProperties=New-Object Microsoft.SharePoint.Client.Utilities.EmailProperties       
        $spoEMailProperties.BCC= [Collections.Generic.List[String]]@($sUserName)
        $spoEMailProperties.CC=[Collections.Generic.List[String]]@($sUserName)
        $spoEMailProperties.To=[Collections.Generic.List[String]]@($sUserName)
        $spoEMailProperties.From=$sUserName
        $spoEMailProperties.Body="<b>Test E-Mail from CSOM</b>"
        $spoEMailProperties.Subject="E-Mail sent from a PS Script using CSOM"
        #Micrososoft.SharePoint.Client.Utility.SendEmail($spoCtx, $spoEMailProperties)
        $spoUtility=[Microsoft.SharePoint.Client.Utilities.Utility]::SendEmail($spoCtx, $spoEMailProperties)       
        $spoCtx.ExecuteQuery()
        $spoCtx.Dispose()
        
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
        Write-Host "E-Mail from a PowerShell Script using CSOM was sent" -ForegroundColor Green
        Write-Host "----------------------------------------------------------------------------"  -ForegroundColor Green
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

#Required Parameters
$sSPOSiteUrl = "https://<SPOSite_Collection_Url>" 
$sUserName = "<O365User>@<O365Domain>.onmicrosoft.com" 
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword= ConvertTo-SecureString "<O365Password>" -AsPlainText -Force
$sCSOMPath="<CSOM_Path>"

Send-EMailUsingCSOM -sSPOSiteUrl $sSPOSiteUrl -sUserName $sUserName -sPassword $sPassword -sCSOMPath $sCSOMPath