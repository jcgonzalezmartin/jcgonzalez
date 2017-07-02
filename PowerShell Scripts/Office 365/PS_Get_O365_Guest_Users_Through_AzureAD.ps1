############################################################################################################################################
# Script that allows to get all the members of all the Guest Users in an Office 365 tenant by means of Azure AD PowerShell cmdlets
# Required Parameters:
#  ->sCSVFilenName: Name of the file to be generated
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that get all the Guest Users in an Office 365 tenant through Azure AD PowerShell cmdlets and export the results to a CSV file
function Get-O365GuestsUsersThroughAzureAD
{   
    param($sCSVFileName) 
    Try
    {   
        [array]$O365GuestsUsers = $null
        $O365TenantGuestsUsers=Get-AzureADUser -Filter "Usertype eq 'Guest'”
        foreach ($O365GuestUser in $O365TenantGuestsUsers) 
        { 
            $O365GuestsUsers=New-Object PSObject
            $O365GuestsUsers | Add-Member NoteProperty -Name "Guest User DisplayName" -Value $O365GuestUser.DisplayName
            $O365GuestsUsers | Add-Member NoteProperty -Name "User Principal Name" -Value $O365GuestUser.UserPrincipalName
            $O365GuestsUsers | Add-Member NoteProperty -Name "Mail Address" -Value $O365GuestUser.Mail
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
Connect-AzureAD -Credential $O365Cred -Confirm:$true


$sCSVFileName="AllTenantGuestsUsers.csv"
#Getting Tenant Guests Users
Get-O365GuestsUsersThroughAzureAD -sCSVFileName $sCSVFileName
