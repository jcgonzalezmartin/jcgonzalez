############################################################################################################################################
# Script that allows to do a massive deletion of Office 365 users. The users are read from a CSV file. 
# The csv file only needs a column that stores the account principal name to be deleted in each iteration.
# Required Parameters:
#    ->$sInputFile: Name of the file with the users to be deleted.
#    ->$sColumName: Name of the reference column to be used when reading the file
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Connection to Office 365
#$msolcred = Get-Credential
Connect-MsolService -Credential $msolcred

#Definition of the function that allows to delete the Office 365 users contained in the CSV file.
function Remove-Office365Users
{
    param ($sInputFile,$sColumnName)
    try
    {
            # Reading the CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $InvFile for processing..." 
            $tblDatos = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -ForegroundColor Red
            exit 
        }         
        # Deleting the users
        Write-Host "Deleting the Office 365 users ..." -foregroundcolor Green    
        foreach ($fila in $tblDatos) 
        { 
            "Deleting user " + $fila.$sColumnName.ToString()            
            Get-MsolUser -UserPrincipalName $fila.$sColumnName #| Remove-MsolUser -Force -RemoveFromRecycleBin
        } 

        Write-Host "-----------------------------------------------------------"  -foregroundcolor Blue
        Write-Host "All the users have been deleted. The processs is completed." -foregroundcolor Blue
        Write-Host "-----------------------------------------------------------"  -foregroundcolor Blue
        }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }  

}

#$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$ScriptDir = $PSScriptRoot
$sInputFile=$ScriptDir+ "\<UsersToDeleteFile>.csv"
$sColumnName="UserPrincipalName"
Remove-Office365Users -sInputFile $sInputFile -sColumnName $sColumnName