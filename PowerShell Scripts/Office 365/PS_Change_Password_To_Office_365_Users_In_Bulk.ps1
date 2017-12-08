############################################################################################################################################
# Script that allows to set a default password to serveral users in your Office 365 tenants. The users are read from a CSV file. 
# The csv file only needs a column that stores the account principal name for each user to be added to Office 365.
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sDefaultPassword: Common password to be set for all the users in the CSV file.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sInputFile: Message to show in the user credentials prompt.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add to Office 365 the list of users contained in the CSV file.
function Set-PasswordToUsers
{
    param ($sInputFile,$sDefaultPassword)
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
        Write-Host "Changing password for Office 365 user..." -ForegroundColor Green    
        foreach ($user in $tblUsers) 
        {   
            Write-Host "Changing password for user " $user.UserPrincipalName.ToString()  	          
            Set-MsolUserPassword -UserPrincipalName $user.UserPrincipalName -NewPassword $sDefaultPassword -ForceChangePassword $true           
        } 

        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green
        Write-Host "All passwords have been updated. The processs is completed." -ForegroundColor Green
        Write-Host "-----------------------------------------------------------"  -ForegroundColor Green
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    } 
}

#Connection to Office 365
$sUserName="<O365_Admin>
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$O365Cred = Get-Credential -UserName $sUserName -Message $sMessage

Connect-MsolService -Credential $O365Cred

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\O365UsersToUpdate.csv"

$sDefaultPassword="<Default_Password>"

Set-PasswordToUsers -sInputFile $sInputFile -sDefaultPassword $sDefaultPassword