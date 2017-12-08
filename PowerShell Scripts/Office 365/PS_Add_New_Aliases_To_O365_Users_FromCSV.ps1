############################################################################################################################################
# Script that allows to do a add users to add e-mail addresses to Office 365 users in bulk using the same UPN. The users are read from a CSV file. 
# The csv file only needs a column that stores the account principal name for each user to be added to Office 365
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $NewDomain: Domain of the new e-mail to be added to the user.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sInputFile: Message to show in the user credentials prompt.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add to Office 365 the list of users contained in the CSV file.
function Add-NewEMailAddressToUsers
{
    param ($sInputFile,$sNewDomain)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblUsers = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -ForegroundColor Red
            exit 
        }         
        
        # Deleting the users
        Write-Host "Adding new E-Mails to Office 365 Users ..." -ForegroundColor Green    
        foreach ($user in $tblUsers) 
        {             
            $sUPNPart=$user.UserPrincipalName.Split("@")[0]            
            $sNewEMailToAdd=$sUPNPart + $sNewDomain
             "Adding new E-Mail $sNewEMailToAdd to User " + $user.UserPrincipalName.ToString()  	
            Set-Mailbox -Identity $user.UserPrincipalName -EmailAddresses @{add=$sNewEMailToAdd}            
        } 

        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green
        Write-Host "All the e-mails have been added. The processs is completed." -ForegroundColor Green
        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    } 
}

#Connection to Office 365
$sUserName="<O365_Admin>"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365


$O365cred = Get-Credential -UserName $sUserName -Message $sMessage
$PSSession = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365cred -Authentication Basic -AllowRedirection
Import-PSSession $PSSession

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
#$sInputFile=$ScriptDir+ "\O365UsersToUpdate.csv"

$sNewDomain="@<YourDomain>.onmicrosoft.com"

Add-NewEMailAddressToUsers -sInputFile $sInputFile -sNewDomain $sNewDomain