############################################################################################################################################
# Script that allows to get the # of Chat Items in a Group MailBox
# Required Parameters:
#  -> $sOffice365GroupIdentity: The Identity of the Office 356 Group.
#  -> $sPassword: Password for the user.
#  -> $sSiteColUrl: Site Collection Url.
#  -> $sCSOMPath: Path for the CSOM assemblies.
############################################################################################################################################

function Get-ChatItemsInTeamsGroup
{
    param ($sOffice365GroupIdentity)
    try
    { 
        $Office365GroupStatistics=Get-MailboxFolderStatistics -Identity $sOffice365GroupIdentity
        foreach ($Office365GroupStatistic in $Office365GroupStatistics){
        if($Office365GroupStatistic.Name -eq "Team Chat"){
            Write-Host "Number of chats stored for $sOffice365GroupIdentity is: " $Office365GroupStatistic.ItemsInFolder
            }
        }
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }   
}


$sUserName="<Office365User>@<O365Domain>"
$sMessage="Introduce your O365 Credentials"
$Cred=Get-Credential -UserName $sUserName -Message $sMessage
#Creating an EXO PowerShell session
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $Cred -Authentication Basic -AllowRedirection
Import-PSSession $PSSession

$sOffice365GroupIdentity="<O365GroupAlias>@<Office365Domain>"
Get-ChatItemsInTeamsGroup -sOffice365GroupIdentity $sOffice365GroupIdentity


