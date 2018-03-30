############################################################################################################################################
# Script that allows to do get a e-mail forwarding configuration for a user/shared mailbox or all the e-mail forwardings for all the user mailboxes and
# shared Mailboxes in a tenant.
# Required Parameters: 
#    -> $sOperationType
#    -> $sUserName
############################################################################################################################################

#Definition of the function that allows to do get a e-mail forwarding configuration for a user/shared mailbox or all the e-mail forwardings for all the user mailboxes and Shared Mailboxes in a tenant.
function Get-ConfiguredMailForwarding
{
    param ($sOperationType,$sUserName)       
    try
    {
        switch ($sOperationType) 
        { 
        "SingleMailBox" {
            Write-Host "Get e-mail forwarding configuration for $sUserName" -ForegroundColor Green                        
            Get-Mailbox -Identity $sUserName | Format-Table DisplayName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward
            } 
        "All" {
            Write-Host "Get-email forwarding configuration for all the user/shared mailboxes in a tenant" -ForegroundColor Green                 
            Get-Mailbox -RecipientTypeDetails UserMailbox, SharedMailbox | ? {$_.ForwardingAddress –ne $Null -or $_.ForwardingSmtpAddress -ne $Null} | Format-Table DisplayName, ForwardingAddress, ForwardingSmtpAddress, DeliverToMailboxAndForward 
            }        
        default {
            Write-Host "Requested Operation not valid!!" -ForegroundColor DarkBlue            
            }
        }
    }
    catch [System.Exception]
    {
        Write-Host -ForegroundColor red $_.Exception.ToString()
    }
}
$sUserName="jcgonzalez@nuberosnet.onmicrosoft.com"
$sMessage="Introduce your Office 365 Credentials"
$O365Cred = Get-Credential -UserName $sUserName -Message $sMessage
$EXOSession= New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $O365Cred -Authentication Basic -AllowRedirection
Import-PSSession $EXOSession

#Single User/Shared MailBox
$sOperationType="SingleMailBox"
Get-ConfiguredMailForwarding -sOperationType $sOperationType -sUserName $sUserName

#All Users/Shared MailBoxes
$sOperationType="All"
Get-ConfiguredMailForwarding -sOperationType $sOperationType

