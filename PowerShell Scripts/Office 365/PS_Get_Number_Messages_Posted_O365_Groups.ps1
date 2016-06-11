############################################################################################################################################
# Script that allows to get the number of messages posted in Office 365 Groups
# Required Parameters: N/A
############################################################################################################################################

#Definition of the function tthat allows to do work with Office 365 Groups using standard cmdlets for Groups
function ReadNumberMessagesPostedInOffice365Groups
{
    param ($sOperationType,$sGroupName,$sNewGroupName)       
    try
    {
        Write-Host "--------------------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Getting the number of messages posted in all Office 365 Groups in an Office 365 tenant" -foregroundcolor Green
        Write-Host "--------------------------------------------------------------------------------------"  -foregroundcolor Green
        Get-UnifiedGroup | Get-MailboxStatistics | Format-Table DisplayName, ItemCount, LastLogonTime

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}
$sUserName="juancarlos.gonzalez@fiveshareit.es"
$sMessage="Introduce your SPO Credentials"
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage
$msolSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $msolCred -Authentication Basic -AllowRedirection
Import-PSSession $msolSession

ReadNumberMessagesPostedInOffice365Groups



