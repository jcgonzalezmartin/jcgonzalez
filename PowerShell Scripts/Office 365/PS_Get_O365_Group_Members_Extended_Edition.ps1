############################################################################################################################################
# Script that allows to gget all the members of all the Groups in an Office 365 tenant and export the results to a CSV file.
# Required Parameters:
#  ->sCSVFilenName: Name of the file to be generated
############################################################################################################################################

$host.Runspace.ThreadOptions = "ReuseThread"

#Definition of the function that get all the members of all the Groups in an Office 365 tenant and export the results to a CSV file
function Get-O365MembersExtended
{   
    param($sCSVFileName) 
    Try
    {   
        [array]$O365GroupsMembers = $null
        $O365Groups=Get-UnifiedGroup -ResultSize Unlimited
        foreach ($O365Group in $O365Groups) 
        { 
            $O365GroupPeople=Get-UnifiedGroupLinks -Identity $O365Group.Name -LinkType Members
            
            foreach ($O365Member in $O365GroupPeople) 
            {
                $O365GroupsMembers=New-Object PSObject
                $O365GroupsMembers | Add-Member NoteProperty -Name "Group Name" -Value $O365Group.DisplayName
                $O365GroupsMembers | Add-Member NoteProperty -Name "Group Owners" -Value $O365Group.ManagedBy
                $O365GroupsMembers | Add-Member NoteProperty -Name "Member Name" -Value $O365Member.Name
                $O365GroupsMembers | Add-Member NoteProperty -Name "Member E-Mail" -Value $O365Member.PrimarySMTPAddress
                $O365GroupsMembers | Add-Member NoteProperty -Name "Recipient Type" -Value $O365Member.RecipientType
                $O365GroupsAllMembers+=$O365GroupsMembers                    
            }
        } 
        $O365GroupsAllMembers | Export-Csv $sCSVFileName
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

$sCSVFileName="AllO365GroupsMembers.csv"
#Getting Groups Information
Get-O365MembersExtended -sCSVFileName $sCSVFileName
