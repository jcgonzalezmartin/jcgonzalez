############################################################################################################################################
# Script that allows to get the members for each Office 365 Group defined in an Office 365 tenant. 
# Required Parameters: N/A.
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that allows to get all the members of all the Office 365 Groups in a tenant
function Get-O365Members
{
    Try
    {   
        #Getting all the Office 365 Groups in the tenant        
        Write-Host "Getting all the members for each O365 Group in the tenant ..." -foregroundcolor Green    
        $O365Groups=Get-UnifiedGroup
        # Deleting the users
        Write-Host "Getting all the users per Group ..." -ForegroundColor Green    
        foreach ($O365Group in $O365Groups) 
        { 
            Write-Host "Members of Group: " $O365Group.DisplayName -ForegroundColor Green
            Get-UnifiedGroupLinks –Identity $O365Group.Identity –LinkType Members
            Write-Host
        } 
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

#Getting Groups Information
Get-O365Members

