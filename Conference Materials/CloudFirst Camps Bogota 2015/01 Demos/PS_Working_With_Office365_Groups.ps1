############################################################################################################################################
# Script that allows to do work with Office 365 Groups using standard cmdlets for Groups
# Required Parameters: N/A
############################################################################################################################################


#Definition of the function tthat allows to do work with Office 365 Groups using standard cmdlets for Groups
function WorkWith-Office365Groups
{
    param ($sOperationType,$sGroupName,$sNewGroupName)       
    try
    {
        switch ($sOperationType) 
        { 
        "Read" {
            Write-Host "Get all the Office 365 Groups in a tenant" -ForegroundColor Green                        
            Get-UnifiedGroup
            } 
        "Create" {
            Write-Host "Creating a new Office 365 Group" -ForegroundColor Green                 
            New-UnifiedGroup –DisplayName $sGroupName
            Get-UnifiedGroup
            }
        "Update" {
            Write-Host "Updating an Office 365 Group" -ForegroundColor Green                 
            #The change in the name can be seen in the O365 Admin Portal
            Set-UnifiedGroup -Identity $sGroupName -DisplayName $sNewGroupName
            Get-UnifiedGroup
            } 
        "Remove" {
            Write-Host "Removing an Office 365 Group" -ForegroundColor Green     
            Remove-UnifiedGroup -Identity $sGroupName
            Get-UnifiedGroup
            }           
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }

    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

#Connection to Office 365
$sUserName="<O365User>@<O365Domain>.onmicrosoft.com"
$sMessage="Introduce your Office 365 Credentials"
#Connection to Office 365
$msolCred = Get-Credential -UserName $sUserName -Message $sMessage
Connect-MsolService -credential $msolCred

Write-Host "-----------------------------------------------------------"  -foregroundcolor Green
Write-Host "Working with Groups through PowerShell." -foregroundcolor Green
Write-Host "-----------------------------------------------------------"  -foregroundcolor Green

##Read
$sOperationType="Read"
$sGroupName="O365 PowerShell Group"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName


##Create
$sOperationType="Create"
WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName

##Update
$sOperationType="Update"
$sNewGroupName="O365 PowerShell Group Updated"
#WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sGroupName -sNewGroupName $sNewGroupName

##Remove
$sOperationType="Remove"
$sNewGroupName="O365 PowerShell Group Updated"
#WorkWith-Office365Groups -sOperationType $sOperationType -sGroupName $sNewGroupName

