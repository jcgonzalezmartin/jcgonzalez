############################################################################################################################################
# Script that allows to get all the members of all the Guest Users in an Office 365 tenant and export the results to a CSV file.
# Required Parameters:
#  ->sCSVFilenName: Name of the file to be generated
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that get all the Guest Users in an Office 365 tenant and export the results to a CSV file
function Get-O365GuestsUsers
{   
    param($sCSVFileName) 
    Try
    {   
        [array]$O365GuestsUsers = $null
        $O365TenantGuestsUsers=Get-Recipient -RecipientTypeDetails GuestMailUser #| Format-Table DisplayName, Name
        foreach ($O365GuestUser in $O365TenantGuestsUsers) 
        { 
            $O365GuestsUsers=New-Object PSObject
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User DisplayName" -Value $O365GuestUser.DisplayName
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User Name" -Value $O365GuestUser.Name
            $O365GuestsUsers | Add-Member NoteProperty -Name "SMTP Mail Address" -Value $O365GuestUser.PrimarySmtpAddress
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User Creation Date" -Value $O365GuestUser.WhenCreated 
            $O365AllGuestsUsers+=$O365GuestsUsers  
        } 
        $O365AllGuestsUsers | Export-Csv $sCSVFileName
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    } 
}


#Connection to Office 365
$sUserName="<Your_Office365_Admin_Account>"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$O365Cred=Get-Credential -UserName $sUserName -Message $sMessage
#Creating an EXO PowerShell session
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $PSSession


$sCSVFileName="AllTenantGuestsUsers.csv"
#Getting Tenant Guests Users
Get-O365GuestsUsers -sCSVFileName $sCSVFileName
