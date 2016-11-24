############################################################################################################################################
#Script that allows to add Users to a SPO Group
# Required Parameters:
#  -> $sUserName: User Name to connect to the SharePoint Admin Center.
#  -> $sMessage: Message to show in the user credentials prompt.
#  -> sInputFile: CSV File with the Site Collections information.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to add a user to a Group in a SharePoint Online Site
function Add-SPOUsersToGroup
{
    param ($sSiteColUrl,$sGroup,$sUserToAdd)
    try
    {    
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "Adding $sUserToAdd as member of $Group in $sSiteColUrl" -Foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        
        Add-SPOUser -Site $sSiteColUrl -LoginName $sUserToAdd -Group $sGroup 
                
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
        Write-Host "User $sUserToAdd succesfully added to $sSiteColUrl !!!" -Foregroundcolor Green
        Write-Host "----------------------------------------------------------------------------"  -foregroundcolor Green
    }
    catch [System.Exception]
    {
        Write-Host -Foregroundcolor Red $_.Exception.ToString()   
    }    
}

#Function that allows to add users to SharePoint Groups in different Site Collections.
#The information about the Site Collection, SharePoint Group and User to be added is read from a CSV file
function Add-SPOUsersToGroupFromCSV
{
    param ($sInputFile)
    try
    {   
        # Reading the Users CSV file
        $bFileExists = (Test-Path $sInputFile -PathType Leaf) 
        if ($bFileExists) { 
            "Loading $sInputFile for processing..." 
            $tblUsers = Import-CSV $sInputFile            
        } else { 
            Write-Host "$sInputFile file not found. Stopping the import process!" -foregroundcolor Red
            exit 
        }

    
        # Adding Users To Groups
        foreach ($spoUser in $tblUsers) 
        { 
          
            #$spoUser.SPOSCollection + $spoUser.SPOGroup 
            Add-SPOUsersToGroup -sSiteColUrl $spoUser.SPOSCollection -sGroup $spoUser.SPOGroup -sUserToAdd $spoUser.SPOUserLogin
        } 
    }
    catch [System.Exception]
    {
        Write-Host -Foregroundcolor Red $_.Exception.ToString()   
    } 
}
 
$sUserName = "<O365AdminUser>@<O365Domain>.onmicrosoft.com"
#$sPassword = Read-Host -Prompt "Enter your password: " -AsSecureString  
$sPassword=ConvertTo-SecureString "<UserPassord>" -asplaintext -force
$sSPOAdminCenterUrl="https://<O365Domain>-admin.sharepoint.com/"
$msolcred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-SPOService -Url $sSPOAdminCenterUrl -Credential $msolcred

$ScriptDir = Split-Path -parent $MyInvocation.MyCommand.Path
$sInputFile=$ScriptDir+ "\<File_Name>.csv"

Add-SPOUsersToGroupFromCSV -sInputFile $sInputFile