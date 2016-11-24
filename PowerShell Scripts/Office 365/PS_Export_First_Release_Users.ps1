############################################################################################################################################
# Script that allows to list of users to whom First Release has been configured in an Office 365 Tenant
# Required Parameters:
#  -> $sUserName: User Name to connect to Office 365.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> $sOutputFile: CSV File with the First Release Users exported.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to export users configured in First Release
function Get-FirstReleaseUsers
{
    param ($sOutputFile)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -Foregroundcolor Green
        Write-Host "Getting all First Relase Users in Office 365" -Foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -Foregroundcolor Green
        
        $FirsReleaseUsers= Get-MsolUser | Where-Object { $_.ReleaseTrack -like "StagedRolloutOne"}|select Displayname,UserPrincipalName        
        $FirsReleaseUsers
        $FirsReleaseUsers | Export-csv -Path $sOutputFile -NoTypeInformation

    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor Red $_.Exception.ToString()   
    }    
}

$sUserName = "<O365Admin>@<O465Domain>.onmicrosoft.com"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString 
$sPassword=ConvertTo-SecureString "<User_Password>" -asplaintext -force
$msolcred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-MsolService -Credential $msolcred

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sOutputFile = $ScriptDir+ "\PS_FirstRelaseUsers.csv"

Get-FirstReleaseUsers -sOutputFile $sOutputFile