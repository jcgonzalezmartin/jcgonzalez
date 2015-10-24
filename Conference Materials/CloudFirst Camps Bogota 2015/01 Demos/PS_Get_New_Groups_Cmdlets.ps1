############################################################################################################################################
# Script that allows to do work with Office 365 Groups. 
# Required Parameters: N/A
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to delete the Office 365 users contained in the CSV file.
function Get-Office365GroupsCredentials
{
    param ($msolCred)
    try
    {   
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting new Exchange Online Cmdlets." -foregroundcolor Green
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
        
        $PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $msolCred -Authentication Basic -AllowRedirection
        Import-PSSession $PSSession

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()   
    }         
}
#Connection to Office 365
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your Office 365 Credentials"
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage

Get-Office365GroupsCredentials -msolCred $msolCred